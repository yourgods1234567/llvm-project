//===- AsyncToLLVM.h - Convert Async to LLVM dialect ------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_CONVERSION_ASYNCTOLLVM_ASYNCTOLLVM_H
#define MLIR_CONVERSION_ASYNCTOLLVM_ASYNCTOLLVM_H

#include <memory>

namespace mlir {

class ConversionTarget;
class Pass;
class MLIRContext;
class TypeConverter;
class RewritePatternSet;

#define GEN_PASS_DECL_CONVERTASYNCTOLLVMPASS
#include "mlir/Conversion/Passes.h.inc"

/// Populates patterns for async structural type conversions.
///
/// A "structural" type conversion is one where the underlying ops are
/// completely agnostic to the actual types involved and simply need to update
/// their types. An example of this is async.execute -- the async.execute op and
/// the corresponding async.yield ops need to update their types accordingly to
/// the TypeConverter, but otherwise don't care what type conversions are
/// happening.
///
/// `addStructuralYieldPattern` controls whether the structural pattern for
/// `async.yield` is registered. Callers that install their own (more
/// specialized) `async.yield` rewriter should pass `false` to avoid pattern
/// competition with that rewriter. The dynamic legality marker for
/// `async.yield` is still installed regardless.
void populateAsyncStructuralTypeConversionsAndLegality(
    TypeConverter &typeConverter, RewritePatternSet &patterns,
    ConversionTarget &target, bool addStructuralYieldPattern = true);

} // namespace mlir

#endif // MLIR_CONVERSION_ASYNCTOLLVM_ASYNCTOLLVM_H
