(*
 * WARNING: This file was automatically generated by MDLGen (v3.0)
 * from the machine description file "amd64/amd64.mdl".
 * DO NOT EDIT this file directly
 *)


functor AMD64MCEmitter(structure Instr : AMD64INSTR
                       structure MLTreeEval : MLTREE_EVAL where T = Instr.T
                       structure Stream : INSTRUCTION_STREAM 
                       structure CodeString : CODE_STRING
                      ) : INSTRUCTION_EMITTER =
struct
   structure I = Instr
   structure C = I.C
   structure Constant = I.Constant
   structure T = I.T
   structure S = Stream
   structure P = S.P
   structure W = Word32
   
   (* AMD64 is little endian *)
   
   fun error msg = MLRiscErrorMsg.error("AMD64MC",msg)
   fun makeStream _ =
   let infix && || << >> ~>>
       val op << = W.<<
       val op >> = W.>>
       val op ~>> = W.~>>
       val op || = W.orb
       val op && = W.andb
       val itow = W.fromInt
       fun emit_bool false = 0w0 : W.word
         | emit_bool true = 0w1 : W.word
       val emit_int = itow
       fun emit_word w = w
       fun emit_label l = itow(Label.addrOf l)
       fun emit_labexp le = itow(MLTreeEval.valueOf le)
       fun emit_const c = itow(Constant.valueOf c)
       val loc = ref 0
   
       (* emit a byte *)
       fun eByte b =
       let val i = !loc in loc := i + 1; CodeString.update(i,b) end
   
       (* emit the low order byte of a word *)
       (* note: fromLargeWord strips the high order bits! *)
       fun eByteW w =
       let val i = !loc
       in loc := i + 1; CodeString.update(i,Word8.fromLargeWord w) end
   
       fun doNothing _ = ()
       fun fail _ = raise Fail "MCEmitter"
       fun getAnnotations () = error "getAnnotations"
   
       fun pseudoOp pOp = P.emitValue{pOp=pOp, loc= !loc,emit=eByte}
   
       fun init n = (CodeString.init n; loc := 0)
   
   
   fun eWord8 w = 
       let val b8 = w
       in eByteW b8
       end
   and eWord16 w = 
       let val b8 = w
           val w = w >> 0wx8
           val b16 = w
       in 
          ( eByteW b8; 
            eByteW b16 )
       end
   and eWord32 w = 
       let val b8 = w
           val w = w >> 0wx8
           val b16 = w
           val w = w >> 0wx8
           val b24 = w
           val w = w >> 0wx8
           val b32 = w
       in 
          ( eByteW b8; 
            eByteW b16; 
            eByteW b24; 
            eByteW b32 )
       end
   fun emit_GP r = itow (CellsBasis.physicalRegisterNum r)
   and emit_FP r = itow (CellsBasis.physicalRegisterNum r)
   and emit_CC r = itow (CellsBasis.physicalRegisterNum r)
   and emit_EFLAGS r = itow (CellsBasis.physicalRegisterNum r)
   and emit_FFLAGS r = itow (CellsBasis.physicalRegisterNum r)
   and emit_MEM r = itow (CellsBasis.physicalRegisterNum r)
   and emit_CTRL r = itow (CellsBasis.physicalRegisterNum r)
   and emit_CELLSET r = itow (CellsBasis.physicalRegisterNum r)
   fun emit_cond (I.EQ) = (0wx4 : Word32.word)
     | emit_cond (I.NE) = (0wx5 : Word32.word)
     | emit_cond (I.LT) = (0wxC : Word32.word)
     | emit_cond (I.LE) = (0wxE : Word32.word)
     | emit_cond (I.GT) = (0wxF : Word32.word)
     | emit_cond (I.GE) = (0wxD : Word32.word)
     | emit_cond (I.B) = (0wx2 : Word32.word)
     | emit_cond (I.BE) = (0wx6 : Word32.word)
     | emit_cond (I.A) = (0wx7 : Word32.word)
     | emit_cond (I.AE) = (0wx3 : Word32.word)
     | emit_cond (I.C) = (0wx2 : Word32.word)
     | emit_cond (I.NC) = (0wx3 : Word32.word)
     | emit_cond (I.P) = (0wxA : Word32.word)
     | emit_cond (I.NP) = (0wxB : Word32.word)
     | emit_cond (I.O) = (0wx0 : Word32.word)
     | emit_cond (I.NO) = (0wx1 : Word32.word)
   and emit_fibinOp (I.FIADDS) = (0wxDE, 0)
     | emit_fibinOp (I.FIMULS) = (0wxDE, 1)
     | emit_fibinOp (I.FICOMS) = (0wxDE, 2)
     | emit_fibinOp (I.FICOMPS) = (0wxDE, 3)
     | emit_fibinOp (I.FISUBS) = (0wxDE, 4)
     | emit_fibinOp (I.FISUBRS) = (0wxDE, 5)
     | emit_fibinOp (I.FIDIVS) = (0wxDE, 6)
     | emit_fibinOp (I.FIDIVRS) = (0wxDE, 7)
     | emit_fibinOp (I.FIADDL) = (0wxDA, 0)
     | emit_fibinOp (I.FIMULL) = (0wxDA, 1)
     | emit_fibinOp (I.FICOML) = (0wxDA, 2)
     | emit_fibinOp (I.FICOMPL) = (0wxDA, 3)
     | emit_fibinOp (I.FISUBL) = (0wxDA, 4)
     | emit_fibinOp (I.FISUBRL) = (0wxDA, 5)
     | emit_fibinOp (I.FIDIVL) = (0wxDA, 6)
     | emit_fibinOp (I.FIDIVRL) = (0wxDA, 7)
   and emit_funOp (I.FCHS) = (0wxE0 : Word32.word)
     | emit_funOp (I.FABS) = (0wxE1 : Word32.word)
     | emit_funOp (I.FTST) = (0wxE4 : Word32.word)
     | emit_funOp (I.FXAM) = (0wxE5 : Word32.word)
     | emit_funOp (I.FPTAN) = (0wxF2 : Word32.word)
     | emit_funOp (I.FPATAN) = (0wxF3 : Word32.word)
     | emit_funOp (I.FXTRACT) = (0wxF4 : Word32.word)
     | emit_funOp (I.FPREM1) = (0wxF5 : Word32.word)
     | emit_funOp (I.FDECSTP) = (0wxF6 : Word32.word)
     | emit_funOp (I.FINCSTP) = (0wxF7 : Word32.word)
     | emit_funOp (I.FPREM) = (0wxF8 : Word32.word)
     | emit_funOp (I.FYL2XP1) = (0wxF9 : Word32.word)
     | emit_funOp (I.FSQRT) = (0wxFA : Word32.word)
     | emit_funOp (I.FSINCOS) = (0wxFB : Word32.word)
     | emit_funOp (I.FRNDINT) = (0wxFC : Word32.word)
     | emit_funOp (I.FSCALE) = (0wxFD : Word32.word)
     | emit_funOp (I.FSIN) = (0wxFE : Word32.word)
     | emit_funOp (I.FCOS) = (0wxFF : Word32.word)
   fun modrm {mod, reg, rm} = eWord8 ((op mod << 0wx6) + ((reg << 0wx3) + rm))
   and reg {opc, reg} = eWord8 ((opc << 0wx3) + reg)
   and sib {ss, index, base} = eWord8 ((ss << 0wx6) + ((index << 0wx3) + base))
   and immed8 {imm} = eWord8 imm
   and immed32 {imm} = eWord32 imm
   and immedOpnd {opnd} = 
       (case opnd of
         I.Immed i32 => i32
       | I.ImmedLabel le => lexp le
       | I.LabelEA le => lexp le
       | _ => error "immedOpnd"
       )
   and extension {opc, opnd} = 
       (case opnd of
         I.Direct(_, r) => modrm {mod=3, reg=opc, rm=r}
       | I.FDirect _ => extension {opc=opc, opnd=memReg opnd}
       | I.Displace{base, disp, ...} => 
         let 
(*#line 523.13 "amd64/amd64.mdl"*)
             val immed = immedOpnd {opnd=disp}
         in ()
         end
       | I.Indexed{base=NONE, index, scale, disp, ...} => ()
       | I.Indexed{base=SOME b, index, scale, disp, ...} => ()
       | _ => error "immedExt"
       )
   and encodeST {prefix, opc, st} = 
       let val st = emit_FP st
       in eWord16 ((prefix << 0wx8) + ((opc << 0wx3) + st))
       end
   and encodeReg {prefix, reg, opnd} = 
       let val reg = emit_GP reg
       in 
          ( emit prefix; 
            immedExt {opc=reg, opnd=opnd})
       end
   and arith {opc1, opc2, src, dst} = 
       (case (src, dst) of
         (I.ImmedLabel le, dst) => arith {opc1=opc1, opc2=opc2, src=I.Immed (lexp le), 
            dst=dst}
       | (I.LabelEA le, dst) => arith {opc1=opc1, opc2=opc2, src=I.Immed (lexp le), 
            dst=dst}
       | (I.Immed i, dst) => ()
       | (src, I.Direct(_, r)) => encodeReg {prefix=opc1 + op3, reg=reg, opnd=src}
       | (I.Direct(_, r), dst) => encodeReg {prefix=opc1 + 0wx1, reg=reg, opnd=dst}
       | _ => error "arith"
       )
       fun emitter instr =
       let
   fun emitInstr (I.NOP) = error "NOP"
     | emitInstr (I.JMP(operand, list)) = error "JMP"
     | emitInstr (I.JCC{cond, opnd}) = error "JCC"
     | emitInstr (I.CALL{opnd, defs, uses, return, cutsTo, mem, pops}) = error "CALL"
     | emitInstr (I.CALLQ{opnd, defs, uses, return, cutsTo, mem, pops}) = error "CALLQ"
     | emitInstr (I.ENTER{src1, src2}) = error "ENTER"
     | emitInstr (I.LEAVE) = error "LEAVE"
     | emitInstr (I.RET option) = error "RET"
     | emitInstr (I.MOVE{mvOp, src, dst}) = error "MOVE"
     | emitInstr (I.LEA{r32, addr}) = error "LEA"
     | emitInstr (I.LEAQ{r64, addr}) = error "LEAQ"
     | emitInstr (I.CMPQ{lsrc, rsrc}) = error "CMPQ"
     | emitInstr (I.CMPL{lsrc, rsrc}) = error "CMPL"
     | emitInstr (I.CMPW{lsrc, rsrc}) = error "CMPW"
     | emitInstr (I.CMPB{lsrc, rsrc}) = error "CMPB"
     | emitInstr (I.TESTQ{lsrc, rsrc}) = error "TESTQ"
     | emitInstr (I.TESTL{lsrc, rsrc}) = error "TESTL"
     | emitInstr (I.TESTW{lsrc, rsrc}) = error "TESTW"
     | emitInstr (I.TESTB{lsrc, rsrc}) = error "TESTB"
     | emitInstr (I.BITOP{bitOp, lsrc, rsrc}) = error "BITOP"
     | emitInstr (I.BINARY{binOp, src, dst}) = error "BINARY"
     | emitInstr (I.SHIFT{shiftOp, src, dst, count}) = error "SHIFT"
     | emitInstr (I.CMPXCHG{lock, sz, src, dst}) = error "CMPXCHG"
     | emitInstr (I.MULTDIV{multDivOp, src}) = error "MULTDIV"
     | emitInstr (I.MUL3{dst, src2, src1}) = error "MUL3"
     | emitInstr (I.MULQ3{dst, src2, src1}) = error "MULQ3"
     | emitInstr (I.UNARY{unOp, opnd}) = error "UNARY"
     | emitInstr (I.SET{cond, opnd}) = error "SET"
     | emitInstr (I.CMOV{cond, src, dst}) = error "CMOV"
     | emitInstr (I.CMOVQ{cond, src, dst}) = error "CMOVQ"
     | emitInstr (I.PUSHQ operand) = error "PUSHQ"
     | emitInstr (I.PUSHL operand) = error "PUSHL"
     | emitInstr (I.PUSHW operand) = error "PUSHW"
     | emitInstr (I.PUSHB operand) = error "PUSHB"
     | emitInstr (I.PUSHFD) = error "PUSHFD"
     | emitInstr (I.POPFD) = error "POPFD"
     | emitInstr (I.POP operand) = error "POP"
     | emitInstr (I.CDQ) = error "CDQ"
     | emitInstr (I.INTO) = error "INTO"
     | emitInstr (I.FBINARY{binOp, src, dst}) = error "FBINARY"
     | emitInstr (I.FIBINARY{binOp, src}) = error "FIBINARY"
     | emitInstr (I.FUNARY funOp) = error "FUNARY"
     | emitInstr (I.FUCOM operand) = error "FUCOM"
     | emitInstr (I.FUCOMP operand) = error "FUCOMP"
     | emitInstr (I.FUCOMPP) = error "FUCOMPP"
     | emitInstr (I.FCOMPP) = error "FCOMPP"
     | emitInstr (I.FCOMI operand) = error "FCOMI"
     | emitInstr (I.FCOMIP operand) = error "FCOMIP"
     | emitInstr (I.FUCOMI operand) = error "FUCOMI"
     | emitInstr (I.FUCOMIP operand) = error "FUCOMIP"
     | emitInstr (I.FXCH{opnd}) = error "FXCH"
     | emitInstr (I.FSTPL operand) = error "FSTPL"
     | emitInstr (I.FSTPS operand) = error "FSTPS"
     | emitInstr (I.FSTPT operand) = error "FSTPT"
     | emitInstr (I.FSTL operand) = error "FSTL"
     | emitInstr (I.FSTS operand) = error "FSTS"
     | emitInstr (I.FLD1) = error "FLD1"
     | emitInstr (I.FLDL2E) = error "FLDL2E"
     | emitInstr (I.FLDL2T) = error "FLDL2T"
     | emitInstr (I.FLDLG2) = error "FLDLG2"
     | emitInstr (I.FLDLN2) = error "FLDLN2"
     | emitInstr (I.FLDPI) = error "FLDPI"
     | emitInstr (I.FLDZ) = error "FLDZ"
     | emitInstr (I.FLDL operand) = error "FLDL"
     | emitInstr (I.FLDS operand) = error "FLDS"
     | emitInstr (I.FLDT operand) = error "FLDT"
     | emitInstr (I.FILD operand) = error "FILD"
     | emitInstr (I.FILDL operand) = error "FILDL"
     | emitInstr (I.FILDLL operand) = error "FILDLL"
     | emitInstr (I.FNSTSW) = error "FNSTSW"
     | emitInstr (I.FENV{fenvOp, opnd}) = error "FENV"
     | emitInstr (I.FMOVE{fsize, src, dst}) = error "FMOVE"
     | emitInstr (I.FILOAD{isize, ea, dst}) = error "FILOAD"
     | emitInstr (I.FBINOP{fsize, binOp, lsrc, rsrc, dst}) = error "FBINOP"
     | emitInstr (I.FIBINOP{isize, binOp, lsrc, rsrc, dst}) = error "FIBINOP"
     | emitInstr (I.FUNOP{fsize, unOp, src, dst}) = error "FUNOP"
     | emitInstr (I.FCMP{i, fsize, lsrc, rsrc}) = error "FCMP"
     | emitInstr (I.SAHF) = error "SAHF"
     | emitInstr (I.LAHF) = error "LAHF"
     | emitInstr (I.SOURCE{}) = ()
     | emitInstr (I.SINK{}) = ()
     | emitInstr (I.PHI{}) = ()
       in
           emitInstr instr
       end
   
   fun emitInstruction(I.ANNOTATION{i, ...}) = emitInstruction(i)
     | emitInstruction(I.INSTR(i)) = emitter(i)
     | emitInstruction(I.LIVE _)  = ()
     | emitInstruction(I.KILL _)  = ()
   | emitInstruction _ = error "emitInstruction"
   
   in  S.STREAM{beginCluster=init,
                pseudoOp=pseudoOp,
                emit=emitInstruction,
                endCluster=fail,
                defineLabel=doNothing,
                entryLabel=doNothing,
                comment=doNothing,
                exitBlock=doNothing,
                annotation=doNothing,
                getAnnotations=getAnnotations
               }
   end
end

