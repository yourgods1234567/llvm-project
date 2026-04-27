// RUN: %clang_cc1 %s -triple powerpc-ibm-aix   -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// RUN: %clang_cc1 %s -triple powerpc64-ibm-aix -emit-llvm -disable-llvm-passes -o - | FileCheck %s

#pragma comment(copyright, "@(#) Hello, " " world\n\t\"quoted\"")

int main() { return 0; }

// CHECK: !comment_string.loadtime = !{![[COPYRIGHT:[0-9]+]]}
// CHECK: ![[COPYRIGHT]] = !{!"@(#) Hello,  world\0A\09\22quoted\22"}
