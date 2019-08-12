;******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               TONED.S                                            *
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
; 0.1   28 August 2002         Code Created                         Ravi      *
; 0.2   2  Sept   2002         Code Reviewed                        Raghava   *
;                                                                             *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Tone Detector implementation for Microchip's dsPIC30F 16-bit MCU           *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;                                                                             *
;******************************************************************************
;  ToneDetector                                                               *
;  ======================                                                     *
;  Description: All the process are implemented at a sampling rate of 8000 Hz *
;               This function computes the absoulte levels of the total input *
;               signal and the signal power in the band of interest. When the *
;               total signal power <mdmAverageInputLevel> is greater than -43 *
;               dBm threshold, the relative levels of the total input signal  *
;               and the required signal are checked. If the average tone power*
;               is within 6 dB of the input signal power, the tone detection  *
;               status, is set to 1. When the required tone power is less than*
;               6 dB of the input level, the tone status is reset to 0. This  *
;               allows the procedure to detect the tone signals with SNR's    *
;               as low as 6 dB.                                               *
;  ======================                                                     *
;  Input:                                                                     *
;        w0 = Tone Filter Delay Line Pointer                                  *
;        w1 = Tone Filter Coefficients Pointer                                *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2                   used not restored                             *
;                                                                             *
;  Functions Called:  ButterWorth, MeanLevel                                  *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   2                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     ToneDetector:   38                                                      *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;    None                                                                     *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     ToneDetector:    35                                                     *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "toned.inc"
    .include "modem.inc"
    .include "defs.inc"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if DEF_CALLPROG == 1    

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ToneDetector
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function computes the absolute levels of the total input 
;               signal and the signal power in the band of interest. When the 
;               total signal power <mdmAverageInputLevel> is greater than -43 
;               dBm threshold, the relative levels of the total input signal 
;               and the required signal are checked. If the average tone power
;               is within 6 dB of the input signal power, the tone detection 
;               status is set to 1. When the required tone power is less than 
;               6 dB of the input level, the tone status is reset to 0.This 
;               allows the procedure to detect the tone signals with SNR's as 
;               low as 6 dB.
; -----------------------------------------------------------------------------

_ToneDetector:

    ;Filter the signal in call progress band
    push      w0
    
    mov       w1,w0 
    mov       w2,w1 
    mov       mdmADCSample, w2        ;Input sample to be filtered
    
    call      _ButterWorth

    ;Compute the signal level in the frequency band of interest    

    mov        w0, w1
    
    pop        w0
    
    push       w0
    call       _MeanLevel
    pop        w0
    
    ;Check if the total input signal level  
    ;is greater than tone signal threshold. 

    mov        [w0+tdAPLevel], w1
    mov        #LVL_43dBm, w2
    
    cp         w1, w2
    bra        le, LOW_TONE

    mov        mdmAverageInputLevel, w1
    mov        [w0+tdAPThreshold], w2
    cp         w1, w2
    bra        le, LOW_TONE

    ;No further processing is required when 
    ;the signal level is lower than -43 dBm0
    
    cp0.b      mdmSignalHigh
    bra        z, LOW_TONE             

    ;Comparing the signal levels
    ;If tone power is within 6 dB of the input signal power , then
    ;tone status is set to indicate the presence of tone
    
    lsr        w1, #2, w1
    mov        [w0+tdAPLevel], w2
    
    cp         w2, w1                  
    bra        le, LOW_TONE
    
    mov        [w0+tdAPToneStatus], w2
    cp0        w2
    bra        nz, EXIT_TONE_DET
    
    mov        #1, w2
    mov        w2, [w0+tdAPToneStatus]      ;tone status is set to 1
    bra        EXIT_TONE_DET
    
LOW_TONE:
    mov        [w0+tdAPToneStatus], w2
    cp0        w2
    bra        z, EXIT_TONE_DET
    
    mov        #0, w1
    mov        w1, [w0+tdAPToneStatus]          ;tone status is reset to 0
    
EXIT_TONE_DET:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
.endif

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------
            
