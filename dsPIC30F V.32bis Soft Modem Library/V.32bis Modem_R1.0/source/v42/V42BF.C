/******************************************************************************
 File Name:   V42BF.C 
*******************************************************************************/

#include "api_c.h"
#include "v42.h"
#include "v42api.h"

#ifdef DEF_V42

extern void chk_for_resp_frame_txmt(V42CDBSTRUCT *);
extern void chk_for_Iframe_txmt(V42CDBSTRUCT *);

/***************************************************************************
*
* V42E.C (Build Frame)  :
*
*       Contains functions for building different V.42 command/response frames.
*
*
****************************************************************************/

UCHAR TestSequence[12]={'E','n','c','o','r','e',' ','M','o','d','e','m'};
void send_2lineout_buf(V42CDBSTRUCT *,UCHAR char2send);

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void SendFrameEndCmd (V42CDBSTRUCT *V42CDSP) {
    V42SendMessageToDP(V42CDSP->ChnId,mHDLCFRMEND,0,msgParams);
}

/**************************************************************************/
/**************************************************************************/

/*
    V42_build_frame_proc() :
    Function to build Info and control frames depending on the current
    mode - re-establishment mode or not - and to takecare of timer recovery
    condition.
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void V42_build_frame_proc(V42CDBSTRUCT *V42CDSP)
{
    /* Note : Control frames will be exchanged during ESC or ONLINE cmd modes */
    /* check for any response frame to be build */

    chk_for_resp_frame_txmt(V42CDSP);

    /* DP flowcontrol condition ? */
    /* RR recheck for this condition */

    if (V42Data.DpFlowControl == TRUE)
        return;

    /* Are we in SYNC DATA STATE ? */

    if (V42Data.state == SYNC_DATA_STATE)
    {
        /* If any frame is to be built for sending to remote, build it */
        if (!V42v.re_establish_v42)
            chk_for_Iframe_txmt(V42CDSP);
//        else
            /* 8.4.9.1  - in re_establishment V42Data.state */
//            chk_for_sabme_txmt(V42CDSP);
    }
}


/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void Build_frame(V42CDBSTRUCT *V42CDSP)
{
    UINT i;

    V42v.nbyt = 0;
    if (V42v.snd_frametype == INFO)
    {
        /* Build I Frame */
        V42v.Pbit = 0x0;
        if (V42v.DCE_role)
            V42v.C_R = 0x02;
        else
            V42v.C_R = 0x00;

        /* Get window number, of the Iframe to be built, using V42v.Vs */
        for (V42Data.cTmp1 = 0; V42Data.cTmp1 < V42Data.Trans_Wnd_size; V42Data.cTmp1++)
            if (V42v.Trans_Mesg_Window[V42Data.cTmp1].frm_seq_num == V42v.Vs)
                break;

        V42v.WindowPtr = &V42v.Trans_Mesg_Window[V42Data.cTmp1];
        V42v.WindowPtr->FrmAddress = (ADDRESS | V42v.C_R);
        V42v.WindowPtr->IfrmVs = (V42v.Vs << 1);
        V42v.WindowPtr->IfrmVr = ((V42v.Vr << 1) | V42v.Pbit);

        /* Call H/W I/F function for sending frame to DP */
//        V42Data.DpFlowControl = send_V42Ifrm2dp(V42v.WindowPtr);

        V42SendMessageToDP(V42CDSP->ChnId,mDATATODP,V42v.WindowPtr->len+3,&V42v.WindowPtr->FrmAddress);
        SendFrameEndCmd(V42CDSP);

        /* 8.4.1 */

        if (V42v.T401_timer_state == OFF)
        {
            V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
            V42v.T401_timer_state = ON;
            SetTimeOutEvent(SYNCMODE_T401TIMER);
        }
    }
    else if(V42v.snd_frametype == UI)
    {
        if (V42v.DCE_role)
            V42v.C_R = 0x02;
        else
            V42v.C_R = 0x00;
        send_2lineout_buf(V42CDSP,ADDRESS | V42v.C_R);
        send_2lineout_buf(V42CDSP,V42v.snd_frametype & 0xEF);    //Pbit=0
        if(V42v.BrkOrAck==BREAK)
            send_2lineout_buf(V42CDSP,BREAK|((V42v.Ns&1)<<7));
        else
            send_2lineout_buf(V42CDSP,BREAKACK|((V42v.Nr&1)<<7));

        send_2lineout_buf(V42CDSP,V42v.Break_type);
        send_2lineout_buf(V42CDSP,V42v.BREAK_Len);
        V42SendMessageToDP(V42CDSP->ChnId,mDATATODP,V42v.nbyt,V42Data.DP_buffer);
        SendFrameEndCmd(V42CDSP);
    }
    else if(V42v.snd_frametype == TEST)
    {
        if (V42v.DCE_role)
            V42v.C_R = 0x02;
        else
            V42v.C_R = 0x00;

        send_2lineout_buf(V42CDSP,ADDRESS | V42v.C_R);
        send_2lineout_buf(V42CDSP,V42v.snd_frametype & 0xEF);    //Pbit =0

        for(i=0;i<sizeof(TestSequence);i++)
        {
             V42Data.DP_buffer[V42v.nbyt++] = (UCHAR)TestSequence[i];
        }

        V42SendMessageToDP(V42CDSP->ChnId,mDATATODP,V42v.nbyt,V42Data.DP_buffer);
        SendFrameEndCmd(V42CDSP);
    }
    else
    {
        send_2lineout_buf(V42CDSP,ADDRESS | V42v.C_R);

#ifdef DEF_DEBUG
    if(V42v.snd_frametype == SABME) {
        V42Data.PARM[0] = ORG_SEND_SABME;
        V42IndicateStatus(V42CDSP->ChnId,V42_NEGOTIATION_STATUS,1,V42Data.PARM);
    }        
    if(V42v.snd_frametype == UA) {
        V42Data.PARM[0] = ANS_SEND_UA;
        V42IndicateStatus(V42CDSP->ChnId,V42_NEGOTIATION_STATUS,1,V42Data.PARM);
    }
#endif

        /* SABME, UA, DM, DISC - constants have P/Fbit set to 1 */

        if ((V42v.snd_frametype == SABME) || (V42v.snd_frametype == UA) ||
            (V42v.snd_frametype == DM) || (V42v.snd_frametype == DISC))
        {
            if (V42v.Pbit)
                send_2lineout_buf(V42CDSP,V42v.snd_frametype);
            else
                send_2lineout_buf(V42CDSP,V42v.snd_frametype && 0xEF);
        }
        else
            send_2lineout_buf(V42CDSP,V42v.snd_frametype);

        if ((V42v.snd_frametype < 0x0f) && (V42v.snd_frametype != UI))
            send_2lineout_buf(V42CDSP,(V42v.Vr << 1) | V42v.Pbit);

        else if (V42v.snd_frametype == FRMR)
        {
            /* Build FRMR frame */
            if (V42v.DCE_role)
                V42v.C_R = 0x00;
            else
                V42v.C_R = 0x02;

            send_2lineout_buf(V42CDSP,V42v.FRMR_field[0]);

            send_2lineout_buf(V42CDSP,V42v.FRMR_field[1]);

            send_2lineout_buf(V42CDSP,V42v.Vs << 1);

            send_2lineout_buf(V42CDSP,(V42v.Vr << 1) | V42v.rec_frm_cr_value);

            send_2lineout_buf(V42CDSP,V42v.FRMR_field[2]);

        }

        V42SendMessageToDP(V42CDSP->ChnId,mDATATODP,V42v.nbyt,V42Data.DP_buffer);

        SendFrameEndCmd(V42CDSP);
    }
    V42v.response_frame = 0;
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void Build_XID_frame (V42CDBSTRUCT *V42CDSP)
{
    UCHAR parm;

#ifdef DEF_DEBUG
    if(V42CDSP->ChnId)
        V42Data.PARM[0] = ANS_SEND_XID;
    else
        V42Data.PARM[0] = ORG_SEND_XID;

    V42IndicateStatus(V42CDSP->ChnId,V42_NEGOTIATION_STATUS,1,V42Data.PARM);
#endif

    V42v.nbyt = 0;
    V42v.response_frame = 0;
    V42v.Group_len = 0;
    V42v.Format_Identifier = 0x82;
    V42v.Group_Identifier = 0x80;

    send_2lineout_buf(V42CDSP,(UCHAR)0x03);
    send_2lineout_buf(V42CDSP,XID);
    send_2lineout_buf(V42CDSP,V42v.Format_Identifier);
    send_2lineout_buf(V42CDSP,V42v.Group_Identifier);

    V42v.nbyt += 2;   /* Append Group len     */
    send_2lineout_buf(V42CDSP,(UCHAR)0x03);

    /*send parameter ID for HDLC optional function*/
    send_2lineout_buf(V42CDSP,(UCHAR)0x03);

    if (V42Data.Sreject)
          send_2lineout_buf(V42CDSP,(UCHAR)0x8e);
    else
          send_2lineout_buf(V42CDSP,(UCHAR)0x8a);

    parm = ((V42Data.LOOP_TEST&1) << 5);    // setting 14 th bit refer Table 11a

    if ((V42v.response_frame == XID) && (V42Data.FCS32_ena))
        parm |= 0x09;    // conformance with the encoding rules in ISO Standard 8885
    else
        parm |= 0x89;    // conformance with the encoding rules in ISO Standard 8885

    send_2lineout_buf(V42CDSP,(UCHAR)parm);

    if (V42Data.FCS32_ena)
          send_2lineout_buf(V42CDSP,(UCHAR)0x01);
    else
          send_2lineout_buf(V42CDSP,(UCHAR)0x00);

    V42v.tmpval = V42Data.Trans_Info_field * 8;

    send_2lineout_buf(V42CDSP,(UCHAR)0x05);

    send_2lineout_buf(V42CDSP,(UCHAR)0x02);

    send_2lineout_buf(V42CDSP,(UCHAR)(V42v.tmpval >> 8));

    send_2lineout_buf(V42CDSP,(UCHAR)(V42v.tmpval & 0xff));

    V42v.tmpval = V42Data.Recv_Info_field * 8;

    send_2lineout_buf(V42CDSP,(UCHAR)0x06);

    send_2lineout_buf(V42CDSP,(UCHAR)0x02);

    send_2lineout_buf(V42CDSP,(UCHAR)(V42v.tmpval >> 8));

    send_2lineout_buf(V42CDSP,(UCHAR)(V42v.tmpval & 0xff));

    send_2lineout_buf(V42CDSP,(UCHAR)0x07);

    send_2lineout_buf(V42CDSP,(UCHAR)0x01);

    send_2lineout_buf(V42CDSP,(V42Data.Trans_Wnd_size));

    send_2lineout_buf(V42CDSP,(UCHAR)0x08);

    send_2lineout_buf(V42CDSP,(UCHAR)0x01);

    send_2lineout_buf(V42CDSP,V42Data.Recv_Wnd_size);
    V42v.Group_len = V42v.nbyt - 6;

    V42Data.DP_buffer[4] = V42v.Group_len >> 8;

    V42Data.DP_buffer[5] = V42v.Group_len & 0xff;

    if (V42v.received_XID_flag == 0)
        V42Data.current_cmprsn_mode =  V42Data.cmprsn_mode;

    if (V42Data.current_cmprsn_mode)
    {
        V42v.Group_Identifier = 0xf0;
        send_2lineout_buf(V42CDSP,V42v.Group_Identifier);
        V42v.tmpval = V42v.nbyt;
        V42v.nbyt += 2;  /* Group len */
        send_2lineout_buf(V42CDSP,(UCHAR)0x00);
        send_2lineout_buf(V42CDSP,(UCHAR)0x03);
        send_2lineout_buf(V42CDSP,(UCHAR)0x56);
        send_2lineout_buf(V42CDSP,(UCHAR)0x34);
        send_2lineout_buf(V42CDSP,(UCHAR)0x32);
        send_2lineout_buf(V42CDSP,(UCHAR)0x01);
        send_2lineout_buf(V42CDSP,(UCHAR)0x01);
        send_2lineout_buf(V42CDSP,V42Data.current_cmprsn_mode);
        send_2lineout_buf(V42CDSP,(UCHAR)0x02);
        send_2lineout_buf(V42CDSP,(UCHAR)0x02);
        send_2lineout_buf(V42CDSP,(UCHAR)((V42Data.TotalNumCodeWords >> 8) & 0xff));
        send_2lineout_buf(V42CDSP,(UCHAR)(V42Data.TotalNumCodeWords  & 0xff));
        send_2lineout_buf(V42CDSP,(UCHAR)0x03);
        send_2lineout_buf(V42CDSP,(UCHAR)0x01);
        send_2lineout_buf(V42CDSP,V42Data.MaxStrLen);

        V42v.Group_len = 15;
        V42Data.DP_buffer[V42v.tmpval++] = V42v.Group_len >> 8;
        V42Data.DP_buffer[V42v.tmpval++] = V42v.Group_len & 0xff;
    }

//    V42Data.DpFlowControl = send_sync_df2dp(V42Data.DP_buffer, V42v.nbyt);
    V42SendMessageToDP(V42CDSP->ChnId,mDATATODP,V42v.nbyt,V42Data.DP_buffer);
    SendFrameEndCmd(V42CDSP);
}

/**************************************************************************/
/**************************************************************************/

/*
    send_2lineout_buf(V42CDSP,) :
    This function is used during V42 frame building to reduce code space ??
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void send_2lineout_buf(V42CDBSTRUCT *V42CDSP,UCHAR char2send)
{
    V42Data.DP_buffer[V42v.nbyt] = char2send;
    V42v.nbyt++;
}

#endif

/******************************************************************************
 END OF FILE 
*******************************************************************************/


