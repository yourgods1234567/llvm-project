## Test that BOLT correctly skips mold-style STT_FUNC symbols in PLT sections.
# REQUIRES: system-linux

# Build shared lib providing printf
# RUN: %clang --target=aarch64-linux-gnu -shared -fPIC -o %t.so \
# RUN:   -fuse-ld=lld -nostdlib %S/Inputs/plt-mold-lib.c

# RUN: llvm-mc -filetype=obj -triple aarch64-linux %s -o %t.o
# RUN: ld.lld -pie --emit-relocs -o %t.exe %t.o %t.so

# Inject mold-style STT_FUNC symbol at the first PLT entry (offset 0x20
# into .plt — AArch64 lld PLT header is 0x20 bytes, entries are 0x10 each)
# RUN: llvm-objcopy --add-symbol 'printf$plt=.plt:0x20,local,function' \
# RUN:   %t.exe %t.mold

# Verify the injected symbol exists
# RUN: llvm-readelf -s %t.mold | FileCheck --check-prefix=SYM %s
# SYM: FUNC LOCAL {{.*}} printf$plt

# Run BOLT — should skip printf$plt and use printf@PLT
# RUN: llvm-bolt %t.mold --print-cfg --print-only=main -o /dev/null \
# RUN:   2>&1 | FileCheck %s

# The call should resolve to printf@PLT, not printf$plt
# CHECK: bl printf@PLT

# RUN: llvm-readobj --symbols %t.mold | FileCheck --check-prefix=MOLD-SYMS %s

# MOLD-SYMS:      Name: printf$plt
# MOLD-SYMS-NEXT: Value:
# MOLD-SYMS-NEXT: Size: 0
# MOLD-SYMS-NEXT: Binding: Local
# MOLD-SYMS-NEXT: Type: Function
# MOLD-SYMS-NEXT: Other: 0
# MOLD-SYMS-NEXT: Section: .plt
  .text
  .globl _start
  .type _start, %function
_start:
  bl main
  mov w8, #93
  svc #0
  .size _start, .-_start

  .globl main
  .type main, %function
main:
  stp x29, x30, [sp, #-16]!
  mov x29, sp
  adrp x0, .Lstr
  add x0, x0, :lo12:.Lstr
  bl printf
  mov w0, #0
  ldp x29, x30, [sp], #16
  ret
  .size main, .-main

  .section .rodata,"a"
.Lstr:
  .asciz "hello\n"
