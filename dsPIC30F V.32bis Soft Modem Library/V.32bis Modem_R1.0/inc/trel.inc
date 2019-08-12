;******************************************************************************
; File Name:   TREL.INC
;******************************************************************************

;------------------------------------------------------------------------------
; Trellis Encoder DM variables length defineations
;------------------------------------------------------------------------------

    .equ SIZEOFTRELENC_NBSS,    11        ;size of the Trellis encoder data 
                                          ;structure

;------------------------------------------------------------------------------
; Trellis Encoder: Global definations of variables
;------------------------------------------------------------------------------

    .global TrelBitsPerBaud
    .global TrelExtraShift
    .global TrelPrevTxPhase
    .global TrelCoordsPtr
    .global TrelDiffEncTabPtr
    .global TrelS0n
    .global TrelS1n
    .global TrelS2n
    .global TrelBitPattern
    .global TrelY0n
    .global TrelY1n
    .global TrelY2n
    .global TrelDebugCntr
;******************************************************************************
; END OF FILE
;******************************************************************************
