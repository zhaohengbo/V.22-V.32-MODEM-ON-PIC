
/******************************************************************************
;                                                                             *
;    Author              :                                                    *
;    Company             :                                                    *
;    Filename            :  lcd.c                                             *
;    Date                :  05/24/2004                                        *
;                                                                             *
;                                                                             *
;    Other Files Required: p30F6014.gld, p30f6014.inc                         *
;    Tools Used: MPLAB IDE       : 6.50.00                                    *
;                ASM30 Assembler : 1.20.01                                    *
;                Linker          : 1.20.01                                    *
;                                                                             *
;    Devices Supported by this file:                                          *
;                        dsPIC 30F6014                                        *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Additional Notes:                                                        *
;                                                                             *
;                                                                             *
;*****************************************************************************/

/*-----------------------------------------------------------------------------
    INCLUDE FILES
 -----------------------------------------------------------------------------*/
 		#include "p30F6014.h"
		#include "lcd.h"
		#include "delay.h"
	
		
/* 
   For Connectivity board here are the data and control signal definitions
   RS -> RA6
   E  -> RA7
   RW -> RB11 (used for SRAM WE signal as well)
   DATA -> RD0 - RD7   
*/

// Control signal data pins 
#define  RW  PORTBbits.RB11       // LCD R/W signal
#define  RS  PORTAbits.RA6        // LCD RS signal
#define  E   PORTAbits.RA7        // LCD E signal 

// Control signal pin direction 
#define  RW_TRIS	TRISBbits.TRISB11 
#define  RS_TRIS	TRISAbits.TRISA6 
#define  E_TRIS		TRISAbits.TRISA7

// Data signals and pin direction
#define  DATA      LATD           // Port for LCD data
#define  DATAPORT  PORTD
#define  TRISDATA  TRISD          // I/O setup for data Port



/****************************************************************************/
/*****	LCD SUBROUTINE  *****/

void Init_LCD( void )             // initialize LCD display
{
	// 15mS delay after Vdd reaches 4.5Vdc before proceeding with LCD initialization
	// not always required and is based on system Vdd rise rate
	Delay15mS();                  // 15ms delay

	/* set initial states for the data and control pins */
	LATD &= 0xFF00;	
    RW = 0;                       // R/W state set low
	RS = 0;                       // RS state set low
	E = 0;                        // E state set low

	/* set data and control pins to outputs */
	TRISD &= 0xFF00;
 	RW_TRIS = 0;                  // RW pin set as output
	RS_TRIS = 0;                  // RS pin set as output
	E_TRIS = 0;                   // E pin set as output

	/* 1st LCD initialization sequence */
	DATA &= 0xFF00;
    DATA |= 0x0038;
    Nop();
    E = 1;	
    Nop();
    Nop();
    Nop();
    E = 0;                        // toggle E signal
   	Delay5mS();                   // 5ms delay
   
   
	/* 2nd LCD initialization sequence */
	DATA &= 0xFF00;
    DATA |= 0x0038;
    Nop();
    E = 1;	
    Nop();
    Nop();
    Nop();	
    E = 0;                        // toggle E signal
    Delay200uS();                 // 200uS delay
   
      
	/* 3rd LCD initialization sequence */
	DATA &= 0xFF00;
    DATA |= 0x0038;
    Nop();
    E = 1;		
    Nop();
    Nop();
    Nop();	
    E = 0;                        // toggle E signal
    Delay200uS();                 // 200uS delay
   
    lcd_cmd( 0x38 );              // function set
    lcd_cmd( 0x0C );              // Display on/off control, cursor blink off	
    lcd_cmd( 0x06 );			  // entry mode set
}


void lcd_cmd( char cmd )          // subroutiune for lcd commands
{
	TRISD &= 0xFF00;              // ensure RD0 - RD7 are outputs
	DATA &= 0xFF00;               // prepare RD0 - RD7
    DATA |= cmd;                  // command byte to lcd
    Nop();
	RW = 0;                       // ensure RW is 0
    RS = 0;
    E = 1;                        // toggle E line
    Nop();
    Nop();
    Nop();
    E = 0;
    Delay5mS();                   // 5ms delay
}


void lcd_data( char data )        // subroutine for lcd data
{
	TRISD &= 0xFF00;              // ensure RD0 - RD7 are outputs
	RW = 0;       				 // ensure RW is 0
    RS = 1;                       // assert register select to 1
	DATA &= 0xFF00;               // prepare RD0 - RD7
    DATA |= data;                 // data byte to lcd
    Nop();
    E = 1;				
 	Nop();
    Nop();
    Nop();
    E = 0;                       // toggle E signal
    RS = 0;                      // negate register select to 0
    Delay200uS();                 // 200uS delay
}

// Control signal data pins 


void puts_lcd( unsigned char *data, unsigned char count ) // data from SRAM
{
  	while ( count )
	{
		lcd_data( *data++ );
		count --;
	}	
}


/*********************************************************************
*                                                                    *
*                       Software License Agreement                   *
*                                                                    *
*   The software supplied herewith by Microchip Technology           *
*   Incorporated (the "Company") for its dsPIC controller            *
*   is intended and supplied to you, the Company's customer,         *
*   for use solely and exclusively on Microchip dsPIC                *
*   products. The software is owned by the Company and/or its        *
*   supplier, and is protected under applicable copyright laws. All  *
*   rights are reserved. Any use in violation of the foregoing       *
*   restrictions may subject the user to criminal sanctions under    *
*   applicable laws, as well as to civil liability for the breach of *
*   the terms and conditions of this license.                        *
*                                                                    *
*   THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION.  NO           *
*   WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING,    *
*   BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND    *
*   FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE     *
*   COMPANY SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL,  *
*   INCIDENTAL OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.  *
*                                                                    *
*********************************************************************/

// -----------------------------------------------------------------------------
//         END OF FILE
// -----------------------------------------------------------------------------
