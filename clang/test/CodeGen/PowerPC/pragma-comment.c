// RUN: %clang_cc1 %s -triple powerpc-ibm-aix   -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -triple powerpc64-ibm-aix -emit-llvm -disable-llvm-passes -o - | FileCheck %s

#pragma comment(copyright, "@(#) Copyright")

int main() { return 0; }

// CHECK: !comment_string.loadtime = !{![[COPYRIGHT:[0-9]+]]}
// CHECK: ![[COPYRIGHT]] = !{!"@(#) Copyright"}