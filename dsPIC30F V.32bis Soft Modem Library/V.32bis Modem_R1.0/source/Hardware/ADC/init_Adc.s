
;******************************************************************************
;                                                                             *
;    Filename            :  init_adc.s                                        *
;    Date                :  06/08/2004                                        *
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
		.include "Device_Fcy.inc"


; -----------------------------------------------------------------------------
;    Global Declarations
; -----------------------------------------------------------------------------
		.global  _Init_ADC
		
		
 		.text

; -----------------------------------------------------------------------------
; Subroutine: Initialization of ADC Module
; -----------------------------------------------------------------------------
_Init_ADC:
		push  w0
 		clr   ADCON1               ; ensure registers to known state
 		clr   ADCON2
 		clr   ADCON3
 		clr   ADCHS
 		clr   ADCSSL               ; ensure registers to known state

; set port configuration here 		
 		bclr  ADPCFG, #PCFG3       ; ensure AN3/RB3 is analog
 	 	bclr  ADPCFG, #PCFG4       ; ensure AN4/RB4 is analog
 	 	bclr  ADPCFG, #PCFG5       ; ensure AN5/RB5 is analog

; set sample/conversion approach here 	
 		mov   #0x00E4, w0          ; auto sampling and convert
 		mov   w0, ADCON1           ; with default read-format mode
 
; Scan for CH0+, Use MUX A, BUFM = 1 (one 16-word buffer), SMPI = 3 per interrupt
		mov   #0x0408, w0
		mov   w0,  ADCON2
				
; A/D Conversion Tad ( minimum Tad = 667nS )
; Autosampling of 3 Tad	

.if  XTx4PLL          ; Tcy = 135ns, so 10/2 * Tcy = Tad min
		mov   #0x0309, w0
.endif

.if   XTx8PLL         ; Tcy = 68ns, so 20/2 * Tcy = Tad min
		mov   #0x0314, w0
.endif

.if   XTx16PLL        ; Tcy = 34ns, so 40/2 * Tcy = Tad min
		mov   #0x0328, w0
.endif
 	
		mov   w0,  ADCON3
		
; set channel scanning here 	
 		mov   #0b0000000000111000, w0
 		mov   w0, ADCSSL           ; scan for AN3, AN4 and AN5

; set ADC priority to 4 		
 		bclr  IPC2, #ADIP0
 		bclr  IPC2, #ADIP1
 		bset  IPC2, #ADIP2  

		bclr  IFS0, #ADIF		  ; clear the interrupt flag
		bset  IEC0, #ADIE		  ; enable interrupt

; enable ADC in SMUA_OL.c file		
;	bset  ADCON1, #ADON       ; enable ADC	
 		pop   w0
    
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
