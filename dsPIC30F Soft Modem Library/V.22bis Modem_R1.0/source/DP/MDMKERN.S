/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               MDMKERN.S                                          *
;  Date:                   18th July,2002                                     *
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
; 0.1   18 July 2002           Code Created                         Rajiv     *
; 0.2   22 July 2002           Code Reviewed                        Raghava   *
; 0.3   09 August 2002         Modified file/function header        Rajiv     *
; 0.4   23 August 2002         Corrected code documentation faults  Rajiv     *
; 0.5   24 September 2002      Modules added for utilizing program  Rajiv     *
;                              memory for saving DP state variables           *
;                              for state machine test                         *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Modem kernel implementation for Microchip's dsPIC30F 16-bit MCU            *
;  Description:    The task scheduler is the outermost contol interface to the*
;                  Software Modem. The main function of the task scheduler is *
;                  to prepare and execute the transmit and receive functions. *
;                  It executes functions that are necessary for generation of *
;                  transmit samples and processing the input receive samples. *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;                                                                             *
;******************************************************************************
;  ClearStruct                                                                *
;  ======================                                                     *
;  Description: This function clears the variables of specified data structure*
;  ======================                                                     *
;  Input:                                                                     *
;        w0 = base address of DATASTRUCT                                      *
;        w1 = sizeof DATASTRUCT                                               *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2                   used not restored                             *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  ModemChannelActivate                                                       *
;  ======================                                                     *
;  Description: The Modem channel is activated. All initializations are done. *
;  ======================                                                     *
;  Input:                                                                     *
;       w0 = &PCM DATA STRUCT                                                 *
;       w1 = &Input Message Struct                                            *
;       w2 = &Output Message struct                                           *
;  Output:                                                                    *
;        Zero                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w4,w5,w6,w7         used not restored                           *
;    w8,w9,w10,w11,w12,w13,w14    used saved and restored                     *
;    PSVPAG                       used saved and restored                     *
;                                                                             *
;  Functions Called:   InitSIPL,InitializeAGC,InitHilbert,                    *
;                      SetIdleTransmitter,SetIdleReceiver,NullFunction,       *
;                      SendMessageToHost                                      *
;                                                                             *
;******************************************************************************
;  ModemChannelProcess                                                        *
;  ======================                                                     *
;  Description: This function processes PCM data and Host commands            *
;  ======================                                                     *
;  Input:                                                                     *
;       w0 = &PCM DATA STRUCT                                                 *
;       w1 = &Input Message Struct                                            *
;       w2 = &Output Message struct                                           *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2,w4                    used not restored                          *
;   w8,w9,w10,w11,w12,w13,w14      used saved and restored                    *
;   CORCON                         used saved and restored                    *
;                                                                             *
;  Functions Called:   ProcessHostCommands,ProcessPCM,SendDataToHost          *
;                                                                             *
;******************************************************************************
;  ProcessPCM                                                                 *
;  ======================                                                     *
;  Description: The main function is to prepare and execute the transmit      *
;               and receive functions.                                        *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2,w3                    used not restored                          *
;                                                                             *
;  Functions Called:   ButterWorth,ECProc,SIPL,MeanLevel                      *
;                                                                             *
;******************************************************************************
;  SendSample                                                                 *
;  ======================                                                     *
;  Description: This function Scales and update the sample into               *
;               PCM output buffer.                                            *
;  ======================                                                     *
;  Input:                                                                     *
;        w0 = Transmit Sample                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2,w4,w5,w6              used not restored                          *
;   ACC A                          used not restored                          *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  SetIdleReceiver                                                            *
;  ======================                                                     *
;  Description: This funcion sets modem receiver to idle state                *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2                    used not restored                                *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  SetIdleTransmitter                                                         *
;  ======================                                                     *
;  Description: This funcion sets modem tramsmiter to idle state              *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2                    used not restored                                *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  IdleTransmitter                                                            *
;  ======================                                                     *
;  Description: This funcion initializes modem tramsmitter to idle transmitter*
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0                        used not restored                               *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  IdleReceiver                                                               *
;  ======================                                                     *
;  Description: This function initializes the modem receiver to idle receiver *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   None                                                                      *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  NullFunction                                                               *
;  ======================                                                     *
;  Description: No processing is done in this function                        *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   None                                                                      *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  SetTransmiter                                                              *
;  ======================                                                     *
;  Description: This function enables transmitter                             *
;  ======================                                                     *
;  Input:                                                                     *
;        Transmiter function address                                          *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0                       used not restored                                *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  SetReceiver                                                                *
;  ======================                                                     *
;  Description: This function enables reciever                                *
;  ======================                                                     *
;  Input:                                                                     *
;        Receiever function address                                           *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0                       used not restored                                *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  SaveDPData                                                                 *
;  ======================                                                     *
;  Description: This function saves all the Modem Variables in program memory *
;  ======================                                                     *
;  Input:                                                                     *
;        Base Address of Buffer,where Data will be saved in program memory    *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2                   used not restored                              *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  RestoreDPData                                                              *
;  ======================                                                     *
;  Description: This function restores the Modem Variables from program memory*
;  ======================                                                     *
;  Input:                                                                     *
;        Base addressof Buffer, from where Data is to be retrieved.           *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2                     used not restored                            *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  SendDebugInfo                                                              *
;  ======================                                                     *
;  Description: This function sends the debug messages to the Host.           *
;  ======================                                                     *
;  Input:                                                                     *
;        Message Parameter                                                    *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0                           used not restored                            *
;                                                                             *
;  Functions Called:   SendMessageToHost                                      *
;                                                                             *
;******************************************************************************
;  ClearDPCDB                                                                 *
;  ======================                                                     *
;  Description: This function clears Data pump variables.                     *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2                     used not restored                            *
;                                                                             *
;  Functions Called:   ClearNBSS,ClearBSS,ClearXBSS,ClearYBSS                 *
;                                                                             *
;******************************************************************************
;  ClearNBSS                                                                  *
;  ======================                                                     *
;  Description: This function clears .nbss variables.                         *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2                     used not restored                            *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  ClearBSS                                                                   *
;  ======================                                                     *
;  Description: This function clears .bss variables.                          *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2                     used not restored                            *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  ClearXBSS                                                                  *
;  ======================                                                     *
;  Description: This function clears .xbss variables.                         *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2                     used not restored                            *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  ClearYBSS                                                                  *
;  ======================                                                     *
;  Description: This function clears .ybss variables.                         *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2                     used not restored                            *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   22                                         *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     ClearStruct:                 5                                          *
;     ModemChannelActivate:        78                                         *
;     ModemChannelProcess:         36                                         *
;     ProcessPCM:                  68                                         *
;     SendSample:                  40                                         *
;     SetIdleReceiver:             6                                          *
;     SetIdleTransmiter:           6                                          *
;     IdleTransmitter:             2                                          *
;     IdleReceiver:                1                                          *
;     NullFunction:                1                                          *
;     SetTransmitter:              5                                          *
;     SetReceiever:                5                                          *
;     SaveDPData:                  17                                         *
;     RestoreDPData:               17                                         *
;     SendDebugInfo:               8                                          *
;     ClearDPCDB:                  16                                         *
;     ClearNBSS:                   8                                          *
;     ClearBSS:                    8                                          *
;     ClearXBSS:                   8                                          *
;     ClearYBSS:                   8                                          *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     IpBpCoefs:                   6                                          *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;     .nbss:                       15                                         *
;     .bss :                       33                                         *
;     .ybss:                       10                                         *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     ClearStruct:           Depends on size of Memory to be cleared          *
;     ModemChannelActivate:   80                                              *
;     ModemChannelProcess:    38                                              *
;     ProcessPCM:             14+(57*PCMFrmLength)                            *
;     SendSample:             42                                              *
;     SetIdleReceiver:        8                                               *
;     SetIdleTransmiter:      8                                               *
;     IdleTransmitter:        4                                               *
;     IdleReceiver:           3                                               *
;     NullFunction:           3                                               *
;     SetTransmitter:         7                                               *
;     SetReceiever:           7                                               *
;     SaveDPData:             8971                                            *
;     RestoreDPData:          8971                                            *
;     SendDebugInfo:          10                                              *
;     ClearDPCDB:             17                                              *
;     ClearNBSS:              252                                             *
;     ClearBSS:               1880                                            *
;     ClearXBSS:              947                                             *
;     ClearYBSS:              1077                                            *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include   "defs.inc"
    .include "modem.inc"
    .include "apiasm.inc"
    .include "message.inc"
    .include "tables.inc"
.if DEF_CALLPROG == 1
    .include "Callprog.inc"
.endif
    .include "Agc.inc"
    .include "Carrec.inc"
    .include "Data.inc"
    .include "Dmctrl.inc"
    .include "Eqz.inc"
    .include "Filter.inc"
    .include "Psf.inc"
    .include "Sbar.inc"
    .include "sipl.inc"
.if DEF_V22 == 1
    .include "v22.inc"
.endif
.if DEF_V23 == 1
    .include "V23.inc"
.endif
.if DEF_V25 == 1
    .include "V25.inc"
.endif
.if DEF_V32 == 1
    .include "V32.inc"
.endif
.if DEF_V8 == 1
    .include "V8.inc"
.endif
.if DEF_V32 == 1
    .include "EC.inc"    
.endif


; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ClearStruct
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function clears the specified data structure 
; -----------------------------------------------------------------------------

_ClearStruct:

    clr        w2                      ; initialize w2 to zero
    dec        w1, w1                  ; adjust w1 for repeat loop requirement
    repeat     w1                      ; repeat target instruction w1 times
    mov        w2, [w0++]              ; clear structure memory element
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ClearStructByte
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function clears the specified data structure 
; -----------------------------------------------------------------------------

_ClearStructByte:

    clr        w2                      ; initialize w2 to zero
    dec        w1, w1                  ; adjust w1 for repeat loop requirement
    repeat     w1                      ; repeat target instruction w1 times
    mov.b      w2, [w0++]              ; clear structure memory element
    return

   
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ModemChannelActivate
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:  The Modem channel is activated. All initializations are done.
; -----------------------------------------------------------------------------

_ModemChannelActivate:

    bclr.b     CORCON, #5
    push       w8                      ;Save the register status required
    push       w9
    push       w10
    push       w11
    push       w12
    push       w13
    push       w14
    push       PSVPAG
    push       CORCON
    
    bset.b     CORCON, #2

    call      _ClearDPCDB

    mov        [w0+#PCMFRMLEN], w4
    mov        w4, ChnPcmBufLen        ;Save the PCM buffer length
      
    mov        [w0+#PCMINPTR], w4
    mov        w4, ChnPcmInPtr         ;Save the PCM input buffer pointer

    mov        [w0+#PCMOUTPTR], w4
    mov        w4, ChnPcmOutPtr        ;Save the PCM output buffer pointer

    mov        [w1+#MSGBUFFER], w4
    mov        w4, ChnInMsgTop         ;Save the Input message buffer pointer

    mov        [w1+#MSGQLENGTH], w5
    add        w4, w5, w6              ;Calculate and save the input message
    mov        w6, ChnInMsgEnd         ;buffer end pointer

    mov        [w1+#MSGWRITEPTR], w4
    mov        w4, ChnMsgInWPtr        ;Save the input msg buffer write pointer

    mov        [w1+#MSGREADPTR], w4
    mov        w4, ChnMsgInRPtr        ;Save the input msg buffer read pointer

    add        w1,#MSGREADPTR,w4
    mov        w4,ChnMsgInRAddr    

    mov        [w2+#MSGBUFFER], w4
    mov        w4, ChnOutMsgTop        ;Save the Out message buffer pointer

    mov        [w2+#MSGQLENGTH], w5    ;Calculate and save the out message
    add        w4, w5, w6              ;buffer end pointer  
    mov        w6, ChnOutMsgEnd

    mov        [w2+#MSGWRITEPTR], w4
    mov        w4, ChnMsgOutWPtr       ;Save the out msg buffer write pointer

    add        w2,#MSGWRITEPTR,w4
    mov        w4,ChnMsgOutWAddr    
    
    mov        [w2+#MSGREADPTR], w4
    mov        w4, ChnMsgOutRPtr       ;Save the out msg buffer read pointer

    clr.b      mdmAdcDelay
    clr.b      mdmDacDelay
    
.if DEF_V32 == 1
    mov        #(MAXBULKDELAY*2),w0
    mov        w0,ECFECBufferLength
.endif
    
    call       _InitSIPL               ;Setup the parameters for SIPL 
    call       _InitializeAGC          ;Setup AGC parameters
.if (DEF_V32 == 1 || DEF_V22 == 1)
    call       _InitHilbert            ;Setup Hilbert filter parameters
.endif
    mov        #psvpage(IpBpCoefs),w2  ;Get DC filter coeffs in program memory
    mov        w2, PSVPAG              ;Initialize PSVPAG SFR register 
    mov        #psvoffset(IpBpCoefs),w1;Point w1 to IpBpCoefs Table
    mov        w1,mdmIpBpCoefsPtr      ;Save the IpBpCoefs Pointer
    
    rcall      _SetIdleTransmitter     ;Initially transmission is idle
    rcall      _SetIdleReceiver        ;Initially reception is idle 

    mov        #handle(_NullFunction), w1
    mov        w1, modemManager        ;No modem state switching is enabled

    mov        #handle(_NullFunction), w1
    mov        w1, dataRxBitFn          ;No reception of bits initially

    mov        #handle(_Get1s), w1
    mov        w1, dataTxBitFn          ;Initially transmit binary 1's        

    mov        #1,w0
    mov.b      wreg, mdmV8Enable       ;Enable V.8 hand shake
    mov.b      wreg, ucAutoRetrain     ;Enable auto retrain of modem

    mov        #0x1c00, w2
    mov        w2, mdmTxGainFactor     ;Set the default transmit gain
    mov        w2, ucTxScaleFactor

    mov        #DATA_L2MSS, w0         ;Set for async data transmission
    mov.b      wreg, ucDataModeSel

    mov        #0xff, w0               ;Idle data = binary 1's
    mov.b      wreg, ucIdleDataSet 
  
    mov        #(RXDATABUFLEN-25),w0
    mov        w0,dataXoffLimit

    mov        #(RXDATABUFLEN-75),w0
    mov        w0,dataXonLimit
    
    mov        #1, w0
    mov.b      wreg, mdmSiplEnable

    mov        #mMODEMREADY,w0         ;Indicate the host that the modem 
    mov.b      wreg,mesgMsgId          ;is ready

    clr.b       mesgMsgLen
    mov        #mesgMsgParams, w8
    call       _SendMessageToHost

    pop       CORCON                   ;Retreive the registers saved
    pop       PSVPAG
    pop       w14
    pop       w13
    pop       w12
    pop       w11
    pop       w10
    pop       w9
    pop       w8                       

    mov        #0, w0
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ModemChannelProcess
   .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function processes PCM data, process the
;                 Host commands and also send data to the HOST
; -----------------------------------------------------------------------------

_ModemChannelProcess:

    push       CORCON
    push       w8                      ;Save the register status needed
    push       w9
    push       w10
    push       w11
    push       w12
    push       w13
    push       w14
    push       w3
    
    bset.b     CORCON, #1
    bset.b     CORCON, #2

    mov        #psvpage(IpBpCoefs),w3  ;Get DC filter coeffs in program memory
    mov        w3, PSVPAG              ;Initialize PSVPAG SFR register 
        
    mov        [w0+#PCMFRMLEN], w4
    mov        w4, ChnPcmBufLen        ;Save the PCM buffer length

    mov        [w0+#PCMINPTR], w4
    mov        w4, ChnPcmInPtr         ;Save the PCM input buffer pointer

    mov        [w0+#PCMOUTPTR], w4
    mov        w4, ChnPcmOutPtr        ;Save the PCM output buffer pointer

    mov        [w1+#MSGWRITEPTR], w4
    mov        w4, ChnMsgInWPtr        ;Save the input msg buffer write pointer

    mov        [w1+#MSGREADPTR], w4
    mov        w4, ChnMsgInRPtr        ;Save the input msg buffer read pointer

    mov        [w2+#MSGWRITEPTR], w4
    mov        w4, ChnMsgOutWPtr       ;Save the out msg buffer write pointer

    mov        [w2+#MSGREADPTR], w4
    mov        w4, ChnMsgOutRPtr       ;Save the out msg buffer read pointer

    mov        #1, w0
    mov.b      wreg, mdmTxSmpCntr      ;Enable transmission of samples
      
    call      _ProcessHostCommands     ;Process messages sent by host

    rcall      _ProcessPCM             ;Process the PCM samples and also
                                      ;generate samples
    pop        w3
 
    call       _SendDataToHost         ;Send the demodulated data to host
    call       _CheckDPFlowControl

    pop       w14                      ;Retreive the registers saved
    pop       w13
    pop       w12
    pop       w11
    pop       w10
    pop       w9
    pop       w8                       
    pop       CORCON
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ProcessPCM
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   The main function of this function is to prepare and 
;                 execute the transmit and receive functions.It executes 
;                 functions that are necessary for generation of transmit 
;                 samples and processing the input receive samples. 
; -----------------------------------------------------------------------------

_ProcessPCM:

    mov        #ChnPcmBufLen, w3
    clr.b      mdmPcmRxIndex    
    mov        [w3], w0    

    mov.b      wreg, mdmRxSmpCntr      ;Initialize the counters for received
    mov.b      wreg, mdmPcmBufLen      ;samples
    
    clr.b      mdmPcmTxIndex           ;Clear PCM Tx & Rx buffers indices


PCM_PROCESS:

    dec.b      mdmRxSmpCntr            ;Decrement the received sample counter 

    mov        ChnPcmInPtr, w3         ;Pcm input buffer pointer
    
    mov        #mdmFilterBuffer, w1
    mov        #mdmIpBpDly, w0         ;DC filter delay line pointer
    add        w0, w1, w0
    mov        mdmIpBpCoefsPtr, w1     ;DC filter coefs pointer

    mov        [w3++], w2              ;Get the Rx sample
    mov        w3,ChnPcmInPtr          ;Update the PCM input buffer pointer

    call       _ButterWorth            ;Filter the input sample(DC filter)
    mov       w0, mdmADCSample         ;Update filtered sample

.if DEF_V32
    call      _ECProc                  ;Cancel the echo in the received signal
    mov       w0, mdmADCSample
.endif

    cp0.b     mdmSiplEnable
    bra       z, NO_SIPL
    
    mov       mdmSamplePhaseAdjust, w1

    call      _SIPL                    ;Clock phase adjustment for Rx signal

    bra       SAMPLES_LOOP

NO_SIPL:
    mov       w0, SIPLOutput
    mov       #1, w0

SAMPLES_LOOP:
    
    mov       #0, w2
    mov       w2, mdmSamplePhaseAdjust 

CHK_SIPL_SMPLS:

    cp0       w0
    bra       z, TX_PROCESS            ;Switch to Tx process if No samples
                                       ;after phase adjustment
    mov       #SIPLOutput, w3
    
    dec       w0, w0                   ;Update and save the SIPL output
    push      w0                       ;counter

    mov       [w3+w2], w1              ;Received sample(after phase adj)
       
    inc2      w2, w2                   ;Update the SIPL output buffer index
    push      w2                       ;Save the SIPL output buffer index 

    mov       #mdmMeanPRunAvg, w0      ;Estimate the average level of the input
    mov       w1,mdmADCSample          ;signal over 32 sample window
    call      _MeanLevel               
                                       
    cp0       w0
    bra       z, RX_PROCESS

    mov       mdmMeanPLevel,w0
    mov       w0, mdmAverageInputLevel ;Update the signal average level once in
                                       ;32 samples
    clr.b     mdmSignalHigh            ;Signal level is checkd for minimum

    mov       #mdmAverageInputLevel, w2
    mov       #LVL_43dBm, w0           ;level of -43dBm
    mov       [w2], w1
    cp        w1, w0
    bra       le, RX_PROCESS

    inc.b     mdmSignalHigh            ;Signal level is set if level is 
                                       ;greater than -43dBm

RX_PROCESS:

    mov       modemReceiver, w0        ;Execute the Modem receiver function
    call      w0

    pop       w2                       ;Retreive the SIPL output buffer index
    pop       w0                       ;Retreive the SIPL output counter
    
    bra       CHK_SIPL_SMPLS           ;Process all the samples in SIPL output
                                       ;buffer
TX_PROCESS:

    cp0.b     mdmTxSmpCntr
    bra       z, MDM_MAN_PROCESS

    mov       modemTransmiter, w0      ;Execute the Modem transmitter 
    call      w0
    rcall     _SendSample              ;Scale and update the sample into
                                       ;PCM output buffer
MDM_MAN_PROCESS:

    mov       modemManager, w0         ;Execute the Modem manager function
    call      w0

    cp0.b     mdmRxSmpCntr             ;Exit the PCM processing loop after 
    bra       nz, CHK_NEXT_SMPL_PROCESS;processing all the samples in the frame

    cp0.b     mdmTxSmpCntr
    bra       nz, CHK_NEXT_SMPL_PROCESS

    goto      EXIT_PCM_PROCESS

CHK_NEXT_SMPL_PROCESS:   

    cp0.b      mdmRxSmpCntr
    bra        nz, PCM_PROCESS         ;Check for the availability of next
                                       ;sample for processing
EXIT_PCM_PROCESS:

    mov        #0x10, w0               ;Change the sampling rate if required at
    and.b      mdmRCTxRatio,wreg       ;the end of the frame
    bra        z, NO_SMPRATE_CHANGE
    
    mov        #mSELECTSMPRATE,w0      ;Select the required sampling
    mov.b      wreg,mesgMsgId          ;rate

    mov       #1,w0
    mov.b     wreg,mesgMsgLen

    mov       #mesgMsgParams, w8

    mov        #0xf, w0    
    and.b      mdmRCTxRatio, wreg
    mov.b      w0, [w8]
  
    call       _SendMessageToHost

NO_SMPRATE_CHANGE:

    clr.b      mdmRCTxRatio

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SendSample
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function Scales and update the sample into
;                 PCM output buffer.
; -----------------------------------------------------------------------------

_SendSample:

    mov        w0, w4
                                
    mov        modemTimerA, w0         ;Update the modem timers (A & B) used 
    mov        modemTimerA+2, w1       ;in state switching (Used for time  
                                       ;reference)
    sub        w0, #0, w0
    subb       w1, #0, w1

    bra        z, CHK_TIMER_B
    
    sub        w0, #1, w0
    subb       w1, #0, w1    

    mov        w0, modemTimerA         ;Decrement the modem Timer A
    mov        w1, modemTimerA+2

CHK_TIMER_B:
    
    mov        modemTimerB, w0
    mov        modemTimerB+2, w1

    sub        w0, #0, w0
    subb       w1, #0, w1

    bra        z, SCALE_TX_SAMPLE

    sub        w0, #1, w0
    subb       w1, #0, w1

    mov        w0,modemTimerB
    mov        w1, modemTimerB+2       ;Decrement the modem Timer B

SCALE_TX_SAMPLE:

    mov        mdmTxGainFactor, w5     ;Scale the transmit sample for the 
    mov        ucTxScaleFactor, w6     ;required transmit level

    mpy        w4*w5, A
    sftac      A, #(16-4+1)
    mov        ACCAL, w4

    mpy        w4*w6, A
    sftac      A, #(16-4+1)
    mov        ACCAL, w4

    mov        ucTransmitLevel, w5

    mpy        w4*w5, A
    sftac      A, #-4
    sac.r      A, w2

    mov        ChnPcmOutPtr, w4
    inc.b      mdmPcmTxIndex
    
    mov        w2,[w4++]               ;Update the scaled sample to the 
    mov        w4,ChnPcmOutPtr         ;PCM ouput buffer

    mov.b      mdmPcmBufLen, wreg
    cp.b       mdmPcmTxIndex 
    bra        nz, EXIT_SENDSAMPLE

    clr.b      mdmTxSmpCntr

EXIT_SENDSAMPLE:

    return


; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SetIdleReceiver
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function sets the function pointer, modemReceiver to
;                 IdleReceiver.
; -----------------------------------------------------------------------------

_SetIdleReceiver:

    mov       #~RXENABLE, w0
    and.b     modemStatus

    mov       #handle(_IdleReceiver), w2 
    mov       w2, modemReceiver

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SetIdleTransmitter
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function sets the function pointer, modemTransmitter to
;                 IdleTransmitter.
; -----------------------------------------------------------------------------

_SetIdleTransmitter:


    mov       #~TXENABLE, w0
    and.b     modemStatus

    mov       #handle(_IdleTransmitter), w2 
    mov       w2, modemTransmiter

    return    

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global IdleTransmitter
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function return 0 for no signal transmission
; -----------------------------------------------------------------------------
    
_IdleTransmitter:

    clr        w0
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global IdleReceiver
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   No processing is done in this function    
; -----------------------------------------------------------------------------

_IdleReceiver:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _NullFunction
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:    No processing is done in this function
; -----------------------------------------------------------------------------

_NullFunction:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SetTransmiter
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function sets the function pointer, modemTransmitter to
;                 the function passed as an argument.
; -----------------------------------------------------------------------------

_SetTransmiter:

    mov        w0, modemTransmiter

    mov        #TXENABLE, w0
    ior.b      modemStatus

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SetReceiver
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function sets the function pointer, modemReceiver to
;                 the function passed as an argument.
; -----------------------------------------------------------------------------

_SetReceiver:
 
    mov        w0, modemReceiver

    mov        #RXENABLE, w0
    ior.b      modemStatus

    return   
   
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SendDebugInfo
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:  This function sends the Message Parameters to the Host.
; -----------------------------------------------------------------------------
    
_SendDebugInfo:    
    mov        #mesgMsgParams, w8
    nop
    mov.b      w0, [w8]
    mov        #1, w0
    mov.b      wreg, mesgMsgLen
    mov        #mDEBUGINFO, w0
    mov.b      wreg, mesgMsgId
    mov        #mesgMsgParams, w8
       
    call       _SendMessageToHost
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ClearDPCDB
    .section  .libsm, "x"

_ClearDPCDB:
    push w0
    push w1
    push w2

    call ClearNBSS
    call ClearBSS
    call ClearXBSS
    call ClearYBSS
  
    pop w2
    pop w1
    pop w0

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

ClearNBSS:
    mov          #nbssFirstVar,w0
    mov          #nbssLastVar,w1
    sub          w1,w0,w1
    clr          w2                      ; initialize w2 to zero
    dec          w1, w1                  ; adjust w1 for repeat loop requirement

    repeat       w1                      ; repeat target instruction w1 times
    mov.b        w2, [w0++]              ; clear structure memory element
    return
     

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

ClearBSS:
    mov          #bssFirstVar,w0
    mov          #bssLastVar,w1
    sub          w1,w0,w1
    clr          w2                      ; initialize w2 to zero
    dec          w1, w1                  ; adjust w1 for repeat loop requirement

    repeat       w1                      ; repeat target instruction w1 times
    mov.b        w2, [w0++]              ; clear structure memory element
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

ClearXBSS:
.if DEF_V32 == 1
    mov          #NECDlyLineI, w0
.else
    mov          #SIPLCoefBuf, w0
.endif

    mov          #xbssLastVar,w1
    sub          w1,w0,w1
    clr          w2                      ; initialize w2 to zero
    dec          w1, w1                  ; adjust w1 for repeat loop requirement

    repeat       w1                      ; repeat target instruction w1 times
    mov.b        w2, [w0++]              ; clear structure memory element
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

ClearYBSS:

.if (DEF_V32 == 1 || DEF_V22 == 1)
    mov          #eqzDlyI, w0
.else
    mov          #mdmFilterBuffer, w0
.endif

    mov          #ybssLastVar,w1
    sub          w1,w0,w1
    clr          w2                      ; initialize w2 to zero
    dec          w1, w1                  ; adjust w1 for repeat loop requirement

    repeat       w1                      ; repeat target instruction w1 times
    mov.b        w2, [w0++]              ; clear structure memory element
    return
    
; -----------------------------------------------------------------------------
;   END OF FILE
; -----------------------------------------------------------------------------

