;******************************************************************************
; File Name:   FILTER.H
;******************************************************************************

;------------------------------------------------------------------------------
; General Filters (FIR/IIR/Hilbert/PSF) Module constant defines
;------------------------------------------------------------------------------

    .equ BUTTERDLINELEN,  4            ;Butterworth delay line length
    .equ DBLBUTDLYLEN,    4            
    .equ BUTTERCOEFSLEN,  6            ;Butterworth Coefficients length

    .equ MAXPSFLEN,       8            ;Maximum psf length
    .equ HILB_FILT_LEN,   32           ;Hilbert filter length

;------------------------------------------------------------------------------
; Hilbert Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ SIZEOFHILB_YBSS_1,  5        ;size of the HILB data structure in bss
    .equ SIZEOFHILB_YBSS,    32       ;size of the HILB data structure in ybss

;------------------------------------------------------------------------------
; Hilbert Module: Global definations of variables
;------------------------------------------------------------------------------

    .global hilbDlyLine                ;Hilbert filter delay line
    .global hilbOp_I                   ;Hilbert filter output(I)
    .global hilbOp_Q                   ;Hilbert filter output(Q)
    .global hilbRealPtr                ;Hilbert filter delayline pointer for
                                       ;accessing real part of hilbert output
    .global hilbDlyPtr                 ;Hilbert filter delayline pointer
    .global hilbDlyEnd                 ;Pointer to end of the filter delay line
    .global hilbCoefPtr                ;Pointer to hilbert coefficients

;******************************************************************************
; END OF FILE
;******************************************************************************



