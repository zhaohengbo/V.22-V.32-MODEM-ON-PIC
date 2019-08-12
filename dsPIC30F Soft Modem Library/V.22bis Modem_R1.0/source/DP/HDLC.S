/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               HDLC.S                                             *
;  Date:                   28th  August,2002                                  *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.43.00.0                             *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;  Revision History:                                                          *
; ----------------------------------------------------------------------------*
; Rev:   Date:              Details:                                Who:      *
; ----------------------------------------------------------------------------*
; 0.1   28 August 2002   Code Created                                Ravi     *
; 0.2   29 August 2002   Code Reviewed                               Raghava  *
; 0.3   29 August 2002   Modified file/function header               Ravi     *
; 0.4   30 August 2002   Corrected code documentation faults         Ravi     *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  High-level Data Link Control framing(HDLC)implementation for Microchip's   *
;  dsPIC30F 16-bit                                                            * 
;  MCU.                                                                       *
;  Description: HDLC data transfer routines are handled in this file          *
;                                                                             *   
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;                                                                             *
;  InitHdlc:                                                                  *
;  ======================                                                     *
;  Description: This function initializes the HDLC transmission and reception.*
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *  
;   w0, w1 used not restored                                                  *
;                                                                             *
;  Functions Called:  ClearStruct                                             *
;                                                                             *
;******************************************************************************
;  SendFlag:                                                                  *
;  ======================                                                     *
;  Description: This function is used to send the HDLC flag                   *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0  used not restored                                                     *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  GetHdlcData:                                                               *
;  ======================                                                     *
;  Description: This function is used to get the bit from HDLC sequence.      *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: w0 = bit                                                           *
;                                                                             *
;  System Resource usage:                                                     * 
;   w0, w1, w2    used not restored                                           *
;                                                                             *
;  Functions Called: GetNewHdlcData, CRC16                                    *
;                                                                             *
;******************************************************************************
;  GetNewHdlcData:                                                            *
;  ======================                                                     *
;  Description: This function is used to get the new HDLC sequence to be      *
;               transmited.                                                   *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2  used not restored                                             *
;                                                                             *
;  Functions Called:  SendFlag, GetTransmitData                               *
;******************************************************************************
;  FrameAbort:                                                                *
;  ======================                                                     *
;  Description: This function is used to reinitialise the HDLC parameters.    *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   No working registers used                                                 *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  PutHdlcData:                                                               *
;  ======================                                                     *
;  Description: This function is used to assemble the received bits           *
;               according to HDLC format.                                     *
;                                                                             *
;  Input:  w0 = Bit                                                           *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *  
;   w0, w1, w2, w3 used not restored                                          *
;                                                                             *
;  Functions Called:  SendDataToHost, SendMessageToHost, FrameAbort,          *
;                     PutReceiveData, CRC16                                   *
;******************************************************************************
;  CRC16:                                                                     *
;  ======================                                                     *
;  Description: This function computes the 16-bit Cyclic Redundancy Check     *
;                                                                             *
;  Input:  w0 = CRC Word                                                      *
;          w1 = Bit                                                           *
;                                                                             *
;  Output: w0 = bit                                                           *
;                                                                             *
;  System Resource usage:                                                     *  
;   w0, w1, w2, w3, w4, w5, w6, w7 used not restored                          *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words : 2                                            *
;                                                                             *                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitHdlc:         15                                                    *
;     SendFlag:         09                                                    *
;     GetHdlcData:      35                                                    *
;     GetNewHdlcData:   40                                                    *
;     FrameAbort:       05                                                    *
;     PutHdlcData:      103                                                   *
;     CRC16:            10                                                    *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;     .bss:  13                                                               *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitHdlc:         18                                                    *
;     SendFlag:         11                                                    *
;     GetHdlcData:      36                                                    *
;     GetNewHdlcData:   36                                                    *
;     FrameAbort:       07                                                    *
;     PutHdlcData:      136                                                   *
;     CRC16:            12                                                    *
;                                                                             *
;*****************************************************************************/ 

;------------------------------------------------------------------------------
; INCLUDE FILES
;------------------------------------------------------------------------------

    .include "modem.inc"
    .include "hdlc.inc"  
    .include "apiasm.inc"
    .include "dpconfig.inc" 

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

.if DEF_HDLC == 1

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
    
    .global _InitHdlc
    .section  .libsm, "x"
    
;------------------------------------------------------------------------------
; Description: This function clears all the HDLC data and initializes the CRC
;              words to 0xffff. For transmission, it sets up the leading flag 
;              transmission.
;------------------------------------------------------------------------------
    
_InitHdlc:

    mov        #HDLCTxByteCnt, w0
    mov        #SIZEOFHDLC_BSS, w1
    call       _ClearStruct            ;clears all the HDLC data
    
    setm       HDLCTxCRCWord           ;sets the Tx CRCWord to FFFF
    setm       HDLCRxCRCWord           ;sets the Rx CRCWord to FFFF
    
    mov        #1, w0
    mov.b      wreg, HDLCTxFlag        ;Sets the HDLC Tx flag
    
    mov        #5, w0
    mov.b      wreg, HDLCTxOnesCnt     ;sets the HDLC Tx 1's count to 5
    
    mov        #8, w0
    mov        w0, HDLCTxBitCnt        ;sets the HDLC Tx bit count to 8
    
    mov        #0x7e, w0
    mov        w0, HDLCTxDataWord      ;sets the HDLC Tx data word to 0x7e
    
    return
    
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

    .global _SendFlag
    .section  .libsm, "x"

;------------------------------------------------------------------------------
; Description: This function initializes the parameters for the
;              transmission HDLC flag(0x7E).
;------------------------------------------------------------------------------
    
_SendFlag:

    mov        #1, w0
    mov.b      wreg, HDLCTxFlag        ;sets the HDLC Tx flag
    
    clr.b      HDLCTxCRC               ;clears the HDLC Tx CRC
    
    setm       HDLCTxCRCWord           ;sets the HDLC Tx CRC Word to FFFF
    
    mov        #8, w0
    mov        w0, HDLCTxBitCnt        ;sets the HDLC Tx bit count to 8
    
    mov        #0x7e, w0
    mov        w0, HDLCTxDataWord      ;sets the HDLC Tx data word to 0x7e
    
    return
    
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

    .global _GetHdlcData
    .section  .libsm, "x"

;------------------------------------------------------------------------------
; Description: This function returns a bit to the caller from the HDLC
;              sequence.When a fresh data byte is required GetNewHdlcData
;              is called to get the new data byte.A count down timer is 
;              initialized to 5 every time a 0 bit is detected in the data 
;              sequence. When 1's are being transmitted,this counter is 
;              decremented. When this value becomes 0, a status is set to
;              indicate that the next bit should be 0. This is an inserted
;              bit and is not passed thro'the CRC generator. All the other
;              bits are passed thro' the CRC polynomial.At the end of the 
;              frame final CRC is transmited before sending the 
;              terminating flag.
;------------------------------------------------------------------------------
    
_GetHdlcData:

    cp0.b      HDLCInsert0             ;checks whether 0 is inserted after 5
                                       ;consecutive binary 1's
    bra        z, GETNEWHDLCDATA       ;if not inserted then get new hdlc data  
    
    clr.b      HDLCInsert0             ;clears the HDLCInsert0
    
    clr        w0
    bra        END_GET_HDLC_DATA       ;returns 0
    
GETNEWHDLCDATA:

    cp0        HDLCTxBitCnt            ;checks for tx bit count
    bra        nz, TX_BIT_CNT          ;if it is 0 then get the new HDLC data
    
    rcall      _GetNewHdlcData
    
TX_BIT_CNT:

    dec        HDLCTxBitCnt            ;Decrements the HDLC tx bit count
    
    mov        HDLCTxDataWord, w1
    and        w1, #1, w1              ;Extract the Bit from the data word
    
    cp0        w1
    bra        z, TX_ONES_CNT          ;Check for the transmit bit

;Decrement the count down timer for conting consecutive 1's    
;Set the Insert0 flag to insert a 0 for the next bit, if 5 consecutive
;binary 1's detected in the data stream (Not in flag transmission)

    dec.b      HDLCTxOnesCnt           ;decrement the HDLC tx 1's count
    cp0.b      HDLCTxOnesCnt
    bra        nz, TX_DATA_WORD
    
    cp0.b      HDLCTxFlag
    bra        nz, TX_DATA_WORD
    
    mov        #1, w0
    mov.b      wreg, HDLCInsert0       ;sets the HDLCInsert0
    
    mov        #5, w0
    mov.b      wreg, HDLCTxOnesCnt     ;sets the HDLC tx 1's count to 5
    bra        TX_DATA_WORD
    
TX_ONES_CNT:

    mov        #5, w0
    mov.b      wreg, HDLCTxOnesCnt

;All the bits are passed through the CRC polynomial except the
;inserted 0's
    
TX_DATA_WORD:

    mov        HDLCTxDataWord, w2
    lsr        w2, #1, w2
    mov        w2, HDLCTxDataWord
    
    mov        HDLCTxCRCWord, w0
    push       w1
    rcall      _CRC16
    
    mov        w0, HDLCTxCRCWord       ;Update the transmit CRC word
    pop        w1
    mov        w1, w0
     
END_GET_HDLC_DATA:
   
    return                             ;Return from the function
    
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

    .global _GetNewHdlcData
    .section  .libsm, "x"
    
;------------------------------------------------------------------------------
; Description: If HDLCTxCRC bit is set, it indicates that, the CRC word is
;              already transmitted. Hence a terminating flag shall be 
;              transmitted.The function GetTransmitData is called to check
;              if, there is new raw data sent by the host. If, data byte is
;              available, TxDataLen is set to 8 and HDLCTxWordCnt is 
;              incremented to begin transmission of the new byte. If, 
;              HDLCTxWordCnt was 0, then the current byte is the first 
;              byte of the current frame and hence the CRC is reset to 
;              0xFFFF and HDLCTxFlag is reset. If no data is available or
;              if end of the frame is signalled by the host, frame end 
;              procedures are executed. At the end of frame transmission, 
;              if HDLCWordCnt is zero, transmission of a flag is started 
;              [CRC transmission is not required]. When it is non-zero, 
;              The complement of the current 16 bit CRC is sent to remote 
;              modem. TxDataLen is set to 16, HDLCTxWordCnt is reset to 0 
;              and TxCRC is set.
;------------------------------------------------------------------------------
    
_GetNewHdlcData:

;If the CRC word is already transmited indicated by the flag TxCRC
;Start transmission of HDLC flag, send the message indicating the
;end of frame

    cp0.b      HDLCTxCRC
    bra        z, TRANSMIT_DATA
    
    call       _SendFlag
    
    bra        END_GET_NEW_HDLC_DATA

;Check for the new data from the host
    
TRANSMIT_DATA:

    call       _GetTransmitData
    
    cp0        w0
    bra        z, CMP_TX_BYTE_CNT
    
    mov        dataTxDataWord, w1
    mov        #0xFF, w2
    cp         w1, w2
    bra        nz, SET_CRC_WORD

CMP_TX_BYTE_CNT:
    cp0        HDLCTxByteCnt           ;checks for tx byte count
    bra        z, SEND_FLAG
    
    mov        #16, w1
    mov        w1, HDLCTxBitCnt        ;sets the HDLC tx bit count ot 16
    
    com        HDLCTxCRCWord, wreg
    mov        w0, HDLCTxDataWord
    
    setm       HDLCTxCRCWord           ;sets the HDLC tx CRC Word to FFFF
    
    mov        #1, w0
    mov.b      wreg, HDLCTxCRC         ;Host data is available
    
    clr        HDLCTxByteCnt           ;Host buffer is empty
    
    clr        dataTxDataWord
    
    
    bra        END_GET_NEW_HDLC_DATA
    
SEND_FLAG:
    
    rcall      _SendFlag
    
    bra        END_GET_NEW_HDLC_DATA
    
SET_CRC_WORD:

    cp0        w0
    bra        z, END_GET_NEW_HDLC_DATA
    
    mov        dataTxDataWord, w1
    mov        w1, HDLCTxDataWord
    
    mov        #8, w1
    mov        w1, HDLCTxBitCnt        ;sets the HDLC tx bit count to 8
    
    mov        HDLCTxByteCnt, w1
    inc        HDLCTxByteCnt
    cp0        w1                      ;check for the tx byte count
    bra        nz, TX_FLAG             ;if not zero the clear the tx flag
    
    setm       HDLCTxCRCWord           ;sets the CRC Word to FFFF
    
TX_FLAG:

    clr.b      HDLCTxFlag              
    
END_GET_NEW_HDLC_DATA:

    return                            ;return from the function
    
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

    .global _FrameAbort
    .section  .libsm, "x"

;------------------------------------------------------------------------------
; Description: This function aborts the received HDLC frame by
;              reinitializing the HDLC parameters
;------------------------------------------------------------------------------
    
_FrameAbort:

    clr        HDLCRxDataWord          ;reset the HDLC rx data word
    
    clr.b      HDLCRxBitCnt            ;reset the HDLC rx bit count
    
    clr        HDLCRxByteCnt           ;reset the HDLC rx byte count
    
    setm       HDLCRxCRCWord           ;Reinitialize the CRC word to FFFF
    
    return
    
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

    .global _PutHdlcData
    .section  .libsm, "x"

;------------------------------------------------------------------------------
; Description: The received bit should be passed as the argument for this
;              function. When the received bit is 1, the following sequence of 
;              operations are executed.
;              HDLCRxOnesCnt is incremented. If it is equal to 7 then the 
;              frame reception is aborted. When the count of 1's, is less 
;              than 7, the bit is shifted left by HDLCRxBitCnt and 
;              assembled in HDLCRxByte. The bit counter HDLCRxBitCnt is 
;              incremented and when it is equal to 8, a complete byte has 
;              been assembled. On a byte assembly, HDLCRxByteCnt is 
;              incremented,the received byte is sent to the Host, CRC is 
;              calculated with the new bit and  HDLCRxBitCount is reset to
;              0 to start assembling the next byte.The function,CalcBitCRC
;              is used to update the CRC value from the 8 bits received. 
;              When the received bit is a 0,the following sequence of 
;              operations are executed,
;              if HDLCRxOnesCnt is 5, then it signals that, this bit
;              should be deleted from the data stream. If HDLCRxOnesCount
;              is 6 then, a flag sequence is detected. On both the 
;              instances, HDLCRxOnesCount is reset to 0.If HDLCRxOnesCount
;              is neither 5 nor 6, then the bit is assembled into 
;              HDLCRxDataByte.When a flags sequence is detected,HDLCRxFlag
;              is set.If HDLCRxByteCnt is non-zero, on reception of a flag
;              ,then a frame has been received. If the CRC calculated in 
;              the receiver is 0xF0B8, the transmitted frame has been 
;              received without errors, CRCOK response is sent to the 
;              Controller. If CRC is not 0xF0B8, then the received frame 
;              has errors and hence, CRCERROR response is sent to the 
;              controller. On reception of the flag sequence, HDLCRxCRC is
;              reset to 0xFFFF and HDLCRxByte, HDLCRxBitCnt and 
;              HDLCRxByteCnt are reset to 0. 
;------------------------------------------------------------------------------
   
_PutHdlcData:

;Check the received bit and execute the operations corresponding to
;the bit

    push       w0
    cp0        w0                      ;Check for the Received Bit
    bra        nz, RXONESCOUNT
        
    mov.b      HDLCRxOnesCnt, wreg

;If a 0 is received after 5 Continuous 1's remove 0 since this zero is
;inserted by the transmiter

    cp.b       w0, #5                  
    bra        nz, CHK_RXONESCNT
    
    clr.b      HDLCRxOnesCnt           ;reset the HDLC rx 1's count
    pop        w0
    bra        END_RECEPTION
    
CHK_RXONESCNT:

;If a 0 is received after 6 consecutive 1's,it indicates that HDLC flag is
;received

    cp.b       w0, #6
    bra        nz, RESET_RXONESCNT

    clr.b      HDLCRxOnesCnt           ;reset the HDLC rx 1's count
    
    inc.b      HDLCRxFlag              ;Set the HDLC Rxflag to indicate
                                       ;the reception of the flag

;After the reception of the flag, If the HDLCRxByteCnt is zero i.e.
;frame has not received Reset the HDLCRxBitCnt and HDLCRxByteCnt
;and set CRCWord to FFFF by executing FrameAbort function
 
    cp0        HDLCRxByteCnt
    bra        z, FRM_ABORT
    
    mov        HDLCRxCRCWord, w1
    mov        #0xF0B8, w2
    
    cp         w1, w2                  ;checks if HDLC CRC word is 0xF0B8
    bra        nz, SEND_DATA_MESG_TO_HOST
    
    inc        HDLCNoOfFrames          ;increments the number of frames
    mov        #1, w2
    mov        w2, HDLCRxFrame
    
    mov        HDLCRxByteCnt, w2
    cp         w2, #4
    bra        nz, SEND_DATA_TO_HOST
    
    inc        HDLCRxByteCnt           ;increments the HDLC rx byte count

;After the reception of the flag,If HDLCRxByteCnt is non-zero (i.e
;frame has received) and if RxCRCWord is equal to 0xf0b8,it indicates
;good CRC otherwise the received frame will be in error. 
    
SEND_DATA_TO_HOST:

    call       _SendDataToHost         ;Send the received data to host
    
    mov        #mCRCOK,w0              ;Indicate the host that the CRC is ok 
    mov.b      wreg,mesgMsgId          ;is ready
    
    clr.b      mesgMsgLen
 
    mov        #mesgMsgParams, w8   
    call       _SendMessageToHost      ;send the message to the host
    
    bra        FRM_ABORT
    
SEND_DATA_MESG_TO_HOST:

    inc        HDLCCRCErrors           ;increments the HDLC CRC errors
    inc        HDLCNoOfFrames          ;increments the HDLC number of frames
    mov        #1, w0
    mov        w0, HDLCRxFrame
    
    call       _SendDataToHost         ;send the data to host
    
    mov        #mCRCERROR,w0           ;Indicate the host that there is a CRC
    mov.b      wreg,mesgMsgId          ;error is ready
    
    clr.b      mesgMsgLen

    mov        #mesgMsgParams, w8       
    call       _SendMessageToHost      ;send the message to the host

;Abort the received frame by reseting the HDLC parameters

FRM_ABORT:

    rcall      _FrameAbort
    
    mov        #1, w0
    mov.b      wreg, HDLCRxFlag       ;set the HDLC rx flag
    pop        w0
    bra        END_RECEPTION
    
RESET_RXONESCNT:
    
    clr.b      HDLCRxOnesCnt          ;clears the HDLC rx 1's count
    bra        HDLCRXFLAG
          
RXONESCOUNT:

    inc.b      HDLCRxOnesCnt          ;increments the Rx 1's count
    mov.b      HDLCRxOnesCnt, wreg
    cp.b       w0, #7
    bra        nz, HDLCRXFLAG

;Abort the received frame if 7 continuous 1's have received
    
    rcall      _FrameAbort
    pop        w0
    bra        END_RECEPTION
    
HDLCRXFLAG:

;No assembling of bytes if the flag is not received
    pop        w0
    mov        w0, w2
    cp0.b      HDLCRxFlag
    bra        z, END_RECEPTION
    
    clr        w0
    mov.b      HDLCRxBitCnt, wreg
    clr        w1
    mov.b      w0, w1

    sl         w2, w1, w1             ;Assemble the received bit
    mov        #HDLCRxDataWord, w2
    ior        w1, [w2], [w2]

    inc.b      HDLCRxBitCnt           ;Increment the Received Bit count
    mov.b      HDLCRxBitCnt, wreg
    cp.b       w0, #8                 ;Assemble for one complete byte
    bra        nz, END_RECEPTION      ;Return if if Bitcount != 8
    
    mov        [w2], w3
    mov        w3, dataRxDataWord
    mov        w3, dataDataByte        ;Update the Received Byte

;Put the received byte on the host transmit buffer
    
    call       _PutReceiveData
    
    inc        HDLCRxByteCnt           ;Increment the byte count after
                                       ;byte is assembled
    do         #7, CRC
    
    mov        HDLCRxCRCWord, w0
    mov        HDLCRxDataWord, w1
    and        w1, #1, w1
    
    rcall      _CRC16                  ;Calculate the CRC for the received bits
    
    mov        w0, HDLCRxCRCWord
    mov        HDLCRxDataWord, w1
    lsr        w1, #1, w1

CRC:
    mov        w1, HDLCRxDataWord

    clr.b      HDLCRxBitCnt            ;clear the HDLC rx bit count
    clr        HDLCRxDataWord          ;clear the HDLC rx data word
    
END_RECEPTION:
    return
    
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

    .global _CRC16
    .section  .libsm, "x"

;------------------------------------------------------------------------------
; Description: This function calculates the CRC using the polynomial
;              1 + X^5 + X^12 + X^16
;------------------------------------------------------------------------------
    
_CRC16:

    and        w0, #1, w2
    xor        w2, w1, w2              ;w2 = c1
    
    sl         w2, #4, w3
    sl         w2, #11, w4
    
    ior        w3, w4, w5              ;w5 = c2
    
    sl         w2, #15, w6
    xor        w0, w5, w7
    lsr        w7, #1, w7
    ior        w6, w7, w0              ;w0 = updated c2
    
    return
    
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

.endif

;------------------------------------------------------------------------------
; END OF FILE
;------------------------------------------------------------------------------
