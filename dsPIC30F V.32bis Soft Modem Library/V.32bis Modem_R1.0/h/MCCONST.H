/**************************************************************************
* FILE NAME:   MCCONST.H
***************************************************************************/



/***************************************************************************
*
* MCCONST.H  :
*
*       Contains V.42 Error Controller software Constants
*       and macros declaration
*
*
****************************************************************************/


#define MAXSIZE_OF_V42_DATAFRAME       130

#define MAX_DTE_BUFSIZE                150
#define MAX_DP_BUFSIZE                 140

#define TRUE                           1
#define FALSE                          0
#define ON                             0x01
#define OFF                            0x00


#define NO_CMPRSN                      0
#define BIS_CMPRSN                     1
#define MNP5_CMPRSN                    2
#define TX_CMPRSN                      1
#define RX_CMPRSN                      2
#define TWO_WAY_CMPRSN                 3
#define NO_PROTO                       0
#define V42_PROTO                      1
#define MNP4_PROTO                     2
#define V42BIS_PROTO                   2

    /* Detect time 3 sec */

#define V42_DETECT_TIMOUT              3000
#define MAX_RETRAINS_WITHOUTCAR        3
#define DM_RETRAIN_CARRIER_TIMEOUT     25000       /* 25 Secs in milli sec units */

    /* V42 handling Related */

#define ODP                            0xFF
#define ADP                            0xFE
#define INFO                           0x02
#define RR                             0x01
#define RNR                            0x05
#define SABME                          0x7F
#define DISC                           0x53
#define DM                             0x1F
#define REJ                            0x09
#define SREJ                           0x0D
#define TEST                           0xE3
#define XID                            0xAF
#define FRMR                           0x87
#define UA                             0x73
#define UI                             0x03

#define ADDRESS                        0X01

#define FRMR_SEC                       0x97
#define DM_SEC                         0xf
#define NR_ERROR                       0x08
#define PARAM_NOT_SUPP                 0X01
#define MaxRetrans                     5
#define SET                            1
#define RESET                          0
#define OPEN                           1
#define CLOSED                         0
#define TRANS_Window_size              5
#define RECV_Window_size               5
#define ALLOC_FD_ARRAY_SIZE            10
#define MAX_FD_ARRAY_SIZE              (ALLOC_FD_ARRAY_SIZE - 1)
#define NO_ECM                         0
#define V42_42BIS                      1
#define V42                            2
#define N400_COUNT                     4        /* 10 */


#define T401_TIMEOUT                   2500     /* 2.5 secs */
#define Timer_T401                     3000    /* 3 sec timeout */

#define PARENT                         1
#define CHILD                          2
#define NEXT                           3
#define MY_NUL                         0x3fff
#define XID_V42_GID                    0x80
#define XID_HDLC_OPT_FUN_PID           0x03
#define XID_MAX_TX_IFIELD_LEN_PID      0x05
#define XID_MAX_RX_IFIELD_LEN_PID      0x06
#define XID_TX_WINDOW_SIZE_PID         0x07
#define XID_RX_WINDOW_SIZE_PID         0x08
#define XID_V42BIS_GID                 0xF0
#define XID_V42BIS_PARM_SET_PID        0x00
#define XID_V42BIS_DATA_COMP_PID       0x01
#define XID_V42BIS_NUM_CODEWORDS_PID   0x02
#define XID_V42BIS_MAX_STRLEN_PID      0x03
#define XID_USER_DATA_SUBFIELD_GID     0xFF


/* The initial code word size */
#define InitialCodeWordSize            9
/* Maximum size of the code word (in bits) */
#define MaxCodeWordSize                12
/* Cardinality of the set of alphabets */
#define NumChars                       256

/* Index number of the first dictionary entry used to store a string */
#define IndexNum                       NumChars+2
/* Number of control words */
#define NumControlWords                3

/* Threshold for code word size */
#define Threshold                      NumChars
/* The mode of transmission */
#define TRANSPARENT                    0

/* The mode of transmission */

#define COMPRESSED                     1
#define ENT_TRANS_MODE                 0
#define ENT_COMP_MODE                  0
#define EID                            1
#define FLUSH                          1
#define STEPUP                         2
#define DEC_RESET                      2

    /* States declaration */

#define WAIT_FOR_CARRIER_STATE         0x05
#define DISCONNECTED                   0x08
#define PRE_CONNECTED_STATE            0x10
#define DISCONNECTING_STATE            0x11
#define SYNC_DATA_STATE                0x21
#define ASYNC_DATA_STATE               0x22
#define V42_DETECTION_STATE            0x23
#define V42_NEGOTIATION_STATE          0x24
#define DP_RETRAINING_STATE            0x26
#define DP_RETRAIN_CARRIER_STATE       0x27
#define DISCONNECTING_STATE1           0x28
#define DISCONNECTING_STATE2           0x29
#define DISCONNECTING_STATE3           0x2A
#define V42_NEG_TMP_STATE              0x2B

#define ORIGINATEMODE                  1
#define ANSWERMODE                     2
#define CONNECTED                      1

/* Constants declaration */

#define OK                             1      /* 30 */
#define ERROR                          0      /* 31 */
#define TRUE                           1

#define FALSE                          0

#define ON                             0x01

#define SIZEDPDATABUF                  256
#define SIZEDTEDATABUF                 1024
#define BUFF_START                     1024
#define MAXDPMSGLEN                    300
#define MAX_NBYTS_2DTE                 125
#define V42ENABLED                     8


#define ODP_ADP_DET_TIMER              2
#define N400_RETX_TIMER                3
#define NEG_N400_TIMER                 4
#define SYNCMODE_T401TIMER             5
#define SYNCMODE_N400_RETX             6
#define DISCONNECTION_TIMEOUT          7
#define HANGUP_TIMEOUT                 8
#define ODP_TRANSMIT_TIMEOUT           9
#define ASYNC_TRANSMIT_TIMEOUT         10
#define RE_TX_BREAK_TIMER              11
#define XID_PREAMBLE_TIMER             12

/**************************************************************************
* END OF FILE
***************************************************************************/
