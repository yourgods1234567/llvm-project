;; __kernel void fmod_kernel( float out, float in1, float in2 )
;; { out = fmod( in1, in2 ); }

; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv64-unknown-unknown %s -o - | FileCheck %s --check-prefix=CHECK-SPIRV
; RUN: %if spirv-tools %{ llc -verify-machineinstrs -O0 -mtriple=spirv64-unknown-unknown %s -o - -filetype=obj | spirv-val %}

; CHECK-SPIRV: %[[#]] = OpExtInst %[[#]] %[[#]] fmod %[[#]] %[[#]]

define spir_kernel void @fmod_kernel(float %out, float %in1, float %in2) {
entry:
  %call = call spir_func float @_Z4fmodff(float %in1, float %in2)
  ret void
}

declare spir_func float @_Z4fmodff(float, float)
