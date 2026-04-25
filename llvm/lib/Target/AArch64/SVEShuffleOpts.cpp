//===------- SVEShuffleOpts - SVE Shuffle Optimization --------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Tries to pattern match and combine scalable vector shuffles that could
// be more efficiently performed by tbl instructions.
// TODO: Also handle bottom/top (de)interleaving.
//
//===----------------------------------------------------------------------===//

#include "AArch64.h"
#include "AArch64Subtarget.h"
#include "AArch64TargetMachine.h"
#include "Utils/AArch64BaseInfo.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/IntrinsicsAArch64.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/InitializePasses.h"
#include <optional>

using namespace llvm;
using namespace llvm::PatternMatch;

#define DEBUG_TYPE "aarch64-sve-shuffle-opts"

namespace {

class SVEShuffleImpl {
  const AArch64TargetMachine *TM = nullptr;
  const LoopInfo *LI = nullptr;

public:
  SVEShuffleImpl() {};
  SVEShuffleImpl(const AArch64TargetMachine *TM) : TM(TM) {};

  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM);
  bool runOnFunction(Function &F, Pass &P);

private:
  bool processLoop(Loop *L);
};

struct SVEShuffleOpts : public FunctionPass {
  SVEShuffleImpl Impl;
  static char ID; // Pass identification, replacement for typeid
  SVEShuffleOpts() : FunctionPass(ID) {}

  bool runOnFunction(Function &F) override {
    if (skipFunction(F))
      return false;

    return Impl.runOnFunction(F, *this);
  }
  void getAnalysisUsage(AnalysisUsage &AU) const override;

  StringRef getPassName() const override { return "SVE Tbl Folding Opts"; }

private:
};
} // end anonymous namespace

// Optimize zext and uitofp from a 4-way deinterleaved load.
static bool optimizeSVEUnsignedExtends(Instruction *I, Loop *L) {
  assert(L && "No loop");
  assert((isa<ZExtInst>(I) || isa<UIToFPInst>(I)) && "No conversion.");
  Value *Src = I->getOperand(0);
  VectorType *DstTy = cast<VectorType>(I->getType());
  VectorType *SrcTy = cast<VectorType>(Src->getType());
  unsigned DstBits = DstTy->getScalarSizeInBits();
  unsigned SrcBits = SrcTy->getScalarSizeInBits();

  // TODO: Would we want tbl-based deinterleaving even if the cast is a uitofp
  //       at the same bitwidth? Maybe if we could combine with another shuffle?
  if (SrcBits >= DstBits)
    return false;

  // We can't abuse the invalid index trick for tbls of bytes, since the
  // largest possible SVE vector (2048b) would have 256 bytes, leaving no
  // way of zeroing.
  // TODO: If we know vscale is 8 or less, then we could use tbls for bytes.
  if (SrcBits <= 8)
    return false;

  using namespace llvm::PatternMatch;
  Value *Load = nullptr;
  Value *Extract = nullptr;

  bool IsUIToFP = isa<UIToFPInst>(I);
  if (match(I->getOperand(0),
            m_Value(Extract,
                    m_ExtractValue(m_Intrinsic<Intrinsic::vector_deinterleave4>(
                        m_Value(Load,
                                m_CombineOr(m_MaskedLoad(m_Value(), m_Value(),
                                                         m_CombineOr(m_Undef(),
                                                                     m_Zero())),
                                            m_Load(m_Value())))))))) {
    ArrayRef<unsigned> Indices = cast<ExtractValueInst>(Extract)->getIndices();
    if (Indices.size() != 1)
      return false;

    // TODO: 'Legalize' if the load is wider than legal...
    if (Load->getType()->getPrimitiveSizeInBits().getKnownMinValue() !=
        AArch64::SVEBitsPerBlock)
      return false;

    // Looking to match the deinterleave factor.
    if (DstBits / SrcBits != 4)
      return false;

    // Build mask
    APInt Invalid = APInt::getAllOnes(DstBits);
    APInt StartIdx = Invalid << SrcBits;
    StartIdx += Indices.front();
    VectorType *TblMaskTy = VectorType::getInteger(DstTy);
    Type *IdxTy = TblMaskTy->getScalarType();
    IRBuilder<> Builder(I);
    Value *StepVector = Builder.CreateStepVector(TblMaskTy);
    Value *ScaledSteps = Builder.CreateMul(
        StepVector, Builder.CreateVectorSplat(TblMaskTy->getElementCount(),
                                              ConstantInt::get(IdxTy, 4)));
    Value *Start = ConstantInt::get(IdxTy, StartIdx);
    Value *ZextTbl = Builder.CreateAdd(
        ScaledSteps,
        Builder.CreateVectorSplat(TblMaskTy->getElementCount(), Start));
    Value *FinalMask = Builder.CreateBitCast(ZextTbl, Load->getType());

    // Replace the deinterleave, extractvalue, and extension chain with
    // a tbl directly on the load.
    Value *Tbl = Builder.CreateIntrinsic(Intrinsic::aarch64_sve_tbl,
                                         {Load->getType()}, {Load, FinalMask});
    Value *Widen = Builder.CreateBitCast(Tbl, TblMaskTy);
    if (IsUIToFP)
      Widen = Builder.CreateUIToFP(Widen, DstTy);
    LLVM_DEBUG(dbgs() << "SVETBLOPT: Replaced " << *I << " with " << *Widen
                      << "\n");
    I->replaceAllUsesWith(Widen);
    I->eraseFromParent();
    return true;
  }

  return false;
}

bool SVEShuffleImpl::processLoop(Loop *L) {
  // TODO: Should we look for the deinterleave4 instead, and ensure that
  //       all users are similar before transforming?
  // TODO: Pull other shuffles into the tbl where possible
  // TODO: Add more advanced cases, such as introducing shuffles so that
  //       the SVE odd/even BT narrowing instructions can be used.
  bool Changed = false;
  for (auto *BB : L->blocks())
    for (auto &I : make_early_inc_range(*BB))
      if (I.getType()->isScalableTy() &&
          (isa<ZExtInst>(&I) || isa<UIToFPInst>(&I)))
        Changed |= optimizeSVEUnsignedExtends(&I, L);
  return Changed;
}

void SVEShuffleOpts::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<LoopInfoWrapperPass>();
  AU.addRequired<TargetPassConfig>();
  AU.setPreservesCFG();
}

char SVEShuffleOpts::ID = 0;
static const char *name = "SVE tbl folding optimizations";
INITIALIZE_PASS_BEGIN(SVEShuffleOpts, DEBUG_TYPE, name, false, false)
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(TargetPassConfig)
INITIALIZE_PASS_END(SVEShuffleOpts, DEBUG_TYPE, name, false, false)

FunctionPass *llvm::createSVEShuffleOptsPass() { return new SVEShuffleOpts(); }

namespace llvm {
class SVEShuffleOptsPass : public PassInfoMixin<SVEShuffleOptsPass> {
  const AArch64TargetMachine *TM;

public:
  explicit SVEShuffleOptsPass(const AArch64TargetMachine &TM) : TM(&TM) {}
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &FAM) {
    SVEShuffleImpl Impl(TM);
    return Impl.run(F, FAM);
  }
};
} // end namespace llvm

bool SVEShuffleImpl::runOnFunction(Function &F, Pass &P) {
  // Make sure we can use SVE
  TargetPassConfig &TPC = P.getAnalysis<TargetPassConfig>();
  TM = &TPC.getTM<AArch64TargetMachine>();
  const AArch64Subtarget *ST = TM->getSubtargetImpl(F);
  if (!ST->isSVEorStreamingSVEAvailable())
    return false;

  LI = &P.getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

  bool Changed = false;
  // Only looking to tranform innermost loops, given the increase in
  // register usage.
  for (Loop *L : LI->getLoopsInPreorder()) {
    if (L->isInnermost())
      Changed |= processLoop(L);
  }

  return Changed;
}

PreservedAnalyses SVEShuffleImpl::run(Function &F,
                                      FunctionAnalysisManager &FAM) {
  const AArch64Subtarget *ST = TM->getSubtargetImpl(F);
  if (!ST->isSVEorStreamingSVEAvailable())
    return PreservedAnalyses::all();

  LI = &FAM.getResult<LoopAnalysis>(F);

  bool Changed = false;
  // Only looking to tranform innermost loops, given the increase in
  // register usage.
  for (Loop *L : LI->getLoopsInPreorder()) {
    if (L->isInnermost())
      Changed |= processLoop(L);
  }

  // Can we do better than 'none'?
  // We're not actually using the new pass manager though.
  return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
}
