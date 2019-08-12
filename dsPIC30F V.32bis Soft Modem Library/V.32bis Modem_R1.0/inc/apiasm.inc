;******************************************************************************
;File Name:   APIASM.H
;******************************************************************************

    .equ DEF_DEBUG,           1
    .equ MAXMSGLEN,           127

;Length of the buffer used to store the data to be sent to DP for modulation
    .equ INDATABUFLEN,        128     
                                    
;Length of the buffer used to store the Received data
    .equ OUTDATABUFLEN,       128 

;-------------------------------------------------------------------------
; Data Pump Commands 
;--------------------------------------------------------------------------*/

    .equ mDATATODP,           0
    .equ mORIGINATE,          1
    .equ mANSWER,             2
    .equ mLOOPBACK,           3
    .equ mTONEDIAL,           4
    .equ mDATAMODESELECT,     5
    .equ mMODESELECT,         6
    .equ mRATESELECT,         7
    .equ mHSMODESELECT,       8
    .equ mHANGUP,             9
    .equ mSHUTDOWN,           10
    .equ mCLPRGSELECT,        11
    .equ mSTARTRETRAIN,       12
    .equ mSELECTRETRAIN,      13
    .equ mDETECTDIALTONE,     17
    .equ mDIALDURATION,       18
    .equ mSETTXLEVEL,         19
    .equ mHDLCFRMEND,         23
    .equ mDPHSTEST,           24
    .equ mCLPRGTONECADENCE,   25
    .equ mSTARTRENEG,         26
    .equ mV22GUARDTONE,       27 

;-------------------------------------------------------------------------
; Data Pump Responses
;--------------------------------------------------------------------------*/

    .equ mDATATOHOST,         0
    .equ mCONNECT,            1
    .equ mNOCARRIER,          2
    .equ mMODEMREADY,         3
    .equ mCRCOK,              4
    .equ mCRCERROR,           5
    .equ mFRAMEACK,           6
    .equ mXON,                7
    .equ mXOFF,               8
    .equ mDETECTFLAG,         10
    .equ mGOTDIALTONE,        11
    .equ mGOTBUSYTONE,        12
    .equ mGOTREORDERTONE,     13
    .equ mGOTRINGBACK,        14
    .equ mDIALEND,            15
    .equ mREMOTERETRAIN,      16
    .equ mLOCALRETRAIN,       17
    .equ mDET7E,              18
    .equ mCHANGEBUFLEN,       19
    .equ mDEBUGINFO,          20
    .equ mCLPRGRESP,          21
    .equ mSELECTSMPRATE,      22
    .equ mHANGUPCOMPLETE,     23

;-------------------------------------------------------------------------
;  Modem Mode definations
;--------------------------------------------------------------------------*/

.equ V32BIS_MODE, 0x0001
.equ V22BIS_MODE, 0x0002
.equ V23_MODE,    0x0004
.equ V21_MODE,    0x0008
.equ B103_MODE,   0x0010

;-------------------------------------------------------------------------
;  DP Data Tx/Rx Mode configuration
;-------------------------------------------------------------------------*/

.equ DATA_L2MSS,            0    ;Lsb 2 Msb with start/stop addition/deletion
.equ DATA_M2L,              1    ;Msb to Lsb without start/stop bits
.equ DATA_HDLC,             2    ;HDLC mode
.equ DATA_L2M,              3    ;Lsb 2 Msb without start/stop bits

;-------------------------------------------------------------------------
;  Modem HandShake Mode Selection
;--------------------------------------------------------------------------*/

.equ ENABLE_AUTO,                   0
.equ ENABLE_V8,                     1
.equ ENABLE_V32BIS,                 2
.equ ENABLE_V32,                    4
.equ ENABLE_V22,                    8
.equ ENABLE_V21,                    16
.equ ENABLE_V23,                    32
.equ ENABLE_B103,                   64

;-------------------------------------------------------------------------
;  Debug DP State Machine Messages
;--------------------------------------------------------------------------*/

;V8 hand shake messages

.equ V8_SILENCE_TX,               0   ; Initial silence in V8 originate mode
.equ V8_SEND_CM,                  1   ; Transmited CM sequence in ORG mode
.equ V8_DETECT_JM,                2   ; Detected JM sequence in ORG mode
.equ V8_CJ_TX,                    3   ; Transmitted CJ sequence in ORG mode
.equ V8_CM_DETECT,                4   ; Detected CM sequence in ANS mode
.equ V8_SEND_JM,                  5   ; Transmitted JM sequence in ANS mod
.equ V8_DETECT_CJ,                6   ; Detected CJ sequence in ANS mode
    
;V32 hand shake messages    
    
.equ    V32_ORG_START,            7   ; Start V.32 ORIGINATE Hand Shake
.equ    V32_START_AA,             8   ; Signal States AA transmission
.equ    V32_DETECT_AC,            9   ; Signal State AC
.equ    V32_DETECT_AC2CA,        10   ; AC-CA Reversal detected
.equ    V32_TX_AA2CC,            11   ; Signal state CA-AC transmit
.equ    V32_DETECT_CA2AC,        12   ; CA-AC Reversal detected
.equ    V32_TX_SILENCE,          13   ; Transmit silence
.equ    V32_DET_AC_DROP,         14   ; AC reception stopped
.equ    V32_DETECT_TRN,          15   ; Detected TRN sequence
.equ    V32_DETECT_R1,           16   ; Detected RATE-1 sequence
.equ    V32_TX_EC_TRN,           17   ; Send TRN in half duplex mode
.equ    AGC_DET_ENG_LOSS,        18   ; AGC detected energy loss
.equ    V32_TX_RATE2,            19   ; Send RATE-2 sequence
.equ    V32_DETECT_R3,           20   ; Detected RATE-3 sequence
.equ    V32_TX_E,                21   ; Send E sequence    
.equ    V32_DETECT_E,            22   ; Detected E sequence

.equ    V32_CONNECT_9600,        23   ; DP Connection establishment
.equ    V32_CONNECT_4800,        24   ; DP Connection establishment

.equ    V32_ANS_START,           25   ; Start V.32 ANSWER Hand Shake
.equ    V32_DETECT_AA,           26   ; Detected AA signal state
.equ    V32_TX_AC2CA,            27   ; Signal state AC-CA transmit
.equ    V32_DETECT_AA2CC,        28   ; AA-CC Reversal detected
.equ    V32_TX_CA2AC,            29   ; Signal state CA-AC transmit
.equ    V32_TX_STOP_AC,          30   ; Stop the transmission of AC
.equ    V32_TX_RATE1,            31   ; Send RATE-1 sequence
.equ    V32_DETECT_R2,           32   ; Detected RATE-2 sequence
.equ    V32_TX_FD_TRN,           33   ; Send TRN in full duplex mode    
.equ    V32_TX_RATE3,            34   ; Send RATE-3 sequence

;V22bis hand shake messages    

.equ    V22_ORG_START,           35   ;    Start V.22 ORIGINATE Hand Shake
.equ    V22_ANS_START,           36   ;    Start V.22 ANSWER Hand Shake
.equ    V22_SENDUNSCRAM,         37   ;    Send unscrambled 1's
.equ    V22_RECEIVEUNSCRAM,      38   ;    Detected unscrambled 1's
.equ    V22_SENDS1,              39   ;    Transmit S1
.equ    V22_SEND1200,            40   ;    Send Scrambled 1's at 1200bps
.equ    V22_RECEIVES1,           41   ;    Detected S1
.equ    V22_RECEIVE1200,         42   ;    Detected Scrambled 1's at 1200bps
.equ    V22_SEND2400,            43   ;    Transmit Scrambled 1's at 2400bps
.equ    V22_RXDSCRAMONES,        44   ;    Received Scrambled 1's at 2400bps
.equ    V22_CONNECT_2400,        45   ;    DP connection establishment(2400bps)
.equ    V22_CONNECT_1200,        46   ;    DP connection establishment(1200bps)

;V21 hand shake messages    

.equ    V21_ORG_START,           47   ; Start V21 in originate mode
.equ    V21_ANS_START,           48   ; Start V21 in answer mode
.equ    V21_CONNECT_300,         49   ; V21 DP Connection establishment(300bps)

;V23 hand shake messages    

.equ    V23_ORG_START,           50   ; Start V23 in originate mode
.equ    V23_ANS_START,           51   ; Start V23 in answer mode
.equ    V23_CONNECT,             52   ; V23 DP Connection establishment 
                                      ; (75/1200 bps - ORG Mode)
                                      ; (1200/75 bps - ANS Mode)     

;******************************************************************************
;    END OF FILE
;******************************************************************************
