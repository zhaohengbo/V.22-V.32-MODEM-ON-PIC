/******************************************************************************
 File Name:   V42N.C 
*******************************************************************************/

/***************************************************************************
*
* V42N.C (V.42 Negotiation) :
*
*       Contains functions for detection and negotiation of DATA MODEM
*       V42 protocol
*
*
****************************************************************************/

#include "api_c.h"
#include "v42.h"
#include "v42api.h"

#ifdef DEF_V42

void Chk_recvd_pattrn(V42CDBSTRUCT *V42CDSP,UCHAR *BufPtr, UCHAR ByteCnt);
void SndV42DectPat2dp(V42CDBSTRUCT *V42CDSP);
void Attempt_LAPM_conn(V42CDBSTRUCT *V42CDSP);
void chk_and_proc_frm(V42CDBSTRUCT *V42CDSP);
void chk_for_resp_frame_txmt(V42CDBSTRUCT *V42CDSP);
void Build_XID_frame(V42CDBSTRUCT *V42CDSP);

UCHAR odp_data_buf[2] = {0x91,0x11};
UCHAR adp_data_buf[2]  = {0x45,0x43};

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void setup_parms_for_v42neg(V42CDBSTRUCT *V42CDSP)
{
    V42Data.Trans_Wnd_size = TRANS_Window_size;
    V42Data.Recv_Wnd_size =   RECV_Window_size;

    /* Receive size can be less than default value */
    /* Based on user option of dictionary size */
    V42Data.TotalNumCodeWords = 512;

     /*Data compression status at Local & Remote end*/
    V42Data.Local_data_comp =  V42Data.Rem_data_comp = 0;

    V42Data.Trans_Info_field =  V42Data.Recv_Info_field =  128;

    /*32 bit poynomial enable*/
    V42Data.FCS32_ena =  0;

    V42v.received_cmprsn_mode = 0;

    /* receive status flag for XID frame*/
    V42v.received_XID_flag = 0;

    V42v.received_P1_parm_flag = 0;
    V42v.received_P2_parm_flag = 0;

    V42Data.current_cmprsn_mode = V42Data.cmprsn_mode = 0;    /*by default disable compression in either direction*/
    V42v.flags_detected = 0;
    V42v.Retrans_count = 0;
    V42v.detect_cnt = 0;
//    ones_patt   = 0;
//    patt_detect_flg = 0;
    V42v.Last_patt = 0;
    V42v.ADP_snt = 0;
    V42v.ODP_snt = 0;
    V42v.neg_phase_snd_frame = 0;
    V42v.dis_xid  = 0;
    //FCS = 0;

    /* timer_control_proc(RESET_TIMER_COUNT); */
    /*
    Based on carrier speed, get the ODP/ADP frame txmt time and no. of frames
    to be send to remote (in case of originating call) - currently for 5 secs.
    In case of ODP pattern, after sending one set (6 bytes), timeout for DSP to
    send the pattern to remote modem.
    */

    /*
    Note : Time for sending 10 frames
    No. of ODP in termes of 10 frames per set
    */
    V42v.neg_timer = 160;    //RRR neg_timer_val[con_speed - 1];
    V42v.Num_ODP_reqd = 10;    // RRR num_ODP_on_line[con_speed - 1];

    /*the negotiation tiner & the no. of ODP required are chosen
    for the lowest bit rate RRR*/
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void V42FallBack(V42CDBSTRUCT *V42CDSP) {
    /* send connect message to host in ASYNC mode*/
    V42Data.state = ASYNC_DATA_STATE;
    V42IndicateStatus(V42CDSP->ChnId,ASYNC_CONNECT,0,(UCHAR *)msgParams);

    msgId = mDATAMODESELECT;
    msgLen = 2;
    msgParams[0] = DATA_L2MSS;
    msgParams[1] = 1;            // Set Number of stop bits to 1

    V42SendMessageToDP(V42CDSP->ChnId,msgId,msgLen,msgParams);
}

/**************************************************************************/
/**************************************************************************/

/*
    Input : Pointer to buffer containing data
        Count of bytes in the buffer
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void detect_v42_proc(V42CDBSTRUCT *V42CDSP,UCHAR *BufPtr, UCHAR ByteCnt)
{
    /* Check if ODP/ADP data is received from remote modem. */
    Chk_recvd_pattrn(V42CDSP,BufPtr, ByteCnt);

    /*
    ANSWERER case, if 2 frames of ODP pattern is received
    from remote modem, send 10 frames of ADP pattern.
    */
    if(!V42v.DCE_role)
    {
        /* Got 2 frames of ODP ? */
        if(V42v.detect_cnt >= 2)
        {
            /* Yes, Sent 10 frames of ADP ? */
            if (!V42v.ADP_snt)
            {
                V42IndicateStatus(V42CDSP->ChnId,V42_ANS_ODP_DETECT,1,V42Data.PARM);
                /* No, send 10 frames of ADP */
                SndV42DectPat2dp(V42CDSP);
    // Timer is set for 100ms which is enough for even bit rate of 2400bps
    //But it has to be set to the time required to transmit 10 ADP frames
            }
            if((V42v.ADP_snt) && (V42v.flags_detected))
            {
                /* Sent 10 frames of ADP and waited for remote to receive that */
                V42Data.state = V42_NEGOTIATION_STATE;
                /* send command to DP to enter SYNC mode */
                msgId = mDATAMODESELECT;
                msgLen = 1;
                msgParams[0] = DATA_HDLC;
                V42SendMessageToDP(V42CDSP->ChnId,msgId,msgLen,msgParams);
                RESETDPBUFPTRS( );
                /* Ans case - Setup T401 timer to wait for XID */
                V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
                SetTimeOutEvent(ODP_ADP_DET_TIMER);
            }

        }
        return;
    }

    /*
    In case of originator mode, if 4 frames (ADP) are received
    enter LAPM negotiation phase. Either in Org or Ans modes,
    if 4 flags are detected, enter negotiation V42Data.state.
    */

    if ((V42v.DCE_role && (V42v.detect_cnt >= 2)) || (V42v.flags_detected >= 4))
    {
    /* Setup timer - for transmission 100ms of intial flags before
    transmiting the XID frame*/
        V42SetupTimer1(V42CDSP->ChnId,(ULNG)100);/* Changed by Srikanth */
        SetTimeOutEvent(XID_PREAMBLE_TIMER);
        V42IndicateStatus(V42CDSP->ChnId,V42_ORG_ADP_DETECT,1,V42Data.PARM);
        /*
            In case of ORIGINATE mode,before entering into the
            V42_NEGOTIATION_STATE, some delay is introduced, for DP to
            get ready to enter into SYNC(HDLC) mode by transmitting the
            buffered data(clearing the previous data left in the buffer).
            50MS delay
        */

        /* send command to DP to enter SYNC mode */

            msgId = mDATAMODESELECT;
            msgLen = 1;
            msgParams[0] = DATA_HDLC;
            V42SendMessageToDP(V42CDSP->ChnId,msgId,msgLen,msgParams);
            RESETDPBUFPTRS( );

            V42Data.state = V42_NEGOTIATION_STATE;
/*attempts LAP-M connection by transmiting XID frame in the begining*/
//            Attempt_LAPM_conn(V42CDSP);

        V42v.detect_cnt = 0;
    }

    /*
    If ORIGINATOR, send ODP pattern.
    As per spec, pattern to be sent for a minimum of 750 milli secs
    or until ADP is received. Sending ODP for 5 secs.
    */
}

/**************************************************************************/
/**************************************************************************/

/*
    During V42 Detection phase, this function checks for;
    In Originate mode : ADP pattern or Flags
    In Answer mode : ODP pattern or Flags
    Input : Pointer to buffer containing data
        Count of bytes in the buffer
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Chk_recvd_pattrn(V42CDBSTRUCT *V42CDSP,UCHAR *BufPtr, UCHAR ByteCnt)
{
    if(V42v.DCE_role){
        if (V42v.detect_cnt >= 4)
            return;

    }
    V42Data.cTmp3 = 0;

    while(ByteCnt)
    {
        V42v.Curr_patt = BufPtr[V42Data.cTmp3];
//        DebugSI("V42v.Curr_patt ",V42v.Curr_patt);
        V42Data.cTmp3++;
        ByteCnt--;

        if (V42v.DCE_role)   /* Originator mode */
        {
            /* Check for ADP pattern or flags (allowed if other end in &Q7 mode) */
            if (((V42v.Last_patt == 'E') && (V42v.Curr_patt == 'C')) ||
               ((V42v.Last_patt == 0x3F) && (V42v.Curr_patt == 0x7E)))
            {
                V42v.Last_patt = 0;
                V42v.detect_cnt ++;
                if(V42v.detect_cnt >= 4)
                    return;
            }
            else
                V42v.Last_patt = V42v.Curr_patt;
        }
        else  /* Answerer mode */
        {
            /* Check for ODP pattern */

            if((V42v.Last_patt == 0x11) && (V42v.Curr_patt == 0x91))
            {
                V42v.Last_patt = 0;
                V42v.detect_cnt ++;
                if(V42v.detect_cnt >= 2)
                    return;
            }
            /* If ODP not detected then check for flags (allowed if other end in &Q7 mode) */
            else if ((V42v.Last_patt == 0x3F) && (V42v.Curr_patt == 0x7E))
            {
                V42v.Last_patt = 0;
                V42v.flags_detected++;

                if(V42v.flags_detected >= 4)
                    return;
            }
            else
                V42v.Last_patt = V42v.Curr_patt;
        }
    }
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void SndV42DectPat2dp(V42CDBSTRUCT *V42CDSP)
{

 INT i,j,nbyt;

    if(V42Data.DpFlowControl == FALSE)
    {
        if(V42v.DCE_role)
        {
        /* If originator send 85 frames of ODP(100ms time data) pattern */
            nbyt = 0;
            for (i = 0; i < 8; i++)
                for (j = 0 ; j < 2; j++)
                    V42Data.DP_buffer[nbyt++] = odp_data_buf[j];
            V42v.ODP_snt++;
        }
        else
        {
            /* Send 10 frames of ADP pattern */
            nbyt = 0;
            for (i = 0; i < 10; i++)
                for (j = 0 ; j < 2; j++)
                    V42Data.DP_buffer[nbyt++] = adp_data_buf[j];
            V42v.ADP_snt++;
        }
        // Send more data than required for 33.6 kbps
        V42SendMessageToDP(V42CDSP->ChnId,mDATATODP,nbyt,V42Data.DP_buffer);

        /* V42Data.state = ODP_ADP_DELAY_STATE; */
//        OdpAdpDelayFlag = TRUE;
    }
}

/**************************************************************************/
/**************************************************************************/

/*
    Attempt_LAPM_conn :
    V42 negotiation process :
    ORIGINATE MODE :
        Send (resend on T401 timeout) XID frame until XID frame is received or
        retransmit count exceeds limit.
        On receipt of XID, send (resend on T401 timeout) SABME frame until UA
        frame is received or retransmit count exceeds limit.
        If UA frame is not received after sending SABME for 5 times (retrans
        limit), indicate failure of V42 negotiation, else enter data transfer
        phase.
    ANSWER MODE :
        Wait for XID frame until timeout occurs, if no XID within this period,
        failure of V42 negotitaion.
        On receipt of XID frame, reset retransmit count and send XID frame.
        Wait for SABME frame until timeout occurs, if no XID within this period,
        failure of V42 negotitaion.
        On receipt of SABME frame, reset retransmit count and send UA frame.

        Note : In negotiation phase, T401 timer timeout period is about
               2 secs and is same for all carrier speeds.
*/

__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Attempt_LAPM_conn(V42CDBSTRUCT *V42CDSP)
{

    /* DP ready to accept frame ? - Org case only we send frames here */

    if ((V42v.DCE_role) && (V42Data.DpFlowControl == TRUE))
        return;

    /* check the mode of operation - Originate or Answer */
    if (V42v.DCE_role)
    {
        /* Originate Mode - 1st time send XID frame */
        if ((V42v.dis_xid == 0) && (V42v.Retrans_count == 0))
        {
            V42v.Pbit = 0x00;        /* 0x01 earlier */
            V42v.C_R = 0x02;
            V42v.neg_phase_snd_frame = XID;
            V42v.snd_frametype = XID;
            Build_XID_frame(V42CDSP);

            /* Start timer */
            V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
            SetTimeOutEvent(N400_RETX_TIMER);
            V42v.Retrans_count = 1;
            V42v.dis_xid = 1;
        }
    }
}

#endif

/******************************************************************************
 END OF FILE 
*******************************************************************************/
