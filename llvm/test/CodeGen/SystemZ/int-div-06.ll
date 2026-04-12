; Test that divisions by constants are implemented as multiplications.
;
; RUN: llc < %s -mtriple=s390x-linux-gnu -asm-verbose=0 | FileCheck %s

; Check signed 32-bit division.
define i32 @f1(i32 %a) {
; CHECK-LABEL: f1:
; CHECK: lgfr [[REG:%r[0-5]]], %r2
; CHECK: sra %r2, 31
; CHECK: msgfi [[REG]], 502748801
; CHECK: srag [[REG]], [[REG]], 46
; CHECK: sr [[REG]], %r2
; CHECK: lr %r2, [[REG]]
; CHECK: br %r14
  %b = sdiv i32 %a, 139968
  ret i32 %b
}

; Check unsigned 32-bit division.
define i32 @f2(i32 %a) {
; CHECK-LABEL: f2:
; CHECK: llgfr [[REG:%r[0-5]]], %r2
; CHECK: msgfi [[REG]], 502748801
; CHECK: srlg %r2, [[REG]], 46
; CHECK: br %r14
  %b = udiv i32 %a, 139968
  ret i32 %b
}

; Check signed 64-bit division.
define i64 @f3(i64 %dummy, i64 %a) {
; CHECK-LABEL: f3:
; CHECK-DAG: llihf [[CONST:%r[0-5]]], 1005497601
; CHECK-DAG: oilf [[CONST]], 4251762321
; CHECK-DAG: srag [[SIGN:%r[0-5]]], %r3, 63
; CHECK-DAG: lgr [[TMP:%r[0-5]]], [[SIGN]]
; CHECK-DAG: ngr [[TMP]], [[CONST]]
; CHECK-DAG: mlgr %r2, [[CONST]]
; CHECK: sgr %r2, [[TMP]]
; CHECK: srag %r2, %r2, 15
; CHECK: sgr %r2, [[SIGN]]
; CHECK: br %r14
  %b = sdiv i64 %a, 139968
  ret i64 %b
}

; Check unsigned 64-bit division.
define i64 @f4(i64 %dummy, i64 %a) {
; CHECK-LABEL: f4:
; CHECK: llihf [[CONST:%r[0-5]]], 1005497601
; CHECK: oilf [[CONST]], 4251762321
; CHECK: mlgr %r2, [[CONST]]
; CHECK: srlg %r2, %r2, 15
; CHECK: br %r14
  %b = udiv i64 %a, 139968
  ret i64 %b
}
