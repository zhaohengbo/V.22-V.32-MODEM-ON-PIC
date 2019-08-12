; -----------------------------------------------------------------------------
;File Name:    MODEMVAR.S
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "dpconfig.inc"
    .include "modem.inc"
    .include "apiasm.inc"
    .include "message.inc"
    .include "tables.inc"
    .include "Agc.inc"
    .include "Data.inc"
    .include "Dmctrl.inc"
    .include "Filter.inc"
    .include "sipl.inc"

.if (DEF_V32 == 1 || DEF_V22 == 1)
    .include "Carrec.inc"
    .include "Eqz.inc"
    .include "Psf.inc"
    .include "Sbar.inc"
.endif
.if DEF_V22 == 1
    .include "v22.inc"
.endif
.if DEF_V23 == 1
    .include "V23.inc"
.endif
.if DEF_V21 == 1
    .include "V21.inc"
.endif
.if DEF_V25 == 1
    .include "V25.inc"
.endif
.if DEF_V32 == 1
    .include "V32.inc"
    .include "EC.inc"    
.endif
.if DEF_V8 == 1
    .include "V8.inc"
.endif
.if DEF_CALLPROG == 1
    .include "callprog.inc"
.endif    
.if DEF_HDLC == 1
     .include "hdlc.inc"
.endif

.if DEF_V32BIS == 1
     .include "trel.inc"
     .include "vit.inc"
.endif

; *****************************************************************************
; Memory Declaration for Modem variables under .nbss section.
; *****************************************************************************

    .section .nbss
    .align 2    

    nbssFirstVar:        .space 1

; -----------------------------------------------------------------------------
; Variables required for all the data modulatioons
; -----------------------------------------------------------------------------

    .align 2    

    datass_word:         .space 2      ;data with start-stop
    dataRxDataWord:      .space 2      ;Assembled data word
    dataTxDataWord:      .space 2      ;Data word to be transmitted
    dataDataByte:        .space 2      ;index,data byte to transmit
    dataXoffLimit:       .space 2
    dataXonLimit:        .space 2
       
    dataRxBitCnt:        .space 1      ;Number of received bits
    dataHostRxWrite:     .space 1      ;Write Pointer to HostRx Buffer
    dataHostRxRead:      .space 1      ;Read Pointer to HostRx Buffer
    dataHostTxWrite:     .space 1      ;Write Pointer to HostTx Buffer
    dataHostTxRead:      .space 1      ;Read Pointer to HostTx Buffer
    dataTxBitCnt:        .space 1      ;Number of transmitted bits
    dataIdleData:        .space 1      ;Transmit Idle data when no host data
    dataXoff:            .space 1      ;Pause data transfer
    dataNoOfStopBits:    .space 1      ;Count for stop bits

    AGCHiEngCntr:        .space 1      ;To keep track of input energy higher or
    AGCLowEngCntr:       .space 1      ;lower than the minimum required energy
    AGCEnergyStat:       .space 1      ;status of input signal energy
    AGCFreeze:           .space 1      ;used to stop updation of gain
    AGCAutoStart:        .space 1      ;Used as a flag start AGC
    AGCOutBufIndex:      .space 1      ;Index for the AGC output Buffer

    modemStatus:         .space 1      ;Modem status flag
    modemMode:           .space 1      ;Modem mode flag
    mdmPcmBufLen:        .space 1      ;PCM buffer length
    modemType:           .space 1      ;Modem type flag
    mdmHangUp:           .space 1      ;Modem Hangup flag
    mdmAgcMinEnSet:      .space 1      ;Initialized minimum energy level
    mdmV8Enable:         .space 1      ;V.8 hand shake enable flag
    mdmSiplEnable:       .space 1      ;SIPL enable flag
    mdmRxSmpCntr:        .space 1      ;Receive sample counter
    mdmTxSmpCntr:        .space 1      ;Transmit sample counter
    mdmPcmTxIndex:       .space 1      ;Transmit sample number
    mdmPcmRxIndex:       .space 1      ;Receive sample number
    mdmAdcDelay:         .space 1      ;Delay involved in ADC
    mdmDacDelay:         .space 1      ;Delay involved in DAC
    mdmSignalHigh:       .space 1      ;Indicates the received signal level
    mdmRCTxRatio:        .space 1      ;Sampling rate selection flag
    mdmDPHSTest:         .space 1      ;Offline DP state machine test        

    ucAutoRetrain:       .space 1      ;Auto retrain mode flag
    ucDataModeSel:       .space 1      ;Data transmission mode select flag 
    ucIdleDataSet:       .space 1      ;Idle data for the data pump
    ucConnectMode:       .space 1      ;Connection mode in loop back
    ucConnectRate:       .space 1      ;Bit rate selection flag
    ucHS_Mode:           .space 1      ;Hand shake mode select
    ucClprgConfig:       .space 1      ;Call progress mode select
    ucClearDown:         .space 1      ;Modem clear down flag

    mesgMsgId:           .space 1      ;Message id
    mesgMsgLen:          .space 1      ;Message Length

; -----------------------------------------------------------------------------
; Variables required for only V.32 modulation
; -----------------------------------------------------------------------------

.if DEF_V32 == 1
    mdmStartRetrain:     .space 1      ;Start of modem retrain
    dmStartRetrain:      .space 1
    V32RRPrevRxPhase:    .space 1
    V32Alt:              .space 1
.endif

; -----------------------------------------------------------------------------
; Variables required for only V.32 and V.22bis modulations
; -----------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)
    mdmDetEqzTrn:        .space 1      ;Equalizer training sequence detect flag
    CarrecStatus:        .space 1      ;Carrier recovery enable/disable flag
    hilbRealPtr:         .space 1      ;Hilbert filter delayline pointer for
                                       ;accessing real part of hilbert output
    TRNDetectBufferPtr:  .space 1       
    TRNDetectLength:     .space 1      ;Demod buffer length
.endif

; -----------------------------------------------------------------------------
; Variables required for HDLC protocol
; -----------------------------------------------------------------------------

.if DEF_HDLC == 1
    .align 2

    HDLCTxByteCnt:       .space 2      ;To count the number of bytes in the 
                                       ;transmit frame
    HDLCTxCRCWord:       .space 2      ;To store the instantaneous 16 bit CRC 
                                       ;word
    HDLCTxBitCnt:        .space 2      ;Counter for transmit bits in a byte
    HDLCTxDataWord:      .space 2      ;The actual used data word which is 
                                       ;serially Tx'ed.
    HDLCTxFlag:          .space 1      ;To indicate that 0x7e is being 
                                       ;transmitted
    HDLCTxOnesCnt:       .space 1      ;For counting the continuous 1's in the
                                       ;data stream
    HDLCTxCRC:           .space 1      ;Indicates that CRC word is being 
                                       ;transmitted when, 1
    HDLCInsert0:         .space 1      ;Status variable to indicate that next
                                       ;bit be 0.
    .align 2

    HDLCRxByteCnt:       .space 2      ;The number of bytes in the received 
                                       ;frame
    HDLCRxCRCWord:       .space 2      ;Instantaneous 16 bit CRC word
    HDLCRxDataWord:      .space 2      ;The actual data word received
    HDLCCRCErrors:       .space 2      ;CRC errors
    HDLCNoOfFrames:      .space 2      ;number of frames
    HDLCRxFrame:         .space 2      ;HDLC Receive Frame
    HDLCRxOnesCnt:       .space 1      ;counter for continuous received 1 bits
    HDLCRxFlag:          .space 1      ;Status to indicate the erception of 
                                       ;0x7e sequence
    HDLCRxBitCnt:        .space 1      ;counter for Number of bits in the 
                                       ;current data word
    HDLCGotCRC:          .space 1      ;Status to indicate the reception of the
                                       ;CRC word
.endif

.if DEF_V32BIS == 1

    ;V.32bis Trellis Encoder variables
 
    .align 2

    TrelBitsPerBaud:     .space 1      ;Number of bits in a symbol
    TrelExtraShift:      .space 1      ;Scaling required for Encoder output
    TrelPrevTxPhase:     .space 1      ;Differential encoder phase

    .align 2

    TrelCoordsPtr:       .space 2       ;Pointer to symbol table
    TrelDiffEncTabPtr:   .space 2       ;Pointer to differential encoder table
    TrelS0n:             .space 2       ;Convolutional encoder variables
    TrelS1n:             .space 2
    TrelS2n:             .space 2
    TrelBitPattern:      .space 2       ;Bit pattern for symbol generation 
    TrelY0n:             .space 2       ;Encoder intermediate variables
    TrelY1n:             .space 2
    TrelY2n:             .space 2
    .align 2
    
    ;V.32bis Viterbi Decoder variables

    VitBitsPerBaud:      .space 1      ;Bits ina a baud for viterbi decoder
    VitWndwCntr:         .space 1      ;Trellis path window counter
    VitRotate:           .space 1      ;Symbol rotation variable

    .align 2
    VitRowsNo:           .space 2      ;Row number in the coordinates table
    VitPtrToConstell:    .space 2      ;Pointer to bit pattern table
    VitBoundValue:       .space 2      ;Constellation bound values
    VitMBoundValue:      .space 2
    VitDescrShift:       .space 2      ;Differential decoder variables
    VitFinalBits:        .space 2
    VitDiffDecTabPtr:    .space 2
    VitY12nm1Rx:         .space 2
    VitMinDstI:          .space 2      ;Minimum distance in Trellis path
    VitMinDstQ:          .space 2
    VitPastStatesTabPtr: .space 2      ;Trellis path states buffer pointer
    VitIndexToPath:      .space 2      ;An index to a trellis path
    VitOldMinPath:       .space 2      ;Previous minimum path
    VitNoOfBreaks:       .space 2      ;Number of breakes in the Viterbi path
    VitCodeShift:        .space 2
.endif

	.align 2
	
    V32SineTabPtr:       .space 2      ;V.32 carrier generation table pointer
    V32SineTabIndex:     .space 2      ;and table index
    V32NTCMEnable:       .space 2      ;Flag to indicate the V.32 NTCM Enable
    
    ECSineTabPtr:        .space 2      ;V32 carrier generation table pointer
    NECSineTabIndex:     .space 2      ;for Echo canceller and table index 
    FECSineTabIndex:     .space 2

    eqzMSEInput:         .space 2      ;Variables used for MSE estimation for
    eqzMSEOutput1:       .space 2      ;V.32bis modulation
    eqzMSEOutput2:       .space 2

    V32RRStart:          .space 1      ;Flag for Renegotiation start
    V32NecRRPrevTxPhase: .space 1      ;Synbol phase for RR sequence detection
    V32FecRRPrevTxPhase: .space 1

    nbssLastVar:         .space 1

                                         
; *****************************************************************************
; Memory Declaration for Modem variables under .bss section
; *****************************************************************************
    
    .section    .bss

; -----------------------------------------------------------------------------
; Memory Declaration for Modem variables under .bss section (one byte variables)
; -----------------------------------------------------------------------------

    .align 2

    bssFirstVar:        .space 1

; -----------------------------------------------------------------------------
; Common variables required for all the data modulation protocols
; -----------------------------------------------------------------------------

    mdmvar1:            .space 1
    mdmvar2:            .space 1
    mdmvar3:            .space 1
    mdmvar4:            .space 1
    mdmvar5:            .space 1
    mdmvar6:            .space 1
    mdmvar7:            .space 1
    mdmvar8:            .space 1
    mdmvar9:            .space 1
    mdmvar10:           .space 1
    mdmvar11:           .space 1
    mdmvar12:           .space 1
    mdmvar13:           .space 1
    mdmvar14:           .space 1
    mdmvar15:           .space 1
    mdmvar16:           .space 1
    mdmvar17:           .space 1
    mdmvar18:           .space 1
    mdmvar19:           .space 1
    mdmvar20:           .space 1
    mdmvar21:           .space 1
    mdmvar22:           .space 1
    mdmvar23:           .space 1
    mdmvar24:           .space 1
    mdmvar25:           .space 1
    mdmvar26:           .space 1
    mdmvar27:           .space 1
    mdmvar28:           .space 1
    mdmvar29:           .space 1
    mdmvar30:           .space 1
    mdmvar31:           .space 1
    mdmvar32:           .space 1

; -----------------------------------------------------------------------------
; Memory Declaration for Modem variables under .bss section (two byte variables)
; -----------------------------------------------------------------------------

    .align 2

    mdmvar76:           .space 2
    mdmvar77:           .space 2
    mdmvar78:           .space 2
    mdmvar79:           .space 2
    mdmvar80:           .space 2
    mdmvar81:           .space 2
    mdmvar82:           .space 2
    mdmvar4_82:         .space 4
    mdmvar83:           .space 2
    mdmvar84:           .space 2
    mdmvar85:           .space 2
    mdmvar86:           .space 2
    mdmvar87:           .space 2
    mdmvar88:           .space 2
    mdmvar4_88:         .space 4
    mdmvar89:           .space 2
    mdmvar90:           .space 2
    mdmvar91:           .space 2
    mdmvar92:           .space 2
    mdmvar93:           .space 2
    mdmvar94:           .space 2
    mdmvar4_94:         .space 4
    mdmvar95:           .space 2
    mdmvar96:           .space 2
    mdmvar97:           .space 2
    mdmvar98:           .space 2
    mdmvar99:           .space 2
    mdmvar100:          .space 2
    mdmvar101:          .space 2
    mdmvar102:          .space 2
    mdmvar103:          .space 2
    mdmvar104:          .space 2
    mdmvar105:          .space 2
    mdmvar106:          .space 2
    mdmvar107:          .space 2
    mdmvar108:          .space 2
    mdmvar109:          .space 2
    mdmvar110:          .space 2
    mdmvar111:          .space 2
    mdmvar112:          .space 2
    mdmvar113:          .space 2
    mdmvar114:          .space 2
    mdmvar115:          .space 2
    mdmvar116:          .space 2
    mdmvar117:          .space 2
    mdmvar118:          .space 2
    mdmvar119:          .space 2
    mdmvar120:          .space 2
    mdmvar121:          .space 2
    mdmvar122:          .space 2
    mdmvar123:          .space 2
    mdmvar124:          .space 2
    mdmvar125:          .space 2
    mdmvar126:          .space 2
    mdmvar127:          .space 2
    mdmvar128:          .space 2
    mdmvar129:          .space 2
    mdmvar130:          .space 2
    mdmvar131:          .space 2
    mdmvar132:          .space 2
    mdmvar133:          .space 2
    mdmvar134:          .space 2
    mdmvar135:          .space 2
    mdmvar136:          .space 2
    mdmvar137:          .space 2
    mdmvar138:          .space 2
    mdmvar139:          .space 2
    mdmvar140:          .space 2
    mdmvar141:          .space 2
    mdmvar142:          .space 2
    mdmvar143:          .space 2
    mdmvar144:          .space 2
    mdmvar145:          .space 2
    mdmvar146:          .space 2

    mdmvar147:          .space 2
    mdmvar148:          .space 2
    mdmvar149:          .space 2
    mdmvar4_149:        .space 4
    mdmvar150:          .space 2
    mdmvar151:          .space 2
    mdmvar152:          .space 2
    mdmvar153:          .space 2
    mdmvar154:          .space 2
    mdmvar155:          .space 2
    mdmvar156:          .space 2
    mdmvar157:          .space 2
    mdmvar158:          .space 2
    mdmvar159:          .space 2
    mdmvar160:          .space 2
    mdmvar161:          .space 2
    mdmvar162:          .space 2
    mdmvar163:          .space 2
    mdmvar164:          .space 2
    mdmvar165:          .space 2    
    mdmvar166:          .space 2
    mdmvar167:          .space 2

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .align 2 

; -----------------------------------------------------------------------------
; data buffres declarations for Data Handling 
; -----------------------------------------------------------------------------

;Data received from the host and to be transmitted
    dataHostRxBuffer:    .space RXDATABUFLEN

;Demodulated data to be sent to the Host
    dataHostTxBuffer:    .space TXDATABUFLEN

; -----------------------------------------------------------------------------
; Variable declarations for AGC 
; -----------------------------------------------------------------------------

    AGCInput:            .space 2      ;input sample to AGC
    AGCOutput:           .space 2      ;Output sample of AGC
    AGCGain:             .space 2      ;The gain factor for AGC
    AGCTC:               .space 2      ;The time constant for AGC  

    AGCMeanPRunAvg:      .space 4      ;AGC Mean Parameter Run Average
    AGCMeanPAvg:         .space 2      ;AGC Mean Parameter Average
    AGCMeanPCntr:        .space 2      ;AGC Mean Parameter Counter
    AGCMeanPLevel:       .space 2      ;AGC Mean Parameter Average Level
    AGCMeanPIp:          .space 2      ;AGC Mean Parameter Input
    AGCOutBuf:           .space 32     ;AGC output buffer

; -----------------------------------------------------------------------------
; Variables required for only V.32 and V.22bis modulations
; -----------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)

; -----------------------------------------------------------------------------
; Variable declarations for Carrier Recovery 
; -----------------------------------------------------------------------------

    CarrecPhase:         .space 2          ;carrier phase adjustment value
    CarrecGammaRho:      .space 2          ;B.W of the carrier recovery PLL filter
    CarrecPdOp:          .space 2          ;C.R. Phase detector output
    CarrecPrevPdOp:      .space 2          ;C.R. previous phase detector output
    CarrecPrevLoopIp:    .space 4          ;PLL loop filter output

.endif
    
; -----------------------------------------------------------------------------
; Variables required for only V.32 modulation
; -----------------------------------------------------------------------------

.if DEF_V32 == 1

; -----------------------------------------------------------------------------
; Variable declarations for Echo Canceller
; -----------------------------------------------------------------------------

    .align 2

    V32RRiCntr:          .space 2

    ;V.32bis Viterbi decoder variables

.if DEF_V32BIS == 1
    VitBitPatsTab:       .space NOOFSTATES       ;Bit pattern buffer
    VitDistsTab:         .space NOOFSTATES*2     ;Minimum distance table
    VitAccumDists:       .space NOOFSTATES*2     ;Accumulated distance table
    VitTmpAccumDists:    .space NOOFSTATES*2     ;Intermediate distance table
    VitPathStatesTab:    .space WNDWSIZE*NOOFSTATES ;Trellis Path states table
    VitPathInputsTab:    .space WNDWSIZE*NOOFSTATES ;Trellis path inputs table
.endif

    ECBaudBits:          .space 2      ;Baud bits for EC ref symbol generation
        
    NECStartPhase:       .space 2
    NECStart:            .space 2
    NECRefSymbolR:       .space 2      ;Reference Symbol(R) for NEC
    NECRefSymbolI:       .space 2      ;Reference Symbol(I) for NEC
    NECTxSwitch:         .space 2      ;Reference Symbol generation switch
                                       ;function for NEC 
    NECSymbolsI:         .space 2      ;Final NEC Reference Symbol (I) 
    NECSymbolsQ:         .space 2      ;Final NEC Reference Symbol (Q) 
    NECSymbolCntr:       .space 2      ;NEC Reference Symbol Counter

    FECStartPhase:       .space 2
    FECStart:            .space 2
    FECCarPhase:         .space 2
    FECRefSymbolR:       .space 2      ;Reference Symbol(R) for FEC
    FECRefSymbolI:       .space 2      ;Reference Symbol(I) for FEC
    FECTxSwitch:         .space 2      ;Reference symbol generation switch
                                       ;function for FEC 
    FECSymbolsI:         .space 2      ;Final FEC Reference Symbol (I)  
    FECSymbolsQ:         .space 2      ;Final FEC Reference Symbol (Q) 
    FECSymbolCntr:       .space 2      ;FEC Reference Symbol Counter

    V32RateCntr:         .space 2      ;Rate sequence symbol Counters
    V32Rate_1Cntr:       .space 2
    V32SilenceCntr:      .space 2      ;Silnce symbols counter
    
    NECRefBaudBits:      .space NECHOMAXDELAY    ;Reference NEC baud bits
    FECRefBaudBits:      .space MAXBULKDELAY     ;Reference FEC baud bits

; -----------------------------------------------------------------------------
; V.32 specific variables
; -----------------------------------------------------------------------------
     
    V32TrnScrIndexA:     .space 1      ;Training phase Scrambler buffer index A
    V32TrnScrIndexB:     .space 1      ;Training phase Scrambler buffer index B
    V32TrnScrBuffer:     .space 4      ;V32SCRAMBLERLEN ;TRN phase scrambler buffer
      
    .align 2

    V32ScrIndexA:        .space 1      ;Data scrambler buffer Index-A 
    V32ScrIndexB:        .space 1      ;Data scrambler buffer Index-B 
    V32ScrBuffer:        .space 4      ;Data scrambler buffer
         
    .align 2

    V32DescrIndexA:      .space 1      ;Data descrambler buffer Index-A 
    V32DescrIndexB:      .space 1      ;Data scrambler buffer Index-B 
    V32DescrBuffer:      .space 4      ;Data descrambler buffer

.endif

    bssLastVar:          .space 1
        
; *****************************************************************************
; Memory Declaration for Modem variables under .xbss section
; *****************************************************************************

    .section .xbss, "b"

; -----------------------------------------------------------------------------
; Variables required for only V.32 modulation
; -----------------------------------------------------------------------------

.if DEF_V32 == 1
    NECDlyLineI:         .space NECSPAN*2  ;NEC I Delay Line
.endif

; -----------------------------------------------------------------------------
; Variables required for all modulation protocols
; -----------------------------------------------------------------------------
   
    SIPLCoefBuf:         .space SIPL_LENGTH*2;sipl coefficients buffer
    modemTimerA:         .space 4      ;Modem timers used to time the different
    modemTimerB:         .space 4      ;data pump events

; -----------------------------------------------------------------------------
; Variables required for only V.32 modulation
; -----------------------------------------------------------------------------

.if DEF_V32 == 1   
    FECDlyLineI:         .space FECSPAN*2  ;FEC I Delay Line               
   
    NECCoefs1Q:          .space NECSPAN*2  ;NEC Q Coefs of Sample1
    NECCoefs2Q:          .space NECSPAN*2  ;NEC Q Coefs of Sample2
    NECCoefs3Q:          .space NECSPAN*2  ;NEC Q Coefs of Sample3

    FECCoefs1Q:          .space FECSPAN*2  ;FEC Q Coefs of Sample1
    FECCoefs2Q:          .space FECSPAN*2  ;FEC Q Coefs of Sample2
    FECCoefs3Q:          .space FECSPAN*2  ;FEC Q Coefs of Sample3
.endif

; -----------------------------------------------------------------------------
; Variables required for only V.32 and V.22bis modulations
; -----------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)
    eqzCoefsI:           .space MAXEQZLEN*2 ;Equalizer Coefficients I
    eqzCoefsQ:           .space MAXEQZLEN*2 ;Equalizer Coefficients Q
.endif
    
    xbssLastVar:         .space 1

; -----------------------------------------------------------------------------
; Memory Declaration for Modem variables under .ybss section
; -----------------------------------------------------------------------------

   .section    .ybss, "b" 
   .align 128

; -----------------------------------------------------------------------------
; Variables required for only V.32 and V.22bis modulations
; -----------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)
    eqzDlyI:             .space 128        ;Equalizer delay line buffer(I)
    eqzDlyQ:             .space 128        ;Equalizer delay line buffer(Q)
.endif

; -----------------------------------------------------------------------------
; Variables required for all modulation protocols
; -----------------------------------------------------------------------------

.if DEF_V32 == 1
    mdmFilterBuffer:     .space 496
.else
    mdmFilterBuffer:     .space 232
.endif

    mesgMsgParams:       .space  2     ;MAXMSGLEN ;Message Parameters

    SIPLPrevPhase:       .space 2      ;Previous phase adjustment
    SIPLOutput:          .space SIPL_OPBUF*2 ;Sipl output sample buffer
    SIPLDlyPtr:          .space 2      ;Sipl filter delay line pointer
    SIPLDlyEnd:          .space 2      ;Pointer to end of SIPL delay line

    dataTxBitFn:         .space 2          ;to switch according to mode
    dataRxBitFn:         .space 2          ;to switch according to mode

; -----------------------------------------------------------------------------
; Variables required for only V.32 modulation
; -----------------------------------------------------------------------------

.if DEF_V32 == 1
    NECDlyLineQ:         .space NECSPAN*2  ;NEC Q Delay Line 

    FECCoefs2I:          .space FECSPAN*2  ;FEC I Coefs of Sample2
    FECCoefs3I:          .space FECSPAN*2  ;FEC I Coefs of Sample3
.endif

; -----------------------------------------------------------------------------
; Variables required for all modulation protocols
; -----------------------------------------------------------------------------

    mdmMeanPRunAvg:      .space 4          ;Mean Parameter Run average
    mdmMeanPAvg:         .space 2          ;Mean Parameter Average
    mdmMeanPCntr:        .space 2          ;Mean Parameter counter
    mdmMeanPLevel:       .space 2          ;Mean Parameter Level
    mdmMeanPIp:          .space 2          ;Mean Parameter Interpolation Factor

    dmcCarrierTimer:     .space 4  

; -----------------------------------------------------------------------------
; Variables required for only V.32 modulation
; -----------------------------------------------------------------------------

.if DEF_V32 == 1
    FECDlyLineQ:         .space FECSPAN*2  ;FEC Q Delay Line
.endif

; -----------------------------------------------------------------------------
; Variables required for all modulation protocols
; -----------------------------------------------------------------------------

    ChnPcmBufLen:        .space 2      ;Channel PCM frame length
    ChnPcmInPtr:         .space 2      ;Pointer to PCM input samples buffer
    ChnPcmOutPtr:        .space 2      ;Pointer to PCM out samples buffer
    
    ChnInMsgTop:         .space 2      ;Ptr to top of In message Queue buffer
    ChnMsgInWPtr:        .space 2      ;Write Pointer to In Message Queue 
    ChnMsgInRPtr:        .space 2      ;Read pointer to In Mssage Queue
    ChnInMsgEnd:         .space 2      ;Ptr to end of In Message Queue buffer
    
    ChnOutMsgTop:        .space 2      ;Ptr to top of Out message Queue buffer
    ChnMsgOutWPtr:       .space 2      ;Write Pointer to Out Message Queue
    ChnMsgOutRPtr:       .space 2      ;Read pointer to Out Mssage Queue
    ChnOutMsgEnd:        .space 2      ;Ptr to end of Out Message Queue buffer
    
    ChnMsgInRAddr:       .space 2      ;Ptr to In Message Queue Read pointer 
    ChnMsgOutWAddr:      .space 2      ;Ptr to Out Message Queue write pointer 

    ;User configuration variables
    
    ucTxScaleFactor:     .space 2      ;User configurable transmit gain 
    ucDtmfDuration:      .space 2      ;DTMF tone duration 
    ucTransmitLevel:     .space 2      ;Signal transmit level

    mdmDemI:             .space 2      ;Demodulated symbol(I)
    mdmDemQ:             .space 2      ;Demodulated symbol(Q)
    mdmDecI:             .space 2      ;Decision generator output(I)
    mdmDecQ:             .space 2      ;Decision generator output(Q)
    
    mdmADCSample:        .space 2      ;ADC sample (Received sample)
    mdmIpBpCoefsPtr:     .space 2      ;Input bandpass filter delay pointer

    dmcTxBufferLength:   .space 2
    dmcRxBufferLength:   .space 2

; -----------------------------------------------------------------------------
; Variables required for only V.32 and V.22bis modulations
; -----------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)
   .align 64
    hilbDlyLine:         .space 64         ;Hilbert filter delay line

    hilbOp_I:            .space 2      ;Hilbert filter output(I)
    hilbOp_Q:            .space 2      ;Hilbert filter output(Q)
    hilbDlyPtr:          .space 2      ;Hilbert filter delayline pointer
    hilbDlyEnd:          .space 2      ;Pointer to end of the filter delay line
    hilbCoefPtr:         .space 2      ;Pointer to hilbert coefficients

    TRNDetectScntr:      .space 2      ;Counter used in detection of S signal 
    TRNDetectSDetect:    .space 2      ;Flag to indicate the detection of S
    TRNDetectScntrSet:   .space 2      ;Counter(Fixed) used in detection of S     
    TRNDetectBuffer:     .space 32     ;Buffer used to store Demod points
.endif

; -----------------------------------------------------------------------------
; Variables required for all modulation protocols
; -----------------------------------------------------------------------------
    
    mdmAverageInputLevel:.space 2      ;Average input signal level
    mdmAgcMinEnLevel:    .space 2      ;Minimum energy level for AGC
    
    modemTransmiter:     .space 2      ;Modem Transmiter function pointer
    modemReceiver:       .space 2      ;Modem Receiver function pointer
    modemManager:        .space 2      ;Modem Manager function pointer
    
    mdmTxGainFactor:     .space 2      ;Gain factor for transmit signal
    mdmSamplePhaseAdjust:.space 2      ;Sample phase adjustment required

    ybssLastVar:         .space 2

; -----------------------------------------------------------------------------
; END OF FILE
; -----------------------------------------------------------------------------


