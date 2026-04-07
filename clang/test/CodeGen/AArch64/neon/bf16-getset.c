// REQUIRES: aarch64-registered-target || arm-registered-target

// RUN:                   %clang_cc1_cg_arm64_neon -target-feature +bf16           -emit-llvm %s -disable-O0-optnone | opt -S -passes=mem2reg,sroa | FileCheck %s --check-prefixes=ALL,LLVM
// RUN: %if cir-enabled %{%clang_cc1_cg_arm64_neon -target-feature +bf16 -fclangir -emit-llvm %s -disable-O0-optnone | opt -S -passes=mem2reg,sroa | FileCheck %s --check-prefixes=ALL,LLVM %}
// RUN: %if cir-enabled %{%clang_cc1_cg_arm64_neon -target-feature +bf16 -fclangir -emit-cir  %s -disable-O0-optnone |                               FileCheck %s --check-prefixes=ALL,CIR %}

#include <arm_neon.h>

//=============================================================================
// NOTES
//
// ACLE section headings based on v2025Q2 of the ACLE specification:
//  * https://arm-software.github.io/acle/neon_intrinsics/advsimd.html#bitwise-equal-to-zero
//=============================================================================

//===------------------------------------------------------===//
// 2.4.1.2. Set all lanes to the same value
//
// TODO: Add the remaining intrinsics from this group.
//===------------------------------------------------------===//

// ALL-LABEL: @test_vduph_lane_bf16(
bfloat16_t test_vduph_lane_bf16(bfloat16x4_t v) {
  // CIR: cir.vec.extract %{{.*}}[%{{.*}} : !s32i] : !cir.vector<4 x !cir.bf16>
  // LLVM: [[VGET_LANE:%.*]] = extractelement <4 x bfloat> %{{.*}}, i32 1
  // LLVM: ret bfloat [[VGET_LANE]]
  return vduph_lane_bf16(v, 1);
}

// ALL-LABEL: @test_vduph_laneq_bf16(
bfloat16_t test_vduph_laneq_bf16(bfloat16x8_t v) {
  // CIR: cir.vec.extract %{{.*}}[%{{.*}} : !s32i] : !cir.vector<8 x !cir.bf16>
  // LLVM: [[VGETQ_LANE:%.*]] = extractelement <8 x bfloat> %{{.*}}, i32 7
  // LLVM: ret bfloat [[VGETQ_LANE]]
  return vduph_laneq_bf16(v, 7);
}
