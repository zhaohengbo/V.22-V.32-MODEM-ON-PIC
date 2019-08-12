;******************************************************************************
;File Name:   DATA.H
;******************************************************************************

;------------------------------------------------------------------------------
; Data handling Module constant defines
;------------------------------------------------------------------------------

;Lengths of data transmit and receive buffers

.equ TXDATABUFLEN,        20  
.equ RXDATABUFLEN,        100

.equ SIZEOF_DATAVAR,      28  
.equ SIZEOF_DATAVAR_NBSS, 9
.equ SIZEOF_DATAVAR_YBSS, 2

;Threshold levels to pause the data transfer
.equ XOFFLIMIT,           75
.equ XONLIMIT,            25

;------------------------------------------------------------------------------
; Data handling Module: Global definations of variables
;------------------------------------------------------------------------------

;Data received from the host and to be transmitted
.global dataHostRxBuffer

;Demodulated data to be sent to the Host
.global dataHostTxBuffer

.global dataRxBitCnt                   ;Number of received bits
.global dataHostRxWrite                ;Write Pointer to HostRx Buffer
.global dataHostRxRead                 ;Read Pointer to HostRx Buffer
.global dataHostTxWrite                ;Write Pointer to HostTx Buffer
.global dataHostTxRead                 ;Read Pointer to HostTx Buffer
.global dataTxBitCnt                   ;Number of transmitted bits
.global dataIdleData                   ;Transmit Idle data when no host data
.global dataXoff                       ;Pause data transfer
.global dataNoOfStopBits               ;Count for stop bits

.global datass_word                    ;data with start-stop
.global dataRxDataWord                 ;Assembled data word
.global dataTxDataWord                 ;Data word to be transmitted
.global dataTxBitFn                    ;to switch according to mode
.global dataRxBitFn                    ;to switch according to mode
.global dataDataByte                   ;index,data byte to transmit
.global dataXoffLimit
.global dataXonLimit

;******************************************************************************
;    END OF FILE
;******************************************************************************

