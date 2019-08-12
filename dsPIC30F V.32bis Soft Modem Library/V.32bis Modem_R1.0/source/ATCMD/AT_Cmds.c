
/*-------------------------------------------------------------------------
FILE NAME:     AT_CMDS.C
--------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------
 INCLUDE FILES
--------------------------------------------------------------------------*/

#include "api_c.h"
#include "atapi.h"
#include "AT_cmds.h"

#ifdef DEF_AT

/*-------------------------------------------------------------------------
 RESPONSE CODES FROM AT COMMAND LAYER
--------------------------------------------------------------------------*/

const char comStringBuf[] __attribute__ ((__section__ (".text"), __space__(__prog__))) = 
{
   LF,CR,'O','K',LF,CR,0,
   LF,CR,'E','R','R','O','R',LF,CR,0,
   LF,CR,'N','O','C','A','R','R','I','E','R',LF,CR,0,
   LF,CR,'C','O','N','N','E','C','T',SP,0,
   LF,CR,'C','A','R','R','I','E','R',SP,0,
   '2','4','0','0',LF,CR,0,
   '1','2','0','0',LF,CR,0,
   '9','6','0','0',LF,CR,0,
   '4','8','0','0',LF,CR,0,
   '3','0','0',LF,CR,0,
   '7','5','/','1','2','0','0',LF,CR,0,
   '1','2','0','0','/','7','5',LF,CR,0,

   '1','1','5','2','0','0',LF,CR,0,    
   '5','7','6','0','0',LF,CR,0,    
   '3','8','4','0','0',LF,CR,0,    
   '1','9','2','0','0',LF,CR,0,    
   '9','6','0','0',LF,CR,0,       

   LF,CR,'P','R','O','T','O','C','O','L', SP,0,  
   'N','O','N','E',LF,CR,0,
   'L','A','P','M',LF,CR,0,
   LF,CR,'R','I','N','G',LF,CR,0,   
   LF,CR,'B','U','S','Y',LF,CR,0,
   LF,CR,'N','O',SP,'D','I','A','L','T','O','N','E',LF,CR,0,   
   LF, CR, '1', '1', '1', '1',0,
   LF, CR,'0', '0', '0', '0',0,         
   LF,CR,'E', 'N', 'C' , 'O' ,'R', 'E','/', 'M','I','C','R',
   'O','C','H','I','P',' ', 'M', 'O', 'D', 'E', 'M',LF,CR,0,
   LF, CR, '0',LF,CR,0,      
   LF, CR, '4',LF,CR,0,
   LF, CR, '3',LF,CR,0,
   LF, CR, '7',LF,CR,0,
   LF, CR, '6',LF,CR,0,
   LF, CR, '1',LF,CR,0,
   
   LF, CR, 'D','E','T','E','C','T','D','I','A','L','T','O','N','E',
   LF, CR, 0,
   
   LF, CR, 'D','E','T','E','C','T','B','U','S','Y','T','O','N','E',
   LF, CR, 0,
   
   LF, CR, '(',0x30,',',0x31,',',0x32,',',0x33,',',0x39,')',',',
   SP, SP, '(',0x30,',',0x31,')',',',SP,SP,'(',0x33,0x30,0x30,'-',
   0x31,0x34,0x34,0x30,0x30,')',SP,SP,'(',0x33,0x30,0x30,'-',0x31,0x34,0x34,0x30,0x30,')',
   LF,CR,0,  
   
   0x1,0x1,0x5,0x2,0x0,0x0,LF,CR,0,
   
   LF,CR,'C','O','N','N','E','C','T',SP,'M','O','D','E',LF,CR,0,

   LF,CR,'R','E','T','R','A','I','N',SP,'M','O','D','E',LF,CR,0,
 
   LF,CR,'R','E','N','E','G','O','T','I','A','T','E',SP,'M','O','D','E',LF,CR,0,
   '1','4','4','0','0',LF,CR,0,
   '1','2','0','0','0',LF,CR,0,
   '7','2','0','0',LF,CR,0,   
};
   
/*-------------------------------------------------------------------------
 Response Codes Buffer pointer and AT command Channel base address pointer
--------------------------------------------------------------------------*/

INT comStringBufPtr;
void *ATChnBaseAddress;  //V42 first channel(ORG) base address pointer


/*-------------------------------------------------------------------------
 Function Name: ATInitBaseAddress
 Description  : Set the AT commands data structure base address pointer
 Input        : None 
 Output       : None 
--------------------------------------------------------------------------*/

void ATInitBaseAddress(void *ptr){
    ATChnBaseAddress = ptr;
}

/*-------------------------------------------------------------------------
 Function Name: InitATCommands
 Description  : Intialize the default configuration for AT commands
 Input        : None 
 Output       : None 
--------------------------------------------------------------------------*/

void InitATCommands(void)
{
    INT i = 0;

    AT_COMMAND *atcmdptr;

    asm("push        w1");
    asm("push        w2");
    asm ("mov        #tblpage(_comStringBuf),w2");  
    asm ("mov        w2, _TBLPAG");
    asm ("mov        #tbloffset(_comStringBuf),w1");
    asm ("mov        w1, _comStringBufPtr");
    asm("pop        w2");
    asm("pop        w1");

    atcmdptr = ATChnBaseAddress;

    atcmdptr->Backcommand=0;
    atcmdptr->KeyNo=0;
    atcmdptr->escapecount=0;

    atcmdptr->commands[i++] = 1;        //for ATE
    atcmdptr->commands[i++] = 0;        //for ATHOOK
    atcmdptr->commands[i++] = 0;        //for ATQ
    atcmdptr->commands[i++] = 1;        //for ATV
    atcmdptr->commands[i++] = 0;        //for ATANDF
    atcmdptr->commands[i++] = 3;        //for ATANDK
    atcmdptr->commands[i++] = 0;        //for ATG
    atcmdptr->commands[i++] = 5;        //for ATV42
    atcmdptr->commands[i++] = 1;        //for ATBUSY
    atcmdptr->commands[i++] = 1;        //for ATDIALTONE
    atcmdptr->commands[i++] = 1;        //for AUTOMODE

    atcmdptr->commands[i++] = 1;        //for ATS0 -11
    atcmdptr->commands[i++] = 0;        //for ATS1 -12
    atcmdptr->commands[i++] = 43;       //for ATS2 -13 
    atcmdptr->commands[i++] = 13;       //for ATS3 -14
    atcmdptr->commands[i++] = 10;       //for ATS4 -15 
    atcmdptr->commands[i++] = 8;        //for ATS5 -16 
    atcmdptr->commands[i++] = 1;        //for ATS6 -17 
    atcmdptr->commands[i++] = 60;       //for ATS7 -18
    atcmdptr->commands[i++] = 2;        //for ATS8 -19
    atcmdptr->commands[i++] = 6;        //for ATS9 -20
    atcmdptr->commands[i++] = 7;        //for ATS10-21 
    atcmdptr->commands[i++] = 70;       //for ATS11-22
    atcmdptr->commands[i++] = 50;       //for ATS12-23
    atcmdptr->commands[i++]=0;          //for ATS18-24
    atcmdptr->commands[i++]=0;          //for ATS24-25
    atcmdptr->commands[i++]=0;          //for ATS25-26
    atcmdptr->commands[i++]=0;          //for ATS26-27
    atcmdptr->commands[i++]=0;          //for ATS29-28
    atcmdptr->commands[i++]=17;         //for ATS32-29
    atcmdptr->commands[i++]=19;         //for ATS33-30
    atcmdptr->commands[i++]=0;          //for ATS86-31
    atcmdptr->commands[i++]=12;         //for ATS91-32
    atcmdptr->commands[i++]=2;          //for ATL-33

    atcmdptr->ModMode = 0;
    atcmdptr->ModRate[0] = 300;
    atcmdptr->ModRate[1] = 14400;    
    atcmdptr->DPConnect = 0;
    atcmdptr->ConnectPattern = 1;
    atcmdptr->RetrainsRequested =0;
    atcmdptr->RetrainsGranted =0;

    SendConfigParamsToDP(atcmdptr);

    ATIndicateStatus(CLPRG_SPEAKER_VOLUME,(UINT *)&atcmdptr->commands[ATL]);

}

/*-------------------------------------------------------------------------
 Function Name: SendString
 Description  : This function is used to send the response characters to
                host layer
 Input        : AT_Conmmand Structure pointer , Response buffer index
 Output       : None 
--------------------------------------------------------------------------*/

void SendString(AT_COMMAND *atcmdptr,INT c)
{
    INT i=0, comStrPtr,Length;
    CHAR ch;
    
    comStrPtr = comStringBufPtr+c;
    Length = GetString(comStrPtr,&atcmdptr->UARTTxBuf[0]);
    ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);
}

/*-------------------------------------------------------------------------
 Function Name: SendConfig
 Description  : This function is used to send the configuration messages to
                host layer
 Input        : AT_Conmmand Structure pointer
 Output       : None 
--------------------------------------------------------------------------*/

void SendConfig(AT_COMMAND *atcmdptr)
{
    CHAR ch,j = 0,i;
    UCHAR TempBuf[4];

    atcmdptr->UARTTxBuf[j++] = LF;
    atcmdptr->UARTTxBuf[j++] = CR;

    atcmdptr->UARTTxBuf[j++] = 'E';
    ch = atcmdptr->commands[ATE];
    ch= ch+0x30;
    atcmdptr->UARTTxBuf[j++] = ch;
    atcmdptr->UARTTxBuf[j++] = SP;

    atcmdptr->UARTTxBuf[j++] = 'H';
    ch = atcmdptr->commands[ATHOOK];
    ch=ch+0x30;
    atcmdptr->UARTTxBuf[j++] = ch;
    atcmdptr->UARTTxBuf[j++] = SP;

    atcmdptr->UARTTxBuf[j++] = 'Q';
    ch = atcmdptr->commands[ATQ];
    ch=ch+0x30;
    atcmdptr->UARTTxBuf[j++] = ch;
    atcmdptr->UARTTxBuf[j++] = SP;

    atcmdptr->UARTTxBuf[j++] = 'V';
    ch = atcmdptr->commands[ATV];
    ch = ch+0x30;
    atcmdptr->UARTTxBuf[j++] = ch;

    atcmdptr->UARTTxBuf[j++] = LF;
    atcmdptr->UARTTxBuf[j++] = CR;

    atcmdptr->UARTTxBuf[j++] = '&';
    atcmdptr->UARTTxBuf[j++] = 'K';
    ch = atcmdptr->commands[ATANDK];
    ch = ch+0x30;
    atcmdptr->UARTTxBuf[j++] = ch;

    atcmdptr->UARTTxBuf[j++] = LF;
    atcmdptr->UARTTxBuf[j++] = CR;

    atcmdptr->UARTTxBuf[j++] = 'V';
    atcmdptr->UARTTxBuf[j++] = '4';
    atcmdptr->UARTTxBuf[j++] = '2';
    atcmdptr->UARTTxBuf[j++] = '=';
    ch = atcmdptr->commands[ATV42];
    ch = ch+0x30;
    atcmdptr->UARTTxBuf[j++] = ch;

    atcmdptr->UARTTxBuf[j++] = LF;
    atcmdptr->UARTTxBuf[j++] = CR;

    ATSendStringToUART(&atcmdptr->UARTTxBuf[0],j);

    j = 0;
    atcmdptr->UARTTxBuf[j++] = 'B';
    atcmdptr->UARTTxBuf[j++] = 'U';
    atcmdptr->UARTTxBuf[j++] = 'S';
    atcmdptr->UARTTxBuf[j++] = 'Y';
    atcmdptr->UARTTxBuf[j++] = '=';
    ch = atcmdptr->commands[ATBUSY];
    ch = ch+0x30;
    atcmdptr->UARTTxBuf[j++] = ch;
    atcmdptr->UARTTxBuf[j++] = LF;
    atcmdptr->UARTTxBuf[j++] = CR;


    atcmdptr->UARTTxBuf[j++] = 'D';
    atcmdptr->UARTTxBuf[j++] = 'T';
    atcmdptr->UARTTxBuf[j++] = '=';
    ch = atcmdptr->commands[ATDIALTONE];
    ch = ch+0x30;
    atcmdptr->UARTTxBuf[j++] = ch;
    atcmdptr->UARTTxBuf[j++] = LF;
    atcmdptr->UARTTxBuf[j++] = CR;


    atcmdptr->UARTTxBuf[j++] = 'A';
    atcmdptr->UARTTxBuf[j++] = 'M';
    atcmdptr->UARTTxBuf[j++] = '=';
    ch = atcmdptr->commands[ATMODE];
    ch = ch+0x30;
    atcmdptr->UARTTxBuf[j++] = ch;
    atcmdptr->UARTTxBuf[j++] = LF;
    atcmdptr->UARTTxBuf[j++] = CR;

    ATSendStringToUART(&atcmdptr->UARTTxBuf[0],j);

    j = 0;
    atcmdptr->UARTTxBuf[j++] = 'S';
    atcmdptr->UARTTxBuf[j++] = '0';
    atcmdptr->UARTTxBuf[j++] = '=';
    ch = atcmdptr->commands[ATS0];
    DecimalToUART((INT)ch,TempBuf);

    for(i=0;i<TempBuf[0];i++)
    {
        atcmdptr->UARTTxBuf[j++] = TempBuf[i+1];
    }

    atcmdptr->UARTTxBuf[j++] = SP;


    atcmdptr->UARTTxBuf[j++] = 'S';
    atcmdptr->UARTTxBuf[j++] = '1';
    atcmdptr->UARTTxBuf[j++] = '=';
    ch = atcmdptr->commands[ATS1];

    DecimalToUART((INT)ch,TempBuf);
    for(i=0;i<TempBuf[0];i++)
    {
        atcmdptr->UARTTxBuf[j++] = TempBuf[i+1];
    }

    atcmdptr->UARTTxBuf[j++] = SP;

    atcmdptr->UARTTxBuf[j++] = 'S';
    atcmdptr->UARTTxBuf[j++] = '6';
    atcmdptr->UARTTxBuf[j++] = '=';
    ch = atcmdptr->commands[ATS6];

    DecimalToUART((INT)ch,TempBuf);
    for(i=0;i<TempBuf[0];i++)
    {
        atcmdptr->UARTTxBuf[j++] = TempBuf[i+1];
    }

    atcmdptr->UARTTxBuf[j++] = SP;

    atcmdptr->UARTTxBuf[j++] = 'S';
    atcmdptr->UARTTxBuf[j++] = '7';
    atcmdptr->UARTTxBuf[j++] = '=';
    ch = atcmdptr->commands[ATS7];
    DecimalToUART((INT)ch,TempBuf);
    for(i=0;i<TempBuf[0];i++)
    {
        atcmdptr->UARTTxBuf[j++] = TempBuf[i+1];
    }
    atcmdptr->UARTTxBuf[j++] = SP;


    atcmdptr->UARTTxBuf[j++] = 'S';
    atcmdptr->UARTTxBuf[j++] = '9';
    atcmdptr->UARTTxBuf[j++] = '1';
    atcmdptr->UARTTxBuf[j++] = '=';
    ch = atcmdptr->commands[ATS91];
    DecimalToUART((INT)ch,TempBuf);

    for(i=0;i<TempBuf[0];i++)
    {
        atcmdptr->UARTTxBuf[j++] = TempBuf[i+1];
    }

    atcmdptr->UARTTxBuf[j++] = LF;
    atcmdptr->UARTTxBuf[j++] = CR;

    ATSendStringToUART(&atcmdptr->UARTTxBuf[0],j);
}

/*-------------------------------------------------------------------------
 Function Name: Link_Diagnostics
 Description  : This function is used to send the Link connection 
                information to host layer
 Input        : AT_Conmmand Structure pointer
 Output       : None 
--------------------------------------------------------------------------*/

void Link_Diagnostics(AT_COMMAND *atcmdptr)
{
    INT ch;

    atcmdptr->UARTTxBuf[0] = LF;
    atcmdptr->UARTTxBuf[1] = CR;


    atcmdptr->UARTTxBuf[2] = 'R';
    atcmdptr->UARTTxBuf[3] = 'e';
    atcmdptr->UARTTxBuf[4] = 't';
    atcmdptr->UARTTxBuf[5] = 'r';
    atcmdptr->UARTTxBuf[6] = 'a';
    atcmdptr->UARTTxBuf[7] = 'i';
    atcmdptr->UARTTxBuf[8] = 'n';
    atcmdptr->UARTTxBuf[9] = 's';

    atcmdptr->UARTTxBuf[10] = SP;

    atcmdptr->UARTTxBuf[11] = 'R';
    atcmdptr->UARTTxBuf[12] = 'e';
    atcmdptr->UARTTxBuf[13] = 'q';
    atcmdptr->UARTTxBuf[14] = 'u';
    atcmdptr->UARTTxBuf[15] = 'e';
    atcmdptr->UARTTxBuf[16] = 's';
    atcmdptr->UARTTxBuf[17] = 't';
    atcmdptr->UARTTxBuf[18] = 'e';
    atcmdptr->UARTTxBuf[19] = 'd';

    atcmdptr->UARTTxBuf[20] = SP;
    atcmdptr->UARTTxBuf[21] = SP;

    ch = atcmdptr->RetrainsRequested+0x30;
    atcmdptr->UARTTxBuf[22] = ch;

    atcmdptr->UARTTxBuf[23] = LF;
    atcmdptr->UARTTxBuf[24] = CR;

    ATSendStringToUART(&atcmdptr->UARTTxBuf[0],25);

    atcmdptr->UARTTxBuf[0] = 'R';
    atcmdptr->UARTTxBuf[1] = 'e';
    atcmdptr->UARTTxBuf[2] = 't';
    atcmdptr->UARTTxBuf[3] = 'r';
    atcmdptr->UARTTxBuf[4] = 'a';
    atcmdptr->UARTTxBuf[5] = 'i';
    atcmdptr->UARTTxBuf[6] = 'n';
    atcmdptr->UARTTxBuf[7] = 's';

    atcmdptr->UARTTxBuf[8] = SP;

    atcmdptr->UARTTxBuf[9] = 'G';
    atcmdptr->UARTTxBuf[10] = 'r';
    atcmdptr->UARTTxBuf[11] = 'a';
    atcmdptr->UARTTxBuf[12] = 'n';
    atcmdptr->UARTTxBuf[13] = 't';
    atcmdptr->UARTTxBuf[14] = 'e';
    atcmdptr->UARTTxBuf[15] = 'd';

    atcmdptr->UARTTxBuf[16] = SP;
    atcmdptr->UARTTxBuf[17] = SP;
    atcmdptr->UARTTxBuf[18] = SP;
    atcmdptr->UARTTxBuf[19] = SP;
 
    ch = atcmdptr->RetrainsGranted+0x30;
    atcmdptr->UARTTxBuf[20] = ch;

    atcmdptr->UARTTxBuf[21] = LF;
    atcmdptr->UARTTxBuf[22] = CR;

    ATSendStringToUART(&atcmdptr->UARTTxBuf[0],23);
}

/*-------------------------------------------------------------------------
 Function Name: ProcessATCommands
 Description  : This function is the main function used to process the 
                commands given by the host layer
 Input        : AT_Conmmand Structure pointer, Data pump state
 Output       : None 
--------------------------------------------------------------------------*/

void ProcessATCommands(ATMSGQSTRUCT *ATInMsg, CHAR DPMode) {

    INT i;
    INT Quiet, Verbose;
    CHAR Key,*TempReadPtr;
    UCHAR KeyCount = 0;
    UINT MsgParams[2];

    AT_COMMAND *atcmdptr;

    atcmdptr = ATChnBaseAddress;

    if(ATInMsg->Write == ATInMsg->Read) return;

    TempReadPtr = ATInMsg->Read;
    Quiet = atcmdptr->commands[ATQ];
    Verbose = atcmdptr->commands[ATV];
        
    while(1)
    {
        if(ATInMsg->Write == ATInMsg->Read) 
        {
            if(DPMode == ONLINEDATAMODE)
            {
                ATInMsg->Read = TempReadPtr;
            }            
            break;
        }
        
        Key = *ATInMsg->Read++;
        if (ATInMsg->Read == (ATInMsg->BufPtr+ATInMsg->Size)) ATInMsg->Read = ATInMsg->BufPtr;    
        KeyCount++;

        if(DPMode == ONLINEDATAMODE)
        {
            if(Key == '+')    atcmdptr->escapecount++;
            else atcmdptr->escapecount = 0;
            if(atcmdptr->escapecount == 3)
            {
                atcmdptr->Backcommand=1;
                atcmdptr->KeyNo=0;
                ATIndicateStatus(DETECT_ESCAPE_SEQUENCE,MsgParams);
                ATInMsg->Read = TempReadPtr;
                atcmdptr->escapecount = 0;
                break;            
            }
    
        }

        if(DPMode == ONLINEMODE)
        {
            if(Key)
            {

                ATIndicateStatus(GO_ON_HOOK,MsgParams);
                ATIndicateStatus(MODEM_RESET,MsgParams);
                SendResponse(atcmdptr,NOCARRIER);
                return;
            }
        }

        if( (DPMode == OFFLINECMDMODE) || (DPMode == ONLINECMDMODE))
        {
            switch(Key)
            {

                case KEY_ENTER:

                    if (atcmdptr->KeyNo)
                    {
                        if(atcmdptr->KeyNo==1)
                        {
                            for(i=0;i<=atcmdptr->KeyNo;i++)
                            {    
                               atcmdptr->aiprevbuf[i]=atcmdptr->KeyBuf[i];
                            }

                            //Copy the PrevCmdCntr characters to icount for analyzing

                            atcmdptr->PrevCmdCntr = atcmdptr->KeyNo;
                            SendResponse(atcmdptr,COMERROR);

                            atcmdptr->KeyNo = 0;
                            atcmdptr->KeyBuf[0] = 0;
                            break;
                        }

                        InterpretCommand(atcmdptr, 0);

                        atcmdptr->KeyNo = 0;
                        atcmdptr->KeyBuf[0] = 0;
                        break;
                    }

                case KEY_BKSPC:
                    if (atcmdptr->KeyNo > 0)
                    {
                        atcmdptr->KeyNo--;
                        atcmdptr->KeyBuf[atcmdptr->KeyNo] = 0;
                        if(atcmdptr->commands[ATE])
                            SendCharToUART(atcmdptr,KEY_BKSPC);

                    }
                    break;

                default:
                    if (atcmdptr->KeyNo < 20)
                    {
                    
                        atcmdptr->KeyBuf[atcmdptr->KeyNo++] = Key;
                        atcmdptr->KeyBuf[atcmdptr->KeyNo] = 0;
                        if(atcmdptr->commands[ATE])
                            SendCharToUART(atcmdptr,Key);

                        if(atcmdptr->KeyBuf[0]=='A' || atcmdptr->KeyBuf[0]=='a')
                        {
                            if(atcmdptr->KeyBuf[1]=='/')
                            {
                                InterpretCommand(atcmdptr, 0);
                                atcmdptr->KeyNo = 0;
                                atcmdptr->KeyBuf[0] = 0;
                                break;
                            }
                        }
                    }
            }    
        }
    }
    return;
}

/*-------------------------------------------------------------------------
 Function Name: InterpretCommand
 Description  : This function is used to interpret the AT command
 Input        : AT_Conmmand Structure pointer
 Output       : None 
--------------------------------------------------------------------------*/

void InterpretCommand(AT_COMMAND *atcmdptr, INT CHNID)
{
    INT i;
    INT Quiet1, Verbose1;
    UCHAR TempBuf[6];
    Quiet1 = atcmdptr->commands[ATQ];
    Verbose1 = atcmdptr->commands[ATV];

    switch(atcmdptr->KeyBuf[0])
    {
// According to the first character of the command it will store the command
// characters from command buffer to current buffer.
        case 'A':
        case 'a':
            for(i=0;i<=atcmdptr->KeyNo-1;i++)
            {
                atcmdptr->aiCurBuf[i] = atcmdptr->KeyBuf[i];
            }

            atcmdptr->icount = atcmdptr->KeyNo;
            ProcessFunction(atcmdptr,atcmdptr->aiCurBuf,atcmdptr->icount, CHNID);
            break;

        default:
        
        for(i=0;i<=atcmdptr->KeyNo-1;i++)
            {
                atcmdptr->aiprevbuf[i] = atcmdptr->KeyBuf[i];
            }
            atcmdptr->PrevCmdCntr=atcmdptr->KeyNo;
            SendResponse(atcmdptr,COMERROR);
            break;

    }
}

/*-------------------------------------------------------------------------
 Function Name: ProcessFunction
 Description  : This function is used to process and execute the required
                functionality of the lower layer
 Input        : AT_Conmmand Structure pointer,Command Buf Pointer, character
                count
 Output       : None 
--------------------------------------------------------------------------*/

void ProcessFunction(AT_COMMAND *atcmdptr, CHAR *aiCurBuf, CHAR icount, CHAR CHNID)
{
    INT i=0,cntr=2, val,SValue,SIndex;
    INT ch,a1,a2;
    INT QuietControl, VerboseControl;
    CHAR ch1;
    UINT MsgParams[25];

    QuietControl = atcmdptr->commands[ATQ];
    VerboseControl = atcmdptr->commands[ATV];

    // read the 2nd character for slash (/)

    ch = aiCurBuf[1];

    //check for / after A if not / copy aiCurBuf to prevbuf

    if(ch != '/')
    {
        for(i=0;i<=icount;i++)
        {
           atcmdptr->aiprevbuf[i] = aiCurBuf[i];
        }

        // copy the number of characters in icount to prevcntr
        atcmdptr->PrevCmdCntr = icount;
    }

    else
    {
        // Repeat command then copy the recent command from
        // prevbuf to aiCurBuf

        for(i=0;i<=atcmdptr->PrevCmdCntr;i++)
        {
          aiCurBuf[i] = atcmdptr->aiprevbuf[i];
        }

        // Copy the PrevCmdCntr characters to icount for analyzing
        atcmdptr->icount = atcmdptr->PrevCmdCntr;
    }

    //if icount is 2 then we have AT command then send
    //OK response to DTE.

    if(atcmdptr->aiCurBuf[1] != '/' && atcmdptr->aiCurBuf[1] != 't' && atcmdptr->aiCurBuf[1] != 'T')
    {
        SendResponse(atcmdptr,COMERROR);
        return;
    }


    if(atcmdptr->icount == 2)
    {
        SendResponse(atcmdptr,COMOK);
     //   return;
    }


    // if the command is 3 characters i.e., ATA,ATH,AT+,ATD
    // Store the current address of aiCurBuf to aiCurBuf,to fetch
    // 3rd character

    aiCurBuf = &aiCurBuf[2];

    // Execute this loop as long as cntr is less than icount

    while(cntr<atcmdptr->icount)
    {

        // Read the 3rd character and increment the cntr

        ch = *aiCurBuf++; // for '+'
        cntr++;//3

        //If the 3rd character is 'T' or 't' then process
        // ATT command (Analog Loop Back)

        if(ch == 'T' || ch == 't')
        {
            // Send mAnswer Message to DataPump and switching to the
            // case according to the Mode.

            if(!atcmdptr->Backcommand)
            {
                if(cntr == atcmdptr->icount)
                {
                    ATIndicateStatus(START_ALB_MODE,MsgParams);
                    continue;
                }
                else
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

            }
            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;                        /*ERROR*/
            }
        }

        //If the 3rd character is 'A' or 'a' then process
        // AT+ATA command

        if(ch == 'A' || ch == 'a')
        {
            // Send mAnswer Message to DataPump and switching to the
            // case according to the Mode.

            if(!atcmdptr->Backcommand)
            {
                if(cntr == atcmdptr->icount)
                {
                    atcmdptr->commands[ATHOOK] = 1;
                    ATIndicateStatus(START_ANSWER_MODE,MsgParams);
                    continue;
                }
                else
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

            }
            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;                        /*ERROR*/
            }
        }

        // If the 3rd character is 'D' or 'd' then the command is
        // AT+ATD

        else if(ch == 'D' || ch == 'd')
        {

            // After ATD, if there is no character then check this condition,if satisfies
            // send an ERROR response to DTE

            if(!atcmdptr->Backcommand)
            {
                if(cntr == atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                a1 =0;
                while(cntr < atcmdptr->icount)
                {
                    a2 = aiCurBuf[a1];
                    a2 -= 0x30;
                    MsgParams[a1+1] = (UCHAR)a2;
                    a1++;
                    cntr++;
                }

                MsgParams[0] =  (UCHAR)a1;
                ATIndicateStatus(START_ORG_MODE,MsgParams);
                continue;
            }
            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;                    /*ERROR*/
            }
        } // end of D loop


        else if(ch == 'E' || ch == 'e')
        {
            ch = *aiCurBuf++;
            cntr++;

            if(ch=='?')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                ch1= atcmdptr->commands[ATE];
                ch1=ch1+0x30;
                SendCharToUART(atcmdptr,LF);
                SendCharToUART(atcmdptr,CR);
                SendCharToUART(atcmdptr,ch1);
                SendCharToUART(atcmdptr,LF);
        
                SendResponse(atcmdptr,COMOK);
            }

            else if(ch == '0')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                atcmdptr->commands[ATE] = 0;
                SendResponse(atcmdptr,COMOK);
            }
    
            else if(ch == '1')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                atcmdptr->commands[ATE] = 1;
                SendResponse(atcmdptr,COMOK);
            }
        
            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }
        }

        else if(ch == 'L' || ch == 'l')
        {
            ch = *aiCurBuf++;
            cntr++;

            if(ch=='?')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                ch1= atcmdptr->commands[ATL];
                ch1=ch1+0x30;
                SendCharToUART(atcmdptr,LF);
                SendCharToUART(atcmdptr,CR);
                SendCharToUART(atcmdptr,ch1);
                SendCharToUART(atcmdptr,LF);
        
                SendResponse(atcmdptr,COMOK);
            }

            else if(ch == '0')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                atcmdptr->commands[ATL] = 0;
                MsgParams[0] = 0;
                ATIndicateStatus(CLPRG_SPEAKER_VOLUME,MsgParams);
                SendResponse(atcmdptr,COMOK);
            }

            else if(ch == '1')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                atcmdptr->commands[ATL] = 1;
                MsgParams[0] = 1;
                ATIndicateStatus(CLPRG_SPEAKER_VOLUME,MsgParams);
                SendResponse(atcmdptr,COMOK);
            }
    
            else if(ch == '2')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                atcmdptr->commands[ATL] = 2;
                MsgParams[0] = 2;
                ATIndicateStatus(CLPRG_SPEAKER_VOLUME,MsgParams);
                SendResponse(atcmdptr,COMOK);
            }
            else if(ch == '3')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                atcmdptr->commands[ATL] = 3;
                MsgParams[0] = 3;
                ATIndicateStatus(CLPRG_SPEAKER_VOLUME,MsgParams);
                SendResponse(atcmdptr,COMOK);
            }
        
            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }
        }

        else if(ch == 'H' || ch == 'h')
        {

            if(cntr== atcmdptr->icount)
            {

                ATIndicateStatus(MODEM_HANGUP,MsgParams);
                break;
          }

            ch = *aiCurBuf++;
            cntr++;

            if(ch=='?')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                ch1= atcmdptr->commands[ATHOOK];
                ch1=ch1+0x30;
                SendCharToUART(atcmdptr,LF);
                SendCharToUART(atcmdptr,CR);
                SendCharToUART(atcmdptr,ch1);
                SendCharToUART(atcmdptr,LF);

                SendResponse(atcmdptr,COMOK);
            }

            else if(ch == '1')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                ATIndicateStatus(GO_OFF_HOOK,MsgParams);
                atcmdptr->commands[ATHOOK] = 1;
                SendResponse(atcmdptr,COMOK);
            }
    
            else if(ch == '0')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                ATIndicateStatus(GO_ON_HOOK,MsgParams);
                atcmdptr->commands[ATHOOK] = 0;
                SendResponse(atcmdptr,COMOK);

            }

            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }

       } //End Loop ATH

        else if(ch == 'I' || ch == 'i')
        {
            ch = *aiCurBuf++;
            cntr++;
            if(ch == '0'|| ch=='?')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                SendString(atcmdptr,COMPRODUCTTYPE);
                SendResponse(atcmdptr,COMOK);

            }
            else if(ch == '3')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                SendString(atcmdptr,COMPRODUCTTYPE);
                SendResponse(atcmdptr,COMOK);

            }
    
            else if(ch == '4')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                SendConfig(atcmdptr);
                SendResponse(atcmdptr,COMOK);

            }
        
            else if(ch == '6')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                Link_Diagnostics(atcmdptr);
                SendResponse(atcmdptr,COMOK);

            }
            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }
        }

        else if(ch == 'Q' || ch == 'q')
        {
            ch = *aiCurBuf++;
            cntr++;

            if(ch == '?')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }
                
                ch1= atcmdptr->commands[ATQ];
                ch1=ch1+0x30;
                SendCharToUART(atcmdptr,LF);
                SendCharToUART(atcmdptr,CR);
                SendCharToUART(atcmdptr,ch1);
                SendCharToUART(atcmdptr,LF);

                SendResponse(atcmdptr,COMOK);
                                
            }

            else if(ch == '0')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);

                    break;
                }

                QuietControl = 0;
                atcmdptr->commands[ATQ] = 0;
                SendResponse(atcmdptr,COMOK);

            }
            else if(ch == '1')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);

                    break;
                }

                QuietControl = 1;
                atcmdptr->commands[ATQ] = 1;
                SendResponse(atcmdptr,COMOK);

            }
            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }
        }//End Loop ATQ

        else if(ch == 'V' || ch == 'v')
        {
            ch = *aiCurBuf++;
            cntr++;

            if(cntr != atcmdptr->icount)
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }
        
            if(ch == '?')
            {
            
                ch1= atcmdptr->commands[ATV];
                ch1=ch1+0x30;
                SendCharToUART(atcmdptr,LF);
                SendCharToUART(atcmdptr,CR);
                SendCharToUART(atcmdptr,ch1);
                SendCharToUART(atcmdptr,LF);
            
                SendResponse(atcmdptr,COMOK);

            }
            else if(ch == '0')
            {
                VerboseControl = 0;
                atcmdptr->commands[ATV] = 0;
                SendResponse(atcmdptr,COMOK);

            }
            else if(ch == '1')
            {
                VerboseControl = 1;
                atcmdptr->commands[ATV] = 1;
                SendResponse(atcmdptr,COMOK);
            }
            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }
        }//End Loop ATV


        else if(ch == 'Z' || ch == 'z')
        {
            ch = *aiCurBuf++;
            cntr++;
            if(ch == '0')
            {
                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }
            
                ATIndicateStatus(MODEM_RESET,MsgParams);
                InitATCommands();
                SendResponse(atcmdptr,COMOK);                
            }

            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }
        }//End of ATZ

        else if(ch == 'X' || ch == 'x')
        {
            if(!atcmdptr->Backcommand)
            {
                ch = *aiCurBuf++;
                cntr++;

                if(ch == '?')
                {
                    if(cntr != atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);
                        break;
                    }

                    SendString(atcmdptr,DETECTDIALTONE);
                    ch1= atcmdptr->commands[ATDIALTONE];
                    ch1=ch1+0x30;
                    SendCharToUART(atcmdptr,LF);
                    SendCharToUART(atcmdptr,CR);
                    SendCharToUART(atcmdptr,ch1);
                    SendCharToUART(atcmdptr,LF);
                
                    SendString(atcmdptr,DETECTBUSYTONE);
                    ch1= atcmdptr->commands[ATBUSY];
                    ch1=ch1+0x30;
                    SendCharToUART(atcmdptr,LF);
                    SendCharToUART(atcmdptr,ch1);
                    SendCharToUART(atcmdptr,LF);
                    SendResponse(atcmdptr,COMOK);
                                
                }

                else if(ch == '0')
                {
                    if(cntr != atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);
                        break;
                    }

                    atcmdptr->commands[ATBUSY] = 0;
                    atcmdptr->commands[ATDIALTONE] = 0;

                    SendResponse(atcmdptr,COMOK);

                }

                else if(ch == '1')
                {
                    if(cntr != atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);
                        break;
                    }

                    atcmdptr->commands[ATBUSY] = 0;
                    atcmdptr->commands[ATDIALTONE] = 0;
                    SendResponse(atcmdptr,COMOK);

                }
                else if(ch == '2')
                {
                    if(cntr != atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);
                        break;
                    }

                    atcmdptr->commands[ATBUSY] = 0;
                    atcmdptr->commands[ATDIALTONE] = 1;
                    SendResponse(atcmdptr,COMOK);

                }
                else if(ch == '3')
                {
                    if(cntr != atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);
                        break;
                    }

                    atcmdptr->commands[ATBUSY] = 1;
                    atcmdptr->commands[ATDIALTONE] = 0;
                    SendResponse(atcmdptr,COMOK);
                }
                else if(ch == '4')
                {
                    if(cntr != atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);
                        break;
                    }

                    atcmdptr->commands[ATBUSY] = 1;
                    atcmdptr->commands[ATDIALTONE] = 1;
                    SendResponse(atcmdptr,COMOK);

                }

                else
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }
                SendConfigParamsToDP(atcmdptr);
            }
            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }
        }//End Loop ATX

        else if(ch == '&')
        {
            if(cntr == atcmdptr->icount)
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }

            ch = *aiCurBuf++;
            cntr++;

            if(ch == 'F' || ch == 'f')
            {
                if(!atcmdptr->Backcommand)
                {
                    if(cntr != atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);
                        break;
                    }
                    
                    ATIndicateStatus(MODEM_RESET,MsgParams);
                    InitATCommands();
                    SendResponse(atcmdptr,COMOK);
                }
                else
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }
            }//End of AT&F

            else if(ch == 'K' || ch == 'k')
            {
                if(cntr == atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                ch = *aiCurBuf++;
                cntr++;

                if(cntr != atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

                if(ch =='?')
                {
                    ch1= atcmdptr->commands[ATANDK];
                    ch1=ch1+0x30;
                    SendCharToUART(atcmdptr,LF);
                    SendCharToUART(atcmdptr,CR);
                    SendCharToUART(atcmdptr,ch1);
                    SendCharToUART(atcmdptr,LF);

                    SendResponse(atcmdptr,COMOK);
                
                }

                   else if(ch == '0')
                {
                    atcmdptr->commands[ATANDK] = 0;
                    SendResponse(atcmdptr,COMOK);
                }

                else if(ch == '3')
                {
                    atcmdptr->commands[ATANDK] =3;   /* Enable RTS and CTS */
                    SendResponse(atcmdptr,COMOK);
                }

                else if(ch == '4')
                {
                   atcmdptr->commands[ATANDK]=4;    /* Enable XON/XOFF */
                   SendResponse(atcmdptr,COMOK);
                }

                else
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }
                SendConfigParamsToDP(atcmdptr);
            }//End of AT&K

            else if(ch == 'Q' || ch == 'q')
            {
                if(cntr == atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }
                if(!atcmdptr->Backcommand)
                {

                    ch = *aiCurBuf++;
                    cntr++;

                    if(cntr != atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);
                        break;
                    }

                    if(ch == '?')
                    {
                        
                        ch1= atcmdptr->commands[ATV42];
                        ch1=ch1+0x30;
                        SendCharToUART(atcmdptr,LF);
                        SendCharToUART(atcmdptr,CR);
                        SendCharToUART(atcmdptr,ch1);
                        SendCharToUART(atcmdptr,LF);
    
                        SendResponse(atcmdptr,COMOK);
                    }

                    else if(ch == '5')
                    {

                        atcmdptr->commands[ATV42] = 1;
                        SendResponse(atcmdptr,COMOK);

                    }

                    else if(ch == '6')
                    {

                        atcmdptr->commands[ATV42] = 0;
                        SendResponse(atcmdptr,COMOK);

                    }

                    else
                    {
                        SendResponse(atcmdptr,COMERROR);
                        break;
                    }
                    SendConfigParamsToDP(atcmdptr);
                }
                else
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }

            }// End of at&Q

            else
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }

    }// End of &


    else if(ch == '+')
    {

        // After AT+ before reading the next character check the
        // condition,if no more characters then send an Error
        // response to DTE.

        if(!atcmdptr->Backcommand)
        {
            if(cntr== atcmdptr->icount)
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }

        // After getting AT+ then check for the character 'M'
        // Read the 4th character and increment the cntr.

            ch = *aiCurBuf++;//aiCurBuf[3]
            cntr++;//4

        // Check for the 4th character if not 'M' or 'm'
        // Send an error response to DTE.

        if(ch != 'M' && ch != 'm')
        {
            SendResponse(atcmdptr,COMERROR);
            break;
        }
        else
        {
        // After AT+M then no more characters then check the
        // condition,if the below condition satisfies send an
        // error response to DTE.
            if(cntr== atcmdptr->icount)
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }

            // Read the 5th character after AT+M and increment the cntr
            ch = *aiCurBuf++;//aiCurBuf[4];
            cntr++;//5

            // Check for the 5th character for AT+MS

            // If the 5th character is 'S' or 's' then set the
            // Flag to Receive Mode

            if(ch != 'S' && ch != 's')
            {
                SendResponse(atcmdptr,COMERROR);
                break;
            }

            else
            {
            // After AT+MS then no more characters then check the
            // condition,if the below condition satisfies send an
            // error response to DTE.
                if(cntr== atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;
                }
            // Read the 6th character after AT+MS and increment the cntr

                ch = *aiCurBuf++;//aiCurBuf[4];
                cntr++;//5

                if(ch != '=')
                 {
                    if(ch=='?')
                    {
                        if(cntr != atcmdptr->icount)
                        {
                            SendResponse(atcmdptr,COMERROR);
                            break;
                        }
                        else
                        {
                    
                        ch1= atcmdptr->ModulationMode;
                        ch1=ch1+0x30;
                        SendCharToUART(atcmdptr,LF);
                        SendCharToUART(atcmdptr,CR);
                        SendCharToUART(atcmdptr,ch1);
                        SendCharToUART(atcmdptr,',');
                        
                        ch1= atcmdptr->commands[ATMODE];
                        ch1=ch1+0x30;
                        SendCharToUART(atcmdptr,ch1);
                        SendCharToUART(atcmdptr,',');
                        
                        ch= atcmdptr->ModRate[0];

                        DecimalToUART(ch,(UCHAR *)&MsgParams[0]);
                        ATSendStringToUART((UCHAR *)&MsgParams[0],MsgParams[0]);
                        SendCharToUART(atcmdptr,',');
                        
                        ch= atcmdptr->ModRate[1];
                        DecimalToUART(ch,(UCHAR *)&MsgParams[0]);
                        ATSendStringToUART((UCHAR *)&MsgParams[0],MsgParams[0]);
                        SendCharToUART(atcmdptr,LF);
            
                        SendResponse(atcmdptr,COMOK);            
    
                        break;
                        }
                     }

                SendResponse(atcmdptr,COMERROR);            
                break;
             }
        // After AT+MS= read next character and incr cntr
            if(cntr == atcmdptr->icount)
            {
                SendResponse(atcmdptr,COMERROR);            
                break;
            }

            ch = *aiCurBuf++;
            cntr++;

            if(cntr == atcmdptr->icount)
            {
                if(ch=='?')
                {
                    SendString(atcmdptr,SELECTMOD);
                    SendResponse(atcmdptr,COMOK);            
                    break;
               }
               else
               {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }
            }

            if(ch <= 0x30 && ch >= 0x39)
            {
                SendResponse(atcmdptr,COMERROR);            
                break;
            }

            if(ch == 0x30 || ch==0x31 || ch==0x32 || ch==0x33 || ch==0x38 || ch == 0x39)
            {
                if(ch==0x30)
                {
                    atcmdptr->ModulationMode=0;
                    atcmdptr->ModMode = 17;
                }
                else if(ch == 0x31)
                {
                    atcmdptr->ModulationMode=1;
                    atcmdptr->ModMode = 64;
                }
                else if(ch == 0x32)
                {
                    atcmdptr->ModulationMode=2;
                    atcmdptr->ModMode = 9;
                }
                else if(ch ==0x33)
                {
                    atcmdptr->ModulationMode=3;
                    atcmdptr->ModMode = 33;
                }
                else if(ch ==0x38)
                {
                    atcmdptr->ModulationMode=8;
                    atcmdptr->ModMode = 5;
                }
                else if(ch ==0x39)
                {
                    atcmdptr->ModulationMode=9;
                    atcmdptr->ModMode = 3;
                }

                ch = *aiCurBuf++;
                cntr++;

                if(cntr== atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }

                if(ch !=',')
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }

                ch = *aiCurBuf++;
                cntr++;

                if(cntr== atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }

                if(ch =='0')
                {
                    atcmdptr->commands[ATMODE] = 0;
                }
                else if(ch == '1')
                {
                    atcmdptr->ModMode = 0;             /* Enabling V.8 */
                    atcmdptr->commands[ATMODE] = 1;
                }
                else
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }

                ch = *aiCurBuf++;
                cntr++;

                if(ch !=',')
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }

                if(cntr== atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }

                ch = *aiCurBuf++;
                cntr++;

                if(cntr == atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }

                if(ch <= 0x30 && ch >= 0x39)
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }

                val =0;
                while(ch >= 0x30 && ch <= 0x39)
                {
                    val = val * 10;
                    val = val + (ch - 0x30);

                    if(cntr == atcmdptr->icount)
                        break;

                    ch = *aiCurBuf++;
                    cntr++;
                }

                if(cntr == atcmdptr->icount)
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }


                if(val<300 || val>14400)
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }

                else if(ch == ',')
                {
                    atcmdptr->ModRate[0]=val;
                    ch = *aiCurBuf++;
                    cntr++;

                    if(cntr == atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);            
                        break;
                    }

                    val =0;
                    if(ch <= 0x30 && ch >= 0x39)
                    {
                        SendResponse(atcmdptr,COMERROR);            
                        break;
                    }

                    while(ch >= 0x30 && ch <= 0x39)
                    {
                        val = val * 10;
                        val = val + (ch - 0x30);

                        if(cntr == atcmdptr->icount)
                            break;

                        ch = *aiCurBuf++;
                        cntr++;
                    }

                    if(val>14400)
                    {
                        atcmdptr->ModRate[1]= 14400;
                        SendResponse(atcmdptr,COMERROR);            

                        break;
                    }
                    else if(val>=300 && val<=14400)
                    {

                        if(val<atcmdptr->ModRate[0])
                        {
                            SendResponse(atcmdptr,COMERROR);            
                            break;
                        }

                        atcmdptr->ModRate[1]= val;
                        SendConfigParamsToDP(atcmdptr);
                        SendResponse(atcmdptr,COMOK);            
                    }
                    else
                    {
                        SendResponse(atcmdptr,COMERROR);            
                        break;
                    }
    
                }

            }
        }
    }
    }
    else
    {
        SendResponse(atcmdptr,COMERROR);            
        break;
    }
    }

        else if(ch == 'S' || ch == 's')
        {
            if(!atcmdptr->Backcommand)
            {
                ch = *(aiCurBuf)++;
                cntr++;

                val = 0;
                if(ch <= 0x30 && ch >= 0x39)
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }
                while(ch >= 0x30 && ch <= 0x39)
                {
                    val = val * 10;
                    val = val + (ch - 0x30);

                    if(cntr == atcmdptr->icount)
                        break;

                    ch = *aiCurBuf++;
                    cntr++;
                }

                if(val>91)
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }

                SIndex = val;
       
                if(ch == '?')
                {
                    if(cntr != atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);            
                        break;
                    }
                                
                    if(SIndex == 91)
                    {
                        ch= atcmdptr->commands[ATS91];
                    }
                    else
                    ch= atcmdptr->commands[ATS0+SIndex];
                        
                    DecimalToUART(ch,(UCHAR *)&MsgParams[0]);
                    ATSendStringToUART((UCHAR *)&MsgParams[0],MsgParams[0]);
                    SendResponse(atcmdptr,COMOK);                                            
                
                 }
                else if(ch == '=')
                {
                    ch = *aiCurBuf++;
                    cntr++;

                    val = 0;

                    while(ch >= 0x30 && ch <= 0x39)
                    {
                        val = val * 10;
                        val = val + (ch - 0x30);

                        if(cntr == atcmdptr->icount)
                        break;

                        ch = *aiCurBuf++;
                        cntr++;
                    }

                    if(val>255)
                    {
                        SendResponse(atcmdptr,COMERROR);            
                        break;
                    }

                    SValue = val;
                    ProcessSRegUpdate(atcmdptr,SIndex,SValue);

                    SendResponse(atcmdptr,COMOK);            

                }
                else
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }
                }
                else
                {
                    SendResponse(atcmdptr,COMERROR);            
                    break;
                }

                }//End of S

                else if(ch=='O' || ch=='o')
                {

                    if(cntr== atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);            
                        break;
                    }
                    if(atcmdptr->Backcommand)
                    {
                        ch = *(aiCurBuf)++;
                        cntr++;
                        if(cntr!= atcmdptr->icount)
                        {
                            SendResponse(atcmdptr,COMERROR);            
                            break;
                        }

                        if(ch == '?')
                        {
                            if(atcmdptr->DPConnect == 1)
                            {
                                SendString(atcmdptr,CONNECTMODE);
                                SendResponse(atcmdptr,COMOK);    
                            }

                            else if(atcmdptr->DPConnect == 2)
                            {
                                SendString(atcmdptr,RETRAINMODE);
                                SendResponse(atcmdptr,COMOK);            
                                
                            }

                        }

                        else if(ch==0x30)
                        {
                            /* Leave Command mode and return to Data Mode */

                            atcmdptr->DPConnect=1;
                            MsgParams[0] = ONLINEDATAMODE;
                            ATIndicateStatus(SET_H_MODE,MsgParams);
                            SendResponse(atcmdptr,COMCONNECT);
                        }

                        else if(ch==0x31)
                        {
                             ATSendMsgToDP(mSTARTRETRAIN,0,(UCHAR *)&MsgParams[0]);    

                             atcmdptr->DPConnect=2;
                             MsgParams[0] = ONLINEMODE;
                             ATIndicateStatus(SET_H_MODE,MsgParams);
                        }

                        else
                        {
                            if(!QuietControl && !VerboseControl)
                                SendString(atcmdptr,COM4);
                            else if(!QuietControl && VerboseControl)
                                SendString(atcmdptr,COMERROR);
                            break;/*ERROR */
                        }
                    }
                    else
                    {
                        SendResponse(atcmdptr,COMERROR);            
                        break;/*ERROR */
                    }

        }

        else if(ch=='W' || ch=='w')
        {
            if(cntr== atcmdptr->icount)
            {
                SendResponse(atcmdptr,COMERROR);            
                break;
            }
                ch = *(aiCurBuf)++;
                cntr++;
                    if(cntr!= atcmdptr->icount)
                    {
                        SendResponse(atcmdptr,COMERROR);            
                        break;
                    }

                if(ch==0x30)
                {
                    atcmdptr->ConnectPattern = 0;  //DTE Speed = 1, DCE Speed = 0
                    SendResponse(atcmdptr,COMOK);            

                }
                else if(ch==0x31)
                {
                    atcmdptr->ConnectPattern = 1;  //protocol = 1, DCE Speed = 0
                    SendResponse(atcmdptr,COMOK);

                }
                else if(ch==0x32)
                {
                    atcmdptr->ConnectPattern = 2;  //DCE Speed = 1
                    SendResponse(atcmdptr,COMOK);

                }
                else
                {
                    SendResponse(atcmdptr,COMERROR);
                    break;/*ERROR */
                }
        }
    
        else
        {
            SendResponse(atcmdptr,COMERROR);
            break;
        }

    } // End of While

}//End of Function


/*-------------------------------------------------------------------------
 Function Name: ProcessSRegUpdate
 Description  : This function is used to update the S-Register value
 Input        : AT_Conmmand Structure pointer,S-reg Index, S-Reg value
 Output       : None 
--------------------------------------------------------------------------*/

void ProcessSRegUpdate(AT_COMMAND *atcmdptr,INT SIndex, INT SValue)
{
    UCHAR MsgParams[2];
    
    switch(SIndex)
    {
        case 0:
            atcmdptr->commands[ATS0] = SValue;
            break;
        case 1:
            break;
        case 6:
            atcmdptr->commands[ATS6] = SValue;
            break;
        case 7:
            atcmdptr->commands[ATS7] = SValue;
            break;
        case 8:
            atcmdptr->commands[ATS8] = SValue;
            break;
        case 9:
            atcmdptr->commands[ATS9] = SValue;
            break;
        case 10:
            atcmdptr->commands[ATS10] = SValue;
            break;
        case 11:
            atcmdptr->commands[ATS11] = SValue;
            break;
        case 12:
            atcmdptr->commands[ATS12] = SValue;
            break;
        case 18:
            atcmdptr->commands[ATS18] = SValue;
            break;
        case 86:
            atcmdptr->commands[ATS86] = SValue;
            break;
        case 91:
            atcmdptr->commands[ATS91] = SValue;

            //Configure data pump signal transmit level

            MsgParams[0] = atcmdptr->commands[ATS91];        
              ATSendMsgToDP(mSETTXLEVEL,1,(UCHAR *)&MsgParams[0]);    

            break;
        
        default:                        
            break;
    
    }

    SendConfigParamsToDP(atcmdptr);
}

/*-------------------------------------------------------------------------
 Function Name: SendCharToUART
 Description  : This function is used to send a character to the host layer
 Input        : AT_Conmmand Structure pointer,Character
 Output       : None 
--------------------------------------------------------------------------*/

void SendCharToUART(AT_COMMAND *atcmdptr,CHAR ch)
{
    atcmdptr->UARTTxBuf[0] = ch;
    ATSendStringToUART(&atcmdptr->UARTTxBuf[0],1);
}

/*-------------------------------------------------------------------------
 Function Name: DecimalToUART
 Description  : This function is used to convert the hex valu to the proper
                ascii format to transfer to host layer
 Input        : Number to convert,Output buffer
 Output       : None 
--------------------------------------------------------------------------*/

void DecimalToUART(INT number,UCHAR *Buffer)
{
    INT R,Q,start=0,i=1;
    INT DivF=1000;
    R = Q = number;
    if(number < 10)
    {
        Q=Q+0x30;
        Buffer[1] = Q;
        Buffer[0] = 1;
        return;
    }
    while(1)
    {
        Q = R/DivF;
        R = R % DivF;
        DivF = DivF/10;
        if(!start)
        {
            if(Q)
            {
                start = 1;
            }
        }
        if(start) 
        {
            Q=Q+0x30;
            Buffer[i++] = Q;
        }    
    
        if(!DivF) break;
      }

    Buffer[0] = i-1;
}

/*-------------------------------------------------------------------------
 Function Name: GetConnectRate
 Description  : This function is used to get the pointer to a connect rate 
                response in response buffer
 Input        : AT_Conmmand Structure pointer,Character,BitRate
 Output       : None 
--------------------------------------------------------------------------*/

void GetConnectRate(AT_COMMAND *atcmdptr,INT BR)
{
    INT BRString,Length;
    
    if(BR == 2400) BRString = COM2400;
    else if(BR == 1200) BRString = COM1200;
    else if(BR == 14400) BRString = COM14400;
    else if(BR == 12000) BRString = COM12000;
    else if(BR == 9600) BRString = COM9600;
    else if(BR == 7200) BRString = COM7200;
    else if(BR == 4800) BRString = COM4800;
    else if(BR == 300) BRString = COM300;
    else if(BR == 75) BRString = COMV23ORG;
    else BRString = COMV23ANS;
 
    Length = GetString(comStringBufPtr+BRString,&atcmdptr->UARTTxBuf[0]);
    ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);                
}

/*-------------------------------------------------------------------------
 Function Name: SendResponse
 Description  : This function is used to send the response code to the host 
                layer
 Input        : AT_Conmmand Structure pointer,Response
 Output       : None 
--------------------------------------------------------------------------*/

void SendResponse(AT_COMMAND *atcmdptr,INT Response)
{
    CHAR Quiet,Verbose;
    INT Length;

    Quiet = atcmdptr->commands[ATQ];
    Verbose = atcmdptr->commands[ATV];

    switch(Response)
    {
        case COMOK:
            if(!Quiet && !Verbose)
                SendString(atcmdptr,COM0);
            else if(!Quiet && Verbose)
                SendString(atcmdptr,COMOK);
            break;

        case COMERROR:
                if(!Quiet && !Verbose)
                    SendString(atcmdptr,COM4);
                else if(!Quiet && Verbose)
                    SendString(atcmdptr,COMERROR);
                break;

        case NOCARRIER:
            if(!Quiet && !Verbose)
                SendString(atcmdptr,COM3);
            else if(!Quiet && Verbose)
                SendString(atcmdptr,NOCARRIER);
            break;

        case COMCONNECT:
            if(atcmdptr->ConnectPattern == 0)
            {
                Length = GetString(comStringBufPtr+COMCONNECT,&atcmdptr->UARTTxBuf[0]);
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);
                Length = GetString(comStringBufPtr+COMDTE_19200,&atcmdptr->UARTTxBuf[0]); 
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);            
            }
            else if(atcmdptr->ConnectPattern ==1)
            {
                Length = GetString(comStringBufPtr+CARRIER,&atcmdptr->UARTTxBuf[0]);
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);                

                GetConnectRate(atcmdptr,atcmdptr->DPBitRate);
            }
            else
            {
                Length = GetString(comStringBufPtr+COMCONNECT,&atcmdptr->UARTTxBuf[0]);
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);                
                GetConnectRate(atcmdptr,atcmdptr->DPBitRate);
            }                         
            break;
        case COMLAPM:
            if(atcmdptr->ConnectPattern ==1)
            {
                Length = GetString(comStringBufPtr+COMPROTOCOL,&atcmdptr->UARTTxBuf[0]);
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);                

                Length = GetString(comStringBufPtr+COMLAPM,&atcmdptr->UARTTxBuf[0]);
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);                

                Length = GetString(comStringBufPtr+COMCONNECT,&atcmdptr->UARTTxBuf[0]);
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);                

                Length = GetString(comStringBufPtr+COMDTE_19200,&atcmdptr->UARTTxBuf[0]); 
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);                

            }

            break;
        case COMNONE:
            if(atcmdptr->ConnectPattern ==1)
            {
                Length = GetString(comStringBufPtr+COMPROTOCOL,&atcmdptr->UARTTxBuf[0]);
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);                

                Length = GetString(comStringBufPtr+COMNONE,&atcmdptr->UARTTxBuf[0]);
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);                

                Length = GetString(comStringBufPtr+COMCONNECT,&atcmdptr->UARTTxBuf[0]);
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);                

                Length = GetString(comStringBufPtr+COMDTE_19200,&atcmdptr->UARTTxBuf[0]); 
                ATSendStringToUART(&atcmdptr->UARTTxBuf[0],Length);                

            }

            break;
        default:
            break;            

    }

}

/*-------------------------------------------------------------------------
 Function Name: SendConfigParamsToDP
 Description  : This function is used to send the configuration parameters 
                to host, which will confihure the data pump
 Input        : AT_Conmmand Structure pointer
 Output       : None 
--------------------------------------------------------------------------*/

void SendConfigParamsToDP(AT_COMMAND *atcmdptr)
{
    UINT MsgParams[10];

    MsgParams[0] = atcmdptr->commands[ATS91];
    MsgParams[1] = atcmdptr->ModMode;
    MsgParams[2] = atcmdptr->ModRate[0];
    MsgParams[3] = atcmdptr->ModRate[1];
    MsgParams[4] = atcmdptr->commands[ATDIALTONE];
    MsgParams[5] = atcmdptr->commands[ATBUSY];
    MsgParams[6] = atcmdptr->commands[ATS6];
    MsgParams[7] = atcmdptr->commands[ATS7];
    MsgParams[8] = atcmdptr->commands[ATV42];
    MsgParams[9] = atcmdptr->commands[ATANDK];

    ATIndicateStatus(MODEM_CONFIG,MsgParams);
}

/*-------------------------------------------------------------------------
 Function Name: DPIndicateStatus
 Description  : This function is called by the host layer to indicate the
                status of the data pump
 Input        : AT_Conmmand Structure pointer, Parameter buffer
 Output       : None 
--------------------------------------------------------------------------*/

void DPIndicateStatus(CHAR STATUS_ID,UINT *DPParams)
{

    AT_COMMAND *atcmdptr;
    atcmdptr = ATChnBaseAddress;

    switch(STATUS_ID)
    {
        case DP_CONNECT:
            atcmdptr->DPConnect = 1;
            atcmdptr->DPBitRate = DPParams[0];
            SendResponse(atcmdptr,COMCONNECT);
            break;

        case DP_ASYNC_CONNECT:
            SendResponse(atcmdptr,COMNONE);
            break;
        
        case DP_LAPM_CONNECT:
            SendResponse(atcmdptr,COMLAPM);
            break;

        case DP_LOCAL_RETRAIN:
            atcmdptr->RetrainsRequested++;
            break;

        case DP_REMOTE_RETRAIN:
            atcmdptr->RetrainsGranted++;
            break;
        
        case SEND_OK_RESPONSE:
            SendResponse(atcmdptr,COMOK);
            break;            

        case DP_CP_STATUS:
               SendString(atcmdptr,DPParams[0]) ;            
            if(DPParams[0] == COMRING)
            {
                if(++atcmdptr->RingCounter == atcmdptr->commands[ATS0])
                {
                    atcmdptr->RingCounter = 0;
                    ATIndicateStatus(START_ANSWER_MODE,0);
                }
                atcmdptr->commands[ATS1] = atcmdptr->RingCounter;
            }
            break;

        case SM_HANGUP:
            SendResponse(atcmdptr,COMOK);
            atcmdptr->Backcommand=0;
            atcmdptr->KeyNo=0;
            atcmdptr->escapecount=0;
            break;
        case V42_ERROR:
            SendString(atcmdptr,NOCARRIER);
            atcmdptr->Backcommand=0;
            atcmdptr->KeyNo=0;
            atcmdptr->escapecount=0;
            break;

        default:
            break;
    }
}

#endif

/*-------------------------------------------------------------------------
    END OF FILE
--------------------------------------------------------------------------*/
