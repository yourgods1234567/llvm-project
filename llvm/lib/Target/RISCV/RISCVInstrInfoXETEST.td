//===-- RISCVInstrInfoXETEST.td - ETEST Matrix Extension -----*- tablegen -*-===//
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

//===----------------------------------------------------------------------===//
// Configuration Instructions (Section 2: func3=000, uop=00)
//===----------------------------------------------------------------------===//

let func4 = 0b0000 in
def MSETTILEMI : XESWinConfigImmInst<(outs), (ins uimm10:$imm10), "msettilemi", "$imm10"> {
  let rd = 0;
}

let func4 = 0b0001 in
def MSETTILEKI : XESWinConfigImmInst<(outs), (ins uimm10:$imm10), "msettileki", "$imm10"> {
  let rd = 0;
}

let func4 = 0b0010 in
def MSETTILENI : XESWinConfigImmInst<(outs), (ins uimm10:$imm10), "msettileni", "$imm10"> {
  let rd = 0;
}

let func4 = 0b0000 in
def MSETTILEM : XESWinConfigRegInst<(outs), (ins GPR:$rs1), "msettilem", "$rs1"> {
  let rd = 0;
}

let func4 = 0b0001 in
def MSETTILEK : XESWinConfigRegInst<(outs), (ins GPR:$rs1), "msettilek", "$rs1"> {
  let rd = 0;
}

let func4 = 0b0010 in
def MSETTILEN : XESWinConfigRegInst<(outs), (ins GPR:$rs1), "msettilen", "$rs1"> {
  let rd = 0;
}

def MRELEASE : XESWinConfigImmInst<(outs), (ins), "mrelease", ""> {
  let func4 = 0b0011;
  let imm10 = 0;
  let rd = 0;
}

//===----------------------------------------------------------------------===//
// Load Instructions (Section 3: func3=000, uop=01, ls=0)
//===----------------------------------------------------------------------===//

let func4 = 0b0000 in {
  def MLAE8 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlae8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MLAE16 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlae16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MLAE32 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlae32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MLAE64 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlae64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0001 in {
  def MLBE8 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlbe8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MLBE16 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlbe16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MLBE32 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlbe32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MLBE64 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlbe64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0010 in {
  def MLCE8 : XESWinLoadInst<(outs MatrixACC:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlce8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MLCE16 : XESWinLoadInst<(outs MatrixACC:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlce16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MLCE32 : XESWinLoadInst<(outs MatrixACC:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlce32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MLCE64 : XESWinLoadInst<(outs MatrixACC:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlce64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0011 in {
  def MLATE8 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlate8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MLATE16 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlate16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MLATE32 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlate32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MLATE64 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlate64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0100 in {
  def MLBTE8 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlbte8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MLBTE16 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlbte16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MLBTE32 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlbte32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MLBTE64 : XESWinLoadInst<(outs MatrixTR:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlbte64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0101 in {
  def MLCTE8 : XESWinLoadInst<(outs MatrixACC:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlcte8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MLCTE16 : XESWinLoadInst<(outs MatrixACC:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlcte16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MLCTE32 : XESWinLoadInst<(outs MatrixACC:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlcte32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MLCTE64 : XESWinLoadInst<(outs MatrixACC:$md), (ins GPR:$rs2, GPRMemZeroOffset:$rs1), "mlcte64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0110 in {
  def MLME8 : XESWinLoadInst<(outs MatrixMR:$md), (ins GPRMemZeroOffset:$rs1), "mlme8", "$md, $rs1"> {
    let Inst{24-20} = 0;
    let d_size = 0b00;
  }
  def MLME16 : XESWinLoadInst<(outs MatrixMR:$md), (ins GPRMemZeroOffset:$rs1), "mlme16", "$md, $rs1"> {
    let Inst{24-20} = 0;
    let d_size = 0b01;
  }
  def MLME32 : XESWinLoadInst<(outs MatrixMR:$md), (ins GPRMemZeroOffset:$rs1), "mlme32", "$md, $rs1"> {
    let Inst{24-20} = 0;
    let d_size = 0b10;
  }
  def MLME64 : XESWinLoadInst<(outs MatrixMR:$md), (ins GPRMemZeroOffset:$rs1), "mlme64", "$md, $rs1"> {
    let Inst{24-20} = 0;
    let d_size = 0b11;
  }
}

//===----------------------------------------------------------------------===//
// Store Instructions (Section 3: func3=000, uop=01, ls=1)
//===----------------------------------------------------------------------===//

let func4 = 0b0000 in {
  def MSAE8 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msae8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MSAE16 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msae16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MSAE32 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msae32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MSAE64 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msae64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0001 in {
  def MSBE8 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msbe8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MSBE16 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msbe16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MSBE32 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msbe32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MSBE64 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msbe64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0010 in {
  def MSCE8 : XESWinStoreInst<(outs), (ins MatrixACC:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msce8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MSCE16 : XESWinStoreInst<(outs), (ins MatrixACC:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msce16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MSCE32 : XESWinStoreInst<(outs), (ins MatrixACC:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msce32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MSCE64 : XESWinStoreInst<(outs), (ins MatrixACC:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msce64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0011 in {
  def MSATE8 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msate8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MSATE16 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msate16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MSATE32 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msate32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MSATE64 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msate64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0100 in {
  def MSBTE8 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msbte8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MSBTE16 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msbte16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MSBTE32 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msbte32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MSBTE64 : XESWinStoreInst<(outs), (ins MatrixTR:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "msbte64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0101 in {
  def MSCTE8 : XESWinStoreInst<(outs), (ins MatrixACC:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "mscte8", "$md, $rs1, $rs2"> {
    let d_size = 0b00;
  }
  def MSCTE16 : XESWinStoreInst<(outs), (ins MatrixACC:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "mscte16", "$md, $rs1, $rs2"> {
    let d_size = 0b01;
  }
  def MSCTE32 : XESWinStoreInst<(outs), (ins MatrixACC:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "mscte32", "$md, $rs1, $rs2"> {
    let d_size = 0b10;
  }
  def MSCTE64 : XESWinStoreInst<(outs), (ins MatrixACC:$md, GPR:$rs2, GPRMemZeroOffset:$rs1), "mscte64", "$md, $rs1, $rs2"> {
    let d_size = 0b11;
  }
}

let func4 = 0b0110 in {
  def MSME8 : XESWinStoreInst<(outs), (ins MatrixMR:$md, GPRMemZeroOffset:$rs1), "msme8", "$md, $rs1"> {
    let Inst{24-20} = 0;
    let d_size = 0b00;
  }
  def MSME16 : XESWinStoreInst<(outs), (ins MatrixMR:$md, GPRMemZeroOffset:$rs1), "msme16", "$md, $rs1"> {
    let Inst{24-20} = 0;
    let d_size = 0b01;
  }
  def MSME32 : XESWinStoreInst<(outs), (ins MatrixMR:$md, GPRMemZeroOffset:$rs1), "msme32", "$md, $rs1"> {
    let Inst{24-20} = 0;
    let d_size = 0b10;
  }
  def MSME64 : XESWinStoreInst<(outs), (ins MatrixMR:$md, GPRMemZeroOffset:$rs1), "msme64", "$md, $rs1"> {
    let Inst{24-20} = 0;
    let d_size = 0b11;
  }
}

//===----------------------------------------------------------------------===//
// Matrix Multiply-Accumulate Instructions (Section 4: func3=000, uop=10)
//===----------------------------------------------------------------------===//

def MFMACC_H : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.h", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b000;
  let s_size = 0b01;
  let d_size = 0b01;
}

def MFMACC_S : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.s", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b000;
  let s_size = 0b10;
  let d_size = 0b10;
}

def MFMACC_D : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.d", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b000;
  let s_size = 0b11;
  let d_size = 0b11;
}

def MFMACC_H_E4 : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.h.e4", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b010;
  let s_size = 0b00;
  let d_size = 0b01;
}

def MFMACC_H_E5 : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.h.e5", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b000;
  let s_size = 0b00;
  let d_size = 0b01;
}

def MFMACC_BF16_E4 : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.bf16.e4", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b110;
  let s_size = 0b00;
  let d_size = 0b01;
}

def MFMACC_BF16_E5 : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.bf16.e5", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b100;
  let s_size = 0b00;
  let d_size = 0b01;
}

def MFMACC_S_H : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.s.h", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b000;
  let s_size = 0b01;
  let d_size = 0b10;
}

def MFMACC_S_BF16 : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.s.bf16", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b100;
  let s_size = 0b01;
  let d_size = 0b10;
}

def MFMACC_D_S : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.d.s", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b000;
  let s_size = 0b10;
  let d_size = 0b11;
}

def MFMACC_S_E4 : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.s.e4", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b010;
  let s_size = 0b00;
  let d_size = 0b10;
}

def MFMACC_S_E5 : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mfmacc.s.e5", "$md, $ms1, $ms2"> {
  let func4 = 0b0000;
  let size_sup = 0b000;
  let s_size = 0b00;
  let d_size = 0b10;
}

def MMACC_W_B : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mmacc.w.b", "$md, $ms1, $ms2"> {
  let func4 = 0b0001;
  let size_sup = 0b000;
  let s_size = 0b00;
  let d_size = 0b10;
}

def MMACCU_W_B : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mmaccu.w.b", "$md, $ms1, $ms2"> {
  let func4 = 0b0001;
  let size_sup = 0b100;
  let s_size = 0b00;
  let d_size = 0b10;
}

def MMACCSU_W_B : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mmaccsu.w.b", "$md, $ms1, $ms2"> {
  let func4 = 0b0001;
  let size_sup = 0b010;
  let s_size = 0b00;
  let d_size = 0b10;
}

def MMACCUS_W_B : XESWinMACInst<(outs MatrixACC:$md), (ins MatrixTR:$ms1, MatrixTR:$ms2),
                            "mmaccus.w.b", "$md, $ms1, $ms2"> {
  let func4 = 0b0001;
  let size_sup = 0b110;
  let s_size = 0b00;
  let d_size = 0b10;
}

//===----------------------------------------------------------------------===//
// MISC Instructions (Section 5: func3=000, uop=11)
//===----------------------------------------------------------------------===//

// --- Mzero (Section 5.2) ---
let func4 = 0b0000, uop = 0b11, func3 = 0b000, ms2 = 0b000, s_size = 0b00, ms1 = 0b000, d_size = 0b00 in {
  def MZERO1R : XESWinBaseInst<(outs MatrixMR:$md), (ins), "mzero", "$md"> { let imm3 = 0b000; }
  def MZERO2R : XESWinBaseInst<(outs MatrixMR:$md), (ins), "mzero2r", "$md"> { let imm3 = 0b001; }
  def MZERO4R : XESWinBaseInst<(outs MatrixMR:$md), (ins), "mzero4r", "$md"> { let imm3 = 0b011; }
  def MZERO8R : XESWinBaseInst<(outs MatrixMR:$md), (ins), "mzero8r", "$md"> { let imm3 = 0b111; }
}

// --- Data Move (Section 5.3) ---
// mmov.mm - matrix to matrix copy
let func4 = 0b0001, uop = 0b11, func3 = 0b000, s_size = 0b00, ms2 = 0b000, d_size = 0b00 in
def MMOV_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mmov.mm", "$md, $ms1"> {
  let imm3 = 0b111;
}

// mmov<b/h/w/d>.x.m - matrix element to GPR (format 2)
def MMOV_B_X_M : XESWinMovXMInst<(outs GPR:$rd), (ins MatrixMR:$ms2, GPR:$rs1),
                                     "mmovb.x.m", "$rd, $ms2, $rs1"> {
  let func4 = 0b0010;
  let ctrl = 0;
  let e_size = 0b00;
}

def MMOV_H_X_M : XESWinMovXMInst<(outs GPR:$rd), (ins MatrixMR:$ms2, GPR:$rs1),
                                     "mmovh.x.m", "$rd, $ms2, $rs1"> {
  let func4 = 0b0010;
  let ctrl = 0;
  let e_size = 0b01;
}

def MMOV_W_X_M : XESWinMovXMInst<(outs GPR:$rd), (ins MatrixMR:$ms2, GPR:$rs1),
                                     "mmovw.x.m", "$rd, $ms2, $rs1"> {
  let func4 = 0b0010;
  let ctrl = 0;
  let e_size = 0b10;
}

def MMOV_D_X_M : XESWinMovXMInst<(outs GPR:$rd), (ins MatrixMR:$ms2, GPR:$rs1),
                                     "mmovd.x.m", "$rd, $ms2, $rs1"> {
  let func4 = 0b0010;
  let ctrl = 0;
  let e_size = 0b11;
}

// mmov<b/h/w/d>.m.x - GPR to matrix element (format 3)
def MMOV_B_M_X : XESWinMovMXInst<(outs MatrixMR:$md), (ins GPR:$rs2, GPR:$rs1),
                                     "mmovb.m.x", "$md, $rs2, $rs1"> {
  let func4 = 0b0011;
  let ctrl = 1;
  let d_size = 0b00;
}

def MMOV_H_M_X : XESWinMovMXInst<(outs MatrixMR:$md), (ins GPR:$rs2, GPR:$rs1),
                                     "mmovh.m.x", "$md, $rs2, $rs1"> {
  let func4 = 0b0011;
  let ctrl = 1;
  let d_size = 0b01;
}

def MMOV_W_M_X : XESWinMovMXInst<(outs MatrixMR:$md), (ins GPR:$rs2, GPR:$rs1),
                                     "mmovw.m.x", "$md, $rs2, $rs1"> {
  let func4 = 0b0011;
  let ctrl = 1;
  let d_size = 0b10;
}

def MMOV_D_M_X : XESWinMovMXInst<(outs MatrixMR:$md), (ins GPR:$rs2, GPR:$rs1),
                                     "mmovd.m.x", "$md, $rs2, $rs1"> {
  let func4 = 0b0011;
  let ctrl = 1;
  let d_size = 0b11;
}

// --- Broadcast <8/16/32/64> (Section 5.4) ---
// mbce<8/16/32/64> md, ms1[0]
let func4 = 0b0100, uop = 0b11, func3 = 0b000, s_size = 0b00, ms2 = 0b000, d_size = 0b00 in {
  def MBCE8 : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mbce8", "$md, $ms1"> { let imm3 = 0b000; }
  def MBCE16 : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mbce16", "$md, $ms1"> { let imm3 = 0b001; }
  def MBCE32 : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mbce32", "$md, $ms1"> { let imm3 = 0b010; }
  def MBCE64 : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mbce64", "$md, $ms1"> { let imm3 = 0b011; }
}

let func4 = 0b0101, uop = 0b11, func3 = 0b000, s_size = 0b00, ms2 = 0b000, d_size = 0b00 in
def MRBC_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                               "mrbc.mv.i", "$md, $ms1[$imm3]">;

let func4 = 0b0110, uop = 0b11, func3 = 0b000, s_size = 0b00, ms2 = 0b000 in {
  def MCBCE8_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                                     "mcbce8.mv.i", "$md, $ms1[$imm3]"> { let d_size = 0b00; }
  def MCBCE16_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                                     "mcbce16.mv.i", "$md, $ms1[$imm3]"> { let d_size = 0b01; }
  def MCBCE32_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                                     "mcbce32.mv.i", "$md, $ms1[$imm3]"> { let d_size = 0b10; }
  def MCBCE64_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                                     "mcbce64.mv.i", "$md, $ms1[$imm3]"> { let d_size = 0b11; }
}

// --- Pack (Section 5.5) ---
let func4 = 0b1000, uop = 0b11, func3 = 0b000, s_size = 0b00, d_size = 0b00 in
def MPACK_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                             "mpack.mm", "$md, $ms1, $ms2"> { let imm3 = 0b111; }

let func4 = 0b1001, uop = 0b11, func3 = 0b000, s_size = 0b00, d_size = 0b00 in
def MPACKHL_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                             "mpackhl.mm", "$md, $ms1, $ms2"> { let imm3 = 0b111; }

let func4 = 0b1010, uop = 0b11, func3 = 0b000, s_size = 0b00, d_size = 0b00 in
def MPACKHH_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                             "mpackhh.mm", "$md, $ms1, $ms2"> { let imm3 = 0b111; }

// --- Slide (Section 5.6) ---
let func4 = 0b1011, uop = 0b11, func3 = 0b000, ms2 = 0b000, d_size = 0b00, s_size = 0b00 in
def MRSLIDEDOWN : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                    "mrslidedown", "$md, $ms1, $imm3">;

let func4 = 0b1100, uop = 0b11, func3 = 0b000, ms2 = 0b000, d_size = 0b00, s_size = 0b00 in
def MRSLIDEUP : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                    "mrslideup", "$md, $ms1, $imm3">;

let func4 = 0b1101, uop = 0b11, func3 = 0b000, ms2 = 0b000 in {
  def MCSLIDEDOWN_B : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                     "mcslidedown.b", "$md, $ms1, $imm3"> {
    let d_size = 0b00;
    let s_size = 0b00;
  }
  def MCSLIDEDOWN_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                     "mcslidedown.h", "$md, $ms1, $imm3"> {
    let d_size = 0b01;
    let s_size = 0b01;
  }
  def MCSLIDEDOWN_W : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                     "mcslidedown.w", "$md, $ms1, $imm3"> {
    let d_size = 0b10;
    let s_size = 0b10;
  }
  def MCSLIDEDOWN_D : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                     "mcslidedown.d", "$md, $ms1, $imm3"> {
    let d_size = 0b11;
    let s_size = 0b11;
  }
}

let func4 = 0b1110, uop = 0b11, func3 = 0b000, ms2 = 0b000 in {
  def MCSLIDEUP_B : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                     "mcslideup.b", "$md, $ms1, $imm3"> {
    let d_size = 0b00;
    let s_size = 0b00;
  }
  def MCSLIDEUP_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                     "mcslideup.h", "$md, $ms1, $imm3"> {
    let d_size = 0b01;
    let s_size = 0b01;
  }
  def MCSLIDEUP_W : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                     "mcslideup.w", "$md, $ms1, $imm3"> {
    let d_size = 0b10;
    let s_size = 0b10;
  }
  def MCSLIDEUP_D : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, uimm3:$imm3),
                     "mcslideup.d", "$md, $ms1, $imm3"> {
    let d_size = 0b11;
    let s_size = 0b11;
  }
}

//===----------------------------------------------------------------------===//
// Element-wise Type Conversion Instructions (Section 6.2: func3=001, uop=00)
//===----------------------------------------------------------------------===//

// --- Floating-point conversions (func4=0000) ---
let func4 = 0b0000, func3 = 0b001, uop = 0b00, ms2 = 0b000 in {
  def MFCVTL_H_E4 : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.h.e4", "$md, $ms1"> {
    let imm3 = 0b000; let d_size = 0b01; let s_size = 0b00;
  }
  def MFCVTH_H_E4 : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.h.e4", "$md, $ms1"> {
    let imm3 = 0b001; let d_size = 0b01; let s_size = 0b00;
  }
  def MFCVTL_H_E5 : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.h.e5", "$md, $ms1"> {
    let imm3 = 0b010; let d_size = 0b01; let s_size = 0b00;
  }
  def MFCVTH_H_E5 : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.h.e5", "$md, $ms1"> {
    let imm3 = 0b011; let d_size = 0b01; let s_size = 0b00;
  }
  def MFCVTL_S_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.s.h", "$md, $ms1"> {
    let imm3 = 0b100; let d_size = 0b10; let s_size = 0b01;
  }
  def MFCVTH_S_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.s.h", "$md, $ms1"> {
    let imm3 = 0b101; let d_size = 0b10; let s_size = 0b01;
  }
  def MFCVTL_S_BF16 : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.s.bf16", "$md, $ms1"> {
    let imm3 = 0b110; let d_size = 0b10; let s_size = 0b01;
  }
  def MFCVTH_S_BF16 : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.s.bf16", "$md, $ms1"> {
    let imm3 = 0b111; let d_size = 0b10; let s_size = 0b01;
  }
}

let func4 = 0b0000, func3 = 0b001, uop = 0b00, ms2 = 0b000 in {
  def MFCVTL_D_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.d.s", "$md, $ms1"> {
    let imm3 = 0b000; let d_size = 0b11; let s_size = 0b10;
  }
  def MFCVTH_D_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.d.s", "$md, $ms1"> {
    let imm3 = 0b001; let d_size = 0b11; let s_size = 0b10;
  }
  def MFCVTL_E4_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.e4.h", "$md, $ms1"> {
    let imm3 = 0b010; let d_size = 0b00; let s_size = 0b01;
  }
  def MFCVTH_E4_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.e4.h", "$md, $ms1"> {
    let imm3 = 0b011; let d_size = 0b00; let s_size = 0b01;
  }
  def MFCVTL_E5_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.e5.h", "$md, $ms1"> {
    let imm3 = 0b100; let d_size = 0b00; let s_size = 0b01;
  }
  def MFCVTH_E5_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.e5.h", "$md, $ms1"> {
    let imm3 = 0b101; let d_size = 0b00; let s_size = 0b01;
  }
  def MFCVTL_H_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.h.s", "$md, $ms1"> {
    let imm3 = 0b110; let d_size = 0b01; let s_size = 0b10;
  }
  def MFCVTH_H_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.h.s", "$md, $ms1"> {
    let imm3 = 0b111; let d_size = 0b01; let s_size = 0b10;
  }
}

let func4 = 0b0000, func3 = 0b001, uop = 0b00, ms2 = 0b000 in {
  def MFCVTL_BF16_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.bf16.s", "$md, $ms1"> {
    let imm3 = 0b000; let d_size = 0b01; let s_size = 0b10;
  }
  def MFCVTH_BF16_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.bf16.s", "$md, $ms1"> {
    let imm3 = 0b001; let d_size = 0b01; let s_size = 0b10;
  }
  def MFCVTL_S_D : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.s.d", "$md, $ms1"> {
    let imm3 = 0b010; let d_size = 0b10; let s_size = 0b11;
  }
  def MFCVTH_S_D : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.s.d", "$md, $ms1"> {
    let imm3 = 0b011; let d_size = 0b10; let s_size = 0b11;
  }
  def MFCVTL_E4_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.e4.s", "$md, $ms1"> {
    let imm3 = 0b100; let d_size = 0b00; let s_size = 0b10;
  }
  def MFCVTH_E4_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.e4.s", "$md, $ms1"> {
    let imm3 = 0b101; let d_size = 0b00; let s_size = 0b10;
  }
  def MFCVTL_E5_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvtl.e5.s", "$md, $ms1"> {
    let imm3 = 0b110; let d_size = 0b00; let s_size = 0b10;
  }
  def MFCVTH_E5_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfcvth.e5.s", "$md, $ms1"> {
    let imm3 = 0b111; let d_size = 0b00; let s_size = 0b10;
  }
}

// --- Float-Integer conversions (func4=0001) ---
let func4 = 0b0001, func3 = 0b001, uop = 0b00, ms2 = 0b000 in {
  def MUFCVTL_H_B : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mufcvtl.h.b", "$md, $ms1"> {
    let imm3 = 0b000; let d_size = 0b01; let s_size = 0b00;
  }
  def MUFCTVH_H_B : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mufcvth.h.b", "$md, $ms1"> {
    let imm3 = 0b001; let d_size = 0b01; let s_size = 0b00;
  }
  def MSFCVTL_H_B : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "msfcvtl.h.b", "$md, $ms1"> {
    let imm3 = 0b010; let d_size = 0b01; let s_size = 0b00;
  }
  def MSFCVTH_H_B : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "msfcvth.h.b", "$md, $ms1"> {
    let imm3 = 0b011; let d_size = 0b01; let s_size = 0b00;
  }
}

let func4 = 0b0001, func3 = 0b001, uop = 0b00, ms2 = 0b000 in {
  def MUFCVT_S_W : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mufcvt.s.w", "$md, $ms1"> {
    let imm3 = 0b100; let d_size = 0b10; let s_size = 0b10;
  }
  def MSFCVT_S_W : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "msfcvt.s.w", "$md, $ms1"> {
    let imm3 = 0b101; let d_size = 0b10; let s_size = 0b10;
  }
  def MFUCVTL_B_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfucvtl.b.h", "$md, $ms1"> {
    let imm3 = 0b110; let d_size = 0b00; let s_size = 0b01;
  }
  def MFUCVTH_B_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfucvth.b.h", "$md, $ms1"> {
    let imm3 = 0b111; let d_size = 0b00; let s_size = 0b01;
  }
}

let func4 = 0b0001, func3 = 0b001, uop = 0b00, ms2 = 0b000 in {
  def MFSCVTL_B_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfscvtl.b.h", "$md, $ms1"> {
    let imm3 = 0b000; let d_size = 0b00; let s_size = 0b01;
  }
  def MFSCVTH_B_H : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfscvth.b.h", "$md, $ms1"> {
    let imm3 = 0b001; let d_size = 0b00; let s_size = 0b01;
  }
  def MFUCVT_W_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfucvt.w.s", "$md, $ms1"> {
    let imm3 = 0b010; let d_size = 0b10; let s_size = 0b10;
  }
  def MFSCVT_W_S : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mfscvt.w.s", "$md, $ms1"> {
    let imm3 = 0b011; let d_size = 0b10; let s_size = 0b10;
  }
}

// --- Fixed-point clip (func4=0010-0101) ---
let func4 = 0b0010, func3 = 0b001, uop = 0b00 in
def MN4CLIPL_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                             "mn4clipl.w.mm", "$md, $ms1, $ms2"> {
  let imm3 = 0b111; let d_size = 0b00; let s_size = 0b10;
}

let func4 = 0b0011, func3 = 0b001, uop = 0b00 in
def MN4CLIPH_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                             "mn4cliph.w.mm", "$md, $ms1, $ms2"> {
  let imm3 = 0b111; let d_size = 0b00; let s_size = 0b10;
}

let func4 = 0b0100, func3 = 0b001, uop = 0b00 in
def MN4CLIPLU_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                             "mn4cliplu.w.mm", "$md, $ms1, $ms2"> {
  let imm3 = 0b111; let d_size = 0b00; let s_size = 0b10;
}

let func4 = 0b0101, func3 = 0b001, uop = 0b00 in
def MN4CLIPHU_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                             "mn4cliphu.w.mm", "$md, $ms1, $ms2"> {
  let imm3 = 0b111; let d_size = 0b00; let s_size = 0b10;
}

let func4 = 0b0010, func3 = 0b001, uop = 0b00, d_size = 0b00, s_size = 0b10 in
def MN4CLIPL_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                             "mn4clipl.w.mv.i", "$md, $ms2, $ms1[$imm3]">;

let func4 = 0b0011, func3 = 0b001, uop = 0b00, d_size = 0b00, s_size = 0b10 in
def MN4CLIPH_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                             "mn4cliph.w.mv.i", "$md, $ms2, $ms1[$imm3]">;

let func4 = 0b0100, func3 = 0b001, uop = 0b00, d_size = 0b00, s_size = 0b10 in
def MN4CLIPLU_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                             "mn4cliplu.w.mv.i", "$md, $ms2, $ms1[$imm3]">;

let func4 = 0b0101, func3 = 0b001, uop = 0b00, d_size = 0b00, s_size = 0b10 in
def MN4CLIPHU_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                             "mn4cliphu.w.mv.i", "$md, $ms2, $ms1[$imm3]">;

// --- Int4 conversions (func4=0110) ---
let func4 = 0b0110, func3 = 0b001, uop = 0b00, ms2 = 0b000 in {
  def MSCVTL_W_B_Q : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mscvtl.w.b.q", "$md, $ms1"> {
    let imm3 = 0b000; let d_size = 0b10; let s_size = 0b00;
  }
  def MSCVTH_W_B_Q : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mscvth.w.b.q", "$md, $ms1"> {
    let imm3 = 0b001; let d_size = 0b10; let s_size = 0b00;
  }
  def MUCVTL_W_B_Q : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mucvtl.w.b.q", "$md, $ms1"> {
    let imm3 = 0b010; let d_size = 0b10; let s_size = 0b00;
  }
  def MUCVTH_W_B_Q : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1), "mucvth.w.b.q", "$md, $ms1"> {
    let imm3 = 0b011; let d_size = 0b10; let s_size = 0b00;
  }
}

//===----------------------------------------------------------------------===//
// Element-wise Integer Arithmetic (Section 6.3: func3=001, uop=01, d_size=s_size=0b10)
//===----------------------------------------------------------------------===//

let func3 = 0b001, uop = 0b01, d_size = 0b10, s_size = 0b10 in {
  def MADD_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                               "madd.w.mm", "$md, $ms1, $ms2"> {
    let func4 = 0b0000; let imm3 = 0b111;
  }
  def MSUB_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                               "msub.w.mm", "$md, $ms1, $ms2"> {
    let func4 = 0b0001; let imm3 = 0b111;
  }
  def MMUL_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                               "mmul.w.mm", "$md, $ms1, $ms2"> {
    let func4 = 0b0010; let imm3 = 0b111;
  }
  def MMULH_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                               "mmulh.w.mm", "$md, $ms1, $ms2"> {
    let func4 = 0b0011; let imm3 = 0b111;
  }
  def MMAX_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                               "mmax.w.mm", "$md, $ms1, $ms2"> {
    let func4 = 0b0100; let imm3 = 0b111;
  }
  def MUMAX_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                               "mumax.w.mm", "$md, $ms1, $ms2"> {
    let func4 = 0b0101; let imm3 = 0b111;
  }
  def MMIN_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                               "mmin.w.mm", "$md, $ms1, $ms2"> {
    let func4 = 0b0110; let imm3 = 0b111;
  }
  def MUMIN_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                               "mumin.w.mm", "$md, $ms1, $ms2"> {
    let func4 = 0b0111; let imm3 = 0b111;
  }
  def MSLL_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                               "msll.w.mm", "$md, $ms1, $ms2"> {
    let func4 = 0b1000; let imm3 = 0b111;
  }
  def MSRL_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                               "msrl.w.mm", "$md, $ms1, $ms2"> {
    let func4 = 0b1001; let imm3 = 0b111;
  }
  def MSRA_W_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                               "msra.w.mm", "$md, $ms1, $ms2"> {
    let func4 = 0b1010; let imm3 = 0b111;
  }
}

let func3 = 0b001, uop = 0b01, d_size = 0b10, s_size = 0b10 in {
  def MADD_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                               "madd.w.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let func4 = 0b0000;
  }
  def MSUB_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                               "msub.w.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let func4 = 0b0001;
  }
  def MMUL_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                               "mmul.w.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let func4 = 0b0010;
  }
  def MMULH_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                               "mmulh.w.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let func4 = 0b0011;
  }
  def MMAX_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                               "mmax.w.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let func4 = 0b0100;
  }
  def MUMAX_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                               "mumax.w.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let func4 = 0b0101;
  }
  def MMIN_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                               "mmin.w.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let func4 = 0b0110;
  }
  def MUMIN_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                               "mumin.w.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let func4 = 0b0111;
  }
  def MSLL_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                               "msll.w.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let func4 = 0b1000;
  }
  def MSRL_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                               "msrl.w.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let func4 = 0b1001;
  }
  def MSRA_W_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                               "msra.w.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let func4 = 0b1010;
  }
}

//===----------------------------------------------------------------------===//
// Element-wise Floating-Point Arithmetic (Section 6.4: func3=001, uop=10)
//===----------------------------------------------------------------------===//

let func4 = 0b0000, func3 = 0b001, uop = 0b10 in {
  def MFADD_H_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfadd.h.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b01; let s_size = 0b01;
  }
  def MFADD_S_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfadd.s.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b10; let s_size = 0b10;
  }
  def MFADD_D_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfadd.d.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b11; let s_size = 0b11;
  }
}

let func4 = 0b0000, func3 = 0b001, uop = 0b10 in {
  def MFADD_H_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfadd.h.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b01; let s_size = 0b01;
  }
  def MFADD_S_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfadd.s.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b10; let s_size = 0b10;
  }
  def MFADD_D_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfadd.d.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b11; let s_size = 0b11;
  }
}

let func4 = 0b0001, func3 = 0b001, uop = 0b10 in {
  def MFSUB_H_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfsub.h.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b01; let s_size = 0b01;
  }
  def MFSUB_S_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfsub.s.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b10; let s_size = 0b10;
  }
  def MFSUB_D_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfsub.d.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b11; let s_size = 0b11;
  }
}

let func4 = 0b0001, func3 = 0b001, uop = 0b10 in {
  def MFSUB_H_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfsub.h.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b01; let s_size = 0b01;
  }
  def MFSUB_S_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfsub.s.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b10; let s_size = 0b10;
  }
  def MFSUB_D_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfsub.d.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b11; let s_size = 0b11;
  }
}

let func4 = 0b0010, func3 = 0b001, uop = 0b10 in {
  def MFMUL_H_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfmul.h.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b01; let s_size = 0b01;
  }
  def MFMUL_S_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfmul.s.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b10; let s_size = 0b10;
  }
  def MFMUL_D_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfmul.d.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b11; let s_size = 0b11;
  }
}

let func4 = 0b0010, func3 = 0b001, uop = 0b10 in {
  def MFMUL_H_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfmul.h.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b01; let s_size = 0b01;
  }
  def MFMUL_S_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfmul.s.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b10; let s_size = 0b10;
  }
  def MFMUL_D_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfmul.d.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b11; let s_size = 0b11;
  }
}

let func4 = 0b0011, func3 = 0b001, uop = 0b10 in {
  def MFMAX_H_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfmax.h.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b01; let s_size = 0b01;
  }
  def MFMAX_S_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfmax.s.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b10; let s_size = 0b10;
  }
  def MFMAX_D_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfmax.d.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b11; let s_size = 0b11;
  }
}

let func4 = 0b0011, func3 = 0b001, uop = 0b10 in {
  def MFMAX_H_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfmax.h.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b01; let s_size = 0b01;
  }
  def MFMAX_S_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfmax.s.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b10; let s_size = 0b10;
  }
  def MFMAX_D_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfmax.d.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b11; let s_size = 0b11;
  }
}

let func4 = 0b0100, func3 = 0b001, uop = 0b10 in {
  def MFMIN_H_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfmin.h.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b01; let s_size = 0b01;
  }
  def MFMIN_S_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfmin.s.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b10; let s_size = 0b10;
  }
  def MFMIN_D_MM : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2),
                       "mfmin.d.mm", "$md, $ms1, $ms2"> {
    let imm3 = 0b111; let d_size = 0b11; let s_size = 0b11;
  }
}

let func4 = 0b0100, func3 = 0b001, uop = 0b10 in {
  def MFMIN_H_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfmin.h.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b01; let s_size = 0b01;
  }
  def MFMIN_S_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfmin.s.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b10; let s_size = 0b10;
  }
  def MFMIN_D_MV_I : XESWinBaseInst<(outs MatrixMR:$md), (ins MatrixMR:$ms1, MatrixMR:$ms2, uimm3:$imm3),
                         "mfmin.d.mv.i", "$md, $ms2, $ms1[$imm3]"> {
    let d_size = 0b11; let s_size = 0b11;
  }
}

} // Predicates = [HasVendorXETESTMatrix]
} // DecoderNamespace = "XETEST"
