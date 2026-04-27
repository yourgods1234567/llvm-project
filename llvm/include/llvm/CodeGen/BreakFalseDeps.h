//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Some instructions have false dependencies which cause unnecessary stalls.
// For example, instructions may write part of a register and implicitly
// need to read the other parts of the register. This may cause unwanted
// stalls preventing otherwise unrelated instructions from executing in
// parallel in an out-of-order CPU.
// This pass is aimed at identifying and avoiding these dependencies.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CODEGEN_BREAKFALSEDEPS_H
#define LLVM_CODEGEN_BREAKFALSEDEPS_H

#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionAnalysisManager.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Support/Compiler.h"

namespace llvm {

class BreakFalseDepsPass : public PassInfoMixin<BreakFalseDepsPass> {
public:
  LLVM_ABI PreservedAnalyses run(MachineFunction &MF,
                                 MachineFunctionAnalysisManager &MFAM);

  MachineFunctionProperties getRequiredProperties() const {
    return MachineFunctionProperties().setNoVRegs();
  }
};

} // namespace llvm

#endif // LLVM_CODEGEN_BREAKFALSEDEPS_H
