
//============================================================================
#include "smua_ol.h"
#include "api_c.h"
#include "p30f6014.h"
#include "lcd.h"
#include "datatype.h"

//============================================================================

extern void display( void );

//============================================================================
// Soft-Modem configuration parameters
//============================================================================

#define ENABLE_AUTO          0
#define ENABLE_V8            1
#define ENABLE_V32BIS        2 
#define ENABLE_V32           4
#define ENABLE_V22           8
#define ENABLE_V21           16
#define ENABLE_V23           32
#define ENABLE_B103          64

#define SM_TXLEVEL           12        // range 0 - 12 (-12dB)
#define SM_SPEAKER_VOLUME    1         // range 0 - 3
#define SM_LOOBACK           0
#define SM_ORIGINATE         1
#define SM_ANSWER            2
#define SM_MODULATION_MODE   ENABLE_AUTO
#define SM_BITRATE           14400
#define SM_V42ENABLE         1

//============================================================================
// Uart Flow control types
//============================================================================

#define NO_FLOW_CONTROL          0
#define HARDWARE_FLOW_CONTROL    1
#define SOFTWARE_FLOW_CONTROL    2 

//============================================================================
// Software flow control commands for UART 
//============================================================================

#define XOF_DC3           19
#define XON_DC1           17

//============================================================================
// Transmit and Receive data buffers(circular buufers) length
//============================================================================

//Length of the buffer used to store the data to be sent to DP for modulation
#define INDATABUFLEN     128     
                                    
//Length of the buffer used to store the Received data
#define OUTDATABUFLEN    128 

//============================================================================
// Maximum transmit data size
//============================================================================

#define MAXTXBYTES_HIGHBR 20
#define MAXTXBYTES_LOWBR  1

//============================================================================
//Transmit and Receive data buffers(circular buffers)
//============================================================================

 //Buffer used to store the data to be sent to data pump for modulation
 //User application writes system data to this buffer
 CHAR InDataBuf[INDATABUFLEN];

 //Buffer used to store the data received
 //User application reads data from this buffer
 CHAR OutDataBuf[OUTDATABUFLEN];

 //Read and write indices for the InDataBuf and OutDataBuf    
 UCHAR    InDataW,InDataR;
 UCHAR    OutDataW,OutDataR;

 //Maximum transmit data
 UCHAR    MaxTxBytes;
 
//============================================================================
// Variables used for controlling the data tranfer to/from UART
//============================================================================

 UCHAR DTEXoff;
 UCHAR UARTTxEmpty;
 UCHAR UARTFlowControl;
 INT HostXoffLimit,HostXonLimit;

//============================================================================
// Variable used to indicate the connection establishment
//============================================================================

 UCHAR SMConnect;

 // Variable used to terminate call
 UCHAR TermCall;
 
 // Variables used for status on connection
 UCHAR ConnType, DPModType, display_count;
 UINT Bps;
	 
//============================================================================
// Soft-Modem configuration parameters. SM_CONFIG structure defined in SMUL_OL.h
//============================================================================

 SM_CONFIG SM_Config_Params;

//============================================================================
// Function definitions for Soft-Modem inner layer functions
//============================================================================

void Configure_SoftModem(SM_CONFIG *);
UCHAR Start_SoftModem(void);

//============================================================================
// Function definitions for functions used to control the UART data flow
//============================================================================

void CheckFlowControl(void);
void SendXonToDTE(void);
void SendXoffToDTE(void);

//============================================================================
// Main Function
//============================================================================
INT main(void)
{
    UCHAR CallStatus;

	Init_LCD();               // initialize LCD
	home_clr();
    puts_lcd( " V.32bis Modem  ", 16 );
    line_2();
    puts_lcd( "Demo, S3->Begin ", 16 );
    
    while ( PORTAbits.RA14 );
   	Delay_1S();
     
    home_clr();
    puts_lcd( "Enter Modem Mode", 16 );
    line_2();
    puts_lcd( "S1->ORG  S3->ANS", 16 );
    
    	
    /* S1 switch selects Originate mode, S3 switch selects Answer mode */
    while ( 1 )
    {	
		if  ( !PORTAbits.RA12 ) {
			SM_Config_Params.SMMode = SM_ORIGINATE;
			SM_Config_Params.DialString[8] = 2;   
			break;
		}	
		if ( !PORTAbits.RA14 ) {
			SM_Config_Params.SMMode = SM_ANSWER;
			break;
		}
	}
	
   	/* Initialize INTx pin for S2 detect, used to terminate call for demo
   	   User code can set this flag in their code */
 	Init_INTpin();
	
    //Select hardware flow control for UART
    UARTFlowControl = HARDWARE_FLOW_CONTROL;

    //Initialize the UART on the connectivity board
    Init_Uart1();
    
	//Initialize ADC for demo purpose
	Init_ADC();

	//Set the desired Soft-Modem configuation parameters
    SM_Config_Params.DPTxLevel = SM_TXLEVEL;
    SM_Config_Params.SpeakerVolume = SM_SPEAKER_VOLUME;
    SM_Config_Params.DPModMode = SM_MODULATION_MODE;
    SM_Config_Params.MaxCnxRate = SM_BITRATE;
    SM_Config_Params.V42Enable = SM_V42ENABLE;

	SM_Config_Params.DialString[0] = 8;   // initializer defines length of digits to dial
	SM_Config_Params.DialString[1] = 9;   // phone number starts here
    SM_Config_Params.DialString[2] = 7;
    SM_Config_Params.DialString[3] = 9;
	SM_Config_Params.DialString[4] = 2;
    SM_Config_Params.DialString[5] = 4;
	SM_Config_Params.DialString[6] = 0;
   	SM_Config_Params.DialString[7] = 1;
   	
   	 	
	while ( 1 )
	{
    	home_clr();
    	puts_lcd( "  V.32bis Demo  ", 16 );
    	line_2();
    	puts_lcd( "S2-> Dial Number", 16 );

		if ( SM_Config_Params.SMMode == SM_ORIGINATE )		
			/* start modem upon detecting S2 closure */
			while ( PORTAbits.RA13 );
		
		if ( SM_Config_Params.SMMode == SM_ORIGINATE )
		{	
			line_2();
    		puts_lcd( "ORG_Mod: Running", 16 );
		}
		else 	
		{
			line_2();
    		puts_lcd( "ANS_Mod: Running", 16 );
    	}
    	
		// Clear terminate call flag
		TermCall = 0;
	
 		//Reset the Soft-Modem connect flag
    	SMConnect = 0;
    	
    	//Call the SMUA inner layer function to configure the parameters
    	Configure_SoftModem( &SM_Config_Params );

    	//Start the Soft-Modem handshake (calls ExecuteSoftModem in SMUL_IL.c file)
    	//Modem operation will stay in ExecuteSoftModem function until call is done
	   	CallStatus = Start_SoftModem(); 

   		/* we are returning here so check modem termination status */
   	 	if( CallStatus )
    	{
			home_clr();
    		puts_lcd( " Modem-> Halted ", 16 );
    		
          	if( CallStatus == NO_DIAL_TONE )
        	{
            	CallStatus = CallStatus;
               	line_2();
   				puts_lcd( "  No Dial Tone  ", 16 );
          	}
        	if( CallStatus == DETECT_BUSY_TONE )
        	{
          	  	CallStatus = CallStatus;
          	  	line_2();
   				puts_lcd( "Detect Busy Tone", 16 );
           	}
        	if( CallStatus == CONNECTION_TIMEOUT )
        	{
            	CallStatus = CallStatus;
            	line_2();
   				puts_lcd( " Connection T-O ", 16 );
       	 	}
       	   	if( CallStatus == HANGUP_COMPLETE )
        	{
            	CallStatus = CallStatus;
            	line_2();
   				puts_lcd( "Call Terminated ", 16 );
           	}
        	if( CallStatus == LOST_REMOTE_CARRIER )
        	{
            	CallStatus = CallStatus;
            	line_2();
   				puts_lcd( "  Carrier Lost  ", 16 );
 	  	 	}
        	if( CallStatus == REM_V42_DISCONNECT )
        	{
            	CallStatus = CallStatus;
            	line_2();
   				puts_lcd( " Rem V42 Discon.", 16 );
        	}
        	if( CallStatus == V42_PROTOCOL_ERROR )
        	{
            	CallStatus = CallStatus;
           		line_2();
   				puts_lcd( "V42 Protocol Err", 16 );
        	}
         	LATCbits.LATC2 = 1;
        	LATCbits.LATC3 = 1;
        	LATCbits.LATC4 = 1;

        	/* turn off DCI module */
        	DCICON1bits.DCIEN = 0;
			Delay_1S();
        }
 	}
}

/* Simple task for capturing ADC data and then converting to ASCII for display */
/* Converted data is loaded into InDataBuf for use by SMUA_IL.c */
void DummyTask( void )
{
	
	if ( SM_Config_Params.SMMode == SM_ORIGINATE )
    {
		/* toggle LED2 */
		LATCbits.LATC2 = ~LATCbits.LATC2;
		/* function takes ADC data, converts to ASCII then loads InDataBuf */
    	display();	
    }
	else if ( SM_Config_Params.SMMode == SM_ANSWER )
    {
		/* toggle LED3 */
		LATCbits.LATC4 = ~LATCbits.LATC4;
		/* function takes ADC data, converts to ASCII then loads InDataBuf */
    	display();	
    } 
}



//============================================================================
// SMUA_IL calls this function to get the data to be transmitted
//============================================================================

INT Get_SM_TransmitData( UCHAR *TxBuffer )
{
    INT TxLen,i;
   
    TxLen = InDataW - InDataR;
    if(!TxLen) return TxLen;

    if(TxLen < 0) TxLen += INDATABUFLEN;

    if(TxLen > MaxTxBytes)
    { 
        TxLen = MaxTxBytes;
    }

    for(i=0;i<TxLen;i++)
    {
        TxBuffer[i] = InDataBuf[InDataR++];
        if(InDataR == INDATABUFLEN) InDataR = 0; 
    }

    return TxLen;
}

//============================================================================
// SMUA_IL calls this function to give the received data to SMUA_OL
//============================================================================

void Put_SM_ReceiveData( UCHAR *RxBuffer, INT RxLen )
{
    INT i;

    for(i=0;i<RxLen ;i++) 
    {
        OutDataBuf[OutDataW++] = *RxBuffer++;
        if (OutDataW == OUTDATABUFLEN) OutDataW = 0;
    }
    if(UARTTxEmpty) SendCharToUARTTx();                        
}

//============================================================================
// SMUA_IL calls this function to indicate the type of connection establishment. 
// The modulation mode and the bit rate also indicated.

// ConnectType    - DP_CONNECT       - 1
//                - NON_LAPM_CONNECT - 2
//                - LAPM_CONNECT     - 4 
//                - RETRAIN_CONNECT  - 8    

// ModulationMode  - V32BIS_MODE     - 0x0001
//                 - V22BIS_MODE     - 0x0002
//                 - V23_MODE        - 0x0004
//                 - V21_MODE        - 0x0008
//                 - B103_MODE       - 0x0010
//
// BitRate         - 75, 300, 1200, 2400, 4800, 7200, 9600, 12000, 14400
//============================================================================

void SoftModem_Connect( UCHAR ConnectType, UCHAR ModulationMode, UINT BitRate )
{
	 /* Status information for main program, if desired */
	 ConnType = ConnectType;
	 DPModType = ModulationMode;
	 Bps = BitRate;

     SMConnect = 1;
     InDataR = InDataW = OutDataR = OutDataW = 0;
     MaxTxBytes = MAXTXBYTES_HIGHBR;

     DTEXoff = 0;
     HostXoffLimit = 80;
     HostXonLimit = 40;
     SendXonToDTE();

     if( (BitRate == 75) || (BitRate == 300) )
     {
         MaxTxBytes = MAXTXBYTES_LOWBR;
         HostXoffLimit = 80;
         HostXonLimit = 60;
     }
     
}

//============================================================================
// This function is called by the SMUA_IL every 5ms to poll the status of the
// SMUA_OL. In this function SMUA_OL can check the UART flow buffer status to
// control the data flow from UART. This function can also be used to 
// initiate call termination by returning a TRUE (1) from this function.
//============================================================================

UCHAR Poll_SMUA_OL_Status(void)
{
    if(SMConnect) CheckFlowControl();

	/* simple routine to blink LED at frame rate * 40 rate 
	   and to load up InDataBuf with ADC data */

	display_count ++;
	
	/* test if there is a connection */
    if( (SMConnect != 0)  &&  (display_count == 100) )
    {
    	display_count = 0;
    	
        if( InDataW == InDataR )
	    {
			ADCON1bits.ADON = 1;
		    DummyTask();
	    }
     }
	/* Check if call should be terminated */
	if ( !TermCall )
		/* Do not terminate call */
	    return 0;
	else 
		/* Reset terminate call flag */
		TermCall = 0;
		/* Terminate call */
		return 1;
}

//============================================================================
// Check the UART data flow and issue flow control commands
//============================================================================

void CheckFlowControl(void)
{
    INT status;

    status = InDataW - InDataR;
    if(status < 0) status += INDATABUFLEN;

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

//============================================================================
// Issue XON command to UART
//============================================================================

void SendXonToDTE(void)
{
	if(UARTFlowControl == NO_FLOW_CONTROL) return;

    if(UARTFlowControl == HARDWARE_FLOW_CONTROL) ClearRTS();

    if(UARTFlowControl == SOFTWARE_FLOW_CONTROL)
    {
        OutDataBuf[OutDataW++] = XON_DC1;
        if(OutDataW == OUTDATABUFLEN) OutDataW = 0;
        SendCharToUARTTx();
    }
}

//============================================================================
// Issue XOFF command to UART
//============================================================================

void SendXoffToDTE(void)
{
	if(UARTFlowControl == NO_FLOW_CONTROL) return;

    if(UARTFlowControl == HARDWARE_FLOW_CONTROL) SetRTS();

    if(UARTFlowControl == SOFTWARE_FLOW_CONTROL)
    {
        OutDataBuf[OutDataW++] = XOF_DC3;
        if(OutDataW == OUTDATABUFLEN) OutDataW = 0;
        SendCharToUARTTx();
    }
}



//============================================================================
//============================================================================
