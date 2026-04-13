// RUN: split-file %s %t

// RUN: %clang_cc1 -triple aarch64-none-linux-gnu -fsyntax-only -verify %t/unsupported.c
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fsyntax-only -verify %t/unsupported.c
// RUN: %clang_cc1 -triple systemz -fsyntax-only -verify %t/unsupported.c
// RUN: %clang_cc1 -triple powerpc64-linux-gnu -fsyntax-only -verify %t/unsupported.c

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/copyright.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/copyright.c

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/empty-copyright.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/empty-copyright.c

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/other-kinds.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/other-kinds.c

// RUN: %clang_cc1 -triple powerpc-ibm-aix   -fsyntax-only -verify %t/duplicate.c
// RUN: %clang_cc1 -triple powerpc64-ibm-aix -fsyntax-only -verify %t/duplicate.c

//--- unsupported.c
// pragma comment kinds not supported on this target.
#pragma comment(copyright, "copyright")            // expected-warning {{'#pragma comment copyright' ignored}}
#pragma comment(compiler)                          // expected-warning {{'#pragma comment compiler' ignored}}
#pragma comment(exestr, "foo")                     // expected-warning {{'#pragma comment exestr' ignored}}
#pragma comment(user, "foo\abar\nbaz\tsomething")  // expected-warning {{'#pragma comment user' ignored}}

//--- copyright.c
// Copyright pragma is accepted without diagnostics.
#pragma comment(copyright, "copyright") // expected-no-diagnostics

//--- empty-copyright.c
// An empty copyright string is accepted without diagnostics.
#pragma comment(copyright, "") // expected-no-diagnostics

//--- other-kinds.c
// Non-copyright comment kinds produce warnings.
#pragma comment(lib, "m")                          // expected-warning {{'#pragma comment lib' ignored}}
#pragma comment(linker, "foo")                     // expected-warning {{'#pragma comment linker' ignored}}
#pragma comment(compiler)                          // expected-warning {{'#pragma comment compiler' ignored}}
#pragma comment(exestr, "foo")                     // expected-warning {{'#pragma comment exestr' ignored}}
#pragma comment(user, "foo\abar\nbaz\tsomething")  // expected-warning {{'#pragma comment user' ignored}}

//--- duplicate.c
// A second copyright pragma in the same translation unit warns.
#pragma comment(copyright, "@(#) Copyright")
#pragma comment(copyright, "Duplicate Copyright") // expected-warning {{'#pragma comment copyright' ignored: it can be specified only once per translation unit}}