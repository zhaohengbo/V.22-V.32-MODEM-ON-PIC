
	.include	"p30f6014.inc"
	.include    "Device_Fcy.inc"
	

; Macros to load configuration fuse bits in MPLAB IDE for ICD2/Pro Mate II
; Note: If using ICD2 as a Debugger, ensure Comm Channel Select is 
;       properly selected for your application. 

.if  XTx4PLL          
	config          __FOSC, CSW_FSCM_OFF & XT_PLL4
.endif

.if   XTx8PLL         
	config          __FOSC, CSW_FSCM_OFF & XT_PLL8
.endif

.if   XTx16PLL       
	config          __FOSC, CSW_FSCM_OFF & XT_PLL16
.endif

	
	config          __FWDT, WDT_OFF
	config          __FBORPOR, PBOR_OFF & BORV_45 & MCLR_EN
	config          __FGS, CODE_PROT_OFF

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
