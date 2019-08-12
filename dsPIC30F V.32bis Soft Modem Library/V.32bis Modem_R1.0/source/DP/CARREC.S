/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               CARREC.S                                           *
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
; 0.1   18th July 2002   Code Created                                Ravi     *
; 0.2   19th July 2002   Code Reviewed                               Raghava  *
; 0.3   12 August 2002   Modified file/function header               Ravi     *
; 0.4   20 August 2002   Corrected code documentation faults         Ravi     *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Carrier Recovery implementation for Microchip's dsPIC30F 16-bit MCU        *
;  Description: In a QAM Receiver, Carrier Recovery is employed primarily for *
;               tracking changes in the received carrier.  If a FSE is used in*
;               the receiver, it is not required to compensate the phase      *
;               offset.But the frequency offset needs to be compensated by the*
;               carrier recover circuit                                       *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;  SetCarrecPll:                                                              *
;  ======================                                                     *
;  Description: This function is used to set the bandwidth of the carrier     *
;               recovery loop filter.                                         *
;                                                                             *
;  Input:  w0 = rho                                                           *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w2, w4, w5 used not restored                                          *
;   AccA           used not restored                                          *
;                                                                             *
;  Functions Called: None                                                     *
;******************************************************************************
;  InitCarSync:                                                               *
;  ======================                                                     *
;  Description: This function initialises the parameters for carrier          *
;               recovery and Jitter cancellation.                             *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0 used not restored                                                      *
;                                                                             *
;  Functions Called: ClearCarrecVars, SetCarrecPll                            *
;******************************************************************************
;  CarrierSync:                                                               *
;  ======================                                                     *
;  Description: This function implements the carrier recovery algorithm.      *
;                                                                             *
;  Input: Void                                                                *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w4-w8, w10, w11 used not restored                                    *
;    AccA, AccB          used not restored                                    *
;                                                                             *
;  Functions Called: None                                                     *
;******************************************************************************
;  ClearCarrecVars:                                                           *
;  ======================                                                     *
;  Description: This function clears Carrec variables.                        *
;                                                                             *
;  Input: Void                                                                *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1        used not restored                                           *
;                                                                             *
;  Functions Called: ClearStruct                                              *
;******************************************************************************
;                                                                             *
;  Stack Usage in 16-bit Words :      0                                       *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;       SetCarrecPll:              06                                         *
;       InitCarSync:               04                                         *
;       CarrierSync:               34                                         *
;       ClearCarrecVars:           06                                         *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;       None                                                                  *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;       None                                                                  *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;       .nbss:                     01                                         *
;       .ybss:                     06                                         *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;       SetCarrecPll:              08                                         *
;       InitCarSync:               08                                         *
;       CarrierSync:               37                                         *
;       ClearCarrecVars:           08                                         *
;*****************************************************************************/
; -----------------------------------------------------------------------------
; INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "carrec.inc"
    .include "Modem.inc"
    .include "defs.inc"
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SetCarrecPll
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to get the band width of the
;               carrier recovery loop filter
; -----------------------------------------------------------------------------

_SetCarrecPll:

    ;Set the carrier recovery loop filter band width
    
    mov        #0x6000, w4
    mov        w0, w5
    mpy        w4*w5, A
    sac.r      A, w2
    mov        w2, CarrecGammaRho
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _InitCarSync
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: :   This function initializes the parameters for carrier
;                   recovery and Jitter cancellation
;                   1.  It clears the carrier recovery & Jitter cancellation 
;                       structure
;                   2.  It initializes the PLL loop filter band width
;                   3.  It initializes the Jitter filter parameters for 60Hz & 
;                       120Hz
; -----------------------------------------------------------------------------
    
_InitCarSync:


    rcall      ClearCarrecVars         ;clears all the members of the structure
  
    mov       #0x7E00, w0
    rcall     _SetCarrecPll            ;Set the carrier recovery PLL band width
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _CarrierSync
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function, implements the carrier recovery algorithm.
;               The phase adjust value required for rotation of the 
;               equalizer output during  the next baud interval is 
;               calculated as follows.
;               CarPdOp  = Qdec * Idemod - IDec * Qdemod
;               CarPrevLoopIp = 
;               CarPrevLoopIp + CarPdOp CarGamma - CarPrevPdOp CarGammaRho
;               CarPrevPdOp = CarPdOp
;               CarPhase = CarCurPhase + Round(X*10430)
; -----------------------------------------------------------------------------
    
_CarrierSync:

    mov.b      CarrecStatus, wreg
    cp0.b      w0                      ;checks for the carrier recovery status
    bra        nz, CAR_PHASE_CALC

    return                             ;Return if carrier recovery is disabled
    
CAR_PHASE_CALC:

    mov        mdmDemI, w4
    mov        mdmDecQ, w5             ;complex I and Q values

    mpy        w4*w5, A
    
    mov        mdmDemQ, w4
    mov        mdmDecI, w5

    msc        w4*w5, A 
    sac.r      A, w4                   ;w4 = CarrecPdOp
    mov        w4, CarrecPdOp
    
    mov        #0x6000, w5
    mpy        w4*w5, A
        
    mov        CarrecPrevPdOp, w6
    mov        CarrecGammaRho, w7
    msc        w6*w7, A
    
    mov        #CarrecPrevLoopIp, w8   ;CarrecPrevLoopIp is long
    mov        w4, CarrecPrevPdOp

    mov.d      [w8], w0
    mov        w0, ACCBL               ;place lower 16 bits into AccBL
    mov        w1, ACCBH               ;place higher 16 bits into AccBH
    
    add        A                          
    mov        ACCAL, w4
    mov        ACCAH, w5
    mov.d      w4, [w8]                ;place back the obtained val into 
                                       ;CarrecPrevLoopIp
   
    mov        CarrecPhase, w11
    mov        #10430, w4
    mpy        w4*w5, B
    sac.r      B, w10
    add        w11, w10, w11
    mov        w11, CarrecPhase        ;obtain the carrier phase value
    
    return 

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global     _ClearCarrecVars
    .section  .libsm, "x"

ClearCarrecVars:

    clr.b     CarrecStatus
    mov       #CarrecPhase, w0
    mov       #SIZEOFCARREC_BSS, w1
    call       _ClearStruct
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
.endif

; -----------------------------------------------------------------------------
;   END OF FILE
; -----------------------------------------------------------------------------
    
