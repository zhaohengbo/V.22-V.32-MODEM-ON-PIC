
/******************************************************************************
;File Name:   AT_CMDS.H
******************************************************************************/

/*-------------------------------------------------------------------------
 AT Comamnd Interface Structure defination
--------------------------------------------------------------------------*/

typedef struct{
    CHAR commands[34];
    CHAR KeyBuf[20];
    CHAR aiCurBuf[20];
    CHAR aiprevbuf[20];
    CHAR KeyNo;
    CHAR PrevCmdCntr;
    CHAR icount;
    CHAR Backcommand;
    CHAR escapecount;
    CHAR ModulationMode;
    UCHAR ModMode;
    UINT ModRate[2];
    UCHAR DPConnect;
    UCHAR RetrainsRequested;
    UCHAR RetrainsGranted;
    UCHAR RingCounter;
    UCHAR ConnectPattern;
    UINT DPBitRate;
    UCHAR UARTTxBuf[30];
}AT_COMMAND;


/*-------------------------------------------------------------------------
 Offsets for accessing different strings String buffer
--------------------------------------------------------------------------*/

#define COMOK           0
#define COMERROR        7
#define NOCARRIER       17
#define COMCONNECT      31
#define CARRIER         42
#define COM2400         53
#define COM1200         60
#define COM9600         67
#define COM4800         74
#define COM300          81 
#define COMV23ORG       87
#define COMV23ANS       97
#define COMDTE_115200   107 
#define COMDTE_57600    116
#define COMDTE_38400    124
#define COMDTE_19200    132
#define COMDTE_9600     140 
#define COMPROTOCOL     147
#define COMNONE         159
#define COMLAPM         166 
#define COMRING         173 
#define COMBUSY         182
#define COMNODIALTONE   191
#define COMPRODUCTCODE  207
#define COMROMCHKSUM    214
#define COMPRODUCTTYPE  221

#define COM0            248                
#define COM4            254
#define COM3            260 
#define COM7            266  
#define COM6            272 
#define COM1            278

#define DETECTDIALTONE  284
#define DETECTBUSYTONE  303
#define SELECTMOD       322
#define DTESPEED        373 
#define CONNECTMODE     382  
#define RETRAINMODE     399
#define RENEGOTIATEMODE 416 
#define COM14400        437
#define COM12000        445
#define COM7200         453

/*-------------------------------------------------------------------------
  Offsets for accessing AT commands buffer
--------------------------------------------------------------------------*/

#define ATE                0        //ATE
#define ATHOOK             1       //ATHOOK
#define ATQ                2        //ATQ
#define ATV                3        //ATV
#define ATANDF             4        //AT&F
#define ATANDK             5        //AT&K
#define ATG                6        //ATG
#define ATV42              7       //ATV42
#define ATBUSY             8       //ATBUSY
#define ATDIALTONE         9        //ATDIALTONE DETECT
#define ATMODE             10      //Automode
#define ATS0               11      //ATS0
#define ATS1               12      //ATS1
#define ATS6               17      //ATS6
#define ATS7               18      //ATS7
#define ATS8               19      //ATS8
#define ATS9               20      //ATS9
#define ATS10              21      //ATS10
#define ATS11              22      //ATS11
#define ATS12              23      //ATS12
#define ATS18              24      //ATS18
#define ATS24              25      //ATS24
#define ATS25              26      //ATS25
#define ATS26              27      //ATS26
#define ATS29              28      //ATS29
#define ATS32              29      //ATS32
#define ATS33              30      //ATS33
#define ATS86              31      //ATS86
#define ATS91              32      //ATS91
#define ATL                33      //ATL

/*-------------------------------------------------------------------------
 Common Ascii Characters used in AT command interfare implementation
--------------------------------------------------------------------------*/

#define LF                0xA
#define CR                0xD
#define SP                0x20

#define KEY_ALTH        0x23
#define KEY_F1          0x3B
#define KEY_ENTER       0x0D
#define KEY_BKSPC       0x08

/*-------------------------------------------------------------------------
 Function definations used in AT command interface
--------------------------------------------------------------------------*/

void InterpretCommand(AT_COMMAND *, INT);
void SendString(AT_COMMAND*,INT);
void ProcessFunction(AT_COMMAND*,CHAR *,CHAR, CHAR);
void SendConfig(AT_COMMAND *);
void SendConfigParamsToDP(AT_COMMAND *);
void SendCharToUART(AT_COMMAND *,CHAR);
void ProcessSRegUpdate(AT_COMMAND *,INT , INT);
void GetConnectRate(AT_COMMAND *,INT);
void DecimalToUART(INT,UCHAR *);
void SendResponse(AT_COMMAND *,INT);

/******************************************************************************
;      END OF FILE
*******************************************************************************/
