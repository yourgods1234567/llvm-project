; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv64-unknown-unknown %s -o - | FileCheck %s --check-prefix=CHECK
; RUN: %if spirv-tools %{ llc -verify-machineinstrs -O0 -mtriple=spirv64-unknown-unknown %s -o - -filetype=obj | spirv-val %}


; CHECK: OpCapability Kernel
; CHECK-DAG: %[[#typeInt64:]] = OpTypeInt 64 0
; CHECK-DAG: %[[#typeInt32:]] = OpTypeInt 32 0
; CHECK-DAG: %[[#typeInt8:]] = OpTypeInt 8 0

; CHECK-DAG: %[[#Num0i32:]] = OpConstantNull %[[#typeInt32]]
; CHECK-DAG: %[[#Num1i32:]] = OpConstant %[[#typeInt32]] 1 
; CHECK-DAG: %[[#Num2i32:]] = OpConstant %[[#typeInt32]] 2
; CHECK-DAG: %[[#Num3i32:]] = OpConstant %[[#typeInt32]] 3 
; CHECK-DAG: %[[#Num8i32:]] = OpConstant %[[#typeInt32]] 8 
; CHECK-DAG: %[[#Num29i32:]] = OpConstant %[[#typeInt32]] 29
; CHECK-DAG: %[[#Num36i32:]] = OpConstant %[[#typeInt32]] 36

; CHECK-DAG: %[[#Array3x64:]] = OpTypeArray %[[#typeInt64:]] %[[#Num3i32]]
; CHECK-DAG: %[[#TypeNDRangeStruct:]] = OpTypeStruct %[[#typeInt32]] %[[#Array3x64]] %[[#Array3x64]] %[[#Array3x64]]

; CHECK-DAG: %[[#pointerInt8:]] = OpTypePointer Generic %[[#typeInt8]]
; CHECK-DAG: %[[#nullPtrInt8:]] = OpConstantNull %[[#pointerInt8]]
; CHECK-DAG: %[[#nullArray3x64:]] = OpConstantNull %[[#Array3x64]]

; CHECK-LABEL: ; -- Begin function test_spirv_enqueue_kernel
; CHECK: %[[#]] = OpEnqueueKernel %[[#typeInt32]] %[[#]] %[[#Num0i32]] %[[#]] %[[#Num0i32]] %[[#nullPtrInt8]] %[[#nullPtrInt8]] %[[#]] %[[#]] %[[#Num8i32]] %[[#Num8i32]]

; CHECK-LABEL: ; -- Begin function device_side_enqueue

; CHECK: %[[#NDRange3sret:]] = OpBuildNDRange %[[#TypeNDRangeStruct]] %[[#]] %[[#nullArray3x64]] %[[#nullArray3x64]]
; CHECK-NEXT: OpStore %[[#NDRange3:]] %[[#NDRange3sret]]



;; #define NULL ((void*)0)
;; kernel void device_side_enqueue(global int *a, global int *b, int i, char c0) {
;;     queue_t default_queue;
;;     unsigned flags = 0;
;;     ndrange_t ndrange;
;;     clk_event_t clk_event;
;;     clk_event_t event_wait_list;
;;     clk_event_t event_wait_list2[] = {clk_event};
;;
;;     const size_t gs[] = {1,2,4};
;;
;;     // enqueue empty kernel
; CHECK: %[[#]] = OpEnqueueKernel %[[#typeInt32]] %[[#default_queue:]] %[[#Num1i32]] %[[#NDRange3]] %[[#Num0i32]] %[[#nullPtrInt8]] %[[#nullPtrInt8]] %[[#]] %[[#]] %[[#Num8i32]] %[[#Num8i32]]
;;     enqueue_kernel(default_queue,
;;             CLK_ENQUEUE_FLAGS_WAIT_KERNEL,
;;             ndrange_3D(gs),
;;             0, NULL, NULL,
;;             ^(){});
;;
;;     // no events, no var args
; CHECK: %[[#]] = OpEnqueueKernel %[[#typeInt32]] %[[#default_queue]] %[[#Num0i32]] %[[#]] %[[#Num0i32]] %[[#nullPtrInt8]] %[[#nullPtrInt8]] %[[#]] %[[#]] %[[#Num29i32]] %[[#Num8i32]]
;;     enqueue_kernel(default_queue, flags, ndrange,
;;             ^(void) {
;;             a[i] = c0;
;;             });
;;
;;     // event, no var args
; CHECK: %[[#]] = OpEnqueueKernel %[[#typeInt32]] %[[#default_queue]] %[[#Num0i32]] %[[#]] %[[#Num2i32]] %[[#event_wait_list:]] %[[#clk_event:]] %[[#]] %[[#]] %[[#Num36i32]] %[[#Num8i32]]
;;     enqueue_kernel(default_queue, flags, ndrange, 2, &event_wait_list, &clk_event,
;;             ^(void) {
;;             a[i] = b[i];
;;             });
;;
;;     // events, var arg
; CHECK: %[[#]] = OpEnqueueKernel %[[#typeInt32]] %[[#default_queue]] %[[#Num0i32]] %[[#]] %[[#Num2i32]] %[[#event_wait_list2:]] %[[#clk_event]] %[[#]] %[[#]] %[[#Num8i32]] %[[#Num8i32]] %[[#]]
;;     char c;
;;     enqueue_kernel(default_queue, flags, ndrange, 2, event_wait_list2, &clk_event,
;;             ^(local void *p) {
;;             return;
;;             },
;;             c);
;;
;;     // no events, three var args
; CHECK: %[[#]] = OpEnqueueKernel %[[#typeInt32]] %[[#default_queue]] %[[#Num0i32]] %[[#]] %[[#Num0i32]] %[[#nullPtrInt8]] %[[#nullPtrInt8]] %[[#]] %[[#]] %[[#Num8i32]] %[[#Num8i32]] %[[#]] %[[#]] %[[#]]
;;     enqueue_kernel(default_queue, flags, ndrange,
;;             ^(local void *p1, local void *p2, local void *p3) {
;;             return;
;;             },
;;             101, 102, 104);
;;
;;     // null event, no var args
; CHECK: %[[#]] = OpEnqueueKernel %[[#typeInt32]] %[[#default_queue]] %[[#Num0i32]] %[[#]] %[[#Num0i32]] %[[#nullPtrInt8]] %[[#clk_event]] %[[#]] %[[#]] %[[#Num36i32]] %[[#Num8i32]]
;;     enqueue_kernel(default_queue, flags, ndrange, 0, NULL, &clk_event,
;;             ^(void) {
;;             a[i] = b[i];
;;             });
;; }


%struct.ndrange_t = type { i32, [3 x i64], [3 x i64], [3 x i64] }

@__const.device_side_enqueue.gs = private unnamed_addr addrspace(2) constant [3 x i64] [i64 1, i64 2, i64 4], align 8
@__block_literal_global.spirv = internal addrspace(1) constant { i32, i32, ptr addrspace(4) } { i32 16, i32 8, ptr addrspace(4) addrspacecast (ptr @__test_spirv_block_invoke to ptr addrspace(4)) }, align 8 #0

; Function Attrs: convergent norecurse nounwind
define spir_kernel void @test_spirv_enqueue_kernel(target("spirv.Queue") %queue) #1 {
entry:
  %ndrange = alloca %struct.ndrange_t, align 8
  %local_sizes = alloca [1 x i64], align 8
  store i64 32, ptr %local_sizes, align 8
  %block_param = addrspacecast ptr addrspace(1) @__block_literal_global.spirv to ptr addrspace(4)
  %result = call spir_func i32 @__spirv_EnqueueKernel(
    target("spirv.Queue") %queue,
    i32 0,
    ptr %ndrange,
    i32 0,
    ptr addrspace(4) null,
    ptr addrspace(4) null,
    ptr addrspace(4) addrspacecast (ptr @__test_spirv_block_invoke_kernel to ptr addrspace(4)),
    ptr addrspace(4) %block_param,
    i32 1,
    ptr %local_sizes)
  ret void
}

define internal spir_func void @__test_spirv_block_invoke(ptr addrspace(4) %.block_descriptor) #5 {
entry:
  ret void
}

define internal spir_kernel void @__test_spirv_block_invoke_kernel(ptr addrspace(4) %.block_descriptor) #5 {
entry:
  ret void
}

declare spir_func i32 @__spirv_EnqueueKernel(target("spirv.Queue"), i32, ptr, i32, ptr addrspace(4), ptr addrspace(4), ptr addrspace(4), ptr addrspace(4), i32, ptr)
@__block_literal_global = internal addrspace(1) constant { i32, i32, ptr addrspace(4) } { i32 16, i32 8, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke to ptr addrspace(4)) }, align 8 #0
@__block_literal_global.1 = internal addrspace(1) constant { i32, i32, ptr addrspace(4) } { i32 16, i32 8, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_4 to ptr addrspace(4)) }, align 8 #0
@__block_literal_global.2 = internal addrspace(1) constant { i32, i32, ptr addrspace(4) } { i32 16, i32 8, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_5 to ptr addrspace(4)) }, align 8 #0

; Function Attrs: convergent norecurse nounwind
define spir_kernel void @device_side_enqueue(ptr addrspace(1) noundef align 4 %a, ptr addrspace(1) noundef align 4 %b, i32 noundef %i, i8 noundef signext %c0, target("spirv.Queue") %default_queue) local_unnamed_addr #1 !kernel_arg_addr_space !6 !kernel_arg_access_qual !7 !kernel_arg_type !8 !kernel_arg_base_type !8 !kernel_arg_type_qual !9 {
entry:
  %clk_event.i = alloca target("spirv.DeviceEvent"), align 8
  %event_wait_list.i = alloca target("spirv.DeviceEvent"), align 8
  %event_wait_list2.i = alloca [1 x target("spirv.DeviceEvent")], align 8
  %gs.i = alloca [3 x i64], align 8
  %tmp.i = alloca %struct.ndrange_t, align 8
  %tmp1.i = alloca %struct.ndrange_t, align 8
  %block.i = alloca <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>, align 8
  %tmp4.i = alloca %struct.ndrange_t, align 8
  %block5.i = alloca <{ i32, i32, ptr addrspace(4), ptr addrspace(1), ptr addrspace(1), i32 }>, align 8
  %tmp12.i = alloca %struct.ndrange_t, align 8
  %block_sizes.i = alloca [1 x i64], align 8
  %tmp14.i = alloca %struct.ndrange_t, align 8
  %block_sizes15.i = alloca [3 x i64], align 8
  %tmp16.i = alloca %struct.ndrange_t, align 8
  %block17.i = alloca <{ i32, i32, ptr addrspace(4), ptr addrspace(1), ptr addrspace(1), i32 }>, align 8
  call void @llvm.lifetime.start.p0(ptr nonnull %tmp.i)
  call void @llvm.lifetime.start.p0(ptr nonnull %tmp1.i)
  call void @llvm.lifetime.start.p0(ptr nonnull %block.i)
  call void @llvm.lifetime.start.p0(ptr nonnull %tmp4.i)
  call void @llvm.lifetime.start.p0(ptr nonnull %block5.i)
  call void @llvm.lifetime.start.p0(ptr nonnull %tmp12.i)
  call void @llvm.lifetime.start.p0(ptr nonnull %tmp14.i)
  call void @llvm.lifetime.start.p0(ptr nonnull %tmp16.i)
  call void @llvm.lifetime.start.p0(ptr nonnull %block17.i)
  call void @llvm.lifetime.start.p0(ptr nonnull %clk_event.i) #8
  call void @llvm.lifetime.start.p0(ptr nonnull %event_wait_list.i) #8
  call void @llvm.lifetime.start.p0(ptr nonnull %event_wait_list2.i) #8
  call void @llvm.lifetime.start.p0(ptr nonnull %gs.i) #8
  call void @llvm.memcpy.p0.p2.i64(ptr noundef nonnull align 8 dereferenceable(24) %gs.i, ptr addrspace(2) noundef align 8 dereferenceable(24) @__const.device_side_enqueue.gs, i64 24, i1 false)
  call spir_func void @_Z10ndrange_3DPKm(ptr dead_on_unwind nonnull writable sret(%struct.ndrange_t) align 8 %tmp.i, ptr noundef nonnull %gs.i) #9
  %0 = call spir_func i32 @__enqueue_kernel_basic_events(target("spirv.Queue") %default_queue, i32 1, ptr nonnull %tmp.i, i32 0, ptr addrspace(4) null, ptr addrspace(4) null, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_kernel to ptr addrspace(4)), ptr addrspace(4) addrspacecast (ptr addrspace(1) @__block_literal_global to ptr addrspace(4))) #8
  store i32 29, ptr %block.i, align 8
  %block.align.i = getelementptr inbounds nuw i8, ptr %block.i, i64 4
  store i32 8, ptr %block.align.i, align 4
  %block.invoke.i = getelementptr inbounds nuw i8, ptr %block.i, i64 8
  store ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_2 to ptr addrspace(4)), ptr %block.invoke.i, align 8
  %block.captured.i = getelementptr inbounds nuw i8, ptr %block.i, i64 16
  store ptr addrspace(1) %a, ptr %block.captured.i, align 8, !tbaa !10
  %block.captured2.i = getelementptr inbounds nuw i8, ptr %block.i, i64 24
  store i32 %i, ptr %block.captured2.i, align 8, !tbaa !2
  %block.captured3.i = getelementptr inbounds nuw i8, ptr %block.i, i64 28
  store i8 %c0, ptr %block.captured3.i, align 4, !tbaa !13
  %1 = addrspacecast ptr %block.i to ptr addrspace(4)
  %2 = call spir_func i32 @__enqueue_kernel_basic(target("spirv.Queue") %default_queue, i32 0, ptr nonnull %tmp1.i, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_2_kernel to ptr addrspace(4)), ptr addrspace(4) %1) #8
  %3 = addrspacecast ptr %event_wait_list.i to ptr addrspace(4)
  %4 = addrspacecast ptr %clk_event.i to ptr addrspace(4)
  store i32 36, ptr %block5.i, align 8
  %block.align7.i = getelementptr inbounds nuw i8, ptr %block5.i, i64 4
  store i32 8, ptr %block.align7.i, align 4
  %block.invoke8.i = getelementptr inbounds nuw i8, ptr %block5.i, i64 8
  store ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_3 to ptr addrspace(4)), ptr %block.invoke8.i, align 8
  %block.captured9.i = getelementptr inbounds nuw i8, ptr %block5.i, i64 16
  store ptr addrspace(1) %a, ptr %block.captured9.i, align 8, !tbaa !10
  %block.captured10.i = getelementptr inbounds nuw i8, ptr %block5.i, i64 32
  store i32 %i, ptr %block.captured10.i, align 8, !tbaa !2
  %block.captured11.i = getelementptr inbounds nuw i8, ptr %block5.i, i64 24
  store ptr addrspace(1) %b, ptr %block.captured11.i, align 8, !tbaa !10
  %5 = addrspacecast ptr %block5.i to ptr addrspace(4)
  %6 = call spir_func i32 @__enqueue_kernel_basic_events(target("spirv.Queue") %default_queue, i32 0, ptr nonnull %tmp4.i, i32 2, ptr addrspace(4) %3, ptr addrspace(4) %4, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_3_kernel to ptr addrspace(4)), ptr addrspace(4) %5) #8
  %7 = addrspacecast ptr %event_wait_list2.i to ptr addrspace(4)
  call void @llvm.lifetime.start.p0(ptr nonnull %block_sizes.i) #8
  store i64 0, ptr %block_sizes.i, align 8
  %8 = call spir_func i32 @__enqueue_kernel_events_varargs(target("spirv.Queue") %default_queue, i32 0, ptr nonnull %tmp12.i, i32 2, ptr addrspace(4) %7, ptr addrspace(4) %4, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_4_kernel to ptr addrspace(4)), ptr addrspace(4) addrspacecast (ptr addrspace(1) @__block_literal_global.1 to ptr addrspace(4)), i32 1, ptr nonnull %block_sizes.i) #8
  call void @llvm.lifetime.end.p0(ptr nonnull %block_sizes.i) #8
  call void @llvm.lifetime.start.p0(ptr nonnull %block_sizes15.i) #8
  store i64 101, ptr %block_sizes15.i, align 8
  %9 = getelementptr inbounds nuw i8, ptr %block_sizes15.i, i64 8
  store i64 102, ptr %9, align 8
  %10 = getelementptr inbounds nuw i8, ptr %block_sizes15.i, i64 16
  store i64 104, ptr %10, align 8
  %11 = call spir_func i32 @__enqueue_kernel_varargs(target("spirv.Queue") %default_queue, i32 0, ptr nonnull %tmp14.i, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_5_kernel to ptr addrspace(4)), ptr addrspace(4) addrspacecast (ptr addrspace(1) @__block_literal_global.2 to ptr addrspace(4)), i32 3, ptr nonnull %block_sizes15.i) #8
  call void @llvm.lifetime.end.p0(ptr nonnull %block_sizes15.i) #8
  store i32 36, ptr %block17.i, align 8
  %block.align19.i = getelementptr inbounds nuw i8, ptr %block17.i, i64 4
  store i32 8, ptr %block.align19.i, align 4
  %block.invoke20.i = getelementptr inbounds nuw i8, ptr %block17.i, i64 8
  store ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_6 to ptr addrspace(4)), ptr %block.invoke20.i, align 8
  %block.captured21.i = getelementptr inbounds nuw i8, ptr %block17.i, i64 16
  store ptr addrspace(1) %a, ptr %block.captured21.i, align 8, !tbaa !10
  %block.captured22.i = getelementptr inbounds nuw i8, ptr %block17.i, i64 32
  store i32 %i, ptr %block.captured22.i, align 8, !tbaa !2
  %block.captured23.i = getelementptr inbounds nuw i8, ptr %block17.i, i64 24
  store ptr addrspace(1) %b, ptr %block.captured23.i, align 8, !tbaa !10
  %12 = addrspacecast ptr %block17.i to ptr addrspace(4)
  %13 = call spir_func i32 @__enqueue_kernel_basic_events(target("spirv.Queue") %default_queue, i32 0, ptr nonnull %tmp16.i, i32 0, ptr addrspace(4) null, ptr addrspace(4) %4, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_6_kernel to ptr addrspace(4)), ptr addrspace(4) %12) #8
  call void @llvm.lifetime.end.p0(ptr nonnull %gs.i) #8
  call void @llvm.lifetime.end.p0(ptr nonnull %event_wait_list2.i) #8
  call void @llvm.lifetime.end.p0(ptr nonnull %event_wait_list.i) #8
  call void @llvm.lifetime.end.p0(ptr nonnull %clk_event.i) #8
  call void @llvm.lifetime.end.p0(ptr nonnull %tmp.i)
  call void @llvm.lifetime.end.p0(ptr nonnull %tmp1.i)
  call void @llvm.lifetime.end.p0(ptr nonnull %block.i)
  call void @llvm.lifetime.end.p0(ptr nonnull %tmp4.i)
  call void @llvm.lifetime.end.p0(ptr nonnull %block5.i)
  call void @llvm.lifetime.end.p0(ptr nonnull %tmp12.i)
  call void @llvm.lifetime.end.p0(ptr nonnull %tmp14.i)
  call void @llvm.lifetime.end.p0(ptr nonnull %tmp16.i)
  call void @llvm.lifetime.end.p0(ptr nonnull %block17.i)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #2

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p2.i64(ptr noalias writeonly captures(none), ptr addrspace(2) noalias readonly captures(none), i64, i1 immarg) #3

; Function Attrs: convergent nounwind
declare spir_func void @_Z10ndrange_3DPKm(ptr dead_on_unwind writable sret(%struct.ndrange_t) align 8, ptr noundef) local_unnamed_addr #4

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal spir_func void @__device_side_enqueue_block_invoke(ptr addrspace(4) readnone captures(none) %.block_descriptor) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal spir_kernel void @__device_side_enqueue_block_invoke_kernel(ptr addrspace(4) readnone captures(none) %0) #5 {
entry:
  ret void
}

declare spir_func i32 @__enqueue_kernel_basic_events(target("spirv.Queue"), i32, ptr, i32, ptr addrspace(4), ptr addrspace(4), ptr addrspace(4), ptr addrspace(4)) local_unnamed_addr

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: none, target_mem: none)
define internal spir_func void @__device_side_enqueue_block_invoke_2(ptr addrspace(4) noundef readonly captures(none) %.block_descriptor) #6 {
entry:
  %block.capture.addr = getelementptr inbounds nuw i8, ptr addrspace(4) %.block_descriptor, i64 28
  %0 = load i8, ptr addrspace(4) %block.capture.addr, align 4, !tbaa !13
  %conv = sext i8 %0 to i32
  %block.capture.addr1 = getelementptr inbounds nuw i8, ptr addrspace(4) %.block_descriptor, i64 16
  %1 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr1, align 8, !tbaa !10
  %block.capture.addr2 = getelementptr inbounds nuw i8, ptr addrspace(4) %.block_descriptor, i64 24
  %2 = load i32, ptr addrspace(4) %block.capture.addr2, align 8, !tbaa !2
  %idxprom = sext i32 %2 to i64
  %arrayidx = getelementptr inbounds [4 x i8], ptr addrspace(1) %1, i64 %idxprom
  store i32 %conv, ptr addrspace(1) %arrayidx, align 4, !tbaa !2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: none, target_mem: none)
define internal spir_kernel void @__device_side_enqueue_block_invoke_2_kernel(ptr addrspace(4) readonly captures(none) %0) #6 {
entry:
  %block.capture.addr.i = getelementptr inbounds nuw i8, ptr addrspace(4) %0, i64 28
  %1 = load i8, ptr addrspace(4) %block.capture.addr.i, align 4, !tbaa !13
  %conv.i = sext i8 %1 to i32
  %block.capture.addr1.i = getelementptr inbounds nuw i8, ptr addrspace(4) %0, i64 16
  %2 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr1.i, align 8, !tbaa !10
  %block.capture.addr2.i = getelementptr inbounds nuw i8, ptr addrspace(4) %0, i64 24
  %3 = load i32, ptr addrspace(4) %block.capture.addr2.i, align 8, !tbaa !2
  %idxprom.i = sext i32 %3 to i64
  %arrayidx.i = getelementptr inbounds [4 x i8], ptr addrspace(1) %2, i64 %idxprom.i
  store i32 %conv.i, ptr addrspace(1) %arrayidx.i, align 4, !tbaa !2
  ret void
}

declare spir_func i32 @__enqueue_kernel_basic(target("spirv.Queue"), i32, ptr, ptr addrspace(4), ptr addrspace(4)) local_unnamed_addr

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none, target_mem: none)
define internal spir_func void @__device_side_enqueue_block_invoke_3(ptr addrspace(4) noundef readonly captures(none) %.block_descriptor) #7 {
entry:
  %block.capture.addr = getelementptr inbounds nuw i8, ptr addrspace(4) %.block_descriptor, i64 24
  %0 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr, align 8, !tbaa !10
  %block.capture.addr1 = getelementptr inbounds nuw i8, ptr addrspace(4) %.block_descriptor, i64 32
  %1 = load i32, ptr addrspace(4) %block.capture.addr1, align 8, !tbaa !2
  %idxprom = sext i32 %1 to i64
  %arrayidx = getelementptr inbounds [4 x i8], ptr addrspace(1) %0, i64 %idxprom
  %2 = load i32, ptr addrspace(1) %arrayidx, align 4, !tbaa !2
  %block.capture.addr2 = getelementptr inbounds nuw i8, ptr addrspace(4) %.block_descriptor, i64 16
  %3 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr2, align 8, !tbaa !10
  %arrayidx5 = getelementptr inbounds [4 x i8], ptr addrspace(1) %3, i64 %idxprom
  store i32 %2, ptr addrspace(1) %arrayidx5, align 4, !tbaa !2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none, target_mem: none)
define internal spir_kernel void @__device_side_enqueue_block_invoke_3_kernel(ptr addrspace(4) readonly captures(none) %0) #7 {
entry:
  %block.capture.addr.i = getelementptr inbounds nuw i8, ptr addrspace(4) %0, i64 24
  %1 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr.i, align 8, !tbaa !10
  %block.capture.addr1.i = getelementptr inbounds nuw i8, ptr addrspace(4) %0, i64 32
  %2 = load i32, ptr addrspace(4) %block.capture.addr1.i, align 8, !tbaa !2
  %idxprom.i = sext i32 %2 to i64
  %arrayidx.i = getelementptr inbounds [4 x i8], ptr addrspace(1) %1, i64 %idxprom.i
  %3 = load i32, ptr addrspace(1) %arrayidx.i, align 4, !tbaa !2
  %block.capture.addr2.i = getelementptr inbounds nuw i8, ptr addrspace(4) %0, i64 16
  %4 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr2.i, align 8, !tbaa !10
  %arrayidx5.i = getelementptr inbounds [4 x i8], ptr addrspace(1) %4, i64 %idxprom.i
  store i32 %3, ptr addrspace(1) %arrayidx5.i, align 4, !tbaa !2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal spir_func void @__device_side_enqueue_block_invoke_4(ptr addrspace(4) readnone captures(none) %.block_descriptor, ptr addrspace(3) readnone captures(none) %p) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal spir_kernel void @__device_side_enqueue_block_invoke_4_kernel(ptr addrspace(4) readnone captures(none) %0, ptr addrspace(3) readnone captures(none) %1) #5 {
entry:
  ret void
}

declare spir_func i32 @__enqueue_kernel_events_varargs(target("spirv.Queue"), i32, ptr, i32, ptr addrspace(4), ptr addrspace(4), ptr addrspace(4), ptr addrspace(4), i32, ptr) local_unnamed_addr

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #2

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal spir_func void @__device_side_enqueue_block_invoke_5(ptr addrspace(4) readnone captures(none) %.block_descriptor, ptr addrspace(3) readnone captures(none) %p1, ptr addrspace(3) readnone captures(none) %p2, ptr addrspace(3) readnone captures(none) %p3) #5 {
entry:
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define internal spir_kernel void @__device_side_enqueue_block_invoke_5_kernel(ptr addrspace(4) readnone captures(none) %0, ptr addrspace(3) readnone captures(none) %1, ptr addrspace(3) readnone captures(none) %2, ptr addrspace(3) readnone captures(none) %3) #5 {
entry:
  ret void
}

declare spir_func i32 @__enqueue_kernel_varargs(target("spirv.Queue"), i32, ptr, ptr addrspace(4), ptr addrspace(4), i32, ptr) local_unnamed_addr

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none, target_mem: none)
define internal spir_func void @__device_side_enqueue_block_invoke_6(ptr addrspace(4) noundef readonly captures(none) %.block_descriptor) #7 {
entry:
  %block.capture.addr = getelementptr inbounds nuw i8, ptr addrspace(4) %.block_descriptor, i64 24
  %0 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr, align 8, !tbaa !10
  %block.capture.addr1 = getelementptr inbounds nuw i8, ptr addrspace(4) %.block_descriptor, i64 32
  %1 = load i32, ptr addrspace(4) %block.capture.addr1, align 8, !tbaa !2
  %idxprom = sext i32 %1 to i64
  %arrayidx = getelementptr inbounds [4 x i8], ptr addrspace(1) %0, i64 %idxprom
  %2 = load i32, ptr addrspace(1) %arrayidx, align 4, !tbaa !2
  %block.capture.addr2 = getelementptr inbounds nuw i8, ptr addrspace(4) %.block_descriptor, i64 16
  %3 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr2, align 8, !tbaa !10
  %arrayidx5 = getelementptr inbounds [4 x i8], ptr addrspace(1) %3, i64 %idxprom
  store i32 %2, ptr addrspace(1) %arrayidx5, align 4, !tbaa !2
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none, target_mem: none)
define internal spir_kernel void @__device_side_enqueue_block_invoke_6_kernel(ptr addrspace(4) readonly captures(none) %0) #7 {
entry:
  %block.capture.addr.i = getelementptr inbounds nuw i8, ptr addrspace(4) %0, i64 24
  %1 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr.i, align 8, !tbaa !10
  %block.capture.addr1.i = getelementptr inbounds nuw i8, ptr addrspace(4) %0, i64 32
  %2 = load i32, ptr addrspace(4) %block.capture.addr1.i, align 8, !tbaa !2
  %idxprom.i = sext i32 %2 to i64
  %arrayidx.i = getelementptr inbounds [4 x i8], ptr addrspace(1) %1, i64 %idxprom.i
  %3 = load i32, ptr addrspace(1) %arrayidx.i, align 4, !tbaa !2
  %block.capture.addr2.i = getelementptr inbounds nuw i8, ptr addrspace(4) %0, i64 16
  %4 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr2.i, align 8, !tbaa !10
  %arrayidx5.i = getelementptr inbounds [4 x i8], ptr addrspace(1) %4, i64 %idxprom.i
  store i32 %3, ptr addrspace(1) %arrayidx5.i, align 4, !tbaa !2
  ret void
}

attributes #0 = { "objc_arc_inert" }
attributes #1 = { convergent norecurse nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { convergent nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #5 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #6 = { mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: readwrite, inaccessiblemem: none, target_mem: none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #7 = { mustprogress nofree norecurse nosync nounwind willreturn memory(readwrite, inaccessiblemem: none, target_mem: none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #8 = { nounwind }
attributes #9 = { convergent nounwind }

!opencl.ocl.version = !{!0}
!llvm.errno.tbaa = !{!2}

!0 = !{i32 3, i32 0}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{i32 1, i32 1, i32 0, i32 0}
!7 = !{!"none", !"none", !"none", !"none"}
!8 = !{!"int*", !"int*", !"int", !"char"}
!9 = !{!"", !"", !"", !""}
!10 = !{!11, !11, i64 0}
!11 = !{!"p1 int", !12, i64 0}
!12 = !{!"any pointer", !4, i64 0}
!13 = !{!4, !4, i64 0}
