; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv32-unknown-unknown %s -o - | FileCheck %s --check-prefix=CHECK-SPIRV
; RUN: %if spirv-tools %{ llc -verify-machineinstrs -O0 -mtriple=spirv32-unknown-unknown %s -o - -filetype=obj | spirv-val %}

; CHECK-SPIRV: OpCapability DeviceEnqueue
; CHECK-SPIRV: OpTypeQueue

define spir_func void @enqueue_simple_block(target("spirv.Queue") %q) {
entry:
  ret void
}
