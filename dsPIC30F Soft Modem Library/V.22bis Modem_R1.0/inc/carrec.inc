;******************************************************************************
; File Name:   CARREC.H
;******************************************************************************

;------------------------------------------------------------------------------
; Carrier Recovery Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ SIZEOFCARREC_BSS,    6        ;Size of Carrier recovery parameters

;------------------------------------------------------------------------------
; Carrier Recovery Module: Global definations of variables
;------------------------------------------------------------------------------

    .global    CarrecStatus            ;Carrier recovery enable/disable flag
    .global    CarrecPhase             ;carrier phase adjustment value
    .global    CarrecGammaRho          ;B.W of the carrier recovery PLL filter
    .global    CarrecPdOp              ;C.R. Phase detector output
    .global    CarrecPrevPdOp          ;C.R. previous phase detector output
    .global    CarrecPrevLoopIp        ;PLL loop filter output

;******************************************************************************
; END OF FILE
;******************************************************************************
