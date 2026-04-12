; RUN: llc -mtriple=hexagon -verify-machineinstrs < %s | FileCheck %s --check-prefix=ASM
; RUN: llc -mtriple=hexagon -verify-machineinstrs -stop-after=finalize-isel < %s \
; RUN:   | FileCheck %s --check-prefix=ISEL
; RUN: llc -mtriple=hexagon -verify-machineinstrs -stop-after=kcfi < %s \
; RUN:   | FileCheck %s --check-prefix=KCFI

; Verify KCFI type hash is emitted before the function.
; ASM:       .word 12345678
; ASM-LABEL: f1:

define void @f1(ptr noundef %x) !kcfi_type !1 {
; ASM:       r{{[0-9]+}} = memw(r0+#-4)
; ASM:       r{{[0-9]+}} = ##12345678
; ASM:       p0 = cmp.eq(r{{[0-9]+}},r{{[0-9]+}})
; ASM-NEXT:  if (p0.new) jump:t
; ASM:       r{{[0-9]+}}:{{[0-9]+}} = memd(##3134984174)

; After ISel, the call should carry a cfi-type.
; ISEL-LABEL: name: f1
; ISEL:       J2_callr %0,{{.*}} cfi-type 12345678

; After the KCFI pass, the check and call are bundled.
; KCFI-LABEL: name: f1
; KCFI:       BUNDLE{{.*}} {
; KCFI-NEXT:    KCFI_CHECK $r0, 12345678
; KCFI-NEXT:    J2_callr killed $r0
; KCFI-NEXT:  }

  call void %x() [ "kcfi"(i32 12345678) ]
  ret void
}

; Test with a second call using a different type hash.
define void @f2(ptr noundef %x) !kcfi_type !2 {
; ASM-LABEL: f2:
; ASM:       r{{[0-9]+}} = memw(r0+#-4)
; ASM:       r{{[0-9]+}} = ##1234
; ASM:       p0 = cmp.eq(r{{[0-9]+}},r{{[0-9]+}})
; ASM-NEXT:  if (p0.new) jump:t
; ASM:       r{{[0-9]+}}:{{[0-9]+}} = memd(##3134984174)

  call void %x() [ "kcfi"(i32 1234) ]
  ret void
}

; Test with patchable-function-entry (nops placed after the label,
; so the KCFI offset is still -4).
define void @f3(ptr noundef %x) #0 {
; ASM-LABEL: f3:
; ASM:       nop
; ASM:       nop
; ASM:       r{{[0-9]+}} = memw(r0+#-4)
; ASM:       r{{[0-9]+}} = ##12345678
; ASM:       p0 = cmp.eq(r{{[0-9]+}},r{{[0-9]+}})
; ASM-NEXT:  if (p0.new) jump:t
; ASM:       r{{[0-9]+}}:{{[0-9]+}} = memd(##3134984174)

  call void %x() [ "kcfi"(i32 12345678) ]
  ret void
}

; Verify the .kcfi_traps section is emitted.
; ASM:       .section .kcfi_traps

attributes #0 = { "patchable-function-entry"="2" }

!llvm.module.flags = !{!0}
!0 = !{i32 4, !"kcfi", i32 1}
!1 = !{i32 12345678}
!2 = !{i32 1234}
