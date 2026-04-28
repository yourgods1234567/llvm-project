# RUN: not llvm-mc -triple riscv32 %s 2>&1 | FileCheck %s
# RUN: not llvm-mc -triple riscv64 %s 2>&1 | FileCheck %s

# CHECK: error: system register 'xmcsr' requires 'experimental-xetestmatrix' to be enabled
csrrw a0, xmcsr, a1
# CHECK: error: system register 'mtilem' requires 'experimental-xetestmatrix' to be enabled
csrr a0, mtilem
# CHECK: error: system register 'mtilen' requires 'experimental-xetestmatrix' to be enabled
csrrwi a0, mtilen, 5
# CHECK: error: system register 'mtilek' requires 'experimental-xetestmatrix' to be enabled
csrr a0, mtilek
# CHECK: error: system register 'xmxrm' requires 'experimental-xetestmatrix' to be enabled
csrrs a0, xmxrm, a1
# CHECK: error: system register 'xmsat' requires 'experimental-xetestmatrix' to be enabled
csrr a0, xmsat
# CHECK: error: system register 'xmfflags' requires 'experimental-xetestmatrix' to be enabled
csrrw a0, xmfflags, a1
# CHECK: error: system register 'xmfrm' requires 'experimental-xetestmatrix' to be enabled
csrr a0, xmfrm
# CHECK: error: system register 'xmsaten' requires 'experimental-xetestmatrix' to be enabled
csrrwi a0, xmsaten, 1
# CHECK: error: system register 'xmisa' requires 'experimental-xetestmatrix' to be enabled
csrr a0, xmisa
# CHECK: error: system register 'xtlenb' requires 'experimental-xetestmatrix' to be enabled
csrr a0, xtlenb
# CHECK: error: system register 'xtrlenb' requires 'experimental-xetestmatrix' to be enabled
csrr a0, xtrlenb
# CHECK: error: system register 'xalenb' requires 'experimental-xetestmatrix' to be enabled
csrr a0, xalenb
