;******************************************************************************
;FILE NAME:    MODEM.H
;******************************************************************************

;------------------------------------------------------------------------------
; General definations for soft modem data pump
;------------------------------------------------------------------------------
    
;------------------------------------------------------------------------------
; Enable the following options if Far echo canceller is required
;------------------------------------------------------------------------------
    
    .equ ENFEC,           1            ;Enable FEC

;******************************************************************************

;------------------------------------------------------------------------------
; Data Pump Rate Conversion factors 
;------------------------------------------------------------------------------

    .equ RATE_7200,       6            ;Sampling Rate Conversion -> 7200 Hz
    .equ RATE_8000,       7            ;Sampling Rate Conversion -> 8000 Hz
    .equ RATE_9600,       0            ;Sampling Rate Conversion -> 9600 Hz

;------------------------------------------------------------------------------
; Signal Level definitions
;------------------------------------------------------------------------------

    .equ LVL_47dBm,       0x20         ;Value corresponding to -47dBm
    .equ LVL_43dBm,       0x40         ;Value corresponding to -43dBm
    .equ LVL_0dBm,        0x4500       ;Value corresponding to 0dBm

;------------------------------------------------------------------------------
; Data Pump sampling rate
;------------------------------------------------------------------------------

    .equ SRATE,           7200            

;------------------------------------------------------------------------------
; ModemType definitions
;------------------------------------------------------------------------------

    .equ MTV32,           0x0004       ;Modem Type -> V32
    .equ MTV22BIS,        0x0008       ;Modem Type -> V22BIS
    .equ MTV22,           0x0010       ;Modem Type -> V22
    .equ MTV21,           0x0020       ;Modem Type -> V21
    .equ MTV23,           0x0040       ;Modem Type -> V23

;------------------------------------------------------------------------------
; Modem mode definitions
;------------------------------------------------------------------------------

    .equ ORIGINATE,        0x0001      ;Originate mode
    .equ ANSWER,           0x0002      ;Answer mode
    .equ ANALOGLOOPBACK,   0x0004      ;Loopback mode
    .equ V21MODE,          0x0008      ;V21 mode

;------------------------------------------------------------------------------
; Modem Status definitions
;------------------------------------------------------------------------------

    .equ TXENABLE,        0x0001       ;Transmit enable
    .equ RXENABLE,        0x0002       ;Receive enable
    .equ CARRIERDETECT,   0x0004       ;Carrier detection
    .equ ENABLEBITTX,     0x0008       ;Enable bit transmission
    .equ ENABLEBITRX,     0x0010       ;Enable bit reception
    .equ RXDBYTE,         0x0020       ;Received Byte
    .equ HDLCBYTEAVAIL,   0x0040       ;HDLC byte available

;------------------------------------------------------------------------------
; Variable offsets for accessing PCM and Message structure members
;------------------------------------------------------------------------------

    .equ PCMFRMLEN,       0            ;Offset to Frame Length
    .equ PCMINPTR,        2            ;Offset to Input sample pointer
    .equ PCMOUTPTR,       4            ;Offset to Output sample pointer

    .equ MSGBUFFER,       0            ;Offset to Message Buffer
    .equ MSGWRITEPTR,     2            ;Offset to Message write pointer
    .equ MSGREADPTR,      4            ;Offset to Message Read pointer
    .equ MSGQLENGTH,      6            ;Offset to Message Queue Length


;------------------------------------------------------------------------------
; Global declaration of general data pump variables
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Global declaration section identifying variables
;------------------------------------------------------------------------------

    .global nbssFirstVar
    .global nbssLastVar
    .global bssFirstVar
    .global bssLastVar
    .global xbassFirstVar
    .global xbssLastVar 
    .global ybassFirstVar
    .global ybssLastVar 

;------------------------------------------------------------------------------
; Global declaration general data pump variables
;------------------------------------------------------------------------------

    .global modemStatus                ;Modem status flag
    .global modemMode                  ;Modem mode flag
    .global mdmPcmBufLen               ;PCM buffer length
    .global modemType                  ;Modem type flag
    .global mdmHangUp                  ;Modem Hangup flag
    .global mdmShutDown                ;Modem shutdown flag
    .global mdmAgcMinEnSet             ;Initialized minimum energy level
    .global mdmDetEqzTrn               ;Equalizer training sequence detect flag
    .global mdmV8Enable                ;V.8 hand shake enable flag
    .global mdmSiplEnable              ;SIPL enable flag
    .global mdmRxSmpCntr               ;Receive sample counter
    .global mdmTxSmpCntr               ;Transmit sample counter
    .global mdmPcmTxIndex              ;Transmit sample number
    .global mdmPcmRxIndex              ;Receive sample number
    .global mdmRetrainCount            ;count for retrains
    .global mdmAdcDelay                ;Delay involved in ADC
    .global mdmDacDelay                ;Delay involved in DAC
    .global mdmSignalHigh              ;Indicates the received signal level
    .global mdmRCTxRatio               ;Sampling rate selection flag
    .global mdmStartRetrain            ;Start of modem retrain
    .global mdmMeanPRunAvg             ;Mean Parameter Run average
    .global mdmMeanPAvg                ;Mean Parameter Average
    .global mdmMeanPCntr               ;Mean Parameter counter
    .global mdmMeanPLevel              ;Mean Parameter Level
    .global mdmMeanPIp                 ;Mean Parameter Interpolation Factor

    .global mdmDemI                    ;Demodulated symbol(I)
    .global mdmDemQ                    ;Demodulated symbol(Q)
    .global mdmDecI                    ;Decision generator output(I)
    .global mdmDecQ                    ;Decision generator output(Q)

    .global mdmADCSample               ;ADC sample (Received sample)
    .global mdmAverageInputLevel       ;Average input signal level
    .global mdmAgcMinEnLevel           ;Minimum energy level for AGC

    .global modemTransmiter            ;Modem Transmiter function pointer
    .global modemReceiver              ;Modem Receiver function pointer
    .global modemManager               ;Modem Manager function pointer

    .global mdmTxGainFactor            ;Gain factor for transmit signal
    .global mdmSamplePhaseAdjust       ;Sample phase adjustment required

    .global modemTimerA                ;Modem timers used to time the different
    .global modemTimerB                ;data pump events

    .global mdmIpBpCoefsPtr            ;Input bandpass filter delay pointer

    .global mdmIpBpDly                 ;Input BP filter delay line
    .global mdmDPHSTest

;------------------------------------------------------------------------------
; Channel buffers information variables
;------------------------------------------------------------------------------

    .global ChnPcmBufLen               ;Channel PCM frame length
    .global ChnPcmInPtr                ;Pointer to PCM input samples buffer
    .global ChnPcmOutPtr               ;Pointer to PCM out samples buffer

    .global ChnInMsgTop                ;Ptr to top of In message Queue buffer
    .global ChnMsgInWPtr               ;Write Pointer to In Message Queue
    .global ChnMsgInRPtr               ;Read pointer to In Mssage Queue
    .global ChnInMsgEnd                ;Ptr to end of In Message Queue buffer

    .global ChnOutMsgTop               ;Ptr to top of Out message Queue buffer
    .global ChnMsgOutWPtr              ;Write Pointer to Out Message Queue
    .global ChnMsgOutRPtr              ;Read pointer to Out Mssage Queue
    .global ChnOutMsgEnd               ;Ptr to end of Out Message Queue buffer

    .global ChnMsgInRAddr              ;Ptr to In Message Queue Read pointer
    .global ChnMsgOutWAddr             ;Ptr to Out Message Queue write pointer

;------------------------------------------------------------------------------
; User configuration variables
;------------------------------------------------------------------------------

    .global ucBusyOnTime               ;Busy tone cadence
    .global ucBusyOffTime
    .global ucReorderOnTime            ;Reorder tone cadence
    .global ucReorderOffTime
    .global ucRingOnTime               ;Ring back tone cadence 
    .global ucRingOffTime
    .global ucRingCount     
    .global DialToneStatus
    .global CallprogStatus
    .global CallprogBuf

    .global ucAutoRetrain              ;Auto retrain mode flag
    .global ucDataModeSel              ;Data transmission mode select flag
    .global ucIdleDataSet              ;Idle data for the data pump
    .global ucConnectMode              ;Connection mode in loop back
    .global ucConnectRate              ;Bit rate selection flag
    .global ucHS_Mode                  ;Hand shake mode select
    .global ucClprgConfig              ;Call progress mode select
    .global ucClearDown                ;Modem clear down flag

    .global ucTxScaleFactor            ;User configurable transmit gain
    .global ucDtmfDuration             ;DTMF tone duration
    .global ucTransmitLevel            ;Signal transmit level

;------------------------------------------------------------------------------
; Common variables required for all the modulation protocols
;------------------------------------------------------------------------------
    
    .global mdmvar1
    .global mdmvar2
    .global mdmvar3
    .global mdmvar4
    .global mdmvar5
    .global mdmvar6
    .global mdmvar7
    .global mdmvar8
    .global mdmvar9
    .global mdmvar10
    .global mdmvar11
    .global mdmvar12
    .global mdmvar13
    .global mdmvar14
    .global mdmvar15
    .global mdmvar16
    .global mdmvar17
    .global mdmvar18
    .global mdmvar19
    .global mdmvar20
    .global mdmvar21
    .global mdmvar22
    .global mdmvar23
    .global mdmvar24
    .global mdmvar25
    .global mdmvar26
    .global mdmvar27
    .global mdmvar28
    .global mdmvar29
    .global mdmvar30
    .global mdmvar31
    .global mdmvar32
    .global mdmvar33
    .global mdmvar34
    .global mdmvar35
    .global mdmvar36
    .global mdmvar37
    .global mdmvar38
    .global mdmvar39
    .global mdmvar40
    .global mdmvar41
    .global mdmvar42
    .global mdmvar43
    .global mdmvar44
    .global mdmvar45
    .global mdmvar46
    .global mdmvar47
    .global mdmvar48
    .global mdmvar49
    .global mdmvar50
    .global mdmvar51
    .global mdmvar52
    .global mdmvar53
    .global mdmvar54
    .global mdmvar55
    .global mdmvar56
    .global mdmvar57
    .global mdmvar58
    .global mdmvar59
    .global mdmvar60
    .global mdmvar61
    .global mdmvar62
    .global mdmvar63
    .global mdmvar64
    .global mdmvar65
    .global mdmvar66
    .global mdmvar67
    .global mdmvar68
    .global mdmvar69
    .global mdmvar70
    .global mdmvar71
    .global mdmvar72
    .global mdmvar73
    .global mdmvar74
    .global mdmvar75
    .global mdmvar76
    .global mdmvar77
    .global mdmvar78
    .global mdmvar79
    .global mdmvar80
    .global mdmvar81
    .global mdmvar82
    .global mdmvar4_82
    .global mdmvar83
    .global mdmvar84
    .global mdmvar85
    .global mdmvar86
    .global mdmvar87
    .global mdmvar88
    .global mdmvar4_88
    .global mdmvar89
    .global mdmvar90
    .global mdmvar91
    .global mdmvar92
    .global mdmvar93
    .global mdmvar94
    .global mdmvar4_94
    .global mdmvar95
    .global mdmvar96
    .global mdmvar97
    .global mdmvar98
    .global mdmvar99
    .global mdmvar100
    .global mdmvar101
    .global mdmvar102
    .global mdmvar103
    .global mdmvar104
    .global mdmvar105
    .global mdmvar106
    .global mdmvar107
    .global mdmvar108
    .global mdmvar109
    .global mdmvar110
    .global mdmvar111
    .global mdmvar112
    .global mdmvar113
    .global mdmvar114
    .global mdmvar115
    .global mdmvar116
    .global mdmvar117
    .global mdmvar118
    .global mdmvar119
    .global mdmvar120
    .global mdmvar121
    .global mdmvar122
    .global mdmvar123
    .global mdmvar124
    .global mdmvar125
    .global mdmvar126
    .global mdmvar127
    .global mdmvar128
    .global mdmvar129
    .global mdmvar130
    .global mdmvar131
    .global mdmvar132
    .global mdmvar133
    .global mdmvar134
    .global mdmvar135
    .global mdmvar136
    .global mdmvar137
    .global mdmvar138
    .global mdmvar139
    .global mdmvar140
    .global mdmvar141
    .global mdmvar142
    .global mdmvar143
    .global mdmvar144
    .global mdmvar145
    .global mdmvar146
    .global mdmvar147
    .global mdmvar148
    .global mdmvar4_149    
    .global mdmvar149    
    .global mdmvar150    
    .global mdmvar151    
    .global mdmvar152    
    .global mdmvar153    
    .global mdmvar154    
    .global mdmvar155    
    .global mdmvar156    
    .global mdmvar157    
    .global mdmvar158    
    .global mdmvar159    
    .global mdmvar160    
    .global mdmvar161    
    .global mdmvar162    
    .global mdmvar163    
    .global mdmvar164    
    .global mdmvar165    
    .global mdmvar166    
    .global mdmvar167

;------------------------------------------------------------------------------
; Global defination of buffer used for different data pump filters
;------------------------------------------------------------------------------

    .global mdmFilterBuffer


;******************************************************************************
;    END OF FILE
;******************************************************************************
