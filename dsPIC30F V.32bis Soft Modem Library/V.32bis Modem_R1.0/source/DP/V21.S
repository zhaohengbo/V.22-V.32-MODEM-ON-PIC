/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               V21.S                                              *
;  Date:                   5th August,2002                                    *
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
; 0.1   05 August 2002         Code Created                         Rajiv     *
; 0.2   07 August 2002         Code Reviewed                        Raghava   *
; 0.3   09 August 2002         Modified file/function header        Rajiv     *
; 0.4   23 August 2002         Corrected code documentation faults  Rajiv     *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  V21 data pump implementation for Microchip's dsPIC30F 16-bit MCU           *
;  Description:   This Code implemented according to ITU-T V.21 modem         *
;                 Standard.This Uses FSK Modulation for Data Transmission.    *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;                                                                             *
;******************************************************************************
;  InitializeV21                                                              *
;  ======================                                                     *
;  Description: This Function initializes the parameters for V21 mode for both*
;               originate and answer modes.                                   *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4             used not restored                             *
;    PSVPAG                     used saved and restored                       *
;                                                                             *
;  Functions Called:   ClearV21Vars                                           *
;                                                                             *
;******************************************************************************
;  V21LoopBack                                                                *
;  ======================                                                     *
;  Description: This Function initializes the parameters for digital          *
;               loop back operation of the datapump in v21 mode               *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w2,w3             used not restored                                   *
;    PSVPAG               used saved and restored                             *
;                                                                             *
;  Functions Called:   SetTransmiter,SetReceiver,InitializeV21,               *
;                      EnableDataTransfer                                     *
;                                                                             *
;******************************************************************************
;  StartV21                                                                   *
;  ======================                                                     *
;  Description: In this function both the transmitter and the receiver are    *
;               configured in the V.21 mode. The transmission of continuous   *
;               binary 1's is set up.                                         *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2,w3,w4                    used not restored                          *
;                                                                             *
;  Functions Called:   SetTransmiter,SetReceiver,InitializeV21                *
;                                                                             *
;******************************************************************************
;  V21TxModem                                                                 *
;  ======================                                                     *
;  Description: This function Set up the parameters for V21 transmission only.*
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2                          used not restored                          *
;                                                                             *
;  Functions Called:   SetTransmiterr,InitializeV21                           *
;                                                                             *
;******************************************************************************
;  V21RxModem                                                                 *
;  ======================                                                     *
;  Description: This function Set up the parameters for V21 reception only.   *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2                          used not restored                          *
;                                                                             *
;  Functions Called:   SetReceiver,InitializeV21                              *
;                                                                             *
;******************************************************************************
;  V21Transmiter                                                              *
;  ======================                                                     *
;  Description: This Function generates the Transmit Samples in V21 mode      *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w2,w3,w4,w5,w8              used not restored                          *
;   Acc A                          used not restored                          *
;                                                                             *
;  Functions Called:   SinCos                                                 *
;                                                                             *
;******************************************************************************
;  V21Receiver                                                                *
;  ======================                                                     *
;  Description: This Function process the received Samples in V21 mode        *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2,w3,w4,w5,w8,w10       used not restored                          *
;   Acc A                          used not restored                          *
;   YMODSRT, YMODEND               used saved and restored                    *
;   MODCON                         used saved and restored                    *
;                                                                             *
;  Functions Called:   fir, AGC, V21Demod                                     *
;                                                                             *
;******************************************************************************
;  V21Demod                                                                   *
;  ======================                                                     *
;  Description: This function is used for demodulation of V21 signal.         *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2,w3,w4,w5,w6,w7,w8,w9  used not restored                          *
;   Acc A                          used not restored                          *
;    PSVPAG                        used saved and restored                    *
;                                                                             *
;  Functions Called:   ButterWorth,EnableDataTransfer,SendMessageToHost       *
;                      FreezeAGC                                              *
;                                                                             *
;******************************************************************************
;  ClearV21Vars                                                               *
;  ======================                                                     *
;  Description: This function clears V21 variables.                           *
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
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   7                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitializeV21:      155                                                 *
;     V21LoopBack:        19                                                  *
;     StartV21:           23                                                  *
;     V21TxModem:         12                                                  *
;     V21RxModem:         12                                                  *
;     V21Transmiter:      32                                                  *
;     V21Receiver:        32                                                  *
;     V21Demod:           118                                                 *
;     ClearV21Vars:       17                                                  *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     V21WbBp1750Coefs:   41                                                  *
;     V21WbBp1080Coefs:   41                                                  *
;     V21LpCoefs:          6                                                  *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;     None (Used from V23 Mode)                                               *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitializeV21:     72                                                   *
;     V21LoopBack:       21                                                   *
;     StartV21:          25                                                   *
;     V21TxModem:        14                                                   *
;     V21RxModem:        14                                                   *
;     V21Transmiter:     33                                                   *
;     V21Receiver:       34                                                   *
;     V21Demod:          93                                                   *
;     ClearV21Vars:      19                                                   *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;  INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "V23.inc"
    .include "V21.inc"
    .include "Tables.inc"
    .include "Modem.inc"
    .include "filter.inc"
    .include "apiasm.inc"
    .include "defs.inc"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if DEF_V21 == 1

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _InitializeV21
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function clears all the parameters in V21 data 
;                 structure and all the transmit and receive parameters are
;                 initialized.
; -----------------------------------------------------------------------------

_InitializeV21:

    push       PSVPAG
 
    rcall      ClearV21Vars
    
    mov        #ORIGINATE, w0
    and.b      modemMode, wreg         ;Check modem is in Originate mode
    bra        z, V21ANSMODE
         
    ;Set the filter coefs pointer for high band

.if DEF_B103 == 1
    mov        #ENABLE_B103, w0
    and.b      ucHS_Mode, wreg         
    bra        z, SET_ORG_V21

    mov        #psvpage(B103WbBp2125Coefs),w2
    mov        w2, PSVPAG
    mov        #psvoffset(B103WbBp2125Coefs),w2  

    ;Set the MARK and SPACE frequency advances for 
    ;high band
        
    mov        #B103B1ANS, w3            
    mov        #B103FMARKORGADV, w0
    mov        #B103FSPACEORGADV,w4
    bra        SET_FSK_ORG_PARAMS

SET_ORG_V21:
.endif

    mov        #psvpage(V21WbBp1750Coefs),w2
    mov        w2, PSVPAG
    mov        #psvoffset(V21WbBp1750Coefs),w2  

    ;Set the MARK and SPACE frequency advances for 
    ;high band
        
    mov        #V21B1ANS, w3            
    mov        #FMARKORGADV, w0
    mov        #FSPACEORGADV,w4

SET_FSK_ORG_PARAMS:
   
    mov        w2, FSKBpCoefPtr      
    mov        w3, FSKFmultFactor0         
    mov        w0, FSKMarkAdvance
    mov        w4, FSKSpaceAdvance         
    goto       INIT_V21_FILTER
    
V21ANSMODE:   

    ;Set the filter coefs pointer for low band

.if DEF_B103 == 1
    mov        #ENABLE_B103, w0
    and.b      ucHS_Mode, wreg         
    bra        z, SET_ANS_V21

    mov        #psvpage(B103WbBp1170Coefs),w2
    mov        w2, PSVPAG
    mov        #psvoffset(B103WbBp1170Coefs),w2  

    ;Set the MARK and SPACE frequency advances for 
    ;high band
        
    mov        #B103B1ORG, w3            
    mov        #B103FMARKANSADV, w0
    mov        #B103FSPACEANSADV,w4
    bra        SET_FSK_ANS_PARAMS

SET_ANS_V21:

.endif

    mov        #psvpage(V21WbBp1080Coefs),w2
    mov        w2, PSVPAG
    mov        #psvoffset(V21WbBp1080Coefs),w2

    ;Set the MARK and SPACE frequency advances for 
    ;low band
       
    mov        #V21B1ORG, w3
    mov        #FMARKANSADV, w0
    mov        #FSPACEANSADV,w4

SET_FSK_ANS_PARAMS:
    
    mov        w2, FSKBpCoefPtr        
    mov        w3, FSKFmultFactor0     
    mov        w0, FSKMarkAdvance
    mov        w4, FSKSpaceAdvance     
    
    mov        #handle(_Get1s), w2
    mov        w2, dataTxBitFn          ;Initially transmit binary 1's        
    
INIT_V21_FILTER:

   ;FIR Initialization

    mov        #mdmFilterBuffer, w2
    mov        #FSKBpDl,w0
    add        w0, w2, w0
    
    mov        w0,FSKBpDlPtr           ;Set delay line pointer
    
    add        #((V21BPFILTERLEN*2)-1),w0       
    mov        w0,FSKBpDlEnd           ;Set delay line end pointer

    mov        #V21SAMPLESPERBAUD, w0
    mov.b      wreg, FSKChangeCount    ;Demod baud switching
    
    mov        #0x1000, w2
    mov        w2, mdmTxGainFactor     ;Set the Tx Gain
    
    pop        PSVPAG

    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V21LoopBack
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function is used for checking the loop back
;                 operation of the datapump in V21 mode.This function 
;                 initializes the parameters for both transmission and
;                 reception.
; -----------------------------------------------------------------------------

_V21LoopBack:

    push      PSVPAG
    mov       #(TXENABLE+RXENABLE), w0
    ior.b     modemStatus              ;Set the status of Modem
    
    mov       #V21MODE, w0
    ior.b     modemMode                ;Set the modem mode

    mov       #MTV21, w0
    mov.b     wreg, modemType          ;Set V21 modem type 
            
    ;Set ModemTransmiter and ModemReceiver for
    ;V21Transmiter and V21Receiver respectively

    mov       #handle(_V21Transmiter), w0
    call      _SetTransmiter

    mov       #handle(_V21Receiver), w0
    call      _SetReceiver       
            
    rcall     _InitializeV21           ;Initialize V21 state variables

    ;Initialize BPF pointer for high band

.if DEF_B103 == 1
    mov        #ENABLE_B103, w0
    and.b      ucHS_Mode, wreg         
    bra        z, SET_LB_V21

    mov        #psvpage(B103WbBp2125Coefs),w2
    mov        w2, PSVPAG
    mov        #psvoffset(B103WbBp2125Coefs),w2 
       
    mov        #B103B1ANS, w3 

    bra        SET_FSK_LB_PARAMS

SET_LB_V21:
.endif

    mov        #psvpage(V21WbBp1750Coefs),w2
    mov        w2, PSVPAG
    mov        #psvoffset(V21WbBp1750Coefs),w2 

    mov        #V21B1ANS, w3 

SET_FSK_LB_PARAMS:

    mov        w2, FSKBpCoefPtr 
    mov        w3, FSKFmultFactor0
   
    call      _InitializeAGC           ;Setup AGC parameters
    mov        #handle(_NullFunction), w2
    mov        w2, dataRxBitFn          ;No reception of bits initially

    pop        PSVPAG 
    return        

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _StartV21
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function sets up the Full Duplex Mode of V21.
;                 Here both the transmitter and the receiver are configured 
;                 in the V.21 mode. The transmission of continuous binary 
;                 1's is set up. 
; -----------------------------------------------------------------------------

_StartV21:

    rcall     _InitializeV21
    
    mov       #0x1000, w2
    mov       w2, mdmTxGainFactor      ;Set Tx gain
    
    mov       #V21MODE, w0
    ior.b     modemMode
   
    mov       #MTV21, w0
    mov.b     wreg, modemType          ;Set V21 modem type 

    ;Set ModemTransmiter and ModemReceiver for
    ;V21Transmiter and V21Receiver respectively
        
    mov       #handle(_V21Transmiter), w0
    call      _SetTransmiter                 

    mov       #handle(_V21Receiver), w0
    call      _SetReceiver                   
    
    mov       #RXENABLE, w0
    ior.b     modemStatus              
    
    mov       #TXENABLE, w0
    ior.b     modemStatus              ;Set the modem status = Rx+Tx      

    mov       #handle(_Get1s), w3
    mov       w3, dataTxBitFn
    
    call      _InitializeAGC           ;Setup AGC parameters
          
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V21TxModem
    .section  .libsm, "x"

;-----------------------------------------------------------------------------
;This function is mainly used in V.8 mode of operation. This function sets up 
;parameters for V.21 transmission when this function is called a status is set
;to indicate that the modem transmitter is specifically configured in the 
;V.21 mode.
;-----------------------------------------------------------------------------

_V21TxModem:

    mov        #V21MODE, w0
    ior.b      modemMode
    
    mov        #TXENABLE, w0
    ior.b      modemStatus
    
    mov       #handle(_V21Transmiter), w0
    call      _SetTransmiter                 ; Point to V21 Transmitter
    
    rcall      _InitializeV21
    
    return  

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V21RxModem
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;This function is mainly used in V.8 mode of operation. This function sets up 
;parameters for V.21 reception. When this function is called a status is set to
;indicate that the modem receiver is specifically configured in the V.21 mode. 
;This is to distinguish the actual V.21 mode from the high-speed signal modes.
; -----------------------------------------------------------------------------

_V21RxModem:

    mov        #V21MODE, w0
    ior.b      modemMode
    
    mov        #RXENABLE, w0
    ior.b      modemStatus
    
    mov       #handle(_V21Receiver), w0
    call      _SetReceiver                  ; Point to V21 Receiver
    
    rcall      _InitializeV21
    call       _InitializeAGC
    return  

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V21Transmiter
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function generates one transmit sample for each call.
;                 The transmit sample is scaled by a factor, 0x6f0.The phase
;                 of transmit carrier is updated every sample. Every baud 
;                 interval,the transmit bit is fetched from through a function
;                 call.The FSK transmitter consists of only a carrier 
;                 generator. Every baud internal, the new bit signals the 
;                 change in the phase advance of the carrier.  The resulting 
;                 signal is of continuous phase.
; -----------------------------------------------------------------------------

_V21Transmiter:

    cp0.b     FSKTxSampleCnt
    bra       nz, V21_TX_SAMPLE        ;Check for samples count
    
    mov       #V21SAMPLESPERBAUD, w0
    mov.b     wreg, FSKTxSampleCnt     ;Reset the samples counter
    
    cp0       FSKTxBaudCount           ;Check for Baud count
    bra       z, GET_V21_TRANSMITDATA 
    
    dec       FSKTxBaudCount           ;Decrement the Baud count
    
GET_V21_TRANSMITDATA:

    mov       dataTxBitFn, w0 
    call      w0                       ;Get the transmit bit        
    
    mov       #FSKCarAdvance, w8
    cp0       w0
    bra       z, V21_SPACE_ADV
    
    ;Set the MARK frequency advance(bit = 1)

    mov       FSKMarkAdvance, w2
    mov       w2, [w8]                 
    goto      V21_TX_SAMPLE
    
V21_SPACE_ADV:

    ;Set the MARK frequency advance(bit = 0)

    mov       FSKSpaceAdvance, w2
    mov       w2, [w8]

V21_TX_SAMPLE:       
    
    mov       #FSKCurPhase, w4
    dec.b     FSKTxSampleCnt
    mov       FSKCarAdvance, w2
    add       w2, [w4], [w4]           ;Update the phase with carrier advance
    
    ;Generate the carrier for either MARK ot SPACE frequency

    mov       [w4], w0
    call      _SinCos                  
    
    mov       w0, w4
    mov       #0x6f0, w5
    mpy       w4*w5, A
    sac.r     A, w0                    ;Sample ready for transmission

    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global  _V21Receiver
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   In the receiver, an FIR band pass filter is used to cut of,
;                 out of band signal.Since, FSK signaling doesn't provide for
;                 any synchronizing signals,the band pass output level is 
;                 compared with the total signal power to estimate the 
;                 presence of FSK signal.
; -----------------------------------------------------------------------------

_V21Receiver:

    mov        #V21BPFILTERLEN, w3    
    mov        FSKBpDlPtr,w10          ;Delay line pointer in w10

    mov        FSKBpCoefPtr, w8
    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND
       
    clr        MODCON                  ;Clears MODCON
    mov        #0x00a0, w4             ;Cet  YMD 
    mov        w4, MODCON              ;Load the MODCON
    bset       MODCON, #14             ;Enable Y Modulus Addressing 

    mov        #mdmFilterBuffer, w5
    mov        #FSKBpDl,w1 
    add        w1, w5, w1
    mov        FSKBpDlEnd,w5           ;Delay line end address        
    
    mov        w1,YMODSRT              ;Initialize Y Modulus Start register 
    mov        w5,YMODEND              ;Initialize Y Modulus End register    
    mov        mdmADCSample, w2
    
    mov        w2, [w10]               ;Update delay line
    nop
    clr        A, [w10]+=2, w5         ;Clear ACCA and prefetch X and Y data
    mov        w10,FSKBpDlPtr
    
    call       _fir                    ;Execute FIR filter 

    push      w0
    call      _CheckCarrierCondition
    pop       w0
    
    pop         YMODEND
    pop         YMODSRT
    pop         MODCON                 ;Restore the status of MODCON
    nop   
    call      _AGC                     ;Execute AGC
     
    rcall     _V21Demod                ;Perform Demodulation
     
    return   

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V21Demod
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   In the V21 demodulator, the instantaneous sample is
;                 multiplied by a sample that arrived PI / 2 samples earlier. 
;                 The product_signal contains double frequency component and
;                 the baseband signal. This signal is filtered using a low
;                 pass filter to remove the high frequency component.The low 
;                 frequency base band signal is input to the slicer. The 
;                 slicer checks the zero crossings and identifies a sample 
;                 for decision.The zero crossings of the LPF are monitored 
;                 for adjuusting the local sampling clock.
;                 In data modem data transfer is enabled after validating 20
;                 continous binary 1's in the received bit stream.
; -----------------------------------------------------------------------------

_V21Demod:

     ;If valid signal energy is not detected no demodualtion
     
     push       PSVPAG
     cp0.b      AGCEnergyStat
     bra        z, EXIT_DEMOD

     mov        AGCOutput, w2
     sl         w2, #2, w4
     
     mov        FSKDsmp2, w5
     mpy        w4*w5, A               ;Multiply rxsample with PI/2
     sac.r      A, w2                  ;delayed sample and adjust the gain of
     mov        w2, FSKIpSample        ;the signal for demodulation
     
     mov        FSKFmultFactor0, w5
     mov        FSKDsmp0, w6
     
     mpy        w5*w6, A
     
     lac        w4, B
     sftac      B, #1
     
     add        A
     
     sac.r      A, w2
     
     mov        w2, FSKDsmp2           ;store the previous samples
     mov        w4, FSKDsmp0
     
     mov        #psvpage(V21LpCoefs),w2;LP filter coefficients
     mov        w2, PSVPAG
     mov        #psvoffset(V21LpCoefs),w1
     mov        w1, FSKLpCoefsPtr      ;Poinyter to LP filter coefficients
     
     mov        #mdmFilterBuffer, w2
     mov        #FSKLpDl, w0           ;Delay Line Address
     add        w0, w2, w0
     mov        FSKIpSample, w2        ; Sample to be filtered
     
;Filter the above calculated product signal to remove the
;high frequency component.              

     call       _ButterWorth
     
     mov        w0, FSKIpSample        ;store the filtered sample

     mov        #mdmFilterBuffer, w3
     mov        #FSKLpDl, w0
     add        w0, w3, w0
     mov        #(BUTTERDLINELEN*2), w3
     add        w3, w0, w0
     mov        FSKLpCoefsPtr, w1      ;Pointer to Lp Coeffs 
     mov        FSKIpSample, w2
     
     call       _ButterWorth
     
     mov        w0, FSKIpSample

     mov        w0, w4
     mov        FSKLpOp, w5
     
     mpy        w4*w5, A
     
     mov        ACCAL, w0
     mov        ACCAH, w1
     sub        w0, #0, w0
     subb       w1, #0, w1
           
     bra        gt, NEXTCOND_V21
     
     mov        #(V21SAMPLESPERBAUD/2), w0
     mov.b      wreg, FSKChangeCount   ;Initialize the Change count
     
     goto       UPD_LPOP_V21
     
NEXTCOND_V21:     
    
     dec.b      FSKChangeCount         ;Countdown the Change count
     bra        nz, UPD_LPOP_V21 
     
     mov        #V21SAMPLESPERBAUD, w0
     mov.b      wreg, FSKChangeCount   ;Reinitiailize the Change count at the 

.if DEF_B103 == 1
     mov        #ENABLE_B103, w0
     and.b      ucHS_Mode, wreg         
     bra        z, V21_DEMOD_DECISION

     cp0        FSKIpSample            ;point of zero crossing
     bra        gt, NEXTVAL_B103
     mov        #1, w3
     goto       CHK_MDMTYPE_V21

NEXTVAL_B103:    
     
     mov        #0, w3
     goto       CHK_MDMTYPE_V21

V21_DEMOD_DECISION:
.endif

     cp0        FSKIpSample            ;point of zero crossing
     bra        lt, NEXTVAL_V21
     mov        #1, w3
     goto       CHK_MDMTYPE_V21
 
NEXTVAL_V21:    
     
     mov        #0, w3
     
CHK_MDMTYPE_V21:

     mov        dataRxBitFn, w1
;    bclr       w1, #15
     mov        w3, w0
     push       w3                     ;Put the decoded bit in the Receive
     
     call       w1                     ; buffer through a function call
     
     pop        w3
     mov        #MTV21, w0
     cp.b       modemType              ;Check the modem type 
     bra        nz, UPD_LPOP_V21
     
     mov        #CARRIERDETECT, w0
     and.b      modemStatus, wreg
     bra        nz, UPD_LPOP_V21
     
     cp0        w3
     bra        z, SETCNTRZERO_V21
     
     mov        #20, w2
     
     mov.b      FSKValidCntr, wreg     ;Set the counter for valid outputs
     
     inc.b      FSKValidCntr           ;Increment the 1's valid counter
     
     cp.b       w0, w2
     
    bra        le, UPD_LPOP_V21
     
    call       _EnableDataTransfer     ;Enable the data transfer

.if DEF_B103 == 1
    mov        #ENABLE_B103, w0
    and.b      ucHS_Mode, wreg         
    bra        z, V21_CONNECT_MODE

    mov        #mCONNECT,w0            ;Send CONNECT message to host to
    mov.b      wreg,mesgMsgId          ;indicate the connection establishment
    mov        #1, w0
    mov.b      wreg,mesgMsgLen
    mov        #mesgMsgParams, w8 
    mov        #B103_MODE, w0
    mov.b      w0, [w8]
    call       _SendMessageToHost
    goto       UPD_LPOP_V21

 V21_CONNECT_MODE:
.endif
    
    mov        #mCONNECT,w0            ;Send CONNECT message to host to
    mov.b      wreg,mesgMsgId          ;indicate the connection establishment
    mov        #1, w0
    mov.b      wreg,mesgMsgLen
    mov        #mesgMsgParams, w8 
    mov        #V21_MODE, w0
    mov.b      w0, [w8]
   call       _SendMessageToHost

.if DEF_DEBUG == 1
    mov        #V21_CONNECT_300, w0
    call       _SendDebugInfo
.endif
    
    goto       UPD_LPOP_V21
     
SETCNTRZERO_V21:
     clr.b      FSKValidCntr           ;Reset the valid counter
  
UPD_LPOP_V21:

     mov        #mdmFilterBuffer, w3
     mov        #FSKLpDl, w0
     add        w0, w3, w0
     mov        #FSKLpOp, w3
     mov        #(2*(BUTTERDLINELEN+2)), w2
     nop
     mov        [w0+w2], [w3]
EXIT_DEMOD:     
     
     pop        PSVPAG
     return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global ClearV21Vars
    .section  .libsm, "x"

ClearV21Vars:

    mov        #FSKValidCntr, w0
    mov        #SIZEOFFSK_BSS_1, w1
    call       _ClearStructByte            ;Clear all V.21 variables

    mov        #FSKTxBaudCount, w0
    mov        #SIZEOFFSK_BSS_2, w1
    call       _ClearStruct            ;Clear all V.21 variables

    mov        #mdmFilterBuffer, w1
    mov        #FSKLpDl,w0             ;Clear BPF delay line
    add        w0, w1, w0
    mov        #SIZEOFFSK_YBSS_1,w1
    call       _ClearStruct
    
    mov        #mdmFilterBuffer, w1
    mov        #FSKBpDl,w0             ;Clear BPF delay line
    add        w0, w1, w0
    mov        #SIZEOFFSK_YBSS_2,w1
    call       _ClearStruct

    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.endif

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------
 
                  
