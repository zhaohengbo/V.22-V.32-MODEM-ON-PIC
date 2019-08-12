/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               isr_uart1.S                                        *
;    Date:                 24th May, 2004                                     *
;                                                                             *
;    Tools used:           MPLAB IDE -> 6.50.00                               *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;    Other Files Required: p30F6014.gld, p30f6014.inc                         *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Here the Interrupt Service routines for UART Transmission and Reception    *
;  are implemented.                                                           *
;                                                                             *
;******************************************************************************
;  U1TXInterrupt                                                              *
;  ======================                                                     *
;  Description: This function transmits a block of 4 characters as TX         *
;               Interrupt arises                                              *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;        w0,w1,w2,w3,w4,U1TXIF                                                *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  U1RXInterrupt                                                              *
;  ======================                                                     *
;  Description: This function receieve a character as RX Interrupt arises     *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,U1RXIF                                                    *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  SendCharToUARTTx                                                           *
;  ======================                                                     *
;  Description: This function echoes a character present in OutDataBuf.       *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,U1TXIE                                                    *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   0                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     U1TXInterrupt:                  50                                      *
;     U1RXInterrupt:                  30                                      *
;     SendCharToUARTTx:               35                                      * 
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
;     U1TXInterrupt:                   Depends on number of Characters sent   *
;     U1RXInterrupt:                   32                                     *
;     SendCharToUARTTx:                37                                     * 
;*****************************************************************************/

; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

.include "p30f6014.inc"

.equ INDATABUFLEN,        10
.equ OUTDATABUFLEN,       10

; -----------------------------------------------------------------------------
; DESCRIPTION:   This function is invoked as soon as TX Interrupt arises.
;                Uart Transmit ISR. Get the Data and transmit via U1TXREG
; -----------------------------------------------------------------------------

.global __U1TXInterrupt

__U1TXInterrupt:

    push.d  w0
    push.d  w2
    push.d  w4                         ;Save the Reg contents

    clr    w0

    mov.b  _OutDataR, wreg
    cp.b   _OutDataW                   ;Check if any data present
    bra    z, SET_TX_EMPTY  

    mov    #1, w2                      ;always sending blocks of 4 characters
    clr    w3
    clr    w4
    mov    #_OutDataBuf, w1
    mov.b  _OutDataR, wreg
    mov.b  w0, w3                      ;Get the Out Read Index
    mov.b  _OutDataW, wreg
    mov.b  w0, w4                      ;Get the Out Write Index
   
    sub.b  w4, w3, w0                  ;Get the data present in OutDataBuf
    bra    nn, CHK_MAXTX
    mov    #OUTDATABUFLEN, w5
    add    w0, w5, w0

CHK_MAXTX:

    cp     w0, w2 
    bra    ge, load_next_char
    mov    w0, w2
 
load_next_char:
     
    mov.b  [w1+w3], w0
    mov.b  wreg, U1TXREG               ;Load the data to TXREG to be transmitted

    inc.b  w3, w3

    mov    #OUTDATABUFLEN,w0

    cp      w3,w0                      ;Chk if Read Index > OUTDATABUFLEN
    bra    nz,UPDATE_TX_INDEX    
    
    clr    w3 

UPDATE_TX_INDEX:

    dec    w2, w2                     ; reduce character count by 1
    bra    nz, load_next_char         ; test for all done

    mov    w3, w0
    mov.b  wreg, _OutDataR             ;Update the Read Index
    
    mov   #_UARTTxEmpty,w2
    clr   w0 
    mov.b w0,[w2]                      ;Set TXEmpty bit

    bra    EXIT_UART_TX_ISR

SET_TX_EMPTY:

    mov   #_UARTTxEmpty,w2
    mov   #1,w0 
    mov.b w0,[w2]                      ;Set the TXEmpty bit

EXIT_UART_TX_ISR:

    bclr   IFS0, #U1TXIF               ; clear interrupt flag

    pop.d  w4
    pop.d  w2
    pop.d  w0
    disi   #1
    retfie
    

; -----------------------------------------------------------------------------
; DESCRIPTION:   This function is invoked as soon as RX Interrupt arises.
;                Uart Receive ISR. Get the Data via U1RXREG and receive in the Buffer
; -----------------------------------------------------------------------------

.global __U1RXInterrupt

__U1RXInterrupt:

    push.d  w0
    push.d  w2
    push    w4                         ;Save these Registers

    clr    w0
    clr    w3
    clr    w4

    btsc   U1STA,#OERR
    bclr   U1STA,#OERR

    mov    #_InDataBuf, w1
    mov.b  _InDataW, wreg
    mov.b  w0, w3                      ;Get the Rx Buffer Write index
 
    mov.b  U1RXREG, wreg
    mov.b  w0, [w1+w3]                 ;Store the incoming data
    
    inc.b  w3,w3                       ;Increment the write Index
    mov    #INDATABUFLEN,w0

    cp      w3,w0                      ;Chk W Index > INDATABUFLEN
    bra    nz,EXIT_UART_RX_ISR    
    
    clr    w3                          ;Reset the write Index

EXIT_UART_RX_ISR:

    mov   w3,w0
    mov.b wreg, _InDataW               ;Update the W index

    bclr IFS0, #U1RXIF                 ;clear interrupt flag

    pop    w4
    pop.d  w2
    pop.d  w0                          ;Retrieve the Register contents

    disi   #1
    retfie                             ;Return from Rx ISR
    

; -----------------------------------------------------------------------------
; DESCRIPTION:   This function is invoked when a character need to be send to UART.
; -----------------------------------------------------------------------------

    .global _SendCharToUARTTx
    .text

_SendCharToUARTTx:

    bclr  IEC0, #U1TXIE               ; Disable ISR processing

    push.d w0
    push.d w2
    push   w4                          ; Save the Registers

    mov   #_UARTTxEmpty,w2
    clr    w3
    cp0.b  [w2]                        ; Chk if TxEmpty bit is set
    bra    z, EXIT_UART_TX

WAIT_LP:

    btss   U1STA, #TRMT                ; Wait till TX buffer is empty
    bra    WAIT_LP  

    clr    w4
    clr    w0
    mov    #_OutDataBuf, w1
    mov.b  _OutDataR, wreg
    mov.b  w0, w3                      ;Get the OutBuf Read Index
    mov.b  _OutDataW, wreg
    mov.b  w0, w4                      ;Get the OutBuf Write Index

    mov.b  [w1+w3], w0
    mov.b  wreg, U1TXREG               ;Send a Character to TXREG

    inc.b  w3, w3                      ;Increment the Read Index
    mov    #OUTDATABUFLEN,w0

    cp      w3,w0                      ;Chk if Rindex > OUTDATABUFLEN
    bra    nz,UPD_TX_R_INDX    
    
    clr    w3                          ;Reset the Read Index

UPD_TX_R_INDX:    

    mov    w3, w0
    mov.b  wreg, _OutDataR             ;Update the Out Read Index

EXIT_UART_TX:

    pop    w4
    pop.d  w2
    pop.d  w0                          ;Retreive the registers 

    bset  IEC0, #U1TXIE                ; Enable ISR processing

      return

   .end

;--------------------------------------------------------------------------
;   END OF FILE
;--------------------------------------------------------------------------

        
    
