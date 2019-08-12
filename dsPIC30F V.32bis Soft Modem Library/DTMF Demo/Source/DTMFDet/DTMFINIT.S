/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               DTMFInit.S                                         *
;  Date:                   24th May, 2004                                     *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.50.00                               *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;  Revision History:                                                          *
; ----------------------------------------------------------------------------*
; Rev:   Date:              Details:                                Who:      *
; ----------------------------------------------------------------------------*
; 0.1   11 Sept   2002   Code Created                                Rajiv    *
; 0.2   16 Sept   2002   Code Reviewed                               Raghava  *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  DTMF Detector initialization for Microchip's dsPIC30F 16-bit MCU.          *
;                                                                             *
;  Description: The parameters are initialized for DTMF Detection.            *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;  DTMFInit:                                                                  *
;  ======================                                                     *
;  Description: This function initializes parameters for DTMF detection.      *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w8               used not restored                                  *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   0                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     DTMFInit:        19                                                     *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;     None                                                                    *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     DTMFInit:        121                                                    *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "Detconst.inc"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _DTMFInit
;    .section  .libdtmf, "x"
    .section  .text
    
; -----------------------------------------------------------------------------
;  Description:   This function initializes parameters for DTMF detection.
; -----------------------------------------------------------------------------
_DTMFInit:

    bclr.b     CORCON, #5

    mov        #DTMFworkBuff, w8       ;Base Address of the working Buffer
    clr        w1

    repeat     #99
    mov        w1, [w8++]              ;Clear the Buffer

    mov        #YES, w0
    mov        w0, DTMFshapeTest       ;Disable the Shape Test

    mov        #NOT_A_DIGIT_FRAME, w0
    mov        w0, DTMFframeType       ;Init frametype

    mov        #20, w0
    mov        w0, DTMFcurrentDigit    ;Init 20 as the Current Digit

    mov        #30, w0
    mov        w0, DTMFdeclaredDigit   ;Init 30 as the prev detected digit

    mov        w1, DTMFsilenceCount    ;Clear the silence count
; Clear all the thresholds    
    mov        w1, DTMFSilenceThreshold 
    mov        w1, DTMFSilenceThreshold+2 
    mov        w1, DTMFEnergyThreshold
    mov        w1, DTMFEnergyThreshold+2
    mov        w1, DTMFsubframeCount
    
    return

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------

