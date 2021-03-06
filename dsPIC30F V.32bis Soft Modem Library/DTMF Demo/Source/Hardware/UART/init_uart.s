/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               InitUart.S                                         *
;  Date:                   24th May, 2004                                     *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.50.00                               *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;    UART specific registers are initialized                                  *
;******************************************************************************
;  Init_Uart1                                                                 *
;  ======================                                                     *
;  Description: This function initializes and enables the Uart Transmission   *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;        w0, w14                                                              *
;                                                                             *
;  Functions Called:  None                                                    *
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
;     Init_Uart1:                   18                                        *
;     Delay1:                       07                                        *
;     SetRTS:                       02                                        *
;     ClearRTS:                     02                                        *
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
;     Init_Uart1:                   20                                        *
;     Delay1:                       Depends on Delay                          *
;     SetRTS:                       04                                        *
;     ClearRTS:                     04                                        *
;*****************************************************************************/
; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

.include "p30f6014.inc"
.include "Device_Fcy.inc"

.if  XTx4PLL 
.equ Fcy,  7372800
.endif

.if   XTx8PLL 
.equ Fcy, 14745600
.endif

.if   XTx16PLL 
.equ Fcy, 29491200
.endif

;Constants and Literals used in code
.equ BAUDRATE, 19200                   ;Operating Baud Rate
; -----------------------------------------------------------------------------
;  Description: Initialization of Uart 
; -----------------------------------------------------------------------------

    .global _Init_Uart1
    .section .text

_Init_Uart1:
    push  w0

    clr   U1MODE                       ;set to known state
    clr   U1STA                        ;set to known state

    mov   #( ( (Fcy/BAUDRATE) / 16) - 1), w0       
    mov   w0, U1BRG                    ;Initialize BRG for 19200

    pop  w0
    
    bset  U1STA, #UTXISEL              ;Interrupt when the transmit
                                       ;buffer is empty
    
    bclr  IFS0, #U1TXIF                ;Clear the tx interrupt flag
    bset  IEC0, #U1TXIE                ;Enable tx ISR processing

    bclr  IFS0, #U1RXIF                ;Clear the rx interrupt flag
    bset  IEC0, #U1RXIE                ;Enable Rx ISR processing

    bset  U1MODE, #UARTEN              ;Enable UART
    bset  U1STA, #UTXEN                ;Enable Transmission  
    
    bclr  U1STA, #URXISEL1     
    bclr  U1STA, #URXISEL0     

    bclr  TRISA, #10                   ;RTS configured as Output
        
    nop
    return

;--------------------------------------------------------------------

 
.end

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------
