(*
 * This file was automatically generated by MDGen
 * from the machine description file "ppc/ppc.md".
 *)


functor PPCDelaySlots(structure I : PPCINSTR
                      structure P : INSN_PROPERTIES
                         where I = I
                     ) : DELAY_SLOT_PROPERTIES =
struct
   structure I = I
   datatype delay_slot =
     D_NONE     
   | D_ERROR    
   | D_ALWAYS   
   | D_TAKEN    
   | D_FALLTHRU 
   
   fun error msg = MLRiscErrorMsg.error("PPCDelaySlots",msg)
   val delaySlotSize = 4

   fun delaySlot _ = {nop=true, n=false, nOn=D_ERROR, nOff=D_NONE}
   fun enableDelaySlot _ = error "enableDelaySlot"
   fun conflict _ = error "conflict"

   fun delaySlotCandidate _ = true
   fun setTarget _ = error "setTarget"
end

