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
   	  .include    "Device_Fcy.inc"
		
      .global _DigitStatus
		.global __INT1Interrupt  
		.global __INT2Interrupt  

.if  XTx8PLL    
.equ  debounce, 0xFFF
.equ  delay, 0x05FF
.endif

.if  XTx16PLL    
.equ  debounce, 0xFFF
.equ  delay, 0x08FF
.endif

 		.text

;..............................................................................
; INT1 pin Interrupt Service Handler (switch S1 on expansion board)
;..............................................................................

__INT1Interrupt:		
    RCALL  debounce_delay
    
    BSET  _HookStatus, #0	

    BCLR   IFS1, #INT1IF      ; ensure flag is reset		    
    RETFIE                    ; return from Interrupt Service routine
          

;..............................................................................
; INT2 pin Interrupt Service Handler (switch S2 on expansion board)
;..............................................................................

__INT2Interrupt:		
    RCALL  debounce_delay

    BSET   _DigitStatus,#0    
		
    BCLR   IFS1, #INT2IF      ; ensure flag is reset
    RETFIE                    ; return from Interrupt Service routine

 
debounce_delay:
    MOV #debounce, W11
cnt_dn:
    DEC W11, W11
    CP0 W11
    BRA NZ, cnt_dn
    RETURN
        

      
		.end
