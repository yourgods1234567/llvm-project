; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx90a \
; RUN:     -amdgpu-disable-rewrite-mfma-form-sched-stage=false \
; RUN:     < %s | FileCheck %s
;
; Verify MIR state BEFORE machine-scheduler (rewrite not yet applied):
;   All 9 MFMAs use VGPR form: vreg_128_align2 / V_MFMA_F32_4X4X2BF16_vgprcd_e64.
;   No AGPR COPYs inserted yet.
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx90a \
; RUN:     -amdgpu-disable-rewrite-mfma-form-sched-stage=false \
; RUN:     -stop-before=machine-scheduler \
; RUN:     < %s | FileCheck %s --check-prefix=BEFORE
;
; Verify MIR state AFTER machine-scheduler (rewrite applied):
;   Case 3: 9 x (areg_128_align2 = COPY vreg) in bb.0.entry.
;   loop.body: all 9 MFMAs rewritten to V_MFMA_F32_4X4X2BF16_e64 with areg dst.
;   Case 2: vreg_128_align2 = COPY areg in bb.2.exit.
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx90a \
; RUN:     -amdgpu-disable-rewrite-mfma-form-sched-stage=false \
; RUN:     -stop-after=machine-scheduler \
; RUN:     < %s | FileCheck %s --check-prefix=MIR
;
; BEFORE-LABEL: name: test_case2_case3
; BEFORE-LABEL: bb.1.loop.body:
; BEFORE-COUNT-9: vreg_128_align2 = V_MFMA_F32_4X4X2BF16_vgprcd_e64
; BEFORE-NOT:     V_MFMA_F32_4X4X2BF16_e64
; BEFORE-LABEL: bb.2.exit:
; BEFORE-NOT:    areg_128_align2 = COPY
;
; MIR-LABEL: name: test_case2_case3
; MIR-LABEL: bb.0.entry:
;
; Case 3: 9 x (areg_128_align2 = COPY vreg) inserted in entry.
;   Converts VGPR zeroinit accumulator -> AGPR before first loop iteration.
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
; Case 2: vreg_128_align2 = COPY areg inserted at exit block start.
;   Converts AGPR MFMA result -> VGPR before extractelement use.
; MIR: vreg_128_align2 = COPY

; Test: RewriteMFMAFormStage — Case 2 + Case 3
;
; Case 2: MFMA dst has a non-MAI USE in a different block (exit).
; Case 3: At that use point, %acc has a non-MAI reaching def (zeroinitializer
;         from entry, lowered to v_mov_b32).
;
; Pressure design (gfx90a, minWavesPerEU=1):
;   8 loop-carried <32 x float> phi nodes (c0..c7) = 8*32 = 256 VGPRs non-MFMA.
;   Variable-index insertelement prevents carrier DCE and keeps all carriers
;   live across the MFMA region.
;   9 MFMA accumulators (mfma.f32.4x4x2bf16, dst=<4 x float>) = 9*4 = 36 VGPRs.
;   Peak ArchVGPR = 256+36 = 292 > 256 (gfx90a limit) -> rewrite fires.
;
; Expected output (rewrite fires, cost <= 0):
;   Case 3: v_accvgpr_write (VGPR->AGPR) in entry for each MFMA zeroinit.
;   Case 2: v_accvgpr_read  (AGPR->VGPR) in exit before extractelement uses.

declare <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16>, <2 x i16>, <4 x float>, i32 immarg, i32 immarg, i32 immarg)

define amdgpu_kernel void @test_case2_case3(
; CHECK-COUNT-9: v_mfma_f32_4x4x2bf16 a[{{[0-9:]+}}], {{.*}}, {{.*}}, a[{{[0-9:]+}}]
    ptr addrspace(1) %out,
    <2 x i16> %a,
    <2 x i16> %b,
    i32 %n) #0 {
entry:
  br label %loop.body

loop.body:
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop.body ]
  ; 8 loop-carried <32 x float>: 8*32=256 VGPRs non-MFMA pressure.
  %c0 = phi <32 x float> [ zeroinitializer, %entry ], [ %c0n, %loop.body ]
  %c1 = phi <32 x float> [ zeroinitializer, %entry ], [ %c1n, %loop.body ]
  %c2 = phi <32 x float> [ zeroinitializer, %entry ], [ %c2n, %loop.body ]
  %c3 = phi <32 x float> [ zeroinitializer, %entry ], [ %c3n, %loop.body ]
  %c4 = phi <32 x float> [ zeroinitializer, %entry ], [ %c4n, %loop.body ]
  %c5 = phi <32 x float> [ zeroinitializer, %entry ], [ %c5n, %loop.body ]
  %c6 = phi <32 x float> [ zeroinitializer, %entry ], [ %c6n, %loop.body ]
  %c7 = phi <32 x float> [ zeroinitializer, %entry ], [ %c7n, %loop.body ]
  ; 9 MFMA accumulators: 9*4=36 VGPRs. Case 3: entry zeroinitializer -> AGPR.
  %acc0 = phi <4 x float> [ zeroinitializer, %entry ], [ %r0, %loop.body ]
  %acc1 = phi <4 x float> [ zeroinitializer, %entry ], [ %r1, %loop.body ]
  %acc2 = phi <4 x float> [ zeroinitializer, %entry ], [ %r2, %loop.body ]
  %acc3 = phi <4 x float> [ zeroinitializer, %entry ], [ %r3, %loop.body ]
  %acc4 = phi <4 x float> [ zeroinitializer, %entry ], [ %r4, %loop.body ]
  %acc5 = phi <4 x float> [ zeroinitializer, %entry ], [ %r5, %loop.body ]
  %acc6 = phi <4 x float> [ zeroinitializer, %entry ], [ %r6, %loop.body ]
  %acc7 = phi <4 x float> [ zeroinitializer, %entry ], [ %r7, %loop.body ]
  %acc8 = phi <4 x float> [ zeroinitializer, %entry ], [ %r8, %loop.body ]

  ; 9 MFMAs — results only used in exit (Case 2: cross-block non-MAI use).
  %r0 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc0, i32 0, i32 0, i32 0)
  %r1 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc1, i32 0, i32 0, i32 0)
  %r2 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc2, i32 0, i32 0, i32 0)
  %r3 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc3, i32 0, i32 0, i32 0)
  %r4 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc4, i32 0, i32 0, i32 0)
  %r5 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc5, i32 0, i32 0, i32 0)
  %r6 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc6, i32 0, i32 0, i32 0)
  %r7 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc7, i32 0, i32 0, i32 0)
  %r8 = call <4 x float> @llvm.amdgcn.mfma.f32.4x4x2bf16(<2 x i16> %a, <2 x i16> %b, <4 x float> %acc8, i32 0, i32 0, i32 0)

  ; Variable index prevents folding: keeps carriers live across all MFMAs.
  %eidx = and i32 %i, 31
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

  %csum = fadd float %c0e, %c1e
  store float %csum, ptr addrspace(1) %out, align 4

  %i.next = add i32 %i, 1
  %cond = icmp eq i32 %i.next, %n
  br i1 %cond, label %exit, label %loop.body

exit:
  ; Case 2: non-MAI uses of MFMA dst in exit block (different block from loop.body).
  ; Case 3: reaching def of each %acc in entry is zeroinitializer (non-MAI).
  ; Expected: v_accvgpr_read (AGPR->VGPR) inserted before these extractelements.
  %e0 = extractelement <4 x float> %r0, i32 0
  %e1 = extractelement <4 x float> %r1, i32 0
  store float %e0, ptr addrspace(1) %out, align 4
  %p1 = getelementptr float, ptr addrspace(1) %out, i32 1
  store float %e1, ptr addrspace(1) %p1, align 4
  ret void
}

attributes #0 = { "amdgpu-waves-per-eu"="1,1" "amdgpu-flat-work-group-size"="64,64" }
