; RUN: llvm-as < %s | llvm-dis | FileCheck %s

; CHECK: @a = global float -0.000000e+00
@a = global float -0.0
; CHECK: @b = global float 0.000000e+00
@b = global float +0.0
; CHECK: @c = global float 0.000000e+00
@c = global float 0.0
; CHECK: @d = global float 0.000000e+00
@d = global float 0.e1
; CHECK: @e = global float 0.000000e+00
@e = global float 0.e-1
; CHECK: @f = global float 0.000000e+00
@f = global float 0.e+1
; CHECK: @g = global float f0x2F800000
@g = global float 0x1.0p-32
; CHECK: @h = global float f0x4F800000
@h = global float 0x1.0p+32
; CHECK: @i = global float f0x4FE18000
@i = global float 0x1.c3p32
; CHECK: @j = global float f0x3FFF8000
@j = global float 0x1.ffp0
; CHECK: @k = global float f0xC7FFFFFF
@k = global float -0xfff.fffp5
; CHECK: @l = global float f0x4407EF00
@l = global float +0x10.fdep5

; CHECK: @0 = global double +inf
@0 = global double +inf
; CHECK: @1 = global ppc_fp128 -inf
@1 = global ppc_fp128 -inf
; CHECK: @2 = global half -qnan
@2 = global half -qnan
; CHECK: @3 = global bfloat +qnan
@3 = global bfloat +qnan
; CHECK: @4 = global fp128 +nan(0xDEADBEEF)
@4 = global fp128 +nan(0xdeadbeef)
; CHECK: @5 = global float +snan(0x1)
@5 = global float +snan(0x1)
; CHECK: @6 = global x86_fp80 f0x0001FFFF000000000000
@6 = global x86_fp80 f0x0000ffff000000000000

; CHECK: @legacy = global float 1.000000e-01
@legacy = global float 0x3FB99999A0000000
