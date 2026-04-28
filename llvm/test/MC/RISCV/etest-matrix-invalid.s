# RUN: not llvm-mc -triple riscv32 %s 2>&1 | FileCheck %s
# RUN: not llvm-mc -triple riscv64 %s 2>&1 | FileCheck %s

# CHECK: instruction requires the following: 'ETEST-Matrix' (ETEST Matrix Extension)
msettilemi 100

# CHECK: instruction requires the following: 'ETEST-Matrix' (ETEST Matrix Extension)
mlae8 tr0, (a0), a1

# CHECK: instruction requires the following: 'ETEST-Matrix' (ETEST Matrix Extension)
mfmacc.h acc0, tr1, tr2

# CHECK: instruction requires the following: 'ETEST-Matrix' (ETEST Matrix Extension)
madd.w.mm tr0, tr1, tr2

# CHECK: instruction requires the following: 'ETEST-Matrix' (ETEST Matrix Extension)
mfadd.h.mm tr0, tr1, tr2

# CHECK: instruction requires the following: 'ETEST-Matrix' (ETEST Matrix Extension)
mfcvtl.h.e4 tr1, tr2

# CHECK: instruction requires the following: 'ETEST-Matrix' (ETEST Matrix Extension)
mrslidedown tr0, tr1, 2

# CHECK: instruction requires the following: 'ETEST-Matrix' (ETEST Matrix Extension)
mcslidedown.b tr0, tr1, 2
