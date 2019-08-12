

//*****************************************************************************
//  FILE NAME: OPTIONS.H
//*****************************************************************************

/******************************************************************************
Compile time option definitions for DTMF Generation and Detection
and display on UART and LCD Panel
******************************************************************************/

/******************************************************************************

UART_ENABLE     - Enable the UART Modules (Both Receive and Transmit)
LCD_ENABLE      - Enable the LCD display on dsPICDEM.net Connectivity board
SWITCH_DIGIT    - In DTMF generation - Detection Loop Back read the digits in
                  a buffer whenever the switch S2 is pressed

DTMF generation and Detection Test in Loop Mack Mode
-----------------------------------------------------

DTMF_GEN_DET_LB - DTMF generation module output is looped back to
                  the detection module.

                  UART - LCD: Digits read from the UART(hyper terminal) are
                  transmitted and detected and displayed on LCD of connectivity
                  board

                  SWITCH (S2) - LCD: Digits stored in a buffer are transmitted
                  one by one when the switch S1 is pressed and detected digits
                  are displayed on the LCD of connectivity board

DTMF Detection Test
-------------------

Disable the option DTMF_GEN_DET_LB and test the DTMF detection as follows:

1.  Connect a telephone handset to one line of a analog telephone exchange
2.  Connect the connectivity board to the another line of the telephone
    exchange.
3.  Run the DTMF detection alogorithm and which will do all the initializations
3.  Dial the connectivity board from the telephone handset
4.  Go off-hook by pressing the switch S1 on the connectivity board.
5   Press the digits on the telephone handset and the digits detected are
    displayed on the board LCD panel (LCD_ENABLE) or UART(UART_ENABLE).

******************************************************************************/

//#define DTMF_GEN_DET_LB

#define UART_ENABLE
#define LCD_ENABLE

#ifdef DTMF_GEN_DET_LB
#define SWITCH_DIGIT
#endif


//*****************************************************************************
//   END OF FILE
//*****************************************************************************

