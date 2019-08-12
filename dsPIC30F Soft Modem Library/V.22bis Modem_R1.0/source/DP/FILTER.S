/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               FILTER.S                                           *
;  Date:                   11th  August,2002                                  *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.43.00.0                             *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;  Revision History:                                                          *
; ----------------------------------------------------------------------------*
; Rev:   Date:              Details:                                  Who:    *
; ----------------------------------------------------------------------------*
; 0.1   11 July   2002   Code Created                                Ravi     *
; 0.2   12 July   2002   Code Reviewed                               Raghava  *
; 0.3   12 August 2002   Modified file/function header               Ravi     *
; 0.4   20 August 2002   Corrected code documentation faults         Ravi     *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Hilbert Transform, Butterworth & FIR implementation for Microchip's        *
;  dsPIC30F 16-bit MCU.                                                       *
;  The Hilbert transformer is used to estimate the imaginary part of the      *
;  received signal. Since the transmitter generates only the real part the    *
;  modulator output, it is necessary to have the imaginary part of the pass   *
;  band signal, before demodulation. This is required in a base band equalizer*
;  implementation. After the Hilbert transform is computed, all the signals in*
;  the receiver are processed in complex domain.                              *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;  InitHilbert:                                                               *
;  ======================                                                     *
;  Description: This function initializes the parameters for Hilbert          *
;               transformer.                                                  *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w8 used not restored                                                 *
;    CORCON used saved and restored                                           *
;    PSVPAG used saved and restored                                           *
;                                                                             *
;  Functions Called: ClearHilbVars                                            *
;                                                                             *
;******************************************************************************
;  Hilbert:                                                                   *
;  ======================                                                     *
;  Description: This function implements the hilbert transform filter.        *
;                                                                             *
;  Input:  w0 = input samples                                                 *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w1, w2, w3, w4, w5, w6, w8, w10 used not restored                    *
;    AccA                                used not restored                    *
;    YMODSRT, YMODEND                    used saved and restored              *
;    MODCON                              used saved and restored              *
;                                                                             *
;  Functions Called: fir                                                      *
;                                                                             *
;******************************************************************************
;  fir:                                                                       *
;  ======================                                                     *
;  Description: This function implements the FIR filtering operation.         *
;                                                                             *
;  Input:  w3  =  N (Number of Taps)                                          *
;          w8  =  Coefs Pointer                                               *
;          w10 = Delay Line Pointer                                           *
;                                                                             *
;  Output: w0 = fir output                                                    *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w3, w4, w5, w8, w10 used not restored                                *
;    AccA                    used not restored                                *
;                                                                             *
;  Functions Called: None                                                     *
;                                                                             *
;******************************************************************************
;  ButterWorth:                                                               *
;  ======================                                                     *
;  Description: This function implements the IIR filtering operation.         *
;                                                                             *
;  Input:  w0 =  Delay Line Pointer                                           *
;          w1 =  Coefs Pointer                                                *
;          w2 =  Input Sample                                                 *
;                                                                             *
;  Output: w0 = dl[2]                                                         *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w1, w2, w3, w4, w5, w6, w8, w10 used not restored                    *
;    AccA                                used not restored                    *
;                                                                             *
;  Functions Called: None                                                     *
;                                                                             *
;******************************************************************************
;  ClearHilbVars:                                                             *
;  ======================                                                     *
;  Description: This function clears Hilbert variables.                       *
;                                                                             *
;  Input:  void                                                               *
;                                                                             *
;  Output: void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w1                   used not restored                               *
;                                                                             *
;  Functions Called: ClearStruct                                              *
;                                                                             *
;******************************************************************************
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words : 5                                            *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitHilbert:               16                                           *
;     Hilbert:                   29                                           *
;     fir:                       08                                           *
;     ButterWorth:               19                                           *
;     ClearHilbVars:             10                                           *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     HilbCoefs                  32                                           *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;     .nbss:                     01                                           *
;     .bss:                      05                                           *
;     .ybss:                     32                                           *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitHilbert:               19                                           *
;     Hilbert:                   31                                           *
;     fir:                       2 + (N-3) + 7                                *
;     ButterWorth:               20                                           *
;     ClearHilbVars:             12                                           *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "filter.inc"
    .include "tables.inc"
    .include "modem.inc" 
    .include "defs.inc"
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _InitHilbert
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;   Description: :   This function initializes the following parameters
;                1.  It clears the Hilbert data structure
;                2.  It initializes the Hilbert delay line pointer for the 
;                    calculation of imaginary point
;                3.  It initializes the real pointer to get the sample which
;                    is pushed 15 samples earlier into the delay line       
; -----------------------------------------------------------------------------

_InitHilbert:

    push       CORCON
    push       PSVPAG    
    
    rcall      ClearHilbVars
    
    mov        #hilbDlyLine,w0
    mov        w0,hilbDlyPtr             ;delay pointer
    
    add        #((HILB_FILT_LEN*2)-1),w0 ;calculates the end address for the
                                         ;circular buffer
    mov        w0,hilbDlyEnd

    mov.b      #34, w0
    mov.b      wreg, hilbRealPtr

    mov        #psvpage(HilbCoefs), w8
    mov        w8, PSVPAG
    mov        #psvoffset(HilbCoefs), w8 ;w8 = filter coefficients

    mov        w8,hilbCoefPtr            ;hilbert coeff pointer
    pop        PSVPAG
    pop        CORCON
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _Hilbert
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function expects a sample value as the input and 
;               returns a complex sample. The real component is the sample
;               pushed into the delay line 15 samples earlier. The 
;               imaginary component is the rounded filter output. 
; -----------------------------------------------------------------------------
   
_Hilbert:

    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND

    clr        w4    
    mov        #hilbRealPtr,w5
    
    mov        #hilbDlyLine, w6
    mov.b      [w5],w4

    mov        #hilbOp_I, w5              
    mov        #HILB_FILT_LEN,w3       ;number of taps = 32

    inc2.b     hilbRealPtr
    mov        [w6+w4],[w5]

    mov        w0, w2                  ;input samples to the filter
    
    mov        #64, w0
    cp.b       hilbRealPtr
    bra        lt, FIR_INIT
    clr.b      hilbRealPtr

FIR_INIT:

;FIR FILTER INITIALIZATION

    mov        hilbDlyPtr,w10          ;delay line pointer in w10
    mov        hilbCoefPtr,w8          ;filter coefficients in w8
             
    clr        MODCON                  ;clears MODCON
    mov        #0x00a0, w4             ;set  YMD 
    mov        w4, MODCON              ;load the MODCON
    bset       MODCON, #14             ;enable Y Modulus Addressing 

    mov        #hilbDlyLine,w1    
    mov        hilbDlyEnd,w5           ;delay line end address        
    
    mov        w1,YMODSRT              ;initialize Y Modulus Start register 
    mov        w5,YMODEND              ;initialize Y Modulus End register    
 
    mov        w2, [w10]               ;Update delay line
    nop
    clr        A, [w10]+=2, w5         ;clear ACCA and prefetch X and Y data
    mov        w10,hilbDlyPtr

    rcall      _fir

    mov        w0, hilbOp_Q     
    
    pop        YMODEND
    pop        YMODSRT        
    pop        MODCON
    nop
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.endif

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _fir
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function implements the Finite Impulse Response filter.
;               FIR filters are mainly used in the receivers to reject the
;               out of band signal.
;               The complex FIR routine is implemented as shown below.
;               Op =    SUM    d(i) * c(i)
;                       i=0 to N-1                 
;               where, d(i) is the complex filter delay line element and 
;               c(i) is the complex filter coefficient.
;               The delay line and the coefficient pointers are passed as 
;               arguments to this function. The rounded complex output is 
;               returned to the calling function.
; -----------------------------------------------------------------------------

_fir:

    sub        w3, #3, w3
    clr        A, [w8]+=2, w4, [w10]+=2, w5       ;clear ACCA and prefetch 
                                                  ;X and Y data    
              
    repeat     w3                                ;repeat the next MAC operation
    mac        w4*w5, A, [w8]+=2, w4, [w10]+=2, w5         

    mac        w4*w5, A, [w8], w4, [w10], w5      ;perform second-to-last MAC
    mac        w4*w5, A                           ;perform last MAC
     
    sac.r      A, W0                             ;store to [w11] using unbiased
                                                 ;rounding     

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ButterWorth
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function implements the Infinite Impulse Response
;               Filtering
;               A common filter routine is implemented for both 2nd order
;               low pass and 1st order band pass filtering. The difference
;               equation that is evaluated is,
;               Y(n) = b0 x(n) + b1 x(n-1) + b2 x(n-2) + a1 y(n-1) + a2 y(n-2)
;               In the equation shown above there are five coefficients. In
;               most case the value of a1 is in the range 0 < a1 < abs(2). 
;               To maintain precision and to avoid scaling, it is stored in
;               2 locations for fixed-point implementations.
;               When greater than 1, it is coef[3] is initialized to 0x7fff
;               When this value is smaller than 1, coef[3] is set to 0. 
;               y(n-1) is convolved twice. Once with coef[3] and then with 
;               coef[4].The routine that implements this function is 
;               ButterWorth. The IIR filter routine has been named so, 
;               because, most filters have been designed using the 
;               Butterworth algorithm. The pointers to the coefficient and 
;               delay lines are passed as arguments to this function. After
;               filtering, this routine returns the rounded output.
; -----------------------------------------------------------------------------

_ButterWorth:

    mov        w0, w10                 ;Filter Delay Line pointer(Dl[])
    mov        w1, w8                  ;Coefficients pointer(Coefs[]) 
    mov        w2, w5                  ;Save input Sample

    clr        A, [w8]+=2, w4
    
 
    mpy        w4*w5, A, [w8]+=2, w4, [w10]+=2, w5 ;Coefs[0] * Sampl
    mac        w4*w5, A, [w8]+=2, w4, [w10]+=2, w5 ;Coefs[1] * Dl[0]
    mac        w4*w5, A, [w8]+=2, w4, [w10]+=2, w5 ;Coefs[2] * Dl[1]

    mov        [w0], w3 
    nop
    mov        w2, [w0]                ;Dl[0] = Sampl
    mov        w3, [w0+2]              ;Dl[1] = Dl[0]

    mac        w4*w5, A, [w8]+=2, w4         ;Coefs[3] * Dl[2]
    mac        w4*w5, A, [w8], w4, [w10], w5 ;Coefs[4] * Dl[2]
    mac        w4*w5, A                      ;Coefs[5] * Dl[3]

    mov        [w0+4], w5
    sac.r      A,  w6                        ;Scale the output

    mov        w5, [w0+6]                    ;Dl[3] = Dl[2] 
    mov        w6, [w0+4]                    ;Dl[2] = Output
    mov        w6, w0                        ;Return Filter output
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)

    .global ClearHilbVars
    .section  .libsm, "x"

ClearHilbVars:

    clr.b      hilbRealPtr 

    mov        #hilbOp_I,w0              ;pointer which delays the o/p by 15 
    mov        #SIZEOFHILB_YBSS_1,w1
    call       _ClearStruct              ;clears the structure members

    mov        #hilbDlyLine,w0           ;delay line
    mov        #SIZEOFHILB_YBSS,w1
    call       _ClearStruct

    return

.endif

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------
    
