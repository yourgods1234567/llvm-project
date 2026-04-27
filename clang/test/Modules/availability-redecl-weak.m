// RUN: rm -rf %t
// RUN: %clang_cc1 -triple arm64-apple-ios12.0 -fmodules-cache-path=%t \
// RUN:   -fmodules -fimplicit-module-maps \
// RUN:   -I %S/Inputs/availability-redecl-weak \
// RUN:   -DINTERFACE_FIRST -emit-llvm -o - %s | FileCheck %s
// RUN: rm -rf %t
// RUN: %clang_cc1 -triple arm64-apple-ios12.0 -fmodules-cache-path=%t \
// RUN:   -fmodules -fimplicit-module-maps \
// RUN:   -I %S/Inputs/availability-redecl-weak \
// RUN:   -emit-llvm -o - %s | FileCheck %s

// Test that isWeakImported() traverses the redeclaration chain across module
// boundaries to find availability attributes.
//
// InterfaceMod has @interface WeakRedecl1 with availability(macos,introduced=11.0)
// and availability(ios,introduced=14.0). ForwardMod has a bare @class WeakRedecl1.
//
// When InterfaceMod is imported first and ForwardMod second, the @class becomes
// getMostRecentDecl(). Cross-PCM mergeInheritableAttributes only copies the first
// AvailabilityAttr (macos), losing the ios attr. The old isWeakImported() only
// checked getMostRecentDecl()->attrs(), found only macos (not the ios target
// platform), and incorrectly returned false (strong linkage).

#ifdef INTERFACE_FIRST
// This order triggers the bug: @interface loaded first, then @class becomes
// the most recent decl with only an inherited macos availability attr.
@import InterfaceMod;
@import ForwardMod;
#else
// This order works even without the fix: @class loaded first, then @interface
// becomes the most recent decl with all availability attrs intact.
@import ForwardMod;
@import InterfaceMod;
#endif

@implementation WeakRedecl1 (TestCategory1)
@end

// CHECK: @"OBJC_CLASS_$_WeakRedecl1" = extern_weak global
