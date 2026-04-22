; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx90a \
; RUN:     -amdgpu-disable-rewrite-mfma-form-sched-stage=false \
; RUN:     < %s | FileCheck %s
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx90a \
; RUN:     -amdgpu-disable-rewrite-mfma-form-sched-stage=false \
; RUN:     -stop-after=machine-scheduler \
; RUN:     < %s | FileCheck %s --check-prefix=MIR
;
; Verify the machine-scheduler-level rewrite() changes:
;   1. All 9 MFMAs: opcode _vgprcd_e64 -> _e64, class vreg -> areg (AGPR form).
;   2. Case 3 COPY: inserted after zeroinitializer def in loop.body (entry edge),
;      converts VGPR acc -> AGPR acc before MFMA (src2/dst reclassification).
;   3. Case 2 COPY: inserted at exit block entry (ReachingUseTracker),
;      converts AGPR MFMA result -> VGPR before fptrunc (V_CVT_F16_F32).
;
; CHECK-LABEL: test_ReachingUseTracker_crossblock_use:
; CHECK-COUNT-9: v_mfma_f32_4x4x2bf16 a[{{[0-9:]+}}], {{.*}}, {{.*}}, a[{{[0-9:]+}}]
;
; MIR-LABEL: name: test_ReachingUseTracker_crossblock_use
; MIR-LABEL: bb.0.entry:
;
; Case 3: 9 x (areg_128_align2 = COPY vreg) in entry block —
;   rewrite() inserts these after the zeroinitializer reaching-defs of MFMA src2.
;   Converts VGPR accumulator -> AGPR before first loop iteration.
; MIR-COUNT-9: areg_128_align2 = COPY
;
; MIR-LABEL: bb.1.loop.body:
;
; All 9 MFMAs rewritten: _vgprcd_e64 (VGPR C/D) -> _e64 (AGPR), dst is areg.
; MIR-COUNT-9: areg_128_align2 = V_MFMA_F32_4X4X2BF16_e64
; MIR-NOT:     V_MFMA_F32_4X4X2BF16_vgprcd_e64
;
; MIR-LABEL: bb.2.exit:
;
; Case 2: 9 x (vreg_128_align2 = COPY areg) at exit block start —
;   rewrite() inserts these via ReachingUseTracker.
;   MFMA dst (AGPR) -> VGPR before fptrunc (V_CVT_F16_F32).
; MIR-COUNT-9: vreg_128_align2 = COPY
;
; fptrunc lowering: V_CVT_F16_F32 operates on the new VGPR copies.
; MIR: V_CVT_F16_F32_e32

; Test: triggers RewriteMFMAFormStage::rewrite() with getRewriteCost() < 0
; and exercises the cross-block ReachingUseTracker path.
;
; Pressure design (gfx90a, separate AGPR/VGPR files):
;   8 loop-carried <32 x float> phi nodes (c0..c7) = 8*32=256 VGPRs non-MFMA.
;   Carrier back-edge: self-insertelement (no dep on MFMA results).
;   Carrier use in loop.body: store one element -> keeps carriers live.
;   GPU scheduler issues MFMAs first (long latency), then fills with stores.
;   Carriers naturally live across MFMAs: peak = 256+36 = 292 > 256 VGPRs.
;   After rewrite: ArchVGPR=256 (carriers), AGPR=36 < 256 -> no AGPR spill.
;   SpillBenefit = -(292-256)*2 * LoopFreq = -72*LoopFreq << 0
;   MFMA results used ONLY in exit block -> UseFreq~0 -> CopyCost~36.
;   getRewriteCost() << 0 -> rewrite() called.
;
; Cross-block use (ReachingUseTracker):
;   MFMAs in loop.body; fptrunc+store in exit block.
;   RUBlock(exit) != MI->getParent()(loop.body) -> ReachingUseTracker.

declare <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16>, <2 x i16>, <4 x float>, i32 immarg, i32 immarg, i32 immarg)

define amdgpu_kernel void @test_ReachingUseTracker_crossblock_use(
    ptr addrspace(1) %out,
    <2 x i16> %a,
    <2 x i16> %b,
    i32 %n) #0 {
entry:
  br label %loop.body

loop.body:
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop.body ]
  ; 8 loop-carried <32 x float>: 8*32=256 VGPRs non-MFMA pressure.
  ; Back-edge: self-insert (no dep on MFMA results, never DCE'd due to store use).
  %c0 = phi <32 x float> [ zeroinitializer, %entry ], [ %c0n, %loop.body ]
  %c1 = phi <32 x float> [ zeroinitializer, %entry ], [ %c1n, %loop.body ]
  %c2 = phi <32 x float> [ zeroinitializer, %entry ], [ %c2n, %loop.body ]
  %c3 = phi <32 x float> [ zeroinitializer, %entry ], [ %c3n, %loop.body ]
  %c4 = phi <32 x float> [ zeroinitializer, %entry ], [ %c4n, %loop.body ]
  %c5 = phi <32 x float> [ zeroinitializer, %entry ], [ %c5n, %loop.body ]
  %c6 = phi <32 x float> [ zeroinitializer, %entry ], [ %c6n, %loop.body ]
  %c7 = phi <32 x float> [ zeroinitializer, %entry ], [ %c7n, %loop.body ]
  ; 9 MFMA accumulators: 9*4=36 VGPRs.
  %acc0 = phi <4 x float> [ zeroinitializer, %entry ], [ %r0, %loop.body ]
  %acc1 = phi <4 x float> [ zeroinitializer, %entry ], [ %r1, %loop.body ]
  %acc2 = phi <4 x float> [ zeroinitializer, %entry ], [ %r2, %loop.body ]
  %acc3 = phi <4 x float> [ zeroinitializer, %entry ], [ %r3, %loop.body ]
  %acc4 = phi <4 x float> [ zeroinitializer, %entry ], [ %r4, %loop.body ]
  %acc5 = phi <4 x float> [ zeroinitializer, %entry ], [ %r5, %loop.body ]
  %acc6 = phi <4 x float> [ zeroinitializer, %entry ], [ %r6, %loop.body ]
  %acc7 = phi <4 x float> [ zeroinitializer, %entry ], [ %r7, %loop.body ]
  %acc8 = phi <4 x float> [ zeroinitializer, %entry ], [ %r8, %loop.body ]

  ; 9 MFMAs. Results only used in exit (CopyForUse exit only, UseFreq~0).
  %r0 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc0, i32 0, i32 0, i32 0)
  %r1 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc1, i32 0, i32 0, i32 0)
  %r2 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc2, i32 0, i32 0, i32 0)
  %r3 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc3, i32 0, i32 0, i32 0)
  %r4 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc4, i32 0, i32 0, i32 0)
  %r5 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc5, i32 0, i32 0, i32 0)
  %r6 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc6, i32 0, i32 0, i32 0)
  %r7 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc7, i32 0, i32 0, i32 0)
  %r8 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc8, i32 0, i32 0, i32 0)

  ; Variable index prevents folding of carrier self-inserts.
  %eidx = and i32 %i, 31
  ; Carrier self-insert: no dep on MFMA results. GPU scheduler fills MFMA
  ; latency with these, naturally scheduling them AFTER MFMAs -> carriers live
  ; across all MFMAs -> peak pressure 256+36=292 VGPRs.
  %c0e = extractelement <32 x float> %c0, i32 0
  %c1e = extractelement <32 x float> %c1, i32 0
  %c2e = extractelement <32 x float> %c2, i32 0
  %c3e = extractelement <32 x float> %c3, i32 0
  %c4e = extractelement <32 x float> %c4, i32 0
  %c5e = extractelement <32 x float> %c5, i32 0
  %c6e = extractelement <32 x float> %c6, i32 0
  %c7e = extractelement <32 x float> %c7, i32 0
  %c0n = insertelement <32 x float> %c0, float %c0e, i32 %eidx
  %c1n = insertelement <32 x float> %c1, float %c1e, i32 %eidx
  %c2n = insertelement <32 x float> %c2, float %c2e, i32 %eidx
  %c3n = insertelement <32 x float> %c3, float %c3e, i32 %eidx
  %c4n = insertelement <32 x float> %c4, float %c4e, i32 %eidx
  %c5n = insertelement <32 x float> %c5, float %c5e, i32 %eidx
  %c6n = insertelement <32 x float> %c6, float %c6e, i32 %eidx
  %c7n = insertelement <32 x float> %c7, float %c7e, i32 %eidx

  ; Store one carrier element (keeps carriers live, prevents DCE).
  %csum = fadd float %c0e, %c1e
  store float %csum, ptr addrspace(1) %out, align 4

  %i.next = add i32 %i, 1
  %cond = icmp eq i32 %i.next, %n
  br i1 %cond, label %exit, label %loop.body

exit:
  ; Cross-block non-MAI uses: MFMAs in loop.body, fptrunc uses in exit.
  ; -> ReachingUseTracker.
  %e0_0 = extractelement <4 x float> %r0, i32 0
  %e1_0 = extractelement <4 x float> %r0, i32 1
  %v0a  = insertelement <2 x float> poison, float %e0_0, i32 0
  %v0   = insertelement <2 x float> %v0a, float %e1_0, i32 1
  %h0   = fptrunc <2 x float> %v0 to <2 x half>
  %p_h0 = getelementptr i16, ptr addrspace(1) %out, i32 2
  store <2 x half> %h0, ptr addrspace(1) %p_h0, align 2

  %e0_1 = extractelement <4 x float> %r1, i32 0
  %e1_1 = extractelement <4 x float> %r1, i32 1
  %v1a  = insertelement <2 x float> poison, float %e0_1, i32 0
  %v1   = insertelement <2 x float> %v1a, float %e1_1, i32 1
  %h1   = fptrunc <2 x float> %v1 to <2 x half>
  %p_h1 = getelementptr i16, ptr addrspace(1) %out, i32 4
  store <2 x half> %h1, ptr addrspace(1) %p_h1, align 2

  %e0_2 = extractelement <4 x float> %r2, i32 0
  %e1_2 = extractelement <4 x float> %r2, i32 1
  %v2a  = insertelement <2 x float> poison, float %e0_2, i32 0
  %v2   = insertelement <2 x float> %v2a, float %e1_2, i32 1
  %h2   = fptrunc <2 x float> %v2 to <2 x half>
  %p_h2 = getelementptr i16, ptr addrspace(1) %out, i32 6
  store <2 x half> %h2, ptr addrspace(1) %p_h2, align 2

  %e0_3 = extractelement <4 x float> %r3, i32 0
  %e1_3 = extractelement <4 x float> %r3, i32 1
  %v3a  = insertelement <2 x float> poison, float %e0_3, i32 0
  %v3   = insertelement <2 x float> %v3a, float %e1_3, i32 1
  %h3   = fptrunc <2 x float> %v3 to <2 x half>
  %p_h3 = getelementptr i16, ptr addrspace(1) %out, i32 8
  store <2 x half> %h3, ptr addrspace(1) %p_h3, align 2

  %e0_4 = extractelement <4 x float> %r4, i32 0
  %e1_4 = extractelement <4 x float> %r4, i32 1
  %v4a  = insertelement <2 x float> poison, float %e0_4, i32 0
  %v4   = insertelement <2 x float> %v4a, float %e1_4, i32 1
  %h4   = fptrunc <2 x float> %v4 to <2 x half>
  %p_h4 = getelementptr i16, ptr addrspace(1) %out, i32 10
  store <2 x half> %h4, ptr addrspace(1) %p_h4, align 2

  %e0_5 = extractelement <4 x float> %r5, i32 0
  %e1_5 = extractelement <4 x float> %r5, i32 1
  %v5a  = insertelement <2 x float> poison, float %e0_5, i32 0
  %v5   = insertelement <2 x float> %v5a, float %e1_5, i32 1
  %h5   = fptrunc <2 x float> %v5 to <2 x half>
  %p_h5 = getelementptr i16, ptr addrspace(1) %out, i32 12
  store <2 x half> %h5, ptr addrspace(1) %p_h5, align 2

  %e0_6 = extractelement <4 x float> %r6, i32 0
  %e1_6 = extractelement <4 x float> %r6, i32 1
  %v6a  = insertelement <2 x float> poison, float %e0_6, i32 0
  %v6   = insertelement <2 x float> %v6a, float %e1_6, i32 1
  %h6   = fptrunc <2 x float> %v6 to <2 x half>
  %p_h6 = getelementptr i16, ptr addrspace(1) %out, i32 14
  store <2 x half> %h6, ptr addrspace(1) %p_h6, align 2

  %e0_7 = extractelement <4 x float> %r7, i32 0
  %e1_7 = extractelement <4 x float> %r7, i32 1
  %v7a  = insertelement <2 x float> poison, float %e0_7, i32 0
  %v7   = insertelement <2 x float> %v7a, float %e1_7, i32 1
  %h7   = fptrunc <2 x float> %v7 to <2 x half>
  %p_h7 = getelementptr i16, ptr addrspace(1) %out, i32 16
  store <2 x half> %h7, ptr addrspace(1) %p_h7, align 2

  %e0_8 = extractelement <4 x float> %r8, i32 0
  %e1_8 = extractelement <4 x float> %r8, i32 1
  %v8a  = insertelement <2 x float> poison, float %e0_8, i32 0
  %v8   = insertelement <2 x float> %v8a, float %e1_8, i32 1
  %h8   = fptrunc <2 x float> %v8 to <2 x half>
  %p_h8 = getelementptr i16, ptr addrspace(1) %out, i32 18
  store <2 x half> %h8, ptr addrspace(1) %p_h8, align 2

  ret void
}

attributes #0 = { "amdgpu-waves-per-eu"="1,1" "amdgpu-flat-work-group-size"="64,64" }
