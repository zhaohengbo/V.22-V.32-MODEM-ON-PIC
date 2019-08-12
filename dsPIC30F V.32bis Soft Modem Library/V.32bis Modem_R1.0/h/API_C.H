/******************************************************************************
;File Name:   API_C.H
******************************************************************************/

#include "datatype.h"
#include "options.h"

/*-------------------------------------------------------------------------
 DP Message structre constants
--------------------------------------------------------------------------*/

#define MAXMSGLEN        127  //Maximum message buffer length
#define DP_IN_MSG_QSIZE  128  //In message queue length
#define DP_OUT_MSG_QSIZE 128  //Out message queue length

/*-------------------------------------------------------------------------
 DP Message and PCM data structre definations
--------------------------------------------------------------------------*/

typedef struct  {
    UCHAR Id;                 //Message ID
    UCHAR Len;                //Message Length
} MESSAGE;

typedef struct {
    INT FrameLength;          //PCM frame Length specified
    INT *IN;                  //PCM samples bffer for receiver
    INT *OUT;                 //Buffer for filling modulated samples
} PCMDATASTRUCT;

typedef struct {
    CHAR *BufPtr;              //Store messages for data pump
    CHAR *Write;               //Current write pointer to ip queue
    CHAR *Read;                //Current read poINTer to ip queue 
    UCHAR Size;                //Length of the output queue
} MSGQSTRUCT;


/*-------------------------------------------------------------------------
 Data Pump Commands 
--------------------------------------------------------------------------*/

#define mDATATODP           0
#define mORIGINATE          1
#define mANSWER             2
#define mLOOPBACK           3
#define mTONEDIAL           4
#define mDATAMODESELECT     5
#define mMODESELECT         6
#define mRATESELECT         7
#define mHSMODESELECT       8
#define mHANGUP             9
#define mSHUTDOWN           10
#define mCLPRGSELECT        11
#define mSTARTRETRAIN       12
#define mSELECTRETRAIN      13
#define mDETECTDIALTONE     17
#define mDIALDURATION       18
#define mSETTXLEVEL         19
#define mHDLCFRMEND         23
#define mDPHSTEST           24
#define mCLPRGTONECADENCE   25
#define mSTARTRENEG         26
#define mV22GUARDTONE       27

/*-------------------------------------------------------------------------
 Data Pump Responses
--------------------------------------------------------------------------*/

#define mDATATOHOST         0
#define mCONNECT            1
#define mNOCARRIER          2
#define mMODEMREADY         3
#define mCRCOK              4
#define mCRCERROR           5
#define mFRAMEACK           6
#define mXON                7
#define mXOFF               8
#define mDETECTFLAG         10
#define mGOTDIALTONE        11
#define mGOTBUSYTONE        12
#define mGOTREORDERTONE     13
#define mGOTRINGBACK        14
#define mDIALEND            15
#define mREMOTERETRAIN      16
#define mLOCALRETRAIN       17
#define mDET7E              18
#define mCHANGEBUFLEN       19
#define mDEBUGINFO          20
#define mCLPRGRESP          21
#define mSELECTSMPRATE      22
#define mHANGUPCOMPLETE     23

/*-------------------------------------------------------------------------
  DTMF generation status indicators
--------------------------------------------------------------------------*/

#define DTMFSILENCE 0x0001
#define DTMFSIGNAL  0x0002
#define DTMFEND     0x0004

/*-------------------------------------------------------------------------
  Modem Mode definations
--------------------------------------------------------------------------*/

#define V32BIS_MODE 0x0001
#define V22BIS_MODE 0x0002
#define V23_MODE    0x0004
#define V21_MODE    0x0008
#define B103_MODE   0x0010

/*-------------------------------------------------------------------------
  Modem HandShake Mode Selection
--------------------------------------------------------------------------*/

#define ENABLE_AUTO                   0
#define ENABLE_V8                     1
#define ENABLE_V32BIS                 2 
#define ENABLE_V32                    4
#define ENABLE_V22                    8
#define ENABLE_V21                    16
#define ENABLE_V23                    32
#define ENABLE_B103                   64

/*-------------------------------------------------------------------------
  Modem State definations
--------------------------------------------------------------------------*/

#define OFFLINECMDMODE       0
#define ONLINECMDMODE        1
#define ONLINEDATAMODE       2
#define ONLINEMODE           3

/*-------------------------------------------------------------------------
  DP Data Tx/Rx Mode configuration
--------------------------------------------------------------------------*/

#define DATA_L2MSS            0 //Lsb 2 Msb with start/stop addition/deletion
#define DATA_M2L              1 //Msb to Lsb without start/stop bits
#define DATA_HDLC             2 //HDLC mode
#define DATA_L2M              3 //Lsb 2 Msb without start/stop bits

/*-------------------------------------------------------------------------
  Debug DP State Machine Messages
--------------------------------------------------------------------------*/

// V.8 State Machine messages

#define V8_SILENCE_TX   0       // Initial silence in V8 originate mode
#define V8_SEND_CM      1       // Transmited CM sequence in ORG mode
#define V8_DETECT_JM    2       // Detected JM sequence in ORG mode
#define V8_CJ_TX        3       // Transmitted CJ sequence in ORG mode
#define V8_CM_DETECT    4       // Detected CM sequence in ANS mode 
#define V8_SEND_JM      5       // Transmitted JM sequence in ANS mode
#define V8_DETECT_CJ    6       // Detected CJ sequence in ANS mode

// V.32 State Machine messages

#define V32_ORG_START            7   // Start V.32 ORIGINATE Hand Shake
#define V32_START_AA         8   // Signal States AA transmission
#define V32_DETECT_AC        9   // Signal State AC
#define V32_DETECT_AC2CA    10   // AC-CA Reversal detected
#define V32_TX_AA2CC        11   // Signal state CA-AC transmit
#define V32_DETECT_CA2AC    12   // CA-AC Reversal detected
#define V32_TX_SILENCE          13   // Transmit silence
#define V32_DETECT_AC_DROP  14   // AC reception stopped
#define V32_DETECT_TRN          15   // Detected TRN sequence
#define V32_DETECT_R1       16   // Detected RATE-1 sequence
#define V32_TX_EC_TRN           17   // Send TRN in half duplex mode
#define AGC_DETECT_ENG_LOSS     18   // AGC detected energy loss
#define V32_TX_RATE2        19   // Send RATE-2 sequence
#define V32_DETECT_R3       20   // Detected RATE-3 sequence
#define V32_TX_E                21   // Send E sequence    
#define V32_DETECT_E            22   // Detected E sequence

#define V32_CONNECT_9600   23   // DP Connection establishment (9600 bps)
#define V32_CONNECT_4800   24   // DP Connection establishment (4800 bps)

//V.32 ANSWER MODE MESSAGES:

#define V32_ANS_START           25   // Start V.32 ANSWER Hand Shake
#define V32_DETECT_AA       26   // Detected AA signal state
#define V32_TX_AC2CA        27   // Signal state AC-CA transmit
#define V32_DETECT_AA2CC    28   // AA-CC Reversal detected
#define V32_TX_CA2AC        29   // Signal state CA-AC transmit
#define V32_TX_STOP_AC      30   // Stop the transmission of AC
#define V32_TX_RATE1        31   // Send RATE-1 sequence
#define V32_DETECT_R2       32   // Detected RATE-2 sequence
#define V32_TX_FD_TRN           33   // Send TRN in full duplex mode    
#define V32_TX_RATE3        34   // Send RATE-3 sequence

// V.22bis State Machine messages

#define V22_ORG_START           35   // Start V.22 ORIGINATE Hand Shake
#define V22_ANS_START           36   // Start V.22 ANSWER Hand Shake
#define V22_SENDUNSCRAM         37   // Send unscrambled 1's
#define V22_RECEIVEUNSCRAM      38   // Detected unscrambled 1's
#define V22_SENDS1              39   // Transmit S1
#define V22_SEND1200            40   // Send Scrambled 1's at 1200bps
#define V22_RECEIVES1           41   // Detected S1
#define V22_RECEIVE1200         42   // Detected Scrambled 1's at 1200bps
#define V22_SEND2400            43   // Transmit Scrambled 1's at 2400bps
#define V22_RXDSCRAMONES        44   // Received Scrambled 1's at 2400bps
#define V22_CONNECT_2400   45   // DP connection establishment (2400 bps)
#define V22_CONNECT_1200   46   // DP connection establishment (1200 bps)

// V.21 State Machine messages

#define V21_ORG_START           47   // Start V21 in originate mode
#define V21_ANS_START           48   // Start V21 in answer mode
#define V21_CONNECT_300    49   // V21 DP Connection establishment(300bps)

// V.23 State Machine messages

#define V23_ORG_START           50   // Start V23 in originate mode
#define V23_ANS_START           51   // Start V23 in answer mode
#define V23_CONNECT        52   // V23 DP Connection establishment 
                                     // (75/1200 bps - ORG Mode)
                                     // (1200/75 bps - ANS Mode) 


//-----------------------------------------------------------------------------
//    END OF FILE
//-----------------------------------------------------------------------------
