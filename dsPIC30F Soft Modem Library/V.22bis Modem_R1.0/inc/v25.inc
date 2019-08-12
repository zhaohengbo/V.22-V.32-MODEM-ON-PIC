;******************************************************************************
; File Name:   V25.H
;******************************************************************************

;------------------------------------------------------------------------------
; V.25 Module constant defines
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;    Types of answer tones defined
;------------------------------------------------------------------------------

    .equ  V25_TYPE1,       0               ;No phase reversals
    .equ  V25_TYPE2,       1               ;Phase reversals at 450 ms interval
    .equ  V25_TYPE3,       2               ;V.8 AnsAm tone

;------------------------------------------------------------------------------
; The following constants are used only in the originate mode and are
; with respect to a sampling rate of 8000 Hz
;------------------------------------------------------------------------------

    .equ  V25_1750MS,      12600
    .equ  V25_600MS,       4320
    .equ  V25_1000MS,      8000
    .equ  V25_500MS,       4000

;------------------------------------------------------------------------------
; These settings are used in the ANSWER mode of handshake only. In the
; originate mode handshake, processing is done at 8000 Hz. In the answer mode
; processing is at 7200 Hz.
;------------------------------------------------------------------------------

    .equ  V25_SRATE,       7200
    .equ  V25_ANSADVANCE,  0x4aab
    .equ  V25_450MS,       3240
    .equ  V25_AMADVANCE,   0x89

;------------------------------------------------------------------------------
; Status definitions for < ans_status > of v25_struct
;------------------------------------------------------------------------------

    .equ  ANS_DETECTED,    1          
    .equ  ANSAM_DETECTED,  2

;------------------------------------------------------------------------------
; V.25 Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ  SIZEOFV25TX_BSS, 4           ;size of V25 data structure
    .equ  SIZEOFV25RX_BSS, 18
    .equ  SIZEOFV25RX_YBSS, 8

;------------------------------------------------------------------------------
; V.25 Module: Global definations of variables
;------------------------------------------------------------------------------
    
    .global V25DTDelayLine             ;V25 Delay Line
    .global V25ModDelayLine            ;de-modulation lpf for AM detection
  
;******************************************************************************
; END OF FILE
;******************************************************************************
