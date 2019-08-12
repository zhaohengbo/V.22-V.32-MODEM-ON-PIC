;******************************************************************************
; File Name:   AGC.H
;******************************************************************************

;------------------------------------------------------------------------------
; AGC Module constant defines
;------------------------------------------------------------------------------

    .equ DEFAULTAGCGAIN,   0x0100      ;Assuming 0 dBm reference level = 0x29c0
    .equ AGC_REFERENCE,    0x0A00      ;-15dbm reference output level

;------------------------------------------------------------------------------
; AGC Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ SIZEOFAGC_NBSS,    6          ;size of the AGC data structure
    .equ SIZEOFAGC_BSS,    26          ;size of the AGC data structure

;------------------------------------------------------------------------------
; AGC Module: Global definations of variables
;------------------------------------------------------------------------------

    .global     AGCHiEngCntr           ;To keep track of input energy higher or
    .global     AGCLowEngCntr          ;lower than the minimum required energy
    .global     AGCInput               ;input sample to AGC
    .global     AGCEnergyStat          ;status of input signal energy
    .global     AGCOutput              ;AGC output buffer
    .global     AGCGain                ;The gain factor for AGC
    .global     AGCTC                  ;The time constant for AGC
    .global     AGCFreeze              ;used to stop updation of gain
    .global     AGCMeanPRunAvg         ;AGC Mean Parameter Run Average
    .global     AGCMeanPAvg            ;AGC Mean Parameter Average
    .global     AGCMeanPCntr           ;AGC Mean Parameter Counter
    .global     AGCMeanPLevel          ;AGC Mean Parameter Average Level
    .global     AGCMeanPIp             ;AGC Mean Parameter Input
    .global     AGCAutoStart           ;Used as a flag start AGC
    .global     AGCOutBuf              ;AGC output buffer
    .global     AGCOutBufIndex         ;Index for the AGC output Buffer

;******************************************************************************
; END OF FILE
;******************************************************************************
