/******************************************************************************
 File Name:   V42IF.C 
******************************************************************************/

#include "api_c.h"
#include "v42.h"
#include "v42api.h"

#ifdef DEF_V42

extern void InitV42State(V42CDBSTRUCT *);
extern void setup_parms_for_v42neg(V42CDBSTRUCT *);
extern INT V42_encoder_main_proc(V42CDBSTRUCT * , UCHAR *, UINT);
extern void SendAsyncDataToDP(V42CDBSTRUCT * , UCHAR *, UINT);
extern void V42FallBack(V42CDBSTRUCT *);
extern void Build_XID_frame(V42CDBSTRUCT *);
extern void Attempt_LAPM_conn(V42CDBSTRUCT *V42CDSP);
extern void Check_for_T401_timeout(V42CDBSTRUCT *);
extern void chk_for_sabme_txmt(V42CDBSTRUCT *);
extern void Disconnect(V42CDBSTRUCT *);
extern void SndV42DectPat2dp(V42CDBSTRUCT *);
extern void DMDisconnectingProc(V42CDBSTRUCT *);
extern void StartV42(V42CDBSTRUCT *, INT);
extern void V42_decoder_main_proc(V42CDBSTRUCT *);
extern void chk_for_resp_frame_txmt(V42CDBSTRUCT *);
extern void init_on_v42_establishment(V42CDBSTRUCT *);
extern void detect_v42_proc(V42CDBSTRUCT *,UCHAR *,UCHAR);
extern void ChkConnectionState(V42CDBSTRUCT *);
extern void chk_and_proc_frm(V42CDBSTRUCT *);
extern void ClearStruct1(CHAR *ptr,ULONG len);

/***************************************************************************
*
* V42IF.C (Interface Functions)  :
*
*          This contains the wrapper function which implements all the export
*    functions given as the part of the API interface for V.42.
*
****************************************************************************/

/*This function returns the size of the static data memory
required by the V42 .*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

ULONG V42GetMemRequirement(void){
    return(sizeof(V42CDBSTRUCT));
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

/*Initialize the zeroth channel base pointer address*/
void V42InitBaseAddress(void *ptr){
    V42Chn0BaseAddress = ptr;
}

/**************************************************************************/
/**************************************************************************/

/*The controller should allocate data memory for V42 & the Identification
number to channel memory is passed as parameter.to this function; initializes all
V42 variable to its default values. On successful completion of the
initialization, returns 1 to the application otherwise '0' is returned.
*/

__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

UINT V42OpenChannel(UINT ChnId){
    V42CDBSTRUCT *V42CDSP;
    ULONG ChnAddrOffset;

    ChnAddrOffset = ChnId*sizeof(V42CDBSTRUCT);
    V42CDSP = V42Chn0BaseAddress+ChnAddrOffset;

    ClearStruct1((CHAR *)V42CDSP, (sizeof(V42CDBSTRUCT)));
    
    V42CDSP->ChnId = ChnId;
    InitV42State(V42CDSP);
    V42v.DCE_role = V42ENABLED;    /*By default enable V.42*/

    /*sets default values for negotiable parameter*/
    setup_parms_for_v42neg(V42CDSP);
    V42Data.state = WAIT_FOR_CARRIER_STATE;
    return(1);
}

/**************************************************************************/
/**************************************************************************/

/*Clears the memory used by V.42.*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void V42CloseChannel(UINT ChnId){
    V42CDBSTRUCT *V42CDSP;
    ULONG ChnAddrOffset;

    ChnAddrOffset = ChnId*sizeof(V42CDBSTRUCT);
    V42CDSP = V42Chn0BaseAddress + ChnAddrOffset;
    ClearStruct1((CHAR *)V42CDSP,(ULONG)sizeof(V42CDBSTRUCT));
}


/**************************************************************************/
/**************************************************************************/

/*The application can send data to be sent to remote modem. The Identification
number to channel is passed as argument. The program returns number of data read
from the buffer.
If the data passed is not completely read by the V42 then the buffer pointer
is saved. The remaining data is read in the later stages & the buffer empty
situation is indicated to controller with IndicateV42Status() with
STATUS_ID= V42_READY_FOR_DATA.
Depending on whether the application is in V42 mode or
async mode the data is processed.

If the application is in ASYNC mode the data read is
directly sent to DP for modulation.

If the application is in SYNC mode the data read is
processed depending on whether COMPRESSED mode is enabled
or not. The encoded frames are sent to DP for transmission.
*/

/*
    The number of data encoded by V42 Encoder depends on
    the difference between Vs(number of frames sent) &
    (number of frames acknowledged)Va. No data is encoded
    if there is a request for reestablishment of V.42 connection
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

UINT V42SendData(UINT ChnId, UCHAR *DATA,UINT LEN){

    V42CDBSTRUCT *V42CDSP;

    ULONG ChnAddrOffset;

    ChnAddrOffset = ChnId*sizeof(V42CDBSTRUCT);
    V42CDSP = V42Chn0BaseAddress + ChnAddrOffset;

    /*after V.42 Fall back the error control function enters
    ASYNC_DATA_STATE*/

    if(V42Data.state == ASYNC_DATA_STATE ){
        SendAsyncDataToDP(V42CDSP,DATA,LEN);
        return(V42v.DataLen);
    }

    /*if in V.42 Error Correction mode encode & send data to DP*/
    if(V42Data.state == SYNC_DATA_STATE ){
        V42v.DataLen =  V42_encoder_main_proc(V42CDSP,DATA,LEN);
    }

    /*the number of unread data is returned*/
    return(V42v.DataLen);
}

/**************************************************************************/
/**************************************************************************/

/*
The controller calls this function in case of a time out event.
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void V42ExecuteTimeOut1(UINT ChnId)
{
    V42CDBSTRUCT *V42CDSP;
    ULONG ChnAddrOffset;

    ChnAddrOffset = ChnId*sizeof(V42CDBSTRUCT);
    V42CDSP = V42Chn0BaseAddress + ChnAddrOffset;
    V42Data.MdmTimeout = TRUE;
    switch(V42Data.TimerEventSet){

        case ODP_ADP_DET_TIMER:
            /*The timer was set to 3 seconds when DP_DATA_CONNECT
            message is got.when the modem is ORG/ANS.*/
            V42ReleaseTimer1(V42CDSP->ChnId);
            V42FallBack(V42CDSP);
            break;

        case N400_RETX_TIMER:
            /*This is set to T401 during negotiation phase.
            Waits for N400 re transmission of XID before falling
            back.*/
            /*
            Either in Org or Ans modes, if retransmit count
            exceeds maximum limit, failure of V42 negotiation.
            */
            if (V42v.Retrans_count++ >= N400_COUNT)
                V42FallBack(V42CDSP);
            else{
                Build_XID_frame(V42CDSP);
                V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
                SetTimeOutEvent(N400_RETX_TIMER);
            }
            break;

        case XID_PREAMBLE_TIMER:
                /*attempts LAP-M connection by transmiting XID frame in the begining*/
            Attempt_LAPM_conn(V42CDSP);
            break;

        case NEG_N400_TIMER:
                /* check the mode of operation - Originate or Answer */
            if (V42v.DCE_role)
            {
                /* Originate Mode */
                /* FOR both XID and SABME V42v.Pbit is set to 1 */
                V42v.C_R = 0x02;

                if (V42v.neg_phase_snd_frame)
                {
                    if (V42v.neg_phase_snd_frame == XID)
                    {
                        V42v.Pbit = 0x00;
                        V42v.snd_frametype = XID;
                        Build_XID_frame(V42CDSP);
                    }
                    else
                    {
                        V42v.Pbit = 0x01;
                        V42v.snd_frametype = SABME;
                        Build_frame(V42CDSP);
                    }
                }
            }
            break;

        case SYNCMODE_T401TIMER:
            Check_for_T401_timeout(V42CDSP);
            break;

        case SYNCMODE_N400_RETX:
            /* 8.4.9.1  - in re_establishment V42Data.state */
            chk_for_sabme_txmt(V42CDSP);
            break;

        case DISCONNECTION_TIMEOUT:
            Disconnect(V42CDSP);
            break;

        case ODP_TRANSMIT_TIMEOUT:
            SndV42DectPat2dp(V42CDSP);

            SetTimeOutEvent(ODP_TRANSMIT_TIMEOUT);
            V42SetupTimer1(V42CDSP->ChnId,(ULONG)100);    //set timer for 100 mSec
            /*The effectively timer is set to 1.3 seconds after DP_DATA_CONNECT message is got.
            when the modem is ORG.*/
            if(++V42v.ODPReTxCnt == 13){
                V42ReleaseTimer1(V42CDSP->ChnId);
                V42FallBack(V42CDSP);
            }
            break;

        case ASYNC_TRANSMIT_TIMEOUT:
            if(V42v.DataLen)
                SendAsyncDataToDP(V42CDSP,V42v.DataPtr,V42v.DataLen);
            break;

        case RE_TX_BREAK_TIMER:
            if (V42v.Retrans_count++ >= N400_COUNT){
                /*send UI frame to DP*/
                Build_frame(V42CDSP);
                V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
                SetTimeOutEvent(RE_TX_BREAK_TIMER);
            }
            else{
                V42ReleaseTimer1(V42CDSP->ChnId);
                V42Data.SessionOk = 5;    /*protocol error*/
                V42Data.ErrorCode = NO_ACK_FOR_BREAK;
                perform_modem_hangup(V42CDSP);
            }
            break;
    }
}

/**************************************************************************/
/**************************************************************************/

/*
This  function is  provided by V42 to help application configure various
negotiable parameters.
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void V42ConfigParameters(UINT ChnId, UINT CONFIG_ID,UINT *PARAMS){

    V42CDBSTRUCT *V42CDSP;
    ULONG ChnAddrOffset;

    ChnAddrOffset = ChnId*sizeof(V42CDBSTRUCT);
    V42CDSP = V42Chn0BaseAddress + ChnAddrOffset;

    switch(CONFIG_ID){
        case DICTIONARYSIZE:
            V42Data.dict_size = *PARAMS;    // 512/1024;
            break;

        case V42DISABLE:
            V42FallBack(V42CDSP);
            V42v.DCE_role = 2;        //disable V.42
            break;

        case V42BISCOMPRESSION:
            V42Data.cmprsn_mode = *PARAMS;
                /*    0 - DISABLE COMPRESSION
                    1 - ENABLE TX COMPRESSION
                    2 - ENABLE RX COMPRESSION
                    3 - ENABLE TX & RX COMPRESSION
                */

            break;

        case DISABLE_ODP_TX:
            V42Data.NoODP = 1;
            break;

        case ENABLE_L_TEST:
            V42Data.LOOP_TEST = *PARAMS;    /* 1 - enable  Loop Test option
                               0 - Disable Loop Test option
                            */
            break;

        case ENABLE_S_REJECT:
            V42Data.Sreject = *PARAMS;    //To enable or Disable Loop Srej option
            break;

        case TX_WINDOW_SIZE:
            V42Data.Trans_Wnd_size = *PARAMS;
            break;

        case RX_WINDOW_SIZE:
            V42Data.Recv_Wnd_size = *PARAMS;
            break;
    }
}

/**************************************************************************/
/**************************************************************************/

/*
This  function is  provided by V42 to help application control v.42
session.
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void V42Control(UINT ChnId, UINT CONTROL_ID,UINT LEN, UINT *PARAMS){

    V42CDBSTRUCT *V42CDSP;
    UINT state;
    ULONG ChnAddrOffset;

    LEN = LEN;

    ChnAddrOffset = ChnId*sizeof(V42CDBSTRUCT);
    V42CDSP = V42Chn0BaseAddress + ChnAddrOffset;

    switch(CONTROL_ID){
        case START_LTEST:
            if((V42Data.state == SYNC_DATA_STATE)&&(V42Data.LOOP_TEST==SET)){
                V42v.TestFrameSent = 1;
                V42v.snd_frametype = TEST;
                Build_frame(V42CDSP);
            }
            break;

        case V42_HANGUP:
            /*abrupt link release request*/
            V42Data.SessionOk = 1;
            perform_modem_hangup(V42CDSP);
            break;

        case V42_L_RELEASE:
            /*link release request*/
            V42v.Retrans_count = 0;
            V42Data.previous_state = V42Data.state;
            /*DM Disc need to be modified*/
            DMDisconnectingProc(V42CDSP);
            break;

        case ORIGINATE_MODEM:
            StartV42(V42CDSP,ORIGINATEMODE);
            break;

        case ANSWER_MODEM:
            StartV42(V42CDSP,ANSWERMODE);
            break;

        case HOST_READY_FOR_DATA:
            V42Data.DteFlowControl = FALSE;
        /*send all the pending I frame to Host*/
            V42_decoder_main_proc(V42CDSP);
            chk_for_resp_frame_txmt(V42CDSP);
            break;

        case GET_CONNECT_STATUS:
            if(V42Data.state ==SYNC_DATA_STATE)state = 1;
            else if(V42Data.state ==ASYNC_DATA_STATE)state = 0;
            else state = 2;     /*in negotiation state*/
            V42Data.PARM[0] = state;/*1-V42 ECM/0-ASYNC data mode*/
            V42Data.PARM[1] = V42Data.TxBitRate;        /*transmit direction data rate/2400*/
            V42Data.PARM[2] = V42Data.RxBitRate;        /*receive direction data rate/2400*/
            V42Data.PARM[3] = V42Data.Local_data_comp;    /*local modem data compression*/
            V42Data.PARM[4] = V42Data.Rem_data_comp;    /*remote modem data compression*/
            V42Data.PARM[5] = V42Data.Trans_Wnd_size;    /*transmit direction window size*/
            V42Data.PARM[6] = V42Data.Recv_Wnd_size;    /*Receive direction window size*/
            V42Data.PARM[7] = V42Data.Sreject;        /*S-Reject capability*/
            V42Data.PARM[8] = V42Data.LOOP_TEST;         /*Loop Back test capability*/
            V42Data.PARM[8] = 128;                /*frame size is always 128*/
            V42IndicateStatus(V42CDSP->ChnId,V42_CONNECTION_STATUS,9,V42Data.PARM);
            break;

        case SEND_BREAK:
            V42v.Break_type = *PARAMS++;
            V42v.BREAK_Len = *PARAMS++;
            if(V42v.Break_type == NONEXP_NONDESTRUCTV){
/* Set the break condition & wait untill all the transmitted frames
are acknowledged by the remote DCE*/
                if(V42v.Ns != V42v.Va){
                    V42v.Break = 1;
    /*donot transmit any more frames till BRKACK*/
                    V42Data.DpFlowControl = 1;
                    break;
                }
            }
            /*send UI frame carrying break signal information*/
            V42v.snd_frametype = UI;

            /*send break information*/
            V42v.BrkOrAck = BREAK;

            /*send UI frame to DP*/
            Build_frame(V42CDSP);
            V42SetupTimer1(V42CDSP->ChnId,(ULNG)Timer_T401);
            SetTimeOutEvent(RE_TX_BREAK_TIMER);
            V42v.Retrans_count = 0;

            /*the BREAK signal type to be delivered is destructive Expedited*/
            if(V42v.Break_type == EXP_DESTRUCTV){
                /*discard data to be read from the host buffer*/
                V42v.DataLen = 0;
                /*all state variables set to reset state*/
                init_on_v42_establishment(V42CDSP);
                V42v.BREAK_DISCARD = 1;
                /*donot transmit any more frames till BRKACK*/
            }
            break;
    }
}

/**************************************************************************/
/**************************************************************************/

/*
This function is invoked by the application when the DP sends a
message to V42.
*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void V42ProcessDPMessage(UINT ChnId, UCHAR *msg,UCHAR *MsgParams)
{
    UINT i; 
    V42CDBSTRUCT *V42CDSP;
    MESSAGE *Msg;

    ULONG ChnAddrOffset;

    ChnAddrOffset = ChnId*sizeof(V42CDBSTRUCT);
    V42CDSP = V42Chn0BaseAddress + ChnAddrOffset;

    Msg = (MESSAGE *)(msg);
    msgId = *msg++;
    msgLen = *msg++;

    switch ( msgId ) {

        case mDATATOHOST:

            for(i=0;i<msgLen;i++) {
                V42v.rcv_frm[V42v.frmlen++] = *MsgParams++;
                if(V42v.frmlen >=140)V42v.frmlen = 0;
            }
            if(V42Data.state == V42_DETECTION_STATE){
                detect_v42_proc(V42CDSP,V42v.rcv_frm,V42v.frmlen);
                V42v.frmlen = 0;
            }
            if(V42Data.state == ASYNC_DATA_STATE){
                if(V42v.frmlen)
                    V42ReceiveData(V42CDSP->ChnId,V42v.rcv_frm,V42v.frmlen);
                V42v.frmlen = 0;
            }
            break;

        case mCONNECT:
            /* Clear DP flowcontrol condition */
            V42Data.DpFlowControl = FALSE;
            V42v.RetrainingFlag = FALSE;
            V42Data.TxBitRate = *MsgParams++;    /*transmit direction data rate/2400*/
            V42Data.RxBitRate = *MsgParams++;    /*receive direction data rate*/
            V42ReleaseTimer1(V42CDSP->ChnId);
            /* this implements the loop back operation through V.42 data mode
            always being in ASYNC & with START & STOP bits.*/

            if (V42v.DCE_role == 2) {
                V42Data.state = ASYNC_DATA_STATE;
                msgId = mDATAMODESELECT;
                msgLen = 2;
                msgParams[0] = DATA_L2MSS;
                msgParams[1] = 1;
                V42SendMessageToDP(V42CDSP->ChnId,msgId,msgLen,msgParams);
                return;
            }

            ChkConnectionState(V42CDSP);
            break;

        case mNOCARRIER:
            /* User abort condition */
            /* Hangup process */
            /*indicate remote modem disconnect to controller*/
            V42Data.SessionOk = 4;
            perform_modem_hangup(V42CDSP);
            break;

        case mFRAMEACK:
            V42Data.HdlcFrameSent2Line = TRUE;
            /*check for unsent data to the DP*/
            /* encode the pending data */
            V42v.DataLen = V42_encoder_main_proc(V42CDSP,V42v.DataPtr,V42v.DataLen);
            break;

/*the messages mXON & mXOFF can be processed by the V42SendMessageToDP
 or a function which is called after every datapump function call for
 reading & writing messages*/
 /*this isssue is to be resolved*/

        case mXON:
            V42Data.DpFlowControl = FALSE;
            /*check for unread data in the host buffer*/
            if(V42Data.state == ASYNC_DATA_STATE){
                if(V42v.DataLen)
                    SendAsyncDataToDP(V42CDSP,V42v.DataPtr,V42v.DataLen);
            }
            if(V42Data.state == SYNC_DATA_STATE){
                    V42v.DataLen = V42_encoder_main_proc(V42CDSP,V42v.DataPtr,V42v.DataLen);
            }
            if(!V42v.DataLen) 
	            V42IndicateStatus(V42CDSP->ChnId,DP_XON_STATUS,0,V42Data.PARM);
            break;

        case mXOFF:
            V42Data.DpFlowControl = TRUE;
            V42IndicateStatus(V42CDSP->ChnId,DP_XOFF_STATUS,0,V42Data.PARM);
            break;

        case mREMOTERETRAIN:
        case mLOCALRETRAIN:
//        case mRENEGOTIATION:

 /* After sending resp to DISC frame, on remote drop we may retrain */
            V42IndicateStatus(V42CDSP->ChnId,DP_RETRAIN_STATUS,0,V42Data.PARM);
//            if(V42Data.state == DP_RETRAINING_STATE) break;

            if (V42Data.state == DISCONNECTING_STATE2)
                break;

            /* Send Xoff to Host only if Dte data transmit flow
            control is off*/

            V42Data.DpFlowControl = TRUE;
            V42ReleaseTimer1(V42CDSP->ChnId);

            /* Ans case - Setup retrain carrier timeout */
            V42SetupTimer1(V42CDSP->ChnId,(ULNG)DM_RETRAIN_CARRIER_TIMEOUT);
            V42v.RetrainingFlag = TRUE;

            if(V42Data.state != DP_RETRAINING_STATE){
                V42Data.previous_state = V42Data.state;
            }
            V42Data.state = DP_RETRAINING_STATE;
            break;

        case mCRCOK:
            V42v.FrameAvailable++;
            V42v.frmlen -= 2;    /*remove two CRC bytes in the end of the frame*/
            /*if the frame is an INFO frame call the decoder*/
            chk_and_proc_frm(V42CDSP);
            V42v.frmlen = 0;
//            V42v.FcsErrors=0;
            break;

        case mCRCERROR:
            /* reject the frame stored in V42v.rcv_frm*/
            V42v.frmlen = 0;
            V42v.FcsErrors++;
            break;

        case mMODEMREADY:
        case mHANGUPCOMPLETE:
            if(V42Data.SessionOk==1){
                V42IndicateStatus(V42CDSP->ChnId,L_RELEASED,0,V42Data.PARM);
            }else if(V42Data.SessionOk==2){
                V42IndicateStatus(V42CDSP->ChnId,REMOTE_V42_DISCONNECT,0,V42Data.PARM);
            }else if(V42Data.SessionOk==3){
                V42Data.PARM[0] = NO_ACK_FOR_DISC;
                V42IndicateStatus(V42CDSP->ChnId,L_RELEASED,1,V42Data.PARM);
            }else if(V42Data.SessionOk==4){
                V42IndicateStatus(V42CDSP->ChnId,DP_LOST_CARRIER,0,V42Data.PARM);
            }else{
                V42IndicateStatus(V42CDSP->ChnId,V42_PROTO_ERROR,1,(UCHAR *)&V42Data.ErrorCode);
            }
            break;

        default:
            V42IndicateStatus(V42CDSP->ChnId,msgId,msgLen,V42Data.PARM);
            break;
    }
}

/**************************************************************************/
/**************************************************************************/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

void ClearStruct1 (CHAR *p, ULONG l) {
    INT i=0;
    while(l) {
        p[i++] = 0;
        l--;
    }
}

__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

UINT V42SetState(UINT ChnId){
    V42CDBSTRUCT *V42CDSP;
    ULONG ChnAddrOffset;

    ChnAddrOffset = ChnId*sizeof(V42CDBSTRUCT);
    V42CDSP = V42Chn0BaseAddress + ChnAddrOffset;

    msgId = mDATAMODESELECT;
    msgLen = 1;
    msgParams[0] = DATA_HDLC;
    V42SendMessageToDP(V42CDSP->ChnId,msgId,msgLen,msgParams);
    RESETDPBUFPTRS( );

    V42Data.state = V42_NEGOTIATION_STATE;

    return(1);
}

#endif

/******************************************************************************
 END OF FILE 
*******************************************************************************/
