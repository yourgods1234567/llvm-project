; RUN: llc -O0 -mtriple=spirv32-unknown-unknown %s -o - | FileCheck %s --check-prefix=CHECK-SPIRV
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv32-unknown-unknown %s -o - -filetype=obj | spirv-val %}

;; This test checks that the backend correctly translates OpenCL C
;; atomic_fetch_min/max, atomic_fetch_min/max_explicit, and legacy
;; atom_min/max built-in functions into the corresponding SPIR-V
;; OpAtomicSMin/OpAtomicSMax/OpAtomicUMin/OpAtomicUMax instructions,
;; selecting the signed or unsigned variant based on the argument type.

;; __kernel void test_atomic_min_max_signed(__global int *p, int val) {
;;   atomic_fetch_min(p, val);
;;   atomic_fetch_max(p, val);
;;   atomic_fetch_min_explicit(p, val, memory_order_relaxed);
;;   atomic_fetch_max_explicit(p, val, memory_order_relaxed);
;;   atom_min(p, val);
;;   atom_max(p, val);
;; }
;;
;; __kernel void test_atomic_min_max_unsigned(__global unsigned int *p, unsigned int val) {
;;   atomic_fetch_min(p, val);
;;   atomic_fetch_max(p, val);
;;   atomic_fetch_min_explicit(p, val, memory_order_relaxed);
;;   atomic_fetch_max_explicit(p, val, memory_order_relaxed);
;;   atom_min(p, val);
;;   atom_max(p, val);
;; }

; CHECK-SPIRV-DAG: %[[#UINT:]] = OpTypeInt 32 0
; CHECK-SPIRV-DAG: %[[#UINT_PTR:]] = OpTypePointer CrossWorkgroup %[[#UINT]]

;; 0x2 Workgroup
; CHECK-SPIRV-DAG: %[[#WORKGROUP_SCOPE:]] = OpConstant %[[#UINT]] 2{{$}}

;; Signed variants: all should use OpAtomicSMin / OpAtomicSMax
; CHECK-SPIRV:     %[[#TEST_SIGNED:]] = OpFunction %[[#]]
; CHECK-SPIRV:     %[[#SPTR:]] = OpFunctionParameter %[[#UINT_PTR]]
; CHECK-SPIRV:     %[[#SVAL:]] = OpFunctionParameter %[[#UINT]]
; CHECK-SPIRV:     %[[#]] = OpAtomicSMin %[[#UINT]] %[[#SPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#SVAL]]
; CHECK-SPIRV:     %[[#]] = OpAtomicSMax %[[#UINT]] %[[#SPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#SVAL]]
; CHECK-SPIRV:     %[[#]] = OpAtomicSMin %[[#UINT]] %[[#SPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#SVAL]]
; CHECK-SPIRV:     %[[#]] = OpAtomicSMax %[[#UINT]] %[[#SPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#SVAL]]
; CHECK-SPIRV:     %[[#]] = OpAtomicSMin %[[#UINT]] %[[#SPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#SVAL]]
; CHECK-SPIRV:     %[[#]] = OpAtomicSMax %[[#UINT]] %[[#SPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#SVAL]]

;; Unsigned variants: all should use OpAtomicUMin / OpAtomicUMax
; CHECK-SPIRV:     %[[#TEST_UNSIGNED:]] = OpFunction %[[#]]
; CHECK-SPIRV:     %[[#UPTR:]] = OpFunctionParameter %[[#UINT_PTR]]
; CHECK-SPIRV:     %[[#UVAL:]] = OpFunctionParameter %[[#UINT]]
; CHECK-SPIRV:     %[[#]] = OpAtomicUMin %[[#UINT]] %[[#UPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#UVAL]]
; CHECK-SPIRV:     %[[#]] = OpAtomicUMax %[[#UINT]] %[[#UPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#UVAL]]
; CHECK-SPIRV:     %[[#]] = OpAtomicUMin %[[#UINT]] %[[#UPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#UVAL]]
; CHECK-SPIRV:     %[[#]] = OpAtomicUMax %[[#UINT]] %[[#UPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#UVAL]]
; CHECK-SPIRV:     %[[#]] = OpAtomicUMin %[[#UINT]] %[[#UPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#UVAL]]
; CHECK-SPIRV:     %[[#]] = OpAtomicUMax %[[#UINT]] %[[#UPTR]] %[[#WORKGROUP_SCOPE]] %[[#]] %[[#UVAL]]

define dso_local spir_kernel void @test_atomic_min_max_signed(ptr addrspace(1) noundef %p, i32 noundef %val) local_unnamed_addr {
entry:
  %call0 = tail call spir_func i32 @_Z16atomic_fetch_minPU3AS1Vii(ptr addrspace(1) noundef %p, i32 noundef %val)
  %call1 = tail call spir_func i32 @_Z16atomic_fetch_maxPU3AS1Vii(ptr addrspace(1) noundef %p, i32 noundef %val)
  %call2 = tail call spir_func i32 @_Z25atomic_fetch_min_explicitPU3AS1Viii(ptr addrspace(1) noundef %p, i32 noundef %val, i32 noundef 0)
  %call3 = tail call spir_func i32 @_Z25atomic_fetch_max_explicitPU3AS1Viii(ptr addrspace(1) noundef %p, i32 noundef %val, i32 noundef 0)
  %call4 = tail call spir_func i32 @_Z8atom_minPU3AS1Vii(ptr addrspace(1) noundef %p, i32 noundef %val)
  %call5 = tail call spir_func i32 @_Z8atom_maxPU3AS1Vii(ptr addrspace(1) noundef %p, i32 noundef %val)
  ret void
}

define dso_local spir_kernel void @test_atomic_min_max_unsigned(ptr addrspace(1) noundef %p, i32 noundef %val) local_unnamed_addr {
entry:
  %call0 = tail call spir_func i32 @_Z16atomic_fetch_minPU3AS1Vjj(ptr addrspace(1) noundef %p, i32 noundef %val)
  %call1 = tail call spir_func i32 @_Z16atomic_fetch_maxPU3AS1Vjj(ptr addrspace(1) noundef %p, i32 noundef %val)
  %call2 = tail call spir_func i32 @_Z25atomic_fetch_min_explicitPU3AS1Vjji(ptr addrspace(1) noundef %p, i32 noundef %val, i32 noundef 0)
  %call3 = tail call spir_func i32 @_Z25atomic_fetch_max_explicitPU3AS1Vjji(ptr addrspace(1) noundef %p, i32 noundef %val, i32 noundef 0)
  %call4 = tail call spir_func i32 @_Z8atom_minPU3AS1Vjj(ptr addrspace(1) noundef %p, i32 noundef %val)
  %call5 = tail call spir_func i32 @_Z8atom_maxPU3AS1Vjj(ptr addrspace(1) noundef %p, i32 noundef %val)
  ret void
}

;; Signed builtins
declare spir_func i32 @_Z16atomic_fetch_minPU3AS1Vii(ptr addrspace(1) noundef, i32 noundef) local_unnamed_addr
declare spir_func i32 @_Z16atomic_fetch_maxPU3AS1Vii(ptr addrspace(1) noundef, i32 noundef) local_unnamed_addr
declare spir_func i32 @_Z25atomic_fetch_min_explicitPU3AS1Viii(ptr addrspace(1) noundef, i32 noundef, i32 noundef) local_unnamed_addr
declare spir_func i32 @_Z25atomic_fetch_max_explicitPU3AS1Viii(ptr addrspace(1) noundef, i32 noundef, i32 noundef) local_unnamed_addr
declare spir_func i32 @_Z8atom_minPU3AS1Vii(ptr addrspace(1) noundef, i32 noundef) local_unnamed_addr
declare spir_func i32 @_Z8atom_maxPU3AS1Vii(ptr addrspace(1) noundef, i32 noundef) local_unnamed_addr

;; Unsigned builtins
declare spir_func i32 @_Z16atomic_fetch_minPU3AS1Vjj(ptr addrspace(1) noundef, i32 noundef) local_unnamed_addr
declare spir_func i32 @_Z16atomic_fetch_maxPU3AS1Vjj(ptr addrspace(1) noundef, i32 noundef) local_unnamed_addr
declare spir_func i32 @_Z25atomic_fetch_min_explicitPU3AS1Vjji(ptr addrspace(1) noundef, i32 noundef, i32 noundef) local_unnamed_addr
declare spir_func i32 @_Z25atomic_fetch_max_explicitPU3AS1Vjji(ptr addrspace(1) noundef, i32 noundef, i32 noundef) local_unnamed_addr
declare spir_func i32 @_Z8atom_minPU3AS1Vjj(ptr addrspace(1) noundef, i32 noundef) local_unnamed_addr
declare spir_func i32 @_Z8atom_maxPU3AS1Vjj(ptr addrspace(1) noundef, i32 noundef) local_unnamed_addr

;; References:
;; [1]: https://www.khronos.org/registry/OpenCL/specs/3.0-unified/html/OpenCL_C.html#atomic-functions
;; [2]: https://www.khronos.org/registry/spir-v/specs/unified1/SPIRV.html#OpAtomicSMin
;; [3]: https://www.khronos.org/registry/spir-v/specs/unified1/SPIRV.html#OpAtomicSMax
