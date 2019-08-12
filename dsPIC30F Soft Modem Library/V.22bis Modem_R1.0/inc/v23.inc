;******************************************************************************
;File Name:   V23.H
;******************************************************************************

;------------------------------------------------------------------------------
; V.23 State Machine Module constant defines
;------------------------------------------------------------------------------

    .equ     V23IPFACTOR1200,    7200/1200 ;Interpolation Factor for 1200 Baud
    .equ     V23IPFACTOR600,     7200/600  ;Interpolation for 600 Baud
    .equ     V23IPFACTOR75,      7200/75   ;Interpolation for 75 Baud
    .equ     V23_1_1200,         0x2E39    ;advance for 1300Hz
    .equ     V23_0_1200,         0x4AAC    ;advance for 2100Hz
    .equ     V23_1_600,          0x2E39    ;advance for 1300Hz
    .equ     V23_0_600,          0x3C72    ;advance for 1700Hz
    .equ     V23_1_75,           0x0DDF    ;advance for 390Hz
    .equ     V23_0_75,           0x1000    ;advance for 450Hz
    .equ     V23_B1_420,         0x2500    ;Linear interpolation coefficients
    .equ     V23_B1_1500,        0x1D80    ;for shifting the samples by pi/2
    .equ     V23_B1_1700,        0x0A80
    .equ     V23BPFILTERLEN,     31        ;Band Pass Filter Length

;------------------------------------------------------------------------------
; FSK(V.21/V.23) Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ     SIZEOFFSK_BSS_1,    7     ;Size of FSK data struct
    .equ     SIZEOFFSK_BSS_2,    20    ;Size of FSK data struct

    .equ     SIZEOFFSK_YBSS_1,   8     ;Size of FSK delay buffer
    .equ     SIZEOFFSK_YBSS_2,   41    ;Size of FSK delay buffer

;------------------------------------------------------------------------------
; FSK Module: Global definations of variables
;------------------------------------------------------------------------------

    .global FSKValidCntr     ;Used for validating the initial 20 1's
    .global FSKChangeCount   ;FSK phase change count
    .global FSKTxSampleCnt   ;Transmit sample counter(baud switching)
    .global FSKTxIpFactor    ;FSK Tx Interpolation factor
    .global FSKRxIpFactor    ;FSK Rx interpolation factor
    .global FSKTxBand        ;Used to determine the FSK Tx rate
    .global FSKRxBand        ;Used to determine the FSK rx rate

    .global FSKFmultFactor0  ;Demod multiplication factor
    .global FSKFmultFactor1  ;Demod multiplication factor
    .global FSKDsmp0         ;Used to save Previous samples
    .global FSKDsmp1         ;in FSK demodulation
    .global FSKDsmp2
    .global FSKDsmp3
    .global FSKDsmp4
    .global FSKDsmp5
    .global FSKIpSample      ;FSK input sample
    .global FSKLpOp          ;FSK LPF output
    .global FSKtemp
    .global FSKCarAdvance    ;FSK carrier advance
    .global FSKCurPhase
    .global FSKMarkAdvance   ;FSK mark frequencey advance
    .global FSKSpaceAdvance  ;FSK space frequency advance
    .global FSKTxBaudCount   ;Transmit baud counter
    .global FSKBpCoefPtr     ;BP filter coefficient pointer
    .global FSKLpCoefsPtr    ;LP filter coefficient pointer
    .global FSKBpDlPtr       ;BP filter delay line pointer
    .global FSKBpDlEnd       ;BP filter delay line end pointer

;******************************************************************************
;    END OF FILE
;******************************************************************************



