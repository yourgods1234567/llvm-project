# RUN: llvm-mc -triple riscv32 -mattr=+experimental-xetestmatrix %s \
# RUN:     | FileCheck %s
# RUN: llvm-mc -triple riscv64 -mattr=+experimental-xetestmatrix %s \
# RUN:     | FileCheck %s

# URW CSRs — xmcsr
# CHECK: csrrw a0, xmcsr, a1
csrrw a0, xmcsr, a1
# CHECK: csrrs a0, xmcsr, a1
csrrs a0, xmcsr, a1
# CHECK: csrrc a0, xmcsr, a1
csrrc a0, xmcsr, a1
# CHECK: csrrwi a0, xmcsr, 5
csrrwi a0, xmcsr, 5
# CHECK: csrrsi a0, xmcsr, 5
csrrsi a0, xmcsr, 5
# CHECK: csrrci a0, xmcsr, 5
csrrci a0, xmcsr, 5

# URW CSRs — mtilem
# CHECK: csrrw a0, mtilem, a1
csrrw a0, mtilem, a1
# CHECK: csrrs a0, mtilem, a1
csrrs a0, mtilem, a1
# CHECK: csrrc a0, mtilem, a1
csrrc a0, mtilem, a1
# CHECK: csrrwi a0, mtilem, 3
csrrwi a0, mtilem, 3
# CHECK: csrrsi a0, mtilem, 3
csrrsi a0, mtilem, 3
# CHECK: csrrci a0, mtilem, 3
csrrci a0, mtilem, 3

# URW CSRs — mtilen
# CHECK: csrrw a0, mtilen, a1
csrrw a0, mtilen, a1
# CHECK: csrrs a0, mtilen, a1
csrrs a0, mtilen, a1
# CHECK: csrrc a0, mtilen, a1
csrrc a0, mtilen, a1
# CHECK: csrrwi a0, mtilen, 7
csrrwi a0, mtilen, 7
# CHECK: csrrsi a0, mtilen, 7
csrrsi a0, mtilen, 7
# CHECK: csrrci a0, mtilen, 7
csrrci a0, mtilen, 7

# URW CSRs — mtilek
# CHECK: csrrw a0, mtilek, a1
csrrw a0, mtilek, a1
# CHECK: csrrs a0, mtilek, a1
csrrs a0, mtilek, a1
# CHECK: csrrc a0, mtilek, a1
csrrc a0, mtilek, a1
# CHECK: csrrwi a0, mtilek, 15
csrrwi a0, mtilek, 15
# CHECK: csrrsi a0, mtilek, 15
csrrsi a0, mtilek, 15
# CHECK: csrrci a0, mtilek, 15
csrrci a0, mtilek, 15

# URW CSRs — xmxrm
# CHECK: csrrw a0, xmxrm, a1
csrrw a0, xmxrm, a1
# CHECK: csrrs a0, xmxrm, a1
csrrs a0, xmxrm, a1
# CHECK: csrrc a0, xmxrm, a1
csrrc a0, xmxrm, a1
# CHECK: csrrwi a0, xmxrm, 1
csrrwi a0, xmxrm, 1
# CHECK: csrrsi a0, xmxrm, 1
csrrsi a0, xmxrm, 1
# CHECK: csrrci a0, xmxrm, 1
csrrci a0, xmxrm, 1

# URW CSRs — xmsat
# CHECK: csrrw a0, xmsat, a1
csrrw a0, xmsat, a1
# CHECK: csrrs a0, xmsat, a1
csrrs a0, xmsat, a1
# CHECK: csrrc a0, xmsat, a1
csrrc a0, xmsat, a1
# CHECK: csrrwi a0, xmsat, 1
csrrwi a0, xmsat, 1
# CHECK: csrrsi a0, xmsat, 1
csrrsi a0, xmsat, 1
# CHECK: csrrci a0, xmsat, 1
csrrci a0, xmsat, 1

# URW CSRs — xmfflags
# CHECK: csrrw a0, xmfflags, a1
csrrw a0, xmfflags, a1
# CHECK: csrrs a0, xmfflags, a1
csrrs a0, xmfflags, a1
# CHECK: csrrc a0, xmfflags, a1
csrrc a0, xmfflags, a1
# CHECK: csrrwi a0, xmfflags, 31
csrrwi a0, xmfflags, 31
# CHECK: csrrsi a0, xmfflags, 31
csrrsi a0, xmfflags, 31
# CHECK: csrrci a0, xmfflags, 31
csrrci a0, xmfflags, 31

# URW CSRs — xmfrm
# CHECK: csrrw a0, xmfrm, a1
csrrw a0, xmfrm, a1
# CHECK: csrrs a0, xmfrm, a1
csrrs a0, xmfrm, a1
# CHECK: csrrc a0, xmfrm, a1
csrrc a0, xmfrm, a1
# CHECK: csrrwi a0, xmfrm, 7
csrrwi a0, xmfrm, 7
# CHECK: csrrsi a0, xmfrm, 7
csrrsi a0, xmfrm, 7
# CHECK: csrrci a0, xmfrm, 7
csrrci a0, xmfrm, 7

# URW CSRs — xmsaten
# CHECK: csrrw a0, xmsaten, a1
csrrw a0, xmsaten, a1
# CHECK: csrrs a0, xmsaten, a1
csrrs a0, xmsaten, a1
# CHECK: csrrc a0, xmsaten, a1
csrrc a0, xmsaten, a1
# CHECK: csrrwi a0, xmsaten, 1
csrrwi a0, xmsaten, 1
# CHECK: csrrsi a0, xmsaten, 1
csrrsi a0, xmsaten, 1
# CHECK: csrrci a0, xmsaten, 1
csrrci a0, xmsaten, 1

# URO CSRs (read-only) — csrr only
# CHECK: csrr a0, xmisa
csrr a0, xmisa
# CHECK: csrr a0, xtlenb
csrr a0, xtlenb
# CHECK: csrr a0, xtrlenb
csrr a0, xtrlenb
# CHECK: csrr a0, xalenb
csrr a0, xalenb
