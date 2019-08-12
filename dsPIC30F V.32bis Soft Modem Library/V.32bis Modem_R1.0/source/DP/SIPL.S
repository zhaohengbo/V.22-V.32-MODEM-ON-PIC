/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               SIPL.S                                             *
;  Date:                   21st July,2002                                     *
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
; 0.1   21 July 2002           Code Created                         Rajiv     *
; 0.2   22 July 2002           Code Reviewed                        Raghava   *
; 0.3   09 August 2002         Modified file/function header        Rajiv     *
; 0.4   23 August 2002         Corrected code documentation faults  Rajiv     *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Software interpolation(SIPL)implementation for Microchip's dsPIC30F        *
;  16-bit MCU                                                                 *
;  Description:    Software interpolation is the process of changing the      *
;                  sampling phase of received signal according to the         *
;                  estimated clock phase offset. When there is a drift        *
;                  in the clock phase, it needs to be tracked.                *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;                                                                             *
;******************************************************************************
;  InitSipl                                                                   *
;  ======================                                                     *
;  Description: This function initializes the parameters for software         *
;               interpolator.                                                 *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w2,w3,w4        used not restored                                     *
;                                                                             *
;  Functions Called:   Load_Sipl_Filter                                       *
;                                                                             *
;******************************************************************************
;  Load_Sipl_Filter                                                           *
;  ======================                                                     *
;  Description: This function loads the 20 coefficients corresponding         *
;               to the phase adjustment value.                                *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,w6,w8,w9,w10,w11,w13   used not restored                  *
;    PSVPAG, CORCON                        used saved and restored            *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  SIPL                                                                       *
;  ======================                                                     *
;  Description: This function implements a FIR filter for performing          *
;               Software interpolation                                        *
;  ======================                                                     *
;  Input:                                                                     *
;        w0 = sipl_input                                                      *
;        w1 = sipl_phase_adj                                                  *
;  Output:                                                                    *
;        w0 = ops_cntr(no of outputs)                                         *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2,w3,w4,w5,w7,w8,w9,w10,w12,w14   used not restored                *
;   Acc A                                    used not restored                *
;   YMODSRT, YMODEND                         used saved and restored          *
;   MODCON                                   used saved and restored          *
;  Functions Called:   Load_Sipl_Filter, fir                                  *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :    6                                         *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitSipl:            13                                                 *
;     Load_Sipl_Filter:    65                                                 *
;     SIPL:                62                                                 *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     SiplDiffCoefs:       352                                                *
;     SiplMainCoefs:       352                                                *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;     .bss                 05                                                 *
;     .xbss:               20                                                 *
;     .ybss:               20                                                 *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitSipl :           34                                                 *
;     Load_Sipl_Filter :   187                                                *
;     SIPL:                60                                                 *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

.include "sipl.inc"
.include "tables.inc"
.include "defs.inc"
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _InitSIPL
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function initializes the parameters for Software 
;                 Interpolator. It loads the 20 coefficients corresponding 
;                 to the phaseadjustment value of 256 (Load_Sipl_Filter).
; -----------------------------------------------------------------------------

_InitSIPL:

    mov        #256, w0
    mov        #(SIPL_LENGTH*2)-1, w3  ; Offset to calculate End address
    mov        #mdmFilterBuffer, w4
    mov        #SIPLDlyLine, w2        ; Get the Delay Line address
    add        w2, w4, w2
    add        w2, w3, w4              ; End address of the delay buffer
    
    mov        w0, SIPLPrevPhase
    mov        w4, SIPLDlyEnd          ; Store the End address
    mov        w2, SIPLDlyPtr          ; Initialize a pointer to delay line

    repeat     #(SIPL_LENGTH-1)        ; Repeat till length of the buffer

    clr        [w2++]                  ; Initialize with zero

    rcall      _Load_Sipl_Filter       ; Load the filter coefficients

    return                     

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _Load_Sipl_Filter
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function takes received sample and phase adjustment as 
;                 the input and generates 0 or 1 or 2 outputs based on the 
;                 phase adjustment value.
; -----------------------------------------------------------------------------

_Load_Sipl_Filter:

    push       PSVPAG
    mov        SIPLPrevPhase, w0
    and        w0, #15, w4                 
    asr        w0, #4, w3         
    mov        w3, w0              
    mov        #0, w2
    mov        #8, w1
    cp         w4, w1
    bra        le, NO_UPDATE_INDEX

    mov        #16, w1
    sub        w1, w4, w4          
    inc        w3, w3              
    mov        #1, w2
          
NO_UPDATE_INDEX:
    mov        #psvpage(SiplDiffCoefs), w1   
    mov        w1, PSVPAG              ;get sipldiff table coeffs in program 
                                       ;memory
; point w8 to sipldiff coeffs                                       
    mov        #psvoffset(SiplDiffCoefs), w8
   
    sl         w0, #1, w1
    add        w8, w1, w8              ;calculate the address with offset
; get siplMain table coeffs in program memory
    mov        #psvpage(SiplMainCoefs), w1  
    mov        w1, PSVPAG        
; point w10 to siplMain coeffs    
    mov        #psvoffset(SiplMainCoefs), w10
   
    sl         w3, #1, w1
    add        w10, w1, w10            ;calculate the address with offset

    mov        #38, w11
    mov        #SIPLCoefBuf, w13
    add        w13,w11,w11             ;point to the last element
    
    do         #8, UPD_COEFS           ;Update the coeffs
    mov        [w8], w5
    mov        [w10], w6
    mpy        w4*w5, A
    sftac      A, #6
    mov        0x22, w5
    cp0        w2                      ;check the flag, if 0  
    bra        z, TO_ADD 
    sub        w6, w5, w5
    goto       STORE_OUT
    
TO_ADD:
    add        w6, w5, w5
STORE_OUT:     

    mov        w5, [w13++]             ;store the coeffs  
    mov        w5, [w11--]             ;store from the last element, since 
    mov        #64, w9                 ;symmetric
    add        w8, w9, w8              ;Update the address by 32

UPD_COEFS:
    add        w10, w9, w10                
   
    do         #1, UPD_NEXTCOEFS       ;Get the 9th and 10th coeff
    mov        [w8], w5
    mov        [w10], w6
    mpy        w4*w5, A
    sftac      A, #6
 
    mov        0x22, w5   
    cp0        w2                      ;check if positive
    bra        z, TO_ADD1 
    sub        w6, w5, w5
    goto       STORE_OUT1
    
TO_ADD1:
    add        w6, w5, w5
STORE_OUT1:     
    
    mov        w5, [w11--]             ;store the coeff
    add        w8,  w9, w8             ;update each time by 32

UPD_NEXTCOEFS:
    add        w10, w9, w10
    pop        PSVPAG
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SIPL
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function takes received sample and phase adjustment as 
;                 the input and generates 0 or 1 or 2 outputs based on the 
;                 phase adjustment value.          
; -----------------------------------------------------------------------------

_SIPL:

    mov        #SIPLOutput, w14
    mov        SIPLDlyPtr,w10          ;delay line pointer in w10
    mov        #SIPLCoefBuf,w8         ;filter coefficients in w8

    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND
    
    mov        SIPLDlyEnd,w5           ;delay line end address        
    clr        MODCON                  ;clears MODCON
    mov        #0x00a0, w4             ;set  YMD 
    mov        w4, MODCON              ;load the MODCON
    bset       MODCON, #14             ;enable Y Modulus Addressing 

    mov        #mdmFilterBuffer, w7
    mov        #SIPLDlyLine,w4    
    add        w4, w7, w4    
    mov        w4,YMODSRT              ;initialize Y Modulus Start register 
    mov        w5,YMODEND              ;initialize Y Modulus End register    

    mov        w0, [w10]               ;Place input on the delay line
    nop
    clr        A, [w10]+=2, w5         ;clear ACCA and update delay    
    mov        w10, SIPLDlyPtr
    mov        #0, w12                 ;counter to count no of outputs
    mov        #0, w7                  ;flag to indicate no output

    cp0        w1                      ;Check Phase_adjustment for zero
    bra        z, TO_FIR

    mov        SIPLPrevPhase, w4
    add        w1, w4, w4              ;update Phase_adjustment

    cp0        w1                      ;Check Phase_adjustment if positive
    bra        le,  TO_CHK_NEGATIVE

    mov        #NFM1, w3

    cp         w4, w3                              
    bra        lt, TO_LOADSIPL
    
    mov        #1, w7                  ;make ouputflag one
    sub        w4,w3,w4
    bra        TO_LOADSIPL
           
TO_CHK_NEGATIVE:

    cp0        w4                      ;Check Phase_adjustment if negative
    bra        ge,  TO_LOADSIPL

    mov        #IPF, w0
    add        w4, w0, w4              ;update Phase_adjustment

    mov        SIPLDlyPtr, w2
    add        #18, w2
    
    mov        SIPLDlyEnd, w1
    cp         w2, w1                  ;check for overflow of address
    bra        lt, UPD_CNTR
    mov        #(SIPL_LENGTH*2), w9
    sub        w2, w9, w2              ;reset the delay address

UPD_CNTR:
    
    inc        w12, w12                ;Increment the output counter
    mov        [w2], [w14++]           ;one ouput is being stored

TO_LOADSIPL:

    mov        w4, SIPLPrevPhase
    push       w8                    
    push       w10
    
    rcall      _Load_Sipl_Filter       ;Load the coeff buffer with new coeffs

    pop        w10
    pop        w8
TO_FIR:

    cp0        w7                      ;check for no output flag
    bra        nz, TOEND_SIPL

    mov        #SIPL_LENGTH, w3        ;Pass the filter length to fir
    call       _fir
    mov        w0, [w14++]             ;store the filtered output
    inc        w12, w12                ;Increment the output counter

TOEND_SIPL:

    mov        w12, w0                 ;Return the no of outputs
    pop        YMODEND
    pop        YMODSRT
    pop        MODCON
    nop
    return
    
; -----------------------------------------------------------------------------
;   END OF FILE
; -----------------------------------------------------------------------------
    
