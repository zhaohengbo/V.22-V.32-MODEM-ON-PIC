/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               AGC.S                                              *
;  Date:                   09th  August,2002                                  *
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
; 0.1   10 July   2002   Code Created                                Ravi     *
; 0.2   11 July   2002   Code Reviewed                               Raghava  *
; 0.3   08 August 2002   Modified file/function header               Ravi     *
; 0.4   20 August 2002   Corrected code documentation faults         Ravi     *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Automatic Gain Control(AGC) implementation for Microchip's dsPIC30F 16-bit *
;  MCU.                                                                       *
;  Description: The modem receiver is designed to work over a wide range input*
;  signals from -5 dBm to -43 dBm.The receiver expects a constant signal level*
;  for demodulation and detection. The AGC is a linear gain control algorithm.*
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;                                                                             *
;  InitializeAGC:                                                             *
;  ======================                                                     *
;  Description: This function initializes all the parameters for Agc,the      *
;               linear gain control algorithm.                                *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0 used not restored                                                      *
;                                                                             *
;  Functions Called:  ClearAGCVars                                            *
;                                                                             *
;******************************************************************************
;  CheckEnergyStatus:                                                         *
;  ======================                                                     *
;  Description: This function checks the signal, whether it is high or low    *
;               with respect to AGC minimum energy level and accordingly      *
;               sets the Energy Status.                                       *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1 used not restored                                                  *
;                                                                             *
;  Functions Called:  MeanLevel, StartAgc, InitializeAGC                      *
;                                                                             *
;******************************************************************************
;  AGC:                                                                       *
;  ======================                                                     *
;  Description: This function is used to scale the input signal to the        *
;               reference value required by the decision module in the        *
;               modem receiver.                                               *
;                                                                             *
;  Input:  w0 = AGCInput                                                      *
;                                                                             *
;  Output: w0 = AGCEnergrStat                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w4, w5, w6, w8, w9, w10 used not restored                     *
;   AccA, AccB                          used not restored                     *
;   CORCON                              used and restored                     *
;                                                                             *
;  Functions Called:  CheckEnergyStatus                                       *
;                                                                             *
;******************************************************************************
;  SetMinEnergyLevel:                                                         *
;  ======================                                                     *
;  Description: This function set the signal energy validation threshold.     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w4, w5, w6, w7 used not restored                                      *
;   AccA            used not restored                                         *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  StartAgc:                                                                  *
;  ======================                                                     *
;  Description: This function Sets the AgcGain and Energy status flag.        *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w2, w4, w5, w6, w7 used not restored                                  *
;   AccA                   used not restored                                  *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  FreezeAGC:                                                                 *
;  ======================                                                     *
;  Description: This function Sets the Agcfreeze flag when no gain control is *
;               required.                                                     *
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
;  ClearAGCVars:                                                              *
;  ======================                                                     *
;  Description: This function clears the AGC variables                        *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1 used not restored                                                   *
;                                                                             *
;  Functions Called:  ClearStruct                                             *
;******************************************************************************
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words : 1                                            *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitializeAGC:          12                                              *
;     CheckEnergyStatus:      37                                              *
;     AGC:                    57                                              *
;     SetMinEnergyLevel:      12                                              *
;     StartAgc:               19                                              *
;     FreezeAGC:              03                                              *
;     ClearAGCVars:           09                                              *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;     .nbss:                  03                                              *
;     .bss:                   26                                              *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitializeAGC:          15                                              *
;     CheckEnergyStatus:      27                                              *
;     AGC:                    90                                              *
;     SetMinEnergyLevel:      14                                              *
;     StartAgc:              168                                              *
;     FreezeAGC:               5                                              *
;     ClearAGCVars:           11                                              *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include   "agc.inc"
    .include   "modem.inc"
    .include   "signal.inc"
    .include   "defs.inc"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global    _InitializeAGC
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;Description  :   The following sequence of operations is performed
;                 1. Clear Agc Parameters
;                 2. Set AgcGain to DefaultGain. [The DefaultGain has to be
;                    initialized when the channel is opened]
;                 3. If AgcMinEnSet is 0,then set AgcMinEnLevel to LVL_47dBm.
;                 4. For data modem start the AGC immediately after opening 
;                    the channel and valid signal is detected by setting 
;                    AgcAutoStart flag.
; -----------------------------------------------------------------------------

_InitializeAGC:
    
    rcall       ClearAGCVars

    cp0.b      mdmAgcMinEnSet          ;will not set minimum energy level
    bra        nz, SET_AUTOSTART       ;if min energy is set   

    mov        #LVL_47dBm, w0          ;set the threshold energy level
    mov        w0,mdmAgcMinEnLevel
   
SET_AUTOSTART: 

    mov        #1, w0
    mov.b      wreg, AGCAutoStart      ;sets the AutoStart
   
    mov        #0x100, w0
    mov        w0, AGCGain             ;agc gain is set to 0x100
    
; In data modem modes, AGC starts updating the Gain parameter as soon as
; valid signal energy is detected. 

; Default Reference receiver input is set to a value corresponding to
; -18 dBm. The receiver initialization routine can reprogram this value
; after the function returns
; The AGC time constant is also programmable. By default, the error
; scaling is 0x1000 corresponding to 1 in (4.12 format). The receiver
; routine can reprogram this value to change AGC convergence time
; Range = 0 - 7fff = 0 - 16
   
    mov        #0x7fff, w0
    mov        w0, AGCTC               ;agctc is set to 0x7fff

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global    _CheckEnergyStatus
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: Check the Energy status of received signal
; -----------------------------------------------------------------------------

_CheckEnergyStatus:

; First estimate the input signal level in the 16 sample window

    mov        #AGCMeanPRunAvg, w0
    mov        AGCInput, w1
    call       _MeanLevel              ;estimates the input signal level in
   
    cp0        w0                      ;the 16 sample window
    bra        nz,CHK_SIGNAL_LVL
    return

;If the input signal level is greater than <AgcMinEnergyLevel>,which
;is by default set to -47dBm, <HiEngCntr> is incremented,when this 
;counter reaches 3(i.e. when the input signal level is high continuously
;for three 32 sample window <EnergyStat> is set to 1.
   
CHK_SIGNAL_LVL:

    mov        AGCMeanPAvg, w0
    mov        mdmAgcMinEnLevel, w1
    cp         w0, w1                  ;input signal is compared with min 
                                       ;energy level
    bra        le, SIGNAL_LVL_LOW      ;if the signal is low the agc hi eng 
                                       ;count is reset
   
    clr.b      AGCLowEngCntr           ;if the signal is high the agc low eng
                                       ;count is reset
   
    mov.b      AGCHiEngCntr,wreg
    mov        #3, w1
    cp.b       w0, w1                  ;when hi eng count reaches 3 i.e. if the
                                       ;eng is hi continuously for 3 16 sample 
    bra        nz, UPDATE_HIENG_CNTR   ;window
   
    cp0.b      AGCEnergyStat           ;checks for agc energy status
    bra        nz, EXIT_CHK_ENG_STATUS
   
    cp0.b      AGCAutoStart            ;checks if autostart is set
    bra        z, EXIT_CHK_ENG_STATUS
   
    rcall      _StartAgc               ;if autostart is set then call StartAgc 
                                       ;function
   
    goto       EXIT_CHK_ENG_STATUS
   
UPDATE_HIENG_CNTR: 

    inc.b      AGCHiEngCntr
    goto       EXIT_CHK_ENG_STATUS
   
SIGNAL_LVL_LOW:

; When input signal energy is less than <AgcMinEnLevel> continuously
; for 5 , sixteen sample windows, then reset the <EnergyStat>.

    clr.b      AGCHiEngCntr            ;if signal level is low the hi eng count
                                       ;is reset
   
    cp0.b      AGCEnergyStat           ;checks if agc energy status is reset 
    bra        nz, UPDATE_LOWENG_CNTR
    return
   
UPDATE_LOWENG_CNTR:

    inc.b      AGCLowEngCntr,wreg
    mov.b      wreg,AGCLowEngCntr      ;pre-increments the agc low energy 
                                       ;counter

    cp.b       w0, #5
    bra        ge, DETECT_LOW_ENG      ;if it detects the low energy signal
                                       ;then again reinitializes agc

    return

DETECT_LOW_ENG:
    rcall      _InitializeAGC

EXIT_CHK_ENG_STATUS:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global     _AGC
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description  : The operations performed in this function depends on the
;                 current values of certain AgcParameters.
;                 1.  The input sample passed as the argument to this 
;                 function, is saved in AgcInput. Then validate the 
;                 presence of remote signal energy.
;                 2.  The output signal AgcOutput is generated and format 
;                 adjusted to 1.15 format. [It is assumed that the input
;                 signal is in 1.15 format]. 
;                 3.  If AgcFreeze is 0, then, the output signal energy 
;                 is accumulated.
;                 If AgcFreeze if 1, energy accumulation is not executed.
;                 4.  If AgcHighEngCntr is non-zero, gain update is executed
;                 when, the average output energy lies outside the o/p 
;                 energy window. 
;                 5.  The gain updation is done using the formula,
;                     Gain = Gain(1-e),Where e - is the error
; -----------------------------------------------------------------------------
   
_AGC:

    mov        w0, AGCInput            ;here is the agc input

    rcall      _CheckEnergyStatus      ;checks the energy status

    mov        AGCInput, w4
    mov        AGCGain, w5
    mpy        w4*w5, A
    sftac      A, #-7
    sac.r      A, w1                   ;agc output is obtained here
    mov        w1,AGCOutput

    cp0.b      AGCFreeze               ;checks whether the agc freeze is reset
    bra        nz, EXIT_AGC

    clr        w0
    mov.b      AGCOutBufIndex, wreg
    mov        #AGCOutBuf, w1
    
    inc2.b     AGCOutBufIndex 

    mov        AGCOutput, w2
    btsc       w2, #15
    neg        w2, w2

    mov        w2, [w1+w0]             ;accumulates abs levels of 16 o/p 
                                       ;samples in double precision

    mov.b      AGCOutBufIndex, wreg    ;just to avoid saturation signal is 
                                       ;scaled before accum
    mov        #32, w2
    cp.b       w0, w2
    bra        lt, ACCUMULATE_AGC_OP

    clr.b      AGCOutBufIndex

ACCUMULATE_AGC_OP: 

    mov        #AGCOutBuf, w9 
    mov        #1, w5
;   clr        A,[w9]+=2,w4
    clr        A
    mov        [w9++],w4

    push       CORCON
    bset       CORCON,#0
    
    do         #15, AGC_LP
    mac        w4*w5, A  ;, [w9]+=2, w4   ;accumulates o/p
AGC_LP:   
    mov        [w9++], w4
        
    pop        CORCON
    sftac      A, #4

    cp0.b      AGCHiEngCntr            ;compares and scales error for faster
                                       ;convergence if needed
    bra        z, EXIT_AGC

    cp0.b      AGCEnergyStat
    bra        z, EXIT_AGC
   
    mov        #AGC_REFERENCE, w10     ;agc reference level signal
    mov        ACCAL,w8

    sub        w8, w10, w4
    mov        w4, AGCInput
   
    mov        AGCTC, w5
    mpy        w4*w5, A
    sac        A, w5
    
    mov        AGCGain, w6
    lac        w6, B
    mpy        w5*w6, A
    
    sub        B                       ;calculates the gain factor required to
                                       ;maintain the o/p signal
    sac.r      B, w1                   ;and maintains at agc reference value
    mov        w1,AGCGain
   
    mov        #0x20, w0
    cp         w1, w0
    bra        gt, EXIT_AGC
    mov        w0, AGCGain
   
EXIT_AGC:
    mov.b      AGCEnergyStat, wreg     ;returns energy status
    return   


; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global     _SetMinEnergyLevel
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description  : This function sets the lower signal energy threshold for the
;                 fast detection of the drop in the remote signal energy.This
;                 function is called when currently valid signal being 
;                 received.
; -----------------------------------------------------------------------------

_SetMinEnergyLevel:

    mov        AGCMeanPLevel, w4       ;this function is called when currently
                                       ;valid signal is
    mov        #0x287a, w5             ;being received
    mpy        w4*w5, A                ;sets the lower signal level threshold
                                       ;for fast detection
    sac.r      A, w6                   ;of the drop in the remote signal energy
   
    mov        #LVL_47dBm, w7
    cp         w6, w7       
    bra        ge, LIMIT_LOW_LVL_SIGNAL
    mov        w7, w6
   
LIMIT_LOW_LVL_SIGNAL:

    mov        w6, mdmAgcMinEnLevel    
   
    mov        #1, w0
    mov.b      wreg,mdmAgcMinEnSet     ;then agc min energy flag is set
   
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global     _StartAgc
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; Description: This function sets up the start gain factor in the beginning. 
;              A coarse adjustment in the beginning of the gain updation speeds
;              up gain convergence. Approximately, the gain is set to within 3
;              dB of the optimum gain in this procedure. This should be called 
;              only once, after valid signal energy is detected. In the data 
;              modem modes, this function is automatically called when high 
;              energy is detected.
; -----------------------------------------------------------------------------

_StartAgc:

;This is the gain required if the input signal is at 0 dBm.
;The gain required for the current input signal level is
;increased in 2 dB steps to chose a starting gain as close to
;the optimum as possible    

    mov        #0x20, w5                 
    mov        w5, AGCGain             ;this is the gain required if the i/p
                                       ;signal is at 0dBm

    mov        #0x5093, w6
    mov        #0x65ac, w7
          
;Since the level is changed by 2 dB for 22 iterations, the dynamic
;range for gain adjustments is 0 to -44 dBm

    mov        #LVL_0dBm, w4           ;input for 0dBm
    mov        AGCMeanPAvg, w2  

    mov        #22,w0                  ;since the lvl is changed by 2dB for 22

AGC_DYNRANGE: 

;Gain has been found if Avg > T
                                       ;iterations
    cp         w2, w4                  ;the dynamic range for the gain
                                       ;adjustments is 0 to -44dBm
    bra        GT, SET_ENG_STAT

    mpy        w5*w6, A                ;Increase 2 dB
    sac.r      A, w5                   ;Decrease 3 dB
    sl         w5, #1, w5

    mpy        w4*w7, A
    sac.r      A, w4
    
    dec        w0,w0
    cp0        w0
    bra        nz,AGC_DYNRANGE

SET_ENG_STAT:

    mov        w5, AGCGain
    mov        #1, w0
    mov.b      wreg, AGCEnergyStat     ;the energy status is set
    return
   
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global     _FreezeAGC
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is called when there is no requirement of gain
;               control.
; -----------------------------------------------------------------------------

_FreezeAGC:
    mov        #1,w0
    mov.b      wreg, AGCFreeze         ;if no gain control is required 
                                       ;AGCFreeze is set
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global     _ClearAGCVars
    .section  .libsm, "x"

ClearAGCVars:

    mov        #AGCHiEngCntr, w0
    mov        #SIZEOFAGC_NBSS, w1
    call       _ClearStructByte
    mov        #AGCInput, w0
    mov        #SIZEOFAGC_BSS, w1
    call       _ClearStruct
    return
    
; -----------------------------------------------------------------------------
;   END OF FILE
; -----------------------------------------------------------------------------
   
