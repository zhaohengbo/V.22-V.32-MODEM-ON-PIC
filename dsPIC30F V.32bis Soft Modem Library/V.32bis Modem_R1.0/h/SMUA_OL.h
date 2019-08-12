
//============================================================================
#include "datatype.h"
//============================================================================

//============================================================================
//Soft-Modem configuration structure
//============================================================================

typedef struct {
    UCHAR DPTxLevel;
    UCHAR SpeakerVolume; 
    UCHAR SMMode;
    UCHAR DialString[20];
    UCHAR DPModMode;	
    UINT  MaxCnxRate;
    UCHAR V42Enable;
}SM_CONFIG;

//============================================================================
// Flags to indicate the type of connection
//============================================================================

#define DP_CONNECT          1
#define NON_LAPM_CONNECT    2
#define LAPM_CONNECT        4
#define RETRAIN_CONNECT     8

//============================================================================
// Flags to indicate the disconnect reason
//============================================================================

#define NO_DIAL_TONE         1
#define DETECT_BUSY_TONE     2
#define CONNECTION_TIMEOUT   4 
#define HANGUP_COMPLETE      8
#define LOST_REMOTE_CARRIER  16
#define REM_V42_DISCONNECT   32
#define V42_PROTOCOL_ERROR   64

//============================================================================
//============================================================================


