; RUN: llc < %s -mtriple=x86_64-linux-gnu         | FileCheck %s --check-prefix=LINUX-X64
; RUN: llc < %s -mtriple=x86_64-linux-gnux32      | FileCheck %s --check-prefix=LINUX-X32
; RUN: llc < %s -mtriple=x86_64-apple-macosx      | FileCheck %s --check-prefix=DARWIN-X64
; RUN: llc < %s -mtriple=x86_64-w64-mingw32       | FileCheck %s --check-prefix=MINGW-X64
; RUN: llc < %s -mtriple=x86_64-pc-windows-msvc   | FileCheck %s --check-prefix=WIN64
; RUN: llc < %s -mtriple=i386-linux-gnu           | FileCheck %s --check-prefix=LINUX-X86
; RUN: llc < %s -mtriple=i686-linux-gnu           | FileCheck %s --check-prefix=LINUX-X86
; RUN: llc < %s -mtriple=i686-pc-windows-msvc     | FileCheck %s --check-prefix=WIN32

; The 64-bit triples use fused libcalls with ABI-specific calling conventions.
; The 32-bit triples inline-expand i128 div/rem, so only assert the absence of
; libcalls there.

define void @sdivrem_i128(ptr %q_out, ptr %r_out, i128 %n, i128 %d) {
; LINUX-X64-LABEL: sdivrem_i128:
; LINUX-X64:       movq %rsp, %r8
; LINUX-X64:       callq __divmodti4@PLT
; LINUX-X64:       movq (%rsp), %rcx
; LINUX-X64:       movq {{[0-9]+}}(%rsp), %rsi
; LINUX-X64:       movq %rax, (%r14)
; LINUX-X64:       movq %rdx, 8(%r14)
; LINUX-X64:       movq %rcx, (%rbx)
; LINUX-X64:       movq %rsi, 8(%rbx)
;
; LINUX-X32-LABEL: sdivrem_i128:
; LINUX-X32:       movl %esp, %r8d
; LINUX-X32:       callq __divmodti4@PLT
; LINUX-X32:       movq (%esp), %rcx
; LINUX-X32:       movq {{[0-9]+}}(%esp), %rsi
; LINUX-X32:       movq %rax, (%r14d)
; LINUX-X32:       movq %rdx, 8(%r14d)
; LINUX-X32:       movq %rcx, (%ebx)
; LINUX-X32:       movq %rsi, 8(%ebx)
;
; DARWIN-X64-LABEL: sdivrem_i128:
; DARWIN-X64:       movq %rsp, %r8
; DARWIN-X64:       callq ___divmodti4
; DARWIN-X64:       movq (%rsp), %rcx
; DARWIN-X64:       movq {{[0-9]+}}(%rsp), %rsi
; DARWIN-X64:       movq %rax, (%r14)
; DARWIN-X64:       movq %rdx, 8(%r14)
; DARWIN-X64:       movq %rcx, (%rbx)
; DARWIN-X64:       movq %rsi, 8(%rbx)
;
; MINGW-X64-LABEL: sdivrem_i128:
; MINGW-X64:       leaq {{[0-9]+}}(%rsp), %rcx
; MINGW-X64:       leaq {{[0-9]+}}(%rsp), %rdx
; MINGW-X64:       leaq {{[0-9]+}}(%rsp), %r8
; MINGW-X64:       callq __divmodti4
; MINGW-X64:       movaps {{[0-9]+}}(%rsp), %xmm1
; MINGW-X64:       movaps %xmm0, (%rdi)
; MINGW-X64:       movaps %xmm1, (%rsi)
;
; WIN64-LABEL: sdivrem_i128:
; WIN64:       leaq {{[0-9]+}}(%rsp), %rcx
; WIN64:       leaq {{[0-9]+}}(%rsp), %rdx
; WIN64:       leaq {{[0-9]+}}(%rsp), %r8
; WIN64:       callq __divmodti4
; WIN64:       movaps {{[0-9]+}}(%rsp), %xmm1
; WIN64:       movaps %xmm0, (%rdi)
; WIN64:       movaps %xmm1, (%rsi)
;
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
; LINUX-X64-LABEL: udivrem_i128:
; LINUX-X64:       movq %rsp, %r8
; LINUX-X64:       callq __udivmodti4@PLT
; LINUX-X64:       movq (%rsp), %rcx
; LINUX-X64:       movq {{[0-9]+}}(%rsp), %rsi
; LINUX-X64:       movq %rax, (%r14)
; LINUX-X64:       movq %rdx, 8(%r14)
; LINUX-X64:       movq %rcx, (%rbx)
; LINUX-X64:       movq %rsi, 8(%rbx)
;
; LINUX-X32-LABEL: udivrem_i128:
; LINUX-X32:       movl %esp, %r8d
; LINUX-X32:       callq __udivmodti4@PLT
; LINUX-X32:       movq (%esp), %rcx
; LINUX-X32:       movq {{[0-9]+}}(%esp), %rsi
; LINUX-X32:       movq %rax, (%r14d)
; LINUX-X32:       movq %rdx, 8(%r14d)
; LINUX-X32:       movq %rcx, (%ebx)
; LINUX-X32:       movq %rsi, 8(%ebx)
;
; DARWIN-X64-LABEL: udivrem_i128:
; DARWIN-X64:       movq %rsp, %r8
; DARWIN-X64:       callq ___udivmodti4
; DARWIN-X64:       movq (%rsp), %rcx
; DARWIN-X64:       movq {{[0-9]+}}(%rsp), %rsi
; DARWIN-X64:       movq %rax, (%r14)
; DARWIN-X64:       movq %rdx, 8(%r14)
; DARWIN-X64:       movq %rcx, (%rbx)
; DARWIN-X64:       movq %rsi, 8(%rbx)
;
; MINGW-X64-LABEL: udivrem_i128:
; MINGW-X64:       leaq {{[0-9]+}}(%rsp), %rcx
; MINGW-X64:       leaq {{[0-9]+}}(%rsp), %rdx
; MINGW-X64:       leaq {{[0-9]+}}(%rsp), %r8
; MINGW-X64:       callq __udivmodti4
; MINGW-X64:       movaps {{[0-9]+}}(%rsp), %xmm1
; MINGW-X64:       movaps %xmm0, (%rdi)
; MINGW-X64:       movaps %xmm1, (%rsi)
;
; WIN64-LABEL: udivrem_i128:
; WIN64:       leaq {{[0-9]+}}(%rsp), %rcx
; WIN64:       leaq {{[0-9]+}}(%rsp), %rdx
; WIN64:       leaq {{[0-9]+}}(%rsp), %r8
; WIN64:       callq __udivmodti4
; WIN64:       movaps {{[0-9]+}}(%rsp), %xmm1
; WIN64:       movaps %xmm0, (%rdi)
; WIN64:       movaps %xmm1, (%rsi)
;
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
