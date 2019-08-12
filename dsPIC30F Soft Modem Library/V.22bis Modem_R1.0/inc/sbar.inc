;******************************************************************************
; File Name:   SBAR.H
;******************************************************************************

;------------------------------------------------------------------------------
; S/SBAR detection Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ SIZEOFTRNDET_YBSS,   16

;------------------------------------------------------------------------------
; S/SBAR detection Module: Global definations of variables
;------------------------------------------------------------------------------

    ;Buffer ptr used to store the Demod points
    .global TRNDetectBufferPtr

    .global TRNDetectLength            ;Demod buffer length

    .global TRNDetectBuffer            ;Buffer used to store Demod points
    .global TRNDetectScntrSet          ;Counter(Fixed) used in detection of S
                                       ;signal
    .global TRNDetectScntr             ;Counter used in detection of S signal
    .global TRNDetectSDetect           ;Flag to indicate the detection of S

;******************************************************************************
; END OF FILE
;******************************************************************************





