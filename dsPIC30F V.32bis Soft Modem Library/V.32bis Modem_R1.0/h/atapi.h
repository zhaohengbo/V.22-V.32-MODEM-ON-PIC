/******************************************************************************
;File Name:   API_C.H
******************************************************************************/
/*-------------------------------------------------------------------------
 Message Queue structure defination used in AT Command interface
--------------------------------------------------------------------------*/

typedef struct {
    CHAR *BufPtr;            //Store messages for AT Cmd interface
    CHAR *Write;             //Current write pointer to ip queue
    CHAR *Read;              //Current read pointer to ip queue 
    UCHAR Size;              //Length of the queue
} ATMSGQSTRUCT;

/*-------------------------------------------------------------------------
 Export/Import Function definations used in AT command interface
--------------------------------------------------------------------------*/

void InitATCommands(void);
void ProcessATCommands(ATMSGQSTRUCT*, CHAR);
void DPIndicateStatus(CHAR,UINT *);

void ATIndicateStatus(CHAR ,UINT *);
void ATSendMsgToDP(UCHAR ,UCHAR ,UCHAR *);
void ATSendStringToUART(UCHAR *, UINT);

/*-------------------------------------------------------------------------
 Message Identifiers used by AT command layer to pass information to 
 the application
--------------------------------------------------------------------------*/

#define DETECT_ESCAPE_SEQUENCE    1
#define GO_ON_HOOK                2
#define GO_OFF_HOOK               3
#define MODEM_RESET               4
#define START_ORG_MODE            5
#define START_ANSWER_MODE         6
#define SET_MODEM_MODE_RATE       7
#define MODEM_HANGUP              8 
#define SET_H_MODE                9
#define MODEM_CONFIG              10
#define START_ALB_MODE            11
#define CLPRG_SPEAKER_VOLUME      12

/*-------------------------------------------------------------------------
 Message Identifiers used by application to pass information to the 
 AT command layer
--------------------------------------------------------------------------*/

#define DP_CONNECT              1
#define DP_ASYNC_CONNECT        2
#define DP_LAPM_CONNECT         3
#define DP_LOCAL_RETRAIN        4
#define DP_REMOTE_RETRAIN       5
#define SEND_OK_RESPONSE        6
#define DP_CP_STATUS            7
#define SM_HANGUP               8
#define V42_ERROR               9

/******************************************************************************
;      END OF FILE
******************************************************************************/
