/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               V22BIS.S                                           *
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
; 0.1   05 August 2002   Code Created                                Ravi     *
; 0.2   07 August 2002   Code Reviewed                               Raghava  *
; 0.3   12 August 2002   Modified file/function header               Ravi     *
; 0.4   23 August 2002   Corrected code documentation faults         Ravi     *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  V22bis implementation for Microchip's dsPIC30F 16-bit MCU.                 *
;  Description: The V.22/V.22bis is a full duplex modem for data transmission *
;               upto 2400 BPS on the PSTN. The full duplex data transmission  *
;               is achieved by separating the transmission and the reception  *
;               bands. The characteristics of the V.22 modems are given below.*
;               Baud rate        600 Symbols/sec                              *
;               Sampling rate    7200 Hz                                      *
;               Bit Rates        1200 and 2400 BPS                            *
;               Carrier frequencies 1200 for Originate and 2400 for Answer    *
;               modes                                                         *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;  StartV22:                                                                  *
;  ======================                                                     *
;  Description: This starts the v22 handshake functioning.                    *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0 used not restored                                *
;                                                                             *
;  Functions Called:  InitV22Modem                                            *
;******************************************************************************
;                                                                             *
;  InitV22Modem:                                                              *
;  ======================                                                     *
;  Description: This function is used to initialize the parameters for        *
;               V22bis.                                                       *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w1, w2, w3       used not restored                                   *
;    PSVPAG               used saved and restored                             *
;                                                                             *
;  Functions Called:  ClearV22Vars, SetTransmiter, SetReceiver, InitPsf       *
;                     InitEqz, InitializeAGC, InitCarSync, SetCarrecPll,      *
;                     InitTrnDetector, InitV22OriginateMode,                  *
;                     InitV22AnswerMode, InitV22LoopBack                      *
;                                                                             *
;******************************************************************************
;  V22LoopBack:                                                               *
;  ======================                                                     *
;  Description: This function starts the V22 modem in loopback mode by        *
;               initializing the parameters for V22 modem.                    *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0 used not restored                                *
;                                                                             *
;  Functions Called:  InitV22Modem                                            *
;                                                                             *
;******************************************************************************
;  InitV22LoopBack:                                                           *
;  ======================                                                     *
;  Description: This function initializes all the parameters required for v22 *
;               loopback.                                                     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;    PSVPAG                     used saved and restored                       *
;                                                                             *
;  Functions Called:  StartV22LB                                              *
;                                                                             *
;******************************************************************************
;  InitV22OriginateMode:                                                      *
;  ======================                                                     *
;  Description: This function initializes all the parameters required for v22 *
;               originate mode.                                               *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;    PSVPAG                     used saved and restored                       *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  InitV22AnswerMode:                                                         *
;  ======================                                                     *
;  Description: This function initializes all the parameters required for v22 *
;               answer mode.                                                  *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;    PSVPAG                     used saved and restored                       *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  StartV22LB:                                                                *
;  ======================                                                     *
;  Description: This function starts the V22 loopback by initializing the     *
;               parameters for V22 modem.                                     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;                                                                             *
;  Functions Called:  InitS1Encoder                                           *
;******************************************************************************
;  V22Transmiter:                                                             *
;  ======================                                                     *
;  Description: This functions generates a transmit sample on every call.     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w4, w5, w8, w9, w11  used not restored                        *
;   AccA, AccB                       used not restored                        *
;                                                                             *
;  Functions Called:  Psf, Sin_Cos, SendSample, V22TxSwitch (function pointer)*
;                     UpdatePsf                                               *
;                                                                             *
;******************************************************************************
;  V22DataEncoder:                                                            *
;  ======================                                                     *
;  Description: This function implements data encoder for both 1200 and       *
;               2400 bit rate.                                                *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w3, w4, w5, w6, w8 used not restored                          *
;    PSVPAG                     used saved and restored                       *
;                                                                             *
;  Functions Called:  dataTxBitFn, V22Scrambler                               *
;                                                                             *
;******************************************************************************
;  V22Scrambler:                                                              *
;  ======================                                                     *
;  Description: This function implements the v22 scrambler polynomial.        *
;                                                                             *
;  Input:  w0 = base address of V22 data structure                            *
;          w1 = bit                                                           *
;                                                                             *
;  Output: w0 = Ds                                                            *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w1, w2, w3, w4, w5, w6 used not restored                             *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  V22Receiver:                                                               *
;  ======================                                                     *
;  Description: This executes the receiver processes when ModemReceiver is    *
;               programmed to V22Receiver.                                    *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w3, w4, w5, w6, w7, w8, w10  used not restored                *
;   AccA                                     used not restored                *
;   YMODSRT, YMODEND                         used saved and restored          *
;   MODCON                                   used saved and restored          *
;                                                                             *
;  Functions Called:  fir, AGC, Hilbert, Sin_Cos, UpdateEqz, TrnDetector,     *
;                     V22BaudReceiver                                         *
;******************************************************************************
;  V22BaudReceiver:                                                           *
;  ======================                                                     *
;  Description: This executes the baud receiver processes when ModemReceiver  *
;               is programmed to V22Receiver.                                 *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w4, w5, w6, w7, w8 used not restored                                  *
;   AccA                   used not restored                                  *
;                                                                             *
;  Functions Called:  Sin_Cos, V22Equalize, V22DecFnPtr, FindEqzError,        *
;                     V22AdaptEqz,CarrierSync, Flock, EstimateMSE, V22RxSwitch*
;******************************************************************************
;  V22Descrambler:                                                            *
;  ======================                                                     *
;  Description: This function implements the v22 descrambler polynomial.      *
;                                                                             *
;  Input:  w0 = address of DescrState                                         *
;          w1 = bit                                                           *
;                                                                             *
;  Output: w0 = Ds                                                            *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w4, w5, w6 used not restored                                  *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  V22Dec1200:                                                                *
;  ======================                                                     *
;  Description: This function implements the decoding algorithm for 1200bps.  *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;    w0, w1, w2, w3, w4, w5, w6, w7, w8, w9  used not restored                *
;    AccA, AccB                              used not restored                *
;    PSVPAG                     used saved and restored                       *
;                                                                             *
;  Functions Called:  GetQuadrant, V22Descrambler, PutReceiveData             *
;                                                                             *
;******************************************************************************
;  V22Dec2400:                                                                *
;  ======================                                                     *
;  Description: This function implements the decoding algorithm for 2400bps.  *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w4, w5, w6, w7    used not restored                                   *
;   AccA, AccB            used not restored                                   *
;    PSVPAG                     used saved and restored                       *
;                                                                             *
;  Functions Called:  GetQuadrant, V22Descrambler, PutReceiveData             *
;******************************************************************************
;  V22ClockSync:                                                              *
;  ======================                                                     *
;  Description: The clock recovery and tracking the clock drift are           *
;               performed in this function.                                   *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w3, w4, w5    used not restored                               *
;   AccA                      used not restored                               *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  DetectS1:                                                                  *
;  ======================                                                     *
;  Description: This function is used to monitor the detection of S1.         *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1, w2 used not restored                        *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  InitS1Encoder:                                                             *
;  ======================                                                     *
;  Description: This function is used initialize the parameters for the       *
;               transmission of S1.                                           *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w1 used not restored                                *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  DetScr1:                                                                   *
;  ======================                                                     *
;  Description: This is used to Count the number of scrambled ones received.  *
;                                                                             *
;  Input:  w0 = bit                                                           *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0 used not restored                                *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  GenS1Symbol:                                                               *
;  ======================                                                     *
;  Description: This is used to Generate of S1 symbols.                       *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage:                                                     *
;   w0, w1, w2, w3, w4, w5, w6, w7 used not restored                          *
;   CORCON                         used saved and restored                    *
;    PSVPAG                     used saved and restored                       *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  GenScram1Symb:                                                             *
;  ======================                                                     *
;  Description: Generates the symbols for the transmission of scrambled ones. *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0-w7, w9 used not restored                         *
;    PSVPAG                     used saved and restored                       *
;                                                                             *
;  Functions Called:  V22Scrambler                                            *
;******************************************************************************
;  GenUnScram1Symb:                                                           *
;  ======================                                                     *
;  Description: Generates the symbols for the transmission of unscrambled ones*
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1, w2, w3, w4, w5, w6, w7 used not restored    *
;    PSVPAG                     used saved and restored                       *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  OrgTx1:                                                                    *
;  ======================                                                     *
;  Description: This function transmits Silence for initial handshake.        *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: None                                                *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  OrgTx2:                                                                    *
;  ======================                                                     *
;  Description: This function transmits silence for 456ms. Then transmit state*
;               is set to transmit unscrambled double dibit pattern (S1).     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0 used not restored                                *
;                                                                             *
;  Functions Called:  OrgTx1, OrgRetrainPoint                                 *
;******************************************************************************
;  OrgRetrainPoint:                                                           *
;  ======================                                                     *
;  Description: This function is used V22bis retrain mode for resuming the    *
;               initial hand shake                                            *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0 used not restored                                *
;                                                                             *
;  Functions Called:  StartOrgTx3, InitS1Encoder                              *
;                                                                             *
;******************************************************************************
;  OrgTx20:                                                                   *
;  ======================                                                     *
;  Description: This function is also used during retrain mode for hand shake *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: None                                                *
;                                                                             *
;  Functions Called:  GenS1Symbol, StartOrgTx3                                *
;                                                                             *
;******************************************************************************
;  StartOrgTx3:                                                               *
;  ======================                                                     *
;  Description: This function starts the transmission of scrambled binary 1's *
;               during retrain 
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w1 used not restored                                *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  OrgTx3:                                                                    *
;  ======================                                                     *
;  Description:  Transmit unscrambled double dibit pattern (S1) for 100ms.    *
;                Following this signal transmit scrambled binary 1's          *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w2 used not restored                            *
;                                                                             *
;  Functions Called:  GenScram1Symb, Setup2400ModeAns                         *
;******************************************************************************
;  OrgTx4:                                                                    *
;  ======================                                                     *
;  Description: Transmit scrambled binary 1's for 600ms at 1200bps. And then  *
;               switch to the transmission of scrambled binary 1's at 2400bps *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w2 used not restored                            *
;                                                                             *
;  Functions Called:  GenScram1Symb                                           *
;******************************************************************************
;  OrgAnsTx5:                                                                 *
;  ======================                                                     *
;  Description: Transmit scrambled binary 1's for 200ms at 2400bps and then   *
;               switch to data mode.                                          *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: None                                                *
;                                                                             *
;  Functions Called:  V22DataEncoder, V22Connected                            *
;                                                                             *
;******************************************************************************
;  V22Connected:                                                              *
;  ======================                                                     *
;  Description: V22 mode switch to data mode by executing EnableDataTransfer. *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w1 used not restored                                *
;                                                                             *
;  Functions Called:  EnableDataTransfer, SendMessageToHost                   *
;                                                                             *
;******************************************************************************
;  OrgRx1:                                                                    *
;  ======================                                                     *
;  Description: This function Wait for the detection of unscrambled binary 1's*
;               for 155ms.                                                    *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1, w2, w3 used not restored                    *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  OrgRx2:                                                                    *
;  ======================                                                     *
;  Description: This function transmits silence for 456ms. Then transmit state*
;               is set to transmit unscrambled double dibit pattern (S1).     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;                                                                             *
;  Functions Called:  Setup2400Mode                                           *
;******************************************************************************
;  Setup2400Mode:                                                             *
;  ======================                                                     *
;  Description: This function sets up the state machine to 2400bps mode.      *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w2 used not restored                            *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  OrgRx3:                                                                    *
;  ======================                                                     *
;  Description: This function Wait for 450ms before start making 2400bps      *
;               decoding.                                                     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;                                                                             *
;  Functions Called:  SetCarrecPll                                            *
;******************************************************************************
;  OrgAnsRx4:                                                                 *
;  ======================                                                     *
;  Description: This function waits for 32 consecutive bits of scrambled      *
;               binary 1's at 2400bps.                                        *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  RxConnected:                                                               *
;  ======================                                                     *
;  Description: V22 start receiving the data at 2400bps. After 600 bauds the  *
;               receive state is switch to retrain signal monitoring.         *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;                                                                             *
;  Functions Called:  InitFlock                                               *
;******************************************************************************
;  AnsTx1:                                                                    *
;  ======================                                                     *
;  Description: This function transmits silence for 75ms and then switch to   *
;               transmit unscrambled binary 1's.                              *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w1 used not restored                                *
;                                                                             *
;  Functions Called:  OrgTx1                                                  *
;******************************************************************************
;  AnsTx2:                                                                    *
;  ======================                                                     *
;  Description: This function generate symbols for unscrambled binary 1's     *
;               transmission                                                  *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1, w3, w4, w5, w6, w7 used not restored        *
;    PSVPAG                     used saved and restored                       *
;                                                                             *
;  Functions Called:  Setup2400ModeAns, Check1200Ans                          *
;******************************************************************************
;  Check1200Ans:                                                              *
;  ======================                                                     *
;  Description: This function checks for the detection of scrambled binay 1's *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1, w2 used not restored                        *
;                                                                             *
;  Functions Called:  FreezeAGC                                               *
;******************************************************************************
;  Setup2400ModeAns:                                                          *
;  ======================                                                     *
;  Description: This function sets up the state machine to 2400bps Answer mode*
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w2 used not restored                            *
;                                                                             *
;  Functions Called:  FreezeAGC, InitS1Encoder                                *
;******************************************************************************
;  AnsTx3:                                                                    *
;  ======================                                                     *
;  Description: This function Transmit S1 for 100bauds and then switch to the *
;               transmission of scrambled binary 1's for 500ms at 1200bps.    *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;                                                                             *
;  Functions Called:  GenS1Symbol                                             *
;******************************************************************************
;  AnsTx4:                                                                    *
;  ======================                                                     *
;  Description: This function transmits scrambled binary 1's for 500ms and    *
;               then switch to 16 way decisions (2400 ps mode) for the        *
;               transmission of scrambled binary 1's for 200ms at 2400bps     *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;                                                                             *
;  Functions Called:  GenScram1Symb                                           *
;******************************************************************************
;  AnsRx1:                                                                    *
;  ======================                                                     *
;  Description: This function checks for the detection of scrambled binary 1's*
;               at 1200bps(Check1200Ans) and unscrambled double dibit pattern *
;               (S1) at 1200bps.                                              *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  AnsRx2:                                                                    *
;  ======================                                                     *
;  Description: This function is used to set the step size for equalizer      *
;               training                                                      *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  AnsRx3:                                                                    *
;  ======================                                                     *
;  Description: This function Wait for 450ms and then switch to 2400bps mode  *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;                                                                             *
;  Functions Called:  SetCarrecPll                                            *
;******************************************************************************
;  InitiateV22Retrain:                                                        *
;  ======================                                                     *
;  Description: This function is used to initiate local retrain.              *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0 used not restored                                *
;                                                                             *
;  Functions Called:  SendMessageToHost, InitTrnDetector, V22Connected,       *
;                     StartRet                                                *
;******************************************************************************
;  StartRet:                                                                  *
;  ======================                                                     *
;  Description: This function is used to start the V22 retrain.               *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0, w1 used not restored                            *
;                                                                             *
;  Functions Called:  None                                                    *
;******************************************************************************
;  WaitForS1:                                                                 *
;  ======================                                                     *
;  Description: This function waits for S1 from the Remote Modem  when        *
;               Retraining has been initiated.                                *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0 used not restored                                *
;                                                                             *
;  Functions Called:  OrgRx2                                                  *
;******************************************************************************
;  ChkV22Retrain:                                                             *
;  ======================                                                     *
;  Description: This function is used to monitor the retrain condition        *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w1 used not restored                                *
;                                                                             *
;  Functions Called:  DetectS1, Setup2400ModeAns                              *
;******************************************************************************
;  ClearV22Vars:                                                              *
;  ======================                                                     *
;  Description: This function clears V22 variables.                           *
;                                                                             *
;  Input:  Void                                                               *
;                                                                             *
;  Output: Void                                                               *
;                                                                             *
;  System Resource usage: w0,w1 used not restored                             *
;                                                                             *
;  Functions Called:  ClearStruct                                             *
;******************************************************************************
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words : 22                                           *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     StartV22:                      03                                       *
;     InitV22Modem:                  77                                       *
;     InitV22LoopBack:               14                                       *
;     InitV22OriginateMode:          18                                       *
;     InitV22AnswerMode:             23                                       *
;     V22LoopBack:                   05                                       *
;     StartV22LB:                    22                                       *
;     V22Transmiter:                 54                                       *
;     V22DataEncoder:                73                                       *
;     V22Scrambler:                  26                                       *
;     V22Receiver:                   60                                       *
;     V22BaudReceiver:               63                                       *
;     V22Descrambler:                27                                       *
;     V22Dec1200:                    60                                       *
;     V22Dec2400:                    108                                      *
;     V22ClockSync:                  37                                       *
;     DetectS1:                      22                                       *
;     InitS1Encoder:                 05                                       *
;     DetScr1:                       06                                       *
;     GenS1Symbol:                   40                                       *
;     GenScram1Symb:                 40                                       *
;     GenUnScram1Symb:               29                                       *
;     OrgTx1:                        03                                       *
;     OrgTx2:                        11                                       *
;     OrgRetrainPoint:               14                                       *
;     OrgTx20:                       07                                       *
;     StartOrgTx3:                   03                                       *
;     OrgTx3:                        15                                       *
;     OrgTx4:                        13                                       *
;     OrgAnsTx5:                     10                                       *
;     V22Connected:                  05                                       *
;     OrgRx1:                        26                                       *
;     OrgRx2:                        20                                       *
;     Setup2400Mode:                 11                                       *
;     OrgRx3:                        14                                       *
;     OrgAnsRx4:                     13                                       *
;     RxConnected:                   08                                       *
;     AnsTx1:                        09                                       *
;     AnsTx2:                        36                                       *
;     Check1200Ans:                  23                                       *
;     Setup2400ModeAns:              30                                       *
;     AnsTx3:                        09                                       *
;     AnsTx4:                        11                                       *
;     AnsRx1:                        10                                       *
;     AnsRx2:                        07                                       *
;     AnsRx3:                        15                                       *
;     InitiateV22Retrain:            16                                       *
;     StartRet:                      15                                       *
;     WaitForS1:                     07                                       *
;     ChkV22Retrain:                 10                                       *
;     ClearV22Vars:                  17                                       *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     V22OrgBpCoefs                  48                                       *
;     V22AnsBpCoefs                  48                                       *
;     V22DiffEncTab                  16                                       *
;     V22Symb1200                     8                                       *
;     V22Symb2400                    32                                       *
;     V22QuadBits                     4                                       *
;     V22DiffEncTab                  16                                       *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage 16-bit Words:                              *
;     .nbss:                        SIZEOFV22_NBSS                            *
;     .bss:                         SIZEOFV22_BSS                             *
;     .ybss:                        SIZEOFV22_YBSS+SIZEOFV22_YBSS_1           *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     StartV22:                     06                                        *
;     InitV22Modem:                 99                                        *
;     InitV22LoopBack:              17                                        *
;     InitV22OriginateMode:         20                                        *
;     InitV22AnswerMode:            25                                        *
;     V22LoopBack:                  06                                        *
;     StartV22LB:                   22                                        *
;     V22Transmiter:                61                                        *
;     V22DataEncoder:               87                                        *
;     V22Scrambler:                 25                                        *
;     V22Receiver:                  76                                        *
;     V22BaudReceiver:              69                                        *
;     V22Descrambler:               27                                        *
;     V22Dec1200:                   71                                        *
;     V22Dec2400:                   152                                       *
;     V22ClockSync:                 31                                        *
;     DetectS1:                     20                                        *
;     InitS1Encoder:                07                                        *
;     DetScr1:                      07                                        *
;     GenS1Symbol:                  43                                        *
;     GenScram1Symb:                44                                        *
;     GenUnScram1Symb:              31                                        *
;     OrgTx1:                       05                                        *
;     OrgTx2:                       15                                        *
;     OrgRetrainPoint:              15                                        *
;     OrgTx20:                      10                                        *
;     StartOrgTx3:                  05                                        *
;     OrgTx3:                        8                                        *
;     OrgTx4:                       16                                        *
;     OrgAnsTx5:                    13                                        *
;     V22Connected:                 08                                        *
;     OrgRx1:                       28                                        *
;     OrgRx2:                       19                                        *
;     Setup2400Mode:                13                                        *
;     OrgRx3:                       17                                        *
;     OrgAnsRx4:                    15                                        *
;     RxConnected:                  13                                        *
;     AnsTx1:                       12                                        *
;     AnsTx2:                       34                                        *
;     Check1200Ans:                 26                                        *
;     Setup2400ModeAns:             33                                        *
;     AnsTx3:                       12                                        *
;     AnsTx4:                       14                                        *
;     AnsRx1:                       12                                        *
;     AnsRx2:                       09                                        *
;     AnsRx3:                       18                                        *
;     InitiateV22Retrain:           18                                        *
;     StartRet:                     17                                        *
;     WaitForS1:                    10                                        *
;     ChkV22Retrain:                14                                        *
;     ClearV22Vars:                 19                                        *
;                                                                             *
;*****************************************************************************/
; -----------------------------------------------------------------------------
; INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "V22.inc"
    .include "Tables.inc"

    .include "Modem.inc"
    .include "filter.inc"
    .include "data.inc"
    .include "apiasm.inc"
    .include "defs.inc"

; -------------------------------------------------------------------------
; -------------------------------------------------------------------------

.if DEF_V22 == 1    

; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
      
    .global _StartV22
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;Description: This function starts the Handshaking part of V22
; -----------------------------------------------------------------------------

_StartV22:

    rcall      _InitV22Modem
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _InitV22Modem
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is used to initialize the parameters for        
;               V22bis.                                                       
; -----------------------------------------------------------------------------

_InitV22Modem:

    push       PSVPAG
    
    mov        #MTV22BIS, w0           ;Modem type = V22bis modem
    mov.b      wreg, modemType

    clr.b      modemStatus             ;Clear the modem status initially
    
    mov        #handle(_V22Transmiter), w0
    call       _SetTransmiter

    mov        #handle(_V22Receiver), w0
    call       _SetReceiver
    
    rcall      ClearV22Vars
  
    ;PSF INITIALIZATION    
    
    mov        #psvpage(V22PsfCoefs),w2
    mov        w2, PSVPAG
    mov        #psvoffset(V22PsfCoefs),w1

    mov        #V22IPFACTOR, w0
    mov        #V22PSFCOEFSLEN, w2
    mov        #V22PSFDELAY, w3

    call       _InitPsf
    
    ;FIR INITIALIZATION

    
    mov        #mdmFilterBuffer, w3
    mov        #V22BpDlyLine,w0
    add        w0, w3, w0
    mov        w0,V22BpIpDlyPtr        
    
    ;calculates the end address for the circular buffer
    
    add        #((V22BPCOEFSLEN*2)-1),w0 
    mov        w0,V22BpIpDlyEnd

    mov        #V22EQZLEN, w0
    call       _InitEqz                ;Initialization of Equalizer
    
    call       _InitializeAGC          ;Initializes AGC
    
    call       _InitCarSync            ;Initializes Carrier Synchronization
    
    mov        #1, w0
    mov.b      wreg, CarrecStatus      ;Enable carrier recovery
    
    mov        #0x7f00, w0
    call       _SetCarrecPll
    
    mov        #handle(_V22Dec1200), w0
    mov        w0, V22DecFnPtr

    mov        #handle(_Get1s), w0
    mov        w0, dataTxBitFn

    mov        #handle(_NullFunction), w1
    mov        w1, dataRxBitFn
    
    mov        #(0x10|0x6), w0
    mov.b      wreg, mdmRCTxRatio
    
    call       _InitTrnDetector        ;Initializes Trn Detector
    
    mov        #200, w1
    mov        w1, TRNDetectScntrSet   ;TRNDetectScntrSet = 200

    mov        #12, w0
    mov.b      wreg, TRNDetectLength   ;TRNDetectLength = 12
    
    mov.b      modemMode, wreg
    and.b      #ORIGINATE, w0
    bra        z, ANSWERMODE           ;if (modemMode&ORIGINATE) = 0,
                                       ;then perform Answering Mode
    rcall      _InitV22OriginateMode   ;Initializes V22OriginateMode
    bra        EXIT_INITV22MODEM
    
ANSWERMODE:    
    
    mov.b      modemMode, wreg
    and.b      #ANSWER, w0
    bra        z, LOOPBACK             ;if (modemMode&ORIGINATE) = 0,
                                       ;then perform LoopBack
    
    rcall      _InitV22AnswerMode      ;Initialization of V22AnswerMode
    bra        EXIT_INITV22MODEM

LOOPBACK:
    rcall      _InitV22LoopBack        ;Initialization of V22LoopBack
        
EXIT_INITV22MODEM:
    pop        PSVPAG
    
    return    

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
        
    .global _V22LoopBack
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function starts the V22 modem in loopback mode by
;               initializing the parameters for V22 modem.
; -----------------------------------------------------------------------------
    
_V22LoopBack:

    rcall      _InitV22Modem           ;Initialization of V22Modem
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _InitV22LoopBack
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used for Initializing the V22 LoopBack 
;               settings
; -----------------------------------------------------------------------------
    
_InitV22LoopBack:
    
    push       PSVPAG

    rcall      _StartV22LB             ;starts the V22 LoopBack
    
    mov        #V22LC_CARRIERADVANCE, w0
    mov        w0, V22TxCarAdvance
    
    mov        w0, V22RxCarAdvance
    
    ;Initialize BP filter coefs pointr

    mov        #psvpage(V22AnsBpCoefs),w1  
    mov        w1, PSVPAG
    mov        #psvoffset(V22AnsBpCoefs), w1 
    mov        w1, V22BpCoefPtr
    
    clr        V22RxCarPhase           ;V22RxCarPhase = 0
    pop        PSVPAG
    clr        V22TxCarPhase           ;V22TxCarPhase = 0
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _InitV22OriginateMode
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used for Initializing the Modem to work in the
;               Orginate Mode
; -----------------------------------------------------------------------------
 
_InitV22OriginateMode:

    push       PSVPAG
    
    mov        #V22LC_CARRIERADVANCE, w0
    mov        w0, V22TxCarAdvance     ;V22TxCarAdvance = 0x2AAA
    mov        #V22HC_CARRIERADVANCE, w0
    mov        w0, V22RxCarAdvance     ;V22RxCarAdvance = 0x5555
    
    mov        #handle(_OrgTx1), w0
    mov        w0, V22TxSwitch
    
    mov        #handle(_OrgRx1), w0
    mov        w0, V22RxSwitch
    
    mov        #psvpage(V22OrgBpCoefs),w1
    mov        w1, PSVPAG
    mov        #psvoffset(V22OrgBpCoefs), w1 
    mov        w1, V22BpCoefPtr        ;Pointer to access the V22OrgBpCoefs
                                       ;table
    mov        #handle(_NullFunction), w1
    mov        w1, dataRxBitFn         ;Assigns Nullfunction to dataRxBitFn
                                       ;function Pointer  
    pop        PSVPAG
                                       
.if DEF_DEBUG == 1
    mov        #V22_ORG_START, w0
    call       _SendDebugInfo
.endif

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _InitV22AnswerMode
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used for Initializing the Modem to work in the
;               Answer Mode
; -----------------------------------------------------------------------------
    
_InitV22AnswerMode:

    ;Setup the carrier advances for answer mode

    push       PSVPAG
    mov        V22RxCarAdvance, w0
    mov        w0, V22RxCarPhase
    
    mov        V22TxCarAdvance, w0
    mov        w0, V22TxCarPhase
    
    mov        #V22HC_CARRIERADVANCE, w0
    mov        w0, V22TxCarAdvance
    
    mov        #V22LC_CARRIERADVANCE, w0
    mov        w0, V22RxCarAdvance
    
    ;Initialize the BP filter coefs pointer
 
    mov        #psvpage(V22AnsBpCoefs),w1
    mov        w1, PSVPAG
    mov        #psvoffset(V22AnsBpCoefs), w1 
    mov        w1, V22AnsBpCoefsPtr    ;Pointer to V22AnsBpCoefsPtr
    
    mov        V22AnsBpCoefsPtr, w1
    mov        w1, V22BpCoefPtr
    
    mov        #handle(_AnsTx1), w0
    mov        w0, V22TxSwitch
    
    mov        #handle(_NullFunction), w0
    mov        w0, V22RxSwitch
    
    mov        #46, w0
    mov        w0, V22TxBaudCntr       ;Setup timer for .075 secs

    pop        PSVPAG
    
.if DEF_DEBUG == 1
    mov        #V22_ANS_START, w0
    call       _SendDebugInfo
.endif
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _StartV22LB
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used when the V22 LoopBack needs to be
;               started
; -----------------------------------------------------------------------------
    
_StartV22LB:

    cp0.b      ucConnectRate
    bra        nz, ELSEPART            ;if the connectrate is 0 then 
                                       ;bitrate is 2400bps
    rcall      _InitS1Encoder          ;Initializes the S1 Encoder
    
    mov        #handle(_OrgTx20), w0
    mov        w0, V22TxSwitch
    
    mov        #handle(_DetectS1), w0
    mov        w0, V22RxSwitch
    
    bra        END_STARTV22LB          ;return from the function
    
ELSEPART:

    mov        #handle(_OrgTx4), w0            ;for 1200bps
    mov        w0, V22TxSwitch
    
    mov        #360, w1
    mov        w1, V22TxBaudCntr       ;V22TxBaudCntr = 360
    
    mov        #handle(_Check1200Ans), w0
    mov        w0, V22RxSwitch         ;V22RxSwitch = _Check1200Ans
    
    mov        #handle(_DetScr1), w0
    mov        w0, dataRxBitFn         ;dataRxBitFn = _DetScr1
    
    mov        #handle(_Get1s), w0
    mov        w0, dataTxBitFn         ;dataTxBitFn = _Get1s
    
END_STARTV22LB:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V22Transmiter
    .section  .libsm, "x"

; -------------------------------------------------------------------------
;  Description: This functions generates a transmit sample on every call.
;               When V22TxSampleCntr is 0, baud processing function is 
;               executed. At the start of every new baud, V22TxSampleCntr' 
;               is reset to the interpolation factor. If V22TxBaudCntr is 
;               non-zero,it is decremented.The encoder module is indirectly
;               called thro' V22TxSwitch The encoded baud is filled into 
;               the PSF delay lines by executing UpdatePSF.
;               During every sample interval the following are performed.
;               V22TxSampleCntr is decremented and PSF outputs are computed
;               by executing PulseShapeFilter. The complex PSF output 
;               (PSfOpI +j PsfOpQ) is modulated by e-j*V22TxCarPhase. 
;               The phase of the transmit carrier V22TxCarrier is updated 
;               every sample by adding, the required carrier phase advance
;               value.The modulator output is scaled and transmitted.
; -------------------------------------------------------------------------

_V22Transmiter:
    
    cp0.b      V22TxSampleCntr
    bra        nz, V22TX_SAMPL_PROC

    mov        #V22IPFACTOR, w0        ;Load the IPFACTOR
    mov.b      wreg, V22TxSampleCntr

    mov        V22TxBaudCntr, wreg
    bra        z, V22TX_BAUD_PROC

    dec        V22TxBaudCntr           ;Decrement and update Bauds
    
V22TX_BAUD_PROC:

    mov        V22TxSwitch, w0         ;Get the Address of V22DataEncoder
    call       w0

    call       _UpdatePsf              ;Update PSF delay lines
        
V22TX_SAMPL_PROC:

    dec.b      V22TxSampleCntr       

    call       _Psf                    ;Perform Pulse shape filtering

    mov        V22TxCarPhase, w0       ;Input for Sine
    mov        #0x3FFF, w1
    add        w0, w1, w1              ;Input for Cosine

    call       _SinCos                 ;computes both sin and cos 
    mov        w0, w8
    mov        w1, w9                  ;Save the outputs

    mov        #0, w12                 ;Init txsample
    bra        GET_TXSAMPLE

    mov        #ANSWER, w0
    and.b      modemMode, wreg
    bra        z, GET_TXSAMPLE

    mov        V22GrdTnSum, w0         ;Input for Sine
    call       _SinCos

    mov        w0, w4
    mov        V22GrdTnScl, w5         ;Get the Scale factor

    mpy        w4*w5, A
    sac.r      A, w1                   ;txsample
    add        w0, w1, w12

    mov        V22GrdTnAdv, w0         ;get the Advancement factor

    mov        #V22GrdTnSum, w4
    add        w0,[w4],  [w4]          ;Update trainsum

GET_TXSAMPLE:

    mov        PSFOpI, w4              ;Get the Inphase Output
    mov        w9, w5

    mpy        w4*w5, A                ;Perform Modulation

    mov        PSFOpQ, w4              ;Get Quadrature phase output
    mov        w8, w5

    mpy        w4*w5, B

    sub        A

    sac.r      A, w2                   ;Txsample is got after Modulation

    add        w12, w2, w12

    mov        V22TxCarAdvance, w0     ;Get the Carrier Phase Advance

    mov        #V22TxCarPhase, w4
    mov        #0x2130, w5
    add        w0, [w4], [w4]          ;Update the Carrier phase
    mov        w12, w4
    mpy        w4*w5, A
    sac.r      A, w0                   ; Final txsample ready for transmitting

    return

; -------------------------------------------------------------------------
; -------------------------------------------------------------------------

    .global _V22DataEncoder
    .section  .libsm, "x"
    
; -------------------------------------------------------------------------
;  Description: This function implements data encoder for both 1200 and
;               2400 bit rate
; -------------------------------------------------------------------------

_V22DataEncoder:

    push       PSVPAG
    mov        dataTxBitFn,w1
    call       w1

    mov        w0, w1                  ;Bit to be scrambled
    mov        #V22ScrState, w0        ;Pass the Address of scrambler state
    rcall      _V22Scrambler

    sl         w0, #1, w1

    push       w1     

    mov        dataTxBitFn,w1
    call       w1

    mov        w0, w1                  ; Bit to be scrambled
    mov        #V22ScrState, w0
    rcall      _V22Scrambler

    pop        w1 

    mov        #V22PrevTxPhase, w3
    add        w0, w1, w0              ; Get two scrambled bits
    mov        #0, w2
    mov.b      [w3], w2                ; Get the Prev phase of transmitter
    
    mov        V22DiffEncTabPtr, w8    ; Point w8 to V22DiffEncTab Table 
    sl         w2, #3, w2
    sl         w0, #1, w0
    add        w2, w0, w0              ; Calculate the offset needed
    nop
    mov        [w8+w0], w0             ; Get the corresponding value from 
    mov        w0, w1                  ; V22DiffEncTab
    mov.b      wreg, V22PrevTxPhase    ; Update V22PrevTxPhase
    
    mov.b      V22BitRate, wreg        ; Get the BitRate

    cp0.b      w0                      ; Check if the BitRate is 1(2,400 Baud)
    bra        nz, ENCODE_2400
    
    mov        #psvpage(V22Symb1200),w6
    mov        w6, PSVPAG
    mov        #psvoffset(V22Symb1200), w6
    mov        w6, V22Symb1200Ptr

    sl         w1, #2, w2 
    mov        V22Symb1200Ptr, w8      ; Point w8 to V22Symb1200 Table
    add        w2, #2, w3

    mov        [w8+w2], w4             ; Get the Inphase output value
    mov        [w8+w3], w5             ; Get the Quadrature phase output value

    mov        w4, PSFIpI
    mov        w5, PSFIpQ              ; Store the outputs
    bra        EXIT_ENCODER            ; Return from Encoder

ENCODE_2400:

    sl         w1, #2, w1

    push       w1
    
    mov        dataTxBitFn,w1
    call       w1

    mov        w0,w1
    mov        #V22ScrState, w0        ; Pass the Address of scrambler state
    rcall      _V22Scrambler

    pop        w1
    
    sl         w0,#1, w0
    add        w0, w1, w1                    

    push       w1

    mov        dataTxBitFn,w1
    call       w1
      
    mov        w0,w1
    mov        #V22ScrState, w0
    rcall      _V22Scrambler

    pop        w1
    add        w0, w1, w0              ; Get two scrambled bits

    sl         w0,#2, w0
    mov        V22Symb2400Ptr, w8      ; Point w8 to V22Symb2400 Table
    add        w0,#2, w1
    mov        [w8+w0], w4             ; Get the Inphase output value
    mov        [w8+w1], w5             ; Get the Quadrature phase output value

    mov        w4, PSFIpI
    mov        w5, PSFIpQ              ; Store the outputs

EXIT_ENCODER:
    pop        PSVPAG
        
    return

; -------------------------------------------------------------------------
; -------------------------------------------------------------------------

    .global _V22ClockSync
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: The clock recovery and tracking the clock drift are 
;               performed in this function.(Refer to DP design document
;               for  more explanation on this)
; -----------------------------------------------------------------------------

_V22ClockSync:

    cp0.b      V22ClkAdj
    bra        nz, EXIT_V22CLOCKSYNC
  
    mov        hilbOp_I, w4
    mov        hilbOp_Q, w5
    
    mpy        w4*w4, A                  ;hilbOp_I*hilbOp_I
    mac        w5*w5, A                  ;t=hilbOp_I*hilbOp_I+hilbOp_I*hilbOp_I
    
    sac.r      A, w1                     ;w1 = wv
    
    
    mov.b      V22RxSampleCntr, wreg
    cp.b       w0, #2
    bra        nz, CMP_RX_SAMPLE_CNTR
    
    mov        w1, V22SmpEarlyEng
    bra        EXIT_V22CLOCKSYNC
        
CMP_RX_SAMPLE_CNTR:

    cp.b       w0, #10
    bra        nz, EXIT_V22CLOCKSYNC     ;if V22RxSampleCntr is not zero return

    mov        w1, V22SmpLateEng
    mov        V22SmpEarlyEng, w2
    sub        w1, w2, w3                ;now w3 = wv
    
    cp0.b      V22ClkAdj
    bra        nz, EXIT_V22CLOCKSYNC     ;if V22ClkAdj is not zero return
    
    mov        V22SmpMidEng,w2
    cp0        w2
    bra        z, STARTCOARSE
    
    dec        w2,w2
    mov        w2,V22SmpMidEng              ;Decrements V22SmpMidEng
    return
    
STARTCOARSE:
    mov        #0x20, w6
    sub        w3, w6, w4
    cp0        w4
    bra        lt, DECRRXSPLCNTR
    
    inc.b      V22RxSampleCntr           ;Increments V22RxSampleCntr
    mov        #2, w5
    mov        w5, V22SmpMidEng
    return
    
DECRRXSPLCNTR:
    mov        #0x20, w6
    add        w3, w6, w4
    cp0        w4
    bra        gt, EXIT_V22CLOCKSYNC
    
    dec.b      V22RxSampleCntr           ;Decrements V22RxSampleCntr
    mov        #2, w5
    mov        w5, V22SmpMidEng
    
EXIT_V22CLOCKSYNC:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V22Scrambler
    .section  .libsm, "x"
    
; -------------------------------------------------------------------------
;  Description: This function implements the V22 Scrambler polynomial
; -------------------------------------------------------------------------

_V22Scrambler:

    mov        w0, w2

    mov        #64, w0
    cp.b       V22ScrOnesCntr          ; Check for max count of ones
    bra        nz, NO_RESETCNTR

    xor        #1, w1
    clr.b      V22ScrOnesCntr          ; reset the ones counter

NO_RESETCNTR:

    mov        [w2], w4
    mov        [w2+2], w5              ; get the scrambler state

    and        w1,#1, w3

    asr        w4, #13, w6
    and        w6, #1, w6

    and        w5, #1, w0

    xor        w3, w6, w6              ; Implementing the scrambler polynomial
    xor        w6, w0, w0              ; get the scrambled bit Ds

    asr        w4, #15, w5

    sl         w4, #1, w4

    ior        w4, w0, w4

    mov        w4, [w2]
    mov        w5, [w2+2]              ; Update the scrambler state 

    cp0        w0                      ; Chk scrambled bit for zero
    bra        z, RESETCNTR

    inc.b      V22ScrOnesCntr          ; Increment ones counter
    goto       EXIT_SCRAMBLER

RESETCNTR:
    clr.b      V22ScrOnesCntr          ; Reset ones counter

EXIT_SCRAMBLER:

    return                             ; Return from scrambler

; -------------------------------------------------------------------------
; -------------------------------------------------------------------------

    .global _V22Receiver
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: :   This executes the receiver processes when ModemReceiver is
;                   programmed  to V22Receiver.
;                   During every sample interval the following procedures are
;                   executed.
;                   1.  Filter the I/P signal
;                   2.  Run AGC and abort further processing if EnergyStat is 0
;                   3.  AgcOutput is passed thro'the hilbert filter and the 
;                       function
;                       Hilbert returns both the real delayed sample and 
;                       the corresponding quadrature component  of the signal.
;                   4   The Hilbert output is demodulated using the carrier 
;                       -V22RxCarrier. 
;                   5.  The clock drift tracking function V22ClockSync, is also
;                       executed.
;                   6.  If V22RxSampleCntr is 0, then receive baud processing 
;                       procedures are executed.The receive sample counter 
;                       V29RxSampleCntr is decremented every sample.
;                   7.  The receive carrier V22RxCarrier is also advanced every
;                       sample.
; -----------------------------------------------------------------------------

_V22Receiver:

    ;FIR INITIALIZATION
    call        _CheckCarrierCondition  
    mov         #V22BPCOEFSLEN, w3    
    mov         V22BpIpDlyPtr,w10      ;delay line pointer in w10
    
    push       MODCON                  ;Save the status of MODCON
    push       YMODSRT                 ;Save context of YMODSRT
    push       YMODEND                 ;Save context of YMODEND

    mov         V22BpCoefPtr, w8       ;filter coefficients in w8
                 
    clr         MODCON                 ;clears MODCON
    mov         #0x00a0, w4            ;set  YMD 
    mov         w4, MODCON             ;load the MODCON
    bset        MODCON, #14            ;enable Y Modulus Addressing 

    mov         #mdmFilterBuffer, w5
    mov         #V22BpDlyLine,w1    
    add         w1, w5, w1
    mov         V22BpIpDlyEnd,w5       ;delay line end address        
    
    mov         w1,YMODSRT             ;initialize Y Modulus Start register 
    mov         w5,YMODEND             ;initialize Y Modulus End register    
    mov         mdmADCSample, w2
    
    mov         w2, [w10]              ;Update delay line
    nop
    clr         A, [w10]+=2, w5        ;clear ACCA and prefetch X and Y data
    mov         w10,V22BpIpDlyPtr

;Rejection of the echo signal
    
    call        _fir
    
    call        _AGC
    
    cp0.b       w0
    bra         z, EXIT_V22RECEIVER
    
    mov        AGCOutput, w0

    call       _Hilbert
    
    rcall      _V22ClockSync 
     
    mov        #1, w0
    and.b      V22RxSampleCntr, wreg   ;if V22RxSampleCntr is 0 do not
                                       ;update carrec phase
    bra        nz, UPDCARR_PHASE
     
    neg        V22RxCarPhase, wreg         
     
    mov        #0x3FFF, w1
    add        w0, w1, w1
     
    call       _SinCos
     
    mov        w0, w7
    mov        w1, w5
     
    mov        hilbOp_I, w4            ;hilbert output I in w4
    mov        hilbOp_Q, w6            ;hilbert output Q in w5
     
    mpy        w4*w5, A
    msc        w6*w7, A
    sac.r      A, w2
    mov        w2, eqzIpI              ;Equalizer input I obtained
     
    mpy        w5*w6, A
    mac        w4*w7, A
    sac.r      A, w2
    mov        w2, eqzIpQ              ;Equalizer input Q obtained
     
    mov.b      V22TotPhase, wreg
    cp.b       w0, #1
    bra        nz, UPD_EQZ             ;if V22TotPhase is 0 do not update
                                       ;Equalizer
    mov        V22RxCarPhase,w0
    call       _TrnDetector
     
UPD_EQZ:

    call       _UpdateEqz              ;Equalizer is updated
     
    cp0.b      V22RxSampleCntr
    bra        nz, UPDCARR_PHASE       ;if V22RxSampleCntr is 0 then do not
                                       ;update carrier phase
    rcall      _V22BaudReceiver
     
UPDCARR_PHASE:

    mov        V22RxCarAdvance, w2     ;update carrec phase
    mov        V22RxCarPhase, w3
     
    add        w2, w3, w3
    mov        w3, V22RxCarPhase
        
    dec.b      V22RxSampleCntr         ;decrement V22RxSampleCntr

EXIT_V22RECEIVER:     
    pop       YMODEND                 ;Restore context of YMODEND
    pop       YMODSRT                 ;Restore context of YMODSRT
    pop       MODCON                  ;Restore the status of MODCON 
    nop
    
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
     
    .global _V22BaudReceiver           
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This is the function for the baud receiver. This function is
;               called in V22Receiver once per baud
; -----------------------------------------------------------------------------

_V22BaudReceiver:

    cp0        V22RxBaudCntr
    bra        z, START_V22_RXBAUD_PROC

    dec        V22RxBaudCntr           ;decrements V22RxBaudCntr
    
START_V22_RXBAUD_PROC:

    mov        #V22IPFACTOR, w0
    mov.b      wreg, V22RxSampleCntr
   
    call       _V22Equalize
       
    mov        eqzDlyPtr, w4
    dec2       w4, w4
    sub        w4, #48
    bra        ge, EQZOUTPUT
    add        #96, w4
    
EQZOUTPUT:

    mov        #eqzDlyQ, w8
    mov        #eqzOpQ, w5
    mov        [w8+w4], w6
    add        w6, [w5], [w5]          ;Equalizer output Q
    
    mov        #eqzDlyI, w8
    mov        #eqzOpI, w5
    mov        [w8+w4], w6
    add        w6, [w5], [w5]          ;Equalizer output I
    
    mov        CarrecPhase, w0
    mov        #0x3FFF, w1
    add        w0, w1, w1
    call       _SinCos                 ;w0 = ms, w1 = mc  
 
    mov        eqzOpI, w4
    mov        w1, w5
    mpy        w4*w5, A

    mov        eqzOpQ, w6
    mov        w0, w7
    msc        w6*w7,A
    
    sac.r      A, w0                   ;Round((EqzOpI*mc)-(EqzOpQ*ms))
    sl         w0, #1, w0
    mov        w0, mdmDemI             ;mdmDemI = mdmDemI<<1

    mpy        w5*w6, A
    mac        w4*w7,A

    sac.r      A, w0                   ;Round((EqzOpQ*mc)+(EqzOpI*ms))
    sl         w0, #1, w0
    mov        w0, mdmDemQ             ;mdmDemQ = mdmDemQ<<1
    
    mov        V22DecFnPtr, w0         ;Decoder  function pointer
    call       w0

    mov        CarrecPhase, w0
    neg        w0,w0
    call       _FindEqzError           ;Finds the Baseband Error

    call       _V22AdaptEqz            ;Adapts the Equalizer taps

    call       _CarrierSync            ;Carrier Syncronization

    call       _Flock                  ;gets the sample phase adjust

    call       _EstimateMSE            ;Estimates the Mean Squareroot Error

    mov        V22RxSwitch, w1               
    call       w1

    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
          
    .global _V22Descrambler
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function implements the v22 descrambler polynomial
; -----------------------------------------------------------------------------

_V22Descrambler:

    mov        w0, w2

    cp0.b      w1                      ; Chk scrambled bit for zero
    bra        z, RESETONESCNTR

    inc.b      V22DescrOnesCntr        ; Increment ones counter
    goto       INIT_DESCRSTATE

RESETONESCNTR:
    clr.b      V22DescrOnesCntr        ; Reset ones counter

INIT_DESCRSTATE:

    mov        [w2], w4
    mov        [w2+2], w5              ; get the scrambler state

    asr        w4, #13, w6
    and        w6, #1, w6

    and        w5, #1, w0

    xor        w1, w6, w6              ; Implementing the scrambler polynomial
    xor        w6, w0, w0              ; get the scrambled bit Ds


    asr        w4, #15, w5

    sl         w4, #1, w4

    ior        w4, w1, w4

    mov        #V22DescrOnesCntr, w1   
    mov        w4, [w2]
    mov        w5, [w2+2]              ; Update the scrambler state 

    mov.b      [w1], w1
    mov        #64, w2

    cp.b       w1, w2                  ; Check for max count of ones
    bra        nz, NO_RESETONESCNTR

    xor        #1, w0
    clr.b      V22DescrOnesCntr        ; reset the ones counter

NO_RESETONESCNTR:    
    return                
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V22Dec1200
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
; Description: Decoder 1200 Dibit is decoded per Baud.The four points
;              transmitted in 1200 are 01 in each quadrant which are near
;              to the axis so a phase shift  is given to the new points
;              and the new axes is calculated from which the quadrant in
;              which the point lies is decoded from the same encoder table
;              (common for encoder and decoder).
; -----------------------------------------------------------------------------
    
_V22Dec1200:

    push       PSVPAG
    
    mov        #0x727C, w4
    mov        #0x393E, w7
    mov        mdmDemI, w5
    mov        mdmDemQ, w6

    mpy        w4*w5, A
    sac.r      A, w2                   ;Round(0x727C*mdmDemI)

    mpy        w6*w7, B
    sac.r      B, w3                   ;Round(0x393E*mdmDemQ)

    sub        w2, w3, w0              ;CoordX

    mpy        w5*w7, A

    sac.r      A, w2                   ;Round(0x393E*mdmDemI)

    mpy        w4*w6, B
    sac.r      B, w1                   ;Round(0x727C*mdmDemQ)

    add        w2, w1, w1              ;CoordY

    call       _GetQuadrant            ;gets the quadrant number
    
    mov        #psvpage(V22QuadBits),w1
    mov        w1, PSVPAG
    mov        #psvoffset(V22QuadBits), w1 
    mov        w1, V22QuadBitsPtr
       
    mov        V22QuadBitsPtr, w8      ;pointer to the V22QuadBits table
    mov        #psvpage(V22DiffEncTab),w1
    mov.b      [w8+w0], w2
    
    mov        w1, PSVPAG
    mov        #psvoffset(V22DiffEncTab), w1 
    mov        w1, V22DiffEncTabPtr
    
    mov        #psvpage(V22Symb1200),w1
    mov        w1, PSVPAG
    mov        #psvoffset(V22Symb1200), w1 
    mov        w1, V22Symb1200Ptr
    
    mov        V22DiffEncTabPtr, w8
    mov        V22Symb1200Ptr, w9

    clr        w0
    mov.b      V22PrevRxPhase, wreg    ;Get the PrevTxphase
    sl         w0, #3, w4
    sl         w2, #1, w3              ;Calculating (PrevTxPhase*4) for offset 
    add.b      w3, w4, w0              ;(PrevTxPhase*4)+ scrambled bits
    mov        #V22PrevRxPhase, w4  
    mov        [w8+w0], w0
    
    mov.b      wreg, V22RxSyncBits
    mov.b      wreg, V22BaudBits
    
    mov.b      w2, [w4]

    mov        #mdmDecI, w4
    mov        #mdmDecQ, w5
    sl         w2, #2, w2              ;Calculate the offset
    
    mov        [w9+w2], [w4]           ;Get the Inphase output value
    add.b      #2, w2
    clr        w0
    mov        [w9+w2], [w5]           ;Get the Quadrature phase output value
    
    mov.b      V22BaudBits, wreg
    lsr        w0, #1, w1
    and        w1, #0x1, w1            ;input to the V22Descrambler function
    
    mov        #V22DescrState, w0      ;another input
    
    rcall      _V22Descrambler
    
    mov        dataRxBitFn,w1
    call       w1
   
    clr        w0
    mov.b      V22BaudBits, wreg
    and        w0, #0x1, w1  
    mov        #V22DescrState, w0     
    
    rcall      _V22Descrambler    
    
    mov        dataRxBitFn,w1
    call       w1
    
    pop        PSVPAG
        
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _V22Dec2400
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: Quadbit decoder,First two bits to get the quadrant to which
;               it corresponds and the remaining two bits to represent one 
;               of four constellation points.    
; -----------------------------------------------------------------------------
    
_V22Dec2400:

    push       PSVPAG
    mov        #0x7fff, w13            ;Minimum Distance is set to 0x7fff
  
    mov        mdmDemI, w0
    mov        mdmDemQ, w1
    
    call       _GetQuadrant            ;gets the quadrant value where I 
                                       ;and Q values lie
    clr        w14
    mov        V22QuadBitsPtr, w3

    mov        #psvpage(V22Symb2400),w2
    mov.b      [w3+w0], w14            ;quadrant 
    sl         w14, #4, w1
    
    mov        w2, PSVPAG

    mov        #psvoffset(V22Symb2400), w5
    mov        w5, V22Symb2400Ptr
 
    add        w1, w5, w6              ;w6 = base address ptr
    
    mov        mdmDemI, w5
    mov        mdmDemQ, w12
    mov        #1, w3                  ;MinState
    clr        w11                     ;i

    do         #3, MIN_DISTANCE
   
    mov        [w6++], w1
    mov        [w6++], w2
    sub        w1, w5, w4              ;finds the distance of I      
    sub        w2, w12, w7             ;finds the distance of Q
    
    mpy        w4*w4, A
    sac.r      A, w9
    mpy        w7*w7, B
    sac.r      B, w10
    add        w9, w10, w9 
                                       ;calculates the Euclidean distance
    cp         w9, w13
    bra        ge, MIN_DISTANCE
    mov        w9, w13                 ;finds the minimum distance
    mov        w11, w3                 ;MinState
                        
MIN_DISTANCE:
    inc        w11, w11
    
    sl         w14, #2, w13    
    ior        w3, w13, w3
    sl         w3, #2, w2              ;calculates the Minstate
    mov        V22Symb2400Ptr, w6
    push       w3
    
    mov        [w6+w2], w1
    add        w2, #2, w2
    mov        w1, mdmDecI             ;finds I
    mov        [w6+w2], w2
    mov        w2,mdmDecQ              ;finds Q
    
    lsr        w3, #2, w6
    and        w6, #0x3, w2
    sl         w2, #1, w2
    
    clr        w0
    mov.b      V22PrevRxPhase, wreg
    sl         w0, #3, w7
    mov        V22DiffEncTabPtr, w10
    clr        w13
    add.b      w2, w7, w13
    lsr        w3, #2, w2
    
    mov        [w10+w13], w0
    mov.b      wreg, V22RxSyncBits
    mov        w0, w9                  ;w9 = bits
    push       w9
    
    and.b      w2, #0x03, w0
    mov.b      wreg, V22PrevRxPhase
    
    clr.b      V22BaudBits             ;V22BaudBits = 0
      
    mov        #V22DescrState, w0
    pop        w9
    lsr        w9, #1, w2
    push       w9
    and        w2, #0x1, w1
    rcall      _V22Descrambler         ;Descrambling
    mov.b      wreg, V22BaudBits
    
    mov        dataRxBitFn,w6
    call       w6

    mov        #V22DescrState, w0
    pop        w9
    and        w9, #0x1, w1   
    rcall      _V22Descrambler         ;Descrambling
    mov        #V22BaudBits, w12
    sl.b       w0, w4
    ior.b      w4, [w12], [w12]
   
    mov        dataRxBitFn,w6
    call       w6
            
    mov        #V22DescrState, w0
    pop        w3
    lsr        w3, #1, w13
    push       w3
    and        w13, #0x1, w1    
    rcall      _V22Descrambler         ;Descrambling
    sl         w0, #2, w4
    ior.b      w4, [w12], [w12]
    
    mov        dataRxBitFn,w6
    call       w6
           
    mov        #V22DescrState, w0
    pop        w3
    and        w3, #0x1, w1
    rcall      _V22Descrambler         ;Descrambling
    sl         w0, #3, w4
    ior.b      w4, [w12], [w12]
    
    mov        dataRxBitFn,w6
    call       w6
    pop        PSVPAG
        
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _DetectS1
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: S1 is unscrambled double dibit of 00 and 11 ie (0 and 3)
;               transmitted.S1 should be validated for atleast 20bauds and
;               then S1Detect is set which also indicates to start the 
;               scrambled ones in 1200bits per second for 600ms (TxBaudCntr
;               set for 360), this is in Orginate Mode of 2400bps After the
;               detection of S1, RxBaudcntr is set for 270(450ms) to 
;               validate scrambled ones sent from the Remote Modem.
;               If the Modem is in Answer then Txswitch is pointed to SendS1
;               and RxSwitch for  Wait450ms for 450ms.
;               When S1 is sent in the Datamode ie asking for retrain from
;               the Remote Modem then Depending upon the CarrierDetectBit 
;               set in the ModemMode Retrain is started.
; -----------------------------------------------------------------------------
    
_DetectS1:

    cp0.b      V22S1Detect
    bra        nz, EXIT_DETECTS1       ;if V22S1Detect is 1 return
    
    mov.b      V22PrevBaudBits, wreg
    mov.b      w0, w1
    
    mov.b      V22RxSyncBits, wreg
    
    add.b      w1, w0, w2
    
    cp.b       w2, #3
    bra        nz, RESET_CNTR          ;if (V22PrevBaudBits+V22RxSyncBits)
                                       ;is not 3 then reset the V22S1Cntr    
    inc.b      V22S1Cntr               ;Increment V22S1Cntr

    mov.b      V22RxSyncBits, wreg
    mov.b      wreg, V22PrevBaudBits
    
    return
    
    
RESET_CNTR:

    mov.b      V22S1Cntr, wreg         ;wreg = tmp
    clr.b      V22S1Cntr               ;V22S1Cntr = 0
  
    cp.b       w0, #20                 ;if V22S1Cntr < 20 return
    bra        lt, EXIT_DETECTS1

    mov        #1, w0
    mov.b      wreg, V22S1Detect       ;set V22S1Detect
    
    mov        #handle(_V22Dec1200), w0
    mov        w0, V22DecFnPtr
    
EXIT_DETECTS1:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _InitS1Encoder
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used initialize the parameters for the
;               transmission of S1
; -----------------------------------------------------------------------------

_InitS1Encoder:

    mov        #60, w1
    mov        w1, V22TxBaudCntr       ;Send S1 for 100 ms
    
    clr.b      V22PrevTxPhase          ;V22PrevTxPhase = 0
    
    clr.b      V22S1Dibit              ;V22S1Dibit = 0
    
.if DEF_DEBUG == 1
    mov        #V22_SENDS1, w0
    call       _SendDebugInfo
.endif
    
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _DetScr1
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: Count the number of scrambled ones received
; -----------------------------------------------------------------------------
    
_DetScr1:

    cp0        w0
    bra        z, RESET_SCR1_CNTR      ;if w0 = 0, reset V22Scr1Cntr
    
    inc        V22Scr1Cntr             ;increments V22ScriCntr
    bra        EXIT_DETSCR1
    
RESET_SCR1_CNTR:
    clr        V22Scr1Cntr             ;V22Scr1Cntr = 0
    
EXIT_DETSCR1:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _GenS1Symbol
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: Generation of S1 symbols.
;               PrevTxPhase and S1dibit are encoded from the Differential 
;               Encoder Table  to single value Bits and from the Bits 
;               obtained corresponding symbols are got from the 1200symbol
;               table ie (input for Psf I and Q)
; -----------------------------------------------------------------------------
    
_GenS1Symbol:

    push        PSVPAG
    
    mov        #psvpage(V22DiffEncTab),w1  
    mov        w1, PSVPAG
    mov        #psvoffset(V22DiffEncTab), w1
    mov        w1, V22DiffEncTabPtr    ;Pointer to V22DiffEncTab table

    mov        V22DiffEncTabPtr, w1
    
    clr        w4
    clr        w2
    mov.b      V22PrevTxPhase, wreg    ;Get the tx Previous Phase(Quadrant)
    mov.b      w0, w2
    sl         w2, #3, w3
    
    mov.b      V22S1Dibit, wreg        ;Get the current dibit
    sl.b       w0, w0
    
    add.b      w3, w0, w4
    mov        #psvpage(V22Symb1200),w6
    mov        [w1+w4], w5             ;w5 = Bits

    mov        w5, w0
    mov.b      wreg, V22PrevTxPhase    ;Update the previous tx phase(Quad)
    
    mov        w6, PSVPAG
    mov        #psvoffset(V22Symb1200), w6
    mov        w6, V22Symb1200Ptr      ;Pointer to V22Symb1200
    
    sl         w5, #2, w7
    add        w7, #2, w5
    mov        [w6+w7], w1
    mov        w1, PSFIpI              ;Store the Encoder O/P(I - Component)
        
    mov        [w6+w5], w1
    mov        w1, PSFIpQ              ;Store the Encoder O/P(Q - Component)
    
    cp0.b      V22S1Dibit
    bra        z, SET_S1DIBIT
    
    clr.b      V22S1Dibit
    bra        EXIT_GENS1SYMBOL        ;Send S1 for Required No.of bauds
    
SET_S1DIBIT:
    mov        #0x3, w0
    mov.b      wreg, V22S1Dibit        ;Update the Dibit
    
EXIT_GENS1SYMBOL:

    pop        PSVPAG
        
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _GenScram1Symb
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to generate symbols to transmit
;               scrambled 1's. Symbols are generated by first scrambling the
;               bits and then differentially encoded with PrevTxPhase.
; -----------------------------------------------------------------------------
    
_GenScram1Symb:

    push       PSVPAG
    mov        #V22ScrState, w0
    mov        #1, w1
    rcall      _V22Scrambler
    
    sl         w0, #1, w9                 
    push       w9
    
    mov        #V22ScrState, w0
    mov        #1, w1
    rcall      _V22Scrambler
    
    pop        w9
    add        w0, w9, w2              ;w2 = updated bs
    
    mov        #psvpage(V22DiffEncTab),w3
    mov        w3, PSVPAG
    mov        #psvoffset(V22DiffEncTab), w3
    mov        w3, V22DiffEncTabPtr    ;Pointer to V22DiffEncTab table

    
    clr        w0
    mov.b      V22PrevTxPhase, wreg    ;Get The Previous Phase(Quadrant)
    clr        w4
    sl         w0, #3, w4
    sl         w2, #1, w2
  
    add.b      w2, w4, w4
    mov        #psvpage(V22Symb1200),w1
    mov        [w3+w4], w5             ;w5 = updated bs
    
    mov        w5, w0
    mov.b      wreg, V22PrevTxPhase    ;Update previous tx phase(Quadrant)
    
    mov        w1, PSVPAG
    
    mov        #psvoffset(V22Symb1200), w6
    mov        w6, V22Symb1200Ptr      ;Pointer to V22Symb1200 table
 
    sl         w5, #2, w7
    add        w7, #2, w5   
    mov        [w6+w7], w1
    mov        w1, PSFIpI              ;Store the Encoder O/P(I - Component)
    
    mov        [w6+w5], w1
    pop        PSVPAG
    
    mov        w1, PSFIpQ              ;Store the Encoder O/P(Q - Component)
      
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _GenUnScram1Symb
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to generate symbols to transmit
;               unscrambled 1's. Symbols are generated by differentially
;               encoding the bits (11) with PrevTxPhase.
; -----------------------------------------------------------------------------
    
_GenUnScram1Symb:

    push       PSVPAG
    mov        #psvpage(V22DiffEncTab),w3
    mov        w3, PSVPAG
    mov        #psvoffset(V22DiffEncTab), w3
    mov        w3, V22DiffEncTabPtr    ;Pointer to V22DiffEncTab table
 
    clr        w0
    mov.b      V22PrevTxPhase, wreg    ;Get the previous tx phase(Quadrant)
    clr        w4
    sl         w0, #3, w4              ;Phase * No.of.Colums in DiffEncTab
    add.b      w4, #0x0006, w4
    mov        #psvpage(V22Symb1200),w1
    mov        [w3+w4], w5
    mov        w5, w0
    mov.b      wreg, V22PrevTxPhase    ;update the previous tx phase
    
    clr        w0
    mov.b      V22PrevTxPhase, wreg    ;get the updated prev tx phase
    
    mov        w1, PSVPAG
    mov        #psvoffset(V22Symb1200), w1
    mov        w1, V22Symb1200Ptr      ;Pointer to V22Symb1200 table
    
    mov        V22Symb1200Ptr, w6
    sl         w0, #2, w7
    add        w7, #2, w5
    mov        [w6+w7], w1
    mov        w1, PSFIpI              ;update the psf input I
    
    mov        [w6+w5], w1
    pop        PSVPAG
    mov        w1, PSFIpQ              ;update the psf input Q
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _OrgTx1
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: Transmission of Silence for initial handshake
; -----------------------------------------------------------------------------
    
_OrgTx1:

    clr        PSFIpI                  ;clears Psf input I
    clr        PSFIpQ                  ;clears psf input Q
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _OrgTx2
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function transmits silence for 456ms. Then transmit state
;               is set to transmit unscrambled double dibit pattern (S1).     
; -----------------------------------------------------------------------------
    
_OrgTx2:

    rcall      _OrgTx1
        
    cp0        V22TxBaudCntr
    bra        nz, EXIT_ORGTX2         ;if V22TxBaudCntr is non zero return

    mov        #handle(_OrgTx3), w0
    mov        w0, V22TxSwitch         ;V22TxSwitch = _OrgTx3
    
    mov        #1, w0
    mov.b      wreg, V22ClkAdj         ;V22ClkAdj is set 
                                       ;for clock adjustment
    
    rcall      _OrgRetrainPoint
    
EXIT_ORGTX2:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _OrgRetrainPoint
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used V22bis retrain mode for resuming the    
;               initial hand shake. S1 transmission is initialized
; -----------------------------------------------------------------------------
    
_OrgRetrainPoint:

    ;Set the data fetching function pointer
   
    mov        #handle(_Get1s), w0
    mov        w0, dataTxBitFn
    
    cp0.b      ucConnectRate
    bra        nz, STARTORGTX3         ;if the ConnectRate is 0 then return
    
    rcall      _InitS1Encoder          ;Initialization of S1 Encoder
    
    mov        #handle(_OrgTx20), w0   ;Next state of swithing 
    mov        w0, V22TxSwitch
    bra        EXIT_ORG_RETRAIN
    
STARTORGTX3:  
    rcall      _StartOrgTx3
    
EXIT_ORG_RETRAIN:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _OrgTx20
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is also used during retrain mode for hand shake 
; -----------------------------------------------------------------------------
    
_OrgTx20:

    rcall      _GenS1Symbol            ;generates the S1 symbols
    
    cp0        V22TxBaudCntr
    bra        nz, EXIT_ORG_TX3        ;Check the BaudCntr for nonzero
      
    rcall      _StartOrgTx3            ;Next phase of hand shake
    
EXIT_ORG_TX3:   
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _StartOrgTx3
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function starts the transmission of scrambled binary 1's 
;               during retrain 
; -----------------------------------------------------------------------------
    
_StartOrgTx3:

    mov        #handle(_OrgTx3), w1
    mov        w1, V22TxSwitch         ;V22TxSwitch = _OrgTx3
    
.if DEF_DEBUG == 1
    mov        #V22_SEND1200, w0
    call       _SendDebugInfo
.endif
    
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _OrgTx3
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description:  Transmit unscrambled double dibit pattern (S1) for 100ms.    
;                Following this signal transmit scrambled binary 1's          
; -----------------------------------------------------------------------------
    
_OrgTx3:

    rcall      _GenScram1Symb          ;generate scrambled ones symbols
    
    cp0.b      V22S1Detect
    bra        z, EXIT_ORGTX3          ;if V22S1Detect is 0 return
   
    mov        #ANALOGLOOPBACK, w0
    and.b      modemMode
    bra        nz, SETUP2400MODEANS    ;if(ANALOGLOOPBACK & modemMode) is !0
                                       ;setup for Answer mode at 2400bps
    mov        #handle(_OrgTx4), w0
    mov        w0, V22TxSwitch         ;V22TxSwitch = _OrgTx4
    
    mov        #360, w2
    mov        w2, V22TxBaudCntr       ;V22TxBaudCntr = 360
    bra        EXIT_ORGTX3
    
    
SETUP2400MODEANS:
    rcall      _Setup2400ModeAns       ;setup for Answer mode at 2400bps
    
EXIT_ORGTX3:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _OrgTx4
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: Transmit scrambled binary 1's for 600ms at 1200bps. And then  
;               switch to the transmission of scrambled binary 1's at 2400bps 
; -----------------------------------------------------------------------------

_OrgTx4:

    rcall      _GenScram1Symb          ;Generate the scrambled ones symbols
    
    cp0        V22TxBaudCntr
    bra        nz, EXIT_ORGTX4         ;check baudcounter for nonzero
  
    mov        #handle(_Get1s), w0
    mov        w0, dataTxBitFn         ;dataTxBitFn = _Get1s
    
    mov        #handle(_OrgAnsTx5), w0
    mov        w0, V22TxSwitch         ;V22TxSwitch = _OrgAnsTx5
    
    mov        #120, w2
    mov        w2, V22TxBaudCntr       ;V22TxBaudCntr = 120
    
    mov        #1, w0
    mov.b      wreg, V22BitRate        ;Enable tx at 2400
    
.if DEF_DEBUG == 1
    mov        #V22_SEND2400, w0
    call       _SendDebugInfo
.endif
    
EXIT_ORGTX4:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
        
    .global _OrgAnsTx5
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: Transmit scrambled binary 1's for 200ms at 2400bps and then   
;               switch to data mode.                                          
; -----------------------------------------------------------------------------
    
_OrgAnsTx5:

    rcall      _V22DataEncoder

    cp0        V22TxBaudCntr
    bra        nz, EXIT_ORGANSTX5      ;check the tx baud counter for !0
  
    cp0.b      V22ClkCntr
    bra        z, EXIT_ORGANSTX5       ;if the V22ClkCntr is nonzero then

    rcall      _V22Connected           ;V22 is connected
    
EXIT_ORGANSTX5:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _V22Connected
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: V22 mode switch to data mode by executing EnableDataTransfer. 
; -----------------------------------------------------------------------------
    
_V22Connected:

    mov        #handle(_V22DataEncoder), w1
    mov        w1, V22TxSwitch         ;V22TxSwitch = _V22DataEncoder
 
    call       _EnableDataTransfer     ;Enables data transfer

    mov        #mCONNECT,w0            ;Send CONNECT message to host to
    mov.b      wreg,mesgMsgId          ;indicate the connection establishment

    mov       #2,w0
    mov.b     wreg,mesgMsgLen
    
    mov       #mesgMsgParams, w8
    
    mov       #V22BIS_MODE,w0
    mov.b     w0, [w8++]    

    mov.b     V22BitRate,wreg
    mov.b     w0, [w8--]        

    call       _SendMessageToHost

.if DEF_DEBUG == 1
    mov       #1, w0
    cp.b      V22BitRate
    bra       nz, CONNECT_1200

    mov        #V22_CONNECT_2400, w0
    call       _SendDebugInfo
    bra        EXIT_V22_DEBUG_CONNECT
CONNECT_1200:
     mov        #V22_CONNECT_1200, w0
    call       _SendDebugInfo

EXIT_V22_DEBUG_CONNECT:
.endif

    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _OrgRx1
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function Wait for the detection of unscrambled binary 1's
;               for 155ms.                                                    
; -----------------------------------------------------------------------------
    
_OrgRx1:

    mov.b      V22RxSyncBits, wreg
    mov        #0x3, w1
    cp.b       w0, w1
    bra        nz, RESETSCR1CNTR       ;if the V22RxSyncBits is !0 then 
                                       ;reset V22Scr1Cntr
    inc        V22Scr1Cntr             ;Increment V22Scr1Cntr

;Check for 150 ms   
    mov        #90, w2
    mov        V22Scr1Cntr, w3         ;V22Scr1Cntr = 90
    cp         w3, w2
    bra        lt, EXIT_ORGRX1

;Switching to phase-2   
    mov        #274, w3
    mov        w3, V22TxBaudCntr       ;V22TxBaudCntr = 274
    
    mov        #handle(_OrgTx2), w0
    mov        w0, V22TxSwitch
    
    mov        #handle(_OrgRx2), w0
    mov        w0, V22RxSwitch
    
    mov        #handle(_DetScr1), w0
    mov        w0, dataRxBitFn
    
    clr        V22Scr1Cntr             ;V22Scr1Cntr = 0

.if DEF_DEBUG == 1
    mov        #V22_RECEIVEUNSCRAM, w0
    call       _SendDebugInfo
.endif
    
    mov        #1, w0
    mov.b      wreg, V22TotPhase       ;V22TotPhase = 1
    
    mov.b      wreg, AGCFreeze         ;set AGCFreeze as there is no need 
                                       ;for gain control
    mov.b      wreg, V22ClkAdj         ;set V22 clock Adjustment
    bra        EXIT_ORGRX1
    
RESETSCR1CNTR: 
    clr        V22Scr1Cntr             ;V22Scr1Cntr = 0
   
EXIT_ORGRX1:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _OrgRx2
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function transmits silence for 456ms. Then transmit state
;               is set to transmit unscrambled double dibit pattern (S1).     
; -----------------------------------------------------------------------------
    
_OrgRx2:

    mov        TRNDetectSDetect,w0   
    cp0        w0
    bra        z, SCR1CNTCOND          ;if S detect is !0 setup for 2400bps
    
    rcall      _Setup2400Mode
    return
    
SCR1CNTCOND:
    mov        #324, w0
    mov        V22Scr1Cntr, w1
    cp         w1, w0
    bra        lt, END_ORGRX2
    
    mov        #458, w0
    mov        w0, V22TxBaudCntr       ;V22TxBaudCntr = 458
    
    mov        #handle(_OrgAnsRx4), w1
    mov        w1, V22RxSwitch
    
    mov        #handle(_OrgAnsTx5), w1
    mov        w1, V22TxSwitch
    
    mov        #0x1400, w0
    mov        w0, eqzStepSize         ;eqzStepSize = 1400
    
    mov        #2, w0
    mov.b      wreg, V22TotPhase       ;V22TotPhase = 2

.if DEF_DEBUG == 1
    mov        #V22_RECEIVE1200, w0
    call       _SendDebugInfo
.endif
    
END_ORGRX2:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _Setup2400Mode
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function sets up the state machine to 2400bps mode.      
; -----------------------------------------------------------------------------
    
_Setup2400Mode:

    mov        #270, w0
    mov        w0, V22RxBaudCntr       ;V22RxBaudCntr = 270
    
    mov        #handle(_OrgRx3), w0    ;Next state of switching
    mov        w0, V22RxSwitch
    
.if DEF_DEBUG == 1
    mov        #V22_RECEIVES1, w0
    call       _SendDebugInfo
.endif
    
    mov        #0x1200, w2
    mov        w2, eqzStepSize         ;eqzStepSize = 1200
    
    mov        #2, w0
    mov.b      wreg, V22TotPhase       ;V22TotPhase = 2
    
    mov        #1, w0
    mov.b      wreg, V22S1Detect       ;V22S1Detect = 1
    
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _OrgRx3
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function Wait for 450ms before start making 2400bps      
;               decoding.                                                     
; -----------------------------------------------------------------------------
    
_OrgRx3:
    
    ;Wait for 450 ms

    cp0        V22RxBaudCntr
    bra        nz, END_ORGRX3

.if DEF_DEBUG == 1
    mov        #V22_RECEIVE1200, w0
    call       _SendDebugInfo
.endif
    
    mov        #handle(_OrgAnsRx4), w1         ;Next state of switching
    mov        w1, V22RxSwitch
    
    clr        V22Scr1Cntr             ;V22Scr1Cntr = 0
    
    mov        #handle(_V22Dec2400), w1
    mov        w1, V22DecFnPtr
    
    mov        #1, w0
    mov.b      wreg, V22BitRate        ;Decode at 2400bps
    
    mov        #0x7ff0, w0             ;Set the carrier recovery 
    call       _SetCarrecPll           ;PLL band width
    
END_ORGRX3:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _OrgAnsRx4
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function waits for 32 consecutive bits of scrambled      
;               binary 1's at 2400bps.                                        
; -----------------------------------------------------------------------------

_OrgAnsRx4:
 
   ;Wait for 32 consecutive scrambled binary 1's

    mov        #32, w0
    mov        V22Scr1Cntr, w1
    
    cp         w1, w0
    bra        lt, END_ORGANSRX4

.if DEF_DEBUG == 1
    mov        #V22_RXDSCRAMONES, w0
    call       _SendDebugInfo
.endif
    
    mov        #1, w0
    mov.b      wreg, V22ClkCntr        ;V22ClkCntr = 1
    
    mov        #handle(_RxConnected), w1  ;Enter into data mode
    mov        w1, V22RxSwitch
    
    mov        #0xc00, w0
    mov        w0, eqzStepSize         ;eqzStepSize = 0xc00
    
    mov        #600, w0
    mov        w0, V22RxBaudCntr       ;V22RxBaudCntr = 600
    
END_ORGANSRX4:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _RxConnected
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: V22 start receiving the data at 2400bps. After 600 bauds the  
;               receive state is switch to retrain signal monitoring.         
; -----------------------------------------------------------------------------
    
_RxConnected:

    cp0        V22RxBaudCntr
    bra        nz, END_RXCONNECTED
    
    call       _InitFlock             ;Enable Clock phase drift tracking

    mov       #32, w0
    mov.b     wreg, eqzFlockBaudCntSet
    
    mov        #handle(_ChkV22Retrain), w1
    mov        w1, V22RxSwitch
    
    clr.b      V22S1Detect             ;V22S1Detect = 0     
    
    mov        #0x300, w0
    mov        w0, eqzStepSize         ;eqzStepSize = 0x400
    
END_RXCONNECTED:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _AnsTx1
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function transmits silence for 75ms and then switch to   
;               transmit unscrambled binary 1's.                              
; -----------------------------------------------------------------------------
    
_AnsTx1:

    rcall      _OrgTx1                 ;Just to transmit Silence
    
    ;Transmit silence for 75ms
    
    cp0        V22TxBaudCntr
    bra        nz, END_ANSTX1
    
    mov        #handle(_AnsTx2), w1    ;Next state of Tx switching
    mov        w1, V22TxSwitch

.if DEF_DEBUG == 1
    mov        #V22_SENDUNSCRAM, w0
    call       _SendDebugInfo
.endif
    
    mov        #handle(_AnsRx1), w1    ;Next state of Rx switching
    mov        w1, V22RxSwitch
    
END_ANSTX1:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
        
    .global _AnsTx2
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function checks for the detection of scrambled binary 1's
;               at 1200bps(Check1200Ans) and unscrambled double dibit pattern 
;               (S1) at 1200bps.                                              
; -----------------------------------------------------------------------------
     
_AnsTx2:
    
    push       PSVPAG
    mov        #psvpage(V22DiffEncTab),w3
    mov        w3, PSVPAG
    mov        #psvoffset(V22DiffEncTab), w3
    mov        w3, V22DiffEncTabPtr    ;Pointer to V22DiffEncTab table

    mov        V22DiffEncTabPtr, w3
    
    clr        w0
    mov.b      V22PrevTxPhase, wreg    ;Get the prev tx phase(Quadrant)
    clr        w4
    sl         w0, #3, w4
    add.b      w4, #0x0006, w4
    mov        #psvpage(V22Symb1200),w1
    mov        [w3+w4], w5
    mov        w5, w0
    mov.b      wreg, V22PrevTxPhase    ;Update the prev tx phase 
    
    clr        w0
    mov.b      V22PrevTxPhase, wreg    ;get the updated previous tx phase
    
    mov        w1, PSVPAG
    mov        #psvoffset(V22Symb1200), w1
    mov        w1, V22Symb1200Ptr      ;Pointer to V22Symb1200
    
    mov        V22Symb1200Ptr, w6
    sl         w0, #2, w7
    add.b      w7, #2, w5
    mov        [w6+w7], w1
    mov        w1, PSFIpI              ;updates the psf input I
    
    mov        [w6+w5], w1
    mov        w1, PSFIpQ              ;updates the psf input Q
    
    mov        TRNDetectSDetect,w0
    cp0        w0
    bra        nz, SETUP2400ANS
    
    rcall      _Check1200Ans
    bra        END_ANSTX2

SETUP2400ANS:
    rcall      _Setup2400ModeAns
    
END_ANSTX2:
    pop        PSVPAG
          
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _Check1200Ans
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function checks for the detection of scrambled binay 1's 
; -----------------------------------------------------------------------------
    
_Check1200Ans:

    mov        #324, w0
    mov        V22Scr1Cntr, w1
    
    cp         w1, w0
    bra        lt, END_CHECK1200ANS
    
    mov        #handle(_Get1s), w1
    mov        w1, dataTxBitFn
    
    mov        #458, w2
    mov        w2, V22TxBaudCntr       ;V22TxBaudCntr = 458
    
    clr        V22Scr1Cntr             ;clear V22Scr1Cntr
    
    mov        #handle(_OrgAnsRx4), w1
    mov        w1, V22RxSwitch
    
    mov        #handle(_OrgAnsTx5), w1
    mov        w1, V22TxSwitch
    
    mov        #0x1200, w2
    mov        w2, eqzStepSize         ;eqzStepSize = 0x1200
    
    call       _FreezeAGC              ;No gain control, freezes AGC
    
    mov        #2, w0
    mov.b      wreg, V22TotPhase       ;V22TotPhase = 2
    
    mov        #1, w0
    mov.b      wreg, V22ClkAdj         ;V22ClkAdj = 1

.if DEF_DEBUG == 1
    mov        #V22_RECEIVEUNSCRAM, w0
    call       _SendDebugInfo
.endif
    
END_CHECK1200ANS:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
        
    .global _Setup2400ModeAns
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function sets up the state machine to 2400bps Answer mode
; -----------------------------------------------------------------------------
    
_Setup2400ModeAns:

    call       _FreezeAGC              ;Freezes AGC, no gain control
    
    mov        #0x01, w0
    mov.b      wreg, V22ClkAdj         ;V22ClkAdj = 1
    
    mov        #2, w0
    mov.b      wreg, V22TotPhase       ;V22TotPhase = 2
    
    mov        #handle(_DetScr1), w2   ;Start look for Scrambled 1's 
    mov        w2, dataRxBitFn
    
    mov        #handle(_Get1s), w2
    mov        w2, dataTxBitFn
    
    cp0.b      ucConnectRate
    bra        nz, FUNCPOIN_CHECK1200ANS   ;checking the bitrate for 2400/1200
    
    mov        #1, w0
    mov.b      wreg, V22S1Detect       ;V22S1Detect = 1

.if DEF_DEBUG == 1
    mov        #V22_RECEIVES1, w0
    call       _SendDebugInfo
.endif
    
    rcall      _InitS1Encoder          ;Initializes the S1Encoder
    
    mov        #handle(_AnsTx3), w2
    mov        w2, V22TxSwitch
    
    mov        #handle(_AnsRx3), w2
    mov        w2, V22RxSwitch         ;Switch to 16 Way dec after
    
    mov        #270, w0
    mov        w0, V22RxBaudCntr       ;450 ms
    
    mov        #0x1200, w0
    mov        w0, eqzStepSize         ;eqzStepSize = 0x1200
    bra        EXIT_SETUP2400ANS
    
FUNCPOIN_CHECK1200ANS:

    mov        #handle(_Check1200Ans), w2
    mov        w2, V22TxSwitch
    
EXIT_SETUP2400ANS:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _AnsTx3
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function Transmit S1 for 100bauds and then switch to the 
;               transmission of scrambled binary 1's for 500ms at 1200bps.    
; -----------------------------------------------------------------------------
    
_AnsTx3:

    rcall      _GenS1Symbol            ;Generates the S1 symbols 
    
    cp0        V22TxBaudCntr
    bra        nz, END_ANSTX3
    
    mov        #300, w0
    mov        w0, V22TxBaudCntr       ;500 ms
    
    mov        #handle(_AnsTx4), w1
    mov        w1, V22TxSwitch

.if DEF_DEBUG == 1
    mov        #V22_SEND1200, w0
    call       _SendDebugInfo
.endif
    
END_ANSTX3:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _AnsTx4
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function transmits scrambled binary 1's for 500ms and    
;               then switch to 16 way decisions (2400 ps mode) for the        
;               transmission of scrambled binary 1's for 200ms at 2400bps     
; -----------------------------------------------------------------------------
    
_AnsTx4:

    rcall      _GenScram1Symb          ;Generates the scrambled 1's symbols
    
    cp0        V22TxBaudCntr
    bra        nz, END_ANSTX4

.if DEF_DEBUG == 1
    mov        #V22_SEND2400, w0
    call       _SendDebugInfo
.endif
    
    mov        #1, w0
    mov.b      wreg, V22BitRate        ;Encode at 2400bps

;Start sending 1's @ 2400 for 200 ms    
    mov        #120, w0
    mov        w0, V22TxBaudCntr       ;V22TxBaudCntr = 120
    
    mov        #handle(_OrgAnsTx5), w1
    mov        w1, V22TxSwitch
    
END_ANSTX4:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _AnsRx1
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function wait for 60 bauds before start looking for      
;               scrambled binary 1's                                          
; -----------------------------------------------------------------------------
    
_AnsRx1:

    mov        #1, w0
    mov.b      wreg, V22TotPhase       ;V22Totphase = 1
    
    mov        #handle(_AnsRx2), w1
    mov        w1, V22RxSwitch
    
    mov        #60, w1
    mov        w1, V22RxBaudCntr       ;V22RxBaudCntr = 60
    
    mov        #handle(_DetScr1), w1
    mov        w1, dataRxBitFn
    
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _AnsRx2
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to set the step size for equalizer      
;               training                                                      
; -----------------------------------------------------------------------------
    
_AnsRx2:

    cp0        V22RxBaudCntr
    bra        nz, END_ANSRX2
    
    mov        #0x1400, w0
    mov        w0, eqzStepSize         ;eqzStepSize = 0x1400
    
    mov        #handle(_NullFunction), w1
    mov        w1, V22RxSwitch

END_ANSRX2:    
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _AnsRx3
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function Wait for 450ms and then switch to 2400bps mode  
; -----------------------------------------------------------------------------
    
_AnsRx3:

    cp0        V22RxBaudCntr
    bra        nz, END_ANSRX3

.if DEF_DEBUG == 1
    mov        #V22_RECEIVE1200, w0
    call       _SendDebugInfo
.endif
    
    mov        #handle(_OrgAnsRx4), w1
    mov        w1, V22RxSwitch
    
    clr        V22Scr1Cntr             ;V22Scr1Cntr = 0
    
    mov        #handle(_V22Dec2400), w1
    mov        w1, V22DecFnPtr
    
    mov        #1, w0
    mov.b      wreg, V22BitRate        ;Decode at 2400bps
    
    mov.b      wreg, V22S1Detect       ;V22S1Detect is set
    
    mov        #0x7f00, w0
    call       _SetCarrecPll
    
END_ANSRX3:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _InitiateV22Retrain
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to initiate local retrain
; -----------------------------------------------------------------------------
    
_InitiateV22Retrain:

    mov        #mLOCALRETRAIN, w0
    mov.b      wreg, mesgMsgId
    
    clr.b      mesgMsgLen
    mov        #mesgMsgParams, w8

    call       _SendMessageToHost

    call       _InitTrnDetector        ;Initializes the Trn Detector
    
    mov        #200, w0
    mov        w0, TRNDetectScntrSet   ;sets the Trn detect S counter
    
    mov        #0, w0
    mov        w0,TRNDetectSDetect        ;clears the Trn S detect
    
    mov        #1, w0
    mov.b      wreg, V22TotPhase       ;V22TotPhase = 1
    
    clr        V22Scr1Cntr             ;clears V22Scr1Cntr
    
    cp0.b      V22BitRate
    bra        nz, START_RETRAIN       ;if bitrate is non zero 
                                       ;start retrain
    
    rcall      _V22Connected
    bra        EXIT_INIT_V22_RET
        
START_RETRAIN:
    rcall      _StartRet
    
EXIT_INIT_V22_RET:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
        
    .global _StartRet
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
;  Description: This function is used to start the V22 retrain.               
; -----------------------------------------------------------------------------
   
_StartRet:

    clr.b      V22ClkCntr              ;clears the V22 clock counter
    
    mov        #900, w0
    mov        w0, V22RxBaudCntr       ;Wait max 1.5 secs for S1
    
    mov        #handle(_OrgRetrainPoint), w1
    mov        w1, V22TxSwitch
    
    mov        #handle(_WaitForS1), w1
    mov        w1, V22RxSwitch
    
    mov        #handle(_DetScr1), w1
    mov        w1, dataRxBitFn
    
    mov        #handle(_V22Dec1200), w1
    mov        w1, V22DecFnPtr
    
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _WaitForS1
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: In this function waits for S1 from the Remote Modem  when
;               Retraining has been initiated from the Orginate Mode after
;               sending S1 ,Modem waits and validates S1 with in 900bauds
;               (ie 1.5s)
; -----------------------------------------------------------------------------
    
_WaitForS1:

    rcall      _OrgRx2
    
    cp0        V22RxBaudCntr
    bra        nz, EXIT_WAITFORS1
    
    mov        #NO_RETRAIN_RESPONSE, w0
    mov.b      wreg, mdmHangUp
    
EXIT_WAITFORS1:
    return
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _ChkV22Retrain
    .section  .libsm, "x"
    
; -----------------------------------------------------------------------------
;  Description: This function is used to monitor the retrain condition        
; -----------------------------------------------------------------------------
    
_ChkV22Retrain:

    rcall      _DetectS1               ;Look for the s1
    
    cp0.b      V22S1Detect    
    bra        z, EXIT_CHKV22RETRAIN
    
    clr.b      V22ClkCntr              ;clears the V22 clock Counter
    
    mov        #handle(_NullFunction), w1
    mov        w1, V22RxSwitch
    
    rcall      _Setup2400ModeAns       ;Switch to 2400 mode
    
EXIT_CHKV22RETRAIN:
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global ClearV22Vars
    .section  .libsm, "x"

ClearV22Vars:

    mov        #V22BitRate, w0         ;Clear V22 data structure
    mov        #SIZEOFV22_BSS_1, w1
    call       _ClearStructByte
   
    mov        #V22TxBaudCntr, w0        ;Clear V22 data structure
    mov        #SIZEOFV22_BSS_2, w1
    call       _ClearStruct

    mov        #mdmFilterBuffer, w1
    mov        #V22BpDlyLine,w0    
    add        w0, w1, w0
        
    mov        #SIZEOFV22_YBSS,w1
    call       _ClearStruct

    return

; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------

.endif
    
; ----------------------------------------------------------------------------
;   END OF FILE
; ----------------------------------------------------------------------------
