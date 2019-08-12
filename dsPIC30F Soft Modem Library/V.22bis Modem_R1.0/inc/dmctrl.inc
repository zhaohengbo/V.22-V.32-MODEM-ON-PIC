;******************************************************************************
; File Name:   DMCTRL.H
;******************************************************************************

;------------------------------------------------------------------------------
; DM Control Module: Global definations of variables
;------------------------------------------------------------------------------

    .global dmcCarrierTimer
    .global dmcTxBufferLength
    .global dmcRxBufferLength

    .global AMV32DetectCntr           ;Counter used to validated V.32 signal

;------------------------------------------------------------------------------
;Variables used for the estimation of average level of V.32 signal
;------------------------------------------------------------------------------

    .global AMV32DetectAPRunAvg
    .global AMV32DetectAPAvg
    .global AMV32DetectAPCntr
    .global AMV32DetectAPLevel
    .global AMV32DetectAPIp

    .global AMV22DetectCntr           ;Counter used to validated V22 signal

;------------------------------------------------------------------------------
;Variables used for the estimation of average level of V.22 signal
;------------------------------------------------------------------------------

    .global AMV22DetectAPRunAvg
    .global AMV32DetectAPAvg
    .global AMV22DetectAPCntr
    .global AMV22DetectAPLevel
    .global AMV22DetectAPIp

    .global AMV21DetectCntr           ;Counter used to validated V.21 signal

;------------------------------------------------------------------------------
;Variables used for the estimation of average level of V.21 signal
;------------------------------------------------------------------------------

    .global AMV21DetectAPRunAvg
    .global AMV32DetectAPAvg
    .global AMV21DetectAPCntr
    .global AMV21DetectAPLevel
    .global AMV21DetectAPIp

;------------------------------------------------------------------------------
;Filter delay lines used for the detection of V.32/V.22/V.21 signals
;------------------------------------------------------------------------------

    .global AMV32DetectDelayLine
    .global AMV22DetectDelayLine
    .global AMV21DetectDelayLine

;******************************************************************************
; END OF FILE
;******************************************************************************
