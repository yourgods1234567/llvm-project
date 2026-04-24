;; __kernel void sample_test(read_only image2d_t src, read_only image1d_buffer_t buff) {}

; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv64-unknown-unknown %s -o - | FileCheck %s --check-prefix=CHECK-SPIRV
; RUN: %if spirv-tools %{ llc -verify-machineinstrs -O0 -mtriple=spirv64-unknown-unknown %s -o - -filetype=obj | spirv-val %}

; CHECK-SPIRV-NOT: OpCapability Shader

define spir_kernel void @sample_test(target("spirv.Image", void, 1, 0, 0, 0, 0, 0, 0) %src, target("spirv.Image", void, 5, 0, 0, 0, 0, 0, 0) %buf) {
  ret void
}
