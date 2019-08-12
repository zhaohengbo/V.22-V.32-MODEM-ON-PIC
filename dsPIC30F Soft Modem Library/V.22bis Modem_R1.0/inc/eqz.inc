;******************************************************************************
; File Name:   EQZ.H
;******************************************************************************

;------------------------------------------------------------------------------
; Equalizer Module constant defines
;------------------------------------------------------------------------------

    .equ MAXEQZLEN,          64                ;Maximum Equalizer Length

;------------------------------------------------------------------------------
; Equalizer Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ SIZEOFEQZ_BSS_1,  6           ;size of the EQZ data structure in bss
    .equ SIZEOFEQZ_BSS_2,  13          ;size of the EQZ data structure in bss

    .equ SIZEOFEQZ_XBSS,   128         ;size of the EQZ data structure in xbss
    .equ SIZEOFEQZ_YBSS,   128         ;size of the EQZ data structure in ybss

;------------------------------------------------------------------------------
; Equalizer Module: Global definations of variables
;------------------------------------------------------------------------------

    .global eqzIpI                     ;Equalizer input symbol (I)
    .global eqzIpQ                     ;Equalizer input symbol (Q)
    .global eqzOpI                     ;Equalizer output symbol(I)
    .global eqzOpQ                     ;Equalizer output symbol(Q)

    .global eqzSpan                    ;Equalizer filter length
    .global eqzDlyI                    ;Equalizer delay line buffer(I)
    .global eqzDlyQ                    ;Equalizer delay line buffer(Q)
    .global eqzCoefsI                  ;Equalizer Coefficients I
    .global eqzCoefsQ                  ;Equalizer Coefficients Q
    .global eqzDlyPtr                  ;Equalizer filter delayline pointer
    .global eqzBBErrorI                ;Baseband error component(I)
    .global eqzBBErrorQ                ;Baseband error component(Q)
    .global eqzErrorI                  ;Equalizer error vector (I)
    .global eqzErrorQ                  ;Equalizer error vector (Q)
    .global eqzTrnOffset               ;Offset of the main tap from center of
                                       ;the equalizer in terms of bauds
    .global eqzStepSize                ;Step size for the equalizer adaption
    .global eqzMse                     ;Mean Square Error of error
    .global eqzFSEDivFactor            ;Equalizer FSE division factor
    .global eqzTrnDecoder              ;Pointer for equalizer TRN decoder
    .global eqzMTSmplPos               ;position of the main tap of equalizer
                                       ;(samples)
    .global eqzMTBaudPos               ;position of the main tap of equalizer
                                       ;(bauds)
    .global eqzFlockStatus             ;equalizer based clock recovery
                                       ;enable/disable flag
    .global eqzFlockBaudCnt            ;Counter for phase adjustment for clock
                                       ;recovery
    .global eqzFlockRefTapEgy          ;Energy of the equalizer tap
    .global eqzFlockBaudCntSet         ;initialized counter for equalizer
                                       ;flockbaud
    .global eqzCntr                    ;Counter for equalizer adaption
    .global eqzCntrSet                 ;initialized counter for equalizer
                                       ;adaption
    
    .global eqzMSEInput
    .global eqzMSEOutput1
    .global eqzMSEOutput2

;******************************************************************************
; END OF FILE
;******************************************************************************


