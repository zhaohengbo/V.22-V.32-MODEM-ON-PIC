/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               V23.S                                              *
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
;  V23 data pump implementation for Microchip's dsPIC30F 16-bit MCU           *
;  Description:   This Code implemented according to ITU-T V.23 modem         *
;                 Standard.This Uses FSK Modulation for Data Transmission.    *
;                 This modem is used for applications like caller-ID detection*
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;                                                                             *
;******************************************************************************
;  InitializeV23                                                              *
;  ======================                                                     *
;  Description: This Function initializes the parameters for V23 mode.        *
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
;  Functions Called:   ClearV23Vars                                           *
;                                                                             *
;******************************************************************************
;  V23LoopBack                                                                *
;  ======================                                                     *
;  Description: This Function initializes the parameters for digital          *
;               loop back operation of the datapump in v23 mode               *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w2,w3             used not restored                                   *
;                                                                             *
;  Functions Called:   SetTransmiter,SetReceiver,InitializeV23                *
;                                                                             *
;******************************************************************************
;  StartV23                                                                   *
;  ======================                                                     *
;  Description: In this function both the transmitter and the receiver are    *
;               configured in the V.23 mode. The transmission of continuous   *
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
;  Functions Called:   SetTransmiter,SetReceiver,InitializeV23                *
;                                                                             *
;******************************************************************************
;  V23Transmiter                                                              *
;  ======================                                                     *
;  Description: This Function generates the Transmit Samples in V23 mode      *
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
;  V23Receiver                                                                *
;  ======================                                                     *
;  Description: This Function process the received Samples in V23 mode        *
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
;  Functions Called:   fir, AGC, V23Demod                                     *
;                                                                             *
;******************************************************************************
;  V23Demod                                                                   *
;  ======================                                                     *
;  Description: This function is used for demodulation of V23 signal.         *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2,w3,w4,w5,w6,w7,w8,w9  used not restored                          *
;   Acc A                          used not restored                          *
;                                                                             *
;  Functions Called:   ButterWorth,EnableDataTransfer,SendMessageToHost       *
;                      FreezeAGC                                              *
;                                                                             *
;******************************************************************************
;  ClearV23Vars                                                               *
;  ======================                                                     *
;  Description: This function clears V23 variables.                           *
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
;  Stack Usage in 16-bit Words :   5                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     InitializeV23:      155                                                 *
;     V23LoopBack:        17                                                  *
;     StartV23:           23                                                  *
;     V23Transmiter:      32                                                  *
;     V23Receiver:        31                                                  *
;     V23Demod:           116                                                 *
;     ClearV23Vars:       17                                                  *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     V23Bp75:            31                                                  *
;     V23WbBp1500Coefs:   31                                                  *
;     V23WbBp1500Coefs:   31                                                  *
;     V23Lpf75:            6                                                  *
;     V23Lpf600:           6                                                  *
;     V23Lpf1200:          6                                                  *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;     .nbss:             SIZEOFFSK_NBSS                                       *
;     .ybss:             67                                                   *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     InitializeV23:     72                                                   *
;     V23LoopBack:       19                                                   *
;     StartV23:          25                                                   *
;     V23Transmiter:     33                                                   *
;     V23Receiver:       33                                                   *
;     V23Demod:          91                                                   *
;     ClearV23Vars:      19                                                   *
;                                                                             *
;*****************************************************************************/


; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "V23.inc"
    .include "v21.inc"
    .include "Tables.inc"
    .include "Modem.inc"
    .include "filter.inc"
    .include "apiasm.inc"
    .include "defs.inc"
    .include "data.inc"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if DEF_V23 == 1

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _InitializeV23
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function clears all the parameters in V23 data 
;                 structure all the transmit and receive parameters are
;                 initialized.
; -----------------------------------------------------------------------------

_InitializeV23:

    push       PSVPAG

    rcall      ClearV23Vars
    
    
    mov        #MTV23, w0
    mov.b      wreg, modemType         ;Set the FSK modem type
    mov        #ORIGINATE, w0
    and.b      modemMode, wreg         ;check modem is in Originate mode
    bra        z, TOANSMODE

    mov        #(RXDATABUFLEN-25),w0
    mov        w0,dataXoffLimit

    mov        #(RXDATABUFLEN-28),w0
    mov        w0,dataXonLimit
    
    mov        #1, w0   
    cp.b       ucConnectRate           ;check for Transmission rate
    bra        nz, TO1200FREQ
    
    mov.b      wreg, FSKRxBand 
    goto       TRANSMIT_75             ;Transmit at 75 Bauds
TO1200FREQ:

    mov        #2, w0
    mov.b      wreg, FSKRxBand         ;Initialize for 1200Hz 
    
TRANSMIT_75:

    clr.b      FSKTxBand
    goto       TRANSMIT_RATE
    
TOANSMODE:

    mov       #ANSWER, w0
    and.b     modemMode, wreg          ;check whether modem in Ans mode
    bra       z, TOLOOPBACK
    
    mov       #1, w0   
    cp.b      ucConnectRate            ;check for Receive rate
    bra       nz, TO1200FREQ1
    
    mov.b     wreg, FSKTxBand 
    goto      RECEIVE_75               ;Receive msg at 75 bauds
TO1200FREQ1:

    mov       #2, w0
    mov.b     wreg, FSKTxBand
    
RECEIVE_75:

    clr.b     FSKRxBand
    goto      TRANSMIT_RATE   

TOLOOPBACK:
    
    mov       #ANALOGLOOPBACK, w0
    and.b     modemMode, wreg          ;check if modem in LoopBack state
    bra       z, TRANSMIT_RATE
    
    mov       #1, w0   
    cp.b      ucConnectRate            ;check for Transmission rate
    bra       nz, TO1200FREQ2
    
    mov       #1, w0
    mov.b     wreg, FSKTxBand 
    goto      EQUATETXRXRATE           ;Transmit and Receive at same rate
TO1200FREQ2:

    mov       #0, w0
    cp.b      ucConnectRate
    bra       nz,  TRANSMIT75
    
    mov       #2, w0
    mov.b     wreg, FSKTxBand
    goto      EQUATETXRXRATE
    
TRANSMIT75:

    clr.b     FSKTxBand
    
EQUATETXRXRATE:

    mov.b     FSKTxBand, wreg
    mov.b     wreg, FSKRxBand          ; Equating Tx and Rx rate  
              
TRANSMIT_RATE:

    cp0.b     FSKTxBand                ;Check Tx rate is 75 Bauds
    bra       z, TO_75
    
    mov       #1, w0
    cp.b      FSKTxBand                ;Check Tx rate is 600 Bauds
    bra       z, TO_600
    
    mov       #2, w0
    cp.b      FSKTxBand                ;Check Tx rate is 1200 Bauds
    bra       z, TO_1200
    goto      RECEIVERATE
    
TO_75:

    mov       #V23_1_75, w2            ;advance for 390Hz, for ones
    mov       #V23_0_75, w3            ;advance for 450Hz, for zeroes
    mov       #V23IPFACTOR75, w0       ;Interpolation Factor for 75 Bauds
    
    mov       w2, FSKMarkAdvance
    mov       w3, FSKSpaceAdvance
    mov.b     wreg, FSKTxIpFactor
    
    goto      RECEIVERATE
    
TO_600:

    mov       #V23_1_600, w2           ;advance for 1300Hz, for ones
    mov       #V23_0_600, w3           ;advance for 1700Hz, for zeroes
    mov       #V23IPFACTOR600, w0      ;Interpolation Factor for 600 Bauds
    
    mov       w2, FSKMarkAdvance
    mov       w3, FSKSpaceAdvance
    mov.b     wreg, FSKTxIpFactor
    
    goto      RECEIVERATE        
    
TO_1200:

    mov       #V23_1_1200, w2          ;advance for 1300Hz, for ones
    mov       #V23_0_1200, w3          ;advance for 2100Hz, for zeroes
    mov       #V23IPFACTOR1200, w0     ;Interpolation Factor for 1200 Bauds
    
    mov       w2, FSKMarkAdvance
    mov       w3, FSKSpaceAdvance
    mov.b     wreg, FSKTxIpFactor
    
RECEIVERATE:

    cp0.b     FSKRxBand                ;Check Rx Rate for 75 Bauds
    bra       z, TO_75Rx
    
    mov       #1, w0
    cp.b      FSKRxBand                ;Check Rx Rate for 600 Bauds
    bra       z, TO_600Rx
    
    mov       #2, w0
    cp.b      FSKRxBand                ;Check Rx Rate for 1200 Bauds
    bra       z, TO_1200Rx
    goto      ENDRECEIVERATE    

TO_75Rx:

      
    mov        #psvpage(V23Bp75),w2
    mov        w2, PSVPAG
    mov        #psvoffset(V23Bp75),w2  ;Set filter coeffs for 75 baud rate
       
    
    mov        #V23_B1_420, w3            
    mov        #V23IPFACTOR75, w0
           
    mov        #psvpage(V23Lpf75),w4
    mov        w4, PSVPAG
    mov        #psvoffset(V23Lpf75),w4
    
    mov        w2, FSKBpCoefPtr        ;set the pointer to bandpass filter coeffs
    mov        w3, FSKFmultFactor0     ;Linear Interpolation coefficient
    mov.b      wreg, FSKRxIpFactor
    mov        w4, FSKLpCoefsPtr       ;set the pointer to low pass filter coeffs
    goto       ENDRECEIVERATE
    
TO_600Rx:

       
    mov        #psvpage(V23WbBp1500Coefs),w2
    mov        w2, PSVPAG
; Set filter coeffs for 600 baud rate    
    mov        #psvoffset(V23WbBp1500Coefs),w2 
    
    mov        #V23_B1_1500, w3
    mov        #V23IPFACTOR600, w0
        
    mov        #psvpage(V23Lpf600),w4
    mov        w4, PSVPAG
    mov        #psvoffset(V23Lpf600),w4
    
    mov        w2, FSKBpCoefPtr        ;set pointer to bandpass filter coeffs
    mov        w3, FSKFmultFactor0     ;Linear Interpolation coefficient
    mov.b      wreg, FSKRxIpFactor
    mov        w4, FSKLpCoefsPtr       ;set pointer to low pass filter coeffs
    goto       ENDRECEIVERATE    
    
TO_1200Rx:

    mov        #psvpage(V23WbBp1700Coefs),w2
    mov        w2, PSVPAG
; Set filter coeffs for 1200 baud rate    
    mov        #psvoffset(V23WbBp1700Coefs),w2  
        
    mov        #V23_B1_1700, w3
    mov        #V23IPFACTOR1200, w0
    mov        #psvpage(V23Lpf1200),w4
    mov        w4, PSVPAG
    mov        #psvoffset(V23Lpf1200),w4
    
    mov        w2, FSKBpCoefPtr        ;set pointer to bandpass filter coeffs
    mov        w3, FSKFmultFactor0     ;Linear Interpolation coefficient
    mov.b      wreg, FSKRxIpFactor
    mov        w4, FSKLpCoefsPtr       ;set pointer to low pass filter coeffs
    
ENDRECEIVERATE:

    mov        #handle(_Get1s), w2
    mov        w2, dataTxBitFn         ;Initialize Tx func pointer to Get 1's
    
    mov        #handle(_NullFunction), w2
    mov        w2, dataRxBitFn         ;Initialize Rx func ptr to Null function
    
    mov        #(0x10|0x6), w0
    mov.b      wreg, mdmRCTxRatio
    
/* FIR Initialization */

    mov        #mdmFilterBuffer,w1
    mov        #FSKBpDl,w0
    add        w0, w1, w0
    mov        w0,FSKBpDlPtr           ;delay pointer
    
;calculates the end address for the circular buffer    
    add        #((V23BPFILTERLEN*2)-1),w0  
    mov        w0,FSKBpDlEnd

    mov.b      FSKRxIpFactor, wreg
    pop        PSVPAG
    mov.b      wreg, FSKChangeCount   
    
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
   
    .global _V23LoopBack
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function is used for checking the loop back
;                 operation of the datapump in V23 mode.This function 
;                 initializes the parameters for both transmission and
;                 reception.
; -----------------------------------------------------------------------------

_V23LoopBack:

    mov       #0x1000, w2
    clr.b     modemStatus              ;Clear the modem status initially       
    
    mov       w2, mdmTxGainFactor      ;set the Tx gain
    
    mov       #handle(_V23Transmiter), w0
    call      _SetTransmiter

    mov       #handle(_V23Receiver), w0
    call      _SetReceiver       
            
    rcall     _InitializeV23           ;Initialize V23 state variables

    mov       #handle(_Get1s), w3
    mov       w3, dataTxBitFn
    
    return        
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
   
    .global _StartV23
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   This function sets up the Full Duplex Mode of V23.
;                 Here both the transmitter and the receiver are configured 
;                 in the V.23 mode. The transmission of continuous binary 
;                 1's is set up. 
; -----------------------------------------------------------------------------

_StartV23:

    rcall     _InitializeV23
    
    mov       #0x1000, w2
    mov       w2, mdmTxGainFactor      ;set Tx gain
    
    mov       #MTV23, w0
    mov.b     wreg, modemType          ;Set FSK modem type 
    
    mov       #handle(_V23Transmiter), w0
    call      _SetTransmiter           ;Point to V23 Transmitter

    mov       #handle(_V23Receiver), w0
    call      _SetReceiver             ;Point to V23 Receiver
    
    clr.b     modemStatus              ;Clear the modem status initially
    
    mov       #handle(_Get1s), w3
    mov       w3, dataTxBitFn
    
    call      _InitializeAGC
    
    mov       #0x400, w4
    mov       w4, AGCTC
    
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V23Transmiter
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

_V23Transmiter:

        
    cp0.b     FSKTxSampleCnt
    bra       nz, DECSAMPLECNTR        ;check for samples count
    
    mov.b     FSKTxIpFactor, wreg
    mov.b     wreg, FSKTxSampleCnt     ;Reset the samples counter
    
    cp0       FSKTxBaudCount           ;check for Bauds count
    bra       z, GET_TRANSMITDATA 
    
    dec       FSKTxBaudCount           ;Decrement the Baud count
    
GET_TRANSMITDATA:

    mov       dataTxBitFn, w0 
    call      w0
    
    mov       #FSKCarAdvance, w8
    cp0       w0
    bra       z, SPACEADV
    
    mov       FSKMarkAdvance, w2
    mov       w2, [w8]                 ;Init carrier advance with Mark 
    goto      DECSAMPLECNTR
    
SPACEADV:

    mov       FSKSpaceAdvance, w2
    mov       w2, [w8]                 ;Init carrier advance with Space 

DECSAMPLECNTR:       
    
    mov       #FSKCurPhase, w4
    dec.b     FSKTxSampleCnt
    mov       FSKCarAdvance, w2
    add       w2, [w4], [w4]           ;update the phase with carrier advance
    
    mov       [w4], w0
    call      _SinCos                  ;Modulation  
    
    mov       w0, w4
    mov       #0x6f0, w5
    mpy       w4*w5, A
    sac.r     A, w0                    ;Sample ready for transmission
    
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
   
    .global  _V23Receiver
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   In the receiver, an FIR band pass filter is used to cut of,
;                 out of band signal.Since, FSK signaling doesn't provide for
;                 any synchronizing signals,the band pass output level is 
;                 compared with the total signal power to estimate the 
;                 presence of FSK signal.
; -----------------------------------------------------------------------------

_V23Receiver:

     ;FIR INITIALIZATION
    
    mov        #V23BPFILTERLEN, w3    
    mov        FSKBpDlPtr,w10          ;delay line pointer in w10

    mov        FSKBpCoefPtr, w8
    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND

    clr        MODCON                  ;clears MODCON
    mov        #0x00a0, w4             ;set  YMD 
    mov        w4, MODCON              ;load the MODCON
    bset       MODCON, #14             ;enable Y Modulus Addressing 

    mov        #mdmFilterBuffer, w5
    mov        #FSKBpDl,w1         
    add        w1, w5, w1        
    mov        FSKBpDlEnd,w5           ;delay line end address        
    
    mov        w1,YMODSRT              ;initialize Y Modulus Start register 
    mov        w5,YMODEND              ;initialize Y Modulus End register    
    mov        mdmADCSample, w2
    
    mov        w2, [w10]               ;Update delay line
    nop
    clr        A, [w10]+=2, w5         ;clear ACCA and prefetch X and Y data
    mov        w10,FSKBpDlPtr
    
    call       _fir  
    
    pop       YMODEND                 ;Restore context of YMODEND
    pop       YMODSRT                 ;Restore context of YMODSRT
    pop       MODCON                  ;Restore the status of MODCON
    nop

    push      w0
    call      _CheckCarrierCondition
    pop       w0
     
    call      _AGC
     
    cp0       w0                       ;Check if sample is ready for demod
    bra       z, NO_DEMOD
    
    rcall     _V23Demod                ;Perform Demodulation
     
NO_DEMOD:     

     return   
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _V23Demod
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description:   In the V23 demodulator, the instantaneous sample is
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

_V23Demod:

     mov        AGCOutput, w2
     sl         w2, #1, w3
     
     mov        #1, w0
     cp.b       FSKRxBand
     bra        lt,  NEXT_CHECK
     
     mov        FSKDsmp1, w5
     mov        w3, w4
     mpy        w4*w5, A               ;Multiply rxsample with the PI/2 
     sac.r      A, w2                  ;delayed sample and adjust the gain of 
     mov        w2, FSKIpSample        ;the signal for demodulation.
     
     mov        FSKFmultFactor0, w4
     mov        FSKDsmp0, w5
     
     mpy        w4*w5, A
     sac.r      A, w2
     
     add        w2, w3, w2
     mov        w2, FSKDsmp1
     mov        w3, FSKDsmp0
     goto       FILTERING

NEXT_CHECK:
     
     sl         w3, #1, w3
     
     mov        #FSKDsmp0, w4
     mov        #FSKDsmp1, w5
     mov        #FSKDsmp2, w6
     mov        #FSKDsmp3, w7
     mov        #FSKDsmp4, w8
     mov        #FSKDsmp5, w9
     
     mov        [w8], [w9]
     mov        [w7], [w8]
     mov        [w6], [w7]
     mov        [w5], [w6]
     mov        [w4], [w5]
     
     mov        w3, [w4]
     
     mov        [w9], w2
     mov        [w8], w1
     sub        w2, w1, w4
     mov        FSKFmultFactor0, w5
     
     mpy        w4*w5, A
     sac.r      A, w2
     
     mov        [w8], w5
     add        w2, w5, w4
     
     mov        FSKDsmp0, w5
     
     mpy        w4*w5, A
     sac.r      A, w2
     
     mov        w2, FSKIpSample
     
FILTERING:

     mov        #mdmFilterBuffer, w1
     mov        #FSKLpDl, w0
     add        w0, w1, w0
     mov        FSKLpCoefsPtr, w1      ;Pointer to LP filter coefficients
     mov        FSKIpSample, w2        ;Input sample to the filter
              
     call       _ButterWorth           ;Low pass filtering done to remove high
     mov        w0, FSKIpSample        ;frequency component
     
     mov        #mdmFilterBuffer, w3
     mov        #FSKLpDl, w0
     add        w0, w3, w0
     mov        #(BUTTERDLINELEN*2), w3
     add        w3, w0, w0
     mov        FSKLpCoefsPtr, w1      ;Pointer to LP filter coefficients
     mov        FSKIpSample, w2        ;Input sample to the filter
     
     call       _ButterWorth
     
     mov        w0, FSKIpSample
     
     dec.b      FSKChangeCount         ;Check for zero crossing
     bra        z, UPDCHANGE_COUNT
     
     mov        w0, w4
     mov        FSKLpOp, w5
     
     mpy        w4*w5, A
     
     mov        ACCAL, w0
     mov        ACCAH, w1
     sub        w0, #0, w0
     subb       w1, #0, w1
           
     bra        gt, UPD_LPOP
     
     mov        #0, w0
     mov.b      FSKRxIpFactor, wreg
     lsr        w0, #1, w0
     
     mov.b      wreg, FSKChangeCount   ;Reinitiailize the Change count at 
                                       ;the point of zero crossing
     goto       UPD_LPOP
     
UPDCHANGE_COUNT:

     mov.b      FSKRxIpFactor, wreg
     mov.b      wreg, FSKChangeCount

     cp0        FSKIpSample
     bra        lt, NEXTVAL
     mov        #1, w3
     goto       CHK_MDMTYPE
 
NEXTVAL:    
     
     mov        #0, w3
     
CHK_MDMTYPE:

     mov        dataRxBitFn, w1
     mov        w3, w0
     push       w3                     ;Put the decoded bit in the Receive
                                       ;buffer through a function
     call       w1   
     
     pop        w3
     mov        #MTV23, w0
     cp.b       modemType              ;Check is it FSK modem    
     bra        nz, UPD_LPOP
     
     mov        #CARRIERDETECT, w0
     and.b      modemStatus, wreg      ;Check for carrier
     bra        nz, UPD_LPOP
     
     cp0        w3
     bra        z, SETCNTRZERO
     
     mov        #20, w2
     
     mov.b      FSKValidCntr, wreg
     
     inc.b      FSKValidCntr           ;Increment 1's valid counter
     
     cp.b       w0, w2
     
     bra        le, UPD_LPOP
     
     call       _EnableDataTransfer    ;Enable the data transfer after 
    
     mov        #mCONNECT, w0          ;validating 20 binary 1's
     mov.b      wreg, mesgMsgId

     mov        #1, w0     
     mov.b      wreg,mesgMsgLen
     mov        #mesgMsgParams, w8

     mov       #V23_MODE,w0
     mov.b     w0, [w8]    

     call       _SendMessageToHost     ;Send the msgs to Host

.if DEF_DEBUG == 1
    mov        #V23_CONNECT, w0
    call       _SendDebugInfo
.endif    

     
     call       _FreezeAGC             ;Freeze AGC
     goto       UPD_LPOP
     
SETCNTRZERO:
     clr.b      FSKValidCntr           ;Reset 1's Valid counter
          
     
UPD_LPOP:

     mov        FSKIpSample, w0
     mov        w0, FSKLpOp
     
     return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global ClearV23Vars
    .section  .libsm, "x"

ClearV23Vars:

    mov        #FSKValidCntr, w0
    mov        #SIZEOFFSK_BSS_1, w1
    call       _ClearStructByte            ;Clear all V.21 variables

    mov        #FSKTxBaudCount, w0
    mov        #SIZEOFFSK_BSS_2, w1
    call       _ClearStruct            ;Clear all V.21 variables

    mov        #mdmFilterBuffer, w1
    mov        #FSKLpDl,w0             ; Init delay line
    add        w0, w1, w0
    mov        #SIZEOFFSK_YBSS_1,w1
    call       _ClearStruct

    mov        #mdmFilterBuffer, w1
    mov        #FSKBpDl,w0             ; Init delay line
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
                 
