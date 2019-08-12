;******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               DMCTRL.S                                           *
;  Date:                   28th August,2002                                   *
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
; 0.1   28 August 2002         Code Created                         Rajiv     *
; 0.2   29 August 2002         Code Reviewed                        Raghava   *
;                                                                             *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Starting the Call originate and Answer modem Handshake for Microchip's     *
;  dsPIC30F 16-bit MCU                                                        *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;                                                                             *
;******************************************************************************
;  StartDmOrgHandshake                                                        *
;  ======================                                                     *
;  Description:  Initializes Call progress Tones                              *
;  ======================                                                     *
;  Input:                                                                     *
;    void                                                                     *
;                                                                             *
;  Output:                                                                    *
;    void                                                                     *
;                                                                             *
;  System Resource usage:                                                     *
;    w0                  used not Restored                                    *
;                                                                             *
;  Functions Called: InitCallProgress,SetReceiver,InitAnsToneRx               *
;******************************************************************************
;  OrgModeReceiver                                                            *
;  ======================                                                     *
;  Description:  Execute call progress procedure for tone detection and also  *
;                 execute the V.25 answer tone detection.                     *
;  ======================                                                     *
;  Input:                                                                     *
;    void                                                                     *
;                                                                             *
;  Output:                                                                    *
;    void                                                                     *
;                                                                             *
;  System Resource usage:                                                     *
;    w0                  used not Restored                                    *
;                                                                             *
;  Functions Called: CallProgressMonitor,SetReceiver,AnswerToneDetect,        *
;                    SetIdleTransmitter                                       *
;******************************************************************************
;  OrgModeReceiverPhase2                                                      *
;  ======================                                                     *
;  Description:  Starts V.8 originate mode handshake                          *
;  ======================                                                     *
;  Input:                                                                     *
;    void                                                                     *
;                                                                             *
;  Output:                                                                    *
;    void                                                                     *
;                                                                             *
;  System Resource usage:                                                     *
;    w0                  used not Restored                                    *
;                                                                             *
;  Functions Called: AnswerToneDetect,SetIdleReceiver,SetIdleTransmitter,     *
;                    V8Originate, StartV32, StartV22, StartV23, StartV21      *
;******************************************************************************
;  StartDmAnsHandshake                                                        *
;  ======================                                                     *
;  Description:  Starts V.8 answer mode hand shake                            *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0                  used not Restored                                    *
;                                                                             *
;  Functions Called:   InitAnsToneTx,V8Answer,SetTransmiter,SetReceiver       *
;                                                                             *
;******************************************************************************
;  AnsTransmiterPhase1                                                        *
;  ======================                                                     *
;  Description:  This function transmits answer tone, while waiting for the   *
;                some suitable response from the remote modem.                *
;  ======================                                                     *
;  Input:                                                                     *
;    void                                                                     *
;                                                                             *
;  Output:                                                                    *
;    void                                                                     *
;                                                                             *
;  System Resource usage:                                                     *
;    w0                  used not Restored                                    *
;                                                                             *
;  Functions Called: AnsToneTransmitter,StartV32,StartV22,SetIdleTransmitter, *
;                    SetIdleReceiver                                          *
;******************************************************************************
;  RemoteModemDetector                                                        *
;  ======================                                                     *
;  Description:  This function is used to detect the remote modem type.       *
;  ======================                                                     *
;  Input:                                                                     *
;    void                                                                     *
;                                                                             *
;  Output:                                                                    *
;    void                                                                     *
;                                                                             *
;  System Resource usage:                                                     *
;    w0                  used not Restored                                    *
;                                                                             *
;  Functions Called: V21Receiver                                              *
;******************************************************************************
;  CheckCarrierCondition                                                      *
;  ======================                                                     *
;  Description: This function checks whether remote carrier is present or not.*
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1                      used not restored                             *
;                                                                             *
;  Functions Called:   SetIdleTransmitter,SetIdleReceiver                     *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   None                                       *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     StartDmOrgHandshake:      08                                            *
;     OrgModeReceiver:          13                                            *
;     OrgModeReceiverPhase2:    48                                            *
;     StartDmAnsHandshake:      30                                            *
;     AnsTransmiterPhase1:      20                                            *
;     RemoteModemDetector:      06                                            *
;     CheckCarrierCondition:    30                                            *
;     InitiateRetrainProcedures:13                                            *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;     .ybss       4                                                           *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     StartDmOrgHandshake:       10                                           *
;     OrgModeReceiver:           15                                           *
;     OrgModeReceiverPhase2:     19                                           *
;     StartDmAnsHandshake:       22                                           *
;     AnsTransmiterPhase1:       11                                           *
;     RemoteModemDetector:       08                                           *
;     CheckCarrierCondition:     18                                           *
;     InitiateRetrainProcedures: 12                                           *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

   .include "modem.inc"
   .include "apiasm.inc"
   .include "dmctrl.inc"
   .include "v25.inc"
   .include "defs.inc"
 
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _StartDMOrgHandshake
    .section  .libsm, "x"
; -----------------------------------------------------------------------------
;  Description: Start ORIGINATE mode handshake by Setting up parameters for 
;               originate handshake.In the originate mode, the DP will scan 
;               for answer tone and look for call progres tones. 
; -----------------------------------------------------------------------------

_StartDMOrgHandshake:

.if DEF_CALLPROG == 1
    call       _InitCallProgress       ;Initialize call progress Params
.endif

   ;Setup receive function pointer to progress in
   ;originate mode handshake

    mov        #handle(_OrgModeReceiver), w0
    call       _SetReceiver            
    
.if DEF_V25 == 1
    call       _InitAnsToneRx          ;Setup Answer Tone detection
.endif

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _OrgModeReceiver
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   Execute call progress procedure for tone detection and also
;                 execute the V.25 answer tone detection.
; -----------------------------------------------------------------------------

_OrgModeReceiver:

  
    ;This function monitors the call progress tones
    
.if DEF_CALLPROG == 1
    call       _CallProgressMonitor
.endif
 
    ;Execute the answer tone detection process

.if DEF_V25 == 1
    call       _AnswerToneDetect       ;Detection of answer tone
    
    ;No further processing till answer tone is detected

    mov        #ANS_DETECTED, w0
    and        V25AnsStatus, wreg
    bra        z, EXIT_ORGRX
.endif

   ;After answer tone is detected, there is no need to check for call progress
   ;tone. Then switch to the next phase of originate mode hand shake

    mov        #handle(_OrgModeReceiverPhase2), w0
    call       _SetReceiver
   
    ;No transmission is involved at this stage 

    call       _SetIdleTransmitter
    
EXIT_ORGRX:

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _OrgModeReceiverPhase2
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:  Once the answer tone is detected, this function is executed 
;                to look for ANSam signal. If the ANSam signal is detected,
;                then originate mode handshake will switch to V8 originate mode
;                handshake, If ANSam signal is not detected the ooiginate mode
;                handshake will start the highest possible modulation mode 
;                handshake (V.32->V.22bis->V23->V.21) 
; -----------------------------------------------------------------------------

_OrgModeReceiverPhase2:        

    
.if DEF_V25 == 1
    call       _AnswerToneDetect       ;Detect ANSam signal
.endif

;If 500 ms has elapsed after detection of the answer tone here, then
;the modulation(ANSam) is not detected, <AnsTimer > is set to a value
;corresponding to 500 ms in <AnswerToneDetect> after the detection
;of the answer tone

.if DEF_V25 == 1
    cp0        V25AnsTimer
    bra        lt, NO_ANSAM_V8       
    
    mov        #ANSAM_DETECTED, W0
    and        V25AnsStatus, wreg
    bra        z, EXIT_ORGRXPHASE2
.endif

   ;Modulation detected. Now V.8 negotiation should begin,
   
   ;Reset the transmit and receive function pointers to
   ;idle states

    call       _SetIdleReceiver
    call       _SetIdleTransmitter

;Call the function to set up V.8 originate Negotiation
;If v.8 is not enabled, then go directly to non-v.8 negotiation process
;In this case, only fall back modes are tried.    
    
    mov        #ENABLE_V8, w0
    and.b      ucHS_Mode, wreg
    bra        z, NO_ANSAM_V8

.if DEF_V8 == 1
    call       _V8Originate            ;Start V8 originate handshake
.endif
    return

;Answer tone modulation(ANSam) not detected. Now a Non V.8 Connection
;should be attempted. NON V8 connection will be attempted starting 
;from V.32

NO_ANSAM_V8:

   ;Reset the transmit and receive function pointers to
   ;idle states

    ;Setup 7200Hz sampling rate

    mov       #(0x10 | RATE_7200),w0
    mov.b     wreg,mdmRCTxRatio
   
    call       _SetIdleReceiver
    call       _SetIdleTransmitter

.if DEF_V32 == 1

   ;Check if Local modem supports V.32 mode
   ;Check V.22 mode, if V.32 is not supported

    mov        #ENABLE_V32, w0
    and.b      ucHS_Mode, wreg         
    bra        z, CHK_V22              
    
    ;Start V.32 hand shake if it is supported
    
    call       _StartV32
    mov        #1, w0
    mov.b      wreg, V32FallBack         ;Enable V.22 fallback
    return
.endif

CHK_V22:

   ;Check if Local modem supports V.22 mode
   ;Check V.23 mode, if V.22 is not supported
       
.if DEF_V22 == 1
    mov        #ENABLE_V22, w0
    and.b      ucHS_Mode, wreg         
    bra        z, CHK_V23

    ;Start V.22 hand shake if it is supported

    call       _StartV22
    return
.endif

CHK_V23:

   ;Check if Local modem supports V.23 mode
   ;Check V.21 mode, if V.23 is not supported
   
.if DEF_V23 == 1
    mov        #ENABLE_V23, w0
    and.b      ucHS_Mode, wreg         
    bra        z, CHK_V21
    
    call       _StartV23
    return
.endif

CHK_V21:

.if DEF_V21 == 1
    mov        #ENABLE_V21, w0
    and.b      ucHS_Mode, wreg         
    bra        z, CHK_B103
    
    call       _StartV21
    return
.endif

CHK_B103:

.if DEF_B103 == 1
    mov        #ENABLE_B103, w0
    and.b      ucHS_Mode, wreg         
    bra        z, EXIT_ORGRXPHASE2
    
    call       _StartV21
    return
.endif

EXIT_ORGRXPHASE2:

    return    

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------


    .global _StartDMAnsHandshake
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: Start ANSWER mode handshake by Setting up parameters for 
;               answer handshake. In answer mode, the initial handshake is 
;               done at 7200 Hz. This facilitates easy detection and 
;               continuing V.21, V.22 and V.32 modulations, V.8 is also run at
;               7200 Hz (Both in Org and Ans Modes)
; -----------------------------------------------------------------------------

_StartDMAnsHandshake:

    ;Setup 7200Hz sampling rate

    mov       #(0x10 | RATE_7200),w0
    mov.b     wreg,mdmRCTxRatio

    ;Abort the current frame processing by resetting the
    ;transmit receive counters
    
    clr.b     mdmRxSmpCntr
    clr.b     mdmTxSmpCntr

.if DEF_V25 == 1

   ;Start AnsAm transmission if V.8 is enabled

    mov        #ENABLE_V8, w0
    and.b      ucHS_Mode, wreg
    bra        z, INIT_T2_ANS
    
    ;Setup parameters for Type-3 (ANSam) tone transmission    

    mov        #V25_TYPE3, w0
    call       _InitAnsToneTx
    bra        SET_ANS_TX
    
INIT_T2_ANS:

    ;Start answer tone with phase reversals if V.32 is enabled

    mov        #ENABLE_V32, w0
    and.b      ucHS_Mode, wreg
    bra        z, INIT_T1_ANS

    ;Setup parameters for Type-2 (ANS with PR) tone transmission    
    
    mov        #V25_TYPE2, w0
    call       _InitAnsToneTx          
    bra        SET_ANS_TX

INIT_T1_ANS:

    ;Start answer tone without phase reversals(Type-1) 
    ;for V.22 and below where there is no echo canceller.

    mov        #V25_TYPE1, w0
    call       _InitAnsToneTx
        
SET_ANS_TX:

   ;Now setup function pointer to transmit answer tone

    mov        #handle(_AnsTransmiterPhase1),w0
    call       _SetTransmiter

.endif

.if DEF_B103 == 1
    mov        #ENABLE_B103, w0
    and.b      ucHS_Mode, wreg         
    bra        nz, EXIT_ANS_HS_START
.endif

    ;At the same time start V8 answer handshake
    
.if DEF_V8 == 1
    call       _V8Answer
.endif

    ;To detect the remote modem mode, set up receiver
    ;function pointer

    mov        #handle(_RemoteModemDetector), w0
    call       _SetReceiver
    
EXIT_ANS_HS_START:

    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _AnsTransmiterPhase1            
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function transmits answer tone, while waiting for the
;               some suitable response from the remote modem. If no response
;               is received, at the end of the answer tone transmission V.32
;               handshake will be started.
; -----------------------------------------------------------------------------

_AnsTransmiterPhase1:

.if DEF_V25 == 1

    ;Transmit ANS/ANSam signal
    call       _AnsToneTransmiter

    ;Decrement the <AnsTimer > till it becomes 0.

    dec        V25AnsTimer
    bra        nz, EXIT_ANSTX_PHASE1
.endif    

; If no response is obtained at the end of transmission of the answer tone,
; Start with V.32 handshake

.if DEF_V32 == 1
    mov        #ENABLE_V32, w0
    and.b      ucHS_Mode, wreg
    bra        z, CHK_V22MODE
    
    call       _StartV32
    return
.endif

CHK_V22MODE:

    ;Start V.22 handshake if V.32 is not supported
    
.if DEF_V22 == 1
    mov        #ENABLE_V22, w0
    and.b      ucHS_Mode, wreg
    bra        z, CHK_HS_BELL103

    call       _StartV22
    return
.endif

CHK_HS_BELL103:

.if DEF_B103 == 1
    mov        #ENABLE_B103, w0
    and.b      ucHS_Mode, wreg         
    bra        z, SET_IDLE_STATE

    call       _StartV21
    return
.endif

SET_IDLE_STATE:

    call       _SetIdleReceiver
    call       _SetIdleTransmitter

EXIT_ANSTX_PHASE1:
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _RemoteModemDetector
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function is used to detect the remote modem type.
; -----------------------------------------------------------------------------

_RemoteModemDetector:

    ;If V8 is enabled, Start V21 receiver

.if DEF_V8 == 1
    mov        #ENABLE_V8, w0
    and.b      ucHS_Mode, wreg
    bra        z, ORGDET_V32_AUTO
    call       _V21Receiver
.endif

ORGDET_V32_AUTO:
;  (Remote Modem detection logic has to be added)

   return     

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _CheckCarrierCondition
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function checks whether remote carrier is present or not
; -----------------------------------------------------------------------------

_CheckCarrierCondition:

    cp0.b      AGCEnergyStat           ;Chk energy is detected from remote mdm
    bra        z, NO_CARRIER
    
    mov        #0xBB80, w0             ;6 secs @8000 Hz
    clr        w1

    ;setup a timer for 6 sec
    
    mov        w0, dmcCarrierTimer
    mov        w1, dmcCarrierTimer+2
    
    return

NO_CARRIER:

    ;CarrierAbsent
    ;Decremented every sample when EnergyStat is 0    

    mov        dmcCarrierTimer, W0
    mov        dmcCarrierTimer+2, W1

    sub        w0, #1, w0
    subb       w1, #0, w1

    mov        w0, dmcCarrierTimer
    mov        w1, dmcCarrierTimer+2
    bra        nz, EXIT_CARRIERCHK
    
    ;If signal is absent for 6 seconds, hangup the modem
    ;indicating the loss of remote carrier

    mov        #1, w0
    mov.b      wreg, mdmHangUp
        
    mov        #mNOCARRIER, w0
    mov.b      wreg, mesgMsgId

    mov        #1, w0
    mov.b      wreg, mesgMsgLen

    mov        #mesgMsgParams, w8
    mov.b      mdmHangUp, wreg
    mov.b      w0, [w8]
    call       _SendMessageToHost

    call       _SetIdleTransmitter
    call       _SetIdleReceiver        ;set to Idle state
    
EXIT_CARRIERCHK:
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global InitiateRetrainProcedures
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function initiates retrain mode in V32 or V22
; -----------------------------------------------------------------------------

InitiateRetrainProcedures:
    
.if DEF_V32 == 1
    mov        #MTV32, w0
    cp.b       modemType
    bra        z, V32RETRAIN
.endif
    
.if DEF_V22 == 1
    mov        #MTV22BIS, w0
    cp.b       modemType
    bra        z, V22RETRAIN
.endif
    return

V32RETRAIN:

.if DEF_V32 == 1
    call       _InitiateV32Retrain
.endif

    return

V22RETRAIN:

.if DEF_V22 == 1
    call       _InitiateV22Retrain
.endif

    return

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------
    
