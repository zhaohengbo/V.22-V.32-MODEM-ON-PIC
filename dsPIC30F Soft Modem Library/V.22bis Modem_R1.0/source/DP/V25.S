/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               V25.S                                              *
;  Date:                   16th August 2002                                   *
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
; 0.1   16 August 2002   Code Created                                Ravi     *
; 0.2   20 August 2002   Code Reviewed                               Raghava  *
; 0.3   09 August 2002   Modified file/function header               Rajiv    *
; 0.4   20 August 2002   Corrected code documentation faults         Rajiv    *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  V.25 Transmitter & Receiver modules implementation for Microchip's         *
;  dsPIC30F 16-bit MCU                                                        *
;                                                                             *
;  Description: This file implements the modules for the generation of        *
;               ANSWER/ANSam tones according to ITU-T V.25 specification      *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;                                                                             *
;  InitAnsToneTx:                                                             *
;  ======================                                                     *
;  Description: This function initializes parameters for transmission of      *
;               different types of answer tones.                              *
;                                                                             *
;  Input:  w0 = Type of answer tone required                                  *
;                                                                             *
;  Output: void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w4, w5   used not restored                                        *
;   AccA             used not restored                                        *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  AnsToneTransmiter:                                                         *
;  ======================                                                     *
;  Description: This function is the common entry point for answer tone       *
;               generation.                                                   *
;                                                                             *
;  Input:  void                                                               *
;                                                                             *
;  Output: w0 = ANSWER/ANSam Tone Sample                                      *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1 used not restored                                                  *
;                                                                             *
;  Functions Called: V25TxFnPtr function pointer                              *
;                                                                             *
;******************************************************************************
;  GenerateAnswerTone:                                                        *
;  ======================                                                     *
;  Description: This function generates and returns the answer tone value.    *
;                                                                             *
;  Input:  void                                                               *
;                                                                             *
;  Output: w0 = ANS Tone Sample                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w4, w5 used not restored                                      *
;   AccA               used not restored                                      *
;                                                                             *
;  Functions Called:  SinCos                                                  *
;                                                                             *
;******************************************************************************
;  AnsTone1:                                                                  *
;  ======================                                                     *
;  Description: This function is used to generate the continuous answer tone  *
;               without phase reversals. (ANS_TYPE1)                          *
;                                                                             *
;  Input:  void                                                               *
;                                                                             *
;  Output: w0 = ANS Tx Sample                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0 used not restored                                                      *
;                                                                             *
;  Functions Called:  GenerateAnswerTone                                      *
;******************************************************************************
;  AnsTone2:                                                                  *
;  ======================                                                     *
;  Description: This function is used to generate the continuous answer tone  *
;               with phase reversals. (ANS_TYPE2)                             *
;                                                                             *
;  Input:  void                                                               *
;                                                                             *
;  Output: w0 = ANS Tx Sample                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2 used not restored                                              *
;                                                                             *
;  Functions Called:  GenerateAnswerTone                                      *
;******************************************************************************
;  AnsTone3:                                                                  *
;  ======================                                                     *
;  Description: This function is to generate the answer tone with phase       *
;               reversals and amplitude modulated with 15Hz tone              *
;               (ANSam Generation - ANS_TYPE3)                                *
;                                                                             *
;  Input:  void                                                               *
;                                                                             *
;  Output: w0 = ANSam Tx Sample                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w4, w5, w6 used not restored                                  *
;   AccA                   used not restored                                  *
;                                                                             *
;  Functions Called:  AnsTone2, SinCos                                        *
;******************************************************************************
;  InitAnsToneRx:                                                             *
;  ======================                                                     *
;  Description: This Function initializes the answer tone for receiver.       *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0 used not restored                                                      *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  AnswerToneDetect:                                                          *
;  ======================                                                     *
;  Description: This function is executed to detect the presence of           *
;               power in the answer tone band.                                *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w3, w4, w5, w6 used not restored                              *
;   AccA                       used not restored                              *
;   CORCON                     used not restored                              *
;                                                                             *
;  Functions Called:  ButterWorth, MeanLevel                                  *
;******************************************************************************
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words : 04                                           *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitAnsToneTx:             36                                           *
;     AnsToneTransmiter:         05                                           *
;     GenerateAnswerTone:        12                                           *
;     AnsTone1:                  04                                           *
;     AnsTone2:                  16                                           *
;     AnsTone3:                  19                                           *
;     InitAnsToneRx:             11                                           *
;     AnswerToneDetect:          101                                          *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     V25AnswerBandCoefs         6                                            *
;     V25AnsAmFilter             6                                            *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;     .bss:                      18                                           *
;     .ybss:                     12                                           *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitAnsToneTx:             25                                           *
;     AnsToneTransmiter:         09                                           *
;     GenerateAnswerTone:        16                                           *
;     AnsTone1:                  07                                           *
;     AnsTone2:                  17                                           *
;     AnsTone3:                  23                                           *
;     InitAnsToneRx:             16                                           *
;     AnswerToneDetect:          58                                           *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include   "v25.inc"
    .include   "modem.inc"
    .include   "Tables.inc"
    .include   "filter.inc"
    .include   "defs.inc"    

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if DEF_V25 == 1

    .global _InitAnsToneTx
    .section  .libsm, "x"
    
;------------------------------------------------------------------------------
;  Description:  This function initializes parameters for transmission of 
;                different types of answer tone. 
;                at_type - Type of answer tone required as defined in <V25.h>
;                * Tone without phase reversals (V25_TYPE1)
;                * Tone with phase reversals at 450ms interval (V25_TYPE2)  
;                * Tone with phase reversal and amplitude modulated with 15Hz
;                  tone (ANSam)
;------------------------------------------------------------------------------
_InitAnsToneTx:

    push       w0                      ;Save the at_type     
    mov        #V25DTToneStatus, w0
    mov        #SIZEOFV25TX_BSS, w1
    call       _ClearStruct            ;Clear the V25 transmit parameters
    pop        w0                      ;Restore at_type

    ;Setup default transmit scaling factor. This is independent of the
    ;transmit level setup by the user.
    
    mov        #0x1000, w1              
    mov        w1, mdmTxGainFactor
    
    mov        #V25_TYPE2, w1          ;Check at_type required 
    cp         w0, w1
    bra        nz, CHK_ANS_TYPE_3
    
    ;TYPE - 2 ANS tone initialization
    
    push       CORCON                  ;Save CORCON status

    bset       CORCON, #0              ;Enable integer multiplication
    mov        #V25_SRATE, w4
    mov        #6, w5
    mpy        w4*w5, A                ;V25_SRATE * 6 = (6 secs of ANS tone) 
    mov        ACCAL, w1
    mov        w1, V25AnsTimer         ;Set the ANS duration timer for 6 secs

    pop        CORCON                  ;Restore CORCON status
    
    mov        #handle(_AnsTone2), w1  ;Set the function pointer for
    mov        w1, V25TxFnPtr          ;ANS tone TYPE_2 transmission
    
    return
   
CHK_ANS_TYPE_3:

    mov        #V25_TYPE3, w1          ;Check at_type
    cp         w0, w1
    bra        nz, ANS_TYPE_1

    ;TYPE - 3 ANSam tone initialization
    
    ;Tone with phase reversals modulated by 15 Hz signal as defined in
    ;V.8. This answer tone is used for identifying the modem as a V.8 
    ;compatible modem. In V.8 AnsAM is sent continuously for 5 secs
    
    mov        #V25_SRATE, w1
    sl         w1, #2, w1              ;V25_SRATE * 8 = (8 secs of ANSam)
    mov        w1, V25AnsTimer         ;Set ANSam tone duration
    
    mov        #handle(_AnsTone3), w1  ;Set the function pointer for
    mov        w1, V25TxFnPtr          ;ANS tone TYPE_3 transmission
    
    return

    ;TYPE - 1 ANS tone initialization

    ;Continuous tone with no phase reversals, this is the default mode
    ;The continuous tone can be used with FDM modems like V.22 and V.23
    
ANS_TYPE_1:

    mov        #24000, w1             ;Set ANS tone transmission
    mov        w1, V25AnsTimer        ;for 3 seconds 
    
    mov        #handle(_AnsTone1), w1 ;Set the function pointer for
    mov        w1, V25TxFnPtr         ;ANS tone TYPE_1 transmission
    
    return

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
    
    .global _AnsToneTransmiter
    .section  .libsm, "x"
    
;------------------------------------------------------------------------------
;  Description: This function is the common entry point for answer tone 
;               generation. Different types of answer tone are generated base 
;               on the function pointer, < V25TxFnPtr>
;------------------------------------------------------------------------------

_AnsToneTransmiter:

    mov        V25TxFnPtr, w1
    call       w1                      ;Execute the answer tone function 
                                       ;pointer 
    mov        V25TxSmpl, w0           ;Return the generated sample
   
    return

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
    
    .global _GenerateAnswerTone
    .section  .libsm, "x"
    
;------------------------------------------------------------------------------
; Description: This function is common to all the answer tone types.
;              compute the sine of current ans tone phase
;              This function returns the answer tone value.
;------------------------------------------------------------------------------

_GenerateAnswerTone:

    mov        V25AnsPhase, w0         ;Estimate the sine of current
    clr        w1                      ;ans tone phase
    call       _SinCos
    
    mov        #V25_ANSADVANCE, w1     ;Update the ans tone phase
    mov        #V25AnsPhase, w2        ;for next interval
    add        w1, [w2], [w2]          
    
    mov        w0, w4    
    mov        #0x1000, w5
    mpy        w4*w5, A                ;Scale the generated sample
    sac.r      A, w0                   ;and return the sample

    return 

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

    .global _AnsTone1
    .section  .libsm, "x"
    
;------------------------------------------------------------------------------
; Description: This function is to generate the continuous answer tone without
;              phase reversals. (V25_TYPE1)
;------------------------------------------------------------------------------

_AnsTone1:

    rcall      _GenerateAnswerTone     ;Get the transmit sample
    mov        w0, V25TxSmpl           ;and store it and return
    return
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
    
    .global _AnsTone2
    .section  .libsm, "x"
    
;------------------------------------------------------------------------------
; Description: This function is to generate the continuous answer tone with 
;              phase reversals. (V25_TYPE2)
;------------------------------------------------------------------------------

_AnsTone2:

    rcall      _GenerateAnswerTone     ;Get the transmit sample
    mov        w0, V25TxSmpl           ;and store it

    ;The phase of the answer tone should be reversed every 450 ms
    ;increment the phase reversal counter and check against V25_450MS samples
    
    inc        V25PhaseRevCntr         ;Update the phase reverse timer count
    mov        V25PhaseRevCntr, w1
    
    mov        #V25_450MS, w2         
    cp         w1, w2                  ;Check for 450ms time out 
    bra        nz, RET_ANSTX_SMPL

   ;Time to reverse the phase of the answer tone
    
    mov        #V25AnsPhase, w1        ;Update the ans tone phase for
    mov        #0x7fff, w2             ;the phase reversal
    add        w2, [w1], [w1]

   ;Now reset the phase reversal counter. Counter is reset every 450 ms
    
    clr        V25PhaseRevCntr       
    
RET_ANSTX_SMPL:

    mov        V25TxSmpl, w0           ;Return the TYPE-2 ans tone sample
    return
    
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
    
    .global _AnsTone3
    .section  .libsm, "x"
    
;------------------------------------------------------------------------------
;  Description: This function executes <AnsTone2 > to generate the answer 
;               tone with phase reversals. Then this tone is amplitude 
;               modulated by 15Hz signal. (V25_TYPE3)
;------------------------------------------------------------------------------

_AnsTone3:

    rcall      _AnsTone2               ;Generate ANS tone with phase reversals
    mov        w0, V25TxSmpl           ;Store the sample

    ;Compute the 15Hz sine value for amplitude modulation
    
    mov        V25AnsAmPhase, w0       ;Generate 15Hz signal for
    call       _SinCos                 ;amplitude modulation

    ;Scale the 15 Hz signal for 20% modulation;    0.2 = 0x1999 (Q.15)

    mov        w0, w4
    mov        #0x1999, w5
    mpy        w4*w5, A                ;Scale the 15Hz signal 
    sac.r      A, w5
    
    mov        #V25AnsAmPhase, w1      ;Update the 15 Hz tone phase for next
    mov        #V25_AMADVANCE, w2      ;interval 
    add        w2, [w1], [w1]
    
    ;Modulate the 2100Hz (S2100) tone with 15Hz (S15)
    
    mov        V25TxSmpl, w4           
    mpy        w4*w5, A                ;S2100 * S15
    sac.r      A, w6

    add        w6, w4, w0              ;S2100 + S2100 * S15
    mov        w0, V25TxSmpl           ;Return ANSam Sample
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _InitAnsToneRx
    .section  .libsm, "x"
    
;------------------------------------------------------------------------------
; Description: This function initializes answer tone for V25 receiver
;------------------------------------------------------------------------------

_InitAnsToneRx:

    mov        #V25PhaseRevCntr, w0

    mov        #SIZEOFV25RX_BSS, w1
    call       _ClearStruct
    
    mov        #mdmFilterBuffer, w1
    mov        #V25DTDelayLine, w0
    add        w1, w0, w0
    mov        #SIZEOFV25RX_YBSS, w1
    call       _ClearStruct

    mov        #LVL_43dBm, w0
    mov        w0, V25DTThreshold      ;V25DTThreshold = LVL_43dBm
    
    clr        V25AnsStatus           ;V25AnsStatus = 0
    
    return
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
    
    .global _AnswerToneDetect
    .section  .libsm, "x"
    
;------------------------------------------------------------------------------
; Description: this function is executed to detect the presence of power in the 
;              answer tone band. The frequency band from 2000 - 2200 Hz is used 
;              for answer tone transmission. The filter coefficients stored in 
;              AnswerBandCoefs > has a bandwidth [2000-2200] hz and is a first 
;              order butter worth band pass filter.
;------------------------------------------------------------------------------

_AnswerToneDetect:


    mov        #mdmFilterBuffer, w1
    mov        #V25DTDelayLine, w0
    add        w0, w1, w0

    ;Filter the input sample
        
    bset       CORCON, #2
    mov        #psvpage(V25AnswerBandCoefs),w1   
    mov        w1, PSVPAG              
    mov        #psvoffset(V25AnswerBandCoefs), w1
    mov        w1, V25AnswerBandCoefsPtr        ;Pointer for accessing the     
    mov        V25AnswerBandCoefsPtr, w1        ;answer_band_coefs table
    
    mov        mdmADCSample, w2
        
    call       _ButterWorth
    
    mov        w0, w1
    mov        #V25DTAvgPRunAvg, w0
    
    ;When the < tone_status > is 0 tone is not detected
    ;So reset the tone timer counter 
    ;Decimanet by 32, Level is updated only once in 32 samples    

    call       _MeanLevel
    
    cp0        w0
    bra        z, DETECT_ANSAM
    
    mov        V25AnsStatus, w0
    mov        #ANS_DETECTED, W1
    and        w0, w1, w1
    bra        nz, DETECT_ANSAM
    
    mov        V25DTAvgPLevel, w1
    mov        #0x20, w2
    cp         w1, w2        
    bra        le, CLEAR_TIMER
    mov        mdmAverageInputLevel, w4
    mov        #0x32F0, w5
    mpy        w4*w5, A
    sac.r      A, w2
    mov        V25DTAvgPLevel, w3
    cp         w2, w3
    bra        ge, CLEAR_TIMER
    
    inc        V25AnsTimer
    mov        V25AnsTimer, w2
    mov        #3600, w3
    lsr        w3, #5, w3
    cp         w2, w3                  ;ans_tone_present
    bra        le, DETECT_ANSAM
    push       w0
    
    pop        w0
    mov        #ANS_DETECTED, w2
    ior        w2, w0, w0
    mov        w0, V25AnsStatus 
    
    mov        #mdmFilterBuffer, w4
    mov        #V25ModDelayLine, w2
    add        w2, w4, w2
    mov        [w2+4], w4
    
    mov        #0x1333, w5
    mpy        w4*w5, A
    sac.r      A, w3
    
    add        w4, w3, w6
    mov        w6, V25SampleHigh
    
    sub        w4, w3, w6
    mov        w6, V25SampleLow
    
    mov        #V25_500MS, w6
    mov        w6, V25AnsTimer        ;V25AnsTimer = V25_500MS
    
    mov        #64, w6
    mov        w6, V25AmCntr          ;V25AmCntr = 64
    
    bra        DETECT_ANSAM
    
CLEAR_TIMER:

    clr        V25AnsTimer            ;V25AnsTimer = 0
    
DETECT_ANSAM:                          ;detect_ansam

;Filter the rectified ans sample, using a low pass filter.
;The filter has a bandwidth of 150 Hz to detect the modulation

    mov        #mdmFilterBuffer, w2
    mov        #V25DTDelayLine, w1
    add        w1, w2, w1
    mov        [w1+4], w2
    btsc       w2, #15
    neg        w2, w2
    
    mov        #mdmFilterBuffer, w1
    mov        #V25ModDelayLine, w0
    add        w0, w1, w0
    mov        #psvpage(V25AnsAmFilter),w1   
    mov        w1, PSVPAG              
    mov        #psvoffset(V25AnsAmFilter), w1
    mov        w1, V25AmFilterPtr       ;Pointer to access am_filter table
    
    mov        V25AmFilterPtr, w1
    call       _ButterWorth
    
    cp0        V25AnsStatus
    bra        z, RETURNED
    mov        #ANS_DETECTED, w2
    cp0        w2
    bra        z, RETURNED             ;Do not detect ansam utill ans is 
                                       ;detected
    dec        V25AnsTimer
    
;Now check if the sample value is greater than < sample_low >
;if it is greater, then the sample value is probably within the
;modulation boundary
    
    mov        V25SampleLow, w1
    cp         w0, w1
    bra        le, ENV_OUT_BOUNDARY    ;Envelope outer boundary

;Now check if the sample value is lower than < sample_high >
;if it is lesser, then the sample value is within the
;modulation boundary
    
    mov        V25SampleHigh, w1
    cp         w0, w1
    bra        ge, ENV_OUT_BOUNDARY
    
    mov        #64, w2
    mov        w2, V25AmCntr          ;reset the modulation counter
    bra        RETURNED
    
ENV_OUT_BOUNDARY:

;envelope_outside_boundary
;Check if the envolope signal is outside the modulation boundary,
;continuously for 64 sample intervals

    dec         V25AmCntr             ;decrement V25AmCntr
    cp0         V25AmCntr
    bra         nz, RETURNED
    
    mov         #ANSAM_DETECTED, w2
    mov         V25AnsStatus, w3
    ior         w2, w3, w3             ;AnsAm has been validated
    mov         w3, V25AnsStatus
   
RETURNED:

    return

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

.endif

;------------------------------------------------------------------------------
;    END OF FILE
;------------------------------------------------------------------------------
 

