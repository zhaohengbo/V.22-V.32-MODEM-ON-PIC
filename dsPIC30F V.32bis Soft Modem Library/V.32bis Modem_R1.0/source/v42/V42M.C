/******************************************************************************
 File Name:   V42M.C 
*******************************************************************************/

#include "api_c.h"
#include "v42.h"
#include "v42api.h"

#ifdef DEF_V42

/***************************************************************************
*
* V42M.C (Miscellanious Functions)  :
*
*       Contains miscellanious functions for implementing V42/V.42bis protocol
*
*
****************************************************************************/

void init_on_v42_establishment(V42CDBSTRUCT *V42CDSP);
void chk_for_resp_frame_txmt(V42CDBSTRUCT *V42CDSP);
void chk_for_Iframe_txmt(V42CDBSTRUCT *V42CDSP);
void chk_for_sabme_txmt(V42CDBSTRUCT *V42CDSP);
void snd_DISC(V42CDBSTRUCT *V42CDSP);
void perform_modem_hangup(V42CDBSTRUCT *V42CDSP);
void chk_and_proc_frm(V42CDBSTRUCT *V42CDSP);
void V42ReleaseTimer1(UINT);
void Build_XID_frame(V42CDBSTRUCT *);
void Chk_Frame_type(V42CDBSTRUCT *);
void Process_Frame(V42CDBSTRUCT *);
void InitV42State(V42CDBSTRUCT *V42CDSP);

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void init_v42var(V42CDBSTRUCT *V42CDSP)
{
    V42v.rem_recv_window = V42v.local_recv_window = OPEN;
    V42v.tmpval = 0;
    V42v.Trans_indx = 0;
    V42v.TmpVa = V42v.TmpVs = 0;
    V42v.kmod  =  V42v.build_response =  V42v.response_frame = 0;
    V42v.snd_frametype =  V42v.rcv_frametype = 0 ;
    V42v.Pbit = V42v.C_R =0;
    V42v.Vrb =  V42v.Vsb = 0;
    V42v.Invalid_Frame = 0;
    V42v.Pbit_unAcked = 0;
/*
    Note : With ZOOM V34 MODEM, if SREJ is opted,
    then even REJ is treated as SREJ ????
*/
    /* V42v.Sreject = 1;  */
    V42Data.Sreject = 0;
    V42v.re_establish_v42 = 0;
    init_on_v42_establishment(V42CDSP);
    V42v.send_RR_cmd_frame = 0;
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void init_on_v42_establishment(V42CDBSTRUCT *V42CDSP)
{
    V42v.Vs = V42v.Va = V42v.Vr = V42v.Nr = V42v.Ns =  0;
    V42v.Iframe_reject = 0;
    V42v.Enc_window_num = 0;
    V42v.Dec_window_num = 0;
    V42v.received_Ifrm_cnt = 0;
    V42v.DecWndRdIndx = 0;
    V42v.WndWrIndx = 0;
    V42v.stop_Iframe_receive = 0;
    V42v.REJ_condition = 0;
    V42v.Timer_recvy = RESET;
    V42v.fd_wrindx = 0;
    V42v.fd_rdindx = 0;
    V42v.Retrans_count = 0;
    V42v.RNR_frame_sent = 0;
    V42v.T401_timer_state = OFF;
}

/**************************************************************************/
/**************************************************************************/

/*
snd_cmdframe_V42v.Pbit1() :

    Function to setup parameters for command frame with V42v.Pbit to 1
    and to save the details into the array for building the frame
    later on
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void snd_cmdframe_Pbit1(V42CDBSTRUCT *V42CDSP)
{
    /* setup command frame value based on current mode (ORG or ANS) */
    if (V42v.DCE_role)
        V42v.C_R = 0x02;
    else
        V42v.C_R = 0x00;

    /* Save the frame details into the array */
    V42v.frame_details_array[V42v.fd_wrindx].Pbit_value = 0x01;

    V42v.frame_details_array[V42v.fd_wrindx].CR_value = V42v.C_R;

    V42v.frame_details_array[V42v.fd_wrindx].type_of_frame = V42v.snd_frametype;

    /* Update the array index - circular buffer mode */

    if (V42v.fd_wrindx == MAX_FD_ARRAY_SIZE)
        V42v.fd_wrindx = 0;
    else
        V42v.fd_wrindx++;
}

/**************************************************************************/
/**************************************************************************/

/*
snd_respframe_Fbit0() :
    Function to setup parameters for response frame with Fbit to 0
    and to save the details into the array for building the frame
    later on
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void snd_respframe_Fbit0(V42CDBSTRUCT *V42CDSP)
{
    /* setup response frame value based on current mode (ORG or ANS) */
    if (V42v.DCE_role)
        V42v.C_R = 0x00;
    else
        V42v.C_R = 0x02;

    /* Save the frame details into the array */

    V42v.frame_details_array[V42v.fd_wrindx].Pbit_value = 0x00;
    V42v.frame_details_array[V42v.fd_wrindx].CR_value = V42v.C_R;
    V42v.frame_details_array[V42v.fd_wrindx].type_of_frame = V42v.snd_frametype;

    /* Update the array index - circular buffer mode */
    if (V42v.fd_wrindx == MAX_FD_ARRAY_SIZE)
        V42v.fd_wrindx = 0;
    else
        V42v.fd_wrindx++;
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void chk_for_resp_frame_txmt(V42CDBSTRUCT *V42CDSP)
{
    /* Check if any frames are queued for sending as responses */
    while (V42v.fd_wrindx != V42v.fd_rdindx)
    {
        /* DP flowcontrol condition ? */
        if (V42Data.DpFlowControl == TRUE)
            return;
        /* Used for waiting txmt of resp to DISC frame */

        V42Data.HdlcFrameSent2Line = FALSE;
        /* If so, get the frame details from the array */

        V42v.snd_frametype = V42v.frame_details_array[V42v.fd_rdindx].type_of_frame;

        /* check if Iframe to be built (in response to SREJ frame) */

        if (V42v.snd_frametype == INFO)
        {
            /*
            save the current send seq no. and setup the seq no. of the
            Iframe to be sent. After building the frame, restore the
            current send seq no.
            Note : for Iframes, Build_frame(), generates V42v.Pbit and V42v.C_R values
            */

            V42v.TmpVs = V42v.Vs;
            V42v.Vs = V42v.frame_details_array[V42v.fd_rdindx].Iframe_Vs;
            Build_frame(V42CDSP);
            V42v.Vs = V42v.TmpVs;
        }
        else
        {
            /* Control / supervisor frame to be built */
            V42v.Pbit = V42v.frame_details_array[V42v.fd_rdindx].Pbit_value;

            /* If it is FRMR response, setup the frmr fields */
            if (V42v.snd_frametype == FRMR)
            {
                /* V42v.C_R value is setup in Build_frame() */
                V42v.rec_frm_cr_value = V42v.frame_details_array[V42v.fd_rdindx].CR_value;
                V42v.FRMR_field[0] = V42v.frame_details_array[V42v.fd_rdindx].frmr_field0;
                V42v.FRMR_field[1] = V42v.frame_details_array[V42v.fd_rdindx].frmr_field1;
                V42v.FRMR_field[2] = V42v.frame_details_array[V42v.fd_rdindx].frmr_field2;
            }
            else
                V42v.C_R  = V42v.frame_details_array[V42v.fd_rdindx].CR_value;

            /* call function to build the response frame */
            if (V42v.snd_frametype == XID)
                Build_XID_frame(V42CDSP);
            else
                Build_frame(V42CDSP);
        }

        /* Update the array read index - circular buffer mode */
        if (V42v.fd_rdindx == MAX_FD_ARRAY_SIZE)
            V42v.fd_rdindx = 0;
        else
            V42v.fd_rdindx++;
    }
}

/**************************************************************************/
/**************************************************************************/

/*
    void chk_for_Iframe_txmt() :
    Function to check conditions for building Iframes  and
    if Iframe to be built, builds it
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void chk_for_Iframe_txmt(V42CDBSTRUCT *V42CDSP)
{
INT MaxFrames=0;

    /*
    If an I frame is to be sent and not in timer recovery V42Data.state and
    remote DCE is ready, send it.

    Note :  In T401 timeout condition (i.e. in timer recovery), we will
        send supervisory frame and on receipt of acknowledgement frame
        we will set V42v.Va and V42v.Vs to the V42v.Nr value of the response frame. So
        even if an REJ/SREJ frame is missed due to line errors, the
        unacknowledged Iframes will be retransmitted (8.5.1).
        Iframes is build if no response frame is pending for transmission
    */

    if ((V42v.fd_wrindx == V42v.fd_rdindx) && (V42v.Timer_recvy == RESET) &&
        (V42v.rem_recv_window == OPEN))
    {
        /* If frames available, until DP flowcontrol cond., send them */

        while(V42v.WndWrIndx != V42v.Vs)
        {
            /* DP flowcontrol condition ? */
            if (V42Data.DpFlowControl == TRUE)
                return;

            V42v.snd_frametype = INFO;
            Build_frame(V42CDSP);

            /* increment the send frame sequence number */

            if(V42v.Vs == 127)
                V42v.Vs = 0;
            else
                V42v.Vs++;

            /*The maximum number frame s that can be sent to DP is decided
            by the internal buffering of the DP*/
            if (++MaxFrames >= MAXFRAMESTODP) break;
        }
    }
}

/**************************************************************************/
/**************************************************************************/

/*
chk_for_sabme_txmt() :

    Function to check for T401 timeout and if timeout, retransmit
    SABME frame. Also checks if the SABME frame is retransmitted
    for N400 times. If so disconnect.
    This function is used during re-establishment phase
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void chk_for_sabme_txmt(V42CDBSTRUCT *V42CDSP)
{
    /* check if T401 timeout occured or not */

        /* T401 timeout */
//        V42Data.MdmTimeout = FALSE;

        /* N400 count of retransmissions, abort negotiation */

        if (V42v.Retrans_count >= N400_COUNT)
        {
            V42Data.SessionOk = 5;
            perform_modem_hangup(V42CDSP);
            return;
        }

        /* Retransmit the Frame */
        V42v.Retrans_count++;
        V42v.Pbit = 0x01;
        if (V42v.DCE_role)
            V42v.C_R = 0x02;
        else
            V42v.C_R = 0x0;
        V42v.snd_frametype = SABME;
        Build_frame(V42CDSP);
        /* Setup T401 timeout timer */
        V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
        SetTimeOutEvent(SYNCMODE_N400_RETX);
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Chk_Frame_type(V42CDBSTRUCT *V42CDSP)
{
    V42v.rcv_frametype = 0;

    /* Get the type of Frame - i.e. Command or Response frame */
    if (V42v.rcv_frm[0] & 0x02)
        V42v.C_R = 0x02;
    else
        V42v.C_R = 0x00;

    V42v.rcv_frametype = V42v.rcv_frm[1];

    if ((V42v.rcv_frm[1] & 0x01) == 0)   /* For Iframes */
    {
        V42v.Ns = ((V42v.rcv_frm[1] >> 1) & 0x7F);
        V42v.rcv_frametype = INFO;
        V42v.Pbit = V42v.rcv_frm[2] & 0x01;
        V42v.Nr = ((V42v.rcv_frm[2] >> 1) & 0x7F);
    }
    else if ((V42v.rcv_frametype < 0x0f) && (V42v.rcv_frametype != 3))   /* 3 for UI frame */
    {
        V42v.Pbit = V42v.rcv_frm[2] & 0x01;
        V42v.Nr = ((V42v.rcv_frm[2] >> 1) & 0x7F);
    }
    else
        V42v.Pbit = V42v.rcv_frm[1] & 0x10;
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void perform_modem_hangup(V42CDBSTRUCT *V42CDSP)
{
    /*
    Set the V42Data.state to DISCONNECTED which in turn set the V42Data.state to
    OFFLINE cmd V42Data.state
    */

    /* In T7,T8 case display the error count on AT&T0 or on TIME OUT (s[18]) */
    //RRR

//    if ((prevs_test_mode == T7) ||(prevs_test_mode == T8))
//        disp_lpbk_err_cnt();

    V42ReleaseTimer1(V42CDSP->ChnId);
    V42Data.state = DISCONNECTED;

    /* Event based ctrl, needs to be invoked again for disc */
    //RRR
    //MdmHwIfSpecialService(INVOKE_CMD_HANDLER);

    /* To clear any cmd chars loaded during ESC check */
//    cmdbuf_len = 0;

    /* perform V42 initialization */
    init_v42var(V42CDSP);

    V42SendMessageToDP(V42CDSP->ChnId,mHANGUP,0,msgParams);
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void StartV42(V42CDBSTRUCT *V42CDSP, INT mode)
{
    V42Data.DteFlowControl = FALSE;
    V42Data.DpFlowControl = FALSE;
    InitV42State(V42CDSP);

    if ( !(V42v.DCE_role & V42ENABLED) ) V42v.DCE_role = 2;
    else {
        if (mode & ORIGINATEMODE)
            V42v.DCE_role = 1;    // v.42 requires the following values
        else if (mode & ANSWERMODE)
            V42v.DCE_role = 0;    // 0=Answer and 1=Originate mode
        else V42v.DCE_role = 2;
    }
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void InitV42State(V42CDBSTRUCT *V42CDSP){
    init_v42var(V42CDSP);
    init_on_v42_establishment(V42CDSP);
    V42ReleaseTimer1(V42CDSP->ChnId);
    V42Data.state = WAIT_FOR_CARRIER_STATE;
    V42Data.DteFlowControl = FALSE;
    V42Data.DpFlowControl = FALSE;
    V42Data.state = WAIT_FOR_CARRIER_STATE;
}

/**************************************************************************/
/**************************************************************************/

/*
void Check_for_T401_timeout() :

    Function to check for T401 timeout and on timeout, perform
    Timer recovery process.
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Check_for_T401_timeout(V42CDBSTRUCT *V42CDSP)
{
    /*
    Since timeouts depend on carrier speeds, after detecting
    the carrier speed, timeout value is set to the variable.

    But currently fixed timeout is used.
    Check if timer T401 timed out
    */

    if (V42Data.MdmTimeout == TRUE)
    {
        V42Data.MdmTimeout = FALSE;
        /* 8.4.8 */
        if (V42v.Timer_recvy == RESET)
        {
            V42v.Retrans_count = 0;
            V42v.Timer_recvy = SET;
        }

        /*
        check if the retrans count reached N400,
        initiate re-establishment procedure - 8.4.9
        Note : do we get into problem during retrain ???
        */

        if(V42v.Retrans_count >= N400_COUNT)
        {
            /* initiate reconnect */

            V42v.Pbit = 0x01;

            if (V42v.DCE_role)
                V42v.C_R = 0x02;
            else
                V42v.C_R = 0x0;

            V42v.snd_frametype = SABME;
            Build_frame(V42CDSP);
            V42v.Retrans_count = 0;
            V42v.re_establish_v42 = 1;
            V42Data.ErrorCode = N400_RE_TX;
            SetTimeOutEvent(SYNCMODE_N400_RETX);
        }
        else
        {
            /* 8.4.8 and 8.4.6 Note 2 */
            /*
                V42v.Pbit unacked to be checked here ??? i.e. is it necessary that
                at any point of time only one V42v.Pbit can be outstanding ?. If that
                is the case, how can we send sup frames upto the count of N400
                in timer recovery condition ?.
            */

            /* Send command frame to query the remote status */

            V42v.Pbit = 0x01;
            if(V42v.DCE_role)
                V42v.C_R = 0x02;
            else
                V42v.C_R = 0x0;

            if (V42v.local_recv_window == OPEN)
                V42v.snd_frametype = RR;
            else
                V42v.snd_frametype = RNR;

            Build_frame(V42CDSP);
            V42v.Pbit_unAcked++;

            /* Increment retransmit count */
            V42v.Retrans_count++;
        }
        /* Setup T401 timeout timer */
        SetTimeOutEvent(SYNCMODE_T401TIMER);
        V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
        V42v.T401_timer_state = ON;
    }
}

/**************************************************************************/
/**************************************************************************/

/*
    Function to get the received frames, if available, and to process them
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void chk_and_proc_frm(V42CDBSTRUCT *V42CDSP)
{
    /* If frames available, get them and process */
    Chk_Frame_type(V42CDSP);
    Process_Frame(V42CDSP);
    /* If any response frames to be sent to DP, send them */
    chk_for_resp_frame_txmt(V42CDSP);
}

/**************************************************************************/
/**************************************************************************/

/*Sends Async data of size 70 ms for maximum bit rate to DP if there is
no flow control & sets the timer to 70 ms. On time out executes
ASYNC_TRANSMIT_TIMEOUT
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void SendAsyncDataToDP(V42CDBSTRUCT *V42CDSP,UCHAR *DATA,UINT LEN){
    UINT NoOfData = 0;

/*If the V42 falls back to ASYNC data mode the received data is
sent to DP uncoded.*/

    if(!V42Data.DpFlowControl){
        NoOfData = LEN;
        if(LEN > MAXV42MSGLEN){
            NoOfData = MAXV42MSGLEN;
            V42SetupTimer1(V42CDSP->ChnId,(ULONG)70);    //set timer for 100 mSec
            SetTimeOutEvent(ASYNC_TRANSMIT_TIMEOUT);
        }
        V42SendMessageToDP(V42CDSP->ChnId,mDATATODP,NoOfData,DATA);
    }
    V42v.DataLen = LEN - NoOfData;
    V42v.DataPtr = DATA + NoOfData;
    if(!V42v.DataLen)
        V42IndicateStatus(V42CDSP->ChnId,V42_READY_FOR_DATA,0,V42Data.PARM);
}

#endif

/******************************************************************************
 END OF FILE 
*******************************************************************************/
