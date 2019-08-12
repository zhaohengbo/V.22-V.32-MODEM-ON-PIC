/******************************************************************************
 File Name:   V42API.H 
*******************************************************************************/
#ifdef __cplusplus
extern "C" {
#endif
void V42InitBaseAddress(void *);
UINT V42OpenChannel(UINT Id);
ULONG V42GetMemRequirement(void);
void V42Control(UINT,UINT,UINT,UINT *PARAMS);
void V42ConfigParameters(UINT Id, UINT CONFIG_ID,UINT *PARAMS);
void V42ExecuteTimeOut1(UINT Id);
UINT V42SendData(UINT Id,UCHAR *DATA,UINT LEN);
void V42CloseChannel(UINT Id);
void V42ProcessDPMessage(UINT Id, UCHAR *msg, UCHAR *);
UINT V42ReceiveData(UINT Id,UCHAR *Data,UINT LEN);
void V42ReleaseTimer1(UINT ID);
void V42SetupTimer1(UINT ID,ULONG Tout_Period);
void V42SendMessageToDP(UINT ChnId,UCHAR MSG_ID,UINT LEN,UCHAR *PARM);
void V42IndicateStatus(UINT ChnId,UINT STATUS_ID,UINT LEN,UCHAR *PARM);
void Send1SecODP(void);
UINT V42SetState(UINT);
#ifdef __cplusplus
}
#endif
    /*specifies the maximum number of INFO frames that can be sent to DP
    in a single V42 call. This parameter is limited by the message queue
    length of the data pump    */

#define MAXFRAMESTODP    1

/*Control IDs defined for V42Control*/
#define START_LTEST            1
#define V42_HANGUP             2
#define ORIGINATE_MODEM        3
#define ANSWER_MODEM           4
#define SEND_BREAK             5
#define HOST_READY_FOR_DATA    6
#define V42_L_RELEASE          7
#define GET_CONNECT_STATUS     8

/*Config IDs defined for V42ConfigParameters*/

#define DICTIONARYSIZE      1
#define V42DISABLE          2
#define V42BISCOMPRESSION   3
#define DISABLE_ODP_TX      4
#define ENABLE_L_TEST       5 /*This setting allows the V42 to initiate the request for loopback test procedure.*/
#define ENABLE_S_REJECT     6
#define TX_WINDOW_SIZE      7
#define RX_WINDOW_SIZE      8

/*Status IDs defined for V42IndicateStatus*/

#define L_RELEASED            1
#define    NO_ACK_FOR_DISC    1    /*sub ID*/

#define V42_CONNECT           2

/*Parm 1 TX_COMPRESSION_ON       sub ID
 Parm 2 RX_COMPRESSION_ON        sub ID*/

#define DP_LOST_CARRIER       3

#define ASYNC_CONNECT         4
#define V42_PROTO_ERROR       5
#define RE_EST_DM_FBIT0       1
#define REJ_RESP_FBIT1        2
#define FRMR_RECD             3
#define N400_RE_TX            4
#define DM_RESP_WITH_FBIT1    5
#define NO_ACK_FOR_BREAK      6

#define    V42_OK                 6
#define    L_TEST_OK              7
#define    L_TEST_ERROR           8
#define    V42_READY_FOR_DATA     9
#define    REMOTE_V42_DISCONNECT 10
#define BREAK_RECD               11
#define BREAK_ACKED              12
#define V42_CONNECTION_STATUS    13
#define DP_RETRAIN_STATUS        14
#define V42_NEGOTIATION_STATUS   15
#define V42_ANS_ODP_DETECT       16
#define V42_ORG_ADP_DETECT       17
#define V42_RETRAIN_CONNECT      18
#define DP_XOFF_STATUS           19
#define DP_XON_STATUS            20

/*following are the sub IDs for this indication
      a)1-V42 ECM data mode
        0-ASYNC data mode
        2-NEGOTIATION state

      b)transmit direction bit rate/2400
      c)receive direction bit rate/2400
      d)transmit data compression  1-ON/0-OFF
      e)remote modem data compression 1-ON/0-OFF
      f)transmit direction window size 1-15
      g)Receive direction window size  1-15
      h)S-Reject capability               1-ON/0-OFF
      i)Loop Back test capability        1-ON/0-OFF
      j)frame size is always 128
*/

#define    NO_COMPRESSION        0    /*V42bis is disabled*/
#define    TX_COMPRESSION        1    /*Compression enabled in transmit direction*/
#define    RX_COMPRESSION        2    /*Compression enabled in receive direction*/
#define    TXRX_COMPRESSION      3    /*Compression enabled in both directions*/

#define DECODE_ERROR             14

/*definition for break & break related parameters*/
#define     BREAK                 0x40
#define     BREAKACK              0x60
#define     NONEXP_NONDESTRUCTV   0x00
#define     EXP_DESTRUCTV         0xc0
#define     EXP_NONDESTRUCTV      0x40
        
//#define OUTDATABUFLEN1        148

/******************************************************************************
 END OF FILE 
*******************************************************************************/
