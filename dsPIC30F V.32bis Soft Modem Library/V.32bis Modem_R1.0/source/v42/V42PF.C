/******************************************************************************
 File Name:   V42PF.C 
*******************************************************************************/

#include "api_c.h"
#include "v42.h"
#include "v42api.h"

#ifdef DEF_V42

extern INT V42_encoder_main_proc(V42CDBSTRUCT * , UCHAR *, UINT);
extern void V42_decoder_main_proc(V42CDBSTRUCT *);

/***************************************************************************
*
* V42PF.C (V42 Process Frame)  :
*
*       Contains functions for checking & processing V.42 frames.
*
*
****************************************************************************/

void Process_Info_frame(V42CDBSTRUCT *V42CDSP);
void Process_SABME_frame(V42CDBSTRUCT *V42CDSP);
void Process_UA_frame(V42CDBSTRUCT *V42CDSP);
void Process_DISC_frame(V42CDBSTRUCT *V42CDSP);
void Process_RR_frame(V42CDBSTRUCT *V42CDSP);
void Process_RNR_frame(V42CDBSTRUCT *V42CDSP);
void Process_DM_frame(V42CDBSTRUCT *V42CDSP);
void Process_REJ_frame(V42CDBSTRUCT *V42CDSP);
void snd_RESP_frame(V42CDBSTRUCT *V42CDSP);
void Process_SREJ_frame(V42CDBSTRUCT *V42CDSP);
void Process_FRMR_frame(V42CDBSTRUCT *V42CDSP);
void Process_XID_frame(V42CDBSTRUCT *V42CDSP);
void Prs_V42bis_Data_Comp_Req(V42CDBSTRUCT *V42CDSP);
void Process_TEST_frame(V42CDBSTRUCT *V42CDSP);
void Process_UI_frame(V42CDBSTRUCT *V42CDSP);
void Check_Valid_Frame(V42CDBSTRUCT *V42CDSP);
void Copy_IFrame(V42CDBSTRUCT *V42CDSP);
void Chk_Response_Rqd(V42CDBSTRUCT *V42CDSP);
void snd_respframe_Fbit0(V42CDBSTRUCT *V42CDSP);
void init_on_v42_establishment(V42CDBSTRUCT *V42CDSP);
void snd_RESP_frame(V42CDBSTRUCT *V42CDSP);
void snd_cmdframe_Pbit1(V42CDBSTRUCT *V42CDSP);
void send_2lineout_buf(V42CDBSTRUCT *V42CDSP,UINT);
void chk_for_resp_frame_txmt(V42CDBSTRUCT *V42CDSP);
void CheckForBreakTx(V42CDBSTRUCT *V42CDSP);
void SendFrameEndCmd(void);
extern UCHAR TestSequence[];
void ProcessValidInfoFrame(V42CDBSTRUCT *CDSP);
void SendREJFrame(V42CDBSTRUCT *V42CDSP);

/*****************************************************************************/
/*****************************************************************************/

/*
    Function to process the received frame
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_Frame(V42CDBSTRUCT *V42CDSP)
{
    /* If not in re-establishment phase, process all frames */
    if (!V42v.re_establish_v42)
    {
        switch(V42v.rcv_frametype)
        {
            case INFO:
                if(V42v.BREAK_DISCARD)break;
                Process_Info_frame(V42CDSP);
                break;

            case RR:
                Process_RR_frame(V42CDSP);
                break;

            case RNR:
                Process_RNR_frame(V42CDSP);
                break;

            case SABME:

#ifdef DEF_DEBUG
                V42Data.PARM[0] = ANS_RECV_SABME;
                V42IndicateStatus(V42CDSP->ChnId,V42_NEGOTIATION_STATUS,1,V42Data.PARM);
#endif

                Process_SABME_frame(V42CDSP);
                break;

            case REJ:
                Process_REJ_frame(V42CDSP);
                break;

            case DM:
            case DM_SEC:
                Process_DM_frame(V42CDSP);
                break;

            case SREJ:
                Process_SREJ_frame(V42CDSP);
                break;

            case DISC:
                Process_DISC_frame(V42CDSP);
                break;

            case FRMR:
                Process_FRMR_frame(V42CDSP);
                break;

            case FRMR_SEC:
                Process_FRMR_frame(V42CDSP);
                break;

            case XID :

#ifdef DEF_DEBUG
                if(V42CDSP->ChnId)
                    V42Data.PARM[0] = ANS_RECV_XID;
                else
                    V42Data.PARM[0] = ORG_RECV_XID;

                V42IndicateStatus(V42CDSP->ChnId,V42_NEGOTIATION_STATUS,1,V42Data.PARM);

#endif

                V42ReleaseTimer1(V42CDSP->ChnId);
                Process_XID_frame(V42CDSP);
                break;

            case UA :

#ifdef DEF_DEBUG
                V42Data.PARM[0] = ORG_RECV_UA;
                V42IndicateStatus(V42CDSP->ChnId,V42_NEGOTIATION_STATUS,1,V42Data.PARM);
#endif

                Process_UA_frame(V42CDSP);
                break;

            case TEST:
                Process_TEST_frame(V42CDSP);
                break;
            case UI:
                Process_UI_frame(V42CDSP);
                break;
            default :
                break;
        }
    }
    /* In re-establishment phase, process following frames */
    else
    {
        switch(V42v.rcv_frametype)
        {
            case SABME:
                Process_SABME_frame(V42CDSP);
                break;

            case DM:

            case DM_SEC:
                Process_DM_frame(V42CDSP);
                break;

            case DISC:
                Process_DISC_frame(V42CDSP);
                break;

            case UA :

#ifdef DEF_DEBUG
                V42Data.PARM[0] = ORG_RECV_UA;
                V42IndicateStatus(V42CDSP->ChnId,V42_NEGOTIATION_STATUS,1,V42Data.PARM);
#endif

                Process_UA_frame(V42CDSP);
                break;
            default :
                break;
        }
    }
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_Info_frame(V42CDBSTRUCT *V42CDSP)
{
    /*
    This function receives and process
    the I-frames that is received and sends the appropriate response
    if neccessary.
    Valid frames data is copied into the window buffer and window count
    is updated. If windows are full, RNR frame is sent and flag is set
    indicating local receiver not ready.
    */

    Check_Valid_Frame(V42CDSP);

    if(V42v.Invalid_Frame)
        return;


    /*if the difference in receive state variable & Send Seq no is
     less than the window size then transmit SREJ other wise transmit REJ
     * /

    if(V42v.Ns>V42v.Vr){
        /* V.42 connection capable of Sreject* /
        if(V42Data.SReject&&((V42v.Ns- V42v.Vr)<V42Data.Recv_Wnd_size)){

            /*send S-reject request with Nr = Ns
                update Va with Ns
                set the S-reject condition
                set the timer to request the
                set P bit to zero* /

            V42v.SrejCondition++;
            ProcessValidInfoFrame(V42CDSP);
        }
        else
        {
            SendREJFrame(V42CDSP);
        }
    }*/

    /* check if the frame is the one with expected sequence number */
    if(V42v.Ns == V42v.Vr)
    {
        ProcessValidInfoFrame(V42CDSP);
    }
    else
    {
        SendREJFrame(V42CDSP);
    }
    V42_decoder_main_proc(V42CDSP);
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_SABME_frame(V42CDBSTRUCT *V42CDSP)
{
    /*
    This frame is received by the Answerer during the Error - control
    connection establishment phase. The DCE receiving this frames
    sends an L-Establish indication to the Control function. Then
    send a UA frame to acknowledge the connection.
    */

    /* check if address field is valid */

    if((V42v.rcv_frm[0] != 3) && (V42v.rcv_frm[0] != 1))
        return;

    V42v.rem_recv_window = OPEN;
    init_on_v42_establishment(V42CDSP);
    V42v.neg_phase_snd_frame = UA;
    V42v.response_frame = UA;
    snd_RESP_frame(V42CDSP);
    V42ReleaseTimer1(V42CDSP->ChnId);
    if(V42Data.state != SYNC_DATA_STATE)
    {
        V42Data.state = SYNC_DATA_STATE;
        V42Data.ECM_enabled = 1;
    }
    if(!V42v.Ec_connect){
        /*compression status given as part of connect status*/
        V42IndicateStatus(V42CDSP->ChnId,V42_CONNECT,0,V42Data.PARM);
        V42v.Ec_connect = 1;
    }
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_UA_frame(V42CDBSTRUCT *V42CDSP)
{
    /* check if address field is valid */

    if((V42v.rcv_frm[0] != 3) && (V42v.rcv_frm[0] != 1))
        return;

    /* 8.5.7 - case of unsolicited UA response frame */

    if ((V42Data.state == SYNC_DATA_STATE) && (!V42v.re_establish_v42))
        return;

    /* If the UA is response to our DISC frame, enter disconnect V42Data.state */
    if (V42Data.state == DISCONNECTING_STATE)//V42v.snd_frametype == DISC)
    {
        /* V42Data.state = DISCONNECTING_STATE3; */
        /* Event based control, initiate disconnection process */
        V42Data.SessionOk = 1;
        perform_modem_hangup(V42CDSP);
    } else{

    /* If not in connected V42Data.state, enter connected V42Data.state */
    if(V42Data.state != SYNC_DATA_STATE)
    {
        V42Data.state = SYNC_DATA_STATE;
        V42Data.ECM_enabled = 1;
    }

    V42v.re_establish_v42 = 0;
    init_on_v42_establishment(V42CDSP);
    if(!V42v.Ec_connect){
        //V42Data.PARM[0] = V42Data.Local_data_comp; /*TX_COMPRESSION*/
        //V42Data.PARM[1] = V42Data.Rem_data_comp;   /*RX_COMPRESSION*/

        V42IndicateStatus(V42CDSP->ChnId,V42_CONNECT,0,V42Data.PARM);
        V42v.Ec_connect = 1;
    }
        /*release the timer set for re-establishment after SABME transmit*/

    V42ReleaseTimer1(V42CDSP->ChnId);
    }
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_DISC_frame(V42CDBSTRUCT *V42CDSP)
{
    /*
    This frame is received during disconnection, send a DM or a UA
    as a response.
    */
    /* check if address field is valid */

    if((V42v.rcv_frm[0] != 3) && (V42v.rcv_frm[0] != 1))
        return;

    if (V42v.DCE_role)
        V42v.C_R = 0x00;
    else
        V42v.C_R = 0x02;

    /* 8.8 - send UA or DM Response with Fbit set to the value of received V42v.Pbit */

    if (V42Data.state == DISCONNECTING_STATE1)
        V42v.response_frame = DM;
    else
        V42v.response_frame = UA;

    snd_RESP_frame(V42CDSP);
    /* Event based ctrl, initiate frame transfer */
    chk_for_resp_frame_txmt(V42CDSP);

    V42Data.state = DISCONNECTING_STATE2;

    /* if required Setup timeout (200ms) - to exit in case DSP
    could not send out UA */

    /*Send UA frame & intiate disconnection*/
    V42Data.SessionOk = 2;
    perform_modem_hangup(V42CDSP);
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_RR_frame(V42CDBSTRUCT *V42CDSP)
{

    /* This frame is recieved if remote DCE is ready to accept data */
    if(V42v.frmlen != 3)
        return;

    Check_Valid_Frame(V42CDSP);

    if(V42v.Invalid_Frame)
        return;

    Chk_Response_Rqd(V42CDSP);

    if(V42v.build_response)
        snd_RESP_frame(V42CDSP);

    V42v.rem_recv_window = OPEN;

    /* 8.4.8 and 8.4.6 */
    if ((V42v.Timer_recvy == SET) /*&& V42v.received_resp_frm*/ && V42v.Pbit)
    {
        //RAMU
        /*
    Note :  Since V42v.Vs is set to V42v.Nr, unacked Iframes will be automatically
        retransmitted and a loss of REJ/SREJ due to line errors will
        not lead to a block condition.
        */

        V42v.Timer_recvy = RESET;
        V42v.T401_timer_state = OFF;
        V42ReleaseTimer1(V42CDSP->ChnId);
        V42v.Pbit_unAcked = 0;
        V42v.Va = V42v.Vs = V42v.Nr;
        CheckForBreakTx(V42CDSP);
        return;
    }

    /* 8.4.3.2 and Note 1 */
    if (V42v.Pbit_unAcked)
    {
        if (V42v.received_resp_frm && V42v.Pbit)
        {
            V42v.Pbit_unAcked = 0;
            if (V42v.Nr != V42v.Va)
            {
                V42ReleaseTimer1(V42CDSP->ChnId);
                V42v.T401_timer_state = OFF;
            }
        }
    }
    else if (V42v.Nr != V42v.Va)
    {
        V42ReleaseTimer1(V42CDSP->ChnId);
        V42v.T401_timer_state = OFF;
    }
    /* 8.4.3.2 para 1 */
    V42v.Va = V42v.Nr;
    CheckForBreakTx(V42CDSP);

    /*  8.4.3.2 - Para 4 */
    if ((V42v.T401_timer_state == OFF) && (V42v.Vs != V42v.Va))
    {
        /* Setup T401 timeout timer */
        V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
        SetTimeOutEvent(SYNCMODE_T401TIMER);
        V42v.T401_timer_state = ON;
    }

    /* encode the pending data */
    V42v.DataLen = V42_encoder_main_proc(V42CDSP,V42v.DataPtr,V42v.DataLen);
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_RNR_frame(V42CDBSTRUCT *V42CDSP)
{
    /* This frame is recieved if remote DCE is not ready to accept data */
    if(V42v.frmlen != 3)
        return;

    Check_Valid_Frame(V42CDSP);

    if (V42v.Invalid_Frame)
        return;

    Chk_Response_Rqd(V42CDSP);

    if(V42v.build_response)
        snd_RESP_frame(V42CDSP);

    V42v.rem_recv_window = CLOSED;

    /* 8.4.8 and 8.4.6 */

    if ((V42v.Timer_recvy == SET) && V42v.received_resp_frm && V42v.Pbit)
    {
        /*
        Since remote DCE is not ready, we have to send RR/RNR command
        frames, to know the link status, after every T401 timeout.
        But under this condition, i.e if we are receiving responses
        to our query, we should clear timer recovery.
        */

        V42v.Timer_recvy = RESET;
        V42v.Va = V42v.Vs = V42v.Nr;
        V42v.Pbit_unAcked = 0;
        return;
    }
    /* 8.4.3.2 and Note 1 */
    else if (V42v.Pbit_unAcked)
    {
        if (V42v.received_resp_frm && V42v.Pbit)
        {
            V42v.Pbit_unAcked = 0;
            if (V42v.Nr != V42v.Va)
            {
                V42ReleaseTimer1(V42CDSP->ChnId);
                V42v.T401_timer_state = OFF;
            }
        }
    }
    else if (V42v.Nr != V42v.Va)
    {
        V42ReleaseTimer1(V42CDSP->ChnId);
        V42v.T401_timer_state = OFF;
    }

    /* 8.4.3.2 para 1 */
    V42v.Va = V42v.Nr;

    /*  8.4.3.2 - Para 4 */
    if ((V42v.T401_timer_state == OFF) && (V42v.Vs != V42v.Va))
    {
        /* Setup T401 timeout timer */
        V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
        SetTimeOutEvent(SYNCMODE_T401TIMER);
        V42v.T401_timer_state = ON;
    }
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_DM_frame(V42CDBSTRUCT *V42CDSP)
{
    /* check if address field is valid */
    if((V42v.rcv_frm[0] != 3) && (V42v.rcv_frm[0] != 1))
        return;

    /* 8.4.9 - cases for re-establishment */

    if (((V42Data.state == SYNC_DATA_STATE) && (!V42v.Pbit)) ||

        ((V42v.Timer_recvy == SET) && V42v.Pbit))

    {
    /*
        8.5.7 - in connected V42Data.state, unsolicited DM response with Fbit 0.
        Re-establish connection
    */
        V42v.Retrans_count = 0;
        V42v.snd_frametype = SABME;
        snd_cmdframe_Pbit1(V42CDSP);
        /* Setup T401 timeout timer */
        V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
        SetTimeOutEvent(SYNCMODE_N400_RETX);
        V42Data.ErrorCode = RE_EST_DM_FBIT0;
        V42v.re_establish_v42 = 1;
    }

    /* If not in connected V42Data.state(V42?), enter disconnected V42Data.state. Else ignore */

    else if(V42v.Pbit && (V42Data.state != SYNC_DATA_STATE))
    {
        /* V42Data.state = DISCONNECTING_STATE3; */
        /* Event based control, initiate disconnection process */
        V42Data.ErrorCode = DM_RESP_WITH_FBIT1;
        V42Data.SessionOk = 5;
        perform_modem_hangup(V42CDSP);
    }
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_REJ_frame(V42CDBSTRUCT *V42CDSP)
{
    /*
    This indicates that the I-Frames previously sent has been rejected
    due to some  condition. Subsequent I-frames are retransmitted.
    This also indicates that remote DCE is ready to accept data.
    */

    if(V42v.frmlen != 3)
        return;

    Check_Valid_Frame(V42CDSP);

    if(V42v.Invalid_Frame)
        return;

    Chk_Response_Rqd(V42CDSP);

    if(V42v.build_response)
        snd_RESP_frame(V42CDSP);

    V42v.rem_recv_window = OPEN;
    /* 8.4.4 2) */
    if ((V42v.snd_frametype == SABME) || (V42v.snd_frametype == UA))
        return;

    /* 8.4.3.2 para 1 */
    V42v.Va = V42v.Nr;
    /* 8.4.8 and 8.4.4 */

    if (V42v.Timer_recvy == SET)
    {
        if(V42v.received_resp_frm && V42v.Pbit)  /* 8.4.4 b */
        {
            V42v.Timer_recvy = RESET;
            V42v.T401_timer_state = OFF;
            V42ReleaseTimer1(V42CDSP->ChnId);
            V42v.Pbit_unAcked = 0;
            V42v.Vs = V42v.Nr;
        }
        /* Note 8.4.4 c  - No further action */
        /*
        As per 8.4.3.2 Note 1 - in timer recovery condition, if RR/RNR
        frame with V42v.Pbit set to 1 not yet acknowledged, T401 should not
        be stopped.
        */
    }

    else  /* 8.4.4 a  */
    {
        if (V42v.received_resp_frm && V42v.Pbit)
        {
            /*
            not in timer recovery and the received frame is REJ response
            frame with F bit set to 1, protocol violation.
            */

            V42v.Retrans_count = 0;
            V42v.snd_frametype = SABME;
            snd_cmdframe_Pbit1(V42CDSP);

            /* Setup T401 timeout timer */
            V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
            SetTimeOutEvent(SYNCMODE_N400_RETX);
            V42v.re_establish_v42 = 1;
            V42Data.ErrorCode = REJ_RESP_FBIT1;
            return;
        }
        V42v.Vs = V42v.Nr;
        V42v.T401_timer_state = OFF;
        V42ReleaseTimer1(V42CDSP->ChnId);
    }
}

/*****************************************************************************/
/*****************************************************************************/

/*
snd_RESP_frame():

    Function to setup parameters for response frame and to save
    the details into the array for building the frame later on
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void snd_RESP_frame(V42CDBSTRUCT *V42CDSP)
{
    /* Save the frame details into the array */

    V42v.frame_details_array[V42v.fd_wrindx].Pbit_value = V42v.Pbit;
    V42v.frame_details_array[V42v.fd_wrindx].CR_value = V42v.C_R;
    V42v.frame_details_array[V42v.fd_wrindx].type_of_frame = V42v.response_frame;

    /* Update the array index - circular buffer mode */
    if (V42v.fd_wrindx == MAX_FD_ARRAY_SIZE)
        V42v.fd_wrindx = 0;
    else
        V42v.fd_wrindx++;
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_SREJ_frame(V42CDBSTRUCT *V42CDSP)
{
    /*
    This indicates that one I-Frame previously sent has been rejected
    due to some particular condition. As a response that particular
    frame is retransmitted.
    */

    if(V42v.frmlen != 3)
        return;

    Check_Valid_Frame(V42CDSP);

    if(V42v.Invalid_Frame)
        return;

    /* 8.4.5  2) */
    if ((V42v.snd_frametype == SABME) || (V42v.snd_frametype == UA))
        return;

    /* not negotiated for selective reject option but received a SREJ frame ? */

    if(!V42Data.Sreject)
    {
        /* Save the frame details into the array */
        V42v.frame_details_array[V42v.fd_wrindx].Pbit_value = V42v.Pbit;
        V42v.frame_details_array[V42v.fd_wrindx].CR_value = V42v.C_R;
        V42v.frame_details_array[V42v.fd_wrindx].frmr_field0 = V42v.rcv_frm[1];
        V42v.frame_details_array[V42v.fd_wrindx].frmr_field1 = V42v.rcv_frm[2];
        V42v.frame_details_array[V42v.fd_wrindx].frmr_field2 = PARAM_NOT_SUPP;
        V42v.frame_details_array[V42v.fd_wrindx].type_of_frame = FRMR;
        /* Update the array index - circular buffer mode */
        if (V42v.fd_wrindx == MAX_FD_ARRAY_SIZE)
            V42v.fd_wrindx = 0;
        else
            V42v.fd_wrindx++;
        return;
    }
    /* 8.4.3.2 */
    /* (V42v.Nr != V42v.Va)  ||  (V42v.Nr == V42v.Va) */
    V42v.T401_timer_state = OFF;
    V42ReleaseTimer1(V42CDSP->ChnId);
    /*
    Save the frame details into the array. V42v.Pbit and command/response bit
    values are setup at the time of building Iframe, no need to setup here.
    */

    V42v.frame_details_array[V42v.fd_wrindx].Iframe_Vs = V42v.Nr;

    V42v.frame_details_array[V42v.fd_wrindx].type_of_frame = INFO;
    /* Update the array index - circular buffer mode */
    if (V42v.fd_wrindx == MAX_FD_ARRAY_SIZE)
        V42v.fd_wrindx = 0;
    else
        V42v.fd_wrindx++;
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_FRMR_frame(V42CDBSTRUCT *V42CDSP)
{
    /*
    This frames indicates that some condition has arised due to which
    transmission is impossible. It should result in RE-Connection.
    */
    /* check if address field is valid */

    if((V42v.rcv_frm[0] != 3) && (V42v.rcv_frm[0] != 1))
        return;
    V42v.Retrans_count = 0;
    V42v.snd_frametype = SABME;
    snd_cmdframe_Pbit1(V42CDSP);

    /* Setup T401 timeout timer */
    V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
    SetTimeOutEvent(SYNCMODE_N400_RETX);
    V42v.re_establish_v42 = 1;
    V42Data.ErrorCode = FRMR_RECD;
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_XID_frame(V42CDBSTRUCT *V42CDSP)
{
    /*
    This routine processes the received XID frame which carries information
    of all the parameters that can be negotiated. If this frame is not
    exchanged , then the default parameters are accepted.
    Modified to process parameters based on GI and PI's and validation of parameters.
    */

    /* check if address field is valid */

    if((V42v.rcv_frm[0] != 3) && (V42v.rcv_frm[0] != 1))
            return;

    V42v.tmpval = 3;   /* Skip Address/control (already validated) and format ID fileds */
    V42v.received_cmprsn_mode = 0;
    V42v.received_XID_flag = 1;

    while (1)
    {
        /* If all bytes of the frame are processed, break */
        if (V42v.tmpval >= V42v.frmlen)
            break;

        V42v.Group_Identifier = V42v.rcv_frm[V42v.tmpval++];

        if ((V42v.Group_Identifier != XID_V42_GID) && (V42v.Group_Identifier != XID_V42BIS_GID))
            break;


        V42v.Group_len = V42v.rcv_frm[V42v.tmpval++];
        V42v.Group_len <<= 8;
        V42v.Group_len |= V42v.rcv_frm[V42v.tmpval++];

        switch (V42v.Group_Identifier)
        {

            case  XID_V42_GID :
                while (V42v.Group_len > 0)
                {
                    V42v.Parameter_ID = V42v.rcv_frm[V42v.tmpval++];
                    V42v.Parameter_len = V42v.rcv_frm[V42v.tmpval++];
                    V42v.Group_len -= 2;

                    switch (V42v.Parameter_ID)
                    {
                        case XID_HDLC_OPT_FUN_PID :
                            if (V42v.Parameter_len == 3)
                            {
                                if(V42v.rcv_frm[V42v.tmpval++] & 0x04)
                                    V42Data.Sreject = 0x01;
                                else
                                    V42Data.Sreject = 0x00;
                                /*
                                Note : With ZOOM V34 MODEM, if SREJ is opted,
                                then even REJ is treated as SREJ ????
                                So disable sreject
                                */

                                V42Data.Sreject = 0x00;
                                if(V42v.rcv_frm[V42v.tmpval++] & 0x20)
                                {    V42Data.LOOP_TEST &= SET;
                                }else{
                                    V42Data.LOOP_TEST = RESET;
                                }

                                /* Not supported */
                                //V42v.LOOP_TEST = RESET;
                                if(V42v.rcv_frm[V42v.tmpval++] & 0x01)
                                    V42Data.FCS32_ena = SET;
                                else
                                    V42Data.FCS32_ena = RESET;

                            /* Not supported */

                                V42Data.FCS32_ena = RESET;
                            }
                            else
                                V42v.tmpval += V42v.Parameter_len;

                            V42v.Group_len -= V42v.Parameter_len;
                            break;

                        case XID_MAX_TX_IFIELD_LEN_PID :
                        case XID_MAX_RX_IFIELD_LEN_PID :

                            /* Size is same for TX and RX frame Info lengths */
                            V42v.Group_len -= V42v.Parameter_len;
                            if (V42v.Parameter_len)
                            {
                                V42v.kmod = V42v.rcv_frm[V42v.tmpval++];

                                while (--V42v.Parameter_len)
                                {
                                    V42v.kmod <<= 8;
                                    V42v.kmod |= V42v.rcv_frm[V42v.tmpval++];
                                }

                                V42v.kmod = V42v.kmod /8;
                                if (V42v.kmod < V42Data.Trans_Info_field)
                                    V42Data.Trans_Info_field = V42v.kmod;
                                    V42Data.Recv_Info_field = V42Data.Trans_Info_field;
                            }
                            break;

                        case XID_TX_WINDOW_SIZE_PID  :

                            if (V42v.Parameter_len == 1)
                            {
                                V42v.kmod = V42v.rcv_frm[V42v.tmpval++];
                                if ((V42v.kmod != 0) && (V42v.kmod < V42Data.Recv_Wnd_size))
                                    V42Data.Recv_Wnd_size = V42v.kmod;
                            }
                            else
                                V42v.tmpval += V42v.Parameter_len;

                            V42v.Group_len -= V42v.Parameter_len;
                            break;

                        case XID_RX_WINDOW_SIZE_PID  :
                            if (V42v.Parameter_len == 1)
                            {
                                V42v.kmod = V42v.rcv_frm[V42v.tmpval++];
                                if ((V42v.kmod != 0) && (V42v.kmod < V42Data.Trans_Wnd_size))
                                    V42Data.Trans_Wnd_size = V42v.kmod;
                            }
                            else
                                V42v.tmpval += V42v.Parameter_len;

                            V42v.Group_len -= V42v.Parameter_len;
                            break;

                        default  :
                            /* Undefined Parameter ID */
                            V42v.tmpval += V42v.Group_len;
                            V42v.Group_len = 0;
                            break;
                    }
                }
                break;

            case  XID_V42BIS_GID :

                while (V42v.Group_len > 0)
                {
                    V42v.Parameter_ID = V42v.rcv_frm[V42v.tmpval++];
                    V42v.Parameter_len = V42v.rcv_frm[V42v.tmpval++];
                    V42v.Group_len -= 2;

                    switch (V42v.Parameter_ID)
                    {
                        case XID_V42BIS_PARM_SET_PID :

                            if (V42v.Parameter_len == 3)
                            {
                                if((V42v.rcv_frm[V42v.tmpval++] == 0x56) &&
                                   (V42v.rcv_frm[V42v.tmpval++] == 0x34) &&
                                   (V42v.rcv_frm[V42v.tmpval++] == 0x32))
                                    V42v.P0 = SET;
                                else
                                    V42v.P0 = RESET;
                            }
                            else
                            {
                                V42v.P0 = RESET;
                                V42v.tmpval += V42v.Parameter_len;
                            }

                            V42v.Group_len -= V42v.Parameter_len;
                            break;

                        case XID_V42BIS_DATA_COMP_PID :

                            V42v.Group_len -= V42v.Parameter_len;

                            if (V42v.Parameter_len == 1)
                                V42v.received_cmprsn_mode = V42v.rcv_frm[V42v.tmpval++];
                            else
                                V42v.tmpval += V42v.Parameter_len;

                            break;

                        case XID_V42BIS_NUM_CODEWORDS_PID :
                            V42v.received_P1_parm_flag = 1;
                            V42v.Group_len -= V42v.Parameter_len;
                            if (V42v.Parameter_len == 2)
                            {
                                V42v.kmod = V42v.rcv_frm[V42v.tmpval++];
                                V42v.kmod <<= 8;
                                V42v.kmod |= V42v.rcv_frm[V42v.tmpval++];
                                if(V42v.kmod < V42Data.TotalNumCodeWords)
                                    V42Data.TotalNumCodeWords = V42v.kmod;
                                if(V42v.kmod < 512)
                                    V42Data.TotalNumCodeWords = 512;
                            }
                            else
                                V42v.tmpval += V42v.Parameter_len;
                            break;

                        case XID_V42BIS_MAX_STRLEN_PID :
                            V42v.received_P2_parm_flag = 1;
                            V42v.Group_len -= V42v.Parameter_len;
                            if (V42v.Parameter_len == 1)
                            {
                                V42v.kmod = V42v.rcv_frm[V42v.tmpval++];
                                if(V42v.kmod < V42Data.MaxStrLen)
                                    V42Data.MaxStrLen = V42v.kmod;

                                if(V42v.kmod < 6)
                                    V42Data.MaxStrLen = 6;
                            }
                            else
                                V42v.tmpval += V42v.Parameter_len;
                            break;

                        default  :
                            /* Undefined Parameter ID */
                            V42v.tmpval += V42v.Group_len;
                            V42v.Group_len = 0;
                            break;
                    }
                }
                break;
        }
    }

    /* User data subfield  not used */

    /*
    if(V42v.rcv_frm[V42v.tmpval++] == 0xFF)
    {
        V42v.tmpval++;
        V42v.tmpval++;
        V42v.kmod = V42v.rcv_frm[V42v.tmpval++] & 0x7F;
    }
    */
    Prs_V42bis_Data_Comp_Req(V42CDSP);
    /*
    If in Answer mode, send XID frame as response and reset T401 timer.
    Increment retransmit count indicating the no. of XID frames sent as
    response to received XID frames.
    */

    if((!V42v.DCE_role) || (V42Data.state == SYNC_DATA_STATE))
    {
        V42v.Retrans_count++;
        V42v.snd_frametype = XID;
        snd_respframe_Fbit0(V42CDSP);
        /* Setup T401 timeout timer */

        V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
    }

    /*
    In Originate mode and not yet connected, send SABME cmd frame in response
    to the received XID frame. Reset T401 timer. Set retransmit count to
    1 indicating the 1st time transmission of SABME frame.
    */

    else /* if(V42Data.state != SYNC_DATA_STATE) */
    {
        V42v.neg_phase_snd_frame = SABME;
        V42v.Retrans_count = 1;
        V42v.snd_frametype = SABME;
        snd_cmdframe_Pbit1(V42CDSP);

        /* Setup T401 timeout timer */
        V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
        SetTimeOutEvent(N400_RETX_TIMER);
    }

    return;
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Prs_V42bis_Data_Comp_Req(V42CDBSTRUCT *V42CDSP)
{
    /*
    This routine determines the Data compression request and the direction
    in which the request is indicated.
    */

    /* Validate the received compression mode with respect to "AT%C" setting */

    switch(V42v.received_cmprsn_mode)
    {
        case 0 :
                V42Data.current_cmprsn_mode = 0;
                break;

        case 1 :
                if ((V42Data.cmprsn_mode == 1) || (V42Data.cmprsn_mode == 3))
                    V42Data.current_cmprsn_mode = 1;
                else
                    V42Data.current_cmprsn_mode = 0;
                break;

        case 2 :
                if ((V42Data.cmprsn_mode == 2) || (V42Data.cmprsn_mode == 3))
                    V42Data.current_cmprsn_mode = 2;
                else
                    V42Data.current_cmprsn_mode = 0;
                break;

        case 3 :
                V42Data.current_cmprsn_mode = V42Data.cmprsn_mode;
                break;
        default:
                V42Data.current_cmprsn_mode = 0;
                break;
    }

    switch(V42Data.current_cmprsn_mode)
    {
        case 0  :
                V42Data.Rem_data_comp = 0;
                V42Data.Local_data_comp = 0;
                break;
        case 1  :
                if(V42v.DCE_role)
                {
                    V42Data.Local_data_comp = 1;
                    V42Data.Rem_data_comp = 0;
                }
                else
                {
                    V42Data.Local_data_comp = 0;
                    V42Data.Rem_data_comp = 1;
                }
                break;
        case 2  :
                if(V42v.DCE_role)
                {
                    V42Data.Rem_data_comp = 1;
                    V42Data.Local_data_comp = 0;
                }
                else
                {
                    V42Data.Rem_data_comp = 0;
                    V42Data.Local_data_comp = 1;
                }
                break;

        case 3  :

                V42Data.Rem_data_comp = 1;
                V42Data.Local_data_comp = 1;
                break;
    }
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Check_Valid_Frame(V42CDBSTRUCT *V42CDSP)
{
    V42v.Invalid_Frame = 0;
    /* check if address field is valid */
    if((V42v.rcv_frm[0] != 3) && (V42v.rcv_frm[0] != 1))
    {
        V42v.Invalid_Frame = 1;
        return;
    }

    if (V42v.Va <= V42v.Vs)
    {
        if ((V42v.Va <= V42v.Nr) && (V42v.Nr <= V42v.Vs))
            return;
    }
    else  /* V42v.Va > V42v.Vs case */
    {
        if ((V42v.Nr <= V42v.Vs) || (V42v.Nr >= V42v.Va))
            return;
    }
    /* Save the frame details into the array */
    V42v.frame_details_array[V42v.fd_wrindx].Pbit_value = V42v.Pbit;
    V42v.frame_details_array[V42v.fd_wrindx].CR_value = V42v.C_R;
    V42v.frame_details_array[V42v.fd_wrindx].frmr_field0 = V42v.rcv_frm[1];
    V42v.frame_details_array[V42v.fd_wrindx].frmr_field1 = V42v.rcv_frm[2];
    V42v.frame_details_array[V42v.fd_wrindx].frmr_field2 = NR_ERROR;
    V42v.frame_details_array[V42v.fd_wrindx].type_of_frame = FRMR;

    /* Update the array index - circular buffer mode */
    if (V42v.fd_wrindx == MAX_FD_ARRAY_SIZE)
        V42v.fd_wrindx = 0;
    else
        V42v.fd_wrindx++;

    V42v.Invalid_Frame = 1;
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Copy_IFrame(V42CDBSTRUCT *V42CDSP)
{
    UCHAR tmp_unsigned_char;
    /*
    This routine copies the I-frames received into the Receive Window.
    V42v.Dec_window_num points to the window into which Iframe data to
    be copied.Also the sequence number of the frame is saved in the
    window for decoding.
    */
    V42v.tmpPtr = &V42v.Recv_Mesg_Window[V42v.Dec_window_num].mtext[0];

    for(tmp_unsigned_char = 3; tmp_unsigned_char < V42v.frmlen; tmp_unsigned_char++)
        *V42v.tmpPtr++ = V42v.rcv_frm[tmp_unsigned_char];

    V42v.Recv_Mesg_Window[V42v.Dec_window_num].len = (V42v.frmlen - 3);
    V42v.Recv_Mesg_Window[V42v.Dec_window_num].frm_seq_num = V42v.Ns;
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Chk_Response_Rqd(V42CDBSTRUCT *V42CDSP)
{
    V42v.received_resp_frm = 1;
    V42v.build_response = 0;
    /* check if the received frame is a command frame or not */
    if(((V42v.DCE_role) && (V42v.C_R == 0)) || ((V42v.DCE_role == 0) && (V42v.C_R)))
    {
        V42v.received_resp_frm = 0;
        /* command frame, check if requesting response from us */
        if(V42v.Pbit)
        {
            /* if local receiver is not ready, send RNR resp, else RR resp */

            if(V42v.local_recv_window == CLOSED)
            {
                V42v.RNR_frame_sent = 1;
                V42v.response_frame  = RNR;
            }
            else
            {
                V42v.RNR_frame_sent = 0;
                V42v.response_frame  = RR;
            }

            V42v.build_response = 1;
        }
    }
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_TEST_frame(V42CDBSTRUCT *V42CDSP){
UINT i;
UINT RcvVal;

    /* check if the received frame is a command frame or not */
    if(((V42v.DCE_role) && (V42v.C_R == 0)) || ((V42v.DCE_role == 0) && (V42v.C_R)))
    {
        V42v.nbyt = 0;
        V42v.response_frame = TEST;
        send_2lineout_buf(V42CDSP,ADDRESS | V42v.C_R);
        send_2lineout_buf(V42CDSP,V42v.response_frame & 0xEF);    //Pbit =0

        for(i=2;i<V42v.frmlen;i++)
        {
             V42Data.DP_buffer[V42v.nbyt++] = V42v.rcv_frm[i];
        }
        V42SendMessageToDP(V42CDSP->ChnId,mDATATODP,V42v.nbyt,V42Data.DP_buffer);
        SendFrameEndCmd( );
    }

    else if(V42v.TestFrameSent){
        V42v.TestFrameSent = 0;
        for(i=2; i< V42v.frmlen; i++){
            RcvVal = V42v.rcv_frm[i];
            if(RcvVal != TestSequence[i-2]){
                i--;
                break;
            }
        }
    }
}

/*****************************************************************************/
/*****************************************************************************/

/*process the UI frame if there is a BRK information,process it
according to the BRK type specified & send the acknowledgement to the peer*/

__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Process_UI_frame(V42CDBSTRUCT *V42CDSP){
UINT i;

        V42v.nbyt = 0;
        V42v.response_frame = UI;
        V42v.BrkOrAck = V42v.rcv_frm[2];
        /*if the frame is acknowledgement to BREAK sent*/
        if(V42v.BrkOrAck == BREAKACK){
            /*indicate the same to host*/
            V42IndicateStatus(V42CDSP->ChnId,BREAK_ACKED,0,(UCHAR *)msgParams);
            /*clear discard & break condition set it is assumed that
            there will not be any data from the host till the time
            specified in the break length & the timer is maintained by
            the host*/
            V42v.Break = 0;
            V42v.BREAK_DISCARD = 0;
            V42ReleaseTimer1(V42CDSP->ChnId);
            return;
            /* check if the received frame is a Break frame or not */
        } else if (V42v.BrkOrAck == BREAK){
            send_2lineout_buf(V42CDSP,ADDRESS | V42v.C_R);
            send_2lineout_buf(V42CDSP,V42v.response_frame & 0xEF);    //Pbit =0
            send_2lineout_buf(V42CDSP,BREAKACK);

            for(i=3;i<V42v.frmlen;i++)
            {
                 V42Data.DP_buffer[V42v.nbyt++] = V42v.rcv_frm[i];
            }
            V42SendMessageToDP(V42CDSP->ChnId,mDATATODP,V42v.nbyt,V42Data.DP_buffer);
            SendFrameEndCmd( );
            V42IndicateStatus(V42CDSP->ChnId,BREAK_RECD,V42v.nbyt,(UCHAR *)V42Data.DP_buffer);
        }
}

/*****************************************************************************/
/*****************************************************************************/

/*
    Depending on the condition if the received frame is valid ie.,
    if there is no sequence errors this function is called to process
    & send the frame to HOST or to send an appropriate command/response
    to its peer.
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void ProcessValidInfoFrame(V42CDBSTRUCT *V42CDSP){
    /* 8.4.3.2 and Note 2 */
    if((V42v.Nr != V42v.Va) && (V42v.rem_recv_window == OPEN))
    {
        V42ReleaseTimer1(V42CDSP->ChnId);
        V42v.T401_timer_state = OFF;
    }

    /* 8.4.3.2 */
    V42v.Va = V42v.Nr;

    /*  8.4.3.2 - Para 4 */
    if ((V42v.T401_timer_state == OFF) && (V42v.Vs != V42v.Va)){
        /* Setup T401 timeout timer */
        V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
        V42v.T401_timer_state = ON;
    }
        /* encode the pending data */
    V42v.DataLen = V42_encoder_main_proc(V42CDSP,V42v.DataPtr,(UINT)V42v.DataLen);

        /* if in own receiver busy condition - as per 8.4.7 */
        /*
        check if receive windows are available for storing the received
        I frames and allowed to receive Iframes (i.e. if in own receiver busy
        condition, then until all frames in the windows are not decoded, new
        I frames should not be received)
        */

    if (!V42v.stop_Iframe_receive)  /*&& (V42v.received_Ifrm_cnt < V42Data.Recv_Wnd_size)) */
    {
            /* receive windows available */
            /* since insequence I frame is received, clear reject exception */
        V42v.REJ_condition = 0;
            /* Increment the sequence count of next expected I frame */
        if(V42v.Vr == 127)
            V42v.Vr = 0;
        else
            V42v.Vr++;
            /* copy the Iframe data and sequence number into the window buffer */
        Copy_IFrame(V42CDSP);
            /*
            Since the current window is filled, update the window number to
            point to next window buffer
            */
        if (V42v.Dec_window_num == (V42Data.Recv_Wnd_size - 1))
            V42v.Dec_window_num = 0;
        else
            V42v.Dec_window_num++;

            /* increment the count of received Iframes */
        V42v.received_Ifrm_cnt++;
        /*
        if all windows are full with the received Iframe, set flag
        indicating that local receiver is not ready.
        */
        if (V42v.received_Ifrm_cnt >= V42Data.Recv_Wnd_size)
        {
            V42v.local_recv_window = CLOSED;
            V42v.stop_Iframe_receive = 1;
            if (!V42v.Pbit)
            {
                    /* send the response frame */
                V42v.RNR_frame_sent = 1;
                V42v.snd_frametype = RNR;
                snd_respframe_Fbit0(V42CDSP);
                return;
            }
        }
    }
    else
    {
        /*
        All receive windows are full, so cannot accept this I frame.
        Set flag indicating that local receiver is not ready

        This is to takecare of the case where after ESC or retrain
        modes, RR frame is sent and own receiver busy cleared.

        Set flag to send REJ resp after decoding one frame
        */

        V42v.local_recv_window = CLOSED;
        if (!V42v.REJ_condition)
            V42v.Iframe_reject = 1;
    }
        /*
        Note : Case of Iframe as response frame with Fbit set not clear
               No problem, because we can send response frame with Fbit 0
               any time
        */

        /* check if response to be sent for the received frame */
        Chk_Response_Rqd(V42CDSP);
        /*
        If the P bit of the received I- Frame (command frame) is set then
        send a response else the I-frame is not soliciting a response.
        */
        if(V42v.build_response)
            snd_RESP_frame(V42CDSP);

        /*
        8.4.2.2 - if no I frame to send or if remote DCE is not ready.
        Also refer 8.4.7 - in local receiver busy, no response to Iframe
        with V42v.Pbit set to 0.
        */
    else if(((V42v.WndWrIndx == V42v.Vs) || (V42v.rem_recv_window == CLOSED)) &&
            (!V42v.RNR_frame_sent))
    {
            /*
            Depending on whether local receiver is ready or not,
            send RR or RNR response frame with Fbit set to 0
            */
        if (V42v.local_recv_window == CLOSED)
        {
            V42v.RNR_frame_sent = 1;
            V42v.snd_frametype = RNR;
        }
        else
            V42v.snd_frametype = RR;
            /* send the response frame */
        snd_respframe_Fbit0(V42CDSP);
    }
}

/*****************************************************************************/
/*****************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void SendREJFrame(V42CDBSTRUCT *V42CDSP){
        /*
        If the received I-frame has a sequence error. Then send the
        Reject response, if not in own receiver busy condition and
        not in reject exception.
        */

    if(V42v.local_recv_window == CLOSED)
    {
        /*
        own receiver busy condition, send REJ resp after
        decoding one frame
        */
        if (!V42v.REJ_condition)
            V42v.Iframe_reject = 1;
        return;
    }
    else if (!V42v.REJ_condition)
    {
        /* send REJ frame  */
        V42v.snd_frametype = REJ;
        /* send the response frame with Fbit set to 0 */
        snd_respframe_Fbit0(V42CDSP);

        /* set flag indicating reject exception condition */
        V42v.REJ_condition = 1;
        V42v.Iframe_reject = 0;
    }
}

/*****************************************************************************/
/*****************************************************************************/

__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void SendSREJFrame(V42CDBSTRUCT *V42CDSP){

    /*
    If the received I-frame has a sequence error. Then send the
    Reject response, if not in own receiver busy condition and
    not in reject exception.
    */

    if (!V42v.REJ_condition)
    {
        /* send REJ frame  */
        V42v.snd_frametype = REJ;
        /* send the response frame with Fbit set to 0 */
        snd_respframe_Fbit0(V42CDSP);

        /* set flag indicating reject exception condition */
        V42v.REJ_condition = 1;
        V42v.Iframe_reject = 0;
    }
}

__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void CheckForBreakTx(V42CDBSTRUCT *V42CDSP){
    if(!V42v.Break)return;
    if(V42v.Va == V42v.Ns){
        /*enable flow control*/
        V42v.snd_frametype = UI;
        V42v.BrkOrAck = BREAK;
        Build_frame(V42CDSP);
        V42v.Break = 0;
        V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
        SetTimeOutEvent(RE_TX_BREAK_TIMER);
    }
}
#endif


/******************************************************************************
 END OF FILE 
*******************************************************************************/
