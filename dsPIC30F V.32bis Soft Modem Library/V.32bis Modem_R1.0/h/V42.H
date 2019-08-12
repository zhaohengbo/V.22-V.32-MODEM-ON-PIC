/******************************************************************************
 File Name:   V42.H 
******************************************************************************/

#include "datatype.h"
#include "mcconst.h"

#define HOSTDATARXBUFLEN       1024
#define HOSTDATATXBUFLEN       512
#define DPDATARXBUFLEN         512
#define DPDATATXBUFLEN         512

#define MAXV42MSGLEN           255

extern void *V42Chn0BaseAddress;

/* Structure for storing response V.42 frame details */

typedef struct
{
    UCHAR Pbit_value;
    UCHAR CR_value;
    UCHAR Iframe_Vs;
    UCHAR frmr_field0;
    UCHAR frmr_field1;
    UCHAR frmr_field2;
    UCHAR type_of_frame;
} FRAME_DETAILS_STRUCT;


typedef struct
{
    UCHAR FrmAddress;
    UCHAR IfrmVs;
    UCHAR IfrmVr;
    UCHAR mtext[MAXSIZE_OF_V42_DATAFRAME];
    UCHAR len;
    UCHAR frm_seq_num;
} Mesg;

typedef struct{

UCHAR           Trans_indx;            //Frame window index
UCHAR           Wnd_buf_len;           //Frame window buffer length
UCHAR           received_cmprsn_mode;  //Flag for compression mode enabling
UCHAR           *V42_tx_buf;           //Frame transmit buffer
UCHAR           *tmpPtr;               //Frame buffer pointer 
UCHAR           *DataPtr;              //V42 data buffer pointer
UWORD            DataLen;              //Data buffer length
UINT             FcsErrors;            //CRC Frame error count 

UCHAR           Vs, Va, Vr, Ns;        //Conter to keep track of V.42 frame tx and rx
UCHAR           Vsb, Vrb;
UCHAR           response_frame;        //Flag to indicate the reception of response frame
UCHAR           *Wnd_ptr;              //Frame Window buffer pointer
UCHAR           snd_frametype, rcv_frametype; //transmit and receive frame types
UCHAR           Pbit , C_R;            //P-Bit indication (Ref: ITU-T V.42 standard)
UCHAR           FRMR_field[5];         //Frame receive field buffer

UCHAR           Retrans_count;         //Count to keep track of frame retransmissions
UCHAR           Last_patt, Curr_patt;  //Curret and previous ODP/ADP pattern
UCHAR           Pbit_unAcked;          //Indication for unacknoledged P-bit
UCHAR           rcv_frm[140];          //Buffer to store the received frame bytes

UCHAR           Parameter_ID;          //XID frame parameter ID
UCHAR           Parameter_len;         //XID frame parameter length
UCHAR           received_XID_flag;     //XID reception indication
UCHAR           received_P1_parm_flag; //P1,P2 flags
UCHAR           received_P2_parm_flag;
UCHAR           flags_detected;        //Detection of HDLC flags
UCHAR           WndWrIndx;             //Frame window write index
UCHAR           neg_phase_snd_frame;   //used to save frame sent during v42 negotiation

UCHAR           InBufByteCnt;          //Used for frame buffer reads
UCHAR           nbyt;  
UCHAR           frmlen;

UCHAR           Enc_window_num;        //Frame Window number in trnsmission
UCHAR           Dec_window_num;        //Frame window number in reception
UCHAR           received_Ifrm_cnt;     //I-Frame reception count
UCHAR           DecWndRdIndx;          //Receive frame window read indices
UCHAR           fd_rdindx;              
UCHAR           fd_wrindx;
UCHAR           rec_frm_cr_value;      //C-R value of the received frame
UCHAR           RNR_frame_sent;        //Indication for RNR frame transmission
Mesg            Trans_Mesg_Window[TRANS_Window_size]; //Transmit frame window
Mesg            Recv_Mesg_Window[RECV_Window_size];   //Receive frame window
Mesg            *WindowPtr;            
FRAME_DETAILS_STRUCT    frame_details_array[ALLOC_FD_ARRAY_SIZE];

V42BITVAR       dis_xid;     
V42BITVAR       build_response;         //Indication for preparing the response frame
V42BITVAR       rem_recv_window, local_recv_window; //Remote and local receive window sizes 
V42BITVAR       Ec_connect, DCE_role, Iframe_reject;//Used to indicate mode of connection
V42BITVAR       Invalid_Frame , Timer_recvy; 
V42BITVAR       received_resp_frm;      //flag to indicate received frame type
V42BITVAR       stop_Iframe_receive;    //For controlling receipt of Iframes under own busy case
V42BITVAR       REJ_condition;          //To indicate reject exception condition
V42BITVAR       re_establish_v42;       //Flag to indicate re-establish v42 phase
V42BITVAR       T401_timer_state;       //Flag for stopping or starting T401 timer check
V42BITVAR       send_RR_cmd_frame;      //Indication for transmitting RR command frame
V42BITVAR       FrameAvailable;         //Valid frame availability
V42BITVAR       TestFrameSent;          //TEST-Frame transmission 
UWORD           kmod, ADDR_ptr;       
UWORD           Group_Identifier,Format_Identifier;  //used in XID frame formation
UWORD           BREAK_Precede,Break,BREAK_Len,BREAK_DISCARD;//Used in BREAK signal transmission
UCHAR           Break_type,BrkOrAck;    
UWORD           P0;
UWORD           ADP_snt,ODP_snt,detect_cnt; //ADP/ODP transmi and receive indication
UWORD           ODPReTxCnt;              //ODP retransmission count

UWORD           Num_ODP_reqd;            //Number of ODP's required
UWORD           TmpVa , TmpVs, Nr;       //Frame sequence counts
UWORD           neg_timer;
UWORD           Group_len;
UWORD           tmpval;
UWORD           RetrainingFlag;
UWORD           AbortDec;
}V42DATASTRUCT;


typedef struct{
    UCHAR  state;               //V42 state indication
    UCHAR  charread;            //Frame byte
    UCHAR  Local_data_comp;     //Local V42bis enable flag
    UCHAR  Rem_data_comp;       //Remote v42bis enable flag
    UCHAR  cmprsn_mode;         //Mode of V42bis copmression
    UCHAR  current_cmprsn_mode; //Present v42bis compression mode 
    UWORD  dict_size;           //V.42bis dictionary size
    UWORD  TotalNumCodeWords;   //Total number of code words in a frame
    UWORD  MaxStrLen;           //Maximum v42bis string length
    UCHAR  Trans_Wnd_size, Recv_Wnd_size; //Tx and Rx window size
    UCHAR  Trans_Info_field, Recv_Info_field; 

    V42BITVAR       FCS32_ena, Sreject; //32 bit CRC Enable and single frame
    UWORD           LOOP_TEST;          //reject enable
    UCHAR           TxBitRate;          //DP transmit and receive bit rates
    UCHAR           RxBitRate;

    UCHAR NoODP;               //No ODP transmission
    UCHAR SessionOk;           //V.42 session success indication
    UCHAR ErrorCode;           //V.42 error condition
    UCHAR cTmp1;
    UCHAR cTmp3;
    UCHAR send_retrain_resp;   //DP retrain response for V.42
    UCHAR previous_state_bak;  //Previous state of V.42
    UCHAR previous_state;
    UCHAR ECM_rescode;         //Error control mode(Previous mode)

    CMDBITVAR ECM_enabled;     //Error control mode enabled
    CMDBITVAR HdlcFrameSent2Line; //Frame updated to Tx buffer
    CMDBITVAR MdmTimerStatus;  //Couners to execute V.42 timeouts 
    CMDBITVAR MdmTimeout;
    ULNG MdmTimeOutCount;
    UINT TimerEventSet;
    INT DpBufWIndex, DpBufRIndex;  //Indicaes used for different DP data buffers
    INT DteBufWIndex, DteBufRIndex;

    GENBITVAR DteFlowControl;      //Flowcontrol related
    GENBITVAR DpFlowControl;

    UCHAR DP_buffer[MAX_DP_BUFSIZE];  //Buffer for data transfer to/from DP

    UINT        DpDatCount;      // Buffer for data transfer from DP to V42 during detection phase 
    UCHAR PARM[4];
} V42COMMONDATASTRUCT;

typedef struct{
UINT    ChnId;
V42DATASTRUCT V42v;
V42COMMONDATASTRUCT V42Data;
UCHAR     MsgId;
UCHAR     MsgLen;
UCHAR     MsgParams[6];
} V42CDBSTRUCT;

//extern V42CDBSTRUCT V42Cdb;

#define V42Bis    V42CDSP->V42Bis

#define V42v    V42CDSP->V42v

#define V42Data    V42CDSP->V42Data
#define msgId        V42CDSP->MsgId
#define msgLen        V42CDSP->MsgLen
#define msgParams        V42CDSP->MsgParams

void Allocate_mem(V42CDBSTRUCT *V42CDSP);

void SetupTimer(V42CDBSTRUCT *V42CDSP,ULNG Tout_Period);

void ReleaseTimer(UINT);

void init_v42bis_var(V42CDBSTRUCT *V42CDSP);

void Initialize_EN_Dictionary(V42CDBSTRUCT *V42CDSP);

void Initialize_DE_Dictionary(V42CDBSTRUCT *V42CDSP);

INT read_byte(V42CDBSTRUCT *V42CDSP);

void perform_modem_hangup(V42CDBSTRUCT *);

INT get_data_from_Host(V42CDBSTRUCT *V42CDSP,UCHAR *DataBuf);

INT get_data_from_DP(V42CDBSTRUCT *V42CDSP,UCHAR *BufPtr,UWORD MAXS);

INT get_df_fromDP(V42CDBSTRUCT *V42CDSP,UCHAR *DPbuf);

void SendDataToDte(V42CDBSTRUCT *V42CDSP );

void PutMessageOnQueue(void);

void init_v42var(V42CDBSTRUCT *);

void Build_frame(V42CDBSTRUCT *);

#define SetTimeOutEvent(x) V42Data.TimerEventSet = x
#define RESETDPBUFPTRS()       V42v.frmlen = 0

/******************************************************************************
 END OF FILE 
*******************************************************************************/
