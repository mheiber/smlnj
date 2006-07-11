(* Copyright 2006 by the Standard ML Fellowship *)
(* primopmap.sml *)

(* The module PrimOpMap provides a table of all the primops formerly defined in
 * the InLine structure, indexed by the primop names defined used in InLine.
 * The table is given in the form of the primopMap function, which maps a primop
 * name to the primop value and its "intrinsic" type (the type formerly used for
 * the primop in InLine).
 *
 * The translate phase will use this table to lookup names in the primId field
 * of variables when translating variables.
 *)

signature PRIMOP_MAP =
sig 
  val primopMap : string -> Primop.primop * Types.ty
end (* signature PRIMOP_MAP *)


structure PrimOpMap : PRIMOP_MAP = 
struct

local

  structure T = Types
  structure BT = BasicTypes
  structure P = PrimOp

in

(**************************************************************************
 *                 BUILDING A COMPLETE LIST OF PRIMOPS                    *
 **************************************************************************)


fun bits size oper = P.ARITH{oper=oper, overflow=false, kind=P.INT size}
val bits31 = bits 31		
val bits32 = bits 32		

fun int size oper = P.ARITH{oper=oper, overflow=true, kind=P.INT size}
val int31 = int 31
val int32 = int 32

fun word size oper = P.ARITH{oper=oper, overflow=false, kind=P.UINT size}
val word32 = word 32
val word31 = word 31
val word8  = word 8

fun purefloat size oper = P.ARITH{oper=oper,overflow=false,kind=P.FLOAT size}
val purefloat64 = purefloat 64	

fun cmp kind oper = P.CMP{oper=oper, kind=kind}
val int31cmp = cmp (P.INT 31)
val int32cmp = cmp (P.INT 32)

val word32cmp = cmp (P.UINT 32)
val word31cmp = cmp (P.UINT 31)
val word8cmp  = cmp (P.UINT 8)

val float64cmp = cmp (P.FLOAT 64)

val v1 = T.IBOUND 0
val v2 = T.IBOUND 1
val v3 = T.IBOUND 2

val tu = BT.tupleTy
fun ar(t1,t2) = BT.--> (t1, t2)

fun ap(tc,l) = T.CONty(tc, l)
fun cnt t = T.CONty(BT.contTycon,[t])
fun ccnt t = T.CONty(BT.ccontTycon,[t])
fun rf t = T.CONty(BT.refTycon,[t])
fun ay t = T.CONty(BT.arrayTycon,[t])
fun vct t = T.CONty(BT.vectorTycon,[t])

val u = BT.unitTy
val bo = BT.boolTy
val i = BT.intTy
val i32 = BT.int32Ty
val i64 = BT.int64Ty
val inf = BT.intinfTy
val w8 = BT.word8Ty
val w = BT.wordTy
val w32 = BT.word32Ty
val w64 = BT.word64Ty
val f64 = BT.realTy
val s  = BT.stringTy

fun p0 t = t
fun p1 t = T.POLYty {sign=[false], tyfun=T.TYFUN {arity=1, body=t}}
fun ep1 t = T.POLYty {sign=[true], tyfun=T.TYFUN {arity=1, body=t}}
fun p2 t = T.POLYty {sign=[false,false], tyfun=T.TYFUN {arity=2, body=t}}
fun p3 t = T.POLYty {sign=[false,false,false], tyfun=T.TYFUN {arity=3, body=t}}

fun sub kind = P.NUMSUBSCRIPT{kind=kind, checked=false, immutable=false}
fun chkSub kind = P.NUMSUBSCRIPT{kind=kind, checked=true, immutable=false}

fun subv kind = P.NUMSUBSCRIPT{kind=kind, checked=false, immutable=true}
fun chkSubv kind = P.NUMSUBSCRIPT{kind=kind, checked=true, immutable=true}

fun update kind = P.NUMUPDATE {kind=kind, checked=false}
fun chkUpdate kind = P.NUMUPDATE {kind=kind, checked=true}

val numSubTy = p2(ar(tu[v1,i],v2))
val numUpdTy = p2(ar(tu[v1,i,v2],u))

fun unf t = p0(ar(t,t))
fun binf t = p0(ar(tu[t,t],t))
fun binp t = p0(ar(tu[t,t],bo))
fun shifter t = p0(ar(tu[t,w],t))

val w32_i32 = p0(ar(w32,i32))
val w32_f64 = p0(ar(w32,f64))
val w32w32_u = p0(ar(tu[w32,w32],u))
val w32i32_u = p0(ar(tu[w32,i32],u))
val w32f64_u = p0(ar(tu[w32,f64],u))

val i_x      = p1(ar(i,v1))
val xw32_w32 = p1(ar(tu[v1,w32],w32))
val xw32_i32 = p1(ar(tu[v1,w32],i32))
val xw32_f64 = p1(ar(tu[v1,w32],f64))
val xw32w32_u = p1(ar(tu[v1,w32,w32],u))
val xw32i32_u = p1(ar(tu[v1,w32,i32],u))
val xw32f64_u = p1(ar(tu[v1,w32,f64],u))

val b_b = unf bo

val f64_i = p0(ar(f64,i))
val i_f64 = p0(ar(i,f64))
val i32_f64 = p0(ar(i32,f64))

val w32_i = p0(ar(w32,i))
val i32_i = p0(ar(i32,i))

val i_i32 = p0(ar(i,i32))
val i_w32 = p0(ar(i,w32))

val w32_w = p0(ar(w32,w))
val i32_w = p0(ar(i32,w))

val w_w32 = p0(ar(w,w32))
val w_i32 = p0(ar(w,i32))

val w_i = p0(ar(w,i))
val i_w = p0(ar(i,w))

val w32_i32 = p0(ar(w32,i32))
val i32_w32 = p0(ar(i32,w32))

val i_i = unf i
val ii_i = binf i
val ii_b = binp i
val iw_i = shifter i

val w_w = unf w
val ww_w = binf w
val ww_b = binp w

val i32_i32 = unf i32
val i32i32_i32 = binf i32
val i32i32_b = binp i32

val w32_w32 = unf w32
val w32w32_w32 = binf w32
val w32w32_b = binp w32
val w32w_w32 = shifter w32

val w8_w8 = unf w8
val w8w8_w8 = binf w8
val w8w8_b = binp w8
val w8w_w8 = shifter w8

val f64_f64 = unf f64
val f64f64_f64 = binf f64
val f64f64_b = binp f64

val w8_i = p0(ar(w8,i))
val w8_i32 = p0(ar(w8,i32))
val w8_w32 = p0(ar(w8,w32))
val i_w8 = p0(ar(i,w8))
val i32_w8 = p0(ar(i32,w8))
val w32_w8 = p0(ar(w32,w8))

val inf_i   = p0(ar(inf,i))
val inf_i32 = p0(ar(inf,i32))
val inf_i64 = p0(ar(inf,i64))
val inf_w8  = p0(ar(inf,w8))
val inf_w   = p0(ar(inf,w))
val inf_w32 = p0(ar(inf,w32))
val inf_w64 = p0(ar(inf,w64))
val i_inf   = p0(ar(i,inf))
val i32_inf = p0(ar(i32,inf))
val i64_inf = p0(ar(i64,inf))
val w8_inf  = p0(ar(w8,inf))
val w_inf   = p0(ar(w,inf))
val w32_inf = p0(ar(w32,inf))
val w64_inf = p0(ar(w64,inf))

val w64_pw32 = p0(ar(w64,tu[w32,w32]))
val pw32_w64 = p0(ar(tu[w32,w32],w64))
val i64_pw32 = p0(ar(i64,tu[w32,w32]))
val pw32_i64 = p0(ar(tu[w32,w32],i64))

val cc_b = binp BT.charTy

(* The type of the RAW_CCALL primop (as far as the type checker is concerned)
 * is:
 *    word32 * 'a * 'b -> 'd
 * However, the primop cannot be used without having 'a, 'b, and 'c
 * monomorphically instantiated.  In particular, 'a will be the type of the
 * ML argument list, 'c will be the type of the result, and 'b
 * will be a type of a fake arguments.  The idea is that 'b will be
 * instantiated with some ML type that encodes the type of the actual
 * C function in order to be able to generate code according to the C
 * calling convention.
 * (In other words, 'b will be a completely ad-hoc encoding of a CTypes.c_proto
 * value in ML types.  The encoding also contains information about
 * calling conventions and reentrancy.)
 *)
val rccType = p3(ar(tu[w32,v1,v2],v3))

in

(*
 * I made an effort to eliminate the cases where type info for primops
 * is left NONE because this is, in fact, incorrect.  (As long as they
 * are left at NONE, there are correct ML programs that trigger internal
 * compiler errors.)
 *    - M.Blume (1/2001)
 *)

structure StringKey : ORD_KEY =
struct
  type ord_key = string
  val compare = String.compare
end

structure RBMap = RedBlackMapFn(StringKey)

val empty = RBMap.empty

(* Below there is a bunch of very long list literals which would create
 * huge register pressure on the compiler.  We construct them backwards
 * using an alternative "cons" that takes its two arguments in opposite
 * order.  This effectively puts the lists' ends to the left and alleviates
 * this effect. (Stupid ML trick No. 21b) (Blume, 1/2001) *)
infix :-:
fun m :-: (name,entry) = RBMap.insert(m,name,entry)

val primops =
    empty :-:
       ("callcc",	 (P.CALLCC,    	p1(ar(ar(cnt(v1),v1),v1)))) :-:
       ("throw",	 (P.THROW,     	p2(ar(cnt(v1),ar(v1,v2))))) :-:
       ("capture",	 (P.CAPTURE,    p1(ar(ar(ccnt(v1),v1),v1)))) :-:
       ("isolate",	 (P.ISOLATE,    p1(ar(ar(v1,u),cnt(v1))))) :-:
       ("cthrow",	 (P.THROW,     	p2(ar(ccnt(v1),ar(v1,v2))))) :-:
       ("!",		 (P.DEREF,     	p1(ar(rf(v1),v1)))) :-:
       (":=",	         (P.ASSIGN,     p1(ar(tu[rf(v1),v1],u)))) :-:
       ("makeref",	 (P.MAKEREF,    p1(ar(v1,rf(v1))))) :-:
       ("boxed",	 (P.BOXED,      p1(ar(v1,bo)))) :-:
       ("unboxed",	 (P.UNBOXED,    p1(ar(v1,bo)))) :-:
       ("cast",	         (P.CAST,      	p2(ar(v1,v2)))) :-:
       ("=",		 (P.POLYEQL,    ep1(ar(tu[v1,v1],bo)))) :-:
       ("<>",	         (P.POLYNEQ,    ep1(ar(tu[v1,v1],bo)))) :-:
       ("ptreql",	 (P.PTREQL,     p1(ar(tu[v1,v1],bo)))) :-:
       ("ptrneq",	 (P.PTRNEQ,     p1(ar(tu[v1,v1],bo)))) :-:
       ("getvar",	 (P.GETVAR,     p1(ar(u,v1)))) :-:
       ("setvar",	 (P.SETVAR,     p1(ar(v1,u)))) :-:
       ("setpseudo",	 (P.SETPSEUDO,  p1(ar(tu[v1,i],u)))) :-:
       ("getpseudo",	 (P.GETPSEUDO,  p1(ar(i,v1)))) :-:
       ("mkspecial",     (P.MKSPECIAL,  p2(ar(tu[i,v1],v2)))) :-:
       ("getspecial",    (P.GETSPECIAL, p1(ar(v1,i)))) :-:
       ("setspecial",    (P.SETSPECIAL, p1(ar(tu[v1,i],u)))) :-:
       ("gethdlr",	 (P.GETHDLR,    p1(ar(u,cnt(v1))))) :-:
       ("sethdlr",	 (P.SETHDLR,    p1(ar(cnt(v1),u)))) :-:
       ("gettag", 	 (P.GETTAG,     p1(ar(v1,i)))) :-:
       ("setmark",	 (P.SETMARK,    p1(ar(v1,u)))) :-:
       ("dispose",	 (P.DISPOSE,    p1(ar(v1,u)))) :-:
       ("compose",	 (P.INLCOMPOSE, p3(ar(tu[ar(v2,v3),ar(v1,v2)],ar(v1,v3))))) :-:
       ("before",	 (P.INLBEFORE,  p2(ar(tu[v1,v2],v1)))) :-:
       ("ignore",        (P.INLIGNORE,  p1(ar(v1,u)))) :-:
       ("identity",      (P.INLIDENTITY,p1(ar(v1,v1)))) :-:
			 
       			 
       ("length",	 (P.LENGTH,      p1(ar(v1,i)))) :-:
       ("objlength",	 (P.OBJLENGTH,   p1(ar(v1,i)))) :-:

       (*  
        * I believe the following five primops should not be exported into
        * the InLine structure. (ZHONG) 
        *)
       (* So we take them out... (Matthias)
       ("boxedupdate",   P.BOXEDUPDATE,   ?) :-:
       ("getrunvec",	 P.GETRUNVEC,     ?) :-:
       ("uselvar",	 P.USELVAR,       ?) :-:
       ("deflvar",	 P.DEFLVAR,       ?) :-:
       *)

       (* I put this one back in so tprof can find it in _Core
	* instead of having to construct it ... (Matthias) *)
       ("unboxedupdate", (P.UNBOXEDUPDATE, p1(ar(tu[ay(v1),i,v1],u)))) :-:
       			 
       ("inlnot",	 (P.INLNOT,      	        b_b)) :-:
       ("floor",         (P.ROUND{floor=true,
                               fromkind=P.FLOAT 64,
                               tokind=P.INT 31},      	f64_i)) :-:
       ("round",         (P.ROUND{floor=false, 
                               fromkind=P.FLOAT 64,
                               tokind=P.INT 31},      	f64_i)) :-:
       ("real",          (P.REAL{fromkind=P.INT 31,
                               tokind=P.FLOAT 64},     	i_f64)) :-:
       ("real32",        (P.REAL{fromkind=P.INT 32,
			         tokind=P.FLOAT 64},    i32_f64)) :-:
       			 
       ("ordof",         (P.NUMSUBSCRIPT{kind=P.INT 8,
                                      checked=false,
                                      immutable=true},  numSubTy)) :-:
       ("store",         (P.NUMUPDATE{kind=P.INT 8,
                                   checked=false},      numUpdTy)) :-:
       ("inlbyteof",     (P.NUMSUBSCRIPT{kind=P.INT 8,
                                      checked=true,
                                      immutable=false}, numSubTy)) :-:
       ("inlstore",      (P.NUMUPDATE{kind=P.INT 8,
                                      checked=true},   	numUpdTy)) :-:
       ("inlordof",      (P.NUMSUBSCRIPT{kind=P.INT 8,
                                      checked=true,
                                      immutable=true},  numSubTy)) :-:

       (*** polymorphic array and vector ***)
       ("mkarray",       (P.INLMKARRAY,         p1(ar(tu[i,v1],ay(v1))))) :-:
       ("arrSub", 	 (P.SUBSCRIPT,      	p1(ar(tu[ay(v1),i],v1)))) :-:
       ("arrChkSub",	 (P.INLSUBSCRIPT,      	p1(ar(tu[ay(v1),i],v1)))) :-:
       ("vecSub",	 (P.SUBSCRIPTV,      	p1(ar(tu[vct(v1),i],v1)))) :-:
       ("vecChkSub",	 (P.INLSUBSCRIPTV,      p1(ar(tu[vct(v1),i],v1)))) :-:
       ("arrUpdate",	 (P.UPDATE,      	p1(ar(tu[ay(v1),i,v1],u)))) :-:
       ("arrChkUpdate",  (P.INLUPDATE,      	p1(ar(tu[ay(v1),i,v1],u)))) :-:

       (* new array representations *)
	("newArray0",	 (P.NEW_ARRAY0,		p1(ar(u,v1)))) :-:
	("getSeqData",	 (P.GET_SEQ_DATA,	p2(ar(v1, v2)))) :-:
	("recordSub",	 (P.SUBSCRIPT_REC,	p2(ar(tu[v1,i],v2)))) :-:
	("raw64Sub",	 (P.SUBSCRIPT_RAW64,	p1(ar(tu[v1,i],f64)))) :-:

       (* *** conversion primops ***
	*   There are certain duplicates for the same primop (but with
	*   different types).  In such a case, the "canonical" name
	*   of the primop has been extended using a simple suffix
	*   scheme. *)
       ("test_32_31_w",  (P.TEST(32,31),  	w32_i)) :-:
       ("test_32_31_i",  (P.TEST(32,31),  	i32_i)) :-:

       ("testu_31_31",   (P.TESTU(31,31),       w_i))) :-:

       ("testu_32_31",   (P.TESTU(32,31),       w32_i))) :-:

       ("testu_32_32",   (P.TESTU(32,32),   	w32_i32))) :-:

       ("copy_32_32_ii", (P.COPY(32,32),   	i32_i32)) :-:
       ("copy_32_32_wi", (P.COPY(32,32),   	w32_i32)) :-:
       ("copy_32_32_iw", (P.COPY(32,32),   	i32_w32)) :-:
       ("copy_32_32_ww", (P.COPY(32,32),   	w32_w32)) :-:

       ("copy_31_31_ii", (P.COPY(31,31),   	i_i)) :-:
       ("copy_31_31_wi", (P.COPY(31,31),   	w_i)) :-:
       ("copy_31_31_iw", (P.COPY(31,31),   	i_w)) :-:

       ("copy_31_32_i",  (P.COPY(31,32),   	w_i32)) :-:
       ("copy_31_32_w",  (P.COPY(31,32),   	w_w32)) :-:

       ("copy_8_32_i",   (P.COPY(8,32),     	w8_i32)) :-:
       ("copy_8_32_w",   (P.COPY(8,32),     	w8_w32)) :-:

       ("copy_8_31",     (P.COPY(8,31),     	w8_i)) :-:

       ("extend_31_32_ii", (P.EXTEND(31,32), 	i_i32)) :-:
       ("extend_31_32_iw", (P.EXTEND(31,32), 	i_w32)) :-:
       ("extend_31_32_wi", (P.EXTEND(31,32), 	w_i32)) :-:
       ("extend_31_32_ww", (P.EXTEND(31,32), 	w_w32)) :-:

       ("extend_8_31",   (P.EXTEND(8,31),   	w8_i)) :-:

       ("extend_8_32_i", (P.EXTEND(8,32), 	w8_i32)) :-:
       ("extend_8_32_w", (P.EXTEND(8,32), 	w8_w32)) :-:

       ("trunc_32_31_i", (P.TRUNC(32,31),   	i32_w)) :-:
       ("trunc_32_31_w", (P.TRUNC(32,31),   	w32_w)) :-:

       ("trunc_31_8",    (P.TRUNC(31,8),   	i_w8)) :-:

       ("trunc_32_8_i",  (P.TRUNC(32,8),   	i32_w8)) :-:
       ("trunc_32_8_w",  (P.TRUNC(32,8),   	w32_w8)) :-:

       (* conversion primops involving intinf *)
       ("test_inf_31",   (P.TEST_INF 31,         inf_i)   :-:
       ("test_inf_32",   (P.TEST_INF 32,         inf_i32)) :-:
       ("test_inf_64",   (P.TEST_INF 64,         inf_i64)) :-:
       ("copy_8_inf",    (P.COPY_INF 8,          w8_inf)  :-:
       ("copy_8_inf_w",  (P.COPY_INF 8,          w8_inf)  :-:
       ("copy_31_inf_w", (P.COPY_INF 31,         w_inf)   :-:
       ("copy_32_inf_w", (P.COPY_INF 32,         w32_inf)) :-:
       ("copy_64_inf_w", (P.COPY_INF 64,         w64_inf)) :-:
       ("copy_31_inf_i", (P.COPY_INF 31,         i_inf)   :-:
       ("copy_32_inf_i", (P.COPY_INF 32,         i32_inf)) :-:
       ("copy_64_inf_i", (P.COPY_INF 64,         i64_inf)) :-:
       ("extend_8_inf",  (P.EXTEND_INF 8,        w8_inf)  :-:
       ("extend_8_inf_w",  (P.EXTEND_INF 8,      w8_inf)  :-:
       ("extend_31_inf_w", (P.EXTEND_INF 31,     w_inf)) :-:
       ("extend_32_inf_w", (P.EXTEND_INF 32,     w32_inf)) :-:
       ("extend_64_inf_w", (P.EXTEND_INF 64,     w64_inf)) :-:
       ("extend_31_inf_i", (P.EXTEND_INF 31,     i_inf)) :-:
       ("extend_32_inf_i", (P.EXTEND_INF 32,     i32_inf)) :-:
       ("extend_64_inf_i", (P.EXTEND_INF 64,     i64_inf)) :-:
       ("trunc_inf_8",   (P.TRUNC_INF 8,         inf_w8)  :-:
       ("trunc_inf_31",  (P.TRUNC_INF 31,        inf_w)) :-:
       ("trunc_inf_32",  (P.TRUNC_INF 32,        inf_w32)) :-:
       ("trunc_inf_64",  (P.TRUNC_INF 64,        inf_w64)) :-:
       
       (* primops to go between abstract and concrete representation of
	* 64-bit ints and words *)
       ("w64p",          (P.CVT64,               w64_pw32)) :-:
       ("p64w",          (P.CVT64,               pw32_w64)) :-:
       ("i64p",          (P.CVT64,               i64_pw32)) :-:
       ("p64i",          (P.CVT64,               pw32_i64)) :-:

       (* *** integer 31 primops ***
        *   Many of the i31 primops are being abused for different types
	*   (mostly Word8.word and also for char).  In these cases
	*   there are suffixed alternative versions of the primop
	*   (i.e., same primop, different type). *)
       ("i31add", 	 (int31 P.+,      	ii_i)) :-:
       ("i31add_8", 	 (int31 P.+,      	w8w8_w8)) :-:

       ("i31sub",	 (int31 P.-,      	ii_i)) :-:
       ("i31sub_8",	 (int31 P.-,      	w8w8_w8)) :-:

       ("i31mul",	 (int31 P.*,      	ii_i)) :-:
       ("i31mul_8",	 (int31 P.*,      	w8w8_w8)) :-:

       ("i31div",	 (int31 P.DIV,      	ii_i)) :-:
       ("i31div_8",	 (int31 P.DIV,      	w8w8_w8)) :-:

       ("i31mod",        (int31 P.MOD,      	ii_i)) :-:
       ("i31mod_8",      (int31 P.MOD,           w8w8_w8)) :-:

       ("i31quot",	 (int31 P./,      	ii_i)) :-:

       ("i31rem",	 (int31 P.REM,      	ii_i)) :-:

       ("i31orb",	 (bits31 P.ORB,      	ii_i)) :-:
       ("i31orb_8",	 (bits31 P.ORB,      	w8w8_w8)) :-:

       ("i31andb",	 (bits31 P.ANDB,      	ii_i)) :-:
       ("i31andb_8",	 (bits31 P.ANDB,      	w8w8_w8)) :-:

       ("i31xorb",	 (bits31 P.XORB,      	ii_i)) :-:
       ("i31xorb_8",	 (bits31 P.XORB,      	w8w8_w8)) :-:

       ("i31notb",	 (bits31 P.NOTB,      	i_i)) :-:
       ("i31notb_8",	 (bits31 P.NOTB,      	w8_w8)) :-:

       ("i31neg",	 (int31 P.~,      	i_i)) :-:
       ("i31neg_8",	 (int31 P.~,      	w8_w8)) :-:

       ("i31lshift",	 (bits31 P.LSHIFT,     	ii_i)) :-:
       ("i31lshift_8",	 (bits31 P.LSHIFT,     	w8w_w8)) :-:

       ("i31rshift",	 (bits31 P.RSHIFT,      ii_i)) :-:
       ("i31rshift_8",	 (bits31 P.RSHIFT,      w8w_w8)) :-:

       ("i31lt",	 (int31cmp P.<,		ii_b)) :-:
       ("i31lt_8",	 (int31cmp P.<,		w8w8_b)) :-:
       ("i31lt_c",	 (int31cmp P.<,		cc_b)) :-:

       ("i31le",	 (int31cmp P.<=,	ii_b)) :-:
       ("i31le_8",	 (int31cmp P.<=,	w8w8_b)) :-:
       ("i31le_c",	 (int31cmp P.<=,	cc_b)) :-:

       ("i31gt",	 (int31cmp P.>,		ii_b)) :-:
       ("i31gt_8",	 (int31cmp P.>,		w8w8_b)) :-:
       ("i31gt_c",	 (int31cmp P.>,		cc_b)) :-:

       ("i31ge", 	 (int31cmp P.>=,	ii_b)) :-:
       ("i31ge_8", 	 (int31cmp P.>=,	w8w8_b)) :-:
       ("i31ge_c", 	 (int31cmp P.>=,	cc_b)) :-:

       ("i31ltu",	 (word31cmp P.LTU,     	ii_b)) :-:
       ("i31geu",	 (word31cmp P.GEU,     	ii_b)) :-:
       ("i31eq",	 (int31cmp P.EQL,      	ii_b)) :-:
       ("i31ne",	 (int31cmp P.NEQ,      	ii_b)) :-:

       ("i31min",	 (P.INLMIN (P.INT 31), 	ii_i)) :-:
       ("i31min_8",	 (P.INLMIN (P.INT 31), 	w8w8_w8)) :-:
       ("i31max",	 (P.INLMAX (P.INT 31), 	ii_i)) :-:
       ("i31max_8",	 (P.INLMAX (P.INT 31), 	w8w8_w8)) :-:

       ("i31abs",	 (P.INLABS (P.INT 31), 	i_i)) :-:

       (*** integer 32 primops ***)
       ("i32mul",        (int32 P.*,      	i32i32_i32)) :-:
       ("i32div",        (int32 P.DIV,      	i32i32_i32)) :-:
       ("i32mod",        (int32 P.MOD,      	i32i32_i32)) :-:
       ("i32quot",       (int32 P./,      	i32i32_i32)) :-:
       ("i32rem",        (int32 P.REM,      	i32i32_i32)) :-:
       ("i32add",        (int32 P.+,      	i32i32_i32)) :-:
       ("i32sub",        (int32 P.-,      	i32i32_i32)) :-:
       ("i32orb",        (bits32 P.ORB,      	i32i32_i32)) :-:
       ("i32andb",       (bits32 P.ANDB,      	i32i32_i32)) :-:
       ("i32xorb",       (bits32 P.XORB,      	i32i32_i32)) :-:
       ("i32lshift",     (bits32 P.LSHIFT,      	i32i32_i32)) :-:
       ("i32rshift",     (bits32 P.RSHIFT,      	i32i32_i32)) :-:
       ("i32neg",        (int32 P.~,      	i32_i32)) :-:
       ("i32lt",         (int32cmp P.<,		i32i32_b)) :-:
       ("i32le",         (int32cmp P.<=,		i32i32_b)) :-:
       ("i32gt",         (int32cmp P.>,		i32i32_b)) :-:
       ("i32ge",         (int32cmp P.>=,		i32i32_b)) :-:
       ("i32eq",         (int32cmp P.EQL,	i32i32_b)) :-:
       ("i32ne",         (int32cmp P.NEQ,	i32i32_b)) :-:

       ("i32min",	 (P.INLMIN (P.INT 32),  	i32i32_i32)) :-:
       ("i32max",	 (P.INLMAX (P.INT 32),  	i32i32_i32)) :-:
       ("i32abs",	 (P.INLABS (P.INT 32), 	i32_i32)) :-:

       (*** float 64 primops ***)
       ("f64add", 	 (purefloat64 (P.+),      f64f64_f64)) :-:
       ("f64sub",	 (purefloat64 (P.-),      f64f64_f64)) :-:
       ("f64div", 	 (purefloat64 (P./),      f64f64_f64)) :-:
       ("f64mul",	 (purefloat64 (P.* ),     f64f64_f64)) :-:
       ("f64neg",	 (purefloat64 P.~,      	 f64_f64)) :-:
       ("f64ge",	 (float64cmp (P.>=),      f64f64_b)) :-:
       ("f64gt",	 (float64cmp (P.>),       f64f64_b)) :-:
       ("f64le",	 (float64cmp (P.<=),      f64f64_b)) :-:
       ("f64lt",	 (float64cmp (P.<),       f64f64_b)) :-:
       ("f64eq",	 (float64cmp P.EQL,       f64f64_b)) :-:
       ("f64ne",	 (float64cmp P.NEQ,       f64f64_b)) :-:
       ("f64abs",	 (purefloat64 P.ABS,      f64_f64)) :-:

       ("f64sin",	 (purefloat64 P.FSIN,	 f64_f64)) :-:
       ("f64cos",	 (purefloat64 P.FCOS,	 f64_f64)) :-:
       ("f64tan",	 (purefloat64 P.FTAN,	 f64_f64)) :-:
       ("f64sqrt",	 (purefloat64 P.FSQRT,    f64_f64)) :-:

       ("f64min",	 (P.INLMIN (P.FLOAT 64),  f64f64_f64)) :-:
       ("f64max",	 (P.INLMAX (P.FLOAT 64),  f64f64_f64)) :-:

       (*** float64 array ***)	
       ("f64Sub",	 (sub (P.FLOAT 64),       numSubTy)) :-:
       ("f64chkSub",	 (chkSub (P.FLOAT 64),    numSubTy)) :-:
       ("f64Update",	 (update (P.FLOAT 64),    numUpdTy)) :-:
       ("f64chkUpdate",  (chkUpdate (P.FLOAT 64), numUpdTy)) :-:

       (*** word8 primops ***)
       (* 
        * In the long run, we plan to represent WRAPPED word8 tagged, and 
        * UNWRAPPED untagged. But right now, we represent both of them 
        * tagged, with 23 high-order zero bits and 1 low-order 1 bit.
        * In this representation, we can use the comparison and (some of 
        * the) bitwise operators of word31; but we cannot use the shift 
        * and arithmetic operators.
        *
        * WARNING: THIS IS A TEMPORARY HACKJOB until all the word8 primops 
        * are correctly implemented.
        *
        * ("w8mul",	word8 (P.* ),      	w8w8_w8)) :-:
	* ("w8div",	word8 (P./),      	w8w8_w8)) :-:
	* ("w8add",	word8 (P.+),      	w8w8_w8)) :-:
	* ("w8sub",	word8 (P.-),      	w8w8_w8)) :-:
        *		
        * ("w8notb",	word31 P.NOTB,      	w8_w8)) :-:
	* ("w8rshift",	word8 P.RSHIFT,      	w8w_w8)) :-:
	* ("w8rshiftl",	word8 P.RSHIFTL,      	w8w_w8)) :-:
	* ("w8lshift",	word8 P.LSHIFT,      	w8w_w8)) :-:
        *
	* ("w8toint",   P.ROUND{floor=true, 
        *                     fromkind=P.UINT 8, 
        *                     tokind=P.INT 31},   w8_i)) :-:
	* ("w8fromint", P.REAL{fromkind=P.INT 31,
        *                    tokind=P.UINT 8},    i_w8)) :-:
        *)
  
       ("w8orb",	(word31 P.ORB,      	w8w8_w8)) :-:
       ("w8xorb",	(word31 P.XORB,      	w8w8_w8)) :-:
       ("w8andb",	(word31 P.ANDB,      	w8w8_w8)) :-:
       	 		
       ("w8gt",	        (word8cmp P.>,           w8w8_b)) :-:
       ("w8ge",	        (word8cmp P.>=,          w8w8_b)) :-:
       ("w8lt",	        (word8cmp P.<,           w8w8_b)) :-:
       ("w8le",		(word8cmp P.<=,          w8w8_b)) :-:
       ("w8eq",		(word8cmp P.EQL,      	w8w8_b)) :-:
       ("w8ne",		(word8cmp P.NEQ,      	w8w8_b)) :-:

       (*** word8 array and vector ***)
       ("w8Sub",	(sub (P.UINT 8),      	numSubTy)) :-:
       ("w8chkSub",	(chkSub (P.UINT 8),      numSubTy)) :-:
       ("w8subv",	(subv (P.UINT 8),        numSubTy)) :-:
       ("w8chkSubv",	(chkSubv (P.UINT 8),     numSubTy)) :-:
       ("w8update",	(update (P.UINT 8),      numUpdTy)) :-:
       ("w8chkUpdate",  (chkUpdate (P.UINT 8),   numUpdTy)) :-:

       (* word31 primops *)
       ("w31mul",	(word31 (P.* ),      	ww_w)) :-:
       ("w31div",	(word31 (P./),      	ww_w)) :-:
       ("w31mod",	(word31 (P.REM),      	ww_w)) :-:
       ("w31add",	(word31 (P.+),      	ww_w)) :-:
       ("w31sub",	(word31 (P.-),      	ww_w)) :-:
       ("w31orb",	(word31 P.ORB,      	ww_w)) :-:
       ("w31xorb",	(word31 P.XORB,      	ww_w)) :-:
       ("w31andb",	(word31 P.ANDB,      	ww_w)) :-:
       ("w31notb",	(word31 P.NOTB,      	w_w)) :-:
       ("w31neg",       (word31 P.~,             w_w)) :-:
       ("w31rshift",	(word31 P.RSHIFT,        ww_w)) :-:
       ("w31rshiftl",   (word31 P.RSHIFTL,       ww_w)) :-:
       ("w31lshift",	(word31 P.LSHIFT,        ww_w)) :-:
       ("w31gt",	(word31cmp (P.>),        ww_b)) :-:
       ("w31ge",	(word31cmp (P.>=),       ww_b)) :-:
       ("w31lt",	(word31cmp (P.<),        ww_b)) :-:
       ("w31le",	(word31cmp (P.<=),       ww_b)) :-:
       ("w31eq",	(word31cmp P.EQL,        ww_b)) :-:
       ("w31ne",	(word31cmp P.NEQ,        ww_b)) :-:
       ("w31ChkRshift", (P.INLRSHIFT(P.UINT 31), ww_w)) :-:
       ("w31ChkRshiftl",(P.INLRSHIFTL(P.UINT 31),ww_w)) :-:
       ("w31ChkLshift", (P.INLLSHIFT(P.UINT 31), ww_w)) :-:

       ("w31min",	(P.INLMIN (P.UINT 31), 	ww_w)) :-:
       ("w31max",	(P.INLMAX (P.UINT 31), 	ww_w)) :-:
       
       (* (pseudo-)word8 primops *)
       ("w31mul_8",	(word31 (P.* ),      	w8w8_w8)) :-:
       ("w31div_8",	(word31 (P./),      	w8w8_w8)) :-:
       ("w31mod_8",	(word31 (P.REM),      	w8w8_w8)) :-:
       ("w31add_8",	(word31 (P.+),      	w8w8_w8)) :-:
       ("w31sub_8",	(word31 (P.-),      	w8w8_w8)) :-:
       ("w31orb_8",	(word31 P.ORB,      	w8w8_w8)) :-:
       ("w31xorb_8",	(word31 P.XORB,      	w8w8_w8)) :-:
       ("w31andb_8",	(word31 P.ANDB,      	w8w8_w8)) :-:
       ("w31notb_8",	(word31 P.NOTB,      	w8_w8)) :-:
       ("w31neg_8",     (word31 P.~,             w8_w8)) :-:
       ("w31rshift_8",	(word31 P.RSHIFT,        w8w_w8)) :-:
       ("w31rshiftl_8", (word31 P.RSHIFTL,       w8w_w8)) :-:
       ("w31lshift_8",	(word31 P.LSHIFT,        w8w_w8)) :-:
       ("w31gt_8",	(word31cmp (P.>),        w8w8_b)) :-:
       ("w31ge_8",	(word31cmp (P.>=),       w8w8_b)) :-:
       ("w31lt_8",	(word31cmp (P.<),        w8w8_b)) :-:
       ("w31le_8",	(word31cmp (P.<=),       w8w8_b)) :-:
       ("w31eq_8",	(word31cmp P.EQL,        w8w8_b)) :-:
       ("w31ne_8",	(word31cmp P.NEQ,        w8w8_b)) :-:
       ("w31ChkRshift_8", (P.INLRSHIFT(P.UINT 31), w8w_w8)) :-:
       ("w31ChkRshiftl_8",(P.INLRSHIFTL(P.UINT 31),w8w_w8)) :-:
       ("w31ChkLshift_8", (P.INLLSHIFT(P.UINT 31), w8w_w8)) :-:

       ("w31min_8",	(P.INLMIN (P.UINT 31), 	w8w8_w8)) :-:
       ("w31max_8",	(P.INLMAX (P.UINT 31), 	w8w8_w8)) :-:

       (*** word32 primops ***)
       ("w32mul",	(word32 (P.* ),      	w32w32_w32)) :-:
       ("w32div",	(word32 (P./),      	w32w32_w32)) :-:
       ("w32mod",	(word32 (P.REM),      	w32w32_w32)) :-:
       ("w32add",	(word32 (P.+),      	w32w32_w32)) :-:
       ("w32sub",	(word32 (P.-),      	w32w32_w32)) :-:
       ("w32orb",	(word32 P.ORB,      	w32w32_w32)) :-:
       ("w32xorb",	(word32 P.XORB,      	w32w32_w32)) :-:
       ("w32andb",	(word32 P.ANDB,      	w32w32_w32)) :-:
       ("w32notb",	(word32 P.NOTB,      	w32_w32)) :-:
       ("w32neg",	(word32 P.~,      	w32_w32)) :-:
       ("w32rshift",	(word32 P.RSHIFT,     	w32w_w32)) :-:
       ("w32rshiftl",   (word32 P.RSHIFTL,    	w32w_w32)) :-:
       ("w32lshift",	(word32 P.LSHIFT,     	w32w_w32)) :-:
       ("w32gt",	(word32cmp (P.>),        w32w32_b)) :-:
       ("w32ge",	(word32cmp (P.>=),       w32w32_b)) :-:
       ("w32lt",	(word32cmp (P.<),        w32w32_b)) :-:
       ("w32le",	(word32cmp (P.<=),       w32w32_b)) :-:
       ("w32eq",	(word32cmp P.EQL,     	w32w32_b)) :-:
       ("w32ne",	(word32cmp P.NEQ,     	w32w32_b)) :-:
       ("w32ChkRshift", (P.INLRSHIFT(P.UINT 32), w32w_w32)) :-:
       ("w32ChkRshiftl",(P.INLRSHIFTL(P.UINT 32),w32w_w32)) :-:
       ("w32ChkLshift", (P.INLLSHIFT(P.UINT 32), w32w_w32)) :-:

       ("w32min",	(P.INLMIN (P.UINT 32), 	w32w32_w32)) :-:
       ("w32max",	(P.INLMAX (P.UINT 32), 	w32w32_w32)) :-:

       (* experimental C FFI primops *)
       ("raww8l",       (P.RAW_LOAD (P.UINT 8),    w32_w32)) :-:
       ("rawi8l",       (P.RAW_LOAD (P.INT 8),     w32_i32)) :-:
       ("raww16l",      (P.RAW_LOAD (P.UINT 16),   w32_w32)) :-:
       ("rawi16l",      (P.RAW_LOAD (P.INT 16),    w32_i32)) :-:
       ("raww32l",      (P.RAW_LOAD (P.UINT 32),   w32_w32)) :-:
       ("rawi32l",      (P.RAW_LOAD (P.INT 32),    w32_i32)) :-:
       ("rawf32l",      (P.RAW_LOAD (P.FLOAT 32),  w32_f64)) :-:
       ("rawf64l",      (P.RAW_LOAD (P.FLOAT 64),  w32_f64)) :-:
       ("raww8s",       (P.RAW_STORE (P.UINT 8),   w32w32_u)) :-:
       ("rawi8s",       (P.RAW_STORE (P.INT 8),    w32i32_u)) :-:
       ("raww16s",      (P.RAW_STORE (P.UINT 16),  w32w32_u)) :-:
       ("rawi16s",      (P.RAW_STORE (P.INT 16),   w32i32_u)) :-:
       ("raww32s",      (P.RAW_STORE (P.UINT 32),  w32w32_u)) :-:
       ("rawi32s",      (P.RAW_STORE (P.INT 32),   w32i32_u)) :-:
       ("rawf32s",      (P.RAW_STORE (P.FLOAT 32), w32f64_u)) :-:
       ("rawf64s",      (P.RAW_STORE (P.FLOAT 64), w32f64_u)) :-:
       ("rawccall",     (P.RAW_CCALL NONE,         rccType)) :-:

          (* Support for direct construction of C objects on ML heap.
           * rawrecord builds a record holding C objects on the heap.
           * rawselectxxx index on this record.  They are of type:
           *    'a * Word32.word -> Word32.word
           * The 'a is to guarantee that the compiler will treat
           * the record as a ML object, in case it passes thru a gc boundary.
           * rawupdatexxx writes to the record.
           *) 
       ("rawrecord",    (P.RAW_RECORD { fblock = false }, i_x)) :-:
       ("rawrecord64",  (P.RAW_RECORD { fblock = true }, i_x)) :-:

       ("rawselectw8",  (P.RAW_LOAD (P.UINT 8), xw32_w32)) :-:
       ("rawselecti8",  (P.RAW_LOAD (P.INT 8), xw32_i32)) :-:
       ("rawselectw16", (P.RAW_LOAD (P.UINT 16), xw32_w32)) :-:
       ("rawselecti16", (P.RAW_LOAD (P.INT 16), xw32_i32)) :-:
       ("rawselectw32", (P.RAW_LOAD (P.UINT 32), xw32_w32)) :-:
       ("rawselecti32", (P.RAW_LOAD (P.INT 32), xw32_i32)) :-:
       ("rawselectf32", (P.RAW_LOAD (P.FLOAT 32), xw32_f64)) :-:
       ("rawselectf64", (P.RAW_LOAD (P.FLOAT 64), xw32_f64)) :-:

       ("rawupdatew8",  (P.RAW_STORE (P.UINT 8), xw32w32_u)) :-:
       ("rawupdatei8",  (P.RAW_STORE (P.INT 8), xw32i32_u)) :-:
       ("rawupdatew16", (P.RAW_STORE (P.UINT 16), xw32w32_u)) :-:
       ("rawupdatei16", (P.RAW_STORE (P.INT 16), xw32i32_u)) :-:
       ("rawupdatew32", (P.RAW_STORE (P.UINT 32), xw32w32_u)) :-:
       ("rawupdatei32", (P.RAW_STORE (P.INT 32), xw32i32_u)) :-:
       ("rawupdatef32", (P.RAW_STORE (P.FLOAT 32), xw32f64_u)) :-:
       ("rawupdatef64", (P.RAW_STORE (P.FLOAT 64), xw32f64_u)) 

end (* local *)

fun primopMap name = RBMap.find(primops,name)

end (* structure PrimOpMap *)