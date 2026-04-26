; RUN: llc < %s -mtriple=i386-linux-gnu          | FileCheck %s --check-prefix=LINUX-X86
; RUN: llc < %s -mtriple=i686-linux-gnu          | FileCheck %s --check-prefix=LINUX-X86
; RUN: llc < %s -mtriple=i686-pc-windows-msvc    | FileCheck %s --check-prefix=WIN32

; The 32-bit X86 triples inline-expand i128 div/rem, so keep the checks
; focused on the absence of libcalls.

define void @sdivrem_i128(ptr %q_out, ptr %r_out, i128 %n, i128 %d) {
; LINUX-X86-LABEL: sdivrem_i128:
; LINUX-X86-NOT:   __divmodti4
; LINUX-X86-NOT:   __divti3
; LINUX-X86-NOT:   __modti3
; LINUX-X86:       retl
;
; WIN32-LABEL: {{_?}}sdivrem_i128:
; WIN32-NOT:   __divmodti4
; WIN32-NOT:   __divti3
; WIN32-NOT:   __modti3
; WIN32:       retl
  %q = sdiv i128 %n, %d
  %r = srem i128 %n, %d
  store i128 %q, ptr %q_out
  store i128 %r, ptr %r_out
  ret void
}

define void @udivrem_i128(ptr %q_out, ptr %r_out, i128 %n, i128 %d) {
; LINUX-X86-LABEL: udivrem_i128:
; LINUX-X86-NOT:   __udivmodti4
; LINUX-X86-NOT:   __udivti3
; LINUX-X86-NOT:   __umodti3
; LINUX-X86:       retl
;
; WIN32-LABEL: {{_?}}udivrem_i128:
; WIN32-NOT:   __udivmodti4
; WIN32-NOT:   __udivti3
; WIN32-NOT:   __umodti3
; WIN32:       retl
  %q = udiv i128 %n, %d
  %r = urem i128 %n, %d
  store i128 %q, ptr %q_out
  store i128 %r, ptr %r_out
  ret void
}
