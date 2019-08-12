/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               DATA.S                                             *
;  Date:                   25th July,2002                                     *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.43.00.0                             *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;  Revision History:                                                          *
; ----------------------------------------------------------------------------*
; Rev:     Date:                 Details:                           Who:      *
; ----------------------------------------------------------------------------*
; 0.1   25 July 2002           Code Created                         Rajiv     *
; 0.2   27 July 2002           Code Reviewed                        Raghava   *
; 0.3   09 August 2002         Modified file/function header        Rajiv     *
; 0.4   23 August 2002         Corrected code documentation faults  Rajiv     *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Modem Data pump implementation for Microchip's dsPIC30F 16-bit MCU         *
;  Description:   The modem data pump expects a continuous bit stream for     *
;                 encoding. At the same time, the modem receiver generates    *
;                 a continuous bit stream from the received symbols. So bit   *
;                 streams should be properly manipulated to extract bits from *
;                 the byte, and to assemble bytes from the received bit       *
;                 stream.                                                     *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;                                                                             *
;******************************************************************************
;  ResetHostBuffers                                                           *
;  ======================                                                     *
;  Description: This function initializes the host buffer pointers            *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;        None                                                                 *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  GetTxQueLength                                                             *
;  ======================                                                     *
;  Description: This function gets the Que length of host buffers             *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        TxQueLength                                                          *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1                used not restored                                   *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  Get1s                                                                      *
;  ======================                                                     *
;  Description: This function is used to get the binary 1's for transmission  *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        one                                                                  *
;                                                                             *
;  System Resource usage:                                                     *
;   w0                     used not restored                                  *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  GetLsb2Msb                                                                 *
;  ======================                                                     *
;  Description: This function gets the transmit data and extract bits from    *
;               LSB to MSB                                                    *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        Extracted bits(LSB-MSB)                                              *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2                          used not restored                          *
;                                                                             *
;  Functions Called:   GetTransmitData                                        *
;                                                                             *
;******************************************************************************
;  GetMsb2Lsb                                                                 *
;  ======================                                                     *
;  Description: This function gets the transmit data and extract bits from    *
;               MSB to LSB                                                    *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        Extracted bits(MSB-LSB)                                              *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2                          used not restored                          *
;                                                                             *
;  Functions Called:   GetTransmitData                                        *
;                                                                             *
;******************************************************************************
;  GetLsb2MsbSS                                                               *
;  ======================                                                     *
;  Description: This function gets the transmit data and extract bits from    *
;               LSB to MSB and adds Start-Stop bits                           *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        Extracted bits(LSB-MSB with Start-Stop)                              *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2,w5                       used not restored                          *
;                                                                             *
;  Functions Called:   GetTransmitData                                        *
;                                                                             *
;******************************************************************************
;  PutLsb2Msb                                                                 *
;  ======================                                                     *
;  Description: This function assembles the the received bits from LSB to MSB *
;               in RxDataWord                                                 *
;  ======================                                                     *
;  Input:                                                                     *
;        Bits                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w3,w7                       used not restored                          *
;                                                                             *
;  Functions Called:   PutReceiveData                                         *
;                                                                             *
;******************************************************************************
;  PutMsb2Lsb                                                                 *
;  ======================                                                     *
;  Description: This function assembles the the received bits from MSB to LSB *
;               in RxDataWord                                                 *
;  ======================                                                     *
;  Input:                                                                     *
;        Bits                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2,w3                       used not restored                          *
;                                                                             *
;  Functions Called:   PutReceiveData                                         *
;                                                                             *
;******************************************************************************
;  PutLsb2MsbSS                                                               *
;  ======================                                                     *
;  Description: This function assembles the the received bits from LSB to MSB *
;               in RxDataWord and removes Start-Stop bits                     *
;  ======================                                                     *
;  Input:                                                                     *
;        Bits                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2,w3                       used not restored                          *
;                                                                             *
;  Functions Called:   PutReceiveData                                         *
;                                                                             *
;******************************************************************************
;  GetTransmitData                                                            *
;  ======================                                                     *
;  Description: This function gets the transmit data from the host buffer     *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        one                                                                  *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2,w3                       used not restored                          *
;                                                                             *
;  Functions Called:   GetTxQueLength,SendMessageToHost                       *
;                                                                             *
;******************************************************************************
;  PutReceiveData                                                             *
;  ======================                                                     *
;  Description: This function is used to update the host buffer with the      *
;               received byte                                                 *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2,w3                       used not restored                          *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  SendDataToHost                                                             *
;  ======================                                                     *
;  Description: This function copies the received data in host buffer to the  *
;               message buffer which will be send to the host                 *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2,w3,w8                 used not restored                          *
;                                                                             *
;  Functions Called:   SendMessageToHost                                      *
;                                                                             *
;******************************************************************************
;  EnableDataTransfer                                                         *
;  ======================                                                     *
;  Description: This function configures the datamode                         *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2,w3,w7,w9                 used not restored                          *
;                                                                             *
;  Functions Called:   ResetHostBuffers                                       *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   0                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     ResetHostBuffers:            5                                          *
;     GetTxQueLength:              6                                          *
;     Get1s:                       2                                          *
;     GetLsb2Msb:                  17                                         *
;     GetMsb2Lsb:                  17                                         *
;     GetLsb2MsbSS:                23                                         *
;     PutLsb2Msb:                  15                                         *
;     PutMsb2Lsb:                  12                                         *
;     PutLsb2MsbSS:                13                                         *
;     GetTransmitData:             43                                         *
;     PutReceiveData:              20                                         *
;     SendDataToHost:              36                                         *
;     EnableDataTransfer:          37                                         *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;     .nbss:            09                                                    *
;     .bss:             28                                                    *
;     .ybss:            02                                                    *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     ResetHostBuffers:             7                                         *
;     GetTxQueLength:               8                                         *
;     Get1s:                        4                                         *
;     GetLsb2Msb:                   21                                        *
;     GetMsb2Lsb:                   21                                        *
;     GetLsb2MsbSS:                 25                                        *
;     PutLsb2Msb:                   17                                        *
;     PutMsb2Lsb:                   14                                        *
;     PutLsb2MsbSS:                 16                                        *
;     GetTransmitData:              43                                        *
;     PutReceiveData:               22                                        *
;     SendDataToHost:               32+(MsgLen*6)                             *
;     EnableDataTransfer:           26                                        *
;                                                                             *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------


    .include "Data.inc"
    .include "modem.inc"
    .include "apiasm.inc"
    .include "defs.inc"
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _ResetHostBuffers
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function resets the read and write pointer of the 
;                 transmit and receive buffers to their initial condition.Any
;                 data that is already present in the buffers is thus lost.
; -----------------------------------------------------------------------------

_ResetHostBuffers:

    clr.b      dataHostRxRead          ;Initialize Host Buffer R/W pointers
    clr.b      dataHostRxWrite    
    clr.b      dataHostTxRead     
    clr.b      dataHostTxWrite
    
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _GetTxQueLength
    .section  .libsm, "x"
; -----------------------------------------------------------------------------
;  Description:  This function returns the number of remaining bytes in the 
;                receive buffer of the data pump waiting to be transmitted 
;                to the line. This is usually employed for completion of the
;                transmission of the data bytes to the remote modem and 
;                switching to a new task.
; -----------------------------------------------------------------------------

_GetTxQueLength:

    clr       w0
    mov.b     dataHostRxRead, wreg
    sub.b     dataHostRxWrite, wreg    ;Difference between pointers
    
    bra       ge, EXIT_GET_TXQUE

    mov       #RXDATABUFLEN,w1
    add       w0, w1, w0               ;Update the Que Length

EXIT_GET_TXQUE:

    mov      #0xff,w1
    and      w0,w1,w0
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _Get1s
    .section  .libsm, "x"
; -----------------------------------------------------------------------------
;  Description:   This function returns only ones
; -----------------------------------------------------------------------------

_Get1s:

    mov      #1, w0                    ;Return one
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _GetLsb2Msb
    .section  .libsm, "x"
; -----------------------------------------------------------------------------
;  Description:   This function gets the transmit data and extract bits from
;                 LSB to MSB.
; -----------------------------------------------------------------------------

_GetLsb2Msb:

    cp0.b   dataTxBitCnt               ;Get the Txdata bit count 
    bra     nz, TX_L2M_BIT

    rcall   _GetTransmitData           ;Extract the bit (LSB)

    cp0     w0                 
    bra     z, NO_HOST_DATA            ;Set Idle data

    mov     #8, w0
    mov.b   wREG, dataTxBitCnt         ;Set transmit bit count

    goto    TX_L2M_BIT

NO_HOST_DATA:
    
    clr     w0
    mov.b   dataIdleData, wreg
    mov     w0, dataTxDataWord         ;Initialize Idle Data
    
    mov     #8, w0
    mov.b   wreg, dataTxBitCnt         ;Set transmit bit count

TX_L2M_BIT:

    dec.b   dataTxBitCnt               ;Decrement the transmit bit count
    mov     dataTxDataWord, w2
    
    mov     #1, w0
    and     w0,w2,w0                   ;Mask all the bits except LSB

    asr     dataTxDataWord             ;Shift the transmit data word

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
   
    .global _GetMsb2Lsb
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function gets the transmit data and extract bits from
;                 MSB to LSB.
; -----------------------------------------------------------------------------

_GetMsb2Lsb:
        
    cp0.b   dataTxBitCnt               ;Get the Txdata bit count
    bra     nz, TX_M2L_BIT

    rcall   _GetTransmitData           ;Extract the bit (LSB)

    cp0     w0
    bra     z, NO_HOST_DATA1           ;Set Idle Data

    mov     #8, w0
    mov.b   wREG, dataTxBitCnt         ;Set Txdata bit count

    goto    TX_M2L_BIT

NO_HOST_DATA1:
    
    mov.b   dataIdleData, wreg
    mov     w0, dataTxDataWord         ;Set Idle Data

    mov     #8, w0
    mov.b   wreg, dataTxBitCnt         ;Set Txdata bit count

TX_M2L_BIT:

    dec.b   dataTxBitCnt               ;Decrement tranmit bit count

    mov     dataTxDataWord, w2
    mov     #0x80, w0

    and     w0,w2,w0                   ;Mask all bits except MSB
        
    sl     dataTxDataWord

    asr    w0, #7, w0                  ;Shift the transmit data word

    return      

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _GetLsb2MsbSS
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function gets the transmit data and extract bits from
;                 LSB to MSB and adds Start-Stop bits.
; -----------------------------------------------------------------------------


_GetLsb2MsbSS:

    cp0.b   dataTxBitCnt  
    bra     nz, TX_L2MSS_BIT           ;If Bits are present, transmit L2MSS

    rcall   _GetTransmitData           ;Extract the bit

    cp0     w0
    bra     z, NO_HOST_DATA2           ;check if bit present

    mov     #9, w0
    add.b   dataNoOfStopBits, wreg     
    mov.b   wreg, dataTxBitCnt         ;set transmit bits including stop bits

    mov     #0xFE00, w2
    
    mov     dataTxDataWord, w0

    sl      w0, #0x1, w0               ;Remove the sign bit
    add     w2, w0, w5
    
    mov     w5,datass_word             ;update start-stop data
    
    goto    TX_L2MSS_BIT

NO_HOST_DATA2:

    clr     w0
    mov.b   dataIdleData, wreg
    mov     w0,datass_word             ;set Idle data, No start-stop bits
    
    mov     #8, w0
    mov.b   wreg, dataTxBitCnt         ;set transmit bit count
    
TX_L2MSS_BIT:

    dec.b   dataTxBitCnt               ;Decrement transmit bit count
    mov     datass_word, w2
    
    cp0     w2
    bra     nz, SEND_PAT
    mov     #1, w0
    bra     EXIT_LSB2MSBSS

SEND_PAT:

    mov     #1, w0
    and     w0,w2,w0                   ;Mask all bits except LSB

    asr     datass_word                ;Extract bits by shifting

EXIT_LSB2MSBSS:

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _PutLsb2Msb
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function assembles the the received bits from LSB to MSB
;                 in RxDataWord.
; -----------------------------------------------------------------------------

_PutLsb2Msb:

    mov       w0, w7

    clr       w0 
    mov.b     dataRxBitCnt, wreg
    mov       dataRxDataWord, w3

    sl        w7, w0, w0               ;Shift to put LSB in MSB
    ior       w0,w3, w3
    
    mov       w3,dataRxDataWord        ;Update receive data word
        
    inc.b     dataRxBitCnt             ;Increment receive bit count

    mov       #8, W0
    cp.b      dataRxBitCnt
    bra       nz, EXIT_PUT_L2M         ;Check if bitcount is 8
    
    rcall     _PutReceiveData          ; Send data to Host
   
    clr.b     dataRxBitCnt            
    
EXIT_PUT_L2M:

    return                      

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _PutMsb2Lsb
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function assembles the the received bits from MSB to LSB
;                 in RxDataWord
; -----------------------------------------------------------------------------

_PutMsb2Lsb:

    mov       dataRxDataWord, w2
    sl        w2, #1, w3
    ior       w0, w3, w3               ;Put MSB bits to LSB
    mov       w3, dataRxDataWord

    inc.b     dataRxBitCnt    
    mov       #8, W0

    cp.b      dataRxBitCnt             ;check if 8 bits present
    bra       nz, EXIT_PUT_M2L
    
    rcall     _PutReceiveData          ;Update bits in Host Buffer
    
    clr.b     dataRxBitCnt
    
 EXIT_PUT_M2L:

    return                      

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _PutLsb2MsbSS
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function assembles the the received bits from LSB to MSB
;                 in RxDataWord and removes Start-Stop bits.
; -----------------------------------------------------------------------------

_PutLsb2MsbSS:

    cp0.b    dataRxBitCnt
    bra      z, CHK_FOR_START_BIT

    mov      dataRxDataWord, w3
    
    mov      w0,w2
    dec.b    dataRxBitCnt, wreg

    sl       w2, w0, w2
    ior      w2, w3, w3                ;Assemble the bits
    
    mov      w3,dataRxDataWord         ;Update the receive data

    inc.b    dataRxBitCnt
    mov      #9, w0

    cp.b     dataRxBitCnt              ;check if the byte is assembled
    bra      nz, EXIT_GET_L2MSS_DATA

    rcall    _PutReceiveData           ;Put the assembled byte in host buffer
    clr.b    dataRxBitCnt

    return

CHK_FOR_START_BIT:

    cp0.b    w0                        ;Check for Start bit
    bra      nz, EXIT_GET_L2MSS_DATA   ;Return if start bit is absent

    mov      #1, w0
    mov.b    wreg, dataRxBitCnt        ;set the receive bit count

    mov      #0, w0
    mov      w0, dataRxDataWord

EXIT_GET_L2MSS_DATA:
     
     return

    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _GetTransmitData
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function retrieves a data byte from the host receive
;                 buffer if available. It is assumed that all the data are 8
;                 bit wide. This function returns the status (available / not
;                 -available) and the byte (if available) to the caller and is
;                 executed by all the bit transmit modules when new data is 
;                 required. After fetching the byte, the data could be 
;                 transmitted in different ways.
; -----------------------------------------------------------------------------

_GetTransmitData:

    cp0.b    dataXoff
    bra      z, CHK_FOR_DATA_QUE

    rcall    _GetTxQueLength

    mov      dataXonLimit, w2
    cp       w0, w2
    bra      ge, CHK_FOR_DATA_QUE

    clr.b    dataXoff

    mov      #mXON, w0
    mov.b    wreg,mesgMsgId
    clr.b    mesgMsgLen                ;Indicates no messages 
    mov      #mesgMsgParams, w8
    call    _SendMessageToHost
    
;When DP sent the XOFF message(i.e. its internal buffer is full),DP keeps
;checking for the data buffer queue length,When the buffer queue length
;reaches the X-ON mark DP sends the XON message to host indicating
;that data transfer can begin which has temprorly stopped during X-OFF.    

CHK_FOR_DATA_QUE:

    clr      w0
    mov.b    dataHostRxRead, wreg
    cp.b     dataHostRxWrite           ;Check if Host Read and Write ptrs equal
    bra      z, EXIT_GET_TX_DATA
    
    mov      #dataHostRxBuffer, w2     
    mov      #dataTxDataWord, w3

    clr      w1
    mov      w1, [w3]                  ;Clear the data word

    inc.b    dataHostRxRead            ;Increment the Host Read pointer
    mov.b    [w2+w0], [w3]             ;Update the Data word

    mov      #RXDATABUFLEN, w0
    cp.b     dataHostRxRead            ;Check if Host Read ptr end of Buffer
    bra      nz, HDLC_FRAME_END ;CHK_XOFF_LIMIT

    clr.b    dataHostRxRead

HDLC_FRAME_END: 
CHK_XOFF_LIMIT:

;When internal data buffer is 75% full DP sends the X-OFF message to
;host indicatiing to stop the data transfer temporarily

    cp0.b    dataXoff
    bra      nz, EXIT_GET_TX_DATA1

    rcall    _GetTxQueLength           ;Get the buffer queue length

    mov      dataXoffLimit, w2
    cp       w0, w2
    bra      le, EXIT_GET_TX_DATA1     ;check Queue Length for Maximum

    mov      #1, w0
    mov.b    wreg, dataXoff

    mov      #mXOFF, w0
    mov.b    wreg,mesgMsgId            ;Set Message Id as XOFF
    clr.b    mesgMsgLen
    mov      #mesgMsgParams, w8
    call    _SendMessageToHost        ;Send Msg to Host

EXIT_GET_TX_DATA1:

    mov      #1, w0
    ;Return 1 indicating that host data is available
    return

EXIT_GET_TX_DATA:

    mov      #0, w0                    ;Return 0 indicating no host data
    return
      

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _PutReceiveData
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function transfers the assembled byte to the host
;                 transmit buffer. Saving is inhibited if bit reception is
;                 disabled
; -----------------------------------------------------------------------------

_PutReceiveData:

;Saving of the received byte into the host buffer is inhibited
;bit reception is not enabled

    mov      dataRxDataWord, w0
    mov      w0, dataDataByte

    mov      #RXDBYTE,w0
    ior.b    modemStatus

    clr      dataRxDataWord

    mov      #CARRIERDETECT, w0
    and.b    modemStatus,wreg          ;check if carrier present
    bra      z, EXIT_PUT_RX_DATA
    
    clr      w0
    mov      dataDataByte, w2
    mov.b    dataHostTxWrite, wreg
    mov      #dataHostTxBuffer, w3

    inc.b    dataHostTxWrite           ;Increment Host write pointer
    mov.b    w2, [w3+w0]               ;Update the byte in Host Buffer

    mov      #TXDATABUFLEN, w0
    cp.b     dataHostTxWrite           ;check for Buffer End
    bra      nz, EXIT_PUT_RX_DATA

    clr.b    dataHostTxWrite

EXIT_PUT_RX_DATA:

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SendDataToHost
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This routine is executed by the modem scheduler for 
;                 transferring the data in the host transmit buffer to the
;                 application. A data message is formed and the message is 
;                 sent to the host. Any calls to this function before 
;                 completion of synchronization are rejected. All the 
;                 remaining bytes in the transmit buffer are sent to the host
;                 in one message. This function is usually called at the end 
;                 of processing of the current PCM frame. i.e., all transmit 
;                 and receive processing is complete. An exception is,in HDLC
;                 mode of operation, this function is called when the end of 
;                 a received frame is detected. i.e., after the reception of
;                 the CRC word, whether the frame is good or bad
; -----------------------------------------------------------------------------

_SendDataToHost:


    clr     w0
    mov.b   dataHostTxRead, WREG
    sub.b   dataHostTxWrite, WREG      ;Check if Host Read and Write ptrs equal
    bra     z, EXIT_SEND_DATATOHOST

    cp0.b   w0
    bra     ge, UPDATE_DATA_TO_QUE

    mov     #TXDATABUFLEN, w3
    add.b   w3, w0, w0
    
UPDATE_DATA_TO_QUE:

;If the No.of bytes exceeds the Maximum buffer length hangup
;the modem indicating the buffer overflow
     
    mov     #mDATATOHOST, w4
    mov     ChnMsgOutWPtr, w10

    mov        ChnOutMsgEnd,w11
    mov.b      w4, [w10++]           ;Get the message ID

    cp         w10,w11
    bra        nz,UPDATE_MSG_ID1
    
    mov        ChnOutMsgTop,w10        ;and end addresses

UPDATE_MSG_ID1:
     
    mov.b      w0, [w10++]
    cp         w10,w11
    bra        nz,UPDATE_MSG_LEN1
    
    mov        ChnOutMsgTop,w10        ;and end addresses

UPDATE_MSG_LEN1:

    cp0.b   w0
    bra     z,EXIT_SEND_DATATOHOST
 
    dec     w0, w3                     ;Loop Count

    clr     w1
    mov     #dataHostTxBuffer, w2
    mov.b   dataHostTxRead, wreg       ;Load from Host Read Pointer

    mov     #TXDATABUFLEN, w1

    do      w3, COPY_DATA_LOOP
    mov.b   [w2+w0], [w10++]

    cp         w10,w11
    bra        nz,UPDATE_MSG_LEN2
    
    mov        ChnOutMsgTop,w10        ;and end addresses

UPDATE_MSG_LEN2:

    inc     w0,w0                      ;Increment index
    cp      w0,w1                      ;Check Host Read Buffer overflow
    bra     nz, COPY_DATA_LOOP     

    clr     w0                         ;Reset the index

COPY_DATA_LOOP:
    mov.b   wreg,dataHostTxRead

    mov        ChnMsgOutWAddr,w1    
    mov        w10, ChnMsgOutWPtr         
    mov        w10,[w1]


EXIT_SEND_DATATOHOST:

    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _EnableDataTransfer
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function is executed by the DP at the end of 
;                 transmission/reception of the handshake/synchronizing 
;                 signals and the DP is ready for data transfer. When this
;                 function is executed, the CONNECT message is issued to the
;                 host application.This is an indication that the actual data
;                 transfer can begin.The host can configure the required data
;                 mode prior to the establishment of the data connection. 
;
; -----------------------------------------------------------------------------

_EnableDataTransfer:

    mov      #CARRIERDETECT, w0
    ior.b    modemStatus               ;Check Carrier Detect bit is set

    rcall    _ResetHostBuffers         ;Reset Host Rx and Tx Buffers

    mov      #DATA_L2M, w0

    cp.b     ucDataModeSel             ;Check Data Mode is L2M without 
    bra      nz, CHK_L2MSS_COND        ;start/stop bits

    mov      #handle(_PutLsb2Msb), w2
    mov      #handle(_GetLsb2Msb), w3
 
    mov      w2, dataRxBitFn
    mov      w3, dataTxBitFn           ;Set The Tx and Rx Function pointers
    goto     SETIDLEDATA

CHK_L2MSS_COND:

    mov      #DATA_L2MSS, w0           ;Check Data Mode is L2M with 
    cp.b     ucDataModeSel             ;start/stop bits
    bra      nz, CHK_M2L_COND

    mov      #handle(_PutLsb2MsbSS), w2
    mov      #handle(_GetLsb2MsbSS), w3

    mov      w2, dataRxBitFn
    mov      w3, dataTxBitFn           ;Set Tx and Rx function pointers
    goto     SETIDLEDATA

CHK_M2L_COND:

    mov      #DATA_M2L, w0             ;Check data mode is M2L without
    cp.b     ucDataModeSel             ;start/stop bits
    bra      nz, HDLC_DATA ;SETIDLEDATA

    mov      #handle(_PutMsb2Lsb), w2 
    mov      #handle(_GetMsb2Lsb), w3

    mov      w2, dataRxBitFn
    mov      w3, dataTxBitFn           ;Set Tx and Rx function pointers  

HDLC_DATA:
.if DEF_HDLC == 1
    mov      #DATA_HDLC, w0            ;Check data mode is M2L without
    cp.b     ucDataModeSel             ;start/stop bits
    bra      nz, SETIDLEDATA
    
    mov      #handle(_PutHdlcData), w0 
    mov      w0, dataRxBitFn 
 
    mov      #handle(_GetHdlcData), w0
    mov      w0, dataTxBitFn
   
    call     _InitHdlc
.endif


SETIDLEDATA:

    mov      #dataIdleData, w9
    mov.b    ucIdleDataSet, wreg
    mov.b    w0, [w9]                  ;Set Idle Data
    
    clr.b    dataTxBitCnt
    clr.b    dataRxBitCnt

    mov      #0, w7
    mov      w7, dataRxDataWord        ;Clear receive data word

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _CheckDPFlowControl
    .section  .libsm, "x"

_CheckDPFlowControl:

    cp0.b    dataXoff
    bra      z, CHK_DP_XOFF

    call    _GetTxQueLength

    mov      dataXonLimit, w2
    cp       w0, w2
    bra      ge, EXIT_DP_FLOW_CONTROL

    clr.b    dataXoff

    mov      #mXON, w0
    mov.b    wreg,mesgMsgId
    clr.b    mesgMsgLen                ;Indicates no messages 
    mov      #mesgMsgParams, w8
    call    _SendMessageToHost

    return;

CHK_DP_XOFF:

    cp0.b    dataXoff
    bra      nz, EXIT_DP_FLOW_CONTROL

    call    _GetTxQueLength           ;Get the buffer queue length

    mov      dataXoffLimit, w2
    cp       w0, w2
    bra      le, EXIT_DP_FLOW_CONTROL   ;check Queue Length for Maximum

    mov      #1, w0
    mov.b    wreg, dataXoff

    mov      #mXOFF, w0
    mov.b    wreg,mesgMsgId            ;Set Message Id as XOFF
    clr.b    mesgMsgLen
    mov      #mesgMsgParams, w8
    call    _SendMessageToHost        ;Send Msg to Host

EXIT_DP_FLOW_CONTROL:

   return;

; -----------------------------------------------------------------------------
;   END OF FILE
; -----------------------------------------------------------------------------
     
