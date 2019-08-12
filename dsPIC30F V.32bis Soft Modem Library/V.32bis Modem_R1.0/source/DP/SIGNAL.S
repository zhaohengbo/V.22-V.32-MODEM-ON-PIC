/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               SIGNAL.S                                           *
;  Date:                   12th  August,2002                                  *
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
; 0.1   19 July   2002   Code Created                                Ravi     *
; 0.2   20 July   2002   Code Reviewed                               Raghava  *
; 0.3   08 August 2002   Modified file/function header               Ravi     *
; 0.4   23 August 2002   Corrected code documentation faults         Rajiv    *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Mean level estimation,Quadrant finding, Carrier generation implementation  *
;  for Microchip's dsPIC30F 16-bit MCU.                                       *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;                                                                             *
;  MeanLevel:                                                                 *
;  ======================                                                     *
;  Description: This estimates the average level of any sampled input signal. *
;                                                                             *
;  Input:  w0 = base address of mean data structure                           *
;          w1 = input samples                                                 *
;                                                                             *
;  Output: w0 = 1,If Averaging is done for 32 samples, 0 otherwise            *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w3, w4, w7, w8, w9, w11 used not restored                     *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  SinCos:                                                                    *
;  ======================                                                     *
;  Description: This function is used for carrier generation.                 *
;                                                                             *
;  Input:  w0 = Txcarrier                                                     *
;          w1 = Txcarrier with 90 deg phase shift                             *
;                                                                             *
;  Output: w0 = sin(x)                                                        *
;          w1 = cos(x)                                                        *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w1, w3, w4, w5, w6, w7 used not restored                             *
;    AccA, AccB                 used not restored                             *
;                                                                             *
;  Functions Called: None                                                     *
;                                                                             *
;******************************************************************************
;  GetQuadrant:                                                               *
;  ======================                                                     *
;  Description: This function is used to get the quadrant to which the        *
;               vector X belongs.  This function returns 0,1,2 and 3          *
;               respectively for points situated in quadrants 1,2,3 and 4.    *
;                                                                             *
;  Input: w0 = XReal     -- (I) Real component of the vector X                *
;         w1 = XImag     -- (I) Imaginary component of the vector X           *
;                                                                             *
;  Output: w0 = Quadrant                                                      *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w1, w2 used not restored                                             *
;                                                                             *
;  Functions Called: None                                                     *
;                                                                             *
;******************************************************************************
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words : 0                                            *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     MeanLevel:                 26                                           *
;     SinCos:                    60                                           *
;     GetQuadrant:               21                                           *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;     None                                                                    *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     MeanLevel:                 28                                           *
;     SinCos:                    63                                           *
;     GetQuadrant:               23                                           *
;                                                                             *
;*****************************************************************************/
; -----------------------------------------------------------------------------
; INCLUDE FILES
; -----------------------------------------------------------------------------

    .include   "signal.inc"
    .include   "defs.inc"
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global   _MeanLevel
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to estimate the average level of the
;               input signal.The input signal is accumulated for 32 samples.
;               At the end of the 32 samples the accumulated value is 
;               divided by 32.        
; -----------------------------------------------------------------------------
   
_MeanLevel:

    btsc       w1, #15
    neg        w1, w1 

    mov        #0, w9
    add        w1, [w0],[w0++]
    mov        #0, w7
    addc       w7, [w0],[w0--]         ;adds and stores the i/p samples to 
                                       ;RunAvg 
   
    mov        #32, w4
    mov        [w0+Cntr], w11
    add        w11, #1, w11
    mov        w11, [w0+Cntr]
    cp         w11, w4                 ;pre-increments the cntr and compares 
                                       ;with 32 samples
    bra        lt, RET_MEAN_LVL_COUNT
   
    add        w9, #1, w9
    mov.d      [w0], w2                
    sl           w3, #11, w3
    lsr        w2, #5, w2
    ior        w2, w3, w2
    mov        w2, [w0+Avg]            ;finds the average/mean level of the 
                                       ;samples
   
    mov        #0, w7
    mov        w7, [w0+Cntr]
    mov        w7, [w0]
    mov        w7, [w0+2]              ;initializes cntr and runavg to zero
   
    mov        [w0+Avg], w8
    mov        w8, [w0+Level]          ;set the level at the average value
   
RET_MEAN_LVL_COUNT:
    mov        w9, w0
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global    _SinCos
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to generate the sine/cos value 
;               required for generation of carriers in all modes of 
;               operation. This function approximates Taylor series 
;               polynomial.
;               sin(x) = 3.140625x + 0.02026367x^2 - 5.325196X^3 + 
;               0.5446778x^4 + 1.800293x^5
;               This routine that implements this sine approximation, 
;               accurate to within two LSBS. This routine accepts input 
;               values in 1.15 format. The coefficients, which are 
;               initialised in data memory in 4.12 format, have been 
;               adjusted to reflect an input value scaled to the maximum 
;               range allowed by this format.On this scale, 180º equals the
;               maximum positive value, 7FFF, and -180º equals the maximum
;               negative value, 8000.
; -----------------------------------------------------------------------------

_SinCos:

    mov.d        w0, w4                ;save the inputs

    btsc         w0, #14
    neg          w0, w4                ;Take Absolute value of sine input
    bclr         w4,#15

    btsc         w1, #14
    neg          w1, w5                ;Take Absolute value of sine input
    bclr         w5,#15

    mov          #0x1CCE, w7          
    mov          #0x08B7, w3           ;coefficient of sine series
    lac          w3, B

    mpy          w4*w7, A              ;a * x
    add          A
    sac.r        A, w6

    mpy          w5*w7, A              ;a * y
    add          A
    sac.r        A, w7

    mov          #0xAACC, w3           ;Take second coeff b
    lac          w3, B

    mpy          w4*w6, A              ;x^2 * b
    add          A                     ;a*x +b* x^2
    sac.r        A, w6

    mpy          w5*w7, A              ;y^2 * b
    add          A                     ;a*y +b* y^2
    sac.r        A, w7

    mov          #0x0053, w3           ;Take the next coeff c
    lac          w3, B

    mpy          w4*w6, A              ;x^3 * c
    add          A                     ;a*x + b*x^2 +c*x^3
    sac.r        A, w6

    mpy          w5*w7, A              ;y^3 * c
    add          A                     ;a*y + b*y^2 +c*y^3
    sac.r        A, w7

    mov          #0x3240, w3           ;Take the next coeff d
    lac          w3, B

    mpy          w4*w6, A              ;x^4 * d
    add          A                     ;a*x + b*x^2 +c*x^3 +d*x^4
    sac.r        A, w6

    mpy          w5*w7, A              ;y^4 * d
    add          A                     ;a*y + b*y^2 +c*y^3 +d*y^4
    sac.r        A, w7

    mpy          w4*w6, A             
    sac.r        A, w6

    mpy          w5*w7, A
    sac.r        A, w7

    sl           w6, #3, w6   ; x1
    sl           w7, #3, w7   ; x11

    cp0          w6                    ;check the sin result for saturation
    bra          ge, sin_out
    mov          #0x7fff, w6           ;saturate to max positive value

sin_out:
    mov          w6, w4    

    cp0          w7                    ;check the cos result for saturation
    bra          ge, cos_out1

    mov          #0x7fff,w7            ;saturate to max positive value


cos_out1:
    mov          w7, w5

    btsc         w0, #15
    neg          w4, w4                ;Finally include sign bit to sin result

    btsc         w1, #15
    neg          w5, w5                ;Finally include sign bit to cos result

    mov.d        w4, w0                ;Return sine and cosine outputs

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
   
    .global _GetQuadrant
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to get the quadrant to which the
;               vector X belongs.  This function returns 0,1,2 and 3 
;               respectively for points situated in quadrants 1,2,3 and 4.
; -----------------------------------------------------------------------------
    
_GetQuadrant:

    cp0        w0
    bra        lt, QUAD1
    cp0        w1
    bra        lt, QUAD1
    clr        w2                      ;First quadrant ( X +ve, Y +ve )
    bra        EXIT_GET_QUAD
    
QUAD1:                                 ;Second Quadrant ( X -ve, Y +ve)
    cp0        w0
    bra        ge, QUAD2
    cp0        w1
    bra        lt, QUAD2
    mov        #1, w2
    bra        EXIT_GET_QUAD
QUAD2:                                 ;Third quadrant ( X -ve, Y -ve )
    cp0        w0
    bra        ge, QUAD3
    cp0        w1
    bra        ge, QUAD3
    mov        #2, w2
    bra        EXIT_GET_QUAD
QUAD3:                                 ;Fourth quadrant ( X +ve, Y -ve)
    mov        #3, w2  
EXIT_GET_QUAD:    
    mov        w2, w0
    return
    

; -----------------------------------------------------------------------------
;   END OF FILE
; -----------------------------------------------------------------------------
