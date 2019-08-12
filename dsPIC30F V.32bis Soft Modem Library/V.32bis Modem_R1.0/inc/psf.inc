;******************************************************************************
;File Name:   PSF.H
;******************************************************************************

;------------------------------------------------------------------------------
; PSF Module constant defines
;------------------------------------------------------------------------------

    .equ MAXPSFLEN,        8           ;Maximum length of PS filter

;------------------------------------------------------------------------------
; PSF Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ SIZEOFPSF_BSS,    10
    .equ SIZEOFPSF_YBSS,   16

;------------------------------------------------------------------------------
; PSF Module: Global definations of variables
;------------------------------------------------------------------------------

    .global        PSFIpFactor         ;InterPolation factor used to
                                       ;interpolate the samples
    .global        PSFCoefAddress      ;PSF coefficients buffer pointer
    .global        PSFCoefPtr          ;Pointer to selected PSF coefs
    .global        PSFLen              ;Length of PS filter
    .global        PSFDlyIndex         ;Delay line pointer to PS filter
    .global        PSFDlyLen           ;PSF delay length
    .global        PSFOpI              ;PSF output component(I)
    .global        PSFOpQ              ;PSF output component(Q)
    .global        PSFIpI              ;PSF input component(I)
    .global        PSFIpQ              ;PSF input component(Q)
    .global        PSFDlyI             ;PS Filter delay line buffer(I)
    .global        PSFDlyQ             ;PS Filter delay line buffer(Q)

;******************************************************************************
;END OF FILE
;******************************************************************************
