#!/usr/bin/env python3
"""Generate RISCVInstrInfoXETEST.td from the spec encoding."""

def bits(val, n):
    """Format an integer as a TableGen binary literal with exactly n bits."""
    return f"0b{val:0{n}b}"

def gen():
    lines = []
    def L(s=""):
        lines.append(s)

    L("""//===-- RISCVInstrInfoXETEST.td - ETEST Matrix Extension -----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the Xetest-matrix vendor extension defined by ETEST.
// Auto-generated from riscv_matrix_instructions.md.
//
//===----------------------------------------------------------------------===//

let DecoderNamespace = "XETEST" in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0,
    Predicates = [HasVendorXETESTMatrix] in {

//===----------------------------------------------------------------------===//
// Format classes
//===----------------------------------------------------------------------===//

// Base format: matrix register operations
// func4(31-28) | uop(27-26) | imm3(25-23) | ms2(22-20) | s_size(19-18) | ms1(17-15) | func3(14-12) | d_size(11-10) | md(9-7) | opcode(6-0)
class XESWinBaseInst<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<4> func4;
  bits<2> uop;
  bits<3> imm3;
  bits<3> ms2;
  bits<2> s_size;
  bits<3> ms1;
  bits<3> func3;
  bits<2> d_size;
  bits<3> md;

  let Inst{31-28} = func4;
  let Inst{27-26} = uop;
  let Inst{25-23} = imm3;
  let Inst{22-20} = ms2;
  let Inst{19-18} = s_size;
  let Inst{17-15} = ms1;
  let Inst{14-12} = func3;
  let Inst{11-10} = d_size;
  let Inst{9-7}   = md;
  let Inst{6-0}   = OPC_CUSTOM_1.Value;
}

// Load/Store format
// func4(31-28) | 01(27-26) | ls(25) | rs2(24-20) | rs1(19-15) | 000(14-12) | d_size(11-10) | md(9-7) | opcode(6-0)
class XESWinLdStInst<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<4> func4;
  bit ls;
  bits<5> rs2;
  bits<5> rs1;
  bits<2> d_size;
  bits<3> md;

  let Inst{31-28} = func4;
  let Inst{27-26} = 0b01;
  let Inst{25}    = ls;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b000;
  let Inst{11-10} = d_size;
  let Inst{9-7}   = md;
  let Inst{6-0}   = OPC_CUSTOM_1.Value;
}

class XESWinLoadInst<dag outs, dag ins, string opcodestr, string argstr>
    : XESWinLdStInst<outs, ins, opcodestr, argstr> {
  let ls = 0;
  let mayLoad = 1;
  let mayStore = 0;
}

class XESWinStoreInst<dag outs, dag ins, string opcodestr, string argstr>
    : XESWinLdStInst<outs, ins, opcodestr, argstr> {
  let ls = 1;
  let mayLoad = 0;
  let mayStore = 1;
}

// Multiply-Accumulate format
// func4(31-28) | 10(27-26) | size_sup(25-23) | ms2(22-20) | s_size(19-18) | ms1(17-15) | 000(14-12) | d_size(11-10) | md(9-7) | opcode(6-0)
class XESWinMACInst<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<4> func4;
  bits<3> size_sup;
  bits<3> ms2;
  bits<2> s_size;
  bits<3> ms1;
  bits<2> d_size;
  bits<3> md;

  let Inst{31-28} = func4;
  let Inst{27-26} = 0b10;
  let Inst{25-23} = size_sup;
  let Inst{22-20} = ms2;
  let Inst{19-18} = s_size;
  let Inst{17-15} = ms1;
  let Inst{14-12} = 0b000;
  let Inst{11-10} = d_size;
  let Inst{9-7}   = md;
  let Inst{6-0}   = OPC_CUSTOM_1.Value;
}

// Config immediate format
// func4(31-28) | 00(27-26) | 0(25) | imm10(24-15) | 000(14-12) | rd(11-7) | opcode(6-0)
class XESWinConfigImmInst<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<4> func4;
  bits<10> imm10;
  bits<5> rd;

  let Inst{31-28} = func4;
  let Inst{27-26} = 0b00;
  let Inst{25}    = 0;
  let Inst{24-15} = imm10;
  let Inst{14-12} = 0b000;
  let Inst{11-7}  = rd;
  let Inst{6-0}   = OPC_CUSTOM_1.Value;
}

// Config register format
// func4(31-28) | 00(27-26) | 1(25) | 0(24) | rs1(23-19) | 0000(18-15) | 000(14-12) | rd(11-7) | opcode(6-0)
class XESWinConfigRegInst<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<4> func4;
  bits<5> rs1;
  bits<5> rd;

  let Inst{31-28} = func4;
  let Inst{27-26} = 0b00;
  let Inst{25}    = 1;
  let Inst{24}    = 0;
  let Inst{23-19} = rs1;
  let Inst{18-15} = 0b0000;
  let Inst{14-12} = 0b000;
  let Inst{11-7}  = rd;
  let Inst{6-0}   = OPC_CUSTOM_1.Value;
}

// Matrix-to-GPR move format (format 2)
// func4(31-28) | 11(27-26) | ctrl(25) | e_size(24-23) | ms2(22-20) | rs1(19-15) | 000(14-12) | rd(11-7) | opcode(6-0)
class XESWinMovXMInst<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<4> func4;
  bit ctrl;
  bits<2> e_size;
  bits<3> ms2;
  bits<5> rs1;
  bits<5> rd;

  let Inst{31-28} = func4;
  let Inst{27-26} = 0b11;
  let Inst{25}    = ctrl;
  let Inst{24-23} = e_size;
  let Inst{22-20} = ms2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b000;
  let Inst{11-7}  = rd;
  let Inst{6-0}   = OPC_CUSTOM_1.Value;
}

// GPR-to-matrix move format (format 3)
// func4(31-28) | 11(27-26) | ctrl(25) | rs2(24-20) | rs1(19-15) | 000(14-12) | d_size(11-10) | md(9-7) | opcode(6-0)
class XESWinMovMXInst<dag outs, dag ins, string opcodestr, string argstr>
    : RVInst<outs, ins, opcodestr, argstr, [], InstFormatOther> {
  bits<4> func4;
  bit ctrl;
  bits<5> rs2;
  bits<5> rs1;
  bits<2> d_size;
  bits<3> md;

  let Inst{31-28} = func4;
  let Inst{27-26} = 0b11;
  let Inst{25}    = ctrl;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b000;
  let Inst{11-10} = d_size;
  let Inst{9-7}   = md;
  let Inst{6-0}   = OPC_CUSTOM_1.Value;
}
""")

    # === Config instructions ===
    L("//===----------------------------------------------------------------------===//")
    L("// Configuration Instructions (Section 2: func3=000, uop=00)")
    L("//===----------------------------------------------------------------------===//")
    L()
    conf_imm = [
        ("MSETTILEMI", "msettilemi", 0b0000),
        ("MSETTILEKI", "msettileki", 0b0001),
        ("MSETTILENI", "msettileni", 0b0010),
    ]
    for name, mnem, f4 in conf_imm:
        L(f"let func4 = {bits(f4,4)} in")
        L(f"def {name} : XESWinConfigImmInst<(outs), (ins uimm10:$imm10), \"{mnem}\", \"$imm10\"> {{")
        L("  let rd = 0;")
        L("}")
        L()
    conf_reg = [
        ("MSETTILEM", "msettilem", 0b0000),
        ("MSETTILEK", "msettilek", 0b0001),
        ("MSETTILEN", "msettilen", 0b0010),
    ]
    for name, mnem, f4 in conf_reg:
        L(f"let func4 = {bits(f4,4)} in")
        L(f"def {name} : XESWinConfigRegInst<(outs), (ins GPR:$rs1), \"{mnem}\", \"$rs1\"> {{")
        L("  let rd = 0;")
        L("}")
        L()
    L("def MRELEASE : XESWinConfigImmInst<(outs), (ins), \"mrelease\", \"\"> {")
    L("  let func4 = 0b0011;")
    L("  let imm10 = 0;")
    L("  let rd = 0;")
    L("}")
    L()

    # === Load instructions ===
    L("//===----------------------------------------------------------------------===//")
    L("// Load Instructions (Section 3: func3=000, uop=01, ls=0)")
    L("//===----------------------------------------------------------------------===//")
    L()
    dsize_suffix = {0: "8", 1: "16", 2: "32", 3: "64"}
    load_specs = [
        ("MLAE", "mlae", 0b0000, "MatrixTR"),
        ("MLBE", "mlbe", 0b0001, "MatrixTR"),
        ("MLCE", "mlce", 0b0010, "MatrixACC"),
        ("MLATE", "mlate", 0b0011, "MatrixTR"),
        ("MLBTE", "mlbte", 0b0100, "MatrixTR"),
        ("MLCTE", "mlcte", 0b0101, "MatrixACC"),
        ("MLME", "mlme", 0b0110, "MatrixMR"),
    ]
    for defpre, mnempre, f4, rc in load_specs:
        L(f"let func4 = {bits(f4,4)} in {{")
        for ds in [0, 1, 2, 3]:
            suff = dsize_suffix[ds]
            L(f"  def {defpre}{suff} : XESWinLoadInst<(outs {rc}:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), \"{mnempre}{suff}\", \"$md, $rs1, $rs2\"> {{")
            L(f"    let d_size = {bits(ds,2)};")
            L("  }")
        L("}")
        L()

    # === Store instructions ===
    L("//===----------------------------------------------------------------------===//")
    L("// Store Instructions (Section 3: func3=000, uop=01, ls=1)")
    L("//===----------------------------------------------------------------------===//")
    L()
    store_specs = [
        ("MSAE", "msae", 0b0000, "MatrixTR"),
        ("MSBE", "msbe", 0b0001, "MatrixTR"),
        ("MSCE", "msce", 0b0010, "MatrixACC"),
        ("MSATE", "msate", 0b0011, "MatrixTR"),
        ("MSBTE", "msbte", 0b0100, "MatrixTR"),
        ("MSCTE", "mscte", 0b0101, "MatrixACC"),
        ("MSME", "msme", 0b0110, "MatrixMR"),
    ]
    for defpre, mnempre, f4, rc in store_specs:
        L(f"let func4 = {bits(f4,4)} in {{")
        for ds in [0, 1, 2, 3]:
            suff = dsize_suffix[ds]
            L(f"  def {defpre}{suff} : XESWinStoreInst<(outs), (ins {rc}:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), \"{mnempre}{suff}\", \"$md, $rs1, $rs2\"> {{")
            L(f"    let d_size = {bits(ds,2)};")
            L("  }")
        L("}")
        L()

    # === Matrix Multiply-Accumulate ===
    L("//===----------------------------------------------------------------------===//")
    L("// Matrix Multiply-Accumulate Instructions (Section 4: func3=000, uop=10)")
    L("//===----------------------------------------------------------------------===//")
    L()
    mac_specs = [
        ("MFMACC_H",   "mfmacc.h",   0b0000, 0b000, 0b01, 0b01),
        ("MFMACC_S",   "mfmacc.s",   0b0000, 0b000, 0b10, 0b10),
        ("MFMACC_D",   "mfmacc.d",   0b0000, 0b000, 0b11, 0b11),
        ("MFMACC_H_E4",  "mfmacc.h.e4",  0b0000, 0b010, 0b00, 0b01),
        ("MFMACC_H_E5",  "mfmacc.h.e5",  0b0000, 0b000, 0b00, 0b01),
        ("MFMACC_BF16_E4", "mfmacc.bf16.e4", 0b0000, 0b110, 0b00, 0b01),
        ("MFMACC_BF16_E5", "mfmacc.bf16.e5", 0b0000, 0b100, 0b00, 0b01),
        ("MFMACC_S_H",   "mfmacc.s.h",   0b0000, 0b000, 0b01, 0b10),
        ("MFMACC_S_BF16", "mfmacc.s.bf16", 0b0000, 0b100, 0b01, 0b10),
        ("MFMACC_D_S",   "mfmacc.d.s",   0b0000, 0b000, 0b10, 0b11),
        ("MFMACC_S_E4",  "mfmacc.s.e4",  0b0000, 0b010, 0b00, 0b10),
        ("MFMACC_S_E5",  "mfmacc.s.e5",  0b0000, 0b000, 0b00, 0b10),
        ("MMACC_W_B",    "mmacc.w.b",    0b0001, 0b000, 0b00, 0b10),
        ("MMACCU_W_B",   "mmaccu.w.b",   0b0001, 0b100, 0b00, 0b10),
        ("MMACCSU_W_B",  "mmaccsu.w.b",  0b0001, 0b010, 0b00, 0b10),
        ("MMACCUS_W_B",  "mmaccus.w.b",  0b0001, 0b110, 0b00, 0b10),
    ]
    for name, mnem, f4, ssup, ssz, dsz in mac_specs:
        L(f"def {name} : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),")
        L(f"                            \"{mnem}\", \"$md, $ms1, $ms2\"> {{")
        L(f"  let func4 = {bits(f4,4)};")
        L(f"  let size_sup = {bits(ssup,3)};")
        L(f"  let s_size = {bits(ssz,2)};")
        L(f"  let d_size = {bits(dsz,2)};")
        L("}")
        L()

    # === MISC Instructions ===
    L("//===----------------------------------------------------------------------===//")
    L("// MISC Instructions (Section 5: func3=000, uop=11)")
    L("//===----------------------------------------------------------------------===//")
    L()

    # Mzero
    L("// --- Mzero (Section 5.2) ---")
    L(f"let func4 = {bits(0,4)}, uop = {bits(3,2)}, func3 = {bits(0,3)}, "
      f"ms2 = {bits(0,3)}, s_size = {bits(0,2)}, ms1 = {bits(0,3)}, d_size = {bits(0,2)} in {{")
    for val, name in [(0b000, "MZERO1R"), (0b001, "MZERO2R"), (0b011, "MZERO4R"), (0b111, "MZERO8R")]:
        L(f"  def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins), \"{name.lower()}\", \"$md\"> {{ let imm3 = {bits(val,3)}; }}")
    L("}")
    L()

    # Data move
    L("// --- Data Move (Section 5.3) ---")
    L("// mmov.mm - matrix to matrix copy")
    L(f"let func4 = {bits(1,4)}, uop = {bits(3,2)}, func3 = {bits(0,3)}, "
      f"s_size = {bits(0,2)}, ms2 = {bits(0,3)}, d_size = {bits(0,2)} in")
    L("def MMOV_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), \"mmov.mm\", \"$md, $ms1\"> {")
    L(f"  let imm3 = {bits(7,3)};")
    L("}")
    L()

    L("// mmov.b/h/w/d.x.m - matrix element to GPR (format 2)")
    for es, suff in [(0b00, "b"), (0b01, "h"), (0b10, "w"), (0b11, "d")]:
        L(f"def MMOV_{suff.upper()}_X_M : XESWinMovXMInst<(outs GPR:$rd), (ins MatrixMR:$ms2, GPR:$rs1),")
        L(f"                                     \"mmov.{suff}.x.m\", \"$rd, $ms2, $rs1\"> {{")
        L(f"  let func4 = {bits(2,4)};")
        L(f"  let ctrl = 0;")
        L(f"  let e_size = {bits(es,2)};")
        L("}")
        L()

    L("// mmov.b/h/w/d.m.x - GPR to matrix element (format 3)")
    for ds, suff in [(0b00, "b"), (0b01, "h"), (0b10, "w"), (0b11, "d")]:
        L(f"def MMOV_{suff.upper()}_M_X : XESWinMovMXInst<(outs MatrixMR:$md), (ins GPR:$rs2, GPR:$rs1),")
        L(f"                                     \"mmov.{suff}.m.x\", \"$md, $rs2, $rs1\"> {{")
        L(f"  let func4 = {bits(3,4)};")
        L(f"  let ctrl = 1;")
        L(f"  let d_size = {bits(ds,2)};")
        L("}")
        L()

    # Broadcast
    L("// --- Broadcast (Section 5.4) ---")
    L(f"let func4 = {bits(4,4)}, uop = {bits(3,2)}, func3 = {bits(0,3)}, "
      f"s_size = {bits(0,2)}, ms2 = {bits(0,3)}, d_size = {bits(0,2)} in {{")
    for im3, suff in [(0b000, "8"), (0b001, "16"), (0b010, "32"), (0b011, "64")]:
        L(f"  def MBCE{suff} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), \"mbce{suff}\", \"$md, $ms1\"> {{ let imm3 = {bits(im3,3)}; }}")
    L("}")
    L()
    L(f"let func4 = {bits(5,4)}, uop = {bits(3,2)}, func3 = {bits(0,3)}, "
      f"s_size = {bits(0,2)}, ms2 = {bits(0,3)}, d_size = {bits(0,2)} in")
    L("def MRBC_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),")
    L("                               \"mrbc.mv.i\", \"$md, $ms1, $imm3\">;")
    L()
    L(f"let func4 = {bits(6,4)}, uop = {bits(3,2)}, func3 = {bits(0,3)}, "
      f"s_size = {bits(0,2)}, ms2 = {bits(0,3)}, d_size = {bits(0,2)} in {{")
    for im3, suff in [(0b000, "8"), (0b001, "16"), (0b010, "32"), (0b011, "64")]:
        L(f"  def MCBCE{suff}_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),")
        L(f"                                     \"mcbce{suff}.mv.i\", \"$md, $ms1, $imm3\"> {{ let imm3 = {bits(im3,3)}; }}")
    L("}")
    L()

    # Pack
    L("// --- Pack (Section 5.5) ---")
    pack_specs = [
        ("MPACK_MM",   "mpack.mm",   0b1000),
        ("MPACKHL_MM", "mpackhl.mm", 0b1001),
        ("MPACKHH_MM", "mpackhh.mm", 0b1010),
    ]
    for name, mnem, f4 in pack_specs:
        L(f"let func4 = {bits(f4,4)}, uop = {bits(3,2)}, func3 = {bits(0,3)}, "
          f"s_size = {bits(0,2)}, d_size = {bits(0,2)} in")
        L(f"def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),")
        L(f"                             \"{mnem}\", \"$md, $ms1, $ms2\"> {{ let imm3 = {bits(7,3)}; }}")
        L()

    # Slide
    L("// --- Slide (Section 5.6) ---")
    slide_specs = [
        ("MRSLIDEDOWNE", "mrslidedowne", 0b1011),
        ("MRSLIDEUPE",   "mrslideupe",   0b1100),
        ("MCSLIDEDOWNE", "mcslidedowne", 0b1101),
        ("MCSLIDEUPE",   "mcslideupe",   0b1110),
    ]
    for defpre, mnempre, f4 in slide_specs:
        L(f"let func4 = {bits(f4,4)}, uop = {bits(3,2)}, func3 = {bits(0,3)}, ms2 = {bits(0,3)} in {{")
        for ds in [0, 1, 2, 3]:
            suff = dsize_suffix[ds]
            L(f"  def {defpre}{suff} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),")
            L(f"                     \"{mnempre}{suff}\", \"$md, $ms1, $imm3\"> {{")
            L(f"    let d_size = {bits(ds,2)};")
            L(f"    let s_size = {bits(ds,2)};")
            L("  }")
        L("}")
        L()

    # === Element-wise Type Conversion ===
    L("//===----------------------------------------------------------------------===//")
    L("// Element-wise Type Conversion Instructions (Section 6.2: func3=001, uop=00)")
    L("//===----------------------------------------------------------------------===//")
    L()

    # fp conversions - first block
    L("// --- Floating-point conversions (func4=0000) ---")
    cvts1 = [
        ("MFCVTL_H_E4",   "mfcvtl.h.e4",   0b000, 0b01, 0b00),
        ("MFCVTH_H_E4",   "mfcvth.h.e4",   0b001, 0b01, 0b00),
        ("MFCVTL_H_E5",   "mfcvtl.h.e5",   0b010, 0b01, 0b00),
        ("MFCVTH_H_E5",   "mfcvth.h.e5",   0b011, 0b01, 0b00),
        ("MFCVTL_S_H",    "mfcvtl.s.h",    0b100, 0b10, 0b01),
        ("MFCVTH_S_H",    "mfcvth.s.h",    0b101, 0b10, 0b01),
        ("MFCVTL_S_BF16", "mfcvtl.s.bf16", 0b110, 0b10, 0b01),
        ("MFCVTH_S_BF16", "mfcvth.s.bf16", 0b111, 0b10, 0b01),
    ]
    L(f"let func4 = {bits(0,4)}, func3 = {bits(1,3)}, uop = {bits(0,2)}, ms2 = {bits(0,3)} in {{")
    for name, mnem, im3, dsz, ssz in cvts1:
        L(f"  def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), \"{mnem}\", \"$md, $ms1\"> {{")
        L(f"    let imm3 = {bits(im3,3)}; let d_size = {bits(dsz,2)}; let s_size = {bits(ssz,2)};")
        L("  }")
    L("}")
    L()

    cvts2 = [
        ("MFCVTL_D_S",    "mfcvtl.d.s",    0b000, 0b11, 0b10),
        ("MFCVTH_D_S",    "mfcvth.d.s",    0b001, 0b11, 0b10),
        ("MFCVTL_E4_H",   "mfcvtl.e4.h",   0b010, 0b00, 0b01),
        ("MFCVTH_E4_H",   "mfcvth.e4.h",   0b011, 0b00, 0b01),
        ("MFCVTL_E5_H",   "mfcvtl.e5.h",   0b100, 0b00, 0b01),
        ("MFCVTH_E5_H",   "mfcvth.e5.h",   0b101, 0b00, 0b01),
        ("MFCVTL_H_S",    "mfcvtl.h.s",    0b110, 0b01, 0b10),
        ("MFCVTH_H_S",    "mfcvth.h.s",    0b111, 0b01, 0b10),
    ]
    L(f"let func4 = {bits(0,4)}, func3 = {bits(1,3)}, uop = {bits(0,2)}, ms2 = {bits(0,3)} in {{")
    for name, mnem, im3, dsz, ssz in cvts2:
        L(f"  def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), \"{mnem}\", \"$md, $ms1\"> {{")
        L(f"    let imm3 = {bits(im3,3)}; let d_size = {bits(dsz,2)}; let s_size = {bits(ssz,2)};")
        L("  }")
    L("}")
    L()

    cvts3 = [
        ("MFCVTL_BF16_S", "mfcvtl.bf16.s", 0b000, 0b01, 0b10),
        ("MFCVTH_BF16_S", "mfcvth.bf16.s", 0b001, 0b01, 0b10),
        ("MFCVTL_S_D",    "mfcvtl.s.d",    0b010, 0b10, 0b11),
        ("MFCVTH_S_D",    "mfcvth.s.d",    0b011, 0b10, 0b11),
        ("MFCVTL_E4_S",   "mfcvtl.e4.s",   0b100, 0b00, 0b10),
        ("MFCVTH_E4_S",   "mfcvth.e4.s",   0b101, 0b00, 0b10),
        ("MFCVTL_E5_S",   "mfcvtl.e5.s",   0b110, 0b00, 0b10),
        ("MFCVTH_E5_S",   "mfcvth.e5.s",   0b111, 0b00, 0b10),
    ]
    L(f"let func4 = {bits(0,4)}, func3 = {bits(1,3)}, uop = {bits(0,2)}, ms2 = {bits(0,3)} in {{")
    for name, mnem, im3, dsz, ssz in cvts3:
        L(f"  def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), \"{mnem}\", \"$md, $ms1\"> {{")
        L(f"    let imm3 = {bits(im3,3)}; let d_size = {bits(dsz,2)}; let s_size = {bits(ssz,2)};")
        L("  }")
    L("}")
    L()

    # Float-integer conversions
    L("// --- Float-Integer conversions (func4=0001) ---")
    fint_cvts1 = [
        ("MUFCVTL_H_B", "mufcvtl.h.b", 0b000, 0b01, 0b00),
        ("MUFCTVH_H_B", "mufcvth.h.b", 0b001, 0b01, 0b00),
        ("MSFCVTL_H_B", "msfcvtl.h.b", 0b010, 0b01, 0b00),
        ("MSFCVTH_H_B", "msfcvth.h.b", 0b011, 0b01, 0b00),
    ]
    L(f"let func4 = {bits(1,4)}, func3 = {bits(1,3)}, uop = {bits(0,2)}, ms2 = {bits(0,3)} in {{")
    for name, mnem, im3, dsz, ssz in fint_cvts1:
        L(f"  def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), \"{mnem}\", \"$md, $ms1\"> {{")
        L(f"    let imm3 = {bits(im3,3)}; let d_size = {bits(dsz,2)}; let s_size = {bits(ssz,2)};")
        L("  }")
    L("}")
    L()

    fint_cvts2 = [
        ("MUFCVT_S_W",  "mufcvt.s.w",  0b100, 0b10, 0b10),
        ("MSFCVT_S_W",  "msfcvt.s.w",  0b101, 0b10, 0b10),
        ("MFUCVTL_B_H", "mfucvtl.b.h", 0b110, 0b00, 0b01),
        ("MFUCVTH_B_H", "mfucvth.b.h", 0b111, 0b00, 0b01),
    ]
    L(f"let func4 = {bits(1,4)}, func3 = {bits(1,3)}, uop = {bits(0,2)}, ms2 = {bits(0,3)} in {{")
    for name, mnem, im3, dsz, ssz in fint_cvts2:
        L(f"  def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), \"{mnem}\", \"$md, $ms1\"> {{")
        L(f"    let imm3 = {bits(im3,3)}; let d_size = {bits(dsz,2)}; let s_size = {bits(ssz,2)};")
        L("  }")
    L("}")
    L()

    fint_cvts3 = [
        ("MFSCVTL_B_H", "mfscvtl.b.h", 0b000, 0b00, 0b01),
        ("MFSCVTH_B_H", "mfscvth.b.h", 0b001, 0b00, 0b01),
        ("MFUCVT_W_S",  "mfucvt.w.s",  0b010, 0b10, 0b10),
        ("MFSCVT_W_S",  "mfscvt.w.s",  0b011, 0b10, 0b10),
    ]
    L(f"let func4 = {bits(1,4)}, func3 = {bits(1,3)}, uop = {bits(0,2)}, ms2 = {bits(0,3)} in {{")
    for name, mnem, im3, dsz, ssz in fint_cvts3:
        L(f"  def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), \"{mnem}\", \"$md, $ms1\"> {{")
        L(f"    let imm3 = {bits(im3,3)}; let d_size = {bits(dsz,2)}; let s_size = {bits(ssz,2)};")
        L("  }")
    L("}")
    L()

    # Fixed-point clip
    L("// --- Fixed-point clip (func4=0010-0101) ---")
    clip_mm = [
        ("MN4CLIPL_W_MM",  "mn4clipl.w.mm",  0b0010),
        ("MN4CLIPH_W_MM",  "mn4cliph.w.mm",  0b0011),
        ("MN4CLIPLU_W_MM", "mn4cliplu.w.mm", 0b0100),
        ("MN4CLIPHU_W_MM", "mn4cliphu.w.mm", 0b0101),
    ]
    for name, mnem, f4 in clip_mm:
        L(f"let func4 = {bits(f4,4)}, func3 = {bits(1,3)}, uop = {bits(0,2)} in")
        L(f"def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),")
        L(f"                             \"{mnem}\", \"$md, $ms1, $ms2\"> {{")
        L(f"  let imm3 = {bits(7,3)}; let d_size = {bits(0,2)}; let s_size = {bits(2,2)};")
        L("}")
        L()

    clip_mv = [
        ("MN4CLIPL_W_MV_I",  "mn4clipl.w.mv.i",  0b0010),
        ("MN4CLIPH_W_MV_I",  "mn4cliph.w.mv.i",  0b0011),
        ("MN4CLIPLU_W_MV_I", "mn4cliplu.w.mv.i", 0b0100),
        ("MN4CLIPHU_W_MV_I", "mn4cliphu.w.mv.i", 0b0101),
    ]
    for name, mnem, f4 in clip_mv:
        L(f"let func4 = {bits(f4,4)}, func3 = {bits(1,3)}, uop = {bits(0,2)}, d_size = {bits(0,2)}, s_size = {bits(2,2)} in")
        L(f"def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),")
        L(f"                             \"{mnem}\", \"$md, $ms1, $ms2, $imm3\">;")
        L()

    # Int4 conversions
    L("// --- Int4 conversions (func4=0110) ---")
    int4_cvts = [
        ("MSCVTL_W_B_Q", "mscvtl.w.b.q", 0b000, 0b10, 0b00),
        ("MSCVTH_W_B_Q", "mscvth.w.b.q", 0b001, 0b10, 0b00),
        ("MUCVTL_W_B_Q", "mucvtl.w.b.q", 0b010, 0b10, 0b00),
        ("MUCVTH_W_B_Q", "mucvth.w.b.q", 0b011, 0b10, 0b00),
    ]
    L(f"let func4 = {bits(6,4)}, func3 = {bits(1,3)}, uop = {bits(0,2)}, ms2 = {bits(0,3)} in {{")
    for name, mnem, im3, dsz, ssz in int4_cvts:
        L(f"  def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), \"{mnem}\", \"$md, $ms1\"> {{")
        L(f"    let imm3 = {bits(im3,3)}; let d_size = {bits(dsz,2)}; let s_size = {bits(ssz,2)};")
        L("  }")
    L("}")
    L()

    # === Integer Arithmetic ===
    L("//===----------------------------------------------------------------------===//")
    L("// Element-wise Integer Arithmetic (Section 6.3: func3=001, uop=01, d_size=s_size=0b10)")
    L("//===----------------------------------------------------------------------===//")
    L()

    int_mm = [
        ("MADD_W_MM",   "madd.w.mm",   0b0000),
        ("MSUB_W_MM",   "msub.w.mm",   0b0001),
        ("MMUL_W_MM",   "mmul.w.mm",   0b0010),
        ("MMULH_W_MM",  "mmulh.w.mm",  0b0011),
        ("MMAX_W_MM",   "mmax.w.mm",   0b0100),
        ("MUMAX_W_MM",  "mumax.w.mm",  0b0101),
        ("MMIN_W_MM",   "mmin.w.mm",   0b0110),
        ("MUMIN_W_MM",  "mumin.w.mm",  0b0111),
        ("MSLL_W_MM",   "msll.w.mm",   0b1000),
        ("MSRL_W_MM",   "msrl.w.mm",   0b1001),
        ("MSRA_W_MM",   "msra.w.mm",   0b1010),
    ]
    L(f"let func3 = {bits(1,3)}, uop = {bits(1,2)}, d_size = {bits(2,2)}, s_size = {bits(2,2)} in {{")
    for name, mnem, f4 in int_mm:
        L(f"  def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),")
        L(f"                               \"{mnem}\", \"$md, $ms1, $ms2\"> {{")
        L(f"    let func4 = {bits(f4,4)}; let imm3 = {bits(7,3)};")
        L("  }")
    L("}")
    L()

    int_mv = [
        ("MADD_W_MV_I",   "madd.w.mv.i",   0b0000),
        ("MSUB_W_MV_I",   "msub.w.mv.i",   0b0001),
        ("MMUL_W_MV_I",   "mmul.w.mv.i",   0b0010),
        ("MMULH_W_MV_I",  "mmulh.w.mv.i",  0b0011),
        ("MMAX_W_MV_I",   "mmax.w.mv.i",   0b0100),
        ("MUMAX_W_MV_I",  "mumax.w.mv.i",  0b0101),
        ("MMIN_W_MV_I",   "mmin.w.mv.i",   0b0110),
        ("MUMIN_W_MV_I",  "mumin.w.mv.i",   0b0111),
        ("MSLL_W_MV_I",   "msll.w.mv.i",   0b1000),
        ("MSRL_W_MV_I",   "msrl.w.mv.i",   0b1001),
        ("MSRA_W_MV_I",   "msra.w.mv.i",   0b1010),
    ]
    L(f"let func3 = {bits(1,3)}, uop = {bits(1,2)}, d_size = {bits(2,2)}, s_size = {bits(2,2)} in {{")
    for name, mnem, f4 in int_mv:
        L(f"  def {name} : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),")
        L(f"                               \"{mnem}\", \"$md, $ms1, $ms2, $imm3\"> {{")
        L(f"    let func4 = {bits(f4,4)};")
        L("  }")
    L("}")
    L()

    # === Float Arithmetic ===
    L("//===----------------------------------------------------------------------===//")
    L("// Element-wise Floating-Point Arithmetic (Section 6.4: func3=001, uop=10)")
    L("//===----------------------------------------------------------------------===//")
    L()

    float_ops = [
        (0b0000, "MFADD", "mfadd"),
        (0b0001, "MFSUB", "mfsub"),
        (0b0010, "MFMUL", "mfmul"),
        (0b0011, "MFMAX", "mfmax"),
        (0b0100, "MFMIN", "mfmin"),
    ]
    precisions = [
        (0b01, "h"),
        (0b10, "s"),
        (0b11, "d"),
    ]

    for f4, defpre, mnempre in float_ops:
        L(f"let func4 = {bits(f4,4)}, func3 = {bits(1,3)}, uop = {bits(2,2)} in {{")
        for dsz, psuff in precisions:
            L(f"  def {defpre}_{psuff.upper()}_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),")
            L(f"                       \"{mnempre}.{psuff}.mm\", \"$md, $ms1, $ms2\"> {{")
            L(f"    let imm3 = {bits(7,3)}; let d_size = {bits(dsz,2)}; let s_size = {bits(dsz,2)};")
            L("  }")
        L("}")
        L()
        L(f"let func4 = {bits(f4,4)}, func3 = {bits(1,3)}, uop = {bits(2,2)} in {{")
        for dsz, psuff in precisions:
            L(f"  def {defpre}_{psuff.upper()}_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),")
            L(f"                         \"{mnempre}.{psuff}.mv.i\", \"$md, $ms1, $ms2, $imm3\"> {{")
            L(f"    let d_size = {bits(dsz,2)}; let s_size = {bits(dsz,2)};")
            L("  }")
        L("}")
        L()

    L("} // Predicates = [HasVendorXETESTMatrix]")
    L("} // DecoderNamespace = \"XETEST\"")
    L()

    return "\n".join(lines)


def main():
    content = gen()
    path = "/home/user/test/LLVM/llvm/lib/Target/RISCV/RISCVInstrInfoXETEST.td"
    with open(path, "w") as f:
        f.write(content)
    def_count = content.count("def ")
    format_class_count = content.count("class ")
    print(f"Generated {path}")
    print(f"Size: {len(content)} bytes, {def_count} defs, {format_class_count} format classes")
    print(f"Total instructions: {def_count - format_class_count}")


if __name__ == "__main__":
    main()
