;******************************************************************************
; File Name:   TONED.H
;******************************************************************************

;------------------------------------------------------------------------------
;Variable offsets used in the detection of various tones
;------------------------------------------------------------------------------

    .equ tdAPRunAvg,     0             ;Accumulator to calculate the average
                                       ;signal level
    .equ tdAPAvg,        4             ;Average of i/p signal taken over a
                                       ;window
    .equ tdAPCntr,       6             ;sample counter
    .equ tdAPLevel,      8             ;scaled signal level
    .equ tdAPIp,         10            ;Input sample
    .equ tdAPToneStatus, 12
    .equ tdAPThreshold,  14

;******************************************************************************
; END OF FILE
;******************************************************************************
