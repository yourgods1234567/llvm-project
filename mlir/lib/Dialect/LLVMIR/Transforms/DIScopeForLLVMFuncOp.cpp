//===- DILineTableFromLocations.cpp - -------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/LLVMIR/Transforms/Passes.h"

#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "llvm/BinaryFormat/Dwarf.h"
#include "llvm/Support/Path.h"

namespace mlir {
namespace LLVM {
#define GEN_PASS_DEF_DISCOPEFORLLVMFUNCOPPASS
#include "mlir/Dialect/LLVMIR/Transforms/Passes.h.inc"
} // namespace LLVM
} // namespace mlir

using namespace mlir;

/// Attempt to extract a filename for the given loc.
static FileLineColLoc extractFileLoc(Location loc) {
  if (auto fileLoc = dyn_cast<FileLineColLoc>(loc))
    return fileLoc;
  if (auto diLoc = dyn_cast<LLVM::DILocAttr>(loc))
    return diLoc.getSourceLoc();
  if (auto nameLoc = dyn_cast<NameLoc>(loc))
    return extractFileLoc(nameLoc.getChildLoc());
  if (auto opaqueLoc = dyn_cast<OpaqueLoc>(loc))
    return extractFileLoc(opaqueLoc.getFallbackLocation());
  if (auto fusedLoc = dyn_cast<FusedLoc>(loc)) {
    for (auto loc : fusedLoc.getLocations()) {
      if (auto fileLoc = extractFileLoc(loc))
        return fileLoc;
    }
  }
  if (auto callerLoc = dyn_cast<CallSiteLoc>(loc))
    return extractFileLoc(callerLoc.getCaller());
  return FileLineColLoc();
}

/// Creates a DISubprogramAttr with the provided compile unit and attaches it
/// to the function. Does nothing when the function already has an attached
/// subprogram.
static void addScopeToFunction(LLVM::LLVMFuncOp llvmFunc,
                               LLVM::DICompileUnitAttr compileUnitAttr) {

  Location loc = llvmFunc.getLoc();
  if (auto diLoc = dyn_cast_if_present<LLVM::DILocAttr>(loc))
    if (isa<LLVM::DISubprogramAttr>(diLoc.getScope()))
      return;
  if (loc->findInstanceOf<FusedLocWith<LLVM::DISubprogramAttr>>())
    return;

  MLIRContext *context = llvmFunc->getContext();

  // Filename and line associate to the function.
  LLVM::DIFileAttr fileAttr;
  int64_t line = 1;
  if (FileLineColLoc fileLoc = extractFileLoc(loc)) {
    line = fileLoc.getLine();
    StringRef inputFilePath = fileLoc.getFilename().getValue();
    fileAttr =
        LLVM::DIFileAttr::get(context, llvm::sys::path::filename(inputFilePath),
                              llvm::sys::path::parent_path(inputFilePath));
  } else {
    fileAttr = compileUnitAttr
                   ? compileUnitAttr.getFile()
                   : LLVM::DIFileAttr::get(context, "<unknown>", "");
  }
  auto subroutineTypeAttr =
      LLVM::DISubroutineTypeAttr::get(context, llvm::dwarf::DW_CC_normal, {});

  // Figure out debug information (`subprogramFlags` and `compileUnitAttr`) to
  // attach to the function definition / declaration. External functions are
  // declarations only and are defined in a different compile unit, so mark
  // them appropriately in `subprogramFlags` and set an empty `compileUnitAttr`.
  DistinctAttr id;
  auto subprogramFlags = LLVM::DISubprogramFlags::Optimized;
  if (!llvmFunc.isExternal()) {
    id = DistinctAttr::create(UnitAttr::get(context));
    subprogramFlags |= LLVM::DISubprogramFlags::Definition;
  } else {
    compileUnitAttr = {};
  }
  auto funcNameAttr = llvmFunc.getNameAttr();
  auto subprogramAttr = LLVM::DISubprogramAttr::get(
      context, id, compileUnitAttr, fileAttr, funcNameAttr, funcNameAttr,
      fileAttr,
      /*line=*/line, /*scopeLine=*/line, subprogramFlags, subroutineTypeAttr,
      /*retainedNodes=*/{}, /*annotations=*/{});
  FileLineColLoc fileLoc = extractFileLoc(loc);
  if (!fileLoc)
    fileLoc = FileLineColLoc::get(context, "", line, /*column=*/0);
  llvmFunc->setLoc(LLVM::DILocAttr::get(fileLoc, subprogramAttr));
}

// Build a DILocAttr for an inlined callee. Each recursion level creates a
// DILexicalBlockFileAttr whose scope chains back through the caller scopes
// to the enclosing subprogram. The scope nesting is carried by the
// DILexicalBlockFileAttr hierarchy, not by nesting locations.
static Location getNestedLoc(Operation *op, LLVM::DIScopeAttr scopeAttr,
                             Location calleeLoc) {
  FileLineColLoc calleeFileLoc = extractFileLoc(calleeLoc);
  auto *context = op->getContext();
  if (!calleeFileLoc)
    calleeFileLoc = FileLineColLoc::get(context, "", 0, 0);
  StringAttr calleeFileName = calleeFileLoc.getFilename();
  LLVM::DIFileAttr calleeFileAttr =
      LLVM::DIFileAttr::get(context, llvm::sys::path::filename(calleeFileName),
                            llvm::sys::path::parent_path(calleeFileName));
  auto lexicalBlockFileAttr = LLVM::DILexicalBlockFileAttr::get(
      context, scopeAttr, calleeFileAttr, /*discriminator=*/0);
  // Recurse if the callee location is again a call site.
  if (auto callSiteLoc = dyn_cast<CallSiteLoc>(calleeLoc))
    return getNestedLoc(op, lexicalBlockFileAttr, callSiteLoc.getCallee());
  return LLVM::DILocAttr::get(calleeFileLoc, lexicalBlockFileAttr);
}

/// Adds DILexicalBlockFileAttr for operations with CallSiteLoc and operations
/// from different files than their containing function.
static void setLexicalBlockFileAttr(Operation *op) {
  Location opLoc = op->getLoc();

  auto funcOp = op->getParentOfType<LLVM::LLVMFuncOp>();
  if (!funcOp)
    return;

  // Extract the subprogram scope from the function's location.
  LLVM::DISubprogramAttr scopeAttr;
  if (auto diLoc = dyn_cast_if_present<LLVM::DILocAttr>(funcOp.getLoc())) {
    scopeAttr = dyn_cast_if_present<LLVM::DISubprogramAttr>(diLoc.getScope());
  } else if (auto funcOpLoc =
                 llvm::dyn_cast_if_present<FusedLoc>(funcOp.getLoc())) {
    scopeAttr = dyn_cast<LLVM::DISubprogramAttr>(funcOpLoc.getMetadata());
  }
  if (!scopeAttr)
    return;

  if (auto callSiteLoc = dyn_cast<CallSiteLoc>(opLoc)) {
    op->setLoc(
        CallSiteLoc::get(getNestedLoc(op, scopeAttr, callSiteLoc.getCallee()),
                         callSiteLoc.getCaller()));
    return;
  }

  FileLineColLoc opFileLoc = extractFileLoc(opLoc);
  if (!opFileLoc)
    return;

  FileLineColLoc funcFileLoc = extractFileLoc(funcOp.getLoc());
  if (!funcFileLoc)
    return;

  StringRef opFile = opFileLoc.getFilename().getValue();
  StringRef funcFile = funcFileLoc.getFilename().getValue();

  // Handle cross-file operations: add DILexicalBlockFileAttr when the
  // operation's source file differs from its containing function.
  if (opFile != funcFile) {
    auto *context = op->getContext();
    LLVM::DIFileAttr opFileAttr =
        LLVM::DIFileAttr::get(context, llvm::sys::path::filename(opFile),
                              llvm::sys::path::parent_path(opFile));

    auto lexicalBlockFileAttr =
        LLVM::DILexicalBlockFileAttr::get(context, scopeAttr, opFileAttr, 0);

    op->setLoc(LLVM::DILocAttr::get(opFileLoc, lexicalBlockFileAttr));
  }
}

namespace {
/// Add a debug info scope to LLVMFuncOp that are missing it.
struct DIScopeForLLVMFuncOpPass
    : public LLVM::impl::DIScopeForLLVMFuncOpPassBase<
          DIScopeForLLVMFuncOpPass> {
  using Base::Base;

  void runOnOperation() override {
    ModuleOp module = getOperation();
    Location loc = module.getLoc();

    MLIRContext *context = &getContext();
    if (!context->getLoadedDialect<LLVM::LLVMDialect>()) {
      emitError(loc, "LLVM dialect is not loaded.");
      return signalPassFailure();
    }

    // Find a DICompileUnitAttr attached to a parent (the module for example),
    // otherwise create a default one.
    LLVM::DICompileUnitAttr compileUnitAttr;
    if (auto fusedCompileUnitAttr =
            module->getLoc()
                ->findInstanceOf<FusedLocWith<LLVM::DICompileUnitAttr>>()) {
      compileUnitAttr = fusedCompileUnitAttr.getMetadata();
    } else {
      LLVM::DIFileAttr fileAttr;
      if (FileLineColLoc fileLoc = extractFileLoc(loc)) {
        StringRef inputFilePath = fileLoc.getFilename().getValue();
        fileAttr = LLVM::DIFileAttr::get(
            context, llvm::sys::path::filename(inputFilePath),
            llvm::sys::path::parent_path(inputFilePath));
      } else {
        fileAttr = LLVM::DIFileAttr::get(context, "<unknown>", "");
      }

      compileUnitAttr = LLVM::DICompileUnitAttr::get(
          DistinctAttr::create(UnitAttr::get(context)), llvm::dwarf::DW_LANG_C,
          fileAttr, StringAttr::get(context, "MLIR"),
          /*isOptimized=*/true, emissionKind);
    }

    module.walk<WalkOrder::PreOrder>([&](Operation *op) -> void {
      if (auto funcOp = dyn_cast<LLVM::LLVMFuncOp>(op)) {
        // Create subprograms for each function with the same distinct compile
        // unit.
        addScopeToFunction(funcOp, compileUnitAttr);
      } else {
        setLexicalBlockFileAttr(op);
      }
    });
  }
};

} // end anonymous namespace
