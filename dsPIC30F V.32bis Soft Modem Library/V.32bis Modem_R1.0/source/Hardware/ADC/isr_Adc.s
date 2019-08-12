
;******************************************************************************
;                                                                             *
;    Filename            :  isr_adc.s                                         *
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

.include "p30f6014.inc"


;Global Declarations for routines in Program Memory 
.global __ADCInterrupt

;Global Declarations for variables in Data Memory 
.global   _PotRP1
.global   _PotRP2
.global   TempSens
.global   ADC_done

;Memory Allocation for variables in Data Memory 
.section .data
_PotRP1:   .space 2
_PotRP2:   .space 2
TempSens:  .space 2
ADC_done:  .space 2

;User code section in Program Memory
.section .text

__ADCInterrupt:
	push.d w0

	mov   #ADCBUF0, w0	   	; Save off the Potentiometer and 
	mov   [w0++], w1		; Temperature sensor values
	mov   w1, TempSens			
	mov   [w0++], w1
	mov   w1, _PotRP1
	mov   [w0++], w1
	mov   w1, _PotRP2

	bclr  IFS0, #ADIF       ; reset interrupt flag
	bclr  ADCON1, #ADON 

	bset  ADC_done, #0
	pop.d w0

	disi #1
	retfie

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

      
    
