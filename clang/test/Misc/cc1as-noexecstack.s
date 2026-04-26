// REQUIRES: x86-registered-target
// RUN: %clang -cc1as -triple x86_64-linux-gnu -filetype obj -mnoexecstack -o %t.o %s
// RUN: llvm-readelf -S %t.o | FileCheck %s

// CHECK: .note.GNU-stack

.text
.globl foo
foo:
    retq
