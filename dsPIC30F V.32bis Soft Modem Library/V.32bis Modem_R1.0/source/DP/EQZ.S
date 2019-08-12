/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               EQZ.S                                              *
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
; 0.1   17 July   2002   Code Created                                Ravi     *
; 0.2   18 July   2002   Code Reviewed                               Raghava  *
; 0.3   12 August 2002   Modified file/function header               Ravi     *
; 0.4   20 August 2002   Corrected code documentation faults         Ravi     *
; 0.4   18 Sept   2003   MSE estimation of V.32bis is added          Raghava  * 
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Equalizer implementation for Microchip's dsPIC30F 16-bit MCU.              *
;  Description: This module is an implementation of fractionally spaced       *
;               equalizer employed in all the receivers except in V23         *
;               receiver. The complex equalizer taps are updated using LMS    *
;               algorithms. Every baud, the equalizer generates an output     *
;               and this output is used in the slicer.  The difference        *
;               between demodulated point and the decision point serves as    *
;               the error for updating the equalizer taps.                    *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;                                                                             *
;  InitEqz:                                                                   *
;  ======================                                                     *
;  Description: This function initializes the parameters for equalizer.       *
;                                                                             *
;  Input:  w0 = eqzSpan                                                       *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w4 used not restored                                              *
;                                                                             *
;  Functions Called:  ClearEqzVars                                            *
;                                                                             *
;******************************************************************************
;  UpdateEqz:                                                                 *
;  ======================                                                     *
;  Description: This function is used to update the equalizer delay line.     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w1, w2, w3, w4, w5 used not restored                                 *
;                                                                             *
;  Functions Called: None                                                     *
;                                                                             *
;******************************************************************************
;  ClearEqz:                                                                  *
;  ======================                                                     *
;  Description: This function is used to clear equalizer filter coefficients. *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w1, w3, w4, w5 used not restored                                     *
;                                                                             *
;  Functions Called: None                                                     *
;                                                                             *
;******************************************************************************
;  Equalize:                                                                  *
;  ======================                                                     *
;  Description: This function performs the equalizer filtering operation.     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11 used not restored       *
;    AccA, AccB                                       used not restored       *
;    YMODSRT, YMODEND                                 used not restored       *
;    MODCON                                           used saved and restored *
;                                                                             *
;  Functions Called: None                                                     *
;******************************************************************************
;  AdaptEqz:                                                                  *
;  ======================                                                     *
;  Description: This function updates the equalizer taps by using adaptive    *
;               algorithm.                                                    *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;  w0, w1, w2, w3, w4, w5, w6, w7, w8, w9,                                    *
;  w10, w11, w12, w13    used not restored                                    *
;  AccA, AccB            used not restored                                    *
;  YMODSRT, YMODEND      used not restored                                    *
;  MODCON                used saved and restored                              *
;                                                                             *
;  Functions Called: None                                                     *
;******************************************************************************
;  FindEqzError:                                                              *
;  ======================                                                     *
;  Description: This function used to find the instantaneous baseband &       *
;               passband error.                                               *
;                                                                             *
;  Input:  w0 = angle                                                         *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w4, w5, w6, w7, w8, w9 used not restored                          *
;   AccA                           used not restored                          *
;                                                                             *
;  Functions Called: SinCos                                                   *
;******************************************************************************
;                                                                             *
;  EstimateMSE:                                                               *
;  ======================                                                     *
;  Description: This function is used to get a measure of the SNR on the line *
;               during training for V22bis.                                   *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w4, w5, w6, w7, w8 used not restored                              *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  EstimateV32MSE:                                                            *
;  ======================                                                     *
;  Description: This function is used to get a measure of the SNR on the line *
;               during training for V32bis.                                   *
;                                                                             *
;  Input:  abs(EqzBBErrorI)                                                   *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w4, w5, w6, w7 used not restored                                  *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  FindMainTap:                                                               *
;  ======================                                                     *
;  Description: It calculates the position of the main tap of the equalizer.  *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w3, w4, w5, w8, w9, w10, w12 used not restored                *
;   AccA, AccB                               used not restored                *
;                                                                             *
;  Functions Called: None                                                     *
;                                                                             *
;******************************************************************************
;  AdjustEqz:                                                                 *
;  ======================                                                     *
;  Description: This function calculates the desired offset in terms of bauds *
;               from the center of the equalizer.                             *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: w0 = Abs(j)                                                        *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2 used not restored                                              *
;                                                                             *
;  Functions Called: FindMainTap, ClearEqz                                    *
;                                                                             *
;******************************************************************************
;  GetMidTapEnergy:                                                           *
;  ======================                                                     *
;  Description: This function gives the difference in the absolute values of  *
;               taps on either sides of the main tap of the equalizer filter. *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: w0 = Round(ans)                                                    *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w3, w4, w5 used not restored                                      *
;   AccA, AccB         used not restored                                      *
;                                                                             *
;  Functions Called: None                                                     *
;******************************************************************************
;  InitFlock:                                                                 *
;  ======================                                                     *
;  Description: This function initializes the parameters for equalizer based  *
;               clock recovery.                                               *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0 used not restored                                                      *
;                                                                             *
;  Functions Called: FindMainTap, GetMidTapEnergy                             *
;******************************************************************************
;  Flock:                                                                     *
;  ======================                                                     *
;  Description: This function computes the Clock phase drift by finding the   *
;               drift in the Current mid tap energy from the reference tap    *
;               energy.                                                       *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w4, w5 used not restored                                      *
;   AccA               used not restored                                      *
;                                                                             *
;  Functions Called: GetMidTapEnergy                                          *
;                                                                             *
;******************************************************************************
;  ClearEqzVars:                                                              *
;  ======================                                                     *
;  Description: This function clears Equalizer variables.                     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1             used not restored                                      *
;                                                                             *
;  Functions Called: ClearStruct                                              *
;                                                                             *
;******************************************************************************
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words : 14                                           *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitEqz:                   08                                           *
;     UpdateEqz:                 15                                           *
;     ClearEqz:                  13                                           *
;     Equalize:                  47                                           *
;     V22Equalize:               61                                           *
;     AdaptEqz:                  53                                           *
;     V22AdaptEqz:               81                                           *
;     FindEqzError:              25                                           *
;     EstimateMSE:               16                                           *
;     EstimateV32MSE             22                                           *
;     FindMainTap:               26                                           *
;     AdjustEqz:                 14                                           *
;     GetMidTapEnergy:           17                                           *
;     InitFlock:                 10                                           *
;     Flock:                     16                                           *
;     ClearEqzVars:              17                                           *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;     .nbss:                     03                                           *
;     .bss:                      13                                           *
;     .xbss:                     128                                          *
;     .ybss:                     128                                          *
;                                                                             *
;  Module Instruction Cycle Count (N = Number of Taps)                        *
;     InitEqz:                   12                                           *
;     UpdateEqz:                 17                                           *
;     ClearEqz:                  8 + (3*N)                                    *
;     Equalize:                  2N + 49                                      *
;     V22Equalize:               4N + 54                                      *
;     AdaptEqz:                  7N + 46                                      *
;     V22AdaptEqz:               12N + 57                                     *
;     FindEqzError:              27                                           *
;     EstimateMSE:               17                                           *
;     EstimateV32MSE:            24                                           *
;     FindMainTap:               12N + 3                                      *
;     AdjustEqz:                 17                                           *
;     GetMidTapEnergy:           18                                           *
;     InitFlock:                 13                                           *
;     Flock:                     16                                           *
;     ClearEqzVars:              19                                           *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "eqz.inc"
    .include "modem.inc"
    .include "defs.inc"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)
        
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _InitEqz     
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: 1.  This functions clears all the parameters in Eqz Struct
;               2.  The hilbert filter is initialized by executing, 
;                   InitHilbert.
;               3.  The equalizer filter length is initialized.
;               4.  The FlockParams are initialized to their reset values.
;                   FlockStatus = 0
;                   FlockBaudCnt = 1
;               5.  Eqz MSE is initialized to maximum value.
; -----------------------------------------------------------------------------
    
_InitEqz:  

    push       w0
    rcall      ClearEqzVars
    pop        w0      

    mov.b      wreg, eqzSpan             ;Store Equalizer length and division
    
    mov        #1, w0                  ;Initialize equalizer counters for
    mov.b      wreg, eqzCntr           ;used for updation interval
    mov.b      wreg, eqzCntrSet                              
    
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
  
    .global _UpdateEqz
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to write the latest complex 
;               demodulated vector into the delay lines. After updating
;               the equalizer imaginary and real delay lines with the input
;               sample, the EqzDelayLinePtr is incremented by 1 [circular 
;               increment], So that they are pointing to the oldest entries
; -----------------------------------------------------------------------------
    
_UpdateEqz:
    mov        #eqzDlyI,w1
    mov        #eqzDlyQ,w5
    mov        eqzDlyPtr, w2
    
    mov        eqzIpI, w3
    mov        w3, [w1+w2]
    
    mov        eqzIpQ, w4
    mov        w4, [w5+w2]
    
    clr        w0
    sl.b       eqzSpan,wreg
    
    inc2       w2, w1
    
    cp        w1,w0
    bra       nz,EXIT_UPDATE_EQZ

    clr        w1

EXIT_UPDATE_EQZ:

    mov        w1, eqzDlyPtr 
    return       

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ClearEqz
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function clears the complex, equalizer coefficient
;               buffers using the respective coefficient pointers
; -----------------------------------------------------------------------------
    
_ClearEqz:

    clr        w0
    clr        w1
    mov.b      eqzSpan, wreg
    sub        w0, #1, w0

    mov        #eqzCoefsI, w3
    mov        #eqzCoefsQ, w4
    mov        #0, w5
    
    do         w0, CLEAR_EQZ_COEFS
    mov        w5, [w3+w1]
    mov        w5, [w4+w1]

CLEAR_EQZ_COEFS:
    inc2       w1,w1        

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    .global _Equalize
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function performs the complex FIR convolution
;               and stores the    complex output in EqzOpI and EqzOpQ.
; -----------------------------------------------------------------------------
    
_Equalize:
 
    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND
    
    mov        eqzDlyPtr, w2           ;w2 = stp = eqzDlyPtr
  
    mov        #eqzCoefsI, w8          ;w8 = cptrr
    
    mov        #eqzDlyI, w11           ;start address      
    mov        w11, YMODSRT            ;initialize Y Modulus Start register 

    clr        w0
    mov.b      eqzSpan,wreg
    sl         w0,w0
    dec        w0,w0

    add        w11, w0, w1
    mov        w1, YMODEND             ;initialize Y Modulus End register
    
    add        w11, w2, w6
    mov        w6, w10
     
    mov        #0x00A0, w5             ;set XMD = W8 and YMOD = W10
    mov        w5, MODCON              ;load the MODCON
    bset       MODCON, #14             ;enable Y Modulus Addressing 
 
    mov        #eqzSpan,w4
    clr        w3
    mov.b      [w4],w3
    dec2       w3,w3
    
    clr        A, [w8]+=2, w4, [w10]+=2, w5
 
    repeat     w3
    mac        w4*w5, A, [w8]+=2, w4, [w10]+=2, w5
    mac        w4*w5, A
    
    mov        #eqzCoefsQ, w8      ;w8 = cptri
    mov        w6, w10
    
    clr        B, [w8]+=2, w4, [w10]+=2, w5
 
    repeat     w3
    mac        w4*w5, B, [w8]+=2, w4, [w10]+=2, w5
    mac        w4*w5, B
    
    mov        ACCAH, w3
    mov        ACCAL, w2
    
    sub        A
    sac.r      A, w0
    
    mov        w3, ACCAH
    mov        w2, ACCAL
    
    add        A
    sac.r      A, w1
    
    mov        w0, eqzOpI 
    mov        w1, eqzOpQ

    pop        YMODEND
    nop
    pop        YMODSRT
    nop
    pop        MODCON 
    nop
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V22Equalize
    .section  .libsm, "x"
; -----------------------------------------------------------------------------
;  Description: This function performs the complex FIR convolution
;               and stores the complex output in EqzOpI and EqzOpQ for V22 Mode.
; -----------------------------------------------------------------------------
   
_V22Equalize:

     push       MODCON                  ;Save the status of MODCON
     push       YMODSRT                 ;Save context of YMODSRT
     push       YMODEND                 ;Save context of YMODEND
     
     mov        eqzDlyPtr, w2           ;w2 = stp = eqzDlyPtr
   
     mov        #eqzCoefsI, w8          ;w8 = cptrr
     
     mov        #eqzDlyI, w11           ;start address      
     mov        w11, YMODSRT            ;initialize Y Modulus Start register 
 
     clr        w0
     mov.b      eqzSpan,wreg
     sl         w0,w0
     dec        w0,w0
 
     add        w11, w0, w1
     mov        w1, YMODEND             ;initialize Y Modulus End register
     
     add        w11, w2, w6
     mov        w6, w10
      
     mov        #0x00A0, w5             ;set XMD = W8 and YMOD = W10
     mov        w5, MODCON              ;load the MODCON
     bset       MODCON, #14             ;enable Y Modulus Addressing 
  
     mov        #eqzSpan,w4
     clr        w3
     mov.b      [w4],w3
     dec2       w3,w3
     
     clr        A, [w8]+=2, w4, [w10]+=2, w5 ;cfiropi = 0
    
     repeat     w3
     mac        w4*w5, A, [w8]+=2, w4, [w10]+=2, w5    ;cptrr[i] * dptrr[i]
     mac        w4*w5, A 
     
     mov        #eqzCoefsQ, w9      ;w8 = cptri
    
     mov        #eqzDlyQ, w10       ;get delay data start address
     mov        w10, YMODSRT        ;initialize Y Modulus Start register 
 
     add        w10, w0, w5
     mov        w5, YMODEND         ;initialize Y Modulus End register
 
     add        w10, w2, w7    
     mov        w7,w10
     
     clr        B, [w9]+=2, w4, [w10]+=2, w5    
     
     repeat     w3
     mac        w4*w5, B, [w9]+=2, w4, [w10]+=2, w5    ;;cptri[i] * dptri[i]
     mac        w4*w5, B
 
     sub        A                   
     
     sac.r      A,w4
     mov        w4,eqzOpI 
 
     mov        #eqzCoefsI, w8      ;w8 = cptrr
     mov        w7,w10
         
     clr        A, [w8]+=2, w4, [w10]+=2, w5 ;cptrr[i] * dptri[i]
     
     repeat     w3
     mac        w4*w5, A, [w8]+=2, w4, [w10]+=2, w5
     mac        w4*w5, A
     
     mov        #eqzCoefsQ, w9      ;w8 = cptrr
 
     mov        w11, YMODSRT
     mov        w1, YMODEND
     mov        w6, w10
     
     clr        B, [w9]+=2, w4, [w10]+=2, w5
     
     repeat     w3
     mac        w4*w5, B, [w9]+=2, w4, [w10]+=2, w5
     mac        w4*w5, B
 
     add        A
     sac.r      A, w4
     mov        w4,eqzOpQ
 
     pop        YMODEND
     nop
     pop        YMODSRT
     nop
     pop        MODCON 
     return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
 

    .global _AdaptEqz
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function updates the equalizer taps by using the 
;               adaptive algorithm (LMS).The Estimated error is scaled
;               by the Equalizer step size before giving it to the LMS.
; -----------------------------------------------------------------------------

_AdaptEqz:

    mov.b      eqzCntr, wreg
    dec.b      w0, w0
    bra        le, CALC_EQZ_ERROR
    return

CALC_EQZ_ERROR:

    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND
    
    mov.b      eqzCntrSet, wreg
    mov.b      wreg, eqzCntr    
    
    mov        eqzStepSize, w7
    
    mov        eqzErrorI, w5
    mpy        w5*w7, A
    sac.r      A, w4                   ;errr
  
    mov        eqzErrorQ, w6
    mpy        w6*w7, B
    sac.r      B, w6                   ;erri
    
    sub        w6, w4, w5              ;erri-errr
    add        w6, w4, w4              ;w4=E1=erri+errr
    mov        w5, w6                  ;w6=E2
            
    mov        eqzDlyPtr, w2           ;w2 = stp = eqzDlyPtr
    mov        #eqzCoefsI, w8          ;w8 = cptrr
    mov        #eqzCoefsQ, w9
    mov        #eqzDlyI, w11           ;start address      
    mov        w11, YMODSRT            ;initialize Y Modulus Start register 
 
    clr        w0
    mov.b      eqzSpan,wreg
    sl         w0,w0
    dec        w0,w0
    
    add        w11, w0, w1
    mov        w1, YMODEND             ;initialize Y Modulus End register
    
    add        w11, w2, w10

    mov        #0x00A0, w5             ;set XMD = W8 and YMOD = W10
    mov        w5, MODCON              ;load the MODCON
    bset       MODCON, #14             ;enable Y Modulus Addressing 
  
    mov        #eqzSpan,w7
    clr        w3
    mov.b      [w7],w3
    dec        w3,w3
 
    clr        A, [w10]+=2, w5   
    
    do         w3, LMS_S1
    mpy        w4*w5, A, [w8], w7;, [w10]+=2, w5    ;cptrr[i] -= E1 * Ipsample
    sac.r      A, w12
    sub        w7, w12, [w8++]
    
    mpy        w5*w6, A, [w9], w7, [w10]+=2, w5
    sac.r      A, w12
    sub        w7, w12, [w9++]
LMS_S1: 
    nop
       
    pop        YMODEND
    nop
    pop        YMODSRT
    nop
    pop        MODCON
    nop
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------


    .global _V22AdaptEqz
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function updates the equalizer taps by using the 
;               adaptive algorithm (LMS).The Estimated error is scaled
;               by the Equalizer step size before giving it to the LMS for V22.
; -----------------------------------------------------------------------------

_V22AdaptEqz:

    mov.b      eqzCntr, wreg
    dec.b      w0, w0
    bra        le, CALC_EQZ_ERROR1
    return

CALC_EQZ_ERROR1:

    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND
    
    mov.b      eqzCntrSet, wreg
    mov.b      wreg, eqzCntr    
    
    mov        eqzStepSize, w7
    
    mov        eqzErrorI, w5
    mpy        w5*w7, A
    sac.r      A, w4                   ;errr
  
    mov        eqzErrorQ, w6
    mpy        w6*w7, B
    sac.r      B, w6                   ;erri
            
    mov        eqzDlyPtr, w2           ;w2 = stp = eqzDlyPtr
    mov        #eqzCoefsI, w8          ;w8 = cptrr
    
    mov        #eqzDlyI, w11           ;start address      
    mov        w11, YMODSRT            ;initialize Y Modulus Start register 
    
    clr        w0
    mov.b      eqzSpan,wreg
    sl         w0,w0
    dec        w0,w0
    
    add        w11, w0, w1
    mov        w1, YMODEND             ;initialize Y Modulus End register
    
    add        w11, w2, w10
    push       w10

    mov        #0x00A0, w5             ;set XMD = W8 and YMOD = W10
    mov        w5, MODCON              ;load the MODCON
    bset       MODCON, #14             ;enable Y Modulus Addressing 
   
    mov        #eqzSpan,w7
    clr        w3
    mov.b      [w7],w3
    dec        w3,w3
    
    clr        A, [w8], w7, [w10]+=2, w5 ;cfiropi = 0
   
    do         w3, LMS_S11
    mpy        w4*w5, A, [w8], w7, [w10]+=2, w5    ;cptrr[i] -= errr * dptrr[i]
    sac.r      A, w12
LMS_S11: 
    sub        w7, w12, [w8++]    
    
    mov        #eqzCoefsI, w8

    mov        #eqzDlyQ, w10           ;get delay data start address
    mov        w10, YMODSRT            ;initialize Y Modulus Start register 

    add        w10, w0, w5
    mov        w5, YMODEND             ;initialize Y Modulus End register

    add        w10, w2, w13    
    mov        w13,w10
    
    clr        B, [w8], w7, [w10]+=2, w5
          
    do         w3, LMS_S2
    mpy        w5*w6, B, [w8], w7,[w10]+=2, w5 ;cptrr[i] -= erri * dptri[i]
    sac.r      B, w12
;LMS_S2: 
    sub        w7, w12, [w8++]
LMS_S2:nop     
    mov        #eqzCoefsQ, w9          ;w8 = cptrr  

    mov        w11, YMODSRT            ;initialize Y Modulus Start register 

    add        w11, w0, w5
    mov        w5, YMODEND             ;initialize Y Modulus End register
    nop
    pop        w10

    clr        A, [w9], w7, [w10]+=2, w5 
    
    do         w3, LMS_S3
    mpy        w5*w6, A, [w9], w7,[w10]+=2, w5 ;cptri[i] -= erri * dptrr[i]
    sac.r      A, w12
LMS_S3: 
    sub        w7, w12, [w9++]
   
    mov        #eqzDlyQ,w11
    mov        w11, YMODSRT

    add        w11, w0, w5
    mov        w5, YMODEND             ;initialize Y Modulus End register

    mov        w13,w10
    mov        #eqzCoefsQ, w9          ;w8 = cptrr
    
    clr        B,[w9], w7, [w10]+=2, w5
       
    do         w3, LMS_S4
    mpy        w4*w5, B,[w9], w7, [w10]+=2, w5 ;cptri[i] += errr * dptri[i]
    sac.r      B, w12
LMS_S4: 
    add        w7, w12, [w9++]

    pop        YMODEND
    nop
    pop        YMODSRT
    nop
    pop        MODCON
    nop
    return


; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _FindEqzError
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to find the error vector [Difference
;               in decision and demodulated vector] represents the 
;               instantaneous error. The error is 
;               calculated as,
;               X = IDemod- IDec
;               Y = QDemod- QDec
;               To obtain the equivalent error vector for tap update, the
;               error vector X+j*Y is rotated by the carrier phase offset.
;               The sine of the carrier phase offset is negated so that the
;               error vector is de-rotated whereas, the equalizer output is 
;               rotated.i.e. the equalizer output is rotated by e+jf where 
;               as the error vector is rotated by e-jf
; -----------------------------------------------------------------------------

_FindEqzError:

    mov        w0,w1
    
    mov        #mdmDecI, w4
    mov        #mdmDemI, w6
    mov        [w6], w3
    sub        w3,[w4], w0
    mov        wreg, eqzBBErrorI

    mov        #mdmDecQ, w4
    mov        #mdmDemQ, w6
    mov        [w6], w3
    sub        w3,[w4], w0
    
    mov        wreg, eqzBBErrorQ
    
    mov        w1,w0
    mov        #0x3fff, w1
    add        w0, w1, w1

    call       _SinCos                 ;w0 = ms, w1 = mc
    
    mov        eqzBBErrorI, w4         ;Rotate the baseband error by carrier 
    mov        eqzBBErrorQ, w6         ;phase
    
    mov        w1, w5 
    mov        w0, w7
    
    mpy        w4*w5, A
    msc        w6*w7, A
    sac.r      A, w8
    mov        w8, eqzErrorI
    
    mpy        w5*w6, A
    mac        w4*w7, A
    sac.r      A, w9
    mov        w9, eqzErrorQ

    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _EstimateMSE
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to get a measure of the SNR on the
;               line during training for V22bis modulation. 
; -----------------------------------------------------------------------------
    
_EstimateMSE:

    mov        eqzBBErrorI, w0
    btsc       w0, #15
    neg        w0, w0
    
    mov        eqzBBErrorQ, w1
    btsc       w1, #15
    neg        w1, w1
    
    add        w0, w1, w1
    lsr        w1, #1, w4
    
    mov        #0x100, w5
    mov        #0x7f00, w7
    mov        eqzMse, w6
        
    mpy        w4*w5, A
    mac        w6*w7, A
    
    sac.r      A, w8
    mov        w8, eqzMse
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _EstimateV32MSE
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to get a measure of the SNR on the
;               line during training for V32bis modulation. 
; -----------------------------------------------------------------------------

_EstimateV32MSE:

    mov        eqzMSEInput,w1          ;CurIp
    add        w0,w1,w6                ;CurIp + PrevIp

    mov        w0,eqzMSEInput          ;Save CurIp

    mov        eqzMSEOutput1,w4        
    mov        #0xfe00,w5       

    mul.su     w4,w5,w2                ;Double prcession multiplication
    lsr        w3,#1,w2                ;with the previous outputs 

    clr        A
    mov        w2,ACCAL

    mov        #0x80,w7
    mac        w6*w7,A

    mov        eqzMSEOutput2,w4
    mov        #0x7f00,w5       

    mac        w4*w5,A

    mov        ACCAL,w0
    mov        ACCAH,w1

    mov        w0,eqzMSEOutput1
    mov        w1,eqzMSEOutput2

    sac.r      A,w1
    asr        w1,#2,w1
    mov        w1,eqzMse               ;Current Equalizer MSE

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global FindMainTap
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: It calculates the position of the main tap of the equalizer.
;               The main tap of the equalizer is the one with the largest 
;               absolute tap weight. Finally the distance of the main tap 
;               from the bottom of the equalizer coefficient line is saved
;               in EqzMTSmplPos.
; -----------------------------------------------------------------------------


_FindMainTap:

    clr        w0
    mov        w0, eqzMTSmplPos
    
    mov.b      eqzSpan, wreg
    
    sub        w0, #1, w0
   
    mov        #eqzCoefsI, w8
    mov        #eqzCoefsQ, w9
   
    clr        A, [w8]+=2, w4
    clr        w3
    clr        B, [w9]+=2, w5
    clr        w10
    clr        w2
    
    do         w0, TAP_WEIGHT          ;Loop for EQZLENGTH
    mpy        w4*w4, A, [w8]+=2, w4   ;Coef(I)*Coef(I),
    mac        w5*w5, A, [w9]+=2, w5   ;Coef(Q)*Coef(Q)

    mov        ACCAL, w0
    mov        ACCAH, w1
    sub        w0, w2,  w12
    subb       w1, w3,  w12
    bra        le, TAP_WEIGHT
    
    mov        w0, w2
    mov        w1, w3

    mov        w10, w12                ;Update the Samp Pos of Max
    mov        w10, eqzMTSmplPos       ;Tap Weight
    
TAP_WEIGHT:
    inc        w10, w10
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _AdjustEqz
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: The desired offset of the main tap from the center of 
;               the equalizer is passed as argument to this function. First,
;               FindMainTap is called to determine the current position of 
;               the dominant tap and the equalizer tap weights are cleared.
;               The position offset in terms of bauds from the center of the
;               equalizer is calculated as shown below.
;               EqzMainTapBaudpos = EqzTrnOffset = 
;               ((EqzSpan/2 - EqzMAINTapSmplPos)  * EqzFseDivFactor) - desired 
;               offset If there is no offset, this value is 0. If EqzTrnOffset 
;               is negative, then there is no delay in the detection of TRN and 
;               hence reference generation is stalled for EqzTrnOffset 
;               number of bauds. If EqzTrnOffset is positive then there is a
;               delay in detection of the TRN and hence decisions have to be
;               advanced. The reference decision generator is called 
;               indirectly thro' EqzTRNDecoder for EqzTrnOffset number of 
;               bauds to compensate for the delay.
; -----------------------------------------------------------------------------
        
_AdjustEqz:

    rcall      _FindMainTap            ;Find the current position of main tap

    rcall      _ClearEqz               ;Clear the Equalizer tap weights

    mov.b      eqzSpan, wreg           ;Equalizer filter length
    lsr        w0, #1, w2              
    
    clr        w0
    
    mov        eqzMTSmplPos, w1

    sub        w2, w1, w1              ;w1 = j
    bra        ge,NO_EQZ_SHIFT         ;return if(EqzTrnOffset<0)

    btsc       w1, #15
    neg        w1, w1                  ;Compensate for Delay in
    mov        w1, w0                  ;detection in TRN sequence

NO_EQZ_SHIFT:
    
    return


; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _GetMidTapEnergy
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used for FSE based clock recovery. This
;               function returns the difference in the absolute values of
;               taps on either sides of the main tap. 
;               If M (EqzMainTapSmplPos)is the position of the main tap, 
;               then this function returns,
;               D = |C(M+1)| - |C(M-1)|
;               where, C denotes the complex equalizer coefficient.
; -----------------------------------------------------------------------------

_GetMidTapEnergy:

    mov        #eqzCoefsI, w1          ;Pointer to Eqz coefs(I)

    dec        eqzMTSmplPos, wreg
    sl         w0, #1, w0  
   
    mov        #eqzCoefsQ, w3          ;Pointer to eqz coefs(Q)    

    mov        [w1+w0],w4
    mov        [w3+w0],w5

    mpy        w4*w4, A
    mac        w5*w5, A

    inc        eqzMTSmplPos, wreg
    sl         w0,#1,w0

    mov        [w1+w0],w4
    mov        [w3+w0],w5

    mpy        w4*w4, B
    mac        w5*w5, B

    sub        B
    sac.r      B, w0                   ;Return Mid Tap energy

    return
      
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
 
    .global _InitFlock
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function enables FSE based clock recovery by setting
;               FlockStatus to 1. The functions, FindMainTap and 
;               GetMidTapEnergy are executed to get the FlockRefTapEnergy.
;               This value is the reference tap energy. Any change in the 
;               tap energy difference computed indicates the clock phase 
;               drift. The tap difference is computed every 40 bauds.
; -----------------------------------------------------------------------------

_InitFlock:

    mov       #1, w0
    mov.b     wreg, eqzFlockStatus     ;Check Flock status
    
    rcall     _FindMainTap             ;Find Main Tap position
    
    rcall     _GetMidTapEnergy         ;Find Mid tap Energy
    mov       w0, eqzFlockRefTapEgy    ;Reference tap energy
    
    mov       #16, w0
    mov.b     wreg, eqzFlockBaudCntSet
    
    return                             ;return from the function


; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
 
    .global _Flock
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function computes the Clock phase drift by finding 
;               the drift in the Current mid tap energy from the reference
;               tap energy.This computation is done for every 40 bauds
; -----------------------------------------------------------------------------
    
_Flock:

    mov       #1,w0

    cp.b      eqzFlockStatus
    bra       z, DEC_BAUDCNT

    return

DEC_BAUDCNT:

    dec.b       eqzFlockBaudCnt
    bra         z, INIT_FLOCKBAUD
    return                             ;return from the function

INIT_FLOCKBAUD:


    mov.b     eqzFlockBaudCntSet, wreg
    mov.b     wreg, eqzFlockBaudCnt    ;reinitialize the Flock Baud counter
    
    rcall     _GetMidTapEnergy         ;Get the Mid Tap energy
    
    mov       eqzFlockRefTapEgy, w1
    sub       w0, w1, w4               ;w4 = temp
    
    mov       #0x180, w5

    mpy       w4*w5, A
    sac.r     A, w2

    mov       w2, mdmSamplePhaseAdjust ;compute Sampl Phase adjust
    
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global ClearEqzVars
    .section  .libsm, "x"
    
ClearEqzVars:
    
    mov        #eqzSpan, w0            ;Clear Equalizer data structure
    mov        #SIZEOFEQZ_BSS_1, w1
    call       _ClearStructByte
    
    mov        #eqzIpI, w0             ;Clear Equalizer data structure
    mov        #SIZEOFEQZ_BSS_2, w1
    call       _ClearStruct                                  

    mov        #eqzCoefsI, w0          ;Clear Equalizer data structure
    mov        #SIZEOFEQZ_XBSS, w1
    call       _ClearStruct                                        

    mov        #eqzDlyI, w0            ;Clear Equalizer data structure
    mov        #SIZEOFEQZ_YBSS, w1
    call       _ClearStruct                                        
   
    clr        eqzMSEInput
    clr        eqzMSEOutput1
    clr        eqzMSEOutput2

    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.endif

; -----------------------------------------------------------------------------
;   END OF FILE
; -----------------------------------------------------------------------------
 

