;******************************************************************************
; File Name:   V8.H
;******************************************************************************

;------------------------------------------------------------------------------
; V.8 State Machine Module constant defines
;------------------------------------------------------------------------------

;Flags used for indicating v8 status

    .equ V8TXSYNCFLAG,    0x0001
    .equ V810ONES,        0x0002
    .equ V8RXSYNCFLAG,    0x0010
    .equ V8TXSTRINGEND,   0x0020
    .equ V8RXSTRINGEND,   0x0040
    .equ V8RXSTRINGFLAG,  0x0080
    .equ V8TXSTRINGEND1,  0x0800

;Timers used in V8 state machine

    .equ V8CITIMER,       19200
    .equ V8TeTIMER,       2000

;Lengths of different sequences involved in V8 state machine

    .equ V8CMSTRINGLEN,   7
    .equ V8JMSTRINGLEN,   7
    .equ V8CJSTRINGLEN,   3

    .equ CALLF_1,         0
    .equ MODN_1,          1
    .equ MODN_2,          2
    .equ MODN_3,          3
    .equ V90_1,           4
    .equ PROTO_1,         5
    .equ PSTN_1,          6

;Definitions for call function category CALLF_1

    .equ TransmitFaxFromCallTerminal,    0x80
    .equ ReceiveFaxAtCallTerminal,       0xa0
    .equ FullDuplexData,                 0xc0

;Definitions for Modulation modes MODN_1

    .equ V90Availability,                0x20
    .equ V34FullDuplex,                  0x40
    .equ V34HalfDuplex,                  0x80

;Definitions for Modulation modes MODN_2

    .equ V32DataModem,                   0x01
    .equ V22DataModem,                   0x02

;Definitions for Modulation modes MODN_3

    .equ V23FullDuplex,                  0x04
    .equ V23HalfDuplex,                  0x40
    .equ V21DataModem,                   0x80

;Definitions for V.90 Category    V90_1

    .equ V90AnalogModem,                 0x20
    .equ V90DigitalModem,                0x40

;Definitions for Protocol  Category PROTO_1

    .equ LapmV42,                        0x20

;Definitions for PSTN Access category PSTN_1

    .equ DigitalPstn,                    0x80
    .equ CallDCECellular,                0x20
    .equ AnswerDCECellular,              0x40

;------------------------------------------------------------------------------
; V.8 Satte Machine Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ SIZEOFV8_BSS_1,  4
    .equ SIZEOFV8_BSS_2,  2
    .equ SIZEOFV8_YBSS_1, 8
    .equ SIZEOFV8_YBSS,   15

;------------------------------------------------------------------------------
; V8 State Machine Module: Global definations of variables
;------------------------------------------------------------------------------

    .global V8RxBitStream1             ;Received JM string1
    .global V8RxBitStream2             ;Received JM string2
    .global V8State                    ;State of the .global  hand shake
    .global V8TxByteCounter            ;Transmit bit counter of some sequence
    .global V8TxByteCounterSet         ;Number of bits to be transmitted in a
                                       ;particular sequence
    .global V8RxStrLen                 ;Length of the received string
    .global V8DefV8Octets              ;Default V.8 octets
    .global V8Codes                    ;V.8 octets buffer

    .global V8RxStrPtr                 ;Pointer to received string buffer
    .global V8RemDetails               ;Bit Mapped variable identifying remote
                                       ;modem.

;******************************************************************************
;    END OF FILE
;******************************************************************************
