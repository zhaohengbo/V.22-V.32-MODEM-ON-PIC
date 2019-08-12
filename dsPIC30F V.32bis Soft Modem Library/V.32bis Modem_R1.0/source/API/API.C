/*************************************************************************/
/* 
**  Filename:    API.C
**
**  Description:
**      This is the Application Program interface for invoking the data 
**      pump, V.42 and AT commands. The detailed API documents of DP, V.42
**      and AP command interface are provided.
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
#include "lcd.h"


#ifdef DEF_AT
#include "AT_cmds.h"
#endif

#ifdef DEF_RTOS
#include "csfunc.h"
#endif

void SoftModemTask(void);

/*------------------------------------------------------------------------
 PREPROCESSOR CONSTANTS
-------------------------------------------------------------------------*/

#define MAXCHANNELS      1
#define XOF_DC3             19
#define XON_DC1             17

#define TIMER_INACTIVE    0
#define TIMER_ACTIVE      1
#define TRUE              1
#define FALSE             0

//Length of the buffer used to store the data to be sent to DP for modulation
#define INDATABUFLEN     128     
                                    
//Length of the buffer used to store the Received data
#define OUTDATABUFLEN    128 

#define PCMFRAMELEN      40   //Maximum PCM frame length 


#ifdef DEF_RTOS

#define SM_TASK_ROM_TCB_ID     0x01
#define SM_CODEC_EVENT         0x01
#define C_INTERRUPT_SIZE       64

#endif
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

 ATMSGQSTRUCT    ATInMsgQueStr[MAXCHANNELS];
 ATMSGQSTRUCT    *ATInMsgQPtr0;

//============================================================================

  //Buffers used for Codec transmit and receive samples
 INT CodecTxBuffer[CODECBUFLEN];
 INT CodecRxBuffer[CODECBUFLEN];
 INT CodecTxRIndex;
 INT CodecTxWIndex; 
 INT CodecRxRIndex;
 INT CodecRxWIndex;
 INT CodecIntrCntr;

//============================================================================

 //Buffer used to store the data to be sent to data pump for modulation
 CHAR InDataBuf[INDATABUFLEN];

 //Buffer used to store the data received
 CHAR OutDataBuf[OUTDATABUFLEN];

 //Read and write indices for the InDataBuf and OutDataBuf    
 UCHAR    InDataW;
 UCHAR    OutDataW,OutDataR;
INT HostXoffLimit,HostXonLimit;
//============================================================================

//Variable used for data pump configuration

 UCHAR DPTxLevel;
 UCHAR CPDetectDialTone;
 UCHAR CPDetectBusyTone;
 UCHAR CPDialTonePeroid;
 UCHAR DPConnectPeriod;
 UCHAR SMV42Enable;
 UCHAR SMFlowControl;

//============================================================================

//Following variables are used in the process of operating the data pump and
//V.42

 //Flag to indicate the On Line Data Mode     
 CHAR    H_Mode;

 //Flag used to control the data flow between application and DP
 CHAR    iH_Xoff;
 CHAR    DTEXoff;

 CHAR    ModemMode;

 //Mode and bit rate selection
 CHAR DPCnxMode,DPHSMode;
 INT DPCnxRate[2] , BitRate;

 UCHAR DPConnect;
 CHAR BytesPerFrame;
 INT ModemSwitch;

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
 
 ULONG  Timer;
 UCHAR  StartDial, DialEnd;
 UCHAR  DTMFString[20];

 UCHAR DebugBuffer[100];
 INT DebugIndex;
 
//============================================================================

#ifdef DEF_AT
 AT_COMMAND ATcmd;
 UCHAR ATEscapeSeq = 0;
#endif

 UCHAR UARTTxEmpty;
//============================================================================

#ifdef DEF_V42
V42CDBSTRUCT V42Cdb;
void *V42Chn0BaseAddress;  //V42 first channel(ORG) base address pointer

UINT MdmTimeout;
UINT MdmTimerStatus;
ULONG MdmTimeOutCount;
UCHAR Buf[24];
#endif

#ifdef DEF_RTOS
struct 
{
    INT interrupt_bytes[C_INTERRUPT_SIZE / 2];
} int_storage;

word16 SM_Task_Stack[110];    

ROM_TCB task_rom_list[] =
{
    K_I_Timer_Task,0,0,
    SoftModemTask,&SM_Task_Stack[0],5,
};
#endif

//============================================================================

 //The following variables are used for bit error calculations and throughput
 //calculation

 LONG RxBitErrors;
 LONG RxBitCount;
 LONG RxByteCount;
 LONG RxByteErrors;
 LONG RxBitCountSet; 

 LONG TimeFrameCount;
 INT  StartLog=0;
 INT  EnableLog;
 LONG BERLimit=100000L;
 LONG BytesLogged;

#ifdef DEF_LCD_MSGS
const char package_name[] = "  V.32bis Demo  ";
const char package_version[] = " AT Command API ";
#endif

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
void SendXonToDTE(void);
void SendXoffToDTE(void);
void Configure_Rate(void);
void UpdateMsgQue(INT,UCHAR *);  
void MdmTimerControl(UINT);
void CheckFlowControl(void);
void SetRTS(void);
void ClearRTS(void);
void DebugMsg(INT);

/*---------------------------------------------------------------------
            MAIN PROGRAM
----------------------------------------------------------------------*/

/*************************************************************************/
/*************************************************************************/

#ifdef DEF_RTOS
void SoftModemTask(void)
{
    UCHAR events;
    while(1)
    {
        events = K_Event_Wait (SM_CODEC_EVENT, 0, 2);
        CodecIntrCntr =0;
        ExecuteSoftModem();
    }
    
    K_Task_End();
}
#endif

/*************************************************************************/
/*************************************************************************/

void InitSoftModem(void)
{

    Init_PORTS();             // initialize Ports
    Init_DCI();               // initialize DCI

#ifdef DEF_LCD_MSGS
//    InitDebugMsg(); 
    Init_LCD();               // initialize LCD
    home_clr();
    puts_lcd( ( char * ) &package_name[0], (sizeof(package_name)) - 1 );
    line_2();
    puts_lcd( ( char * ) &package_version[0], (sizeof(package_version)) - 1 );
#endif

    ResetModemState();

    ResetCodecBuffers();
    Init_Si3021();
    ResetCodecBuffers();
    
#ifdef DEF_AT
    ATInitBaseAddress((void *)&ATcmd);
    InitATCommands();
    Init_Uart1();
#endif

#ifdef DEF_V42
    V42InitBaseAddress((void *)&V42Cdb);
#endif

}

/*************************************************************************/
/*************************************************************************/

#ifdef DEF_RTOS
void ExecuteSoftModem(void)
{
    INT i=0,Status;
    UINT DPMsgParams[1];

#ifdef DEF_AT
    //Invoke the AT command processing every frame 
    ATInMsgQueStr[0].Write = &InDataBuf[InDataW];
    ProcessATCommands(ATInMsgQPtr0,H_Mode);
#endif

#ifdef DEF_V42
        MdmTimerControl(0);
#endif

    //In data mode send data bytes collected from the upper layer
    //to the data pump/V.42
    if (H_Mode == ONLINEDATAMODE)
    {
        SendDataToDP(0);
    }

    Pcm[0].IN = &CodecRxBuffer[CodecRxRIndex];
    Pcm[0].OUT = &CodecTxBuffer[CodecTxWIndex];

    CodecRxRIndex += Pcm[0].FrameLength;
    if(CodecRxRIndex >= CODECBUFLEN) CodecRxRIndex = 0;

    //Execute the ring detection procedure to get into
    //answer mode after ring detection

    if(!RingDetect)
    {
        Status = CheckRingTone(&Pcm[0]);
#ifdef DEF_AT
        if(Status)
        {
            DPMsgParams[0] = COMRING;
            DPIndicateStatus(DP_CP_STATUS,DPMsgParams);
        }
#endif
    }

    //Execute the DTMF transmission procedure for dialling

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
        if(StartLog>0)
        {
            TimeFrameCount++;
        }   

        //Invoke the data pump PCM frame processing
        ModemChannelProcess(&Pcm[0],InMsgQPtr0,OutMsgQPtr0);
    }

    //Copy the data pump transmit samples into the codec
    //transmit buffer

    for (i=0;i<Pcm[0].FrameLength;i++) {
        CodecTxBuffer[CodecTxWIndex++] = (Pcm[0].OUT[i] & 0xfffe);
        if(CodecTxWIndex >= CODECBUFLEN) CodecTxWIndex = 0;
    }

    //Process any messages sent by the data pump and send them
    //to V.42 if V.42 is enabled
    ProcessDPResponses(0);

    ModemSwitchFunction(0);         

}
#else
void ExecuteSoftModem(void)
{
    INT i=0,Status;
    UINT DPMsgParams[1];

    while(1)
    {

        //Wait for frame length time to collect 
        //required number of samples        

        while(CodecIntrCntr < Pcm[0].FrameLength);
        CodecIntrCntr = 0;

#ifdef DEF_AT
        //Invoke the AT command processing every frame 
        ATInMsgQueStr[0].Write = &InDataBuf[InDataW];
        ProcessATCommands(ATInMsgQPtr0,H_Mode);
#endif

#ifdef DEF_V42
        MdmTimerControl(0);
#endif

        //In data mode send data bytes collected from the upper layer
        //to the data pump/V.42
        if (H_Mode == ONLINEDATAMODE)
        {
            SendDataToDP(0);
        }

        Pcm[0].IN = &CodecRxBuffer[CodecRxRIndex];
        Pcm[0].OUT = &CodecTxBuffer[CodecTxWIndex];

        CodecRxRIndex += Pcm[0].FrameLength;
        if(CodecRxRIndex >= CODECBUFLEN) CodecRxRIndex = 0;

        //Execute the ring detection procedure to get into
        //answer mode after ring detection

        if(!RingDetect)
        {
            Status = CheckRingTone(&Pcm[0]);
#ifdef DEF_AT
            if(Status)
            {
                DPMsgParams[0] = COMRING;
                DPIndicateStatus(DP_CP_STATUS,DPMsgParams);
            }
#endif
        }

        //Execute the DTMF transmission procedure for dialling

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

            if(StartLog>0)
            {
                TimeFrameCount++;
            }   

            //Invoke the data pump PCM frame processing
            ModemChannelProcess(&Pcm[0],InMsgQPtr0,OutMsgQPtr0);
        }

        //Copy the data pump transmit samples into the codec
        //transmit buffer

        for (i=0;i<Pcm[0].FrameLength;i++) {
            CodecTxBuffer[CodecTxWIndex++] = (Pcm[0].OUT[i] & 0xfffe);
            if(CodecTxWIndex >= CODECBUFLEN) CodecTxWIndex = 0;
        }

        //Process any messages sent by the data pump and send them
        //to V.42 if V.42 is enabled
        ProcessDPResponses(0);

        ModemSwitchFunction(0);         
        DebugBuffer[DebugIndex++] = CodecIntrCntr;
        if(DebugIndex == 100) DebugIndex = 0;

    }
}
#endif

/*************************************************************************/
/*************************************************************************/


/*************************************************************************/
/*
** Function Name : main
**
** Description : Entry point of the code.
**
*/
/*************************************************************************/
                    
INT main(void)
{                

    INT i=0,Sample,Status;

#ifdef DEF_RTOS
    K_OS_Init();
    Status = K_Task_Create(SM_TASK_ROM_TCB_ID);
    if(Status == K_ERROR)
    {
        return;
    }
#endif

    InitSoftModem();
        
#ifdef DEF_RTOS
    Status = K_Task_Start(SM_TASK_ROM_TCB_ID);
    if(Status == K_ERROR)
    {
        return;
    }

    K_OS_Start();
#else
    ExecuteSoftModem();
#endif

}  //MAIN END

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

#ifdef DEF_AT
    ATInMsgQPtr0 = &ATInMsgQueStr[0];
    ATInMsgQueStr[0].Size = INDATABUFLEN;
    ATInMsgQueStr[0].Read = ATInMsgQueStr[0].Write = ATInMsgQueStr[0].BufPtr = 
    &InDataBuf[0];
#endif

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
    RxBitCount = 0;
    RxBitErrors = 0;    

    ChnEnableCngTx = 0;    
    ChnDetectRingBack = 0;
    ChnDetectReorderTone = 0;
    ChnResponse = 0;
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
    H_Mode = OFFLINECMDMODE;
    InDataW = OutDataR =  OutDataW = 0;
    BytesPerFrame = 20;
    HostXoffLimit = 80;
    HostXonLimit = 40;

    ATInMsgQueStr[0].Read = ATInMsgQueStr[0].Write = ATInMsgQueStr[0].BufPtr = 
    &InDataBuf[0];

    RingDetect = 0;

    //This function is provided by the data pump for initializing the
    //data pump variables

    ModemChannelActivate(&Pcm[0],InMsgQPtr0,OutMsgQPtr0); 

    //Depending on the mode enabled set the DP configuration variables
    //This function configures the data pump by sending configurable
    //messages to the data pump

    Configure_DP(0);   //Configure ORG mode DP

    ResetCodecBuffers();

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
         Timer = CPDialTonePeroid * 8000;
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
#ifdef DEF_AT
                    DPMsgParams[0] = COMNODIALTONE;
                    DPIndicateStatus(DP_CP_STATUS,DPMsgParams);
#endif
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
#ifdef DEF_AT
                    DPMsgParams[0] = NOCARRIER;
                    DPIndicateStatus(DP_CP_STATUS,DPMsgParams);
#endif
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
                while(OutDataW != OutDataR);
                go_on_hook();
                ResetModemState();         
                SetFS8000();    
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

    CheckFlowControl();

    if (!iH_Xoff) 
    {

/*        ATInMsgQueStr[0].Write = &InDataBuf[InDataW]; */
        status = ATInMsgQueStr[0].Write - ATInMsgQueStr[0].Read;
        if(!status) return;
        if(status < 0) status += ATInMsgQueStr[0].Size;

        if(status > BytesPerFrame)
        { 
            status = BytesPerFrame;
        }

        //For the DP_STANDALONE mode send the data to DP directly through
        //the message mDATATODP

#ifdef DEF_V42
        for(i=0;i<status;i++)
        {
            Buf[i] = *ATInMsgQueStr[0].Read++;
            if (ATInMsgQueStr[0].Read == (ATInMsgQueStr[0].BufPtr+ATInMsgQueStr[0].Size) ) ATInMsgQueStr[0].Read  = ATInMsgQueStr[0].BufPtr;
        }
        iH_Xoff    = 1;
        V42SendData(0,Buf,status);
#else    

        Ptr = InMsgQueStr[ID].Write;

        *Ptr++ = mDATATODP;
        if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;

        *Ptr++ = status;
        if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;
        
        InMsgQueStr[ID].Write += 2 + status;

        for (i=0; i< status; i++) 
        {
            TxByte = *ATInMsgQueStr[0].Read++;
            *Ptr++ = TxByte;
            if (ATInMsgQueStr[0].Read == (ATInMsgQueStr[0].BufPtr+ATInMsgQueStr[0].Size) ) ATInMsgQueStr[0].Read  = ATInMsgQueStr[0].BufPtr;
            if (Ptr == (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size) ) Ptr = InMsgQueStr[ID].BufPtr;
        }

        if (InMsgQueStr[ID].Write >= (InMsgQueStr[ID].BufPtr+InMsgQueStr[ID].Size))
        InMsgQueStr[ID].Write -= InMsgQueStr[ID].Size;
#endif

#ifdef DEF_AT
        if(ATEscapeSeq == 1)
        {
            ATEscapeSeq = 0;
            H_Mode = ONLINECMDMODE;
            DPIndicateStatus(SEND_OK_RESPONSE,0);
        } 
#endif

    }
}

/**************************************************************************/
/*
**  Function Name: ProcessDPResponses 
**
**  Description :
**                Get messages from the datapump and put them in the message 
**                parameter buffer.Read/analyse the messages.
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
            msgbyte = OutDataBuf[OutDataW++] = *Ptr++;
            if (OutDataW == OUTDATABUFLEN) OutDataW = 0;
            if (Ptr == (OutMsgQueStr[ID].BufPtr+OutMsgQueStr[ID].Size)) Ptr = OutMsgQueStr[ID].BufPtr;
            FindBitErrors(msgbyte);
        }
        //Send the received data to the host(UART)
        SendCharToUARTTx();                        
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
        BytesPerFrame = 20;

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
                BytesPerFrame = 1;
                HostXoffLimit = 80;
                HostXonLimit = 60;
            }
            SMV42Enable = 0;
        }

        if((MsgParams[0]== V21_MODE) || (MsgParams[0]== B103_MODE))
        {
            BitRate = 300;
            BytesPerFrame = 1;
            HostXoffLimit = 80;
            HostXonLimit = 60;
            SMV42Enable = 0;
        }

#ifdef DEF_AT
        DPMsgParams[0] = BitRate;
        DPIndicateStatus(DP_CONNECT,DPMsgParams);
#endif        
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
        RxBitCount = RxBitErrors = RxByteErrors = 0;
        H_Mode = ONLINEDATAMODE;

#endif
        speaker_off();
        return;
    }
    
    if(MessageID == mDEBUGINFO)
    {
#ifdef DEF_LCD_MSGS
//        DebugMsg(MsgParams[0]); 
#endif
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
#ifdef DEF_AT
        DPMsgParams[0] = NOCARRIER;
        DPIndicateStatus(DP_CP_STATUS,DPMsgParams);
#endif
        return;
    } 
    if(MessageID == mMODEMREADY) return;
    if(MessageID == mCHANGEBUFLEN) return;
    if(MessageID ==  mHANGUPCOMPLETE)
    {
        ChnResponse = 0;
#ifdef DEF_AT
        DPIndicateStatus(SM_HANGUP,DPMsgParams);
#endif
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
#ifdef DEF_AT
            DPMsgParams[0] = COMBUSY;
            DPIndicateStatus(DP_CP_STATUS,DPMsgParams);
#endif
            ChnResponse = 0;
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



/**************************************************************************/
/*
**  Function Name:  FindBitErrors
**
**  Description :   This function checks the received byte bit by bit and
**                  update the biterror count and rx bit count. Test is done
**                  for binary 1's
**
**  Inputs:         Received Byte
**
**  Outputs:        None
**
*/
/*************************************************************************/

void FindBitErrors(int RxByte)
{
    int Bit,i;

    RxByteCount++;                

    if(RxByte != 0xff)
    RxByteErrors++;

    for(i=0;i<8;i++)
    {
        Bit = RxByte & 1;
        if(!Bit) RxBitErrors++;
        RxBitCount++;        

        RxByte = RxByte >> 1;
    }

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

void SendXonToDTE(void)
{
    if(SMFlowControl== 0) return;

    if(SMFlowControl== 3) ClearRTS();

    if(SMFlowControl== 4)
    {
        OutDataBuf[OutDataW++] = XON_DC1;
        if(OutDataW == OUTDATABUFLEN) OutDataW = 0;
        SendCharToUARTTx();                        
    }


    return;
}

void SendXoffToDTE(void)
{
    if(SMFlowControl== 0) return;

    if(SMFlowControl== 3) SetRTS();

    if(SMFlowControl== 4) 
    {
        OutDataBuf[OutDataW++] = XOF_DC3;
        if(OutDataW == OUTDATABUFLEN) OutDataW = 0;
        SendCharToUARTTx();                        
    }

    return;
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

void CheckFlowControl(void)
{
    INT status;

    ATInMsgQueStr[0].Write = &InDataBuf[InDataW];
      status = ATInMsgQueStr[0].Write - ATInMsgQueStr[0].Read;
     if(status < 0) status += ATInMsgQueStr[0].Size;

    if(!DTEXoff)
    {
        if(status > HostXoffLimit)
        { 
            SendXoffToDTE();
            DTEXoff = 1;
        }
    }

    else 
    {
        if(status < HostXonLimit) 
        {
            SendXonToDTE();
            DTEXoff = 0;
        }
    }
}


void Configure_Rate()
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
    if(!StartLog)
    {
        StartLog = 1;
        TimeFrameCount = 0;
    }

    for(i=0;i< LEN ;i++) 
    {
        RxByteCount++;
        OutDataBuf[OutDataW++] = *Data++;
        if (OutDataW == OUTDATABUFLEN) OutDataW = 0;
    }
    if(RxByteCount >= BERLimit)
    {
        StartLog = -1;
        BytesLogged = RxByteCount;
    }

    if(UARTTxEmpty) SendCharToUARTTx();                        
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
            H_Mode = ONLINEDATAMODE;
            iH_Xoff = 0;
            DTEXoff = 0;
            SendXonToDTE();
#ifdef DEF_AT
            DPIndicateStatus(DP_ASYNC_CONNECT,DPMsgParams);
#endif
            break;

    case V42_CONNECT:
#ifdef DEF_AT
            DPIndicateStatus(DP_LAPM_CONNECT,DPMsgParams);
#endif
            H_Mode = ONLINEDATAMODE;
            iH_Xoff = 0;
            InDataW=0;
            ATInMsgQueStr[0].Read = ATInMsgQueStr[0].Write = ATInMsgQueStr[0].BufPtr = 
            &InDataBuf[0];

            DTEXoff = 0;
            SendXonToDTE();
            RxByteCount = 0;            
            break;

    case V42_RETRAIN_CONNECT:
            H_Mode = ONLINEDATAMODE;
            iH_Xoff = 0;
            DTEXoff = 0;
            SendXonToDTE();
#ifdef DEF_AT
            DPMsgParams[0] = BitRate;
            DPIndicateStatus(DP_CONNECT,DPMsgParams);
            DPIndicateStatus(DP_LAPM_CONNECT,DPMsgParams);
#endif
            break;

    case L_RELEASED:
           go_on_hook();
           ResetModemState();         
#ifdef DEF_AT
           DPIndicateStatus(SM_HANGUP,DPMsgParams);
#endif
           SetFS8000();    
           break;

    case DP_LOST_CARRIER:
    case REMOTE_V42_DISCONNECT:
    case V42_PROTO_ERROR:
     
           go_on_hook();
           ResetModemState();         
#ifdef DEF_AT
           DPIndicateStatus(V42_ERROR,DPMsgParams);
#endif
           SetFS8000();    
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

//Following functions are used by AT command layer as import functions

#ifdef DEF_AT

/**************************************************************************/
/*
**  Description :   This function is called by AT command layer to indicate 
**                    the AT command processing status
**
*/
/*************************************************************************/

void ATIndicateStatus(CHAR STATUS_ID,UINT *MsgParams)
{
    INT i;
    switch(STATUS_ID)
    {

        case DETECT_ESCAPE_SEQUENCE:
            ATEscapeSeq = 1;
            break;

        case GO_ON_HOOK:
            go_on_hook();
            break;

        case GO_OFF_HOOK:
            go_off_hook(ClprgSpeakerVol);
            break;

        case MODEM_RESET:        
            ResetModemState();
            SetFS8000();
            break;

        case START_ALB_MODE:        
            ModemSwitch = 9;
            break;

        case START_ANSWER_MODE:        
            ModemSwitch = 7;
            RingDetect = 1;              
            break;

        case START_ORG_MODE:
            for(i=0;i<MsgParams[0]+1;i++)
            {
                DTMFString[i] = (UCHAR)MsgParams[i];
            }
            ModemSwitch = 1;
            break;

        case MODEM_HANGUP:
            HangModem();
            break;

        case SET_H_MODE:
            H_Mode = (UCHAR)MsgParams[0];
            break;

        case MODEM_CONFIG:
            DPTxLevel = (UCHAR)MsgParams[0];

            if(DPHSMode != (UCHAR)MsgParams[1] || DPCnxRate[0] != MsgParams[2] || DPCnxRate[1] != MsgParams[3])
            {
                DPHSMode = (UCHAR)MsgParams[1];
                DPCnxRate[0] = MsgParams[2];
                DPCnxRate[1] = MsgParams[3];
                Configure_Rate();
            }

            CPDetectDialTone = (UCHAR)MsgParams[4];
            CPDetectBusyTone = (UCHAR)MsgParams[5];
            CPDialTonePeroid = (UCHAR)MsgParams[6];
            DPConnectPeriod = (UCHAR)MsgParams[7];
            SMV42Enable = (UCHAR)MsgParams[8];
            SMFlowControl = (UCHAR)MsgParams[9];
            break;

        case CLPRG_SPEAKER_VOLUME:

	        if((UCHAR)MsgParams[0] == 0)
	        {
	            ClprgSpeakerVol = 0x60;
	        }
	        if((UCHAR)MsgParams[0] == 1)
	        {
	            ClprgSpeakerVol = 0x03;
	        }
	        else if((UCHAR)MsgParams[0] == 2)
	        {
	            ClprgSpeakerVol = 0x63;
	        }
    	    else if((UCHAR)MsgParams[0] == 3)
	        {
	            ClprgSpeakerVol = 0x00;
	        }	    
            break;
            
        default:
            break;    

    }

}    

/**************************************************************************/
/*
**  Description :   This function is used to send the message received from 
**                  AT command layer to DP layer
**
*/
/*************************************************************************/

void ATSendMsgToDP(UCHAR MSG_ID,UCHAR MsgLen,UCHAR *MsgParams)
{
     MsgS.Id = MSG_ID;
     MsgS.Len = MsgLen;
     UpdateMsgQue(0,MsgParams);
}

/**************************************************************************/
/*
**  Description :   This function is used to send the commands received from 
**                  AT command layer to UART
**
*/
/*************************************************************************/

void ATSendStringToUART(UCHAR *StringBuf,UINT Length)
{
    INT i;
    for(i=0;i<Length;i++)
    {
        OutDataBuf[OutDataW++] = StringBuf[i];
        if(OutDataW == OUTDATABUFLEN) OutDataW = 0;
    }
    SendCharToUARTTx();                        
}
#endif


/*--------------------------------------------------------------------
             END OF FILE
---------------------------------------------------------------------*/
