/******************************************************************************
 File Name:   V42MAIN.C 
*******************************************************************************/

#include "api_c.h"
#include "v42.h"
#include "v42api.h"

#ifdef DEF_V42

/***************************************************************************
*
* V42MAIN.C  :
*
*       Contains main function for handling DATA MODEM V42 error correction
*
****************************************************************************/

#define ENC_DECFILEL    1
#define ENC 1
#define DEC 0

INT V42bis_Encoder_Main(V42CDBSTRUCT *,UCHAR *,INT);
void V42bis_Decoder_Main(V42CDBSTRUCT *);
void detect_v42_proc(V42CDBSTRUCT *,UCHAR *,UCHAR);
void v42_negotiation_proc(V42CDBSTRUCT *);
void Chk_Frame_type(V42CDBSTRUCT *);
void V42_build_frame_proc(V42CDBSTRUCT *);
void V42_Copy_to_Host_Buf(V42CDBSTRUCT *);
void V42_Copy_to_Host_Buf(V42CDBSTRUCT *);
void snd_respframe_Fbit0(V42CDBSTRUCT *);
void snd_cmdframe_Pbit1(V42CDBSTRUCT *);
void chk_and_proc_frm(V42CDBSTRUCT *);
void chk_for_sabme_txmt(V42CDBSTRUCT *);
void Check_for_T401_timeout(V42CDBSTRUCT *);
void chk_for_resp_frame_txmt(V42CDBSTRUCT *);
void SendXon2Dte(V42CDBSTRUCT *);
void chk_Frame_type(V42CDBSTRUCT *);
void Process_DISC_frame(V42CDBSTRUCT *);
void setup_parms_for_v42neg(V42CDBSTRUCT *);
void DMDisconnectingProc(V42CDBSTRUCT *V42CDSP);
void Disconnect(V42CDBSTRUCT *V42CDSP);
void TxmtAsyncData2Dte(V42CDBSTRUCT *V42CDSP);
void TxmtAsyncData2Dp(V42CDBSTRUCT *V42CDSP);
void snd_DISC(V42CDBSTRUCT *V42CDSP);

/**************************************************************************/
/**************************************************************************/

/*
    V42_encoder_main_proc() :
    Main function of V42 for encoding and decoding of I frames
    and for handling the received control frames.
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
UINT V42_encoder_main_proc(V42CDBSTRUCT *V42CDSP,UCHAR *DATA,UINT LEN)
{
    UINT i,MaxFrames=0;

    /* Event based control, so until data from DTE and window free ,
     encode it */
    V42v.DataPtr = DATA;
    V42v.DataLen = LEN;

    if(LEN<=0)
        return(0);

    if ((V42v.re_establish_v42)||(V42Data.DpFlowControl)){
        return(LEN);
    }

//    V42_build_frame_proc(V42CDSP);

    V42v.TmpVs = V42v.WndWrIndx;
    V42v.TmpVa = V42v.Va;

    if (V42v.TmpVs < V42v.TmpVa)
        V42v.TmpVs += 128;

        /* Check if transmit window is free to fill another frame of data */
    while((V42v.TmpVs - V42v.TmpVa) < V42Data.Trans_Wnd_size)
    {
        /*if the data is completely read, break the while loop*/
//        if(LEN<=0){
//            cprintf("EMT ");
//            break;
//        }

        /* reset count of octets in window and end of data flag */
        V42v.Trans_indx = 0;

        /* setup pointer to window buffer */
        V42v.V42_tx_buf = &V42v.Trans_Mesg_Window[V42v.Enc_window_num].mtext[0];

        /*
        Depending on V42BIS compression required by remote or not, call
        proper function for transfering data from host to window buffer.
        */

        if (V42Data.Local_data_comp == 0 )
        {
            /*READ DATA*/
            //V42v.Trans_indx = get_data_from_Host(V42CDSP,V42v.V42_tx_buf);

            for(i=0;i<LEN;i++){
                if(i==V42Data.Trans_Info_field)break;
                *V42v.V42_tx_buf++ = *DATA++;
            }
            V42v.Trans_indx = i;
    
            /*save the data pointer after forming each frame*/
            V42v.DataPtr = DATA;

            /*Update the data count*/
            LEN = LEN-i;
        }

           if(LEN<=0)
            V42IndicateStatus(V42CDSP->ChnId,V42_READY_FOR_DATA,0,V42Data.PARM);

        /* check if data is loaded into the window */
        if (V42v.Trans_indx > 0)
        {
     /* some data is loaded into window, so update the window parms */
            V42v.Trans_Mesg_Window[V42v.Enc_window_num].len = V42v.Trans_indx;

            /*
            store the frame sequence no. in the window so that at the time
            of building the Iframe, for transmission(retransmission) to the
            remote, the required window data can be accessed using V42v.Vs
            */

            V42v.Trans_Mesg_Window[V42v.Enc_window_num].frm_seq_num = V42v.WndWrIndx;

            /*
            Since the current window is filled, update the window number to
            point to next window buffer
            */

            if (V42v.Enc_window_num == (V42Data.Trans_Wnd_size - 1))
                V42v.Enc_window_num = 0;
            else
                V42v.Enc_window_num++;

            /* increment the window sequence no. */

            if (V42v.WndWrIndx == 127)
                V42v.WndWrIndx = 0;
            else
                V42v.WndWrIndx++;

        }

        /*The maximum number frame s that can be sent to DP is decided
        by the internal buffering of the DP*/
        if (++MaxFrames >= MAXFRAMESTODP) break;
    }

     /* if no flowcontrol from DP, txmt frames, if available */
     V42_build_frame_proc(V42CDSP);
     return(LEN);
}

/**************************************************************************/
/**************************************************************************/

/*
    V42_decoder_main_proc() :
    Main function of V42 for processing received frames and
    decoding of I frames.
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void V42_decoder_main_proc(V42CDBSTRUCT *V42CDSP)
{
    UINT Status;

    /* check if Iframe to decode, or the partially decoded frame */
    while(V42v.received_Ifrm_cnt){
        /*donot decode if the host data control is true*/
        if(V42Data.DteFlowControl)break;
        if (!V42v.AbortDec)
        {
            Status = 0;
            /* new Iframe to be decoded, setup pointer to window */
            for (V42Data.cTmp1 = 0; V42Data.cTmp1 < V42Data.Recv_Wnd_size; V42Data.cTmp1++){
                if (V42v.Recv_Mesg_Window[V42Data.cTmp1].frm_seq_num == V42v.DecWndRdIndx)
                {
                    Status = 1;
                    break;
                }
            }
            if(!Status)break;

            V42v.Wnd_ptr = &V42v.Recv_Mesg_Window[V42Data.cTmp1].mtext[0];
            V42v.Wnd_buf_len = V42v.Recv_Mesg_Window[V42Data.cTmp1].len;
        }

/*
    Depending on V42BIS compression required by remote or not,
    call proper function for processing the I frame
*/

        if (V42Data.Rem_data_comp == 0){
/*
If the compression not enabled,the data received from the remote
modem is returned to the controller program.
*/
            Status = V42ReceiveData(V42CDSP->ChnId,V42v.Wnd_ptr,V42v.Wnd_buf_len);
            if(Status)V42Data.DteFlowControl = TRUE;
            V42v.Recv_Mesg_Window[V42Data.cTmp1].frm_seq_num  = 0xff;
        }

/*
    Check if the frame is completely decoded or partially decoded
    due to host  buffer(data_utx_buf) nearing full condition
    Note : Until frame is completely decoded, window parameters
    are not updated  response frame is not sent to remote DCE
*/
        /* frame completely decoded, update window parameters */
        //if(V42Data.DteFlowControl == FALSE)
        {
        /* decrement the count of Iframes in the window buffers */
            V42v.received_Ifrm_cnt--;
        /* increment the window sequence no. */
            if (V42v.DecWndRdIndx == 127)
                V42v.DecWndRdIndx = 0;
            else
                V42v.DecWndRdIndx++;
        }

        /*
        We have decoded one window data and hence a window become empty. Check if
        in own receiver condition, if so check conditions for indicating to remote
        DCE that we are ready to receive Iframes again.
        */

        if (V42v.local_recv_window == CLOSED)
        {
        /*
            If negotiated receive window count is greater than 8, then
            if four or less than four windows are pending for decoding,
            RR or REJ to be sent.
        */

            if (V42Data.Recv_Wnd_size > 8)
            {
                if (V42v.received_Ifrm_cnt > 5)
                    continue;
            }
            /*
            If negotiated receive window count is greater than 4, then
            if two or less than two windows are pending for decoding,
            RR or REJ to be sent.
            */
            else if (V42Data.Recv_Wnd_size > 4)
            {
                if (V42v.received_Ifrm_cnt > 2)
                    continue;
            }

        /*
            If negotiated receive window count is <= 4, then if one
            window buffer to be decoded, send RR or REJ
        */

            else if (V42v.received_Ifrm_cnt > 1)
                continue;
            /*
            if Iframes rejected and not in reject exception,
            send REJ response else send RR response
            */
            if (V42v.Iframe_reject && (!V42v.REJ_condition))
            {
                V42v.Iframe_reject = 0;
                V42v.REJ_condition = 1;
                V42v.snd_frametype = REJ;
            }
            else
                V42v.snd_frametype = RR;

            /* send the response frame */
            snd_respframe_Fbit0(V42CDSP);
            /*
            set status indicating that we are ready
            to receive further Iframes
            */
            V42v.local_recv_window = OPEN;
            V42v.stop_Iframe_receive = 0;
            V42v.RNR_frame_sent = 0;
            break;
        }
    }
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void DMDisconnectingProc(V42CDBSTRUCT *V42CDSP)
{
    /*
    If connected in V42 mode,proper termination is done
    by sending the DISC frames to remote
    */

    if ((V42Data.previous_state == SYNC_DATA_STATE) || (V42Data.state == SYNC_DATA_STATE))
    {
        V42Data.state = DISCONNECTING_STATE;
        V42v.Retrans_count = 0;
        /* Event based ctrl, initiate disconnection process */
        Disconnect(V42CDSP);
    }
    else
    {
        /* Event based ctrl, initiate disconnection process */
        V42Data.SessionOk = 1;
        perform_modem_hangup(V42CDSP);
    }
}

/**************************************************************************/
/**************************************************************************/

/*
This function sends the DISC frames during the disconnection of V42, and also
receives the DM,UA frames and process it.
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void Disconnect(V42CDBSTRUCT *V42CDSP)
{
    if(V42v.Retrans_count < 1)
    {
        snd_DISC(V42CDSP);
    }
    else
    {
        /* V42Data.state = DISCONNECTING_STATE3; */
        /* Event based control, initiate disconnection process */
        V42Data.SessionOk = 3;
        perform_modem_hangup(V42CDSP);
    }
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void snd_DISC(V42CDBSTRUCT *V42CDSP)
{
    V42v.Retrans_count++;
    V42v.snd_frametype = DISC;

    if (V42v.DCE_role)
        V42v.C_R = 0x02;
    else
        V42v.C_R = 0x00;

    V42v.Pbit = 0x01;
    Build_frame(V42CDSP);
    /* Setup T401 timeout timer */
    V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
    SetTimeOutEvent(DISCONNECTION_TIMEOUT);
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))
void ChkConnectionState(V42CDBSTRUCT *V42CDSP){


    if (V42Data.state == WAIT_FOR_CARRIER_STATE)
    {
        /*
        On getting the carrier this V42Data.state is entered.
        On entering this V42Data.state, Depending on at&q option or loopback
        test, State is set properly and accordingly command is sent
        to DP
        */
        if(V42Data.NoODP){
             /*force the condition that ADP is detected & directly
             switch to V42_NEGOTIATION_STATE*/
            V42v.flags_detected = 4;
            detect_v42_proc(V42CDSP,V42v.rcv_frm,0);
            msgId = mDATAMODESELECT;
            msgLen = 1;
            msgParams[0] = DATA_HDLC;
            V42SendMessageToDP(V42CDSP->ChnId,msgId,msgLen,msgParams);
            RESETDPBUFPTRS( );

            V42Data.state = V42_NEGOTIATION_STATE;
            return;
        }
        V42Data.state = V42_DETECTION_STATE;
        msgId = mDATAMODESELECT;
        msgLen = 2;
        msgParams[0]= DATA_L2MSS;
        msgParams[1]= 10;            /* Set no of stop bits to 10 */
        V42SendMessageToDP(V42CDSP->ChnId,mDATAMODESELECT,2,msgParams);
        RESETDPBUFPTRS( );
        init_v42var(V42CDSP);

        if(!V42v.DCE_role){
            V42SetupTimer1(V42CDSP->ChnId,(ULNG)3000);    //set timer for 3000 mSec
            SetTimeOutEvent(ODP_ADP_DET_TIMER);
        }
        else    /*Originate mode start ODP*/
        {
            /* Setup timeout - for DP to send the pattern */
            V42SetupTimer1(V42CDSP->ChnId,(ULONG)100);    //set timer for 100 mSec
            SetTimeOutEvent(ODP_TRANSMIT_TIMEOUT);
        }
        return;
    }
    else
    {
        if(V42Data.state == DP_RETRAINING_STATE)
        {
            if ((V42Data.previous_state == SYNC_DATA_STATE) ||
                    (V42Data.previous_state == ASYNC_DATA_STATE))
            {

            if (V42Data.previous_state == SYNC_DATA_STATE)
                V42IndicateStatus(V42CDSP->ChnId,V42_RETRAIN_CONNECT,0,V42Data.PARM);
            else
                V42IndicateStatus(V42CDSP->ChnId,ASYNC_CONNECT,0,V42Data.PARM);

                if(V42v.DataLen == 0)
                    V42IndicateStatus(V42CDSP->ChnId,V42_READY_FOR_DATA,0,V42Data.PARM);

#if(0)
                if(V42Data.send_retrain_resp)
                {
                    /*
                    On getting the carrier in retrain mode,If
                    connection details to be sent,send it
                    */
                    if (V42Data.ECM_rescode == 1)
                    {
                        V42IndicateStatus(V42CDSP->ChnId,V42_RETRAIN_CONNECT,0,V42Data.PARM);
                    }
                    V42Data.send_retrain_resp = 0;
                }
#endif
                if (V42Data.ECM_enabled)
                    /* set flag to send RR supervisory frame */
                    V42v.send_RR_cmd_frame = 1;
                    V42Data.state = V42Data.previous_state;
//                    V42v.snd_frametype = RR;
//                    snd_cmdframe_Pbit1(V42CDSP);
//                    V42v.local_recv_window = OPEN;
//                    V42v.RNR_frame_sent = 0;
//                    V42_build_frame_proc(V42CDSP);
            }
            else
            {
                /* If auto retrain when in command mode or v42detection */
                V42Data.state = V42Data.previous_state;
                V42Data.previous_state = V42Data.previous_state_bak;
            }

        }

        /*
        During V42 detection, DSP to be in default mode,
        i.e strip start/stop bits for receive data only.
        */
        if (V42Data.state != V42_DETECTION_STATE)
        {
            /* Not in V42 Detection phase, in V42 Negotiation phase ? */
            if (V42Data.state == V42_NEGOTIATION_STATE)
            {
                /* Yes, Send command to DP to enter into SYNC mode */
                msgId = mDATAMODESELECT;
                msgLen = 1;
                msgParams[0] = DATA_HDLC;
                RESETDPBUFPTRS( );
            }
            else
            {
                /*
                In online command mode or in data V42Data.state. Depending on
                V42 connect mode or not, send command to DP to enter
                into SYNC or ASYNC mode
                */
                if (V42Data.ECM_enabled){
                    msgId = mDATAMODESELECT;
                    msgLen = 1;
                    msgParams[0] = DATA_HDLC;
                }
                else{
                    msgId = mDATAMODESELECT;
                    msgLen = 2;
                    msgParams[0] = DATA_L2MSS;
                    msgParams[1] = 1;
                }
            }

            V42SendMessageToDP(V42CDSP->ChnId,msgId,msgLen,msgParams);
            RESETDPBUFPTRS( );
        }

    /*
        Since mdm default timer is used during retrain,
        if required start the timer again.
    */
        if (V42Data.state == SYNC_DATA_STATE)
        {
            /* start T401 ? */
            if (V42v.T401_timer_state == ON)
                V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
        }
        else if ((V42Data.state == V42_DETECTION_STATE) ||
            (V42Data.state == V42_NEGOTIATION_STATE))
            V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);

    }
}

#endif

/******************************************************************************
 END OF FILE 
*******************************************************************************/
