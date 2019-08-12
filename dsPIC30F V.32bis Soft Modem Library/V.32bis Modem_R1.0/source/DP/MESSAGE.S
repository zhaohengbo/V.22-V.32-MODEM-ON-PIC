/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               MESSAGE.S                                          *
;  Date:                   19th July,2002                                     *
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
; 0.1   19 July 2002           Code Created                         Rajiv     *
; 0.2   20 July 2002           Code Reviewed                        Raghava   *
; 0.3   09 August 2002         Modified file/function header        Rajiv     *
; 0.4   23 August 2002         Corrected code documentation faults  Rajiv     *
; 0.5   25 Sept   2003         V.32bis messages are added           Raghava   * 
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Message processing implementation for Microchip's dsPIC30F 16-bit MCU      *
;  Description:    This module processes the messages received by the         *
;                  DataPump. An instance of the data pump is associated with  *
;                  two message queue structures. One for messages from        *
;                  controller to datapump and another for messages from       *
;                  datapump to controller.The data pump can be                *
;                  configured/controlled only by the messages.                *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;  ProcessHostCommands                                                        *
;  ======================                                                     *
;  Description: This function processes the messages received by the DataPump *
;               from the host                                                 *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,w5,w6,w8,w10,w11       used not restored                  *
;    Acc A, Acc B                          used not restored                  *
;                                                                             *
;  Functions Called:   V32LoopBack,V22LoopBack,V23LoopBack,V21LoopBack,       *
;                      InitDtmf,SendMessageToHost,EnableDataTransfer,         *
;                      SetIdleReceiver,SetIdleTransmitter,ResetHostBuffers    *
;                                                                             *
;******************************************************************************
;  SendMessageToHost                                                          *
;  ======================                                                     *
;  Description: This function updates the message Queue for the responses     *
;               received from the DataPump                                    *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w8,w10,w11       used not restored                              *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :  0                                           *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     ProcessHostCommands:     290                                            *
;     SendMessageToHost:       29                                             *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;     .nbss:                   01                                             *
;     .bss:                    64                                             *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     ProcessHostCommands:     cycle count depends on number of Messages      *
;     SendMessageToHost:       cycle count depends on number of Messages      *
;                                                                             *
;*****************************************************************************/


; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "modem.inc"
    .include "apiasm.inc"
    .include "message.inc"
    .include "data.inc"
    .include "defs.inc"
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ProcessHostCommands
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:     This function process the messages given by the controller.
;                   The description of each message is explained in detail
;                   in the data pump API document provided.
; -----------------------------------------------------------------------------

_ProcessHostCommands:
         

START_MSG_PROCESS:

    mov        #ChnMsgInRPtr, w2
    mov        #ChnMsgInWPtr, w0
    mov        [w0], w1
    mov        [w2], w0

    cp         w1, w0

    bra        nz, UPD_MESGID
 
    mov        ChnMsgInRAddr,w1
    mov        w0,[w1] 
   
    return

UPD_MESGID:

    mov        w0, w10
    mov        ChnInMsgEnd,w11

    mov        #mesgMsgId, w2
    mov.b      [w10++], [w2]           ;Get the message ID

    cp         w10,w11
    bra        nz,UPDATE_INMSG_LEN

    mov        ChnInMsgTop,w10         ;and end addresses

UPDATE_INMSG_LEN:

    mov        #mesgMsgLen, w2
    mov.b      [w10++], [w2]           ;Get the message length

    cp         w10,w11
    bra        nz,UPDATE_INMSG_PARAMS

    mov        ChnInMsgTop,w10         ;and end addresses

UPDATE_INMSG_PARAMS:

    clr        w0
    mov.b      mesgMsgLen, wreg

    cp0.b      w0
    bra        z, UPD_MSGIN_RDPTR

    dec        w0, w0
    
UPD_MSGIN_RDPTR:
    mov        w10, ChnMsgInRPtr

    mov        #mDATATODP, w0          ;Check for DATATODP message and process
    cp.b       mesgMsgId
    bra        z, DATATODP_Process

    mov        #mORIGINATE, w0         ;Check for ORIGINATE message and process
    cp.b       mesgMsgId
    bra        z, ORIGINATE_Process
    
    mov        #mANSWER, w0            ;Check for ANSWER message and process
    cp.b       mesgMsgId
    bra        z, ANSWER_Process        

    mov        #mLOOPBACK, w0          ;Check for LOOPBACK message and process
    cp.b       mesgMsgId
    bra        z, LOOPBACK_Process
    
    mov        #mTONEDIAL, w0          ;Check for TONEDIAL message and process
    cp.b       mesgMsgId
    bra        z, TONEDIAL_Process        

    mov        #mDATAMODESELECT, w0    ;Check for DATAMODESELECT message and 
    cp.b       mesgMsgId               ;process 
    bra        z, DATAMODESELECT_Process

    mov        #mMODESELECT, w0        ;Check for MODESELECT message and 
    cp.b       mesgMsgId               ;process
    bra        z, MODESELECT_Process

    mov        #mRATESELECT, w0        ;Check for RATESELECT message and 
    cp.b       mesgMsgId               ;process
    bra        z, RATESELECT_Process

    mov        #mHSMODESELECT, w0      ;Check for HSMODESELECT message and 
    cp.b       mesgMsgId               ;process 
    bra        z, HSMODESELECT_Process

    mov        #mDETECTDIALTONE, w0
    cp.b       mesgMsgId
    bra        z, DETECTDIALTONE_Process

    mov        #mHANGUP, w0            ;Check for HANGUP message and process
    cp.b       mesgMsgId
    bra        z, HANGUP_Process

    mov        #mCLPRGSELECT, w0       ;Check for CLPRGSELECT message and
    cp.b       mesgMsgId               ;process 
    bra        z, CLPRGSELECT_Process

    mov        #mCLPRGTONECADENCE, w0       
    cp.b       mesgMsgId               
    bra        z, CLPRGTONECADENCE_Process

    mov        #mSTARTRETRAIN, w0      ;Check for STARTRETRAIN message and
    cp.b       mesgMsgId               ;process  
    bra        z, STARTRETRAIN_Process
  
    mov        #mSELECTRETRAIN, w0     ;Check for SELECTRETRAIN message and
    cp.b       mesgMsgId               ;process 
    bra        z, SELECTRETRAIN_Process

    mov        #mDIALDURATION, w0      ;Check for DIALDURATION message and
    cp.b       mesgMsgId               ;process
    bra        z, DIALDURATION_Process

    mov        #mSETTXLEVEL, w0        ;Check for SETTXLEVEL message and
    cp.b       mesgMsgId               ;process 
    bra        z, SETTXLEVEL_Process
  
    mov        #mHDLCFRMEND, w0        ;Check for HDLCFRMEND message and
    cp.b       mesgMsgId               ;process
    bra        z, HDLCFRMEND_Process

    mov        #mDPHSTEST, w0          ;Check for HDLCFRMEND message and
    cp.b       mesgMsgId               ;process
    bra        z, DPHSTEST_Process

    bra        START_MSG_PROCESS       ;Check for next message pending

DATATODP_Process:

    clr        w0
    clr        w3
    mov.b      mesgMsgLen, wreg
    dec        w0, w2

    mov.b      dataHostRxWrite, wreg   ;Data buffer write index
    mov        #dataHostRxBuffer, w4   
    
    mov        ChnMsgInRPtr, w10
    mov        ChnInMsgEnd,w11
    mov        #RXDATABUFLEN, w1
    
    do         w2, COPY_DATATO_DP
    mov.b      [w10++], [w4+w0]         ;Copy the data from host to DP buffer
    dec        w2,w2
    cp         w10, w11
    bra        nz,CHK_RXDATALEN

    mov        ChnInMsgTop,w10         ;and end addresses

CHK_RXDATALEN:
       
    inc        w0,w0
    cp         w0,w1
    bra        nz,COPY_DATATO_DP

    clr        w0

COPY_DATATO_DP:
    inc        w3,w3
    mov        w10, ChnMsgInRPtr
    mov.b      wreg,dataHostRxWrite
    bra        START_MSG_PROCESS
    
ORIGINATE_Process:

    mov        #ORIGINATE, w0
    ior.b      modemMode

    cp0.b       mdmDPHSTest
    bra         nz,START_V8_ORG
        
    call       _StartDMOrgHandshake    ;Start the originate mode hand shake
    bra        START_MSG_PROCESS

START_V8_ORG:
     
.if DEF_V8 == 1
    call       _V8Originate
.endif

    bra        START_MSG_PROCESS
        
ANSWER_Process: 

    mov        #ANSWER, w0
    ior.b      modemMode

    cp0.b       mdmDPHSTest
    bra         nz,START_V8_ANS
    
    call       _StartDMAnsHandshake    ;Start the answer mode hand shake
    bra        START_MSG_PROCESS

START_V8_ANS:

.if DEF_V8 == 1
    call        _V8Answer
.endif

    bra        START_MSG_PROCESS
   
LOOPBACK_Process:

    mov        #ANALOGLOOPBACK, w0     ;Start the digital loop back in the 
    ior.b      modemMode               ;specified mode(ConnectMode)
    
.if (DEF_V32BIS == 1 || DEF_V32 == 1)
    mov        #16, w0
    cp.b       ucConnectMode
    bra        nz, V22_LOOPBACK

    call       _V32LoopBack
    bra        START_MSG_PROCESS
.endif

V22_LOOPBACK:

.if DEF_V22 == 1
    mov        #18, w0
    cp.b       ucConnectMode
    bra        gt, V23_LOOPBACK

    call       _V22LoopBack
    bra        START_MSG_PROCESS
.endif

V23_LOOPBACK:    

.if DEF_V23 == 1
    mov        #20, w0
    cp.b       ucConnectMode
    bra        gt, V21_LOOPBACK

    call       _V23LoopBack
    bra        START_MSG_PROCESS
.endif

V21_LOOPBACK:

.if DEF_V21 == 1
    mov        #21, w0
    cp.b       ucConnectMode
    bra        gt, B103_LOOPBACK

    call       _V21LoopBack
    bra        START_MSG_PROCESS
.endif

B103_LOOPBACK:

.if DEF_B103 == 1
    mov       #64,w0
    mov.b     wreg, ucHS_Mode
    call      _V21LoopBack
.endif

    bra         START_MSG_PROCESS

TONEDIAL_Process:

    bra       START_MSG_PROCESS        ;Check for next message in the queue

DATAMODESELECT_Process:
 
    mov        ChnMsgInRPtr, w10
    mov        ChnInMsgEnd,w11
    mov.b      [w10++], w0
    cp         w10, w11
    bra        nz,SETMODETX
    mov        ChnInMsgTop,w10         ;and end addresses

SETMODETX:
    mov.b     wreg,ucDataModeSel
    mov        w10, ChnMsgInRPtr
        
    mov       #CARRIERDETECT, w0
    and.b     modemStatus,wreg
    bra       z, TEST_STOP_BITS

    call      _EnableDataTransfer

TEST_STOP_BITS:

    mov       #DATA_L2MSS, w0
    cp.b      ucDataModeSel
    bra       nz, END_DATAMODE_SELECT

    mov        ChnMsgInRPtr, w10
    mov        ChnInMsgEnd,w11
    mov.b      [w10++], w0
    cp         w10, w11
    bra        nz,SETSTOPBITS
    mov        ChnInMsgTop,w10         ;and end addresses

SETSTOPBITS:
 
    mov       w10, ChnMsgInRPtr
    mov.b     wreg, dataNoOfStopBits
      
END_DATAMODE_SELECT:

    bra       START_MSG_PROCESS
    

MODESELECT_Process:
 
    mov        ChnMsgInRPtr, w10
    mov        ChnInMsgEnd,w11
    mov.b      [w10++], w0
    cp         w10, w11
    bra        nz,SETLBMODE
    mov        ChnInMsgTop,w10         ;and end addresses

SETLBMODE:

    mov        w10, ChnMsgInRPtr
    mov.b     wreg,ucConnectMode

    bra       START_MSG_PROCESS

RATESELECT_Process:
 
    mov        ChnMsgInRPtr, w10
    mov        ChnInMsgEnd,w11
    mov.b      [w10++], w0
    cp         w10, w11
    bra        nz,SETRATETX
    mov        ChnInMsgTop,w10         ;and end addresses

SETRATETX:

    mov        w10, ChnMsgInRPtr
    mov.b      wreg, ucConnectRate
    
    bra       START_MSG_PROCESS

HSMODESELECT_Process:
 
    mov        ChnMsgInRPtr, w10
    mov        ChnInMsgEnd,w11
    mov.b      [w10++], w0
    cp         w10, w11
    bra        nz,SETHSMODE
    mov        ChnInMsgTop,w10         ;and end addresses

SETHSMODE:
    mov        w10, ChnMsgInRPtr

.if DEF_V32 == 1
    bset      V32NTCMEnable,#0

.if DEF_V32BIS == 1
    clr       V32NTCMEnable
.endif

.endif
    
    cp0.b     w0
    bra       nz, END_HSMODE_SEL

.if DEF_V8 == 1
    mov       #ENABLE_V8, w3
    ior.b     w0, w3, w0
    ior.b     ucHS_Mode
.endif

.if (DEF_V32BIS == 1 || DEF_V32 == 1)
    mov       #ENABLE_V32, w3
    ior.b     w0, w3, w0
    ior.b     ucHS_Mode
.endif

.if DEF_V22 == 1
    mov       #ENABLE_V22, w3
    ior       w0, w3, w0
    ior.b     ucHS_Mode
.endif

.if DEF_V23 == 1
    mov       #ENABLE_V23, w3
    ior       w0, w3, w0
    ior.b     ucHS_Mode
.endif

.if DEF_V21 == 1
    mov       #ENABLE_V21, w3
    ior       w0, w3, w0
    ior.b     ucHS_Mode
.endif

    bra       START_MSG_PROCESS

END_HSMODE_SEL:
.if DEF_V32 == 1
    cp.b      w0,#3
    bra       z, ENBALE_V32_HS_1

    cp.b      w0,#5
    bra       z, ENBALE_V32_NTCM_1
.endif

    mov.b     wreg, ucHS_Mode
    bra       START_MSG_PROCESS

.if DEF_V32 == 1

ENBALE_V32_HS_1:
    mov       #5,w0
    mov.b     wreg, ucHS_Mode
    bra       START_MSG_PROCESS

ENBALE_V32_NTCM_1:
    mov       #5,w0
    mov.b     wreg, ucHS_Mode
    mov       #1,w0
    mov       w0, V32NTCMEnable
    bra       START_MSG_PROCESS
.endif

DETECTDIALTONE_Process:

.if DEF_CALLPROG == 1
    call      _InitDialToneDetector
.endif
    bra       START_MSG_PROCESS


HANGUP_Process:

    mov.b      #mHANGUPCOMPLETE,w0     ;Hangup the modem by resetting the modem
    mov.b      wreg,mesgMsgId          ;status

    clr.b       mesgMsgLen
    mov         #mesgMsgParams, w8
    rcall      _SendMessageToHost

    call      _SetIdleReceiver
    call      _SetIdleTransmitter

    clr.b     modemStatus
    clr.b     modemMode

;   mov       #_NullFunction, w0
    mov       #handle(_NullFunction), w0
    mov       w0, modemManager

    call      _ResetHostBuffers

    bra       START_MSG_PROCESS
    
CLPRGSELECT_Process:

    mov        ChnMsgInRPtr, w10
    mov        ChnInMsgEnd,w11
    mov.b      [w10++], w0
    cp         w10, w11
    bra        nz,SETCP_CONFIG
    mov        ChnInMsgTop,w10         ;and end addresses

SETCP_CONFIG:
 
    mov        w10, ChnMsgInRPtr
    mov.b     wreg, ucClprgConfig

    bra       START_MSG_PROCESS
    
CLPRGTONECADENCE_Process:
.if DEF_CALLPROG == 1

    clr       w3
    clr       w2
    
    mov        ChnMsgInRPtr, w10
    mov        ChnInMsgEnd,w11
    mov.b      [w10++], w3
    cp         w10, w11
    bra        nz,READ_BUSYONTIME
    mov        ChnInMsgTop,w10         ;and end addresses

READ_BUSYONTIME:
    mov.b      [w10++], w2
    cp         w10, w11
    bra        nz,SET_BUSYONTIME
    mov        ChnInMsgTop,w10         ;and end addresses

SET_BUSYONTIME:
    sl        w2, #8, w2
    ior       w2,w3,w3
    sl        w3, #3, w3
    mov       w3, ucBusyOnTime
    clr       w3

    mov.b      [w10++], w3
    cp         w10, w11
    bra        nz,READ_BUSYOFFTIME
    mov        ChnInMsgTop,w10         ;and end addresses

READ_BUSYOFFTIME:
    mov.b      [w10++], w2
    cp         w10, w11
    bra        nz,SET_BUSYOFFTIME
    mov        ChnInMsgTop,w10         ;and end addresses

SET_BUSYOFFTIME:
    sl        w2, #8, w2
    ior       w2,w3,w3
    sl        w3, #3, w3
    mov       w3, ucBusyOffTime

    clr       w3
    mov.b     [w10++], w3
    cp         w10, w11
    bra        nz,SET_REORDONTIME
    mov        ChnInMsgTop,w10         ;and end addresses

SET_REORDONTIME:

    sl        w3, #3, w3
    mov       w3, ucReorderOnTime
    clr       w3
 
    mov.b      [w10++], w3
    cp         w10, w11
    bra        nz,SET_REORDOFFTIME
    mov        ChnInMsgTop,w10         ;and end addresses

SET_REORDOFFTIME:
  
    sl        w3, #3, w3
    mov       w3, ucReorderOffTime
    clr       w3

    mov.b      [w10++], w3
    cp         w10, w11
    bra        nz,READ_RINGONTIME
    mov        ChnInMsgTop,w10         ;and end addresses

READ_RINGONTIME:
    mov.b      [w10++], w2
    cp         w10, w11
    bra        nz,SET_RINGONTIME
    mov        ChnInMsgTop,w10         ;and end addresses

SET_RINGONTIME:
    sl        w2,#8,w2
    ior       w2,w3,w3
    sl        w3, #3, w3
    mov       w3, ucRingOnTime
    clr       w3
 
    mov.b      [w10++], w3
    cp         w10, w11
    bra        nz,READ_RINGOFFTIME
    mov        ChnInMsgTop,w10         ;and end addresses

READ_RINGOFFTIME:
    mov.b      [w10++], w2
    cp         w10, w11
    bra        nz,SET_RINGOFFTIME
    mov        ChnInMsgTop,w10         ;and end addresses
SET_RINGOFFTIME:
    sl        w2, #8, w2 
    ior       w2,w3,w3
    sl        w3, #3, w3
    mov       w3, ucRingOffTime
    
    clr       w3
 
    mov.b      [w10++], w3
    cp         w10, w11
    bra        nz,SET_RINGCOUNT
    mov        ChnInMsgTop,w10         ;and end addresses

SET_RINGCOUNT:
 
    sl        w3, #1, w3
    mov       w3, ucRingCount

    mov        w10, ChnMsgInRPtr
.endif
    
    bra       START_MSG_PROCESS

STARTRETRAIN_Process:

    mov      #ANALOGLOOPBACK, w0           ;Initiate the retrain procedure
    and.b    modemMode,wreg
    bra      nz, START_MSG_PROCESS

    clr.b    ECEnable

    call     InitiateRetrainProcedures
    
    bra      START_MSG_PROCESS

SELECTRETRAIN_Process:
 
    mov        ChnMsgInRPtr, w10
    mov        ChnInMsgEnd,w11

    mov.b      [w10++], w0
    cp         w10, w11
    bra        nz,SET_AUTORET
    mov        ChnInMsgTop,w10         ;and end addresses

SET_AUTORET:

    mov        w10, ChnMsgInRPtr
    mov.b     wreg, ucAutoRetrain

    bra      START_MSG_PROCESS

DIALDURATION_Process:

    clr       w1                       ;Set the dial signal duration
 
    mov        ChnMsgInRPtr, w10
    mov        ChnInMsgEnd,w11

    mov.b      [w10++], w0
    cp         w10, w11
    bra        nz,SET_DIALDUR
    mov        ChnInMsgTop,w10         ;and end addresses

SET_DIALDUR:
  
    sl        w0,#8,w0
 
    mov.b      [w10++], w0
    cp         w10, w11
    bra        nz,SET_DTMFDUR
    mov        ChnInMsgTop,w10         ;and end addresses

SET_DTMFDUR:
    
    mov        w10, ChnMsgInRPtr
        
    mov       w0, ucDtmfDuration
    bra       START_MSG_PROCESS

SETTXLEVEL_Process:
 
    clr        w0
    mov        ChnMsgInRPtr, w10
    mov        ChnInMsgEnd,w11

    mov.b      [w10++], w0
    cp         w10, w11
    bra        nz,SET_TXLVL
    mov        ChnInMsgTop,w10         ;and end addresses

SET_TXLVL:
  
    mov       #0x3c60,w4
    mov       w4,ucTransmitLevel

    mov       #0x7214, w5

CHK_TX_LEVEL:

    cp0       w0
    bra       z, CHK_TXSCALE_FACTOR

    mpy       w4*w5, A
    sac.r     A, w4

    dec       w0, w0
    bra       CHK_TX_LEVEL


CHK_TXSCALE_FACTOR:

    mov       w10, ChnMsgInRPtr
    mov       w4, ucTransmitLevel
    bra       START_MSG_PROCESS

HDLCFRMEND_Process:
                                 
   mov        #0xFF,w4                 ;Indicates the end of HDLC frame
                                       ;(Sync mode)                                       
   clr        w0
   mov.b      dataHostRxWrite, wreg
   mov        #dataHostRxBuffer, w3

   inc.b      dataHostRxWrite  
   mov.b      w4, [w3+w0]

   mov        #RXDATABUFLEN, w0

   cp.b       dataHostRxWrite
   bra        nz, EXIT_HDLCMSG

   clr.b      dataHostRxWrite

EXIT_HDLCMSG:

   bra        START_MSG_PROCESS

DPHSTEST_Process:
   
   mov        #1,w0
   mov.b      wreg,mdmDPHSTest
   bra        START_MSG_PROCESS

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SendMessageToHost
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function update the message Queue to send the 
;                 messages given by the datapump to the host.
; -----------------------------------------------------------------------------

_SendMessageToHost:

    mov        ChnMsgOutWPtr, w10

    mov        #mesgMsgId, w2
    mov        ChnOutMsgEnd,w11
    mov.b      [w2], [w10++]           ;Get the message ID

    cp         w10,w11
    bra        nz,UPDATE_MSG_LEN
    
    mov        ChnOutMsgTop,w10        ;and end addresses

UPDATE_MSG_LEN:

    mov        #mesgMsgLen, w2
    clr        w0
    mov.b      [w2],[w10++]            ;Get the message length

    cp         w10,w11
    bra        nz,UPDATE_MSG_PARAMS
    
    mov        ChnOutMsgTop,w10        ;and end addresses

UPDATE_MSG_PARAMS:

    mov.b      mesgMsgLen, wreg
    cp0.b      w0
    bra        z, UPD_MSGOUT_WRPTR

    dec        w0, w0                  ;Decrement the mesg length

    do         w0,UPDATE_MSG_PARAMS1

    mov.b      [w8++],[w10++] 

    cp         w10,w11
    bra        nz,UPDATE_MSG_PARAMS1

    mov        ChnOutMsgTop,w10        ;and end addresses
    
UPDATE_MSG_PARAMS1:
    nop

UPD_MSGOUT_WRPTR:

    mov        ChnMsgOutWAddr,w1    
    mov        w10, ChnMsgOutWPtr         
    mov        w10,[w1]
    
    return


; -----------------------------------------------------------------------------
;   END OF FILE
; -----------------------------------------------------------------------------
