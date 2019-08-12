/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               SBAR.S                                             *
;  Date:                   12th  August,2002                                  *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.43.00.0                             *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;  Revision History:                                                          *
; ----------------------------------------------------------------------------*
; Rev:   Date:              Details:                                Who:      *
; ----------------------------------------------------------------------------*
; 0.1   12 July   2002   Code Created                                Ravi     *
; 0.2   13 July   2002   Code Reviewed                               Raghava  *
; 0.3   13 August 2002   Modified file/function header               Ravi     *
; 0.4   20 August 2002   Corrected code documentation faults         Ravi     *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Trn Detector(S/Sbar Detector)implementation for Microchip's dsPIC30F 16-bit*
;  MCU.                                                                       *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;                                                                             *
;  InitTrnDetector:                                                           *
;  ======================                                                     *
;  Description:  Initializes the parameters for the detection of Phase        *
;                reversal                                                     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w3 used not restored                                          *
;                                                                             *
;  Functions Called: ClearSDetectVars                                         *
;                                                                             *
;******************************************************************************
;  TrnDetector:                                                               *
;  ======================                                                     *
;  Description: This function is used to detect the S signal                  *
;                                                                             *
;  Input:  w0 = phase angle                                                   *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w4, w5, w6 used not restored                                      *
;   AccA               used not restored                                      *
;                                                                             *
;  Functions Called: TrnDetector2                                             *
;                                                                             *
;******************************************************************************
;  TrnDetector2:                                                              *
;  ======================                                                     *
;  Description: This function is used to detect the phase reversal in the     *
;               received signal, likr S-SBAR transition                       *
;                                                                             *
;  Input:  w0 = demod point                                                   *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w3, w4, w8, w9, w10, w11, w12 used not restored               *
;                                                                             *
;  Functions Called: None                                                     *
;                                                                             *
;******************************************************************************
;  ClearSDetectVars:                                                          *
;  ======================                                                     *
;  Description: This function clears Trn Detect variables.                    *
;                                                                             *
;  Input:  void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1                                    used not restored               *
;                                                                             *
;  Functions Called: ClearStruct                                              *
;                                                                             *
;******************************************************************************
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :     1                                        *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitTrnDetector:               04                                       *
;     TrnDetector:                   21                                       *
;     TrnDetector2:                  43                                       *
;     ClearSDetectVars:              13                                       * 
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;     .nbss:                        01                                        *
;     .bss:                         19                                        *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitTrnDetector:                07                                      *
;     TrnDetector:                    24                                      *
;     TrnDetector2:                   35                                      *
;     ClearSDetectVars:               15                                      *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "sbar.inc"
    .include "defs.inc"
    .include "modem.inc"
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _InitTrnDetector
    .section  .libsm, "x"
    
_InitTrnDetector:
    
    rcall      ClearSDetectVars
    
    mov        #70, w3
    mov        w3, TRNDetectScntrSet   ;Set value for the S counter
    
    return


; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _TrnDetector
    .section  .libsm, "x"
    
_TrnDetector:


    push       w0
    cp0.b      mdmDetEqzTrn            ;and return if phase reversal is already
    bra        z, SINE_COSINE          ;detected
    pop        w0
    return

SINE_COSINE:
    
   ;Generate the Carrier phase for demodulation
    pop        w0
    neg        w0, w0                      
       
    mov        #0x3fff, w6
    add        w0, w6, w1
    
    call       _SinCos        
    
    ;Demodulation
    
    mov        hilbOp_I, w4                             
    mov        w1, w5
    mpy        w4*w5, A                ;HILBOP_I * Cos(RxCarrrier)
    
    mov        hilbOp_Q, w4                
    mov        w0, w5
    mpy        w4*w5, B                ;HILBOP_Q * Sin(RxCarrrier)
    
    sub        A
    
    sac.r      A, w0                       
    
    rcall      _TrnDetector2           ;Detect S or S/SBAR - Phase Reversal
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _TrnDetector2
    .section  .libsm, "x"
    
_TrnDetector2:
    
    ;Update the Demod buffer with the demod point
    
    mov         w0,w2
    mov         #TRNDetectBuffer, w3

    clr         w0
    mov.b       TRNDetectBufferPtr, wreg        
    inc2.b     w0,w1   
    mov         [w3+w0],w4                 
    mov          w2,[w3+w0]

    ;Update the buffer index and reset the buffer index circularly
    
    mov.b      TRNDetectLength, wreg
    sl         w0,#1,w0

    cp.b       w1, w0
    bra        lt, PRIME_12_SAMP_BUF

    clr        w1
    
PRIME_12_SAMP_BUF:

    mov        w1,w0
    mov.b      wreg,TRNDetectBufferPtr

    cp0        w4
    bra        nz, NOPRIME
    return
    
NOPRIME:
    
    ;Get the difference between the two demodualtion points

    sub        w4, w2, w4
    btsc       w4, #15
    neg        w4, w4
    
    mov        TRNDetectSDetect, w11   ;Check S detection flag
    cp0        w11
    bra        nz, CHECK_SBAR

    ;Based on the difference (0x4000) update the S detect counter
    
    mov        TRNDetectScntr, w9
    mov        #4000, w8
    
    cp         w4, w8
    bra        le, SET_SCNTR
    
    ;If the difference is less than 0x4000 clear the S counter
    
    clr        w9
    mov        w9, TRNDetectScntr
    return
SET_SCNTR:

    ;Increment the S counter if difference is greater than 0x4000
    
    add        w9, #1, w9
    mov        w9, TRNDetectScntr
    mov        TRNDetectScntrSet, w10    
    
    cp         w9, w10
    bra        le, RETURNED
    
    mov        #1, w11
    mov        w11, TRNDetectSDetect   ;Set the S detect flag
    
RETURNED:
    return
    
CHECK_SBAR:
    
    ;After S detection look for S-SBAR transition (Phase Reversal)
    
    mov       #2800, w12
    
    cp        w4, w12
    bra       le, EXIT_TRN_DETECT
    
    inc.b     mdmDetEqzTrn             ;Set Phase-Reversal detection flag
EXIT_TRN_DETECT:
    return
    

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global ClearSDetectVars
    .section  .libsm, "x"

ClearSDetectVars:

    clr.b      TRNDetectBufferPtr
    clr.b      TRNDetectLength
        
    clr        w0
    mov        w0,TRNDetectScntrSet
    mov        w0,TRNDetectScntr
    mov        w0,TRNDetectSDetect
    
    mov        #TRNDetectBuffer, w0
    mov        #SIZEOFTRNDET_YBSS, w1
    
    call       _ClearStruct            ;Clears the Trn Det structure members

    clr.b      w0                      ;Clear Phase reversal detection counter
    mov.b      wreg, mdmDetEqzTrn           
   
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
.endif

; -----------------------------------------------------------------------------
;   END OF FILE
; -----------------------------------------------------------------------------
    
