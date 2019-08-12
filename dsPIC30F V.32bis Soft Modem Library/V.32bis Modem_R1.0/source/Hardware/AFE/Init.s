/******************************************************************************
;  Filename:               Init.S                                             *
;  Date:                   13th Nov,2003                                      *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.43.00.0                             *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  The initialization of different I/O Ports on dsPIC.                        *
;******************************************************************************
;  Init_PORTS                                                                 *
;  ======================                                                     *
;  Description: This function initializes the required I/O ports.             *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    Port, Tris, Lat, ADPCFG Registers                                        *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   0                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     Init_PORTS:                  33                                         *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;     None                                                                    *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     Init_PORTS:                   35                                        *
;                                                                             *
;*****************************************************************************/


; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

     .include "p30f6014.inc"

;..............................................................................
; Global Declarations:
;..............................................................................
        .global  _Init_PORTS
        .text

; -----------------------------------------------------------------------------
;  Description: Initialization of Ports
; -----------------------------------------------------------------------------
_Init_PORTS:

    /**********************************************************/
    /* PortA Requirements for dsPICDEM.net Connectivity Board */
;    CLR   PORTA                   ;set PortA output pin state to low
;    SETM  TRISA                   ;set all PortA pins as input
;    BCLR  TRISA, #RA6             ;set LCD_RS signal as output    
;    BCLR  TRISA, #RA7             ;set LCD_E signal as output

    /* SPARE PORTA pins */
;    BCLR  TRISA, #RA9             ;set SPARE PortA pin as output
;    BCLR  TRISA, #RA10            ;set SPARE PortA pin as output
                 

    /**********************************************************/
    /* PortB Requirements for dsPICDEM.net Connectivity Board */
    CLR   PORTB                   ;set PortB output pin state to low

    MOV   #0b1111111111000111, w0
    MOV   w0, ADPCFG
    ; #0b 1 1 1 1 1 1 1 1 1 1 0 0 0 1 1 1
    ;     | | | | | | | | | | | | | | | |____ set RB0 is digital
    ;     | | | | | | | | | | | | | | |______ set RB1 is digital
    ;     | | | | | | | | | | | | | |________ set AN2/RB2 (MCP42010 CS pin) is digital                 
    ;     | | | | | | | | | | | | |__________ set AN3/RB3 (TEMP sensor pin) is analog
    ;     | | | | | | | | | | | |____________ set AN4/RB4 (RP1 sensor pin) is analog
    ;     | | | | | | | | | | |______________ set AN5/RB5 (RP2 sensor pin) is analog
    ;     | | | | | | | | | |________________ (SPARE PIN) set AN6/RB6 is digital 
    ;     | | | | | | | | |__________________ (SPARE PIN) set AN7/RB7 is digital
    ;     | | | | | | | |____________________ (SPARE PIN) set AN8/RB8 is digital
    ;     | | | | | | |______________________ set AN9/RB9 is digital
    ;     | | | | | |________________________ set AN10/RB10 is digital
    ;     | | | | |__________________________ set AN11/RB11 is digital
    ;     | | | |____________________________ set AN12/RB12 (74HCT573 ALE pin) is digital
    ;     | | |______________________________ set AN13/RB14 (RealTek IORD pin) is digital
    ;     | |________________________________ set AN14/RB14 (RealTek IOWR pin) is digital
    ;     |__________________________________ set AN15/RB15 (RealTek RSTDRV pin) is digital
 
    
    CLR   TRISB                   ;set all PortB pins as output   
    BSET  TRISB, #RB0             ;ensure RB0 (PGD/EMUD) is input
    BSET  TRISB, #RB1             ;ensure RB1 (PGC/EMUC) is input
    BSET  TRISB, #RB3             ;ensure AN3/RB3 (TEMP sensor pin) is input
    BSET  TRISB, #RB4             ;ensure AN4/RB4 (RP1 sensor pin) is input
    BSET  TRISB, #RB5             ;ensure AN5/RB5 (RP2 sensor pin) is input
    BSET  LATB, #RB15             ;set AN15/RB15 (RealTek RSTDRV pin) is input
       
    /* SPARE PORTB pins */
    /* RB6
       RB7
       RB8 */
 

    /**********************************************************/
    /* PortC Requirements for dsPICDEM.net Connectivity Board */
    CLR   PORTC                   ;set PortB output pin state to low
    SETM  TRISC                   ;set all PortC pins as input   

    /* SPARE PORTC pin */
	BCLR  TRISC, #TRISC1          ;set SPARE PortC pin as output
	BCLR  TRISC, #TRISC13         ;set SPARE PortC pin as output
	BCLR  TRISC, #TRISC14         ;set SPARE PortC pin as output
	
	BSET  LATC, #LATC2
	BCLR  LATC, #LATC3
	BSET  LATC, #LATC4
	
	BCLR  TRISC, #TRISC2          ;set PortC pin as output
	BCLR  TRISC, #TRISC3          ;set PortC pin as output
	BCLR  TRISC, #TRISC4          ;set PortC pin as output
    /* LED1 on RC2           turn on LEDs by making pin output
       LED2 on RC3
       LED3 on RC4 */
       


    /**********************************************************/
    /* PortD Requirements for dsPICDEM.net Connectivity Board */
    CLR   PORTD                   ;set PortB output pin state to low
    CLR   TRISD                   ;set all PortD pins as outputs

    /* PortD is used as I/O for LCD and SRAM */



    /**********************************************************/
    /* PortF Requirements for dsPICDEM.net Connectivity Board */
    CLR   PORTF                   ;set PortF output pin state to low
	CLR   TRISF                   ;set all PortF pins as outputs

	BSET  TRISF, #TRISF0          ;set CAN_RXD pin as input
	BSET  TRISF, #TRISF2          ;set UART1 RX pin as input

    /* SPARE PORTF pins */
    /* RF4 
       RF5 
       RF7 
       
       RF6 -> SCK to MCP42010
       RF8 -> SDO to MCP42010 */
 
      
      
    /**********************************************************/
    /* PortG Requirements for dsPICDEM.net Connectivity Board */
    /* PortG Requirements for Si3021 AFE CODEC interface      */
    CLR   PORTG                   ;set PortG output pin state to low    

    BSET  PORTG, #RG8
    BSET  PORTG, #RG7             ;Set PortG pins as Inputs
 																																																				
    MOV   #0b1101111111111111, w0      
    MOV   w0, TRISG
 
    ; #0b 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1
    ;     | | | | | | | | | | | | | | | |____ set RG0 (RE control) pin as input
    ;     | | | | | | | | | | | | | | |______ set RG1 (DE control) pin as input
    ;     | | | | | | | | | | | | | |________ set RG2 (SCL, 24LC515) pin as input                 
    ;     | | | | | | | | | | | | |__________ set RG3 (SDA, 24LC515) pin as input
    ;     | | | | | | | | | | | |____________ placeholder (no pin)
    ;     | | | | | | | | | | |______________ placeholder (no pin)
    ;     | | | | | | | | | |________________ set RG6 pin (FC/RGDT pin) as input
    ;     | | | | | | | | |__________________ set RG7 pin (*OFFHK pin) as input
    ;     | | | | | | | |____________________ set RG8 pin (3021RST pin) as input
    ;     | | | | | | |______________________ set RG9 pin (RGDT/FSD pin) as input
    ;     | | | | | |________________________ placeholder (no pin)
    ;     | | | | |__________________________ placeholder (no pin)
    ;     | | | |____________________________ pin configured in dci_init.s file
    ;     | | |______________________________ pin configured in dci_init.s file
    ;     | |________________________________ pin configured in dci_init.s file
    ;     |__________________________________ pin configured in dci_init.s file
 
         
    RETURN
        
        
   .end

; -----------------------------------------------------------------------------
;         END OF FILE
; -----------------------------------------------------------------------------
