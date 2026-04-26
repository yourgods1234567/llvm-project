; RUN: llc < %s -mtriple=riscv32-linux-gnu             | FileCheck %s --check-prefix=RV32I
; RUN: llc < %s -mtriple=riscv32-linux-gnu -mattr=+m   | FileCheck %s --check-prefix=RV32M

; RV32 inline-expands i128 div/rem, so keep the checks focused on the absence
; of libcalls instead of the whole expanded algorithm.

define void @sdivrem_i128(ptr %q_out, ptr %r_out, i128 %n, i128 %d) {
; RV32I-LABEL: sdivrem_i128:
; RV32I-NOT:   __divmodti4
; RV32I-NOT:   __divti3
; RV32I-NOT:   __modti3
; RV32I:       ret
;
; RV32M-LABEL: sdivrem_i128:
; RV32M-NOT:   __divmodti4
; RV32M-NOT:   __divti3
; RV32M-NOT:   __modti3
; RV32M:       ret
  %q = sdiv i128 %n, %d
  %r = srem i128 %n, %d
  store i128 %q, ptr %q_out
  store i128 %r, ptr %r_out
  ret void
}

define void @udivrem_i128(ptr %q_out, ptr %r_out, i128 %n, i128 %d) {
; RV32I-LABEL: udivrem_i128:
; RV32I-NOT:   __udivmodti4
; RV32I-NOT:   __udivti3
; RV32I-NOT:   __umodti3
; RV32I:       ret
;
; RV32M-LABEL: udivrem_i128:
; RV32M-NOT:   __udivmodti4
; RV32M-NOT:   __udivti3
; RV32M-NOT:   __umodti3
; RV32M:       ret
  %q = udiv i128 %n, %d
  %r = urem i128 %n, %d
  store i128 %q, ptr %q_out
  store i128 %r, ptr %r_out
  ret void
}
