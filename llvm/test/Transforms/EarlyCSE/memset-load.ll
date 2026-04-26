; RUN: opt -S -passes='early-cse<memssa>' < %s | FileCheck %s

define ptr @load_from_zero_memset(ptr %p) {
; CHECK-LABEL: @load_from_zero_memset(
; CHECK: ret ptr null
entry:
  call void @llvm.memset.p0.i64(ptr %p, i8 0, i64 8, i1 false)
  %v = load ptr, ptr %p, align 8
  ret ptr %v
}

declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg)
