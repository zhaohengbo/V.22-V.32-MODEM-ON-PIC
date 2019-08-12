

//============================================================================
#include "options.h"
#include "detconst_c.h"
#include "lcd.h"
//============================================================================

#define INDATABUFLEN     10
#define OUTDATABUFLEN    10 

//PCM samples structure
PCMDATASTRUCT Pcm[1];

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
 UCHAR DTMFTxString[20];

 INT Digit;
 CHAR InDataBuf[INDATABUFLEN];
 CHAR OutDataBuf[OUTDATABUFLEN];
 UCHAR    OutDataW,OutDataR;
 UCHAR    InDataW,InDataR;
 UCHAR UARTTxEmpty;
 UCHAR DigitCount;
//============================================================================
INT DigitStatus;
INT HookStatus;
CHAR SwitchDigitString[12] = {0,1,2,3,4,5,6,7,8,9,14,15};
CHAR DigitIndex = 0;
//============================================================================

const char package_name[] = "   DTMF Demo";
const char package_version[] = " Revision 1.0";

//============================================================================
void Init_Hardware(void);
void ResetCodecBuffers(void);
void SendDigitToUART(CHAR);
void PutDigitOnLCD(CHAR);
void GetDtmfDigits(void);
//============================================================================

main()
{
    INT ProcessType, InputType,i,Status;
    CHAR DTMFDigit;

    Pcm[0].FrameLength = 80;

	/* Initialize Hardware */
    Init_Hardware();

	/* Initialize DTMF Generation Module */
    InitDTMFGen(&DTMFTxString[0],0);

    InputType = LEFT_JUSTIFIED;
    
    /* Initialize DTMF Detection Module */
	DTMFInit();

    HookStatus = 0;
    /* wait until switch S1 is pressed to start demo */
    while(!HookStatus);

	/* Execute function call to generate off-hook to sieze PSTN line */
	go_off_hook(0x60);

    ResetCodecBuffers();

	while(1)
	{
        while(CodecIntrCntr < Pcm[0].FrameLength);
        CodecIntrCntr = 0;

        GetDtmfDigits();

        Pcm[0].IN = &CodecRxBuffer[CodecRxRIndex];
        Pcm[0].OUT = &CodecTxBuffer[CodecTxWIndex];

        CodecRxRIndex += Pcm[0].FrameLength;
        if(CodecRxRIndex >= CODECBUFLEN) CodecRxRIndex = 0;

#ifdef DTMF_GEN_DET_LB
        Status = DTMFGen(Pcm[0].OUT);
        for(i=0;i<Pcm[0].FrameLength;i++)
        {
            Pcm[0].IN[i] = Pcm[0].OUT[i];
        } 
#endif

        ProcessType = DTMFDetection(InputType,Pcm[0].IN,&Digit);

        if(ProcessType == DIGIT_DETECTED)
        {
            if(Digit == 14)
            {
                DTMFDigit = '*';
            }
            else if(Digit == 15)
            {
                DTMFDigit = '#';
            }
            else
            {
                 DTMFDigit = (CHAR)(Digit+0x30);
            }

            #ifdef UART_ENABLE
            SendDigitToUART(DTMFDigit);
            #endif

            #ifdef LCD_ENABLE
            PutDigitOnLCD(DTMFDigit);
            #endif
        }

        for (i=0;i<Pcm[0].FrameLength;i++) 
        {
            CodecTxBuffer[CodecTxWIndex++] = (Pcm[0].OUT[i] & 0xfffe);
            if(CodecTxWIndex >= CODECBUFLEN) CodecTxWIndex = 0;
        }

    }
}

void Init_Hardware(void)
{
    Init_PORTS();             // initialize Ports
    Init_DCI();               // initialize DCI

    ResetCodecBuffers();
    Init_Si3021();
    ResetCodecBuffers();

#ifdef UART_ENABLE
    Init_Uart1();
#endif

#ifdef LCD_ENABLE
    Init_LCD();               // initialize LCD
    home_clr();
    puts_lcd( ( char * ) &package_name[0], (sizeof(package_name)) - 1 );
    line_2();
    puts_lcd( ( char * ) &package_version[0], (sizeof(package_version)) - 1 );
#endif

    Init_INTpin();
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

#ifdef UART_ENABLE
void SendDigitToUART(CHAR DTMFDigit)
{
    OutDataBuf[OutDataW++] = DTMFDigit;
	if (OutDataW == OUTDATABUFLEN) OutDataW = 0;
    if(UARTTxEmpty) SendCharToUARTTx();                        
}
#endif

#ifdef LCD_ENABLE
void PutDigitOnLCD(CHAR DTMFDigit)
{
    char LCDMsgString[20],Length;

    LCDMsgString[0] = DTMFDigit;
    Length = 1;

    home_clr();
    puts_lcd( ( char * ) &LCDMsgString[0], Length);
}
#endif

void GetDtmfDigits(void)
{
    CHAR status,i,digit;

#ifdef UART_ENABLE
    status = InDataW - InDataR;
    if(status)
    {
        if(status < 0) status += INDATABUFLEN;

        for(i=0;i<status;i++)
        {
           
           digit = InDataBuf[InDataR++];
           if(digit == 0x2A) digit = 14;
           else if(digit == 0x23) digit = 15;
           else digit -= 0x30;

           DTMFTxString[i] = digit;
           if(InDataR == INDATABUFLEN) InDataR = 0;
        }
        InitDTMFGen(&DTMFTxString[0],status);
    }
#endif

#ifdef SWITCH_DIGIT
    if(!DigitStatus) return;
    DTMFTxString[0] = SwitchDigitString[DigitIndex++];
    if(DigitIndex == 12) DigitIndex = 0;
    DigitStatus = 0;
    InitDTMFGen(&DTMFTxString[0],0x1);
#endif

}

//============================================================================
//============================================================================

