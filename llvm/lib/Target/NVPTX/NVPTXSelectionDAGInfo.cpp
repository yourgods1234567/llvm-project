//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "NVPTXSelectionDAGInfo.h"
#include "llvm/ADT/FoldingSet.h"
#include "llvm/CodeGen/ISDOpcodes.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/IR/DebugLoc.h"
#include "llvm/Support/CodeGen.h"
#include <memory>

#define GET_SDNODE_DESC
#include "NVPTXGenSDNodeInfo.inc"

using namespace llvm;

// ---------------------------------------------------------------------------
// DebugLoc-aware CSE map for NVPTX
// ---------------------------------------------------------------------------

/// Appends DebugLoc data to ID at -O0, so nodes at different source locations
/// are not merged.  Constants are always CSE'd regardless of location.
static void profileDebugLoc(FoldingSetNodeID &ID, unsigned Opcode,
                            const DebugLoc &DL, const SelectionDAG &DAG) {
  if (DAG.getOptLevel() != CodeGenOptLevel::None)
    return;
  if (!DL)
    return;
  switch (Opcode) {
  case ISD::UNDEF:
  case ISD::Constant:
  case ISD::ConstantFP:
  case ISD::TargetConstant:
  case ISD::TargetConstantFP:
    return; // Always CSE constants regardless of location.
  default:
    DL.Profile(ID);
  }
}

/// Profile specialization: must key nodes identically to FindNodeOrInsertPos.
namespace llvm {
template <>
struct ContextualFoldingSetTrait<SDNode, SelectionDAG *>
    : public DefaultContextualFoldingSetTrait<SDNode, SelectionDAG *> {
  static void Profile(SDNode &N, FoldingSetNodeID &ID, SelectionDAG *DAG) {
    N.Profile(ID);
    profileDebugLoc(ID, N.getOpcode(), N.getDebugLoc(), *DAG);
  }
};
} // namespace llvm

namespace {

/// CSE map that at -O0 keys each node by both its DAG structure and its
/// DebugLoc, so identical operations at different source lines stay distinct.
class NVPTXSDNodeCSEMap final : public SDNodeCSEMap {
  ContextualFoldingSet<SDNode, SelectionDAG *> FS;

public:
  explicit NVPTXSDNodeCSEMap(SelectionDAG *DAG) : FS(DAG) {}

  SDNode *FindNodeOrInsertPos(const FoldingSetNodeID &ID, unsigned Opcode,
                              const SDLoc &DL, void *&InsertPos) override {
    FoldingSetNodeID AugID = ID;
    profileDebugLoc(AugID, Opcode, DL.getDebugLoc(), *FS.getContext());
    return FS.FindNodeOrInsertPos(AugID, InsertPos);
  }

  void InsertNode(SDNode *N, void *InsertPos) override {
    FS.InsertNode(N, InsertPos);
  }

  bool RemoveNode(SDNode *N) override { return FS.RemoveNode(N); }

  SDNode *GetOrInsertNode(SDNode *N) override { return FS.GetOrInsertNode(N); }

  void clear() override { FS.clear(); }
};

} // namespace

std::unique_ptr<SDNodeCSEMap>
NVPTXSelectionDAGInfo::createCSEMap(SelectionDAG &DAG) const {
  return std::make_unique<NVPTXSDNodeCSEMap>(&DAG);
}

NVPTXSelectionDAGInfo::NVPTXSelectionDAGInfo()
    : SelectionDAGGenTargetInfo(NVPTXGenSDNodeInfo) {}

NVPTXSelectionDAGInfo::~NVPTXSelectionDAGInfo() = default;

const char *NVPTXSelectionDAGInfo::getTargetNodeName(unsigned Opcode) const {
#define MAKE_CASE(V)                                                           \
  case V:                                                                      \
    return #V;

  // These nodes don't have corresponding entries in *.td files yet.
  switch (static_cast<NVPTXISD::NodeType>(Opcode)) {
    MAKE_CASE(NVPTXISD::ATOMIC_CMP_SWAP_B128)
    MAKE_CASE(NVPTXISD::ATOMIC_SWAP_B128)
    MAKE_CASE(NVPTXISD::LoadV2)
    MAKE_CASE(NVPTXISD::LoadV4)
    MAKE_CASE(NVPTXISD::LoadV8)
    MAKE_CASE(NVPTXISD::MLoad)
    MAKE_CASE(NVPTXISD::LDUV2)
    MAKE_CASE(NVPTXISD::LDUV4)
    MAKE_CASE(NVPTXISD::StoreV2)
    MAKE_CASE(NVPTXISD::StoreV4)
    MAKE_CASE(NVPTXISD::StoreV8)
    MAKE_CASE(NVPTXISD::SETP_F16X2)
    MAKE_CASE(NVPTXISD::SETP_BF16X2)
    MAKE_CASE(NVPTXISD::UNPACK_VECTOR)
  }
#undef MAKE_CASE

  return SelectionDAGGenTargetInfo::getTargetNodeName(Opcode);
}

bool NVPTXSelectionDAGInfo::isTargetMemoryOpcode(unsigned Opcode) const {
  // These nodes don't have corresponding entries in *.td files.
  if (Opcode >= NVPTXISD::FIRST_MEMORY_OPCODE &&
      Opcode <= NVPTXISD::LAST_MEMORY_OPCODE)
    return true;

  return SelectionDAGGenTargetInfo::isTargetMemoryOpcode(Opcode);
}

void NVPTXSelectionDAGInfo::verifyTargetNode(const SelectionDAG &DAG,
                                             const SDNode *N) const {
  switch (N->getOpcode()) {
  default:
    break;
  case NVPTXISD::ProxyReg:
    // invalid number of results; expected 2, got 1
    return;
  }

  return SelectionDAGGenTargetInfo::verifyTargetNode(DAG, N);
}
