(* Copyright 1996 by Bell Laboratories *)
(* evalloop.sml *)
 
functor EvalLoopF(Compile: TOP_COMPILE) : EVALLOOP =
struct

local open Environment
      structure C  = Compile
      structure EM = ErrorMsg
      structure E  = Environment
      structure PP = PrettyPrintNew
      structure T = Time
      structure U = Unsafe
      structure PC = SMLofNJ.Internals.ProfControl
      structure ED = ElabDebug

      open PP
in 

exception Interrupt
type lvar = Access.lvar

val compManagerHook :
    { manageImport : Ast.dec * EnvRef.envref -> unit,
      managePrint :  Symbol.symbol * EnvRef.envref -> unit,
      getPending : unit -> Symbol.symbol list } ref =
    ref { manageImport = fn _ => (),
	  managePrint = fn _ => (),
	  getPending = fn () => [] }

fun installCompManagers cm = compManagerHook := cm

val say = Control.Print.say

exception EndOfFile

fun interruptable f x =
    let val oldcont = !U.topLevelCont
     in U.topLevelCont :=
         SMLofNJ.Cont.callcc
            (fn k => (SMLofNJ.Cont.callcc(fn k' => (SMLofNJ.Cont.throw k k'));
	              raise Interrupt));
        (f x before U.topLevelCont := oldcont)
        handle e => (U.topLevelCont := oldcont; raise e)
    end

exception ExnDuringExecution of exn

(* 
 * The baseEnv and localEnv are purposely refs so that a top-level command
 * can re-assign either one of them, and the next iteration of the loop
 * will see the new value. It's also important that the toplevelenv
 * continuation NOT see the "fetched" environment, but only the ref;
 * then, if the user "filters" the environment ref, a smaller image
 * can be written. 
 *)

fun evalLoop source = let
    val parser = SmlFile.parseOne source
    val cinfo = C.mkCompInfo { source = source, transform = fn x => x }

    fun checkErrors (s: string) = 
        if CompInfo.anyErrors cinfo then
           (if !Control.progressMsgs then say ("<<< Error stop after "^s^"\n")
            else ();
            raise EM.Error)
        else if !Control.progressMsgs then say ("<<< "^s^" successful\n")
        else ()

    fun oneUnit () = (* perform one transaction  *)
	case parser () of
	    NONE => raise EndOfFile
	  | SOME ast => let
		val loc = EnvRef.loc ()
		val base = EnvRef.base ()
		val _ = #manageImport (!compManagerHook) (ast, loc)

		fun getenv () = E.layerEnv (#get loc (), #get base ())

                val {static=statenv, dynamic=dynenv, symbolic=symenv} =
		    getenv ()

                val splitting = Control.LambdaSplitting.get ()
                val {csegments, newstatenv, absyn, exportPid, exportLvars,
                     imports, inlineExp, ...} = 
                    C.compile {source=source, ast=ast,
			       statenv=statenv,
                               symenv=symenv,
			       compInfo=cinfo, 
                               checkErr=checkErrors,
                               splitting=splitting,
			       guid = (),
			       extRefInfo = fn _ => NONE }

                (** returning absyn and exportLvars here is a bad idea,
                    they hold on things unnecessarily; this must be 
                    fixed in the long run. (ZHONG)
                 *)

                val executable = Execute.mkexec
				     { cs = csegments,
				       exnwrapper = ExnDuringExecution }
				 before checkErrors ("mkexec")
                val executable = Isolate.isolate (interruptable executable)

                val _ = (PC.current := Profile.otherIndex)
                val newdynenv = 
                    Execute.execute { executable=executable, imports=imports,
				      exportPid=exportPid, dynenv=dynenv }
                val _ = (PC.current := Profile.compileIndex)

                val newenv =
		    E.mkenv { static = newstatenv,
			      dynamic = newdynenv, 
                              symbolic = SymbolicEnv.mk (exportPid,inlineExp) }
                val newLocalEnv = E.concatEnv (newenv, #get loc ())
                    (* refetch loc because execution may 
                       have changed its contents *)


		(* start adding testing code of ppast.ppdec here *)
		val debugging = ref true

		val printDepth = Control_Print.printDepth
				 
		fun debugPrint (debugging: bool ref)
                    (msg: string, printfn: PP.stream -> 'a -> unit, arg: 'a) =
                    if (!debugging) then
                        with_pp (EM.defaultConsumer())
                                (fn ppstrm =>
                                    (openHVBox ppstrm (PP.Rel 0);
                                     PP.string ppstrm msg;
                                     newline ppstrm;
                                     openHVBox ppstrm (PP.Rel 0);
                                     printfn ppstrm arg;
                                     closeBox ppstrm;
                                     newline ppstrm;
                                     closeBox ppstrm;
                                     flushStream ppstrm))
                    else ()

		fun ppAstDebug (msg,dec) =
		    let fun ppAstDec ppstrm d = 
                            PPAst.ppDec (statenv,NONE) ppstrm (d,!printDepth)
                     in debugPrint (Control.printAst) (msg, ppAstDec, dec)
                    end
		    
		fun ppAbsynDebug (msg,dec) =
		    let fun ppAbsynDec ppstrm d = 
                            PPAbsyn.ppDec (statenv,NONE) ppstrm (d,!printDepth)
                    in debugPrint (Control.printAbsyn) (msg, ppAbsynDec, dec)
                    end

		(* we install the new local env first before we go about
		 * printing, otherwise we find ourselves in trouble if
		 * the autoloader changes the the contents of loc under
		 * our feet... *)

		val _ = #set loc newLocalEnv

		fun look_and_load sy = let
		    fun look () = StaticEnv.look (E.staticPart (getenv ()), sy)
		in
		    look ()
		    handle StaticEnv.Unbound =>
			   (#managePrint (!compManagerHook) (sy, loc);
			    look ())
		end

		(* Notice that even through several potential rounds
		 * the result of get_symbols is constant (up to list
		 * order), so memoization (as performed by
		 * StaticEnv.special) is ok. *)
		fun get_symbols () = let
		    val se = E.staticPart (getenv ())
		    val othersyms = #getPending (!compManagerHook) ()
		in
		    StaticEnv.symbols se @ othersyms
		end

		val ste1 = StaticEnv.special (look_and_load, get_symbols)

		val e0 = getenv ()
		val e1 = E.mkenv { static = ste1,
				   symbolic = E.symbolicPart e0,
				   dynamic = E.dynamicPart e0 }


		val _ = Ens_print.maj (E.staticPart e1)
		(*val s = Pickle_ens.test ()
		val all = Pickle_ens.test_back s
		val _ = Ens_print.print_all all*)
		
            in
		(* testing code to print ast *)
		ppAstDebug("AST::",ast);
		(* testing code to print absyn *)
		ppAbsynDebug("ABSYN::",absyn);

		PP.with_pp
		    (#errConsumer source)
		    (fn ppstrm => PPDec.ppDec e1 ppstrm (absyn, exportLvars))
            end

    fun loop() = (oneUnit(); loop())
in
    interruptable loop ()
end (* function evalLoop *)

fun withErrorHandling treatasuser { thunk, flush, cont = k } =
    let fun showhist' [s] = say (concat["  raised at: ", s, "\n"])
          | showhist' (s::r) =
	      (showhist' r; say (concat ["             ", s, "\n"]))
          | showhist' [] = ()

	fun exnMsg (CompileExn.Compile s) = concat ["Compile: \"", s, "\""]
          | exnMsg exn = General.exnMessage exn

	fun showhist e = showhist' (SMLofNJ.exnHistory e)

	fun user_hdl (ExnDuringExecution exn) = user_hdl exn
	  | user_hdl exn =
	    let val msg = exnMsg exn
		val name = exnName exn
	    in if msg = name then
		   say (concat ["\nuncaught exception ", name, "\n"])
	       else say (concat ["\nuncaught exception ",
				 name, " [", msg, "]\n"]);
	       showhist exn;
	       flush (); 
	       k exn
	    end

	fun bug_hdl exn =
	    let val msg = exnMsg exn
		val name = exnName exn
	    in say (concat ["\nunexpected exception (bug?) in SML/NJ: ",
			    name," [", msg, "]\n"]);
	       showhist exn;
	       flush();
	       k exn
	    end

	fun non_bt_hdl e =
	    case e of
		EndOfFile => (say "\n")
              | (Interrupt | ExnDuringExecution Interrupt) =>
		  (say "\nInterrupt\n"; flush(); k e)
              | EM.Error => (flush(); k e)
              | CompileExn.Compile "syntax error" => (flush(); k e)
              | CompileExn.Compile s =>
                  (say(concat["\nuncaught exception Compile: \"", s,"\"\n"]);
                   flush(); k e)
              | Isolate.TopLevelCallcc =>
                  (say("Error: throw from one top-level expression \
		       \into another\n");
                   flush (); k e)
	      | (Execute.Link | ExnDuringExecution Execute.Link) =>
		  (flush (); k e)
	      | ExnDuringExecution exn => user_hdl exn
	      | exn => if treatasuser then user_hdl exn else bug_hdl exn
    in SMLofNJ.Internals.TDP.with_monitors false thunk
       handle e => non_bt_hdl e
    end

(*** interactive loop, with error handling ***)
fun interact () =
    let val source = Source.newSource ("stdIn", 1, TextIO.stdIn, true,
                                       EM.defaultConsumer ())
	fun flush' () =
            case TextIO.canInput(TextIO.stdIn, 4096) of
		(NONE | SOME 0) => ()
              | SOME _ => (ignore (TextIO.input TextIO.stdIn); flush'())

	fun flush () = (#anyErrors source := false;
			flush'() handle IO.Io _ => ())

	fun loop () = withErrorHandling false
			{ thunk = fn () => evalLoop source,
			  flush = flush, cont = loop o ignore }
    in loop ()
    end

fun isTermIn f = 
    let val (rd, buf) = TextIO.StreamIO.getReader(TextIO.getInstream f)
	val isTTY = 
            case rd of
		TextPrimIO.RD{ioDesc = SOME iod, ...} =>
                  (OS.IO.kind iod = OS.IO.Kind.tty)
              | _ => false
    in (* since getting the reader will have terminated the stream, we need
        * to build a new stream. *)
	TextIO.setInstream(f, TextIO.StreamIO.mkInstream(rd, buf));
	isTTY
    end

fun evalStream (fname, stream) =
    let val interactive = isTermIn stream
	val source = Source.newSource (fname, 1, stream, interactive,
                                       EM.defaultConsumer ())
    in evalLoop source
       handle exn => (Source.closeSource source;
		      case exn of
			  EndOfFile => () 
			| _ => raise exn)
    end

end (* top-level local *)
end (* functor EvalLoopF *)
