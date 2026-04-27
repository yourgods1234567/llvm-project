// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm %s -o - | FileCheck %s

#define FP_NAN 3
#define FP_INFINITE 516
#define FP_ZERO 96
#define FP_SUBNORMAL 144
#define FP_NORMAL 264

void test_fpclassify_nan() {
  float nanValue = 0.0f / 0.0f;
  __builtin_fpclassify(FP_NAN, FP_INFINITE, FP_NORMAL, FP_SUBNORMAL, FP_ZERO,
                       nanValue);
// CHECK-LABEL: entry:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 3)
// CHECK: br i1 %{{.*}}, label %fpclassify_end, label %fpclassify_not_nan
// CHECK-LABEL: fpclassify_not_nan:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 516)
// CHECK-LABEL: fpclassify_not_infinite:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 264)
// CHECK-LABEL: fpclassify_not_normal:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 144)
// CHECK-LABEL: fpclassify_end:
// CHECK: %fpclassify_result = phi i32 [ 3, %entry ], [ 516, %fpclassify_not_nan ], [ 264, %fpclassify_not_infinite ], [ 144, %fpclassify_not_normal ], [ 96, %fpclassify_not_subnormal ]
}

void test_fpclassify_inf() {
  float infValue = 1.0f / 0.0f;
  __builtin_fpclassify(FP_NAN, FP_INFINITE, FP_NORMAL, FP_SUBNORMAL, FP_ZERO,
                       infValue);
// CHECK-LABEL: entry:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 3)
// CHECK: br i1 %{{.*}}, label %fpclassify_end, label %fpclassify_not_nan
// CHECK-LABEL: fpclassify_not_nan:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 516)
// CHECK-LABEL: fpclassify_not_infinite:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 264)
// CHECK-LABEL: fpclassify_not_normal:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 144)
// CHECK-LABEL: fpclassify_end:
// CHECK: %fpclassify_result = phi i32 [ 3, %entry ], [ 516, %fpclassify_not_nan ], [ 264, %fpclassify_not_infinite ], [ 144, %fpclassify_not_normal ], [ 96, %fpclassify_not_subnormal ]
}

void test_fpclassify_normal() {
  float normalValue = 1.0f;
  __builtin_fpclassify(FP_NAN, FP_INFINITE, FP_NORMAL, FP_SUBNORMAL, FP_ZERO,
                       normalValue);
// CHECK-LABEL: entry:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 3)
// CHECK: br i1 %{{.*}}, label %fpclassify_end, label %fpclassify_not_nan
// CHECK-LABEL: fpclassify_not_nan:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 516)
// CHECK-LABEL: fpclassify_not_infinite:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 264)
// CHECK-LABEL: fpclassify_not_normal:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 144)
// CHECK-LABEL: fpclassify_end:
// CHECK: %fpclassify_result = phi i32 [ 3, %entry ], [ 516, %fpclassify_not_nan ], [ 264, %fpclassify_not_infinite ], [ 144, %fpclassify_not_normal ], [ 96, %fpclassify_not_subnormal ]
}

void test_fpclassify_subnormal() {
  float subnormalValue = 1.0e-40f;
  __builtin_fpclassify(FP_NAN, FP_INFINITE, FP_NORMAL, FP_SUBNORMAL, FP_ZERO,
                       subnormalValue);
// CHECK-LABEL: entry:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 3)
// CHECK: br i1 %{{.*}}, label %fpclassify_end, label %fpclassify_not_nan
// CHECK-LABEL: fpclassify_not_nan:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 516)
// CHECK-LABEL: fpclassify_not_infinite:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 264)
// CHECK-LABEL: fpclassify_not_normal:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 144)
// CHECK-LABEL: fpclassify_end:
// CHECK: %fpclassify_result = phi i32 [ 3, %entry ], [ 516, %fpclassify_not_nan ], [ 264, %fpclassify_not_infinite ], [ 144, %fpclassify_not_normal ], [ 96, %fpclassify_not_subnormal ]
}

void test_fpclassify_zero() {
  float zeroValue = 0.0f;
  __builtin_fpclassify(FP_NAN, FP_INFINITE, FP_NORMAL, FP_SUBNORMAL, FP_ZERO,
                       zeroValue);
// CHECK-LABEL: entry:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 3)
// CHECK: br i1 %{{.*}}, label %fpclassify_end, label %fpclassify_not_nan
// CHECK-LABEL: fpclassify_not_nan:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 516)
// CHECK-LABEL: fpclassify_not_infinite:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 264)
// CHECK-LABEL: fpclassify_not_normal:
// CHECK: call i1 @llvm.is.fpclass.f32(float %{{.*}}, i32 144)
// CHECK-LABEL: fpclassify_end:
// CHECK: %fpclassify_result = phi i32 [ 3, %entry ], [ 516, %fpclassify_not_nan ], [ 264, %fpclassify_not_infinite ], [ 144, %fpclassify_not_normal ], [ 96, %fpclassify_not_subnormal ]
}
