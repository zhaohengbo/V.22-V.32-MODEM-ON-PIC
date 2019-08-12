;******************************************************************************
;File Name:   V32.H
;******************************************************************************

;------------------------------------------------------------------------------
; V.32 State Machine Module constant defines
;------------------------------------------------------------------------------

    .equ V32BAUDRATE,       2400       ;V.32 Data Pump Symbol Rate
    .equ V32SAMPLINGRATE,   7200       ;V.32 Data Pump Sampling Rate

    ;V.32 Data Pump interpolation factor(samples per symbol)
    .equ V32IPFACTOR,       (V32SAMPLINGRATE/V32BAUDRATE)

    ;Carrier Advance for 1800Hz (= (1800/7200) * 65535)
    ;[CA = (2*M_PI*V32Carrier)/SR]

    .equ V32CARRIERADVANCE, 0x4000

    ;V.32 PSF parameters
    .equ V32PSFCOEFSLEN,    24         ;PS Filter length
    .equ V32PSFDELAY,       (V32PSFCOEFSLEN / (V32IPFACTOR)) ;PSF delay = 8

    ;V.32 Encoder Reference Symbols

    .equ RV1,                0x1000
    .equ RV2,               (RV1 + RV1)
    .equ RV3,               (RV2 + RV1)
    .equ RV4,               (RV3 + RV1)
    .equ RV5,               (RV4 + RV1)

    ;Timers used for V.32 hand shake time outs

    .equ RET_TIMER,         9600 * 10  ;Failure to detect required signal
    .equ RET_TIMER_1,       9600 * 5   ;Failure to detect S after R1 OR R2 Tx
    .equ RET_TIMER_2,       9600 * 2   ;Failure to detect S/SBAR in ANS Mode
    .equ RET_TIMER_3,       9600 * 5   ;Failure to detect E
    .equ RET_TIMER_4,       9600 * 4   ;Failure to complete RTD estimation

    .equ V32BPCOEFSLEN,     30         ;Input BP Filter Length
    .equ V32SCRAMBLERLEN,   23         ;V.32 Scrambler buffer length
    .equ V32EQZLEN,         64         ;V.32 Equalizer length

;------------------------------------------------------------------------------
;Variable Offset for accessing Scrambler parameters
;------------------------------------------------------------------------------

    .equ SCRINDEXA,         0
    .equ SCRINDEXB,         1
    .equ SCRBUFFER,         2

;------------------------------------------------------------------------------
; V.32 Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ SIZEOFV32_BSS_1,   12         ;Size of V.32 state machine variables
    .equ SIZEOFV32_BSS_2,   39         ;Size of V.32 state machine variables
    .equ SIZEOFV32_YBSS,    30         ;Size of V.32 Delay buffer

;------------------------------------------------------------------------------
; V.32 Module: Global definations of variables
;------------------------------------------------------------------------------

    .global V32RRPrevRxPhase 
    .global dmStartRetrain
    .global V32RRiCntr
    .global V32Alt
    .global V32TrnScrIndexA            ;Training phase Scrambler buffer index A
    .global V32TrnScrIndexB            ;Training phase Scrambler buffer index B
    .global V32TrnScrBuffer            ;TRN phase scrambler buffer
    .global V32ScrIndexA               ;Data scrambler buffer Index-A
    .global V32ScrIndexB               ;Data scrambler buffer Index-B
    .global V32ScrBuffer               ;Data scrambler buffer
    .global V32DescrIndexA             ;Data descrambler buffer Index-A
    .global V32DescrIndexB             ;Data scrambler buffer Index-B
    .global V32DescrBuffer             ;Data descrambler buffer
    .global V32IpBpDlyLine             ;Input BP filter delay line buffer

    .global V32RateCntr
    .global V32Rate_1Cntr
    .global V32SilenceCntr

    .global V32SineTabPtr
    .global V32SineTabIndex  
    .global V32NTCMEnable

    .global V32RRStart
    .global V32NecRRPrevTxPhase
    .global V32FecRRPrevTxPhase

;******************************************************************************
;    END OF FILE
;******************************************************************************







