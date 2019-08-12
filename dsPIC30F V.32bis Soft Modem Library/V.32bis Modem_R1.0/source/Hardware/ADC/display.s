

;******************************************************************************
;                                                                             *
;    Filename            :  display.s                                         *
;    Date                :  06/07/2004                                        *
;    File Version        :  1.0                                               *
;                                                                             *
;    Other Files Required: p30F6014.gld, p30f6014.inc                         *
;    Tools Used:MPLAB IDE       : 6.52.00                                     *
;               ASM30 Assembler : 1.20.01                                     *
;               Linker          : 1.20.01                                     *
;                                                                             *
;                                                                             *
;******************************************************************************
;    Additional Notes:                                                        *
;                                                                             *
;                                                                             *
;                                                                             *
;******************************************************************************

; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------
		.include "p30f6014.inc"


; -----------------------------------------------------------------------------
; Global Declarations for routines in Program Memory 
; -----------------------------------------------------------------------------
		.global _display
		.global _smp1val
		.global _smp2val
		.global _smp3val
		.global _temp1
		.global _temp2
		.global _temp3

		.global _InDataBuf
		.global _InDataW
	

; -----------------------------------------------------------------------------     
; Memory Allocation for variables in Data Memory 
; -----------------------------------------------------------------------------
		.section 	.bss
				.align 2
negtempflag: 	.space 2
_temp1:			.space 2
_temp2:			.space 2
_temp3:			.space 2
tempdoflag:		.space 2


; -----------------------------------------------------------------------------
; Memory Initialization for variables in Data Memory       
; -----------------------------------------------------------------------------
		.section	.data
smp1str:	.byte 0x0A, 0x0D
		    .ascii "Temperature= "
smp1val:	.ascii "+000.0 degC"

smp2str:	.byte 0x0A, 0x0D
		    .ascii "RP1= "
smp2val:	.ascii "0.00v"

smp3str:	.byte 0x0A, 0x0D
		    .ascii "RP2= "
smp3val:	.ascii "0.00v"

endsmpstr:  .byte 0x0A, 0x0D
        	.asciz " "          

.equ  StringLength, ((endsmpstr+3) - smp1str)


		.section .text
; -----------------------------------------------------------------------------     
; User code section in Program Memory
; -----------------------------------------------------------------------------
_display:
     push.d w0
	 push.d w2
 	 push.d w4
   		 
; -----------------------------------------------------------------------------
; Convert temperature reading from millivolts to degree Centigrade in hexadecimal	 
; -----------------------------------------------------------------------------
wait:btss  ADC_done, #0       ; wait until ADC conversions complete
	 bra   wait
	 bclr  ADC_done, #0
	 
	 clr   negtempflag
     mov   TempSens, w0
     sub   #0x0199, w0
     bra   c, not_subzerotemp
     mov   TempSens, w0
     mov   #0x0199, w1
     subr  w0, w1, w0
     setm  negtempflag
not_subzerotemp:
     rcall _adc2dec
	 mov   #smp1val, w1
	 mov   w1, _temp1
	 mov   #0x002B,w0
	 btsc  negtempflag, #0
	 inc2  w0, w0

; -----------------------------------------------------------------------------
; Convert temperature from hexadecimal to decimal fraction
; -----------------------------------------------------------------------------
	 mov.b  w0, [w1++]
	 mov.b  _adones, wreg
     mov.b  w0, [w1++]
     mov.b  _adtenths, wreg
     mov.b  w0, [w1++]
     mov.b  _adhundredths, wreg
     mov.b  w0, [w1++]

; -----------------------------------------------------------------------------
; Convert voltages measured from Potentiometers RP1 and RP2 to decimal fractions
; -----------------------------------------------------------------------------
     mov    _PotRP1, w0
     rcall  _adc2dec
     mov    #smp2val, w1
     mov   w1, _temp2
     rcall  refresh_adc_dispstr
         
     mov    _PotRP2, w0
     rcall  _adc2dec
     mov    #smp3val, w1
     mov   w1, _temp3
     rcall  refresh_adc_dispstr


; -----------------------------------------------------------------------------    
; Load up InDataBuf Transmit buffer for modem
; -----------------------------------------------------------------------------

	 clr     tempdoflag 
	 btsc    CORCON, #DL2
	 bra     donestpush
	 btss    CORCON, #DL1
	 bra     nodonest
donestpush:
	 push    DOSTARTL
	 push    DOSTARTH
	 push    DOENDL
	 push    DOENDH
	 push    DCOUNT
	 bset    tempdoflag, #0
	 
nodonest:
  	 mov    #smp1str, w1   
     do     #StringLength, clp
     clr    w0 
     clr    w3
     mov    #_InDataBuf, w2
     mov.b  _InDataW, wreg
     mov.b  w0, w3                      ;Get the Rx Buffer Write index
 
     mov.b  [w1++],[w2+w3]              ;Store the incoming data
    
     inc.b  w3,w3                       ;Increment the write Index
     mov    #128,w0

     cp     w3,w0                       ;Chk W Index > INDATABUFLEN
     bra    nz,SET_TXW_INDEX
    
     clr    w3                          ;Reset the write Index

SET_TXW_INDEX:

     mov   w3,w0
     mov.b wreg, _InDataW               ;Update the W index
clp: nop

	 btss    tempdoflag, #0
	 bra     finished_display
donestpop:
	 pop DCOUNT
	 pop DOENDH
	 pop DOENDL
	 pop DOSTARTH
	 pop DOSTARTL
	 
finished_display:
   	 pop.d  w4
     pop.d  w2
     pop.d  w0
        
     return
         
; -----------------------------------------------------------------------------
; The following routine will refresh the display character array with newly
; measured values from Pots RP1 and RP2      
; -----------------------------------------------------------------------------
refresh_adc_dispstr:         
     mov.b  _adones, wreg
     mov.b  w0, [w1++]
     inc    w1, w1			;skip the decimal point
     mov.b  _adtenths, wreg
     mov.b  w0, [w1++]
     mov.b  _adhundredths, wreg
     mov.b  w0, [w1++]
     return
         

	.end 

;*********************************************************************
;                                                                    *
;                       Software License Agreement                   *
;                                                                    *
;   The software supplied herewith by Microchip Technology           *
;   Incorporated (the "Company") for its dsPIC controller            *
;   is intended and supplied to you, the Company's customer,         *
;   for use solely and exclusively on Microchip dsPIC                *
;   products. The software is owned by the Company and/or its        *
;   supplier, and is protected under applicable copyright laws. All  *
;   rights are reserved. Any use in violation of the foregoing       *
;   restrictions may subject the user to criminal sanctions under    *
;   applicable laws, as well as to civil liability for the breach of *
;   the terms and conditions of this license.                        *
;                                                                    *
;   THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION.  NO           *
;   WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING,    *
;   BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND    *
;   FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE     *
;   COMPANY SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL,  *
;   INCIDENTAL OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.  *
;                                                                    *
;*********************************************************************

; -----------------------------------------------------------------------------
;         END OF FILE
; -----------------------------------------------------------------------------
        
           
