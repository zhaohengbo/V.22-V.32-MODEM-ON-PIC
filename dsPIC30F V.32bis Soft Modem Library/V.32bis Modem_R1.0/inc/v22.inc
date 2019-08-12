;******************************************************************************
; File Name:   V22.H
;******************************************************************************


;------------------------------------------------------------------------------
; V.22 State Machine Module constant defines
;------------------------------------------------------------------------------

.equ    V22IPFACTOR,           12      ;Interpolation factor
.equ    V22PSFDELAY,            4      ;Delay in PS filter
.equ    V22PSFCOEFSLEN,        48      ;PS filter length
.equ    V22BPCOEFSLEN,         48      ;BP filter length
.equ    V22HC_CARRIERADVANCE,  0x5555  ;Carrier Phase advance(HIGH Carrier)
.equ    V22LC_CARRIERADVANCE,  0x2AAA  ;Carrier Phase advance(LOW Carrier)
.equ    V22R1,                 0x1000  ;Reference Symbol
.equ    V22R3,                 0x3000  ;Reference Symbol
.equ    V22EQZLEN,             48      ;Equalizer filter length for V22

.equ    NO_RETRAIN_RESPONSE,   13

;------------------------------------------------------------------------------
; V..22 S/M Module DM variables length defineations
;------------------------------------------------------------------------------

.equ    SIZEOFV22_BSS_1,       17
.equ    SIZEOFV22_BSS_2,       29
.equ    SIZEOFV22_YBSS,        48

;------------------------------------------------------------------------------
; V.22 S/M Module: Global definations of variables
;------------------------------------------------------------------------------

.global    V22ScrState1                 ;Gives the state of the scrambler
.global    V22DescrState1               ;Gives the state of the descrambler
.global    V22TxSwitch1                 ;Transmit and receive function
                                        ;pointers
.global    V22RxSwitch1                 ;used to switch between different
                                        ;states
.global    V22DecFnPtr1                 ;Decoder function pointer
.global    V22BitRate1                  ;Flag to select the bit rate for V22
.global    V22ClkDlyLine1               ;Filter delay line used in clock
                                        ;recovery
.global    V22BpCoefPtr1                ;Pointer to BP filter
.global    V22ScrOnesCntr1              ;Incremented for every scrambled
                                        ;binary 1
.global    V22DescrOnesCntr1            ;Incremented for every received
                                        ;binary 1
.global    V22TxSampleCntr1             ;Transmit sample counter(Used for
                                        ;baud switching)
.global    V22RxSampleCntr1             ;Receive sample counter(Used for
                                        ;baud switching)
.global    V22TxBaudCntr1               ;Transmit Buad counter(used for
                                        ;state switching)
.global    V22RxBaudCntr1               ;Receive Buad counter(used for
                                        ;state switching)
.global    V22BaudBits1                 ;Used to assemble the bits in a baud
.global    V22PrevBaudBits1             ;Assembled previous baud bits
.global    V22PrevTxPhase1              ;Transmit Phase used for V22
                                        ;encoding
.global    V22PrevRxPhase1              ;Receive Phase used for V22 encoding
.global    V22S1Detect1                 ;Flag to indicate the S1 signal
                                        ;detection
.global    V22RxSyncBits1               ;Used to assemble a group of bits
.global    V22TxCarPhase1               ;Transmit carrier phase
.global    V22RxCarPhase1               ;Receive carrier phase
.global    V22TxCarAdvance1             ;Transmit carrier phase advance
.global    V22RxCarAdvance1             ;Receive carrier phase advance
.global    V22SmpEarlyEng1              ;Used to store the signal energy
.global    V22SmpLateEng1               ;Used to store the signal energy
.global    V22SmpMidEng1                ;Used to store the signal energy
.global    V22ClkAdj1                   ;Clock adjustment flag
.global    V22Scr1Cntr1                 ;Counter for counting scrambled 1's
.global    V22S1Cntr1                   ;Counter for counting S1 symbols
.global    V22S1Dibit1                  ;Di bit pattern used in encoding
.global    V22ClkCntr1                  ;Counter used in clock recovery
.global    V22GrdTnAdv1                 ;Gaurd tone advance factor
.global    V22GrdTnSum1                 ;Gaurd tone advance advance sum
.global    V22GrdTnScl1                 ;gaurd tone scaling factor
.global    V22BpIpDlyPtr1               ;BP delay line pointer
.global    V22BpIpCoefPtr1              ;Pointer to BP filter
.global    V22BpDlyLine                 ;BP filter delay line
.global    V22TotPhase1                 ;V22 Total Phase
.global    V22FallBack1                 ;Flag to enable the fall back
                                        ;operation
.global    V22DiffEncTabPtr1            ;Pointer to the V22DiffEncTab table
.global    V22Symb1200Ptr1              ;Pointer to the V22Symb1200 table
.global    V22Symb2400Ptr1              ;Pointer to the V22Symb2400 table
.global    V22QuadBitsPtr1              ;Pointer to the V22QuadBits table
.global    V22BpIpDlyEnd1               ;Delay End pointer
.global    V22AnsBpCoefsPtr1            ;pointer to BP Answer mode filter

;******************************************************************************
;    END OF FILE
;******************************************************************************
