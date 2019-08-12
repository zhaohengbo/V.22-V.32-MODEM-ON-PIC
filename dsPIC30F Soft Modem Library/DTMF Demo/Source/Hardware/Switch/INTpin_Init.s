

;******************************************************************************
;                                                                             *
;    Author              :                                                    *
;    Company             :                                                    *
;    Filename            :  INTpin_Init.s                                     *
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
		

		.global  _Init_INTpin
		

 		.text
 
       

;..............................................................................
; Subroutine: Initialization of INTx pins
;..............................................................................
_Init_INTpin:

   		BSET   INTCON2, #INT1EP      ; set INT1 pin for active high detection
 		BSET   INTCON2, #INT2EP      ; set INT2 pin for active high detection      
   		    
      	SETM.B  TRISAH               ; ensure upper pins are input	    

		BCLR   IFS1, #INT1IF         ; ensure flag is reset		    
    	BCLR   IFS1, #INT2IF         ; ensure flag is reset
	
		BSET   IEC1, #INT1IE         ; ensure interrupt is enabled
		BSET   IEC1, #INT2IE         ; ensure interrupt is enabled

; INT pin Interrupt priorities default to 4 on reset (no change required for this debug code)

		RETURN
		
		.end
