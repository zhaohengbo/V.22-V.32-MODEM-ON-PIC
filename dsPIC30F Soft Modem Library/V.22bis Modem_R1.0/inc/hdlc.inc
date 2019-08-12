;******************************************************************************
; FILE NAME: HDLC.H
;******************************************************************************

;------------------------------------------------------------------------------
; HDLC Module constant defines
;------------------------------------------------------------------------------

    .equ    HDLCFRAMEEND,     0x100    ;to detect HDLC frame end
    .equ    HDLCBYTEAVAIL,    0x0040   ;to check HDLC byte availability

;------------------------------------------------------------------------------
; AGC Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ    SIZEOFHDLC_BSS,   14       ;size of HDLC data structure in bss

;------------------------------------------------------------------------------
; HDLC Module: Global definations of variables
;------------------------------------------------------------------------------

    .global HDLCTxByteCnt              ;To count the number of bytes in the 
                                       ;transmit frame
    .global HDLCTxFlag                 ;To indicate that 0x7e is being 
                                       ;transmitted
    .global HDLCTxOnesCnt              ;For counting the continuous 1's in the
                                       ;data stream
    .global HDLCTxCRC                  ;Indicates that CRC word is being 
                                       ;transmitted when, 1
    .global HDLCInsert0                ;Status variable to indicate that next
                                       ;bit be 0.
    .global HDLCTxCRCWord              ;To store the instantaneous 16 bit CRC 
                                       ;word
    .global HDLCTxBitCnt               ;Counter for transmit bits in a byte
    .global HDLCTxDataWord             ;The actual used data word which is 
                                       ;serially Tx'ed.

    .global HDLCRxByteCnt              ;The number of bytes in the received 
                                       ;frame
    .global HDLCRxOnesCnt              ;counter for continuous received 1 bits
    .global HDLCRxFlag                 ;Status to indicate the erception of 
                                       ;0x7e sequence
    .global HDLCRxCRCWord              ;Instantaneous 16 bit CRC word
    .global HDLCRxBitCnt               ;counter for Number of bits in the 
                                       ;current data word
    .global HDLCRxDataWord             ;The actual data word received
    .global HDLCGotCRC                 ;Status to indicate the reception of the
                                       ;CRC word
    .global HDLCCRCErrors              ;CRC errors
    .global HDLCNoOfFrames             ;number of frames
    .global HDLCRxFrame                ;HDLC Receiver Frame
    .global HDLCFrmEnd                 ;HDLC Frame End
    .global HDLCFrmByteCount    

;******************************************************************************
; END OF FILE
;******************************************************************************
