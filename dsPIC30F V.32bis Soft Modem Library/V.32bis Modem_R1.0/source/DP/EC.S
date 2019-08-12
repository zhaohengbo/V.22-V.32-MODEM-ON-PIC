;******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               EC.S                                               *
;  Date:                   30th August,2002                                   *
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
; 0.1   30 August 2002         Code Created                         Rajiv     *
; 0.2   02 Sept   2002         Code Reviewed                        Raghava   *
; 0.3   15 Sept   2003         Code is added to incorporate                   *
;                              V.32bis optimization                 Raghava   *
;                                                                             *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Echo Canceller implementation for Microchip's dsPIC30F 16-bit MCU          *
;                                                                             *
;  Description: Full duplex data transmission is achieved in V.32bis          *
;               modem using echo cancellation. I.e. when the transmission     *
;               and the reception band overlap, then we need to remove the    *
;               unwanted echo signal from the received signal. Since the      *
;               echo channel characteristics can change from call-to-call     *
;               and time-to-time, we need to estimate the channel on every    *
;               session. Hence echo cancellers are implemented using          *
;               adaptive FIR filters. This module is used to cancel the       *
;               near end echo and far end echo.                               *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;                                                                             *
;******************************************************************************
;  InitNEC                                                                    *
;  ======================                                                     *
;  Description: This function is used to initialize the parameters for near   *
;  end echo cancellation. This function initially clears the near echo        *
;  canceller buffers and baud clock parameters are set.                       *
;  ======================                                                     *
;  Input:                                                                     *
;        w0=IpFactor                                                          *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1                       used not restored                            *
;                                                                             *
;  Functions Called: ClearNECVars                                             *
;                                                                             *
;******************************************************************************
;  InitFEC                                                                    *
;  ======================                                                     *
;  Description: This function is used to initialize the parameters for far    *
;  end echo cancellation. It initially clears the far echo canceller buffers  *
;  and baud clock parameters are set.                                         *
;  ======================                                                     *
;  Input:                                                                     *
;        w0=IpFactor                                                          *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1                      used not restored                             *
;                                                                             *
;  Functions Called: ClearFECVars                                             *
;                                                                             *
;******************************************************************************
;  SetupNECParams                                                             *
;  ======================                                                     *
;  Description: This function is used to set the near end echo canceller      *
;  reference buffer pointers based on the near end constant delay             *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0                         used not restored                             *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  SetupFECParams                                                             *
;  ======================                                                     *
;  Description: This function is used to set the far end echo canceller       *
;  reference buffer pointers based on the round trip delay estimated before   *
;  calling this function.                                                     *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w2                      used not restored                             *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  UpDateNECBuffers                                                           *
;  ======================                                                     *
;  Description: NEC Reference symbols are generated                           *
;  ======================                                                     *
;  Input:                                                                     *
;        w0=Real part of input                                                *
;        w1=Imaginary part of input                                           *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w4,w5,w6,w7,w8    used not restored                             *
;    ACC A                      used not restored                             *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  UpDateFECBuffers                                                           *
;  ======================                                                     *
;  Description: FEC Reference symbols are generated                           *
;  ======================                                                     *
;  Input:                                                                     *
;        w0=Real part of input                                                *
;        w1=Imaginary part of input                                           *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w4,w5,w6,w7,w8    used not restored                             *
;    ACC A                      used not restored                             *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  NECProc                                                                    *
;  ======================                                                     *
;  Description: This function is used to calculate the near echo canceller    *
;  filter output. The step size is updated based on the echo residue. The     *
;  filter delay line is updated from the symbols taken from the NEC reference *
;  buffer. The filter output is calculated as Real_Output - Imaginary_output  *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,w5,w7,w8,w9,w10,w11  used not restored                    *
;    ACC A, ACC B                        used not restored                    *
;    MODCON, YMODSRT, YMODEND            used, saved and restored             *
;                                                                             *
;  Functions Called: None                                                     *
;                                                                             *
;******************************************************************************
;  FECProc                                                                    *
;  ======================                                                     *
;  Description: This function is used to calculate the far echo canceller     *
;  filter output. The step size is updated based on the echo residue. The     *
;  filter delay line is updated from the symbols taken from the FEC reference *
;  buffer. The filter output is calculated as Real_Output - Imaginary_output  *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,w5,w7,w8,w9,w10,w11  used not restored                    *
;    ACC A, ACC B, YMODSRT, YMODEND      used not restored                    *
;    MODCON                              used, saved and restored             *
;                                                                             *
;  Functions Called: None                                                     *
;                                                                             *
;******************************************************************************
;  UpdateNec                                                                  *
;  ======================                                                     *
;  Description: This function is used to update the near echo canceller filter*
;  coefficients using the LMS algorithm and is executed only after near echo  *
;  canceller filter updation is enabled.                                      *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13  used not restored         *
;    ACC A, ACC B                                   used not restored         *
;    MODCON,YMODSRT, YMODEND                        used, saved and restored  *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  UpdateFec                                                                  *
;  ======================                                                     *
;  Description: This function is used to update the far echo canceller filter *
;  coefficients using the LMS algorithm. It is executed only far echo         *
;  canceller filter updation is enabled.                                      *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13  used not restored         *
;    ACC A, ACC B, YMODSRT, YMODEND                 used not restored         *
;    MODCON                                         used, saved and restored  *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  ECProc                                                                     *
;  ======================                                                     *
;  Description: This function is the entry point for the echo canceller       *
;  algorithm and will be called only if echo canceller is enabled.            *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        w0=Output Sample                                                     *
;                                                                             *
;  System Resource usage:                                                     *
;    w0                         used not restored                             *
;                                                                             *
;  Functions Called:   NECProc,FECProc,UpdateNec,UpdateFec                    *
;                                                                             *
;******************************************************************************
;  ClearNECVars                                                               *
;  ======================                                                     *
;  Description: This function clears all NEC variables.                       *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1                      used not restored                             *
;                                                                             *
;  Functions Called:   ClearStruct                                            *
;                                                                             *
;******************************************************************************
;  ClearFECVars                                                               *
;  ======================                                                     *
;  Description: This function clears all FEC variables.                       *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1                      used not restored                             *
;                                                                             *
;  Functions Called:   ClearStruct                                            *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :  18                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitNEC:             12                                                 *
;     InitFEC:             05                                                 *
;     SetupNECParams:      04                                                 *
;     SetupFECParams:      17                                                 *
;     UpDateNECBuffers:    28                                                 *
;     UpDateFECBuffers:    28                                                 *
;     NECProc:             98                                                 *
;     FECProc:             99                                                 *
;     UpdateNec:           57                                                 *
;     UpdateFec:           57                                                 *
;     ECProc:              21                                                 *
;     ClearNECVars:        26                                                 *
;     ClearFECVars:        26                                                 *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;    .bss:     SIZEOFNEC_BSS+SIZEOFFEC_BSS+SIZEOFEC_BSS                       *
;    .xbss:    (SIZEOFNEC_XBSS+ SIZEOFEC_XBSS)                                *
;    .ybss:    320                                                            *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitNEC:           08                                                   *
;     InitFEC:           08                                                   *
;     SetupNECParams:    06                                                   *
;     SetupFECParams:    19                                                   *
;     UpDateNECBuffers:  29                                                   *
;     UpDateFECBuffers:  29                                                   *
;     NECProc:           164                                                  *
;     FECProc:           164                                                  *
;     UpdateNec:         367                                                  *
;     UpdateFec:         367                                                  *
;     ECProc:            21                                                   *
;     ClearNECVars:      28                                                   *
;     ClearFECVars:      28                                                   *
;                                                                             *
;*****************************************************************************/
; -----------------------------------------------------------------------------
;    MACRO DEFINITIONS
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

   .include "EC.inc"
   .include "filter.inc"
   .include "modem.inc"
   .include "apiasm.inc"
   .include "defs.inc"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if DEF_V32 == 1
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
             
    .global _InitNEC
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;Description: This function is used to initialize the parameters for near
;             end echo cancellation. This function initially clears the near 
;             echo canceller buffers and baud clock parameters are set. 
;  
; -----------------------------------------------------------------------------
_InitNEC:
        
    push       w0
    rcall      ClearNECVars
    pop        w0
    
    mov.b      wreg, NECBaudClkSet     ;Init the Baud set with IpFactor

    mov        #psvpage(ECSineTab),w2
    mov        w2, PSVPAG
    mov        #psvoffset(ECSineTab),w1
    mov        w1,ECSineTabPtr
    clr        NECSineTabIndex
    clr        FECSineTabIndex        
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if ENFEC == 1

    .global _InitFEC
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is used to initialize the parameters for far
;  end echo cancellation. It initially clears the far echo canceller buffers
;  and baud clock parameters are set.
; -----------------------------------------------------------------------------

_InitFEC:

    push       w0                      ;save the IpFactor
    rcall      ClearFECVars
    pop        w0
        
    mov.b      wreg, FECBaudClkSet     ;Init the Baud set with IpFactor
        
    return
            
 .endif   
     
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SetupNECParams
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is used to set the near end echo canceller
;  reference buffer pointers based on the near end constant delay.
; -----------------------------------------------------------------------------

_SetupNECParams:

        
    mov        NECDelay, w0
    sl         w0, #1, w0
    add        NECRefPtrW              ;Update NEC write ptr by taking Delay
    
    return         
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if ENFEC == 1

    .global _SetupFECParams
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is used to set the far end echo canceller
;  reference buffer pointers based on the round trip delay estimated before
;  calling this function. 
; -----------------------------------------------------------------------------

_SetupFECParams:

    cp0        ECFECBufferLength
    bra        z, UPD_WPTR
    
    mov        ECFECBufferLength, w0
    mov        ECBulkDelay, w2
    
    lsr        w0, #1, w0
    lsr        w2, #1, w2
;Hang up the Modem when there is FEC buffer overflow. i.e When FEC
;delay exceeds the Maximum Bulk Delay (RoundTripDelay) or if it is.
;negative.     
    cp         w2, w0
    bra        le, UPD_WPTR
    
    mov        #1, w0
    mov.b      wreg, mdmHangUp
    
UPD_WPTR:
     
    mov        ECBulkDelay, w2
    sl         w2, #1, w0
    add        FECRefPtrW              ;Initialize the Reference Ptr
    mov        w2, FECBaudCntr         ;Initialize the baud counter for FEC
    
    clr.b      FECSwitch
    clr        FECBeta                 ;Reset the Step size
    
    return
.endif    

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
      
    .global _UpDateNECBuffers
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: Reference symbols are generated for near echo canceller
; -----------------------------------------------------------------------------

_UpDateNECBuffers:

    mov       #NECStart,w2             ;Check for the Ist entry into this
    cp0       [w2]                     ;function
    bra       nz,UPD_NEC_BUFFERS    

    inc       [w2],[w2]     

UPD_NEC_BUFFERS:
 
    mov         ECSineTabPtr,w2        ;Carrier generator look up table pointer
    mov         NECSineTabIndex,w3
    add         w3,#2,w5 

    mov         [w2+w3],w4             ;Get the Sine and Cosine values
    mov         [w2+w5],w6

    inc2        w5,w5                  ;Update the look table index
    and         w5,#0xf,w5
    mov         w5,NECSineTabIndex
    
    mov        w0, w5
    mov        w1, w7
    
    mpy        w5*w6, A
    msc        w4*w7, A
    sac.r      A, w2

    mov        ECCoefShift, w0

    mov        #NECRefSymbolR,w8
    sl         w2, w0, w2
    mov        w2, [w8]                 ;Update the NEC Reference Sumbol(R) 

    mpy        w4*w5, A
    mac        w6*w7, A
    sac.r      A, w2
    
    mov        #NECRefSymbolI,w8
    sl         w2, w0, w2
    mov        w2, [w8]                ;Update the NEC Reference Sumbol(I) 
        
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
      
    .global _UpDateFECBuffers
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: Reference symbols are generated for far echo canceller
; -----------------------------------------------------------------------------

_UpDateFECBuffers:

    mov       #FECStart,w2             ;Check for the Ist entry into this
    cp0       [w2]                     ;function
    bra       nz,UPD_FEC_BUUFERS    

    inc       [w2],[w2]     

UPD_FEC_BUUFERS:

    mov         ECSineTabPtr,w2        ;Carrier generator look up table pointer
    mov         FECSineTabIndex,w3
    add         w3,#2,w5 

    mov         [w2+w3],w4             ;Get the Sine and Cosine values
    mov         [w2+w5],w6

    inc2        w5,w5                  ;Update the look table index
    and         w5,#0xf,w5
    mov         w5,FECSineTabIndex
    
    mov        w0, w5
    mov        w1, w7
    
    mpy        w5*w6, A
    msc        w4*w7, A
    sac.r      A, w2

    mov        ECCoefShift, w0

    mov        #FECRefSymbolR,w8
    sl         w2, w0, w2
    mov        w2, [w8]                ;Update the FEC Reference Sumbol(R) 

    mpy        w4*w5, A
    mac        w6*w7, A
    sac.r      A, w2
    
    mov        #FECRefSymbolI,w8
    sl         w2, w0, w2
    mov        w2, [w8]                ;Update the FEC Reference Sumbol(R) 
        
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _NECProc
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is used to calculate the near echo canceller
;  filter output. The step size is updated based on the echo residue. The
;  filter delay line is updated from the symbols taken from the NEC reference
;  buffer. The filter output is calculated as Real_Output - Imaginary_output
; -----------------------------------------------------------------------------
             
_NECProc:

    inc.b      NECBaudClk
    mov.b      NECBaudClk, wreg        ;update the Baudclk         
    
    cp.b       w0, #1                  ;chk if 1st sample
    bra        z, CASE1
    
    cp.b       w0, #2                  ;chk if 2nd sample
    bra        z, CASE2
    
    cp.b       w0, #3                  ;chk if 3rd sample
    bra        z, CASE3
    
    bra        RESETBAUDCLK            ;No samples
    
CASE1:

    mov        #NECRefSymbolR,w4
    mov        #NECRefSymbolI,w5

    mov        #NECDlyLineI,w1         ;Base Addr of NEC delay line I
    mov        NECDlIndex, w3          ;Delay Index
    sl         w3,#1,w3
    mov        #NECDlyLineQ,w2         ;Base Addr of NEC delay line Q
 
    mov        [w4], [w1+w3]
    mov        [w5], [w2+w3]

    inc        NECDlIndex              ;Increment the Delay Index
    mov        #NECSPAN, w0
;check the Delay Index reaches end of buffer, if end, reset it
    cp         NECDlIndex
    bra        nz, NO_RESET_DLYINDEX
    clr        NECDlIndex
        
NO_RESET_DLYINDEX:
    
    mov        #mdmFilterBuffer, w1
    mov        #NECCoefs1I, w0         ;Addr of NecCoefs1I buffer
    add        w0, w1, w0
    mov        #NECCoefs1Q, w1         ;Addr of NecCoefs1Q buffer
    mov        w0, NECCoefPtrI         ;Init pointer to I Buffer
    mov        w1, NECCoefPtrQ         ;Init pointer to Q Buffer
    bra        RESETBAUDCLK

CASE2:
    mov        #mdmFilterBuffer, w1
    mov        #NECCoefs2I, w0         ;Addr of NecCoefs2I buffer
    add        w1, w0, w0
    mov        #NECCoefs2Q, w1         ;Addr of NecCoefs2Q buffer
    mov        w0, NECCoefPtrI         ;Init Pointer to I buffer
    mov        w1, NECCoefPtrQ         ;Init pointer to Q buffer
    bra        RESETBAUDCLK

CASE3:

    mov        #mdmFilterBuffer, w1
    mov        #NECCoefs3I, w0         ;Addr of NecCoefs3I buffer
    add        w1, w0, w0
    mov        #NECCoefs3Q, w1         ;Addr of NecCoefs3Q buffer
    mov        w0, NECCoefPtrI         ;Init Pointer to I buffer
    mov        w1, NECCoefPtrQ         ;Init pointer to Q buffer
    
RESETBAUDCLK:

    mov.b      NECBaudClkSet, wreg
    cp.b       NECBaudClk              ;Chk if processed 3 samples
    bra        nz, SAMPLES_PRESENT
    clr.b      NECBaudClk              ;reset the Baud clk
    
SAMPLES_PRESENT:             
              
    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND
  
    mov        NECDlIndex, w2          ;w2 = stp = Delay Index
    sl         w2, #1, w2
  
    mov        NECCoefPtrI, w10        ;w8 = cptrr
    
    mov        #NECDlyLineI, w8        ;start address      
    mov        w8, XMODSRT             ;initialize Y Modulus Start register 
   
    mov        #NECSPAN,w0
    sl         w0,w0
    dec        w0,w0

    add        w8, w0, w1
    mov        w1, XMODEND             ;initialize Y Modulus End register
    
    add        w8, w2, w8
    
    mov        NECCoefPtrQ, w9         ;w8 = cptri
   
    mov        #NECDlyLineQ, w11       ;get delay data start address
    mov        w11, YMODSRT            ;initialize Y Modulus Start register 

    add        w11, w0, w5
    mov        w5, YMODEND             ;initialize Y Modulus End register

    add        w11, w2, w11    
        
    mov        #0x00B8, w5             ;set XMD = W8 and YMOD = W10
    mov        w5, MODCON              ;load the MODCON
    bset       MODCON, #14             ;enable Y Modulus Addressing 
    bset       MODCON, #15
    mov        #NECSPAN,w3
    dec        w3, w3   
    clr        A, [w8]+=2, w4, [w10]+=2, w5 ;cfiropi = 0
    clr        B, [w9]+=2, w6, [w11]+=2, w7      

    do         w3, FILT_LP
    mac        w4*w5, A, [w8]+=2, w4, [w10]+=2, w5    ;cptrr[i] * dptrr[i]
FILT_LP:
    mac        w6*w7, B, [w9]+=2, w6, [w11]+=2, w7
        
    sub        A                   
    sac.r      A,w4
    mov        mdmADCSample, w0
    sub        w0, w4, w0              ;get the EC Output
    mov        w0, ECOpSample          ;Store the EC output
    mov        w0, NECOpSample 
     
    pop        YMODEND
    pop        YMODSRT
    pop        MODCON                  ;Retreive the MODCON status
    nop
       
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
.if ENFEC == 1
    
    .global _FECProc
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is used to calculate the far echo canceller
;  filter output. The step size is updated based on the echo residue. The
;  filter delay line is updated from the symbols taken from the FEC reference
;  buffer. The filter output is calculated as Real_Output - Imaginary_output. 
; -----------------------------------------------------------------------------

_FECProc:
    
    
    inc.b      FECBaudClk              ;Increment the FEC Baud Clock
    mov.b      FECBaudClk, wreg              

;Initialize the EC Coefficient pointer according to FEC Baud Clock    
   
    cp.b       w0, #1
    bra        z, CASE1FEC
    
    cp.b       w0, #2
    bra        z, CASE2FEC
    
    cp.b       w0, #3
    bra        z, CASE3FEC
    
    bra        RESETBAUDCLK1
    
    
CASE1FEC:

   cp0.b       FECBaudCntr             ;Check the FEC Baud Counter
   bra         z, UPD_DLYLINE
   dec.b       FECBaudCntr             ;decrement the Baud counter
   bra         nz, UPD_DLYLINE
   
   mov         FECBetaSet, w0
   mov         w0, FECBeta             ;Init the step size
   
   call        _FreezeAGC

UPD_DLYLINE:
   
    mov        #FECRefSymbolR,w4
    mov        #FECRefSymbolI,w5

    mov        #FECDlyLineI,w1         ;FEC Delay line I
    mov        FECDlIndex, w3          ;Delay index
    sl         w3,#1,w3
    mov        #FECDlyLineQ,w2         ;FEC Delay line Q    

    mov        [w4], [w1+w3]
    mov        [w5], [w2+w3]

    inc        FECDlIndex              ;Increment the delay index
    mov        #FECSPAN, w0
    cp         FECDlIndex              ;Chk end of delay buffer
    bra        nz, NO_RESET_DLYINDEX1
    
    clr        FECDlIndex              ;reset the delay index
        
NO_RESET_DLYINDEX1:
    
    mov        #mdmFilterBuffer, w1
    mov        #FECCoefs1I, w0         ;Base addr of FEC Coef1 I buffer
    add        w0, w1, w0
    mov        #FECCoefs1Q, w1         ;Base addr of FEC Coef1 q buffer
    mov        w0, FECCoefPtrI         ;init pointer to FEC I buffer
    mov        w1, FECCoefPtrQ         ;init pointer to FEC Q buffer
    bra        RESETBAUDCLK1

CASE2FEC:

    mov        #FECCoefs2I, w0         ;Base addr of FEC Coef2 I buffer
    mov        #FECCoefs2Q, w1         ;Base addr of FEC Coef2 Q buffer
    mov        w0, FECCoefPtrI         ;init pointer to FEC I buffer
    mov        w1, FECCoefPtrQ         ;init pointer to FEC Q buffer
    bra        RESETBAUDCLK1

CASE3FEC:

    mov        #FECCoefs3I, w0         ;Base addr of FEC Coef3 I buffer
    mov        #FECCoefs3Q, w1         ;Base addr of FEC Coef3 Q buffer
    mov        w0, FECCoefPtrI         ;init pointer to FEC I buffer
    mov        w1, FECCoefPtrQ         ;init pointer to FEC Q buffer
    
RESETBAUDCLK1:

    mov        #3, w0
    cp.b       FECBaudClk              ;chk if 3 samples processed
    bra        nz, SAMPLES_PRESENT1
    clr.b      FECBaudClk              ;Reset the Baud clk
    
SAMPLES_PRESENT1:              
              
    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND
   
    mov        FECDlIndex, w2          ;w2 = stp = Delay Index
    sl         w2, #1, w2
  
    mov        FECCoefPtrI, w10        ;w8 = cptrr
    
    mov        #FECDlyLineI, w8        ;start address      
    mov        w8, XMODSRT             ;initialize Y Modulus Start register 
   
    mov        #FECSPAN,w0
    sl         w0,w0
    dec        w0,w0

    add        w8, w0, w1
    mov        w1, XMODEND             ;initialize Y Modulus End register
    
    add        w8, w2, w8
    
    mov        FECCoefPtrQ, w9         ;w8 = cptri
   
    mov        #FECDlyLineQ, w11       ;get delay data start address
    mov        w11, YMODSRT            ;initialize Y Modulus Start register 

    add        w11, w0, w5
    mov        w5, YMODEND             ;initialize Y Modulus End register

    add        w11, w2, w11    
        
    mov        #0x00B8, w5             ;set XMD = W8 and YMOD = W10
    mov        w5, MODCON              ;load the MODCON
    bset       MODCON, #14             ;enable Y Modulus Addressing 
    bset       MODCON, #15
    mov        #FECSPAN,w3
    dec        w3, w3   
    clr        A, [w8]+=2, w4, [w10]+=2, w5 ;cfiropi = 0
    clr        B, [w9]+=2, w6, [w11]+=2, w7      

    do         w3, FILT_LPP
    mac        w4*w5, A, [w8]+=2, w4, [w10]+=2, w5    ;cptrr[i] * dptrr[i]
FILT_LPP:
    mac        w6*w7, B, [w9]+=2, w6, [w11]+=2, w7
       
    sub        A                   
    sac.r      A,w4                    ;Get the EC output
    mov        w4, FECOpSample         ;Store the Ec output sample
     
    pop        YMODEND
    pop        YMODSRT
    pop        MODCON                  ;Retreive status of MODCON
    nop   
    return
    
.endif

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _UpdateNec
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is used to update the near echo canceller filter
;  coefficients using the LMS algorithm and is executed only after near echo
;  canceller filter updation is enabled.
; -----------------------------------------------------------------------------

_UpdateNec:

    cp0.b      NECUpdateEnable         ;Chk if NEC enabled
    bra        z, EXIT_UPDATENEC
    

    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND
 
    mov        ECOpSample, w4          ;Get the EC output sample
    mov        NECBeta, w5             ;Step size
    mpy        w4*w5, A
    sac.r      A, w4
    neg        w4, w4                  ;errr
    mov        w4, w6                  ;erri
  
    mov        NECDlIndex, w2          ;w2 = stp =Delay Index
    mov        NECCoefPtrI, w11        ;w9 = cptrr
    
    mov        #NECDlyLineI, w8        ;start address      
    mov        w8, XMODSRT             ;initialize X Modulus Start register 

    mov        #NECSPAN, w0
    sl         w0,w0
    dec        w0,w0
    
    add        w8, w0, w1
    mov        w1, XMODEND             ;initialize X Modulus End register
    sl         w2, #1, w2
    
    add        w8, w2, w8
    
    mov        NECCoefPtrQ, w9
    mov        #NECDlyLineQ, w10       ;get delay data start address
    mov        w10, YMODSRT            ;initialize Y Modulus Start register 

    add        w10, w0, w5
    mov        w5, YMODEND             ;initialize Y Modulus End register

    add        w10, w2, w10    
        
    mov        #0x00A8, w5             ;set XMD = W8 and YMOD = W10
    mov        w5, MODCON              ;load the MODCON
    bset       MODCON, #14             ;enable Y Modulus Addressing 
    bset       MODCON, #15             ;enable X Modulus Addressing
    
    mov        #NECSPAN, w3
    dec        w3,w3

    mov        w8, w13
    mov        w10, w2
    clr        A,[w8]+=2, w5
    do         w3, LMS_LP
    mpy        w4*w5, A,  [w8]+=2, w5, [w10]+=2, w7
    mac        w6*w7, A,  [w11], w7
    sac.r      A, w12
    sub        w7, w12, [w11++]
LMS_LP:    
    nop
        
    mov        w13, w8
    mov        w2, w10
    clr        A,[w8]+=2, w5
    
    do         w3, LMS_LPI
    mpy        w5*w6, A, [w8]+=2, w5, [w10]+=2, w7
    msc        w4*w7, A, [w9], w7
    sac.r      A, w12
    sub        w7, w12, [w9++]
LMS_LPI:
    nop
        
    pop        YMODEND
    pop        YMODSRT
    pop        MODCON
    nop
EXIT_UPDATENEC:

    return

.if ENFEC == 1

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _UpdateFec
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is used to update the far echo canceller filter
;  coefficients using the LMS algorithm. It is executed only far echo
;  canceller filter updation is enabled. 
; -----------------------------------------------------------------------------

_UpdateFec:

    cp0.b      FECUpdateEnable         ;Chk if FEC enabled
    bra        z, EXIT_UPDATEFEC
    

    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND
 
    mov        ECOpSample, w4          ;Echo canceller output sample
    mov        FECBeta, w5             ;FEC step size
    mpy        w4*w5, A
    sac.r      A, w4
    neg        w4, w4                  ;errr
    mov        w4, w6                  ;erri
   
    mov        FECDlIndex, w2          ;w2 = stp =Delay Index
    mov        FECCoefPtrI, w11        ;w9 = cptrr
    
    mov        #FECDlyLineI, w8        ;start address      
    mov        w8, XMODSRT             ;initialize X Modulus Start register 

    mov        #FECSPAN, w0
    sl         w0,w0
    dec        w0,w0
    
    add        w8, w0, w1
    mov        w1, XMODEND             ;initialize X Modulus End register
    sl         w2, #1, w2
    
    add        w8, w2, w8
    
    mov        FECCoefPtrQ, w9
    mov        #FECDlyLineQ, w10       ;get delay data start address
    mov        w10, YMODSRT            ;initialize Y Modulus Start register 

    add        w10, w0, w5
    mov        w5, YMODEND             ;initialize Y Modulus End register

    add        w10, w2, w10    
        
    mov        #0x00A8, w5             ;set XMD = W8 and YMOD = W10
    mov        w5, MODCON              ;load the MODCON
    bset       MODCON, #14             ;enable Y Modulus Addressing 
    bset       MODCON, #15             ;enable X Modulus Addressing
    
    mov        #FECSPAN, w3
    dec        w3,w3

    mov        w8, w13
    mov        w10, w2
    clr        A,[w8]+=2, w5
    do         w3, LMS_LPII
    mpy        w4*w5, A,  [w8]+=2, w5, [w10]+=2, w7
    mac        w6*w7, A,  [w11], w7
    sac.r      A, w12
    sub        w7, w12, [w11++]
LMS_LPII:    
    nop
    
    mov        w13, w8
    mov        w2, w10
    clr        A,[w8]+=2, w5
    
    do         w3, LMS_LPIII
    mpy        w5*w6, A, [w8]+=2, w5, [w10]+=2, w7
    msc        w4*w7, A, [w9], w7
    sac.r      A, w12
    sub        w7, w12, [w9++]
LMS_LPIII:
    nop
   
    pop        YMODEND
    pop        YMODSRT
    pop        MODCON
    nop
EXIT_UPDATEFEC:
    return

.endif

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ECProc
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is the entry point for the echo canceller
;  algorithm and will be called only if echo canceller is enabled. 
; -----------------------------------------------------------------------------

_ECProc:

    cp0.b      ECEnable                ;Chk If Echo canceller enabled
    bra        nz, TO_NECPROC
    
    mov        mdmADCSample, w0        ;If not enabled return received sample
    return
    
TO_NECPROC:
    call       _NECProc                ;Cancel the Near end Echo

.if ENFEC == 1
         
    cp0.b      FECUpdateEnable         ;Chk if FEC enabled
    bra        z, UPD_OPSAMPLE
    
    call       _FECProc                ;Cancel the far end Echo
.endif

UPD_OPSAMPLE:

    clr        w0
.if ENFEC == 1
    mov        FECOpSample, w0         ;Far end echo cancelled output
.endif
    sub        NECOpSample, wreg       ;NEC-FEC
    mov        w0, ECOpSample          ;Echo Cancelled output  
    cp0        NECBeta                 ;Chk if step size defined
    bra        z, NO_UPDNEC            ;for NEC filter updation
    
   call       _UpdateNec               ;Update the NEC filter step size

NO_UPDNEC:
    
.if ENFEC == 1

    cp0        FECBeta
    bra        z, NO_UPDFEC
    
    call       _UpdateFec
.endif

NO_UPDFEC:

    cp0        NECBeta                 ;Chk for NEC step size
    bra        nz, GET_RESIDUE         ;Get the Residue signal
    bra        EXIT_ECProc
.if ENFEC == 1    
    cp0        FECBeta                 ;chk for FEC step size
    bra        z, EXIT_ECProc
.endif
GET_RESIDUE:
    
    mov        mdmMeanPLevel, w0
    mov        w0, ECResidue           ;Least Residual error output 

EXIT_ECProc:

   mov        ECOpSample, w0          ;return the Echo cancelled output
   return
    

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global ClearNECVars
    .section  .libsm, "x"

ClearNECVars:
      
    mov        #NECBaudClkSet, w0
    mov        #SIZEOFNEC_BSS_1, w1
    call       _ClearStructByte            ;clear all variables under .bss section
       
    mov        #NECRefPtrR, w0
    mov        #SIZEOFNEC_BSS_2, w1
    call       _ClearStruct               ;clear all variables under .bss section

    mov        #ECBaudBits, w0
    mov        #SIZEOFNEC_BSS_3, w1
    call       _ClearStruct               ;clear all variables under .bss section

    mov        #NECDlyLineI, w0
    mov        #SIZEOFNEC_XBSS_1, w1
    call       _ClearStruct            ;clear all variables under .xbss section
    
    mov        #NECCoefs1Q, w0
    mov        #SIZEOFNEC_XBSS_2, w1
    call       _ClearStruct            ;clear all variables under .xbss section
       
    mov        #mdmFilterBuffer, w1
    mov        #NECCoefs1I, w0
    add        w0, w1, w0
    mov        #SIZEOFNEC_YBSS_1, w1
        
    call       _ClearStruct

    mov        #NECDlyLineQ, w0
    mov        #SIZEOFNEC_YBSS_2, w1
    call       _ClearStruct            ;clear all variables under .xbss section
    
    clr.b      ECEnable
        
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global ClearFECVars
    .section  .libsm, "x"

ClearFECVars:

    mov        #FECBaudClkSet, w0
    mov        #SIZEOFFEC_BSS_1, w1
    call       _ClearStructByte
        
    mov        #FECRefPtrR, w0
    mov        #SIZEOFFEC_BSS_2, w1
    call       _ClearStruct

    mov        #FECStartPhase, w0
    mov        #SIZEOFFEC_BSS_3, w1
    call       _ClearStruct

    mov        #FECDlyLineI, w0
    mov        #SIZEOFEC_XBSS_1, w1
    call       _ClearStruct
    
    mov        #FECCoefs1Q, w0
    mov        #SIZEOFEC_XBSS_2, w1
    call       _ClearStruct

    mov        #mdmFilterBuffer, w1
    mov        #FECCoefs1I, w0
    add        w0, w1, w0
    mov        #SIZEOFFEC_YBSS_1, w1
    call       _ClearStruct        

    mov        #FECCoefs2I, w0
    mov        #SIZEOFFEC_YBSS_2, w1
    call       _ClearStruct    

    mov        #FECDlyLineQ, w0
    mov        #SIZEOFFEC_YBSS_3, w1
    call       _ClearStruct
        
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.endif

;******************************************************************************
; END OF FILE
;******************************************************************************
                      
