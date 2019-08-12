/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               DTMFGEN.S                                          *
;  Date:                   02th  September,2002                               *
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
; 0.1   02 September 2002   Code Created                               Ravi   *
; 0.2   03 September 2002   Code Reviewed                              Raghava*
; 0.3   03 September 2002   Modified file/function header              Ravi   *
; 0.4   03 September 2002   Corrected code documentation faults        Ravi   *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  DTMF(Dual Tone Multi Frequency) tone generator implementation for          *
;  Microchip's dsPIC30F 16-bit MCU.                                           *
;  Description: A DTMF transmitter (encoder) generates a composite audio      *
;               tone burst which comprises two frequencies fl and  fh that    *
;               are not harmonically related. Furthermore, the choice of      *
;               DTMF frequencies has been guided by the need to avoid         *
;               between a dialling tone and a conversation flow. For this     *
;               reason, the probability of finding one of the possible        *
;               combinations of frequencies and their levels in a             *
;               conversation (or a room noise) is statistically extremely     *
;               weak.                                                         *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;  DTMFGen:                                                                   *
;  ======================                                                     *
;  Description: This function generates composite DTMF signal that comprises  *
;               of two frequencies for each digit                             *
;                                                                             *
;  Input:  w0 = dtmfdigit                                                     *
;          w1 = base address of dtmftone buffer                               *
;          w2 = Number of samples                                             *
;                                                                             *
;  Output: w0 = dtmfdigit                                                     *
;                                                                             *
;  System Resource usage:                                                     *
;   w0 - w13 used not restored                                                *
;   AccA used not restored                                                    *
;   CORCON used not restored                                                  *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words : 7                                            *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitDTMFGen:    16                                                      *
;     DTMFGen:        129                                                     *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     LOWImp:         16                                                      *
;     LOWCos:         16                                                      *
;     HIGHImp:        16                                                      *
;     HIGHCos:        16                                                      *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;     None                                                                    *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitDTMFGen:        Depends on Number dialling                          *
;     DTMFGen:            89 + 19N                                            *
;                                                                             *
;*****************************************************************************/
; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "dtmftables.inc"
    .include "dtmfgen.inc"

 .section .nbss

   DtmfCounter:             .space 2
   DtmfState:               .space 2
   DtmfSilenceDuration:     .space 2
   DtmfToneDuration:        .space 2
   DtmfTxSmplCounter:       .space 2
   Digit:                   .space 2
   DtmfStrIndex:            .space 2
   DtmfString:              .space 20
   dtmf_lowcos:             .space 2
   dtmf_highcos:            .space 2
   dtmf_low0:               .space 2
   dtmf_low1:               .space 2
   dtmf_high0:              .space 2
   dtmf_high1:              .space 2
   
   
   
    .global _InitDTMFGen
;    .section  .libsm, "x"
    .section .text

; Inputs: w0 = DtmfStringBuf, w1 = Noofdigits 


_InitDTMFGen:

    clr        DtmfCounter
    clr        DtmfStrIndex
    mov        #DTMFSILENCE, w2
    mov        w2, DtmfState
    mov        #800, w2
    mov        w2, DtmfSilenceDuration
    mov        w2, DtmfToneDuration
    mov        #8000, w2
    mov        w2, DtmfTxSmplCounter
    
    dec        w1, w1
    mov        #DtmfString, w2
    repeat     w1
    mov.b      [w0++], [w2++]

    mov        #-1, w0
    mov.b      w0, [w2]

    return        

    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _DTMFGen
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
; Description: DTMF generator comprises of generation of two tones for
;              each digit.
;              Signaling frequencies are chosen in two groups of distinct
;              frequencies in the range from 300 Hz to 3400 Hz. A signal 
;              is made up of one, and only one, frequency from each group
;              which are simultaneously transmitted on the line.
;
;              Low Group      High Group
;              ---------      ----------
;              697 Hz         1209 Hz
;              770 Hz         1336 Hz
;              852 Hz         1477 Hz
;              941 Hz         1633 Hz
; -----------------------------------------------------------------------------
    
_DTMFGen:

    push       CORCON
    push       PSVPAG
    push       w8                      ;Save the register needed
    push       w9
    push       w10
    push       w11
    push       w12
        
    mov        #DTMFEND, w2
    mov        DtmfState, w4
    cp         w4, w2
    bra        nz, DTMFBEGIN
    
    mov        #(DTMFFRMLENGTH-1), w2
    clr        w3    
    repeat     w2
    mov        w3, [w0++]

    mov        DtmfState, w0
    bra        DTMF_GEN_EXIT 
    
DTMFBEGIN:

    cp0        DtmfTxSmplCounter
    bra        gt, DTMF_COMPUTE

    mov        DtmfToneDuration, w2
    mov        w2, DtmfTxSmplCounter

    clr        DtmfCounter

    mov        #DTMFSIGNAL, w2
    mov        DtmfState, w3
    cp         w3, w2
    bra        nz, SKIP_SILENCE

    mov        #DTMFSILENCE, w2
    mov        w2, DtmfState

    mov        DtmfSilenceDuration, w2
    mov        w2, DtmfTxSmplCounter
    bra        DTMF_COMPUTE

SKIP_SILENCE:
    
    mov        #DTMFSIGNAL, w2
    mov        w2, DtmfState

    mov        DtmfStrIndex, w3
    mov        #DtmfString, w8
    
    mov        #-1, w2

    clr        w4
    mov.b      [w8+w3], w4
    
    inc        w3,w3
    mov        w3,DtmfStrIndex
    
    mov        w4, Digit
    cp.b       w4, w2
    bra        nz, DTMF_COMPUTE
    
    mov        #DTMFEND, w2
    mov        w2, DtmfState

DTMF_COMPUTE:

    mov        #DTMFSIGNAL, w2
    mov        DtmfState, w3

    cp         w3, w2
    bra        nz, L2

    mov        #DTMFFRMLENGTH, w2

    cp0        DtmfCounter
    bra        nz, L3

    bset       CORCON, #7              ;setting seventh bit of CORCON for 
    bset       CORCON, #2              ;setting seventh bit of CORCON for     

    ;storing the corresponding coeff values using only one look up
    
    mov        #psvpage(LOWImp),w3
    mov        w3, PSVPAG
    mov        #psvoffset(LOWImp),w8
    
    mov        Digit, w10
    sl         w10, #1, w10
 
    mov        [w8+w10], w4            ;Coeff=A * sin(2pi * Frowtone/Fsamp)
    
    mov        w4, dtmf_low0           ;low0
                                        
    mov        #psvpage(LOWCos),w3
    mov        w3, PSVPAG
    mov        #psvoffset(LOWCos),w8
    
    mov        [w8+w10], w5   
    
    mov        w5, dtmf_lowcos         ;lowcos
    
    mov        #psvpage(HIGHImp),w3
    mov        w3, PSVPAG
    mov        #psvoffset(HIGHImp),w8
    
    mov        [w8+w10], w6            ;Coeff=A * sin(2pi * Fcoltone/Fsamp)
    
    mov        w6, dtmf_high0          ;high0
    
    mov        #psvpage(HIGHCos),w3
    mov        w3, PSVPAG
    mov        #psvoffset(HIGHCos),w8
    
    mov        [w8+w10], w7            
    
    mov        w7, dtmf_highcos       ;highcos
    
    ;computation of initial values
    
    mpy        w4*w5, A                ;coeff * y[n-1]
    sac        A, w10                  
    sl         w10, #1, w10            ;2 * (coeff * y[n-1])
    
    mov        w10, dtmf_low1
    
    mpy        w6*w7, A
    sac        A, w11                  ;coeff * y[n-1]
    sl         w11, #1, w11            ;2 * (coeff * y[n-1])
    
    mov        w11, dtmf_high1

    ;Tone generation for 360 samples i.e. 45 ms duration
    
    add        w4, w6, w3
    mov        w3, [w0++]              ;sum the initial values
    
    add        w10, w11, w3
    mov        w3, [w0++]              ;sum the initial values

    dec2       w2,w2  
L3:

    sub        w2, #1, w2
    
    do         w2, TONE_GENERATION
   
    ;low frequency generation
    
    mov        dtmf_lowcos, w5
    mov        dtmf_low1, w6
    mov        dtmf_low0, w4
    
    
    mpy        w5*w6, A                ;cos(coeff) * x[n-1]
    sac        A, w8                   
    sl         w8, #1, w8              ;2 * cos(coeff)* x[n-1]
    
    sub        w8, w4, w8              ;2 * cos(coeff) * x[n-1] - x[n-2]
    
    mov        w6, dtmf_low0
    mov        w8, dtmf_low1
    
    mov        dtmf_high1, w6  
    mov        dtmf_highcos, w7
    ;high frequency generation
    
    mpy        w6*w7, A                ;cos(coeff) * y[n-1]
    sac        A, w9                   
    sl         w9, #1, w9              ;2 * cos(coeff) * y[n-1]
    
    mov        dtmf_high0, w7
    sub        w9, w7, w9              ;2 * cos(coeff) * y[n-1] - y[n-2]
    
    mov        w6, dtmf_high0
    mov        w9, dtmf_high1
    
    ;sum the two tones
    
    add        w8, w9, w12
    
    mov        w12, [w0++]

TONE_GENERATION:
    nop 

    bra      L4
L2:

    mov      #(DTMFFRMLENGTH-1), w1
    clr      w4
    repeat   w1
    mov      w4, [w0++]

L4:
    mov      #DTMFFRMLENGTH, w0
    sub      DtmfTxSmplCounter
    inc      DtmfCounter

    mov      DtmfState, w0

DTMF_GEN_EXIT:

    pop       w12
    pop       w11
    pop       w10
    pop       w9
    pop       w8                       ;Retreive the registers saved
    pop       PSVPAG
    pop       CORCON

    return
    
; -----------------------------------------------------------------------------
; END OF FILE
; -----------------------------------------------------------------------------
