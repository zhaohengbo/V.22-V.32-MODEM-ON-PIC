;******************************************************************************
; File Name:   SIGNAL.H
;******************************************************************************

;------------------------------------------------------------------------------
;Variable offsets used in the estimation of signal average level
;------------------------------------------------------------------------------

    .equ RunAvg, 0                     ;Accumulator to calculate the average 
                                       ;signal level
    .equ Avg,    4                     ;Average of i/p signal taken over a 
                                       ;window
    .equ Cntr,   6                     ;sample counter
    .equ Level,  8                     ;scaled signal level
    .equ Ip,     10                    ;Input sample


;******************************************************************************
; END OF FILE
;******************************************************************************


