
(* absyntp.sml
 *
 * (C) 2007 The SML/NJ Fellowship
 *)
structure AbsynTP : ABSYNTP =
struct

local
  structure S = Symbol
  structure F = Fixity
  structure SP = SymPath
  structure B = Bindings
  structure LT = LtyExtern
  structure T = TypesTP
  structure A = Access
  structure V = VarCon
  structure ST = Stamps

  open Modules Types
in

type region = Ast.region  (* = int * int *)

datatype exp
  = VARexp of V.var ref * tyvar list
    (* the 2nd arg is a type mv list used to capture the instantiation
       parameters for this occurence of var when its type is polymorphic.
       FLINT will use these to provide explicit type parameters for
       var if var is bound to a primop. *)
  | CONexp of datacon * tyvar list (* ditto *)
  | INTexp of IntInf.int * ty
  | WORDexp of IntInf.int * ty
  | REALexp of string
  | STRINGexp of string
  | CHARexp of string
  | RECORDexp of (Absyn.numberedLabel * exp) list
  | SELECTexp of Absyn.numberedLabel * exp           (* record selections *)
  | VECTORexp of exp list * ty        
  | APPexp of exp * exp
  | HANDLEexp of exp * fnrules
  | RAISEexp of exp * ty              
  | CASEexp of exp * rule list * bool     (* true: match; false: bind *)
  | IFexp of { test: exp, thenCase: exp, elseCase: exp }
  | ANDALSOexp of exp * exp
  | ORELSEexp of exp * exp
  | WHILEexp of { test: exp, expr: exp }
  | FNexp of fnrules
  | LETexp of dec * exp
  | SEQexp of exp list
  | CONSTRAINTexp of exp * ty         
  | MARKexp of exp * region

and rule = RULE of Absyn.pat * exp 

and dec	
  = VALdec of vb list                  (* always a single element list *)
  | VALRECdec of rvb list
  | TYPEdec of tycon list
  | DATATYPEdec of {datatycs: tycon list, withtycs: tycon list}
  | ABSTYPEdec of {abstycs: tycon list, withtycs: tycon list, body: dec}
  | EXCEPTIONdec of eb list
  | STRdec of strb list
  | FCTdec of fctb list
  | SIGdec of Signature list
  | FSIGdec of fctSig list
  | OPENdec of (SP.path * Structure) list
  | LOCALdec of dec * dec
  | SEQdec of dec list
  | OVLDdec of V.var
  | FIXdec of {fixity: F.fixity, ops: S.symbol list} 
  | MARKdec of dec * region

(*
 * The "argtycs" field in APPstr is used to record the list of instantiated
 * hotycs passed to functor during the functor application.
 *)
and strexp 
  = VARstr of Structure 
  | STRstr of B.binding list
  | APPstr of {oper: Functor, arg: Structure, argtycs: T.tycpath list}
  | LETstr of dec * strexp
  | MARKstr of strexp * region

(*
 * For typing purpose, a functor is viewed as a high-order type constructor 
 * (hotyc) that takes a list of hotycs returns another list of hotycs. The
 * "argtycs" field in FCTfct records the list of formal hotyc paramaters.
 *)
and fctexp 
  = VARfct of Functor
  | FCTfct of {param: Structure, argtycs: T.tycpath list, 
	       def: strexp}
  | LETfct of dec * fctexp
  | MARKfct of fctexp * region

(*
 * Each value binding vb only binds one variable identifier. That is, 
 * pat is always a simple VARpat (with type constraints) or it simply
 * does not contain any variable patterns; boundtvs gives the list of
 * type variables that are being generalized at this binding. 
 *)
and vb = VB of {pat: Absyn.pat, exp: exp, boundtvs: tyvar list,
                tyvars: tyvar list ref} 

(*
 * Like value binding vb, boundtvs gives a list of type variables 
 * being generalized at this binding. However, the mutually recursive
 * list of RVBs could share type variables, that is, the boundtvs sets
 * used in these RVBs could contain overlapping set of type variables.
 *)
and rvb = RVB of {var: V.var, exp: exp, boundtvs: tyvar list,
                  resultty: ty option, tyvars: tyvar list ref}

and eb = EBgen of {exn: datacon, etype: ty option, ident: exp}
       | EBdef of {exn: datacon, edef: datacon} 

and strb = STRB of {name: S.symbol, str: Structure, def: strexp} 
and fctb = FCTB of {name: S.symbol, fct: Functor, def: fctexp}

withtype fnrules = rule list * Types.ty

end (* local *)
end