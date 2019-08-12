;******************************************************************************
;FILE NAME:    DPCONFIG.INC
;******************************************************************************

/*-------------------------------------------------------------------------
 Data pump Modulation configuration options
--------------------------------------------------------------------------*/

;******************************************************************************
; Data pump modulation selection definitions
;******************************************************************************

;------------------------------------------------------------------------------
; Always Enable the following options, since the following options are
; required for all the modulation protocols
;------------------------------------------------------------------------------

    .equ DEF_CALLPROG,    1            ;Enable call progress
    .equ DEF_V25,         1            ;enable V.25
    .equ DEF_V8,          1            ;Enable V.8
    .equ DEF_V21,         1            ;Enable V.21
    .equ DEF_B103,        1            ;Enable B103

;------------------------------------------------------------------------------
; Selection of different Modulation protocols.
;------------------------------------------------------------------------------

    .equ DEF_V32BIS,      0            ;Enable/Disable V.32bis
    .equ DEF_V32,         0            ;Enable/Disable V.32
    .equ DEF_V22,         1            ;Enable/Disable V.22
    .equ DEF_V23,         1            ;Enable/Disable V.23

;Note: In V.32/V.32bis case, Enabling only V.32bis and disabling V.32, that is 
;DEF_V32BIS = 1 and DEF_V32 = 0 is not supported. But enabling only V.32 
;and disable V.32bis, that is DEF_V32BIS = 0 and DEF_V32 = 1 is supported

;------------------------------------------------------------------------------
; Enable the following options only if V.42 is enabled
;------------------------------------------------------------------------------

    .equ DEF_HDLC,        1            ;Enable/Disable HDLC protocol

;******************************************************************************
; END OF FILE
;******************************************************************************
