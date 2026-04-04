; RUN: llc < %s -mtriple=armv6-linux-gnueabihf | FileCheck %s --check-prefix=ARMV6
; RUN: llc < %s -mtriple=armv7-linux-gnueabi   | FileCheck %s --check-prefix=ARMV7
; RUN: llc < %s -mtriple=armv7-none-eabi       | FileCheck %s --check-prefix=ARMV7

; These 32-bit ARM triples inline-expand i128 div/rem. Keep the checks minimal:
; verify that no libcalls are emitted and that the function reaches its
; epilogue.

define void @sdivrem_i128(ptr %q_out, ptr %r_out, i128 %n, i128 %d) {
; ARMV6-LABEL: sdivrem_i128:
; ARMV6-NOT:   __divmodti4
; ARMV6-NOT:   __divti3
; ARMV6-NOT:   __modti3
; ARMV6:       pop{{.*}}pc}
;
; ARMV7-LABEL: sdivrem_i128:
; ARMV7-NOT:   __divmodti4
; ARMV7-NOT:   __divti3
; ARMV7-NOT:   __modti3
; ARMV7:       pop{{.*}}pc}
  %q = sdiv i128 %n, %d
  %r = srem i128 %n, %d
  store i128 %q, ptr %q_out
  store i128 %r, ptr %r_out
  ret void
}

define void @udivrem_i128(ptr %q_out, ptr %r_out, i128 %n, i128 %d) {
; ARMV6-LABEL: udivrem_i128:
; ARMV6-NOT:   __udivmodti4
; ARMV6-NOT:   __udivti3
; ARMV6-NOT:   __umodti3
; ARMV6:       pop{{.*}}pc}
;
; ARMV7-LABEL: udivrem_i128:
; ARMV7-NOT:   __udivmodti4
; ARMV7-NOT:   __udivti3
; ARMV7-NOT:   __umodti3
; ARMV7:       pop{{.*}}pc}
  %q = udiv i128 %n, %d
  %r = urem i128 %n, %d
  store i128 %q, ptr %q_out
  store i128 %r, ptr %r_out
  ret void
}
