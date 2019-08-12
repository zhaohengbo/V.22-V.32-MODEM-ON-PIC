
;******************************************************************************
; File Name:   DTMFTABLES.H
;******************************************************************************

;DTMF generation status indicators

   .equ DTMFSILENCE,    0x0001
   .equ DTMFSIGNAL,     0x0002
   .equ DTMFEND,        0x0004
   .equ DTMFFRMLENGTH,  80

   .global DtmfCounter
   .global DtmfState
   .global DtmfSilenceDuration
   .global DtmfToneDuration
   .global DtmfTxSmplCounter
   .global Digit
   .global DtmfStrIndex
   .global DtmfString
   .global dtmf_lowcos
   .global dtmf_highcos
   .global dtmf_low0
   .global dtmf_low1
   .global dtmf_high0
   .global dtmf_high1
   
;******************************************************************************
; END OF FILE
;******************************************************************************
