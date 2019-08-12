;******************************************************************************
;                                                                             *
;    Author              :                                                    *
;    Company             :                                                    *
;    Filename            :  INTx_Interrupt.s                                  *
;    Date:                 24th May, 2004                                     *
;                                                                             *
;    Tools used:           MPLAB IDE -> 6.50.00                               *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;    Other Files Required: p30F6014.gld, p30f6014.inc                         *
;                                                                             *
;    Devices Supported by this file:                                          *
;                        dsPIC 30F6014                                        *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Additional Notes:                                                        *
;                                                                             *
;                                                                             *
;                                                                             *
;                                                                             *
;******************************************************************************

      .include "p30f6014.inc"
   	  .include "Device_Fcy.inc"
		
      .global __INT2Interrupt  
	  .global _TermCall
	

 		.text



;..............................................................................
; INT2 pin Interrupt Service Handler (switch S2 on board)
;..............................................................................

__INT2Interrupt:		
    BSET   _TermCall, #0    
		
    BCLR   IFS1, #INT2IF      ; ensure flag is reset
    disi #1
    RETFIE                    ; return from Interrupt Service routine


        

      
		.end
