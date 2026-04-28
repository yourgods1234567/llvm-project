# RUN: llvm-mc %s -triple=riscv32 -mattr=+experimental-xetestmatrix -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM %s
# RUN: llvm-mc -filetype=obj -triple riscv32 -mattr=+experimental-xetestmatrix < %s \
# RUN:     | llvm-objdump --mattr=+experimental-xetestmatrix -M no-aliases -d -r - \
# RUN:     | FileCheck -check-prefixes=CHECK-OBJ %s
# RUN: llvm-mc %s -triple=riscv64 -mattr=+experimental-xetestmatrix -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM %s
# RUN: llvm-mc -filetype=obj -triple riscv64 -mattr=+experimental-xetestmatrix < %s \
# RUN:     | llvm-objdump --mattr=+experimental-xetestmatrix -M no-aliases -d -r - \
# RUN:     | FileCheck -check-prefixes=CHECK-OBJ %s

# CHECK-ASM: msettilemi	100
# CHECK-ASM: encoding: [0x2b,0x00,0x32,0x00]
# CHECK-OBJ: msettilemi	0x64
msettilemi	100

# CHECK-ASM: msettileki	50
# CHECK-ASM: encoding: [0x2b,0x00,0x19,0x10]
# CHECK-OBJ: msettileki	0x32
msettileki	50

# CHECK-ASM: msettileni	200
# CHECK-ASM: encoding: [0x2b,0x00,0x64,0x20]
# CHECK-OBJ: msettileni	0xc8
msettileni	200

# CHECK-ASM: msettilem	a0
# CHECK-ASM: encoding: [0x2b,0x00,0x50,0x02]
# CHECK-OBJ: msettilem	a0
msettilem	a0

# CHECK-ASM: msettilek	a0
# CHECK-ASM: encoding: [0x2b,0x00,0x50,0x12]
# CHECK-OBJ: msettilek	a0
msettilek	a0

# CHECK-ASM: msettilen	a0
# CHECK-ASM: encoding: [0x2b,0x00,0x50,0x22]
# CHECK-OBJ: msettilen	a0
msettilen	a0

# CHECK-ASM: mrelease
# CHECK-ASM: encoding: [0x2b,0x00,0x00,0x30]
# CHECK-OBJ: mrelease
mrelease

# CHECK-ASM: mlae8	tr0, (a0), a1
# CHECK-ASM: encoding: [0x2b,0x00,0xb5,0x04]
# CHECK-OBJ: mlae8	tr0, (a0), a1
mlae8	tr0, (a0), a1

# CHECK-ASM: mlae16	tr0, (a0), a1
# CHECK-ASM: encoding: [0x2b,0x04,0xb5,0x04]
# CHECK-OBJ: mlae16	tr0, (a0), a1
mlae16	tr0, (a0), a1

# CHECK-ASM: mlae32	tr0, (a0), a1
# CHECK-ASM: encoding: [0x2b,0x08,0xb5,0x04]
# CHECK-OBJ: mlae32	tr0, (a0), a1
mlae32	tr0, (a0), a1

# CHECK-ASM: mlae64	tr0, (a0), a1
# CHECK-ASM: encoding: [0x2b,0x0c,0xb5,0x04]
# CHECK-OBJ: mlae64	tr0, (a0), a1
mlae64	tr0, (a0), a1

# CHECK-ASM: mlbe8	tr1, (a0), a1
# CHECK-ASM: encoding: [0xab,0x00,0xb5,0x14]
# CHECK-OBJ: mlbe8	tr1, (a0), a1
mlbe8	tr1, (a0), a1

# CHECK-ASM: mlbe16	tr1, (a0), a1
# CHECK-ASM: encoding: [0xab,0x04,0xb5,0x14]
# CHECK-OBJ: mlbe16	tr1, (a0), a1
mlbe16	tr1, (a0), a1

# CHECK-ASM: mlbe32	tr1, (a0), a1
# CHECK-ASM: encoding: [0xab,0x08,0xb5,0x14]
# CHECK-OBJ: mlbe32	tr1, (a0), a1
mlbe32	tr1, (a0), a1

# CHECK-ASM: mlbe64	tr1, (a0), a1
# CHECK-ASM: encoding: [0xab,0x0c,0xb5,0x14]
# CHECK-OBJ: mlbe64	tr1, (a0), a1
mlbe64	tr1, (a0), a1

# CHECK-ASM: mlce8	acc0, (a0), a1
# CHECK-ASM: encoding: [0x2b,0x02,0xb5,0x24]
# CHECK-OBJ: mlce8	acc0, (a0), a1
mlce8	acc0, (a0), a1

# CHECK-ASM: mlce16	acc0, (a0), a1
# CHECK-ASM: encoding: [0x2b,0x06,0xb5,0x24]
# CHECK-OBJ: mlce16	acc0, (a0), a1
mlce16	acc0, (a0), a1

# CHECK-ASM: mlce32	acc0, (a0), a1
# CHECK-ASM: encoding: [0x2b,0x0a,0xb5,0x24]
# CHECK-OBJ: mlce32	acc0, (a0), a1
mlce32	acc0, (a0), a1

# CHECK-ASM: mlce64	acc0, (a0), a1
# CHECK-ASM: encoding: [0x2b,0x0e,0xb5,0x24]
# CHECK-OBJ: mlce64	acc0, (a0), a1
mlce64	acc0, (a0), a1

# CHECK-ASM: msae8	tr1, (a0), a2
# CHECK-ASM: encoding: [0xab,0x00,0xc5,0x06]
# CHECK-OBJ: msae8	tr1, (a0), a2
msae8	tr1, (a0), a2

# CHECK-ASM: msae16	tr1, (a0), a2
# CHECK-ASM: encoding: [0xab,0x04,0xc5,0x06]
# CHECK-OBJ: msae16	tr1, (a0), a2
msae16	tr1, (a0), a2

# CHECK-ASM: msae32	tr1, (a0), a2
# CHECK-ASM: encoding: [0xab,0x08,0xc5,0x06]
# CHECK-OBJ: msae32	tr1, (a0), a2
msae32	tr1, (a0), a2

# CHECK-ASM: msae64	tr1, (a0), a2
# CHECK-ASM: encoding: [0xab,0x0c,0xc5,0x06]
# CHECK-OBJ: msae64	tr1, (a0), a2
msae64	tr1, (a0), a2

# CHECK-ASM: msbe8	tr2, (a0), a2
# CHECK-ASM: encoding: [0x2b,0x01,0xc5,0x16]
# CHECK-OBJ: msbe8	tr2, (a0), a2
msbe8	tr2, (a0), a2

# CHECK-ASM: msbe16	tr2, (a0), a2
# CHECK-ASM: encoding: [0x2b,0x05,0xc5,0x16]
# CHECK-OBJ: msbe16	tr2, (a0), a2
msbe16	tr2, (a0), a2

# CHECK-ASM: msbe32	tr2, (a0), a2
# CHECK-ASM: encoding: [0x2b,0x09,0xc5,0x16]
# CHECK-OBJ: msbe32	tr2, (a0), a2
msbe32	tr2, (a0), a2

# CHECK-ASM: msbe64	tr2, (a0), a2
# CHECK-ASM: encoding: [0x2b,0x0d,0xc5,0x16]
# CHECK-OBJ: msbe64	tr2, (a0), a2
msbe64	tr2, (a0), a2

# CHECK-ASM: msce8	acc3, (a0), a2
# CHECK-ASM: encoding: [0xab,0x03,0xc5,0x26]
# CHECK-OBJ: msce8	acc3, (a0), a2
msce8	acc3, (a0), a2

# CHECK-ASM: msce16	acc3, (a0), a2
# CHECK-ASM: encoding: [0xab,0x07,0xc5,0x26]
# CHECK-OBJ: msce16	acc3, (a0), a2
msce16	acc3, (a0), a2

# CHECK-ASM: msce32	acc3, (a0), a2
# CHECK-ASM: encoding: [0xab,0x0b,0xc5,0x26]
# CHECK-OBJ: msce32	acc3, (a0), a2
msce32	acc3, (a0), a2

# CHECK-ASM: msce64	acc3, (a0), a2
# CHECK-ASM: encoding: [0xab,0x0f,0xc5,0x26]
# CHECK-OBJ: msce64	acc3, (a0), a2
msce64	acc3, (a0), a2

# CHECK-ASM: mlate8	tr3, (a1), zero
# CHECK-ASM: encoding: [0xab,0x81,0x05,0x34]
# CHECK-OBJ: mlate8	tr3, (a1), zero
mlate8	tr3, (a1), zero

# CHECK-ASM: mlate16	tr3, (a1), zero
# CHECK-ASM: encoding: [0xab,0x85,0x05,0x34]
# CHECK-OBJ: mlate16	tr3, (a1), zero
mlate16	tr3, (a1), zero

# CHECK-ASM: mlate32	tr3, (a1), zero
# CHECK-ASM: encoding: [0xab,0x89,0x05,0x34]
# CHECK-OBJ: mlate32	tr3, (a1), zero
mlate32	tr3, (a1), zero

# CHECK-ASM: mlate64	tr3, (a1), zero
# CHECK-ASM: encoding: [0xab,0x8d,0x05,0x34]
# CHECK-OBJ: mlate64	tr3, (a1), zero
mlate64	tr3, (a1), zero

# CHECK-ASM: mlbte8	tr0, (a1), zero
# CHECK-ASM: encoding: [0x2b,0x80,0x05,0x44]
# CHECK-OBJ: mlbte8	tr0, (a1), zero
mlbte8	tr0, (a1), zero

# CHECK-ASM: mlbte16	tr0, (a1), zero
# CHECK-ASM: encoding: [0x2b,0x84,0x05,0x44]
# CHECK-OBJ: mlbte16	tr0, (a1), zero
mlbte16	tr0, (a1), zero

# CHECK-ASM: mlbte32	tr0, (a1), zero
# CHECK-ASM: encoding: [0x2b,0x88,0x05,0x44]
# CHECK-OBJ: mlbte32	tr0, (a1), zero
mlbte32	tr0, (a1), zero

# CHECK-ASM: mlbte64	tr0, (a1), zero
# CHECK-ASM: encoding: [0x2b,0x8c,0x05,0x44]
# CHECK-OBJ: mlbte64	tr0, (a1), zero
mlbte64	tr0, (a1), zero

# CHECK-ASM: mlcte8	acc1, (a1), zero
# CHECK-ASM: encoding: [0xab,0x82,0x05,0x54]
# CHECK-OBJ: mlcte8	acc1, (a1), zero
mlcte8	acc1, (a1), zero

# CHECK-ASM: mlcte16	acc1, (a1), zero
# CHECK-ASM: encoding: [0xab,0x86,0x05,0x54]
# CHECK-OBJ: mlcte16	acc1, (a1), zero
mlcte16	acc1, (a1), zero

# CHECK-ASM: mlcte32	acc1, (a1), zero
# CHECK-ASM: encoding: [0xab,0x8a,0x05,0x54]
# CHECK-OBJ: mlcte32	acc1, (a1), zero
mlcte32	acc1, (a1), zero

# CHECK-ASM: mlcte64	acc1, (a1), zero
# CHECK-ASM: encoding: [0xab,0x8e,0x05,0x54]
# CHECK-OBJ: mlcte64	acc1, (a1), zero
mlcte64	acc1, (a1), zero

# CHECK-ASM: msate8	tr2, (a0), a3
# CHECK-ASM: encoding: [0x2b,0x01,0xd5,0x36]
# CHECK-OBJ: msate8	tr2, (a0), a3
msate8	tr2, (a0), a3

# CHECK-ASM: msate16	tr2, (a0), a3
# CHECK-ASM: encoding: [0x2b,0x05,0xd5,0x36]
# CHECK-OBJ: msate16	tr2, (a0), a3
msate16	tr2, (a0), a3

# CHECK-ASM: msate32	tr2, (a0), a3
# CHECK-ASM: encoding: [0x2b,0x09,0xd5,0x36]
# CHECK-OBJ: msate32	tr2, (a0), a3
msate32	tr2, (a0), a3

# CHECK-ASM: msate64	tr2, (a0), a3
# CHECK-ASM: encoding: [0x2b,0x0d,0xd5,0x36]
# CHECK-OBJ: msate64	tr2, (a0), a3
msate64	tr2, (a0), a3

# CHECK-ASM: msbte8	tr1, (a0), a3
# CHECK-ASM: encoding: [0xab,0x00,0xd5,0x46]
# CHECK-OBJ: msbte8	tr1, (a0), a3
msbte8	tr1, (a0), a3

# CHECK-ASM: msbte16	tr1, (a0), a3
# CHECK-ASM: encoding: [0xab,0x04,0xd5,0x46]
# CHECK-OBJ: msbte16	tr1, (a0), a3
msbte16	tr1, (a0), a3

# CHECK-ASM: msbte32	tr1, (a0), a3
# CHECK-ASM: encoding: [0xab,0x08,0xd5,0x46]
# CHECK-OBJ: msbte32	tr1, (a0), a3
msbte32	tr1, (a0), a3

# CHECK-ASM: msbte64	tr1, (a0), a3
# CHECK-ASM: encoding: [0xab,0x0c,0xd5,0x46]
# CHECK-OBJ: msbte64	tr1, (a0), a3
msbte64	tr1, (a0), a3

# CHECK-ASM: mscte8	acc2, (a0), a3
# CHECK-ASM: encoding: [0x2b,0x03,0xd5,0x56]
# CHECK-OBJ: mscte8	acc2, (a0), a3
mscte8	acc2, (a0), a3

# CHECK-ASM: mscte16	acc2, (a0), a3
# CHECK-ASM: encoding: [0x2b,0x07,0xd5,0x56]
# CHECK-OBJ: mscte16	acc2, (a0), a3
mscte16	acc2, (a0), a3

# CHECK-ASM: mscte32	acc2, (a0), a3
# CHECK-ASM: encoding: [0x2b,0x0b,0xd5,0x56]
# CHECK-OBJ: mscte32	acc2, (a0), a3
mscte32	acc2, (a0), a3

# CHECK-ASM: mscte64	acc2, (a0), a3
# CHECK-ASM: encoding: [0x2b,0x0f,0xd5,0x56]
# CHECK-OBJ: mscte64	acc2, (a0), a3
mscte64	acc2, (a0), a3

# CHECK-ASM: mlme8	tr0, (a1)
# CHECK-ASM: encoding: [0x2b,0x80,0x05,0x64]
# CHECK-OBJ: mlme8	tr0, (a1)
mlme8	tr0, (a1)

# CHECK-ASM: msme8	acc0, (a2)
# CHECK-ASM: encoding: [0x2b,0x02,0x06,0x66]
# CHECK-OBJ: msme8	acc0, (a2)
msme8	acc0, (a2)

# CHECK-ASM: mlme16	tr0, (a1)
# CHECK-ASM: encoding: [0x2b,0x84,0x05,0x64]
# CHECK-OBJ: mlme16	tr0, (a1)
mlme16	tr0, (a1)

# CHECK-ASM: msme16	acc0, (a2)
# CHECK-ASM: encoding: [0x2b,0x06,0x06,0x66]
# CHECK-OBJ: msme16	acc0, (a2)
msme16	acc0, (a2)

# CHECK-ASM: mlme32	tr0, (a1)
# CHECK-ASM: encoding: [0x2b,0x88,0x05,0x64]
# CHECK-OBJ: mlme32	tr0, (a1)
mlme32	tr0, (a1)

# CHECK-ASM: msme32	acc0, (a2)
# CHECK-ASM: encoding: [0x2b,0x0a,0x06,0x66]
# CHECK-OBJ: msme32	acc0, (a2)
msme32	acc0, (a2)

# CHECK-ASM: mlme64	tr0, (a1)
# CHECK-ASM: encoding: [0x2b,0x8c,0x05,0x64]
# CHECK-OBJ: mlme64	tr0, (a1)
mlme64	tr0, (a1)

# CHECK-ASM: msme64	acc0, (a2)
# CHECK-ASM: encoding: [0x2b,0x0e,0x06,0x66]
# CHECK-OBJ: msme64	acc0, (a2)
msme64	acc0, (a2)

# CHECK-ASM: mfmacc.h	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x86,0x24,0x08]
# CHECK-OBJ: mfmacc.h	acc0, tr1, tr2
mfmacc.h	acc0, tr1, tr2

# CHECK-ASM: mfmacc.s	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x8a,0x28,0x08]
# CHECK-OBJ: mfmacc.s	acc0, tr1, tr2
mfmacc.s	acc0, tr1, tr2

# CHECK-ASM: mfmacc.d	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x8e,0x2c,0x08]
# CHECK-OBJ: mfmacc.d	acc0, tr1, tr2
mfmacc.d	acc0, tr1, tr2

# CHECK-ASM: mfmacc.h.e4	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x86,0x20,0x09]
# CHECK-OBJ: mfmacc.h.e4	acc0, tr1, tr2
mfmacc.h.e4	acc0, tr1, tr2

# CHECK-ASM: mfmacc.h.e5	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x86,0x20,0x08]
# CHECK-OBJ: mfmacc.h.e5	acc0, tr1, tr2
mfmacc.h.e5	acc0, tr1, tr2

# CHECK-ASM: mfmacc.bf16.e4	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x86,0x20,0x0b]
# CHECK-OBJ: mfmacc.bf16.e4	acc0, tr1, tr2
mfmacc.bf16.e4	acc0, tr1, tr2

# CHECK-ASM: mfmacc.bf16.e5	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x86,0x20,0x0a]
# CHECK-OBJ: mfmacc.bf16.e5	acc0, tr1, tr2
mfmacc.bf16.e5	acc0, tr1, tr2

# CHECK-ASM: mfmacc.s.h	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x8a,0x24,0x08]
# CHECK-OBJ: mfmacc.s.h	acc0, tr1, tr2
mfmacc.s.h	acc0, tr1, tr2

# CHECK-ASM: mfmacc.s.bf16	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x8a,0x24,0x0a]
# CHECK-OBJ: mfmacc.s.bf16	acc0, tr1, tr2
mfmacc.s.bf16	acc0, tr1, tr2

# CHECK-ASM: mfmacc.d.s	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x8e,0x28,0x08]
# CHECK-OBJ: mfmacc.d.s	acc0, tr1, tr2
mfmacc.d.s	acc0, tr1, tr2

# CHECK-ASM: mfmacc.s.e4	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x8a,0x20,0x09]
# CHECK-OBJ: mfmacc.s.e4	acc0, tr1, tr2
mfmacc.s.e4	acc0, tr1, tr2

# CHECK-ASM: mfmacc.s.e5	acc0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x8a,0x20,0x08]
# CHECK-OBJ: mfmacc.s.e5	acc0, tr1, tr2
mfmacc.s.e5	acc0, tr1, tr2

# CHECK-ASM: mmacc.w.b	acc3, tr1, tr2
# CHECK-ASM: encoding: [0xab,0x8b,0x20,0x18]
# CHECK-OBJ: mmacc.w.b	acc3, tr1, tr2
mmacc.w.b	acc3, tr1, tr2

# CHECK-ASM: mmaccu.w.b	acc3, tr1, tr2
# CHECK-ASM: encoding: [0xab,0x8b,0x20,0x1a]
# CHECK-OBJ: mmaccu.w.b	acc3, tr1, tr2
mmaccu.w.b	acc3, tr1, tr2

# CHECK-ASM: mmaccsu.w.b	acc3, tr1, tr2
# CHECK-ASM: encoding: [0xab,0x8b,0x20,0x19]
# CHECK-OBJ: mmaccsu.w.b	acc3, tr1, tr2
mmaccsu.w.b	acc3, tr1, tr2

# CHECK-ASM: mmaccus.w.b	acc3, tr1, tr2
# CHECK-ASM: encoding: [0xab,0x8b,0x20,0x1b]
# CHECK-OBJ: mmaccus.w.b	acc3, tr1, tr2
mmaccus.w.b	acc3, tr1, tr2

# CHECK-ASM: mzero	tr0
# CHECK-ASM: encoding: [0x2b,0x00,0x00,0x0c]
# CHECK-OBJ: mzero	tr0
mzero	tr0

# CHECK-ASM: mzero2r	tr1
# CHECK-ASM: encoding: [0xab,0x00,0x80,0x0c]
# CHECK-OBJ: mzero2r	tr1
mzero2r	tr1

# CHECK-ASM: mzero4r	tr2
# CHECK-ASM: encoding: [0x2b,0x01,0x80,0x0d]
# CHECK-OBJ: mzero4r	tr2
mzero4r	tr2

# CHECK-ASM: mzero8r	tr3
# CHECK-ASM: encoding: [0xab,0x01,0x80,0x0f]
# CHECK-OBJ: mzero8r	tr3
mzero8r	tr3

# CHECK-ASM: mmov.mm	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x80,0x80,0x1f]
# CHECK-OBJ: mmov.mm	tr0, tr1
mmov.mm	tr0, tr1

# CHECK-ASM: mmovb.x.m	a0, tr0, a1
# CHECK-ASM: encoding: [0x2b,0x85,0x05,0x2c]
# CHECK-OBJ: mmovb.x.m	a0, tr0, a1
mmovb.x.m	a0, tr0, a1

# CHECK-ASM: mmovb.m.x	tr1, a2, a3
# CHECK-ASM: encoding: [0xab,0x80,0xc6,0x3e]
# CHECK-OBJ: mmovb.m.x	tr1, a2, a3
mmovb.m.x	tr1, a2, a3

# CHECK-ASM: mmovh.x.m	a0, tr0, a1
# CHECK-ASM: encoding: [0x2b,0x85,0x85,0x2c]
# CHECK-OBJ: mmovh.x.m	a0, tr0, a1
mmovh.x.m	a0, tr0, a1

# CHECK-ASM: mmovh.m.x	tr1, a2, a3
# CHECK-ASM: encoding: [0xab,0x84,0xc6,0x3e]
# CHECK-OBJ: mmovh.m.x	tr1, a2, a3
mmovh.m.x	tr1, a2, a3

# CHECK-ASM: mmovw.x.m	a0, tr0, a1
# CHECK-ASM: encoding: [0x2b,0x85,0x05,0x2d]
# CHECK-OBJ: mmovw.x.m	a0, tr0, a1
mmovw.x.m	a0, tr0, a1

# CHECK-ASM: mmovw.m.x	tr1, a2, a3
# CHECK-ASM: encoding: [0xab,0x88,0xc6,0x3e]
# CHECK-OBJ: mmovw.m.x	tr1, a2, a3
mmovw.m.x	tr1, a2, a3

# CHECK-ASM: mmovd.x.m	a0, tr0, a1
# CHECK-ASM: encoding: [0x2b,0x85,0x85,0x2d]
# CHECK-OBJ: mmovd.x.m	a0, tr0, a1
mmovd.x.m	a0, tr0, a1

# CHECK-ASM: mmovd.m.x	tr1, a2, a3
# CHECK-ASM: encoding: [0xab,0x8c,0xc6,0x3e]
# CHECK-OBJ: mmovd.m.x	tr1, a2, a3
mmovd.m.x	tr1, a2, a3

# CHECK-ASM: mbce8	tr2, tr3
# CHECK-ASM: encoding: [0x2b,0x81,0x01,0x4c]
# CHECK-OBJ: mbce8	tr2, tr3
mbce8	tr2, tr3

# CHECK-ASM: mbce16	tr2, tr3
# CHECK-ASM: encoding: [0x2b,0x81,0x81,0x4c]
# CHECK-OBJ: mbce16	tr2, tr3
mbce16	tr2, tr3

# CHECK-ASM: mbce32	tr2, tr3
# CHECK-ASM: encoding: [0x2b,0x81,0x01,0x4d]
# CHECK-OBJ: mbce32	tr2, tr3
mbce32	tr2, tr3

# CHECK-ASM: mbce64	tr2, tr3
# CHECK-ASM: encoding: [0x2b,0x81,0x81,0x4d]
# CHECK-OBJ: mbce64	tr2, tr3
mbce64	tr2, tr3

# CHECK-ASM: mcbce8.mv.i	tr0, tr1[2]
# CHECK-ASM: encoding: [0x2b,0x80,0x00,0x6d]
# CHECK-OBJ: mcbce8.mv.i	tr0, tr1[0x2]
mcbce8.mv.i	tr0, tr1[2]

# CHECK-ASM: mcbce16.mv.i	tr0, tr1[2]
# CHECK-ASM: encoding: [0x2b,0x84,0x00,0x6d]
# CHECK-OBJ: mcbce16.mv.i	tr0, tr1[0x2]
mcbce16.mv.i	tr0, tr1[2]

# CHECK-ASM: mcbce32.mv.i	tr0, tr1[2]
# CHECK-ASM: encoding: [0x2b,0x88,0x00,0x6d]
# CHECK-OBJ: mcbce32.mv.i	tr0, tr1[0x2]
mcbce32.mv.i	tr0, tr1[2]

# CHECK-ASM: mcbce64.mv.i	tr0, tr1[2]
# CHECK-ASM: encoding: [0x2b,0x8c,0x00,0x6d]
# CHECK-OBJ: mcbce64.mv.i	tr0, tr1[0x2]
mcbce64.mv.i	tr0, tr1[2]

# CHECK-ASM: mrbc.mv.i	tr3, tr0[1]
# CHECK-ASM: encoding: [0xab,0x01,0x80,0x5c]
# CHECK-OBJ: mrbc.mv.i	tr3, tr0[0x1]
mrbc.mv.i	tr3, tr0[1]

# CHECK-ASM: mpack.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x80,0xa0,0x8f]
# CHECK-OBJ: mpack.mm	tr0, tr1, tr2
mpack.mm	tr0, tr1, tr2

# CHECK-ASM: mpackhl.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x80,0xa0,0x9f]
# CHECK-OBJ: mpackhl.mm	tr0, tr1, tr2
mpackhl.mm	tr0, tr1, tr2

# CHECK-ASM: mpackhh.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x80,0xa0,0xaf]
# CHECK-OBJ: mpackhh.mm	tr0, tr1, tr2
mpackhh.mm	tr0, tr1, tr2

# CHECK-ASM: mrslidedown	tr0, tr1, 2
# CHECK-ASM: encoding: [0x2b,0x80,0x00,0xbd]
# CHECK-OBJ: mrslidedown	tr0, tr1, 0x2
mrslidedown	tr0, tr1, 2

# CHECK-ASM: mrslideup	tr0, tr1, 2
# CHECK-ASM: encoding: [0x2b,0x80,0x00,0xcd]
# CHECK-OBJ: mrslideup	tr0, tr1, 0x2
mrslideup	tr0, tr1, 2

# CHECK-ASM: mcslidedown.b	tr0, tr1, 2
# CHECK-ASM: encoding: [0x2b,0x80,0x00,0xdd]
# CHECK-OBJ: mcslidedown.b	tr0, tr1, 0x2
mcslidedown.b	tr0, tr1, 2

# CHECK-ASM: mcslideup.b	tr3, tr0, 0
# CHECK-ASM: encoding: [0xab,0x01,0x00,0xec]
# CHECK-OBJ: mcslideup.b	tr3, tr0, 0x0
mcslideup.b	tr3, tr0, 0

# CHECK-ASM: mcslidedown.h	tr0, tr1, 2
# CHECK-ASM: encoding: [0x2b,0x84,0x04,0xdd]
# CHECK-OBJ: mcslidedown.h	tr0, tr1, 0x2
mcslidedown.h	tr0, tr1, 2

# CHECK-ASM: mcslideup.h	tr3, tr0, 0
# CHECK-ASM: encoding: [0xab,0x05,0x04,0xec]
# CHECK-OBJ: mcslideup.h	tr3, tr0, 0x0
mcslideup.h	tr3, tr0, 0

# CHECK-ASM: mcslidedown.w	tr0, tr1, 2
# CHECK-ASM: encoding: [0x2b,0x88,0x08,0xdd]
# CHECK-OBJ: mcslidedown.w	tr0, tr1, 0x2
mcslidedown.w	tr0, tr1, 2

# CHECK-ASM: mcslideup.w	tr3, tr0, 0
# CHECK-ASM: encoding: [0xab,0x09,0x08,0xec]
# CHECK-OBJ: mcslideup.w	tr3, tr0, 0x0
mcslideup.w	tr3, tr0, 0

# CHECK-ASM: mcslidedown.d	tr0, tr1, 2
# CHECK-ASM: encoding: [0x2b,0x8c,0x0c,0xdd]
# CHECK-OBJ: mcslidedown.d	tr0, tr1, 0x2
mcslidedown.d	tr0, tr1, 2

# CHECK-ASM: mcslideup.d	tr3, tr0, 0
# CHECK-ASM: encoding: [0xab,0x0d,0x0c,0xec]
# CHECK-OBJ: mcslideup.d	tr3, tr0, 0x0
mcslideup.d	tr3, tr0, 0

# CHECK-ASM: mfcvtl.h.e4	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x00,0x00]
# CHECK-OBJ: mfcvtl.h.e4	tr0, tr1
mfcvtl.h.e4	tr0, tr1

# CHECK-ASM: mfcvth.h.e4	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x80,0x00]
# CHECK-OBJ: mfcvth.h.e4	tr0, tr1
mfcvth.h.e4	tr0, tr1

# CHECK-ASM: mfcvtl.h.e5	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x00,0x01]
# CHECK-OBJ: mfcvtl.h.e5	tr0, tr1
mfcvtl.h.e5	tr0, tr1

# CHECK-ASM: mfcvth.h.e5	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x80,0x01]
# CHECK-OBJ: mfcvth.h.e5	tr0, tr1
mfcvth.h.e5	tr0, tr1

# CHECK-ASM: mfcvtl.s.h	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x04,0x02]
# CHECK-OBJ: mfcvtl.s.h	tr0, tr1
mfcvtl.s.h	tr0, tr1

# CHECK-ASM: mfcvth.s.h	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x84,0x02]
# CHECK-OBJ: mfcvth.s.h	tr0, tr1
mfcvth.s.h	tr0, tr1

# CHECK-ASM: mfcvtl.s.bf16	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x04,0x03]
# CHECK-OBJ: mfcvtl.s.bf16	tr0, tr1
mfcvtl.s.bf16	tr0, tr1

# CHECK-ASM: mfcvth.s.bf16	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x84,0x03]
# CHECK-OBJ: mfcvth.s.bf16	tr0, tr1
mfcvth.s.bf16	tr0, tr1

# CHECK-ASM: mfcvtl.d.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x9c,0x08,0x00]
# CHECK-OBJ: mfcvtl.d.s	tr0, tr1
mfcvtl.d.s	tr0, tr1

# CHECK-ASM: mfcvth.d.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x9c,0x88,0x00]
# CHECK-OBJ: mfcvth.d.s	tr0, tr1
mfcvth.d.s	tr0, tr1

# CHECK-ASM: mfcvtl.e4.h	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x04,0x01]
# CHECK-OBJ: mfcvtl.e4.h	tr0, tr1
mfcvtl.e4.h	tr0, tr1

# CHECK-ASM: mfcvth.e4.h	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x84,0x01]
# CHECK-OBJ: mfcvth.e4.h	tr0, tr1
mfcvth.e4.h	tr0, tr1

# CHECK-ASM: mfcvtl.e5.h	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x04,0x02]
# CHECK-OBJ: mfcvtl.e5.h	tr0, tr1
mfcvtl.e5.h	tr0, tr1

# CHECK-ASM: mfcvth.e5.h	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x84,0x02]
# CHECK-OBJ: mfcvth.e5.h	tr0, tr1
mfcvth.e5.h	tr0, tr1

# CHECK-ASM: mfcvtl.h.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x08,0x03]
# CHECK-OBJ: mfcvtl.h.s	tr0, tr1
mfcvtl.h.s	tr0, tr1

# CHECK-ASM: mfcvth.h.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x88,0x03]
# CHECK-OBJ: mfcvth.h.s	tr0, tr1
mfcvth.h.s	tr0, tr1

# CHECK-ASM: mfcvtl.bf16.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x08,0x00]
# CHECK-OBJ: mfcvtl.bf16.s	tr0, tr1
mfcvtl.bf16.s	tr0, tr1

# CHECK-ASM: mfcvth.bf16.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x88,0x00]
# CHECK-OBJ: mfcvth.bf16.s	tr0, tr1
mfcvth.bf16.s	tr0, tr1

# CHECK-ASM: mfcvtl.s.d	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x0c,0x01]
# CHECK-OBJ: mfcvtl.s.d	tr0, tr1
mfcvtl.s.d	tr0, tr1

# CHECK-ASM: mfcvth.s.d	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x8c,0x01]
# CHECK-OBJ: mfcvth.s.d	tr0, tr1
mfcvth.s.d	tr0, tr1

# CHECK-ASM: mfcvtl.e4.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x08,0x02]
# CHECK-OBJ: mfcvtl.e4.s	tr0, tr1
mfcvtl.e4.s	tr0, tr1

# CHECK-ASM: mfcvth.e4.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x88,0x02]
# CHECK-OBJ: mfcvth.e4.s	tr0, tr1
mfcvth.e4.s	tr0, tr1

# CHECK-ASM: mfcvtl.e5.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x08,0x03]
# CHECK-OBJ: mfcvtl.e5.s	tr0, tr1
mfcvtl.e5.s	tr0, tr1

# CHECK-ASM: mfcvth.e5.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x88,0x03]
# CHECK-OBJ: mfcvth.e5.s	tr0, tr1
mfcvth.e5.s	tr0, tr1

# CHECK-ASM: mufcvtl.h.b	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x00,0x10]
# CHECK-OBJ: mufcvtl.h.b	tr0, tr1
mufcvtl.h.b	tr0, tr1

# CHECK-ASM: mufcvth.h.b	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x80,0x10]
# CHECK-OBJ: mufcvth.h.b	tr0, tr1
mufcvth.h.b	tr0, tr1

# CHECK-ASM: msfcvtl.h.b	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x00,0x11]
# CHECK-OBJ: msfcvtl.h.b	tr0, tr1
msfcvtl.h.b	tr0, tr1

# CHECK-ASM: msfcvth.h.b	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x94,0x80,0x11]
# CHECK-OBJ: msfcvth.h.b	tr0, tr1
msfcvth.h.b	tr0, tr1

# CHECK-ASM: mufcvt.s.w	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x08,0x12]
# CHECK-OBJ: mufcvt.s.w	tr0, tr1
mufcvt.s.w	tr0, tr1

# CHECK-ASM: msfcvt.s.w	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x88,0x12]
# CHECK-OBJ: msfcvt.s.w	tr0, tr1
msfcvt.s.w	tr0, tr1

# CHECK-ASM: mfucvtl.b.h	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x04,0x13]
# CHECK-OBJ: mfucvtl.b.h	tr0, tr1
mfucvtl.b.h	tr0, tr1

# CHECK-ASM: mfucvth.b.h	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x84,0x13]
# CHECK-OBJ: mfucvth.b.h	tr0, tr1
mfucvth.b.h	tr0, tr1

# CHECK-ASM: mfscvtl.b.h	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x04,0x10]
# CHECK-OBJ: mfscvtl.b.h	tr0, tr1
mfscvtl.b.h	tr0, tr1

# CHECK-ASM: mfscvth.b.h	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x90,0x84,0x10]
# CHECK-OBJ: mfscvth.b.h	tr0, tr1
mfscvth.b.h	tr0, tr1

# CHECK-ASM: mfucvt.w.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x08,0x11]
# CHECK-OBJ: mfucvt.w.s	tr0, tr1
mfucvt.w.s	tr0, tr1

# CHECK-ASM: mfscvt.w.s	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x88,0x11]
# CHECK-OBJ: mfscvt.w.s	tr0, tr1
mfscvt.w.s	tr0, tr1

# CHECK-ASM: mn4clipl.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x90,0xa8,0x23]
# CHECK-OBJ: mn4clipl.w.mm	tr0, tr1, tr2
mn4clipl.w.mm	tr0, tr1, tr2

# CHECK-ASM: mn4cliph.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x90,0xa8,0x33]
# CHECK-OBJ: mn4cliph.w.mm	tr0, tr1, tr2
mn4cliph.w.mm	tr0, tr1, tr2

# CHECK-ASM: mn4cliplu.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x90,0xa8,0x43]
# CHECK-OBJ: mn4cliplu.w.mm	tr0, tr1, tr2
mn4cliplu.w.mm	tr0, tr1, tr2

# CHECK-ASM: mn4cliphu.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x90,0xa8,0x53]
# CHECK-OBJ: mn4cliphu.w.mm	tr0, tr1, tr2
mn4cliphu.w.mm	tr0, tr1, tr2

# CHECK-ASM: mn4clipl.w.mv.i	tr0, tr2, tr1[2]
# CHECK-ASM: encoding: [0x2b,0x90,0x28,0x21]
# CHECK-OBJ: mn4clipl.w.mv.i	tr0, tr2, tr1[0x2]
mn4clipl.w.mv.i	tr0, tr2, tr1[2]

# CHECK-ASM: mn4cliph.w.mv.i	tr0, tr2, tr1[2]
# CHECK-ASM: encoding: [0x2b,0x90,0x28,0x31]
# CHECK-OBJ: mn4cliph.w.mv.i	tr0, tr2, tr1[0x2]
mn4cliph.w.mv.i	tr0, tr2, tr1[2]

# CHECK-ASM: mn4cliplu.w.mv.i	tr0, tr2, tr1[2]
# CHECK-ASM: encoding: [0x2b,0x90,0x28,0x41]
# CHECK-OBJ: mn4cliplu.w.mv.i	tr0, tr2, tr1[0x2]
mn4cliplu.w.mv.i	tr0, tr2, tr1[2]

# CHECK-ASM: mn4cliphu.w.mv.i	tr0, tr2, tr1[2]
# CHECK-ASM: encoding: [0x2b,0x90,0x28,0x51]
# CHECK-OBJ: mn4cliphu.w.mv.i	tr0, tr2, tr1[0x2]
mn4cliphu.w.mv.i	tr0, tr2, tr1[2]

# CHECK-ASM: mscvtl.w.b.q	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x00,0x60]
# CHECK-OBJ: mscvtl.w.b.q	tr0, tr1
mscvtl.w.b.q	tr0, tr1

# CHECK-ASM: mscvth.w.b.q	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x80,0x60]
# CHECK-OBJ: mscvth.w.b.q	tr0, tr1
mscvth.w.b.q	tr0, tr1

# CHECK-ASM: mucvtl.w.b.q	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x00,0x61]
# CHECK-OBJ: mucvtl.w.b.q	tr0, tr1
mucvtl.w.b.q	tr0, tr1

# CHECK-ASM: mucvth.w.b.q	tr0, tr1
# CHECK-ASM: encoding: [0x2b,0x98,0x80,0x61]
# CHECK-OBJ: mucvth.w.b.q	tr0, tr1
mucvth.w.b.q	tr0, tr1

# CHECK-ASM: madd.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x07]
# CHECK-OBJ: madd.w.mm	tr0, tr1, tr2
madd.w.mm	tr0, tr1, tr2

# CHECK-ASM: madd.w.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x05]
# CHECK-OBJ: madd.w.mv.i	tr0, tr2, tr1[0x3]
madd.w.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: msub.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x17]
# CHECK-OBJ: msub.w.mm	tr0, tr1, tr2
msub.w.mm	tr0, tr1, tr2

# CHECK-ASM: msub.w.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x15]
# CHECK-OBJ: msub.w.mv.i	tr0, tr2, tr1[0x3]
msub.w.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mmul.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x27]
# CHECK-OBJ: mmul.w.mm	tr0, tr1, tr2
mmul.w.mm	tr0, tr1, tr2

# CHECK-ASM: mmul.w.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x25]
# CHECK-OBJ: mmul.w.mv.i	tr0, tr2, tr1[0x3]
mmul.w.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mmulh.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x37]
# CHECK-OBJ: mmulh.w.mm	tr0, tr1, tr2
mmulh.w.mm	tr0, tr1, tr2

# CHECK-ASM: mmulh.w.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x35]
# CHECK-OBJ: mmulh.w.mv.i	tr0, tr2, tr1[0x3]
mmulh.w.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mmax.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x47]
# CHECK-OBJ: mmax.w.mm	tr0, tr1, tr2
mmax.w.mm	tr0, tr1, tr2

# CHECK-ASM: mmax.w.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x45]
# CHECK-OBJ: mmax.w.mv.i	tr0, tr2, tr1[0x3]
mmax.w.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mumax.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x57]
# CHECK-OBJ: mumax.w.mm	tr0, tr1, tr2
mumax.w.mm	tr0, tr1, tr2

# CHECK-ASM: mumax.w.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x55]
# CHECK-OBJ: mumax.w.mv.i	tr0, tr2, tr1[0x3]
mumax.w.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mmin.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x67]
# CHECK-OBJ: mmin.w.mm	tr0, tr1, tr2
mmin.w.mm	tr0, tr1, tr2

# CHECK-ASM: mmin.w.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x65]
# CHECK-OBJ: mmin.w.mv.i	tr0, tr2, tr1[0x3]
mmin.w.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mumin.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x77]
# CHECK-OBJ: mumin.w.mm	tr0, tr1, tr2
mumin.w.mm	tr0, tr1, tr2

# CHECK-ASM: mumin.w.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x75]
# CHECK-OBJ: mumin.w.mv.i	tr0, tr2, tr1[0x3]
mumin.w.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: msll.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x87]
# CHECK-OBJ: msll.w.mm	tr0, tr1, tr2
msll.w.mm	tr0, tr1, tr2

# CHECK-ASM: msll.w.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x85]
# CHECK-OBJ: msll.w.mv.i	tr0, tr2, tr1[0x3]
msll.w.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: msrl.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x97]
# CHECK-OBJ: msrl.w.mm	tr0, tr1, tr2
msrl.w.mm	tr0, tr1, tr2

# CHECK-ASM: msrl.w.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x95]
# CHECK-OBJ: msrl.w.mv.i	tr0, tr2, tr1[0x3]
msrl.w.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: msra.w.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0xa7]
# CHECK-OBJ: msra.w.mm	tr0, tr1, tr2
msra.w.mm	tr0, tr1, tr2

# CHECK-ASM: msra.w.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0xa5]
# CHECK-OBJ: msra.w.mv.i	tr0, tr2, tr1[0x3]
msra.w.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfadd.h.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x94,0xa4,0x0b]
# CHECK-OBJ: mfadd.h.mm	tr0, tr1, tr2
mfadd.h.mm	tr0, tr1, tr2

# CHECK-ASM: mfadd.h.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x94,0xa4,0x09]
# CHECK-OBJ: mfadd.h.mv.i	tr0, tr2, tr1[0x3]
mfadd.h.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfadd.s.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x0b]
# CHECK-OBJ: mfadd.s.mm	tr0, tr1, tr2
mfadd.s.mm	tr0, tr1, tr2

# CHECK-ASM: mfadd.s.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x09]
# CHECK-OBJ: mfadd.s.mv.i	tr0, tr2, tr1[0x3]
mfadd.s.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfadd.d.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x9c,0xac,0x0b]
# CHECK-OBJ: mfadd.d.mm	tr0, tr1, tr2
mfadd.d.mm	tr0, tr1, tr2

# CHECK-ASM: mfadd.d.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x9c,0xac,0x09]
# CHECK-OBJ: mfadd.d.mv.i	tr0, tr2, tr1[0x3]
mfadd.d.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfsub.h.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x94,0xa4,0x1b]
# CHECK-OBJ: mfsub.h.mm	tr0, tr1, tr2
mfsub.h.mm	tr0, tr1, tr2

# CHECK-ASM: mfsub.h.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x94,0xa4,0x19]
# CHECK-OBJ: mfsub.h.mv.i	tr0, tr2, tr1[0x3]
mfsub.h.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfsub.s.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x1b]
# CHECK-OBJ: mfsub.s.mm	tr0, tr1, tr2
mfsub.s.mm	tr0, tr1, tr2

# CHECK-ASM: mfsub.s.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x19]
# CHECK-OBJ: mfsub.s.mv.i	tr0, tr2, tr1[0x3]
mfsub.s.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfsub.d.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x9c,0xac,0x1b]
# CHECK-OBJ: mfsub.d.mm	tr0, tr1, tr2
mfsub.d.mm	tr0, tr1, tr2

# CHECK-ASM: mfsub.d.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x9c,0xac,0x19]
# CHECK-OBJ: mfsub.d.mv.i	tr0, tr2, tr1[0x3]
mfsub.d.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfmul.h.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x94,0xa4,0x2b]
# CHECK-OBJ: mfmul.h.mm	tr0, tr1, tr2
mfmul.h.mm	tr0, tr1, tr2

# CHECK-ASM: mfmul.h.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x94,0xa4,0x29]
# CHECK-OBJ: mfmul.h.mv.i	tr0, tr2, tr1[0x3]
mfmul.h.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfmul.s.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x2b]
# CHECK-OBJ: mfmul.s.mm	tr0, tr1, tr2
mfmul.s.mm	tr0, tr1, tr2

# CHECK-ASM: mfmul.s.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x29]
# CHECK-OBJ: mfmul.s.mv.i	tr0, tr2, tr1[0x3]
mfmul.s.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfmul.d.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x9c,0xac,0x2b]
# CHECK-OBJ: mfmul.d.mm	tr0, tr1, tr2
mfmul.d.mm	tr0, tr1, tr2

# CHECK-ASM: mfmul.d.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x9c,0xac,0x29]
# CHECK-OBJ: mfmul.d.mv.i	tr0, tr2, tr1[0x3]
mfmul.d.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfmax.h.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x94,0xa4,0x3b]
# CHECK-OBJ: mfmax.h.mm	tr0, tr1, tr2
mfmax.h.mm	tr0, tr1, tr2

# CHECK-ASM: mfmax.h.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x94,0xa4,0x39]
# CHECK-OBJ: mfmax.h.mv.i	tr0, tr2, tr1[0x3]
mfmax.h.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfmax.s.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x3b]
# CHECK-OBJ: mfmax.s.mm	tr0, tr1, tr2
mfmax.s.mm	tr0, tr1, tr2

# CHECK-ASM: mfmax.s.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x39]
# CHECK-OBJ: mfmax.s.mv.i	tr0, tr2, tr1[0x3]
mfmax.s.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfmax.d.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x9c,0xac,0x3b]
# CHECK-OBJ: mfmax.d.mm	tr0, tr1, tr2
mfmax.d.mm	tr0, tr1, tr2

# CHECK-ASM: mfmax.d.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x9c,0xac,0x39]
# CHECK-OBJ: mfmax.d.mv.i	tr0, tr2, tr1[0x3]
mfmax.d.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfmin.h.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x94,0xa4,0x4b]
# CHECK-OBJ: mfmin.h.mm	tr0, tr1, tr2
mfmin.h.mm	tr0, tr1, tr2

# CHECK-ASM: mfmin.h.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x94,0xa4,0x49]
# CHECK-OBJ: mfmin.h.mv.i	tr0, tr2, tr1[0x3]
mfmin.h.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfmin.s.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x4b]
# CHECK-OBJ: mfmin.s.mm	tr0, tr1, tr2
mfmin.s.mm	tr0, tr1, tr2

# CHECK-ASM: mfmin.s.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x98,0xa8,0x49]
# CHECK-OBJ: mfmin.s.mv.i	tr0, tr2, tr1[0x3]
mfmin.s.mv.i	tr0, tr2, tr1[3]

# CHECK-ASM: mfmin.d.mm	tr0, tr1, tr2
# CHECK-ASM: encoding: [0x2b,0x9c,0xac,0x4b]
# CHECK-OBJ: mfmin.d.mm	tr0, tr1, tr2
mfmin.d.mm	tr0, tr1, tr2

# CHECK-ASM: mfmin.d.mv.i	tr0, tr2, tr1[3]
# CHECK-ASM: encoding: [0x2b,0x9c,0xac,0x49]
# CHECK-OBJ: mfmin.d.mv.i	tr0, tr2, tr1[0x3]
mfmin.d.mv.i	tr0, tr2, tr1[3]
