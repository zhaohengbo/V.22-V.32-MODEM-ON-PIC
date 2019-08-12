;******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               CALLPROG.S                                         *
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
; 0.2   02 October 2002        Code Modified                        Ravi      *
; 0.3   04 October 2002        Code Reviewed                        Raghava   *
;                                                                             *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Call progress processing implementation for Microchip's dsPIC30F           *
;  16-bit MCU                                                                 *
;                                                                             *
;  Description: The calling modem needs to automatically monitor the progress *
;               of the call. The call progress is indicated by the control    *
;               exchange through tones of pre-designated frequencies. Once    *
;               the remote modem goes off-hook, the central exchange stops    *
;               call progress tones and establishes a physical link and       *
;               supports the link till, one of the modems hang up.The         *
;               callprogress tone detection involves the detection of         *
;               BUSY tone,DIAL TONE. The answer modem initially sends the     *
;               answer tone.Pre designated frequencies are used for answer    *
;               tone and it might also indicate the type of the modem. For    *
;               example V22 uses 2100Hz tone and v32 uses 2100Hz tone with    *
;               phase reversals.                                              *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;                                                                             *
;******************************************************************************
;  InitDialToneDetector                                                       *
;  ======================                                                     *
;  Description: This function initializes the parameters for dial tone        *
;               detection at 8000Hz                                           *
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
;  Functions Called:   ClearStruct, SetReceiver                               *
;                                                                             *
;******************************************************************************
;  InitBusyToneDetector                                                       *
;  ======================                                                     *
;  Description: This function initializes the parameters for busy tone        *
;               detection at 8000Hz                                           *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3                used not restored                             *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  InitRingBackToneDetector                                                   *
;  ======================                                                     *
;  Description: This function initializes the parameters for ring back tone   *
;               detection at 8000Hz                                           *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4             used not restored                             *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  DetectDialTone                                                             *
;  ======================                                                     *
;  Description: This function is used to detect the presence of dial tone in  *
;               the received signal                                           *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2                   used not restored                             *
;                                                                             *
;  Functions Called:   ToneDetector,SetIdleReceiver,SendMessageToHost         *
;                                                                             *
;******************************************************************************
;  InitCallProgress                                                           *
;  ======================                                                     *
;  Description: This function is used to initialize some parameters for       *
;               starting the transmission/procesing of call progress signals  *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;        w0, w1                                                               *
;                                                                             *
;  Functions Called:InitBusyToneDetector,InitRingBackToneDetector,ClearStruct *
;                                                                             *
;******************************************************************************
;  CallProgressMonitor                                                        *
;  ======================                                                     *
;  Description: The call progress monitor checks for the presence of busy tone*
;               in the input signal.                                          *
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
;  Functions Called:   DetectBusyTone, DetectRBTone                           *
;                                                                             *
;******************************************************************************
;  DetectBusyTone                                                             *
;  ======================                                                     *
;  Description: The call progress tones in band 200-600 Hz are continuously   *
;               checked for busy tone transitions.                            *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,w5          used not restored                             *
;    ACC A                      used not restored                             *
;                                                                             *
;  Functions Called: CheckDutyCycle,ToneDetector                              *
;                                                                             *
;******************************************************************************
;  DetectRBTone                                                               *
;  ======================                                                     *
;  Description: The call progress tones in band 200-600 Hz are continuously   *
;               checked for ring back tone transitions.                       *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,w5          used not restored                             *
;    ACC A                      used not restored                             *
;                                                                             *
;  Functions Called: CheckDutyCycle,ToneDetector                              *
;                                                                             *
;******************************************************************************
;  CheckDutyCycle                                                             *
;  ======================                                                     *
;   Description:  This function checks the busy tone on/off durations to      *
;                 validate the presence of busy tone                          *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w11     used not restored                  *
;                                                                             *
;  Functions Called:   BusyTransition, ReorderTransition, RingTransition      *
;                                                                             *
;******************************************************************************
;  BusyTransition                                                             *
;  ======================                                                     *
;  Description: This function indicates a valid busy transition has been      *
;               detected.                                                     *
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
;  Functions Called:  SendMessageToHost                                       *
;                                                                             *
;******************************************************************************
;  ReorderTransition                                                          *
;  ======================                                                     *
;  Description: This function indicates a valid reorder transition has been   *
;               detected.                                                     *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2                   used not restored                             *
;                                                                             *
;  Functions Called:  SendMessageToHost                                       *
;                                                                             *
;******************************************************************************
;  RingTransition                                                             *
;  ======================                                                     *
;  Description: This function indicates a valid ring transition has been      *
;               detected.                                                     *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2                   used not restored                             *
;                                                                             *
;  Functions Called:  SendMessageToHost                                       *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   0                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitDialToneDetector:       16                                          *
;     InitBusyToneDetector:       23                                          *
;     InitRingBackToneDetector:   13                                          *
;     DetectDialTone:             30                                          *
;     InitCallProgress:           16                                          *
;     CallProgressMonitor:        36                                          *
;     DetectBusyTone:             58                                          *
;     DetectRBTone:               58                                          *
;     CheckDutyCycle:             82                                          *
;     BusyTransition:             17                                          *
;     ReorderTransition:          17                                          *
;     RingTransition:             17                                          *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;    cpDTBandCoefs:  6                                                        *
;    cpBTBandCoefs:  6                                                        *
;    cpRBTBandCoefs: 6                                                        *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;                                                                             *
;    .nbss:     57                                                            *
;    .ybss:     12                                                            *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitDialToneDetector:         18                                        *
;     InitBusyToneDetector:         25                                        *
;     InitRingBackToneDetector:     15                                        *
;     DetectDialTone:               32                                        *
;     InitCallProgress:             18                                        *
;     CallProgressMonitor:          34                                        *
;     DetectBusyTone:               53                                        *
;     DetectRBTone:                 53                                        *
;     CheckDutyCycle:               50                                        *
;     BusyTransition:               19                                        *
;     ReorderTransition:            19                                        *
;     RingTransition:               19                                        *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "callprog.inc"
    .include "modem.inc"
    .include "tables.inc"
    .include "apiasm.inc"
    .include "defs.inc"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if DEF_CALLPROG == 1

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
             
    .global _InitCallProgress
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to setup call progress parameters
; -----------------------------------------------------------------------------

_InitCallProgress:

    clr.b      cpCPStatus
    mov        #cpDTAPRunAvg, w0
    mov        #SIZEOFCP_NBSS, w1
    call       _ClearStruct            ;Clear the call progress structure
    
    mov        #mdmFilterBuffer, w1
    mov        #cpDTDelayLine, w0
    add        w0, w1, w0
    mov        #SIZEOFCP_YBSS, w1
    call       _ClearStruct
    
    call       _InitBusyToneDetector   ;Detect the dial tone
    call       _InitRingBackToneDetector
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _InitDialToneDetector
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function setup the parameters for dial tone detection 
; -----------------------------------------------------------------------------

_InitDialToneDetector:

    mov        #cpDTAPRunAvg, w0
    mov        #SIZEOFCP_NBSS, w1
    call       _ClearStruct            ;Clear the dial tone detection structure
    
    mov        #mdmFilterBuffer, w1
    mov        #cpDTDelayLine, w0
    add        w0, w1, w0
    mov        #SIZEOFCP_YBSS, w1
    call       _ClearStruct
    
    mov        #handle(_DetectDialTone), w0
    call       _SetReceiver            ;Setup the receive function pointer

    ;Initially the lowest threshold is set for detection of signals.
     
    mov        #LVL_43dBm, w1
    mov        w1, cpDTThreshold
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _InitBusyToneDetector
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function setup the parameters for Busy tone detection 
; -----------------------------------------------------------------------------

_InitBusyToneDetector:        
    
;Configure the ON/OFF times for the busy tone and reorder 
;tones detection    

    mov        ucBusyOnTime, w0
    mov        ucBusyOffTime, w1
    sub        w0, w1, w2
    btsc       w2, #15
    neg        w2, w2
    
    mov        #BUSY_TOLERENCE, w3
    add        w2, w3, w3
    
    mov        w3, cpBusyCadence
    
    mov        w0, cpBusyOnTime
    mov        w1, cpBusyOffTime
    
    mov        ucReorderOnTime, w0
    mov        ucReorderOffTime, w1
    sub        w0, w1, w2
    btsc       w2, #15
    neg        w2, w2
    
    mov        #REORDER_TOLERENCE, w3
    add        w2, w3, w3
    
    mov        w3, cpReorderCadence
    
    mov        w0, cpReorderOnTime
    mov        w1, cpReorderOffTime
    
;Initially signal threshold is set to a low value

    mov        #LVL_43dBm, w0
    mov        w0, cpBTThreshold
    
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _InitRingBackToneDetector
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function setup the parameters for Ring Back tone detection 
; -----------------------------------------------------------------------------

_InitRingBackToneDetector:        
    
;Configure the ON/OFF times for the ring back tone detection

    mov        ucRingOffTime, w0
    mov        ucRingOnTime, w1
    
    sub        w0, w1, w2
    btsc       w2, #15
    neg        w2, w2
    
    mov        #RING_TOLERENCE, w3
    add        w2, w3, w3
    
    mov        w3, cpRingCadence
    
    mov        w1, cpRingOnTime
    mov        w0, cpRingOffTime
    
    mov        #LVL_43dBm, w4
    mov        w4, cpRBTThreshold
    
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global  _DetectDialTone
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is used to detect the presence of dial tone in
;               the received signal. After the detection of dial tone a
;               message is sent to host to indicate the detection of dial tone 
; -----------------------------------------------------------------------------

_DetectDialTone:

    ;<ToneDetector> function is executed first to detect the 
    ;presence of power in the call progress band. The frequency 
    ;band from 200 - 600 Hz is generally used for call progress 
    ;tones. The filter coefficients stored in <ClprgBandCoefs> has
    ;a bandwidth [200-600] hz and is a first order butter worth ;
    ;band pass filter.

    mov        #cpDTAPRunAvg, w0
    mov        #mdmFilterBuffer, w2
    mov        #cpDTDelayLine, w1
    add        w2, w1, w1
    
    mov        #psvpage(cpDTBandCoefs), w2
    mov        w2, PSVPAG
    mov        #psvoffset(cpDTBandCoefs), w2

    ;Detect the presence of power in the call progress band.     

    call       _ToneDetector

    ;Check for the presence of dial tone    

    cp0        cpDTToneStatus
    bra        z, NO_DIAL_TONE

    ;Dial tone present
    ;When the < tone_status > is 1 tone is detected so increment the tone 
    ;timer counter
    
    mov        #7200, w0
    inc        cpDTOnTimer

    cp         cpDTOnTimer           ;detect continuous tone for one second
    bra        lt, EXIT_DT_DETECTION

    ;If the tone has detected continuously for 1 sec.
    ;indicate the host that the dial tone has been detected
 
    call       _SetIdleReceiver
    
    mov        #mGOTDIALTONE, w0
    mov        #mesgMsgParams, w8
    mov.b      w0, [w8]               ;Message to be sent
    mov        #1, w0
    mov.b      wreg, mesgMsgLen       ;Length of the Message
    
    mov        #mCLPRGRESP, w0
    mov.b      wreg, mesgMsgId        ;Message ID
    
    call       _SendMessageToHost 

    mov        #DIALTONE_DETECTED, w1
    mov        #cpCPStatus, w2
    ior.b      w1, [w2], [w2]
 
    bra        EXIT_DT_DETECTION
        
NO_DIAL_TONE:

    ;When the <ToneStatus> is 0 tone is not detected
    ;So reset the tone timer counter, No dial tone is present

    clr        cpDTOnTimer

EXIT_DT_DETECTION:    
    
    return   
    
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

    .global _CallProgressMonitor
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:  This function monitors the presence of call progress tones 
;                like busy tone.
; -----------------------------------------------------------------------------

_CallProgressMonitor: 

;The call progress monitor checks for the presence of busy tone,
;reorder tone and ring back tone in the input signal

    ;Check whether busy tone detection is enabled or not
 
    mov        #BUSYTONE_DETECTED, w0
    and.b      cpCPStatus, wreg
    bra        nz, EXIT_CALL_PROG_MON
    
    mov        #REORDERTONE_DETECTED, w0
    and.b      cpCPStatus, wreg
    bra        nz, EXIT_CALL_PROG_MON
    
    mov        #RINGBACKTONE_DETECTED, w0
    and.b      cpCPStatus, wreg
    bra        nz, EXIT_CALL_PROG_MON
    
;if the detection of busy tone/reorder tone is enabled and still 
;the tone is not detected, execute the busy tone detction process

    mov        #CLPRGDETECTBUSYTONE, w1
    cp0.b      ucClprgConfig
    bra        z, OTHERCOND
    cp0        w1
    bra        nz, BUSY_TONE_DET
    
OTHERCOND:
;if the detection of ring back tone is enabled and still 
;the tone is not detected, execute the ring back tone detction process

    mov        #CLPRGDETECTREORDERTONE, w1
    cp0.b      ucClprgConfig
    bra        z, RING_BACK_TONE_DET
    cp0        w1
    bra        z, RING_BACK_TONE_DET
    
;Check for the presence of busy tone

BUSY_TONE_DET:
    call       _DetectBusyTone        

RING_BACK_TONE_DET:
    mov        #CLPRGDETECTRINGBACKTONE, w1
    cp0.b      ucClprgConfig
    bra        z, UPD_TONESTATUS
    cp0        w1
    bra        z, UPD_TONESTATUS
    
    mov        #RINGBACKTONE_DETECTED, w0
    and.b      cpCPStatus, wreg
    bra        nz, UPD_TONESTATUS
    
    call       _DetectRBTone
    
UPD_TONESTATUS:

;Save the current status for next iteration 
;to detect transition 

    mov        cpCurBTStatus, w0
    mov        w0, cpPrevBTStatus
    
    mov        cpCurRBTStatus, w0
    mov        w0, cpPrevRBTStatus
    
EXIT_CALL_PROG_MON:

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _DetectBusyTone    
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:  This function is used to detect the presence of busy tone.
;                The call progress tones in the band 200-600 Hz are 
;                continuously checked for busy tone transitions. Usually busy 
;                tones have nearly 50% duty cycle. This property is made use of
;                to detect the presence of busy tone
; -----------------------------------------------------------------------------

_DetectBusyTone:

;tone detector function is executed to check the presence of power
;in the busy tone/reorder tone band. the frequency band [300 600] is 
;used for the busy/reorder tone detection

    ;Check the presence of signal in the call progress band

    mov        #cpBTAPRunAvg, w0
    mov        #mdmFilterBuffer, w2
    mov        #cpBTDelayLine, w1
    add        w2, w1, w1
    
    mov        #psvpage(cpBTBandCoefs), w2
    mov        w2, PSVPAG
    mov        #psvoffset(cpBTBandCoefs), w2

    call       _ToneDetector
    
    ;lpf_input
    
    mov        #-4000, w4

    cp0        cpBTToneStatus
    bra        z, LPF_OUTPUT

    neg        w4, w4
    
LPF_OUTPUT:
    ;lpf_output
    
    mov        #400, w5
    mpy        w4*w5, A
    sac.r      A, w2
    
    mov        #0x7c00, w4
    mov        cpBTStatusFilter, w5
    mpy        w4*w5, A
    sac.r      A, w3
    
    add        w2, w3, w2
    mov        w2, cpBTStatusFilter
    
    mov        #1, w1
    mov        w1, cpCurBTStatus
    
    cp0        cpBTStatusFilter
    bra        ge, CHK_TONE

    clr        cpCurBTStatus
    
CHK_TONE:

   ;Check if tone is present or not

    cp0        cpCurBTStatus
    bra        z, TONE_LOW

    ;Tone power in the CP band is present.
    ;Now increment the <ToneOnTimer>    
       
    inc        cpBTOnTimer

    ;Tone detection threshols will be set dynamically 
    ;at 50ms interval

    mov        #400, w0
    cp         cpBTOnTimer
    bra        nz, UPD_PREVTONE
    
    mov        mdmAverageInputLevel, w4
    mov        #0x1000, w5
    mpy        w4*w5, A
    sac.r      A, w2
    mov        w2, cpBTThreshold
    
UPD_PREVTONE:

    mov        cpCurBTStatus, w0
    mov        cpPrevBTStatus, w1
    xor        w1, w0, w1
    bra        z, EXIT_DETECTBUSYTONE

    ;If this is the first time after a low tone period, then there has
    ;been a transition from low to high tone power. So the duty cycle
    ;should be checked.    
    mov        cpBTOnTimer, w0
    mov        cpBTOffTimer, w1
    call       _CheckDutyCycle
    
    ;Reset the on/off timers
    clr        cpBTOffTimer
    clr        cpBTOnTimer
    bra        EXIT_DETECTBUSYTONE

TONE_LOW:
;Tone power in the band is absent therefore increment the off timer
     inc       cpBTOffTimer

    ;Now dynamically set the threshold for detection of rise in the CP
    ;band signal level. This is done exactly at the 50 ms interval after
    ;detection of loss of the signal in CP band.

     mov       #400, w0
     cp        cpBTOffTimer
     bra       nz, EXIT_DETECTBUSYTONE
     
     mov       #mdmAverageInputLevel, w1
     mov       [w1], w0
     sl        w0, #1, w0
     mov       w0, cpBTThreshold
     
EXIT_DETECTBUSYTONE:

     return
     
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _DetectRBTone
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:  This function is used to detect the presence of Ring Back tone.
; -----------------------------------------------------------------------------

_DetectRBTone:     

;tone detector function is executed to check the presence of power
;in the ring back tone band. the frequency band [400 500] is 
;used for the ring back tone detection   

    mov        #cpRBTAPRunAvg, w0
    mov        #mdmFilterBuffer, w2
    mov        #cpRBTDelayLine, w1
    add        w1, w2, w1

    mov        #psvpage(cpRBTBandCoefs), w2
    mov        w2, PSVPAG
    mov        #psvoffset(cpRBTBandCoefs), w2

    call       _ToneDetector
    
    ;lpf_input
    
    mov        #-4000, w4

    cp0        cpRBTToneStatus
    bra        z, LPFOUTPUT

    neg        w4, w4
    
LPFOUTPUT:
    ;lpf_output    
    
    mov        #400, w5
    mpy        w4*w5, A
    sac.r      A, w2
    
    mov        #0x7c00, w4
    mov        cpRBTStatusFilter, w5
    mpy        w4*w5, A
    sac.r      A, w3
    
    add        w2, w3, w2
    mov        w2, cpRBTStatusFilter
    
    mov        #1, w1
    mov        w1, cpCurRBTStatus
    
    cp0        cpRBTStatusFilter
    bra        ge, CHECK_TONE

    clr        cpCurRBTStatus
    
CHECK_TONE:
;Check if the tone is present ot not

    cp0        cpCurRBTStatus
    bra        z, TONELOW

;Tone power in the ring back tone band is present. 
;Now increment the Tone on timer

    inc        cpRBTOnTimer

    mov        #400, w0
    cp         cpRBTOnTimer
    bra        nz, UPDATE_PREVTONE
    
    mov        mdmAverageInputLevel, w4
    mov        #0x1000, w5
    mpy        w4*w5, A
    sac.r      A, w2
    mov        w2, cpRBTThreshold
    
UPDATE_PREVTONE:

    mov        cpCurRBTStatus, w0
    mov        cpPrevRBTStatus, w1
    xor        w1, w0, w1
    bra        z, EXIT_DETECTRBTONE

    mov        cpRBTOnTimer, w0
    mov        cpRBTOffTimer, w1
    
;If this is the first time after a low tone period, then there has
;been a transition from low to high tone power. So the duty cycle
;(tone cadence) should be checked.
    
    call       _CheckDutyCycle
    
;Reset the on/off timers    
    
    clr        cpRBTOnTimer
    clr        cpRBTOffTimer
    bra        EXIT_DETECTRBTONE

TONELOW:

;Tone power in the band is absent therefore increment the off timer

     inc       cpRBTOffTimer

     mov       #400, w0
     cp        cpRBTOffTimer
     bra       nz, EXIT_DETECTRBTONE
     
     mov       #mdmAverageInputLevel, w1
     mov       [w1], w0
     sl        w0, #1, w0
     mov       w0, cpRBTThreshold
     
EXIT_DETECTRBTONE:

     return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _CheckDutyCycle
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: Here the validity of the tone periods are checked.
;                The difference in the durations of the on/off periods should 
;               be less than 100 ms. This removes the possibility of detecting
;               spurious tones as busy transitions.
; -----------------------------------------------------------------------------

_CheckDutyCycle:
  
    ;Calculate the difference between ToneOffTime and ToneOnTime
    ;Now check the validity of the tone periods
    
    sub        w0, w1, w8
    btsc       w8, #15
    neg        w8, w8                  ;Difference b/n On & Off Timers
    
    mov        #BUSY_TOLERENCE, w9
    mov        cpBusyOnTime, w2
    sub        w2, w9, w3
    btsc       w3, #15
    neg        w3, w3                  ;Minimum On Time
    
    add        w2, w9, w4              ;Maximum On Time
    
    mov        cpBusyOffTime, w5
    sub        w5, w9, w6
    btsc       w6, #15
    neg        w6, w6                  ;Minimum Off Time
    
    add        w5, w9, w7              ;Maximum Off Time
    
;The difference in the durations of the on/off periods should be less
;than the respective tone cadence. This removes the possibility of 
;detecting spurious tones
    
    mov        cpBusyCadence, w2
    
;Now test if the tone off/on duration is greater than 100 ms (1000 samples)
;if the difference is greater than 100ms, It will not be considered as the
;busy transition
 
    cp         w8, w2
    bra        ge, NO_BUSYTONE
    
;On/off timers shoud be within the respective tone
;on/off bounds to validite the tone transition

;After tone differential duration is validated, the absolute signal on
;period is checked. A tone period is considered only if the duration is 
;greater than, 150 ms @8000 Hz, 150 ms = 1200 samples.   
 
    cp         w0, w3
    bra        le, NO_BUSYTONE
    
    cp         w0, w4
    bra        ge, NO_BUSYTONE
    
    cp         w1, w6
    bra        le, NO_BUSYTONE
    
    cp         w1, w7
    bra        ge, NO_BUSYTONE
    
;Busy tone transition is present
    
    call       _BusyTransition
    bra        EXIT_CHECK_DUTY_CYCLE
    
NO_BUSYTONE:
    clr        cpBTTransitions
    
    mov        #REORDER_TOLERENCE, w5
    mov        cpReorderOnTime, w9
    
    sub        w9, w5, w3
    btsc       w3, #15
    neg        w3, w3                  ;Minimum On Time
    
    add        w9, w5, w4              ;Maximum On Time
    
    mov        cpReorderOffTime, w9
    sub        w9, w5, w6
    btsc       w6, #15                 ;Minimum Off Time
    neg        w6, w6
    
    add        w9, w5, w7              ;Maximum Off Time
    
    mov        cpReorderCadence, w2
    cp         w8, w2
    bra        ge, NO_BUSYTONE1

    cp         w0, w3
    bra        le, NO_BUSYTONE1
    
    cp         w0, w4
    bra        ge, NO_BUSYTONE1
    
    cp         w1, w6
    bra        le, NO_BUSYTONE1
    
    cp         w1, w7
    bra        ge, NO_BUSYTONE1
    
;Reorder tone transition is present
    
    call       _ReorderTransition
    bra        EXIT_CHECK_DUTY_CYCLE
    
NO_BUSYTONE1:
    clr        cpRTTransitions    
    
    mov        #RING_TOLERENCE, w5
    mov        cpRingOnTime, w9
    
    sub        w9, w5, w3
    btsc       w3, #15
    neg        w3, w3                  ;Minimum On Time
    
    add        w9, w5, w4              ;Maximum On Time
    
    mov        cpRingOffTime, w9
    sub        w9, w5, w6
    btsc       w6, #15                 ;Minimum Off Time
    neg        w6, w6
    
    add        w9, w5, w7              ;Maximum Off Time
    
    mov        cpRingCadence, w2
    cp         w8, w2
    bra        ge, NO_BUSYTONE2

    cp         w0, w3
    bra        le, NO_BUSYTONE2
    
    cp         w0, w4
    bra        ge, NO_BUSYTONE2
    
    cp         w1, w6
    bra        le, NO_BUSYTONE2
    
    sub        w1, w7, w11
    bra        geu, NO_BUSYTONE2
    
;Ring back tone transition is present
    
    call       _RingTransition
    bra        EXIT_CHECK_DUTY_CYCLE
 
 NO_BUSYTONE2:
    clr        cpRBTTransitions
    
 EXIT_CHECK_DUTY_CYCLE:
    return
 
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _BusyTransition
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function indicates a valid busy transition has been
;               detected.
; -----------------------------------------------------------------------------

_BusyTransition:

;Check for 2 busy transtions before validatinfg the
;busy tone presence

    ;Increment the busy transition counter

    inc        cpBTTransitions

    ;When 6 continuous transitions are detected, busy tone is
    ;signalled. i.e. for 3 tone on-off periods.
 
    mov        #2, w0
    cp         cpBTTransitions
    bra        lt, EXIT_BUSY_TRANS
    
    ;Send a response to the host to indicate the detection of busy tone 

    mov        #mGOTBUSYTONE, w0
    mov        #mesgMsgParams, w8
    mov        w0, [w8]               ;Message to be sent
    mov        #1, w0
    mov.b      wreg, mesgMsgLen       ;Length of the Message
    
    mov        #mCLPRGRESP, w0
    mov.b      wreg, mesgMsgId        ;Message ID
    
    call       _SendMessageToHost

    mov        #BUSYTONE_DETECTED, w0
    mov        #cpCPStatus, w1
    ior.b      w0, [w1], [w1]
    
EXIT_BUSY_TRANS:

    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
       
    .global _ReorderTransition
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function indicates a valid Reorder transition has been
;               detected.
; -----------------------------------------------------------------------------

_ReorderTransition:        
    
;Check for 2 reorder tone transtions before validatinfg the
;reorder tone presence
    
    inc        cpRTTransitions
    
    mov        #2, w0
    cp         cpRTTransitions
    bra        lt, EXIT_REORDER_TRANSITION
    
    mov        #mGOTREORDERTONE, w0
    mov        #mesgMsgParams, w8
    mov        w0, [w8]               ;Message to be sent
    mov        #1, w0
    mov.b      wreg, mesgMsgLen       ;Length of the Message
    
    mov        #mCLPRGRESP, w0
    mov.b      wreg, mesgMsgId        ;Message ID
    
    call       _SendMessageToHost
    
    mov        #REORDERTONE_DETECTED, w1
    mov        #cpCPStatus, w2
    ior.b      w1, [w2], [w2]
    
EXIT_REORDER_TRANSITION:
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _RingTransition
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function indicates a valid Ring transition has been
;               detected.
; -----------------------------------------------------------------------------

_RingTransition:        
    
;Check for specified number of transtions before validatinfg the
;ring back tone presence 
   
    inc        cpRBTTransitions
    mov        ucRingCount, w0
    
    cp         cpRBTTransitions
    bra        lt, EXIT_RING_TRANSITION
    
    mov        #mGOTRINGBACK, w0
    mov        #mesgMsgParams, w8
    mov        w0, [w8]               ;Message to be sent
    mov        #1, w0
    mov.b      wreg, mesgMsgLen       ;Length of the Message
    
    mov        #mCLPRGRESP, w0
    mov.b      wreg, mesgMsgId        ;Message ID
    
    call       _SendMessageToHost
    
    mov        #RINGBACKTONE_DETECTED, w1
    mov        #cpCPStatus, w2
    ior.b      w1, [w2], [w2]
    
EXIT_RING_TRANSITION:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.endif

; -----------------------------------------------------------------------------
;     END of FILE
; -----------------------------------------------------------------------------
