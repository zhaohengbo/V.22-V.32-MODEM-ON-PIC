/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               PSF.S                                              *
;  Date:                   09th July,2002                                     *
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
; 0.1   09 July 2002           Code Created                         Rajiv     *
; 0.2   10 July 2002           Code Reviewed                        Raghava   *
; 0.3   09 August 2002         Modified file/function header        Rajiv     *
; 0.4   20 August 2002         Corrected code documentation faults  Rajiv     *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Pulse Shaping Filter(PSF)implementation for Microchip's dsPIC30F 16-bit MCU*
;  Description:   The pulse-shaping filter is implemented as a linear FIR     *
;                 filter. The primary purpose of a PSF is base band pulse     *
;                 smothering. The length of the PSF is an integral multiple   *
;                 of the interpolation factor. Interpolation is also          *
;                 implemented using the PSF. While the input to the PSF, is   *
;                 at symbol rate, the output is computed at the sampling rate.*
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;                                                                             *
;******************************************************************************
;  InitPsf                                                                    *
;  ======================                                                     *
;  Description: This function initializes the parameters for PSF.             *
;  ======================                                                     *
;  Input:                                                                     *
;        w0 = IPFACTOR                                                        *
;        w1 = Coefficients Address                                            *
;        w2 = PSF Length                                                      *
;        w3 = Delay Length                                                    *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,w5,w6       used not restored                             *
;                                                                             *
;  Functions Called:   ClearPsfVars                                           *
;                                                                             *
;******************************************************************************
;  UpdatePsf                                                                  *
;  ======================                                                     *
;  Description: The PSF delay line is updated with the encoded symbols        *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w1,w2,w3,w4,w6       used not restored                                   *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  Psf                                                                        *
;  ======================                                                     *
;  Description: This function implements a linear FIR filter for performing   *
;               pulse shaping                                                 *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2,w3,w4,w6,w8,w10       used not restored                          *
;   Acc A, Acc B                   used not restored                          *
;   YMODSRT, YMODEND               used not restored                          *
;   MODCON                         used saved and restored                    *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  ClearPsfVars                                                               *
;  ======================                                                     *
;  Description: This function clears PSF variables                            *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1                          used not restored                          *
;                                                                             *
;  Functions Called:   ClearStruct                                            *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   3                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitPsf:     10                                                         *
;     UpdatePsf:   24                                                         *
;     Psf:         45                                                         *
;     ClearPsfVars:11                                                         *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     V32PsfCoefs: 24                                                         *
;     V22PsfCoefs: 48                                                         *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;     .bss:        10                                                         *
;     .ybss:       16                                                         *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitPsf:     12                                                         *
;     UpdatePsf:   26                                                         *
;     Psf:         66                                                         *
;     ClearPsfVars:13                                                         *
;                                                                             *
;*****************************************************************************/


; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "psf.inc"
    .include "defs.inc"
    .include "modem.inc"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _InitPsf
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function initializes the following parameters for
;                 pulse shaping filter.
;              1.  Clears the PSF data structure
;              2.  PSF Delay line pointer is initialized
;              3.  Filter coefficient pointer is initialized
;              4.  PSFIpFactor is initialized for interpolation
; -----------------------------------------------------------------------------

_InitPsf:

    mov        w0, w4                  ;Save IPFACTOR
    mov        w1, w5                  ;Save Coeff address
    mov        w2, w6                  ;Save PSF length

    rcall      ClearPsfVars

    mov        w6, PSFLen              ;Initialize the global variables of PSF
    mov        w4, PSFIpFactor
    mov        w5, PSFCoefAddress
    mov        w3, PSFDlyLen
    
    return                             ;Return after initializing PSF params

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global    _UpdatePsf  
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:  This function is called every baud. It updates the PSF delay 
;                line(PSFDlyI and PSFDlyQ) with encoded symbols(Real and 
;                Imaginary components of base band signal).PSFCoefPtr is reset
;                to PSFCoefAddress.
; -----------------------------------------------------------------------------

_UpdatePsf:

    mov        #PSFDlyIndex, w2
    mov        PSFCoefAddress, w3
    mov        w3, PSFCoefPtr          ;Update the Coefficients Address

    mov        [w2], w1                ;Get the Delay index
    mov        PSFIpI, w4
    mov        #mdmFilterBuffer, w3
    mov        #PSFDlyI, w6
    add        w6, w3, w6
    sl         w1,#1, w3
    add        w6, w3, w6
    mov        w4, [w6]                ;Place PSF I input on to delay line 

    mov        PSFIpQ, w4
    mov        #mdmFilterBuffer, w12 
    mov        #PSFDlyQ, w6
    add        w6, w12, w6
    add        w6, w3, w6
    mov        w4, [w6]                ;Place PSF Q input on to delay line 

    dec        w1, w1
    mov        w1, [w2]                ;update the delay index
    cp0        w1                      ;check delay index for negative
    bra        ge, NO_PSFBUF_OF
    mov        PSFDlyLen, w3
    dec        w3, [w2]                ;if negative, Update delay index

NO_PSFBUF_OF: 
    return                             ;return after placing input into delay
                                       ;line
 
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _Psf
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:  This function performs the FIR convolution. Both real and 
;                imaginary components are computed and stored in PSFOpI and 
;                PSFOpQ.
; -----------------------------------------------------------------------------

_Psf:

    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND
    
    mov        PSFDlyIndex, w2
    add        #1, w2                  ;Counter for Taps
    mov        PSFDlyLen, w3
    cp         w2, w3                  ;Check if count exceeds delay length
    bra        lt, PSF_FILTER
    mov        #0, w2                  ;Reset the count

PSF_FILTER:

    clr        MODCON                  ;Clear MODCON status
    mov        #mdmFilterBuffer, w6
    mov        #PSFDlyI, w10
    add        w10, w6, w10
    mov        w10, YMODSRT            ;Load start address of delay I buffer

    sl         w3, #1,w3
    dec        w3, w6

    add        w10, w6, w4
    mov        w4, YMODEND             ;load the end address
    mov        #0x00A0, w0             ;set YMD  
    mov        w0, MODCON              ;load the MODCON
    bset       MODCON, #14             ;enable Y Modulus Addressing

    sl         w2, #1, w2
    mov        PSFCoefPtr, w8          ;Get the address of coeff buffer
    add        w2, w10, w10            ;Move delay I for offset count
    mov        PSFDlyLen, w3
    dec2       w3, w3
;Clear acc A and prefetch I and coeff 
    clr        a, [w8]+=2, w4,[w10]+=2, w5

    repeat     w3                      ;Loop over the count value
    mac        w4*w5, A, [w8]+=2, w4, [w10]+=2, w5  
    mac        w4*w5, A                ;Filter implementation
    mov        #mdmFilterBuffer, w8
    mov        #PSFDlyQ, w10           ;load start address of delay Q buffer
    add        w10, w8, w10
    mov        w10, YMODSRT               
    add        w10, w6, w5
    add        w2, w10, w10            ;Move delay Q for offset count
    mov        PSFCoefPtr, w8          ;Get the address of coeff buffer
    mov        w5, YMODEND             ;load the end address of delay Q buffer
;Clear acc B and prefetch Q and coeff 
    clr        b, [w8]+=2, w4, [w10]+=2, w5

    repeat     w3 
    mac        w4*w5, B, [w8]+=2,w4, [w10]+=2,w5 
    mac        w4*w5, B                ;Filter implementation                
    mov        w8, PSFCoefPtr          ;Update coeff buffer
    mov        #PSFOpI, w0
    mov        #PSFOpQ, w1
    sac.r      a, [w0]                 ;store the PSF outputs
    sac.r      b, [w1]

    pop        YMODEND
    pop        YMODSRT
    pop        MODCON                  ;Retrieve MODCON status
    nop
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global ClearPsfVars
    .section  .libsm, "x"

ClearPsfVars:

    mov        #PSFIpFactor, w0        ;Pass the struct start address   
    mov        #SIZEOFPSF_BSS, w1      ;Length of psf struct
    call       _ClearStruct

    mov        #mdmFilterBuffer, w1
    mov        #PSFDlyI, w0            ;Pass the delay buffer address   
    add        w0, w1, w0
    mov        #SIZEOFPSF_YBSS, w1     ;Length of I AND Q buffers
    call       _ClearStruct

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.endif

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------
