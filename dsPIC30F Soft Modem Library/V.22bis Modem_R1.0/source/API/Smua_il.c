/*************************************************************************/
/* 
**  Filename:    SMUA.IL
**
**  Description:
**      This is the Application Program interface for invoking the data 
**      pump, V.42. The detailed API documents of DP, V.42 interface are 
**      provided.
*/
/***************************************************************************/

/*-------------------------------------------------------------------------
 INCLUDE FILES
--------------------------------------------------------------------------*/

#include "options.h"        //Header having the complie time options
#include "api_c.h"          //Header having the message structure definition
#include "codec_c.h"
#include "v42.h"
#include "v42api.h"
#include "atapi.h"
#include "smua_ol.h"
#include "p30f6014.h"

void SoftModemTask(void);

/*------------------------------------------------------------------------
 PREPROCESSOR CONSTANTS
-------------------------------------------------------------------------*/

#define MAXCHANNELS      1

#define TIMER_INACTIVE    0
#define TIMER_ACTIVE      1
#define TRUE              1
#define FALSE             0

#define PCMFRAMELEN      40   //Maximum PCM frame length 


/*------------------------------------------------------------------------
 PUBLIC VARIABLES DEFINITIONS
-------------------------------------------------------------------------*/

//============================================================================
   
 //PCM samples structure
 PCMDATASTRUCT Pcm[MAXCHANNELS];

 //To store messages/commands sent by the application to Data pump
 CHAR InMsgQue0[DP_IN_MSG_QSIZE];

 //To store responses sent by the data pump to the application
 CHAR OutMsgQue0[DP_OUT_MSG_QSIZE];

 //Structure that maintains the Queue having messages to data pump
 MSGQSTRUCT    InMsgQueStr[MAXCHANNELS];

 //Structure that maintains the Queue having responses from data pump
 MSGQSTRUCT    OutMsgQueStr[MAXCHANNELS]; 

 //pointers to in message queue structure
 MSGQSTRUCT *InMsgQPtr0;

 //pointers to out message queue structure
 MSGQSTRUCT *OutMsgQPtr0;

 //Message parameter structure
 MESSAGE MsgS;  

//============================================================================

  //Buffers used for Codec transmit and receive samples
 INT CodecTxBuffer[CODECBUFLEN];
 INT CodecRxBuffer[CODECBUFLEN];
 INT CodecTxRIndex;
 INT CodecTxWIndex; 
 INT CodecRxRIndex;
 INT CodecRxWIndex;
 INT CodecIntrCntr;

//Variable used for data pump configuration
 UCHAR DPTxLevel;
 UCHAR CPDetectDialTone;
 UCHAR CPDetectBusyTone;
 UCHAR DPConnectPeriod;
 UCHAR CPDialTonePeriod;
 UCHAR SMV42Enable;

//============================================================================

//Following variables are used in the process of operating the data pump and
//V.42

 //Flag to indicate the On Line Data Mode     
 CHAR    H_Mode;

 //Flag used to control the data flow between application and DP
 CHAR    iH_Xoff;

 CHAR    ModemMode;

 //Mode and bit rate selection
 UCHAR DPCnxMode,DPHSMode,ModulationMode;
 UINT DPCnxRate[2] , BitRate;

 UCHAR DPConnect;
 INT ModemSwitch;
 ULONG  Timer;
 UCHAR SMDisconnect;

//============================================================================

 //The following variables are used for call progress settings 
 //for the data pump 

 INT  ChnEnableCngTx;
 INT  ChnDetectRingBack;
 INT  ChnDetectReorderTone;
 CHAR ChnBusyOnTime1;
 CHAR ChnBusyOnTime2;       
 CHAR ChnBusyOffTime1;      
 CHAR ChnBusyOffTime2;      
 INT  ChnReorderOnTime;    
 INT  ChnReorderOffTime;   
 CHAR ChnRingOnTime1;       
 CHAR ChnRingOnTime2;
 CHAR ChnRingOffTime1;      
 CHAR ChnRingOffTime2;      
 CHAR  ChnResponse;
 UCHAR RingDetect;
 INT ClprgSpeakerVol;
 
 UCHAR  StartDial, DialEnd;
 UCHAR  DTMFString[20];

//============================================================================ 

#ifdef DEF_V42
V42CDBSTRUCT V42Cdb;
void *V42Chn0BaseAddress;  //V42 first channel(ORG) base address pointer

UINT MdmTimeout;
UINT MdmTimerStatus;
ULONG MdmTimeOutCount;
#endif

//============================================================================

//Data transmit and receive buffers
UCHAR TxDataBuf[24];
UCHAR RxDataBuf[130];

//============================================================================

/*-----------------------------------------------------------------------
API functions provided by the DATAPUMP algorithm
------------------------------------------------------------------------*/

extern void ModemChannelActivate(PCMDATASTRUCT *,MSGQSTRUCT *,MSGQSTRUCT *);

extern void ModemChannelProcess(PCMDATASTRUCT *,MSGQSTRUCT *,MSGQSTRUCT *);

extern UCHAR CheckRingTone(PCMDATASTRUCT *);

/*------------------------------------------------------------------------
Fucntion prototypes used in example API
-------------------------------------------------------------------------*/

/*************************************************************************/
void InitSoftModem(void);
void SetDefaultConfig(void);
void SaveDTMFDigits(UCHAR *);
void SetSMMode(UCHAR);
void SetSpeakerVolume(UCHAR);
void HangModem(void);

/*************************************************************************/

void ExecuteSoftModem(void);
void SetPointers(void);
void Configure_DP(INT);
void SendDataToDP(INT);
void ProcessMessages(INT,UINT,CHAR *);
void FindBitErrors(INT);
void ProcessDPResponses(INT);
void ModemSwitchFunction(INT);
void ResetCodecBuffers(void);
void ResetModemState(void);
void SendXoffMessage(void);
void SendXonMessage(void);
void Configure_Rate(void);
void UpdateMsgQue(INT,UCHAR *);  
void MdmTimerControl(UINT);
void DebugMsg(INT);

extern BlinkLed(void);

/*************************************************************************/

INT Get_SM_TransmitData(UCHAR *);
void Put_SM_ReceiveData(UCHAR *,INT);
void SoftModem_Connect(UCHAR,UCHAR,UINT);
UCHAR Poll_SMUA_OL_Status(void);

/*************************************************************************/
// This function is called by the upper layer of the soft modem user 
// application to configure the soft-modem. 
/*************************************************************************/

void Configure_SoftModem(SM_CONFIG *SM_Config_Params)
{                
    InitSoftModem();
    SetConfigParams(SM_Config_Params);
}

/*************************************************************************/
// This function is called by the upper layer to start soft-modem handshake
// This function returns only if there is a disconnection happened due to
// some reason 
/*************************************************************************/

UCHAR Start_SoftModem(void)
{
    ExecuteSoftModem();    
    return(SMDisconnect);
}

/*************************************************************************/
/*************************************************************************/

void InitSoftModem(void)
{

    Init_PORTS();             // initialize Ports
    Init_DCI();               // initialize DCI

    ResetModemState();

    ResetCodecBuffers();
    Init_Si3021();
    ResetCodecBuffers();

#ifdef DEF_V42
    V42InitBaseAddress((void *)&V42Cdb);
#endif

}

/*************************************************************************/
/*
**  Function Name:  ResetModemState
**
**  Input:          None
**
**  Return Value:   None
*/
/*************************************************************************/

void ResetModemState(void)
{
    
    SetDefaultConfig();

    //Initialize the pointers for PCM structure
    //and Message queues  
    
    SetPointers();

    DPConnect = 0;
    ModemSwitch = 0;
    ChnResponse = 0;
    H_Mode = OFFLINECMDMODE;
    RingDetect = 1;
    SMDisconnect = 0;

    //This function is provided by the data pump for initializing the
    //data pump variables

    ModemChannelActivate(&Pcm[0],InMsgQPtr0,OutMsgQPtr0); 

    ResetCodecBuffers();

}

/*************************************************************************/
/*
**  Function Name:  SetDefaultConfig
**
**  Input:          None
**
**  Return Value:   None
*/
/*************************************************************************/

void SetDefaultConfig(void)
{
    //Call progress configurable parameters

    CPDetectDialTone = 0;
    CPDetectBusyTone = 1;
    ChnEnableCngTx = 0;
    ChnDetectRingBack = 0;
    ChnDetectReorderTone = 0;

    ChnBusyOnTime1 = 0xF4;
    ChnBusyOnTime2 = 1;
    ChnBusyOffTime1 = 0xF4;
    ChnBusyOffTime2 = 1;

    ChnReorderOnTime = 250;
    ChnReorderOffTime = 250;

    ChnRingOnTime1 = 0xD0;
    ChnRingOnTime2 = 7;
    ChnRingOffTime1 = 0xA0;
    ChnRingOffTime2 = 0xF;

    //Default transmit Level = -12dBm
    DPTxLevel = 12;

    //DataPump default Configuration Parameters
    DPHSMode = 0;
    DPCnxRate[0] = 300;
    DPCnxRate[1] = 14400;

    DPConnectPeriod = 60;
    CPDialTonePeriod = 1;
}

/*************************************************************************/
/*
** Function Name : SetPointers
**
** Description :    The pointers to following Data Structures are initialized:
**                  PCM data structure
**                  In and Out Message Queues
**
** Inputs :     Void
**
** Outputs :    Void
**
*/
/*************************************************************************/

void SetPointers(void)
{
    Pcm[0].FrameLength = PCMFRAMELEN;

    //Pointer to IN and OUT message queues
    InMsgQPtr0 = &InMsgQueStr[0];
    OutMsgQPtr0 = &OutMsgQueStr[0];

    //Set the size of the message queue
    InMsgQueStr[0].Size = DP_IN_MSG_QSIZE;
    OutMsgQueStr[0].Size = DP_OUT_MSG_QSIZE;

    //Read and write pointers to In and Out message queues
    InMsgQueStr[0].Read = InMsgQueStr[0].Write = InMsgQueStr[0].BufPtr = 
    &InMsgQue0[0];
    
    OutMsgQueStr[0].Read = OutMsgQueStr[0].Write = OutMsgQueStr[0].BufPtr = 
    &OutMsgQue0[0];
}

SetConfigParams(SM_CONFIG *SM_Config_Params)
{
    DPTxLevel = SM_Config_Params->DPTxLevel;
    DPHSMode = SM_Config_Params->DPModMode;
    DPCnxRate[1] = SM_Config_Params->MaxCnxRate;
    Configure_DP(0);

    SetSpeakerVolume(SM_Config_Params->SpeakerVolume);
    SaveDTMFDigits(&SM_Config_Params->DialString[0]);
    SetSMMode(SM_Config_Params->SMMode);

    SMV42Enable = SM_Config_Params->V42Enable;
}

/*************************************************************************/
/*
** Function Name : Configure_DP
**
** Description :    This function configures the data pump for a specific
**                  mode by sending messages to the data pump.
**
** Inputs :     Void
**
** Outputs :    Void
**
*/
/*************************************************************************/

void Configure_DP(INT CHNID) {

    UCHAR MsgParams[2];

    //Configure data pump signal transmit level for -12dBm
    MsgS.Len = 1;                
    MsgS.Id = mSETTXLEVEL;
    MsgParams[0] = DPTxLevel;        
    UpdateMsgQue(CHNID,&MsgParams[0]);
 
    //Select the configured rate and mode for the data pump
    Configure_Rate(); 

   //Select the data transmission mode
    MsgS.Len = 2;                
    MsgS.Id = mDATAMODESELECT;
    MsgParams[0] = DATA_L2MSS;      //Extract/assemble transmit/receive bits
    MsgParams[1] = 1;
    UpdateMsgQue(CHNID,&MsgParams[0]);  

}

void Configure_Rate(void)
{
    UCHAR MsgParams[2];

    MsgS.Id = mHSMODESELECT;
    MsgS.Len = 1;
    MsgParams[0] = DPHSMode;
    UpdateMsgQue(0,&MsgParams[0]); 

    //Select the bit rate for the configured mode
    //DPCnxRate = 0 - Maximum possible rate for selected mode
    //          = 1 - Next lower rate 

    MsgS.Len = 1;                
    MsgS.Id = mRATESELECT;

    if(DPHSMode <=(ENABLE_V8+ENABLE_V32BIS))
    {
        DPCnxMode = 16;
        if(DPCnxRate[1] >= 14400)
        {
            MsgParams[0] = 0;
        }
        else if (DPCnxRate[1] >= 12000)
        {
            MsgParams[0] = 1;            
        }
        else if (DPCnxRate[1] >= 9600)
        {
            MsgParams[0] = 2;
        }
        else if (DPCnxRate[1] >= 7200)
        {
            MsgParams[0] = 3;
        }
        else if (DPCnxRate[1] >= 4800)
        {
            MsgParams[0] = 4;
        }
        else if (DPCnxRate[1] >= 2400)
        {
            MsgParams[0] = 0;
        }
        else if (DPCnxRate[1] >= 1200)
        {
            MsgParams[0] = 1;
        }

    }

    else if(DPHSMode <=(ENABLE_V8+ENABLE_V32))
    {
        DPCnxMode = 16;
        if(DPCnxRate[1] >= 9600)
        {
            MsgParams[0] = 0;
        }
        else
        {
            MsgParams[0] = 1;            
        }
    }

    else if ( (DPHSMode > (ENABLE_V8+ENABLE_V32)) && (DPHSMode <= (ENABLE_V8+ENABLE_V22)) )
    {
        DPCnxMode = 18;
        if(DPCnxRate[1] >= 2400)
        {
            MsgParams[0] = 0;            
        }
        else
            MsgParams[0] = 1;            
    }
    else if ( (DPHSMode > (ENABLE_V8+ENABLE_V22)) && (DPHSMode <= (ENABLE_V8+ENABLE_V21)) )
    {
	        DPCnxMode = 21;
            MsgParams[0] = 0;            
    }
    else if(DPHSMode == ENABLE_B103)
    {
	        DPCnxMode = 22;
            MsgParams[0] = 0;            
    }
    else 
    {
	        DPCnxMode = 20;
            if(DPCnxRate[1] >= 1200)
                MsgParams[0] = 0;            
            else
                MsgParams[0] = 1;                        
    }
    
    UpdateMsgQue(0,&MsgParams[0]);  

}

void SetSpeakerVolume(UCHAR VolumeLevel)
{
    if(VolumeLevel == 0)
    {
        ClprgSpeakerVol = 0x60;
    }
    if(VolumeLevel == 1)
    {
        ClprgSpeakerVol = 0x03;
    }
    if(VolumeLevel == 2)
    {
        ClprgSpeakerVol = 0x63;
    }
    if(VolumeLevel == 3)
    {
         ClprgSpeakerVol = 0x00;
    }	    
}

void SaveDTMFDigits(UCHAR *DialString)
{
    INT i;

    for(i=0;i<DialString[0]+1;i++)
    {
        DTMFString[i] = DialString[i];
    }
}

void SetSMMode(UCHAR SMMode)
{
    if(SMMode == 0)
    {
        ModemSwitch = 9;
    }
    else if(SMMode == 1)
    {
        ModemSwitch = 1;
    }
    else if(SMMode == 2)
    {
        RingDetect = 0;
    }
    else ModemSwitch = 0;
}


/*************************************************************************/
/*************************************************************************/

void ExecuteSoftModem(void)
{
    INT i=0,Status;
    UINT DPMsgParams[1];
	LONG TimeOut = 0;

    while(1)
    {
        //Wait for frame length time to collect 
        //required number of samples        
		while( CodecIntrCntr < Pcm[0].FrameLength );
		 	
		/* reset frame byte counter */ 		
        CodecIntrCntr = 0;

		/* Poll SMUA_OL to see if user application desires to terminate call */
        Status = Poll_SMUA_OL_Status();
        
        /* If callback function returns 1 then terminate call */
        if(Status) HangModem();

        if(SMDisconnect) break;

#ifdef DEF_V42
        MdmTimerControl(0);
#endif

        //In data mode send data bytes collected from the upper layer
        //to the data pump/V.42
        if (H_Mode == ONLINEDATAMODE)
           SendDataToDP(0);

        Pcm[0].IN = &CodecRxBuffer[CodecRxRIndex];
        Pcm[0].OUT = &CodecTxBuffer[CodecTxWIndex];

        CodecRxRIndex += Pcm[0].FrameLength;
        if(CodecRxRIndex >= CODECBUFLEN) CodecRxRIndex = 0;

        //Execute the ring detection procedure to get into
        //answer mode after ring detection

        if(!RingDetect)
        {
            Status = CheckRingTone(&Pcm[0]);
            if(Status)
            {
                RingDetect = 1;
                ModemSwitch = 7;
            }
        }

        //Execute the DTMF transmission procedure for dialing

        if(StartDial)
        {
            Status = DTMFGen(Pcm[0].OUT);
            if(Status == DTMFEND) 
            {
                StartDial = 0;
                DialEnd = 1;
            }
        }
        else
        {        
            //Invoke the data pump PCM frame processing
            //must be called every frame
            ModemChannelProcess(&Pcm[0],InMsgQPtr0,OutMsgQPtr0);
        }

        //Copy the data pump transmit samples into the codec
        //transmit buffer
        for (i=0;i<Pcm[0].FrameLength;i++) {
            CodecTxBuffer[CodecTxWIndex++] = (Pcm[0].OUT[i] & 0xfffe);
            if(CodecTxWIndex >= CODECBUFLEN)
                   	CodecTxWIndex = 0;
	        }

        //Process any messages sent by the data pump and send them
        //to V.42 if V.42 is enabled
        ProcessDPResponses(0);

        ModemSwitchFunction(0);         
    }
}


/*************************************************************************/
/*
**  Function Name:  ModemSwitchFunction
**
**  Input:          Chn ID
**
**  Return Value:   None
*/
/*************************************************************************/

void ModemSwitchFunction(CHNID) {
    INT ch;
    UCHAR MsgParams[11];
    UINT DPMsgParams[1];
    
    if(Timer>0)
    Timer -= 40;

    switch(ModemSwitch) {

        case 0:        
                break;
            
        case 1:
              
                go_off_hook(ClprgSpeakerVol);
                ResetCodecBuffers();         
                RingDetect = 1;              

                MsgParams[0]=(ChnEnableCngTx << 3);
                MsgParams[0]|=(ChnDetectRingBack <<2);
                MsgParams[0]|=(ChnDetectReorderTone<<1);
                MsgParams[0]|= CPDetectBusyTone;
         
                MsgS.Id = mCLPRGSELECT;
                MsgS.Len = 1;
                UpdateMsgQue(CHNID,&MsgParams[0]);
         
                MsgParams[0] = ChnBusyOnTime1;
                MsgParams[1] = ChnBusyOnTime2;
                MsgParams[2] = ChnBusyOffTime1;
                MsgParams[3] = ChnBusyOffTime2;
                MsgParams[4] = ChnReorderOnTime;
                MsgParams[5] = ChnReorderOffTime;
                MsgParams[6] = ChnRingOnTime1;
                MsgParams[7] = ChnRingOnTime2;
                MsgParams[8] = ChnRingOffTime1;
                MsgParams[9] = ChnRingOffTime2;
                MsgParams[10] = 1;
         
                MsgS.Id = mCLPRGTONECADENCE;
                MsgS.Len = 11;
                UpdateMsgQue(CHNID,&MsgParams[0]);
    
                if(CPDetectDialTone == 0)
                {
                    ModemSwitch = 2;
                    break;
                }
         
                MsgS.Id = mDETECTDIALTONE;
                MsgS.Len = 0;
                UpdateMsgQue(CHNID,&MsgParams[0]);
         
                ChnResponse = mGOTDIALTONE;
                Timer = CPDialTonePeriod * 8000;
                ModemSwitch = 2;                  
                break; 

        case 2:
  
                if(CPDetectDialTone)
                {
                    if(ChnResponse)
                    {
                        if(Timer<=0)
                        {
                            ResetModemState();
                            go_on_hook();
                            SMDisconnect = NO_DIAL_TONE;
                            return;
                        }
                        else
                            break;
                    }     
                }

                StartDial = 1;
                InitDTMFGen(&DTMFString[1],DTMFString[0]);
                ResetCodecBuffers();
                H_Mode = ONLINEMODE;
                ModemSwitch = 5;
                break;  
        
        case 3:
                ModemSwitch = 4;                  
                break; 

        case 4:
                ModemSwitch = 5;

                MsgS.Len = 0;                
                MsgS.Id = mORIGINATE;
                UpdateMsgQue(CHNID,&MsgParams[0]);
                break;  
        case 5:
                
                if(!DialEnd) break;
                ModemMode = 1;
                MsgS.Len = 0;
                MsgS.Id = mORIGINATE;
    
                UpdateMsgQue(CHNID,&MsgParams[0]);

                ModemSwitch = 6;
                Timer = DPConnectPeriod * 8000L;
                ChnResponse = mCONNECT;
               
                break;
                
        case 6:
                if(Timer <= 0) 
                {
                    ResetModemState();
                    go_on_hook();
                    SMDisconnect = CONNECTION_TIMEOUT;
                    break;                  
                }
                if(ChnResponse) break;
                
                ModemSwitch = 10;
                break;

        case 7:
                go_off_hook(ClprgSpeakerVol);
      
                MsgS.Len = 0;
                MsgS.Id = mANSWER;
                UpdateMsgQue(CHNID,&MsgParams[0]);
                ModemSwitch = 6;
                ModemMode = 0;
      
                H_Mode = ONLINEMODE;

                Timer = DPConnectPeriod * 8000;
                ChnResponse = mCONNECT;
                ResetCodecBuffers();        
                break;                  
        case 8:
                if(ChnResponse) break;
                go_on_hook();
                ResetModemState();
                SetFS8000();    
                SMDisconnect = HANGUP_COMPLETE;
                break;                

        case 9:
                MsgS.Len = 1;                
                MsgS.Id = mMODESELECT;            
                MsgParams[0] = DPCnxMode;        
                UpdateMsgQue(CHNID,&MsgParams[0]);

                MsgS.Len = 0;                
                MsgS.Id = mLOOPBACK;
                UpdateMsgQue(CHNID,&MsgParams[0]);
                go_off_hook(ClprgSpeakerVol);            
                start_si3021_loopback();
                ResetCodecBuffers();

                ModemSwitch = 10;
                break;
        case 10:
                break;
    }
}

/*************************************************************************/
/*
**  Function Name:  UpdateMsgQue
**
**  Description :   Whenever a message is available, it is put in the DP In 
**                  Message Queue. DP in message queue will operate on
**                  circular basis    
**
**  Input:          None
**
**  Return Value:   None
*/
/*************************************************************************/

void UpdateMsgQue(INT ID,UCHAR *MsgParams){

    CHAR *Ptr;
    INT i;

    Ptr = InMsgQueStr[ID].Write;
        *Ptr++ = MsgS.Id;
    if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;
    *Ptr++ = MsgS.Len;
    if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;
    InMsgQueStr[ID].Write += 2 + MsgS.Len;

    if (MsgS.Len) {
        for (i=0; i< MsgS.Len; i++) {
            *Ptr++ = MsgParams[i];
            if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;
        }
    }
    if (InMsgQueStr[ID].Write >= (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size))
        InMsgQueStr[ID].Write -= InMsgQueStr[ID].Size;


}

/**************************************************************************/
/*
** Function Name :  SendDataToDP
**
** Description   :  This function is used to send the data to DP for modulation
**
** Inputs :         None
**
** Outputs :        None
*/
/*************************************************************************/

void SendDataToDP(INT ID) {

    CHAR status,i,TxByte;
    CHAR *Ptr;
    INT Len;

    if (!iH_Xoff) 
    {
		status = Get_SM_TransmitData(TxDataBuf);
        if(!status) return;
        
        //For the DP_STANDALONE mode send the data to DP directly through
        //the message mDATATODP

#ifdef DEF_V42
        iH_Xoff = 1;
        V42SendData(0,TxDataBuf,status);
#else    

        Ptr = InMsgQueStr[ID].Write;

        *Ptr++ = mDATATODP;
        if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;

        *Ptr++ = status;
        if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;
        
        InMsgQueStr[ID].Write += 2 + status;

        for (i=0; i< status; i++) 
        {
            *Ptr++ = TxDataBuf[i];
            if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;
        }

        if (InMsgQueStr[ID].Write >= (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size))
        InMsgQueStr[ID].Write -= InMsgQueStr[ID].Size;
#endif

    }
}

/**************************************************************************/
/*
**  Function Name: ProcessDPResponses 
**
**  Description :
**                Get messages from the datapump and put them in the message 
**                parameter buffer. Read/analyse the messages.
**
**  Inputs:     None
**
**  Outputs:    None
*/
/*************************************************************************/

void ProcessDPResponses(INT ID) {
    CHAR *Ptr;
    INT i;
    UCHAR MsgParams[20];

    while(1) {
        if (OutMsgQueStr[ID].Write == OutMsgQueStr[ID].Read) return;
        Ptr = OutMsgQueStr[ID].Read;
        MsgS.Id = *Ptr++;
        if (Ptr == (OutMsgQueStr[ID].BufPtr+OutMsgQueStr[ID].Size)) Ptr = OutMsgQueStr[ID].BufPtr;
        MsgS.Len = *Ptr++;
        if (Ptr == (OutMsgQueStr[ID].BufPtr+OutMsgQueStr[ID].Size)) Ptr = OutMsgQueStr[ID].BufPtr;

        OutMsgQueStr[ID].Read += 2 + MsgS.Len;

        if (OutMsgQueStr[ID].Read >= (OutMsgQueStr[ID].BufPtr+OutMsgQueStr[ID].Size))
            OutMsgQueStr[ID].Read -= OutMsgQueStr[ID].Size;

#ifdef DEF_V42
        if(DPConnect)
        {
            for(i=0;i<MsgS.Len;i++)
            {
                 MsgParams[i] = *Ptr++;
                 if (Ptr == (OutMsgQueStr[ID].BufPtr+OutMsgQueStr[ID].Size)) Ptr = OutMsgQueStr[ID].BufPtr;
            }
            V42ProcessDPMessage(ID,(UCHAR *)&MsgS,&MsgParams[0]);
            continue;
        }        
#endif

        ProcessMessages(ID,MsgS.Id,Ptr);

    }

}


/**************************************************************************/
/*
**  Function Name:  ProcessMessages 
**
**  Description :   Analyze the message and set the relevant flags. This 
**                    message processing is called only during Non-V.42 Mode.
**
**  Inputs:         Message ID
**
**  Outputs:        None
**
*/
/*************************************************************************/

void ProcessMessages(INT ID,UINT MessageID,CHAR *Ptr){

    unsigned int status,val,i,msgbyte,ch;
    UCHAR MsgParams[2];
    UINT DPMsgParams[2];

    if(MessageID == ChnResponse) ChnResponse = 0;

    //mDATATOHOST:  Copy the demodulated data to the OutDataBuf and find the
    //errors in the received bits
    
    if(MessageID == mDATATOHOST)        
    {
        for(i=0;i<MsgS.Len;i++) 
        {
            RxDataBuf[i] = *Ptr++;
            if (Ptr == (OutMsgQueStr[ID].BufPtr+OutMsgQueStr[ID].Size)) Ptr = OutMsgQueStr[ID].BufPtr;
        }

        Put_SM_ReceiveData(RxDataBuf,MsgS.Len);       
        return;
    }

    for(i=0;i<MsgS.Len;i++)
    {
        MsgParams[i] = *Ptr++;
        if (Ptr == (OutMsgQueStr[ID].BufPtr+OutMsgQueStr[ID].Size)) Ptr = OutMsgQueStr[ID].BufPtr;
    }
        
    //mCONNECT: Indicates the data pump connection establishment.

    if(MessageID == mCONNECT)
    {

        DPConnect++;
        ModulationMode = MsgParams[0];

        if(MsgParams[0]== V32BIS_MODE)
        {
            if(MsgParams[1] == 0)
                BitRate = 14400;
            if(MsgParams[1] == 1)
                BitRate = 12000;
            if(MsgParams[1] == 2)
                BitRate = 9600;
            if(MsgParams[1] == 3)
                BitRate = 7200;
            if(MsgParams[1] == 4)
                BitRate = 4800;
        }
        if(MsgParams[0]== V22BIS_MODE)
        {
            if(MsgParams[1] == 1)
                BitRate = 2400;
            else BitRate = 1200;                
        }

        if(MsgParams[0]== V23_MODE)
        {
            if(!ModemMode)
                BitRate = 120;
            else 
            {
                BitRate = 75;                
            }
            SMV42Enable = 0;
        }

        if((MsgParams[0]== V21_MODE) || (MsgParams[0]== B103_MODE))
        {
            BitRate = 300;
            SMV42Enable = 0;
        }

#ifdef DEF_V42

        V42OpenChannel(ID);

        if(!ModemMode)
        {
            V42Control(ID,ANSWER_MODEM,0,(UINT *)MsgParams);
        }
        else
            V42Control(ID,ORIGINATE_MODEM,0,(UINT *)MsgParams);

        if(SMV42Enable==0)
            V42ConfigParameters(ID, V42DISABLE,(UINT *)MsgParams);

        V42ProcessDPMessage(ID,(UCHAR *)&MsgS,&MsgParams[0]);

#else
        iH_Xoff = 0;
        H_Mode = ONLINEDATAMODE;
        SoftModem_Connect(DP_CONNECT,ModulationMode,BitRate);
#endif
        speaker_off();
        return;
    }
    
    if(MessageID == mDEBUGINFO)
    {
        return;
    }
    
    if(MessageID == mXOFF)
    {
        SendXoffMessage();
    }

    if(MessageID == mXON)
    {
        SendXonMessage();
    }

    if(MessageID == mLOCALRETRAIN) return;
    if(MessageID == mREMOTERETRAIN) return;
    if(MessageID == mNOCARRIER)
    {
        go_on_hook();
        ResetModemState();         
        SetFS8000();    
        SMDisconnect = LOST_REMOTE_CARRIER;
        return;
    } 
    if(MessageID == mMODEMREADY) return;
    if(MessageID == mCHANGEBUFLEN) return;
    if(MessageID ==  mHANGUPCOMPLETE)
    {
        ChnResponse = 0;
        return;
    }
  
    if(MessageID ==mCLPRGRESP )
    {
        if (MsgParams[0] == mGOTDIALTONE) 
        {
            ChnResponse = 0;
        }
        else if(MsgParams[0] == mGOTBUSYTONE)
        {
            go_on_hook();
            ResetModemState();         
            ChnResponse = 0;
            SMDisconnect = DETECT_BUSY_TONE;
        }
        else if(MsgParams[0] == mGOTREORDERTONE)
        {
            ChnResponse = 0;
        }
        else if(MsgParams[0] == mGOTRINGBACK)
        {
            ChnResponse = 0;
        }
        else return;   
    }     

   if(MessageID ==mSELECTSMPRATE )
   {
        SetFS7200();
        return;
   }   

   else return;    
}


void ResetCodecBuffers(void)
{
    INT i;
    
    for(i=0;i<CODECBUFLEN;i++)
    {
        CodecTxBuffer[i] = 0;
        CodecRxBuffer[i] = 0;
    }

    CodecRxWIndex = CodecTxWIndex = Pcm[0].FrameLength;
    CodecRxRIndex = CodecTxRIndex = 0;
    CodecIntrCntr = Pcm[0].FrameLength;
}


void SendXoffMessage(void)
{
    iH_Xoff = 1;
    return;
}

void SendXonMessage(void)
{
    iH_Xoff = 0;
    return;
}

void HangModem(void)
{
    UCHAR MsgParams[2];
#ifdef DEF_V42
    V42Control(0,V42_L_RELEASE,0,(UINT *)&MsgParams[0]);
#else
    MsgS.Id = mHANGUP;
    MsgS.Len = 0;
    UpdateMsgQue(0,&MsgParams[0]);

    ModemSwitch = 8;
    ChnResponse = mHANGUPCOMPLETE;
#endif
}


//Following functions are used by V42 layer as import functions

#ifdef DEF_V42

/**************************************************************************/
/*
**  Description :   Save the received data frame from V42 in a buffer
**
*/
/*************************************************************************/

UINT V42ReceiveData(UINT ID,UCHAR *Data,UINT LEN){
    INT i;

    for(i=0;i< LEN ;i++) 
    {
        RxDataBuf[i] = *Data++;
    }
    Put_SM_ReceiveData(RxDataBuf,LEN);

    return(LEN-i);
}

/**************************************************************************/
/*
**  Description :   Switch off the V42 event timer
**
*/
/*************************************************************************/

void V42ReleaseTimer1(UINT ID)
{
    MdmTimeout = FALSE;
    MdmTimerStatus = TIMER_INACTIVE;
    MdmTimeOutCount=0;
}

/**************************************************************************/
/*
**  Description :   Update the event timer and execute the timeout event if
**                  timeout occurs
**
*/
/*************************************************************************/

void MdmTimerControl(UINT ID)
{
    if(MdmTimerStatus == TIMER_ACTIVE)
    {
        MdmTimeOutCount--;
        if(!MdmTimeOutCount ){
            MdmTimeout = TRUE;
            MdmTimerStatus = TIMER_INACTIVE;
            V42ExecuteTimeOut1(ID);
        }
    }

}

/**************************************************************************/
/*
**  Description :   Setup the event timer
**
*/
/*************************************************************************/

void V42SetupTimer1(UINT ID,ULONG Tout_Period)
{
    MdmTimerStatus = TIMER_ACTIVE;
    MdmTimeout = FALSE;
    MdmTimeOutCount = (ULONG)Tout_Period >> 2;
}

/**************************************************************************/
/*
**  Description :   This function is used to send the message received from 
**                  V42 to DP layer
**
*/
/*************************************************************************/

void V42SendMessageToDP(UINT ID,UCHAR MSG_ID,UINT LEN,UCHAR *PARM){
    UINT i;
    CHAR *Ptr;

    Ptr = InMsgQueStr[ID].Write;

    *Ptr++ = MSG_ID;
    if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;

    *Ptr++ = LEN;
    if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;

    InMsgQueStr[ID].Write += 2 + LEN;

    for(i=0;i<LEN;i++){
        *Ptr++ = *PARM++;
        if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;
    }

    if (InMsgQueStr[ID].Write >= (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size))
    InMsgQueStr[ID].Write -= InMsgQueStr[ID].Size;
}

/**************************************************************************/
/*
**  Description :   This function is called by V42 layer to indicate the
**                  V42 processing status
**
*/
/*************************************************************************/

void V42IndicateStatus(UINT ID,UINT STATUS_ID,UINT LEN,UCHAR *PARM){
    INT status;
    UINT DPMsgParams[1];

    switch(STATUS_ID){

    case V42_READY_FOR_DATA:
            iH_Xoff = 0;
            break;

    case ASYNC_CONNECT:
            SoftModem_Connect(NON_LAPM_CONNECT,ModulationMode,BitRate);
            H_Mode = ONLINEDATAMODE;
            iH_Xoff = 0;
            break;

    case V42_CONNECT:
            SoftModem_Connect(LAPM_CONNECT,ModulationMode,BitRate);
            H_Mode = ONLINEDATAMODE;
            iH_Xoff = 0;
            break;

    case V42_RETRAIN_CONNECT:
            SoftModem_Connect(RETRAIN_CONNECT,ModulationMode,BitRate);
            H_Mode = ONLINEDATAMODE;
            iH_Xoff = 0;
            break;

    case L_RELEASED:
           go_on_hook();
           ResetModemState();         
           SetFS8000();    
           SMDisconnect = HANGUP_COMPLETE;
           break;

    case DP_LOST_CARRIER:
           go_on_hook();
           ResetModemState();         
           SetFS8000();    
           SMDisconnect = LOST_REMOTE_CARRIER;
           break; 

    case REMOTE_V42_DISCONNECT:
           go_on_hook();
           ResetModemState();         
           SetFS8000();    
           SMDisconnect = REM_V42_DISCONNECT;
           break;

    case V42_PROTO_ERROR:
           go_on_hook();
           ResetModemState();         
           SetFS8000();    
           SMDisconnect = V42_PROTOCOL_ERROR;     
           break;

    case DP_RETRAIN_STATUS:
           iH_Xoff = 1;
           SendXoffMessage();            
           break;
            
    case V42_NEGOTIATION_STATUS:
           break;
            
    case V42_ANS_ODP_DETECT:
           break;

    case DP_XOFF_STATUS:
           SendXoffMessage();           
           break;

    case DP_XON_STATUS:
           SendXonMessage();           
           break;

      default:
           break;
    }
}

#endif



/*--------------------------------------------------------------------
             END OF FILE
---------------------------------------------------------------------*/
