;******************************************************************************
; File Name:   DEFS.H
;******************************************************************************

;------------------------------------------------------------------------------
; INCLUDE FILES
;------------------------------------------------------------------------------

    .include "dpconfig.inc"

;------------------------------------------------------------------------------
; Variable definations for Data pump variables in the overlap memory space. 
; overlap memory means, that part of memory which is used for all the 
; modulation protocols.
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Call progress module variable definations
;------------------------------------------------------------------------------

.equ    cpCPStatus,          mdmvar1

;------------------------------------------------------------------------------
; V.8 state machine module variable definations
;------------------------------------------------------------------------------

.equ    V8State,             mdmvar2     ;State of the V8 hand shake
.equ    V8TxByteCounter,     mdmvar3     ;Transmit bit counter of some sequence
.equ    V8TxByteCounterSet,  mdmvar4     ;Number of bits to be transmitted in a 
.equ    V8RxStrLen,          mdmvar5     ;Length of the received string

;------------------------------------------------------------------------------
; FSK - (V.21/V.23) module variable definations
;------------------------------------------------------------------------------

.equ    FSKValidCntr,        mdmvar6     ;Used for validating the initial 20 1's
.equ    FSKChangeCount,      mdmvar7     ;FSK phase change count
.equ    FSKTxSampleCnt,      mdmvar8     ;Transmit sample counter(baud switching)
.equ    FSKTxIpFactor,       mdmvar9     ;FSK Tx Interpolation factor
.equ    FSKRxIpFactor,       mdmvar10    ;FSK Rx interpolation factor
.equ    FSKTxBand,           mdmvar11    ;Used to determine the FSK Tx rate    
.equ    FSKRxBand,           mdmvar12    ;Used to determine the FSK rx rate

;------------------------------------------------------------------------------
; Call progress module variable definations
;------------------------------------------------------------------------------

.equ    ucBusyOnTime,        mdmvar76    ;Busy tone cadence
.equ    ucBusyOffTime,       mdmvar77
.equ    ucReorderOnTime,     mdmvar78    ;Reorder tone cadence
.equ    ucReorderOffTime,    mdmvar79
.equ    ucRingOnTime,        mdmvar80    ;Ring back tone cadence 
.equ    ucRingOffTime,       mdmvar81
.equ    ucRingCount,         mdmvar82    ;Number of rings           

.equ    cpDTAPRunAvg,        mdmvar4_82
.equ    cpDTAPAvg,           mdmvar83
.equ    cpDTAPCntr,          mdmvar84
.equ    cpDTAPLevel,         mdmvar85
.equ    cpDTAPIp,            mdmvar86

.equ    cpDTToneStatus,      mdmvar87    ;Tone present/absence status
.equ    cpDTThreshold,       mdmvar88    ;Threshold level for tone detection
    
.equ    cpBTAPRunAvg,        mdmvar4_88
.equ    cpBTAPAvg,           mdmvar89
.equ    cpBTAPCntr,          mdmvar90
.equ    cpBTAPLevel,         mdmvar91
.equ    cpBTAPIp,            mdmvar92

.equ    cpBTToneStatus,      mdmvar93    ;Tone present/absence status
.equ    cpBTThreshold,       mdmvar94    ;Threshold level for tone detection

.equ    cpRBTAPRunAvg,       mdmvar4_94    
.equ    cpRBTAPAvg,          mdmvar95
.equ    cpRBTAPCntr,         mdmvar96
.equ    cpRBTAPLevel,        mdmvar97
.equ    cpRBTAPIp,           mdmvar98

.equ    cpRBTToneStatus,     mdmvar99    ;Tone present/absence status
.equ    cpRBTThreshold,      mdmvar100   ;Threshold level for tone detection

.equ    cpDTOnTimer,         mdmvar101
.equ    cpDTOffTimer,        mdmvar102

.equ    cpBTOnTimer,         mdmvar103
.equ    cpBTOffTimer,        mdmvar104

.equ    cpRBTOnTimer,        mdmvar105
.equ    cpRBTOffTimer,       mdmvar106
     
.equ    cpBTTransitions,     mdmvar107
.equ    cpRTTransitions,     mdmvar108
.equ    cpRBTTransitions,    mdmvar109

.equ    cpBTStatusFilter,    mdmvar110
.equ    cpRBTStatusFilter,   mdmvar111
    
.equ    cpPrevBTStatus,      mdmvar112
.equ    cpPrevRBTStatus,     mdmvar113

.equ    cpCurBTStatus,       mdmvar114
.equ    cpCurRBTStatus,      mdmvar115

.equ    cpBusyOnTime,        mdmvar116
.equ    cpBusyOffTime,       mdmvar117
.equ    cpBusyCadence,       mdmvar118

.equ    cpReorderOnTime,     mdmvar119
.equ    cpReorderOffTime,    mdmvar120
.equ    cpReorderCadence,    mdmvar121

.equ    cpRingOnTime,        mdmvar122
.equ    cpRingOffTime,       mdmvar123
.equ    cpRingCadence,       mdmvar124

;------------------------------------------------------------------------------
; V.8 state machine module variable definations
;------------------------------------------------------------------------------

.equ    V8RemDetails,        mdmvar125   ;Bit Mapped variable identifying remote
.equ    V8RxStrPtr,          mdmvar126   ;Pointer to received string buffer

;------------------------------------------------------------------------------
; FSK - (V.21/V.23) module variable definations
;------------------------------------------------------------------------------

.equ    FSKTxBaudCount,      mdmvar127   ;Transmit baud counter
.equ    FSKIpSample,         mdmvar128   ;FSK input sample

.equ    FSKFmultFactor0,     mdmvar129   ;Demod multiplication factor
.equ    FSKFmultFactor1,     mdmvar130   ;Demod multiplication factor
.equ    FSKDsmp0,            mdmvar131   ;Used to save Previous samples
.equ    FSKDsmp1,            mdmvar132   ;in FSK demodulation
.equ    FSKDsmp2,            mdmvar133      
.equ    FSKDsmp3,            mdmvar134      
.equ    FSKDsmp4,            mdmvar135      
.equ    FSKDsmp5,            mdmvar136      
.equ    FSKLpOp,             mdmvar137   ;FSK LPF output
.equ    FSKtemp,             mdmvar138      
.equ    FSKCarAdvance,       mdmvar139   ;FSK carrier advance
.equ    FSKCurPhase,         mdmvar140      
.equ    FSKMarkAdvance,      mdmvar141   ;FSK mark frequencey advance
.equ    FSKSpaceAdvance,     mdmvar142   ;FSK space frequency advance
.equ    FSKBpCoefPtr,        mdmvar143   ;BP filter coefficient pointer
.equ    FSKLpCoefsPtr,       mdmvar144   ;LP filter coefficient pointer
.equ    FSKBpDlPtr,          mdmvar145   ;BP filter delay line pointer
.equ    FSKBpDlEnd,          mdmvar146   ;BP filter delay line end pointer

;------------------------------------------------------------------------------
; V.25 module variable definations
;------------------------------------------------------------------------------

.equ    V25PhaseRevCntr,     mdmvar147   ;Counter to time out 450 ms for  
                                         ;phase reversals
.equ    V25AnsTimer,         mdmvar148   ;Timer for setting ans duration
.equ    V25TxSmpl,           mdmvar149   ;ANS/ANSam transmit sample
.equ    V25DTAvgPRunAvg,     mdmvar4_149 ;V25 tone Run Average parameter
.equ    V25DTAvgPAvg,        mdmvar150   ;V25 tone Average parameter
.equ    V25DTAvgPCntr,       mdmvar151   ;V25 tone avg power Counter
.equ    V25DTAvgPLevel,      mdmvar152   ;V25 tone avg power Level
.equ    V25DTAvgPStatus,     mdmvar153   ;V25 tone avg power Status
.equ    V25DTAvgPIp,         mdmvar154   ;V25 tone avg power Input
.equ    V25DTAvgPPrevIp,     mdmvar155   ;V25 Previous Input

.equ    V25DTThreshold,      mdmvar156   ;V25 threshold
.equ    V25AnsStatus,        mdmvar157   ;to indicate the status of ans 
                                         ;detection
.equ    V25SampleHigh,       mdmvar158   ;Modulation high sample
.equ    V25SampleLow,        mdmvar159   ;modulation low sample

.equ    V25AmCntr,           mdmvar160   ;To count the modulation interval 
.equ    V25AnswerBandCoefsPtr, mdmvar161 ;Pointer to access the answer band
                                         ;coefficients table
.equ    V25AmFilterPtr,      mdmvar162   ;Pointer to access the Am filter
                                         ;table

.equ    V25DTToneStatus,     mdmvar163   ;V25 tone Status indication
.equ    V25TxFnPtr,          mdmvar164   ;Points to a function for the 
                                         ;generation of required type of 
                                         ;answer tone
.equ    V25AnsPhase,         mdmvar165   ;Phase advance for ANS (2100Hz) tone
.equ    V25AnsAmPhase,       mdmvar166   ;phase advance for 15Hz signal

;------------------------------------------------------------------------------
; V.22bis module variable definations
;------------------------------------------------------------------------------

.equ    V22BitRate,          mdmvar1     ;Flag to select the bit rate for V22
.equ    V22ScrOnesCntr,      mdmvar2     ;Incremented for every scrambled 
                                         ;binary 1
.equ    V22DescrOnesCntr,    mdmvar3     ;Incremented for every received 
                                         ;binary 1
.equ    V22TxSampleCntr,     mdmvar4     ;Transmit sample counter(Used for 
                                         ;baud switching)
.equ    V22RxSampleCntr,     mdmvar5     ;Receive sample counter(Used for 
                                         ;baud switching)
.equ    V22BaudBits,         mdmvar6     ;Used to assemble the bits in a baud
.equ    V22PrevBaudBits,     mdmvar7     ;Assembled previous baud bits
.equ    V22PrevTxPhase,      mdmvar8     ;Transmit Phase used for V22 
                                         ;encoding
.equ    V22PrevRxPhase,      mdmvar9     ;Receive Phase used for V22 encoding
.equ    V22S1Detect,         mdmvar10    ;Flag to indicate the S1 signal 
                                         ;detection
.equ    V22RxSyncBits,       mdmvar11    ;Used to assemble a group of bits
.equ    V22ClkAdj,           mdmvar12    ;Clock adjustment flag
.equ    V22S1Cntr,           mdmvar13    ;Counter for counting S1 symbols
.equ    V22S1Dibit,          mdmvar14    ;Di bit pattern used in encoding
.equ    V22ClkCntr,          mdmvar15    ;Counter used in clock recovery
.equ    V22TotPhase,         mdmvar16    ;V22 Total Phase
.equ    V22FallBack,         mdmvar17    ;Flag to enable the fall back 


.equ    V22TxBaudCntr,       mdmvar76    ;Transmit Baud counter(used for 
                                         ;state switching)
.equ    V22RxBaudCntr,       mdmvar77    ;Receive Baud counter(used for 
                                         ;state switching) 
.equ    V22TxCarPhase,       mdmvar78    ;Transmit carrier phase
.equ    V22RxCarPhase,       mdmvar79    ;Receive carrier phase
.equ    V22Scr1Cntr,         mdmvar80    ;Counter for counting scrambled 1's

.equ    V22ScrState,         mdmvar4_82  ;Gives the state of the scrambler
.equ    V22DescrState,       mdmvar4_88  ;Gives the state of the descrambler
    
.equ    V22TxSwitch,         mdmvar81    ;Transmit and receive function 
                                         ;pointers
.equ    V22RxSwitch,         mdmvar82    ;used to switch between different 
                                         ;states
.equ    V22DecFnPtr,         mdmvar83    ;Decoder function pointer
.equ    V22TxCarAdvance,     mdmvar84    ;Transmit carrier phase advance
.equ    V22RxCarAdvance,     mdmvar85    ;Receive carrier phase advance
.equ    V22SmpEarlyEng,      mdmvar86    ;Used to store the signal energy
.equ    V22SmpLateEng,       mdmvar87    ;Used to store the signal energy
.equ    V22SmpMidEng,        mdmvar88    ;Used to store the signal energy
.equ    V22BpCoefPtr,        mdmvar89    ;Pointer to BP filter
.equ    V22GrdTnAdv,         mdmvar90    ;Guard tone advance factor
.equ    V22GrdTnSum,         mdmvar91    ;Guard tone advance advance sum
.equ    V22GrdTnScl,         mdmvar92    ;guard tone scaling factor
.equ    V22BpIpDlyPtr,       mdmvar93    ;BP delay line pointer
.equ    V22BpIpCoefPtr,      mdmvar94    ;Pointer to BP filter
.equ    V22BpIpDlyEnd,       mdmvar95    ;Delay End pointer
.equ    V22AnsBpCoefsPtr,    mdmvar96    ;pointer to BP Answer mode filter
.equ    V22DiffEncTabPtr,    mdmvar97    ;Pointer to the V22DiffEncTab table
.equ    V22Symb1200Ptr,      mdmvar98    ;Pointer to the V22Symb1200 table
.equ    V22Symb2400Ptr,      mdmvar99    ;Pointer to the V22Symb2400 table
.equ    V22QuadBitsPtr,      mdmvar100   ;Pointer to the V22QuadBits table

;------------------------------------------------------------------------------
; V.32 module variable definations
;------------------------------------------------------------------------------

.equ    V32TxSampleCntr,     mdmvar1     ;Transmit sample counter(baud switching)
.equ    V32RxSampleCntr,     mdmvar2     ;Receive sample counter(baud switching) 
.equ    V32PrevTxPhase,      mdmvar3     ;Previous transmit phase used in data
                                         ;encoder 
.equ    V32PrevRxPhase,      mdmvar4     ;Previous receive phase used in data
                                         ;decoder
.equ    V32EnBaudProc,       mdmvar5     ;Flag to enable receive baud rate signal
                                         ;processing
.equ    V32GotRate,          mdmvar6     ;Flag to indicate the reception of rate
                                         ;rate sequence(R1,R2,R3)
.equ    V32BDEstPhase,       mdmvar7     ;Flag used to indicate the bulk delay 
                                         ;estimation phase
.equ    V32EcTrnFlag,        mdmvar8     ;Flag to indicate the echo canceller
                                         ;training phase
.equ    V32TcmEnable,        mdmvar9     ;Flag to enbale/disable NON_TCM/TCM mode
.equ    V32BitRate,          mdmvar10    ;Bit rate selection
.equ    V32FallBack,         mdmvar11    ;Fallback to V.22 mode enable
.equ    V32GotE,             mdmvar12    ;Flag to indicate the detection of E

;------------------------------------------------------------------------------
; Equalizer module variable definations
;------------------------------------------------------------------------------

.equ    eqzSpan,             mdmvar18    ;Equalizer filter length
.equ    eqzFlockStatus,      mdmvar19    ;equalizer based clock recovery 
                                         ;enable/disable flag
.equ    eqzFlockBaudCnt,     mdmvar20    ;Counter for phase adjustment for clock
                                         ;recovery
.equ    eqzFlockBaudCntSet,  mdmvar21    ;initialized counter for equalizer
                                         ;flockbaud
.equ    eqzCntr,             mdmvar22    ;Counter for equalizer adaption
.equ    eqzCntrSet,          mdmvar23    ;initialized counter for equalizer 

;------------------------------------------------------------------------------
; Echo Canceller module variable definations
;------------------------------------------------------------------------------

.equ    NECBaudClkSet,       mdmvar24    ;Reference factor for IP factor
.equ    NECBaudClk,          mdmvar25    ;Reference factor for baud rate    
.equ    NECUpdateEnable,     mdmvar26    ;Enable/Disable NEC filter adaption
.equ    NECSwitch,           mdmvar27    ;Switching between bauds 

.equ    FECBaudClkSet,       mdmvar28    ;Reference factor for IP factor
.equ    FECBaudClk,          mdmvar29    ;Reference factor for baud rate    
.equ    FECUpdateEnable,     mdmvar30    ;Enable/Disable NEC filter adaption
.equ    FECSwitch,           mdmvar31    ;Switching between bauds

.equ    ECEnable,            mdmvar32    ;Enable/Disable echo cancellation

;------------------------------------------------------------------------------
; V.32 module variable definations
;------------------------------------------------------------------------------

.equ    V32TxBaudCntr,       mdmvar76    ;Transmit baud counter 
.equ    V32RxBaudCntr,       mdmvar77    ;Receive baud counter

.equ    V32ConfirmedRateRxData,   mdmvar78   ;Final confirmed rate sequence word 
.equ    V32Rate1,            mdmvar79    ;Rate sequence (R1) word value
.equ    V32Rate2,            mdmvar80    ;Rate sequence (R2) word value
.equ    V32RefE,             mdmvar81    ;Reference E sequence word
.equ    V32TxRateWord,       mdmvar82    ;Transmit rate word
.equ    V32RecTimer,         mdmvar4_82  ;Timer count used for timeouts in V.32
.equ    V32RxRateWord,       mdmvar83    ;Receives rate word
.equ    V32ValidRateCntr,    mdmvar84    ;Counter to validate the rate sequence
.equ    V32BlkDlyTimer,      mdmvar85    ;Timer count used during bulk delay 
                                         ;estimation

   
.equ    V32RxTrnBaudCnt,     mdmvar86    ;Counter used for equalizer training
.equ    V32FDMode,           mdmvar87    ;Full duplex mode flag
.equ    V32TxHsOver,         mdmvar88    ;Flag to indicate the end of V.32 HS   

.equ    V32TxCarrier,        mdmvar89    ;Transmit carrier phase
.equ    V32RxCarrier,        mdmvar90    ;Receive carrier phase
.equ    V32PrevRateRxData,   mdmvar91    ;Received rate sequence word
.equ    V32Rate3,            mdmvar92    ;Rate sequence (R3) word value 
.equ    V32DefRateWord,      mdmvar93    ;Defined rate word (Default Rate)
.equ    V32MaxLocal,         mdmvar94    ;Maximum local modem connect rate 
.equ    V32MaxRemote,        mdmvar95    ;maximum remote modemc connect rate
.equ    V32Rate4,            mdmvar96    ;Rate sequence (R4) word value 
.equ    V32PrevQuad,         mdmvar97    ;Quadrant of previous received point
.equ    V32RRCntr,           mdmvar98    ;Counter used for rate renegotiation
.equ    V32DtMdMse,          mdmvar99    ;Equalizer MSE during data mode
.equ    V32LocRR,            mdmvar100   ;Flag to indicate the start of Local
                                         ;Rate Renegotiation
.equ    V32RetBaudCntr,      mdmvar101   ;Baud counter used during retrain
   
.equ    V32TxSwitch,         mdmvar102   ;Transmit state switching used for 
                                         ;HS state switching
.equ    V32RxSwitch,         mdmvar103   ;Receive state switching used for HS
                                         ;state switching
.equ    V32DecFnPtr,         mdmvar104   ;Decoder/Decision point generation 
    
.equ    V32IpBpDlyPtr,       mdmvar105   ;Input BP filter delay buf pointer
.equ    V32IpBpDlyEnd,       mdmvar106   ;Ptr to end of BP filter delay line
.equ    V32IpBpCoefPtr,      mdmvar107   ;Ptr to BP filter coefficients
   
.equ    V32EncTabPtr,        mdmvar108   ;Encoder table pointer
.equ    V32NT96SymbIPtr,     mdmvar109   ;Encoder symbol(I) table pointer
.equ    V32NT96SymbQPtr,     mdmvar110   ;Encoder symbol(Q) table pointer
.equ    V32RateSymbPtr,      mdmvar111   ;4 Point symbols for Rate sequence 
.equ    V32QuadBitsPtr,      mdmvar112   ;Bits corresponds to the quadrant

;------------------------------------------------------------------------------
; PSF module variable definations
;------------------------------------------------------------------------------

.equ    PSFIpFactor,         mdmvar113   ;InterPolation factor used to 
                                         ;interpolate the samples
.equ    PSFCoefAddress,      mdmvar114   ;PSF coefficients buffer pointer
.equ    PSFCoefPtr,          mdmvar115   ;Pointer to selected PSF coefs
.equ    PSFLen,              mdmvar116   ;Length of PS filter
.equ    PSFDlyIndex,         mdmvar117   ;Delay line pointer to PS filter
.equ    PSFDlyLen,           mdmvar118   ;PSF delay length
.equ    PSFOpI,              mdmvar119   ;PSF output component(I)
.equ    PSFOpQ,              mdmvar120   ;PSF output component(Q)
.equ    PSFIpI,              mdmvar121   ;PSF input component(I)
.equ    PSFIpQ,              mdmvar122   ;PSF input component(Q)

;------------------------------------------------------------------------------
; Echo Canceller module variable definations
;------------------------------------------------------------------------------

.equ    NECRefPtrR,          mdmvar123   ;Read Index to NEC reference symbol buf
.equ    NECRefPtrW,          mdmvar124   ;Write Index to NEC reference symbol buf
.equ    NECBaudCntr,         mdmvar125   ;Bauds counter for NEC cancellation
.equ    NECDelay,            mdmvar126   ;Delay in Near end echo    
.equ    NECDlIndex,          mdmvar127   ;Index to NEC filter delay line    
.equ    NECBeta,             mdmvar128   ;Step size factor for LMS algorithm    
.equ    NECCarAdv,           mdmvar129   ;Carrier advance factor               
.equ    NECCarPhase,         mdmvar130   ;Carrier phase factor                  
.equ    NECOpSample,         mdmvar131   ;Output sample after echo cancellation 
.equ    NECCoefShift,        mdmvar132   ;Scaling factor filter coefficients
.equ    NECCoefPtrI,         mdmvar133   ;Pointer filter NEC CoefsI
.equ    NECCoefPtrQ,         mdmvar134   ;Pointer filter NEC CoefsQ

.equ    FECRefPtrR,          mdmvar135   ;Read Index to FEC reference symbol buf
.equ    FECRefPtrW,          mdmvar136   ;Write Index to FEC reference symbol buf
.equ    FECBaudCntr,         mdmvar137   ;Bauds counter for FEC
.equ    FECOpSample,         mdmvar138   ;FEC output sample
.equ    FECDlIndex,          mdmvar139   ;Index to FEC filter delay line    
.equ    FECBeta,             mdmvar140   ;Step size for FEC filter adaption    
.equ    FECBetaSet,          mdmvar141   ;Initial Step size for FEC filter adapt
.equ    FECCoefShift,        mdmvar142   ;Scaling factor filter coefficients
.equ    FECCoefPtrI,         mdmvar143   ;Pointer filter FEC CoefsI
.equ    FECCoefPtrQ,         mdmvar144   ;Pointer filter FEC CoefsQ
    
.equ    ECTotalBauds,        mdmvar145   ;Total number of bauds for EC training
.equ    ECCarAdv,            mdmvar146   ;Carrier advance factor
.equ    ECOpSample,          mdmvar147   ;Echo cancelled sample
.equ    ECRoundTripDelay,    mdmvar148   ;Round trip delay in connection
.equ    ECBulkDelay,         mdmvar149   ;Estimated bulk delay for the far echo
.equ    ECResidue,           mdmvar150   ;Residue factor of echo canceller
.equ    ECCoefShift,         mdmvar151   ;EC Shift factor
.equ    ECTrnFlag,           mdmvar152   ;EC Training flag
.equ    ECFECRefPtr,         mdmvar153   ;Reference pointer of FEC
.equ    ECFECBufferLength,   mdmvar154   ;FEC Buffer Length

;------------------------------------------------------------------------------
; Equalizer module variable definations
;------------------------------------------------------------------------------

    
.equ    eqzIpI,              mdmvar155   ;Equalizer input symbol (I)
.equ    eqzIpQ,              mdmvar156   ;Equalizer input symbol (Q)
.equ    eqzOpI,              mdmvar157   ;Equalizer output symbol(I)
.equ    eqzOpQ,              mdmvar158   ;Equalizer output symbol(Q)
.equ    eqzDlyPtr,           mdmvar159   ;Equalizer filter delayline pointer
.equ    eqzBBErrorI,         mdmvar160   ;Baseband error component(I)
.equ    eqzBBErrorQ,         mdmvar161   ;Baseband error component(Q)
.equ    eqzErrorI,           mdmvar162   ;Equalizer error vector (I)
.equ    eqzErrorQ,           mdmvar163   ;Equalizer error vector (Q)
.equ    eqzStepSize,         mdmvar164   ;Step size for the equalizer adaption
.equ    eqzMse,              mdmvar165   ;Mean Square Error of error
.equ    eqzMTSmplPos,        mdmvar166   ;position of the main tap of equalizer
                                         ;(samples)
.equ    eqzFlockRefTapEgy,   mdmvar167   ;Energy of the equalizer tap

;------------------------------------------------------------------------------
; FSK module: Variable offsets for the general filter buffer
;------------------------------------------------------------------------------

.equ    FSKBpDl,             0
.equ    FSKLpDl,             82

;------------------------------------------------------------------------------
; V.25 module: Variable offsets for the general filter buffer
;------------------------------------------------------------------------------

.equ    V25DTDelayLine,      98
.equ    V25ModDelayLine,     106 

;------------------------------------------------------------------------------
; V.8 module: Variable offsets for the general filter buffer
;------------------------------------------------------------------------------

.equ    V8RxBitStream1,      114 
.equ    V8RxBitStream2,      129   
.equ    V8DefV8Octets,       144
.equ    V8Codes,             152

;------------------------------------------------------------------------------
; CP module: Variable offsets for the general filter buffer
;------------------------------------------------------------------------------

.equ    cpDTDelayLine,       160   
.equ    cpBTDelayLine,       168   
.equ    cpRBTDelayLine,      176    

;------------------------------------------------------------------------------
; V.32/V.22 modules PSF: Variable offsets for the general filter buffer
;------------------------------------------------------------------------------

.if (DEF_V32 == 1 || DEF_V22 == 1)
.equ    V32IpBpDlyLine,      0
.equ    V22BpDlyLine,        0
.equ    PSFDlyI,             96                   
.equ    PSFDlyQ,             112
.endif

;------------------------------------------------------------------------------
; V.32 -Echo canceller modules: Variable offsets for the general filter buffer
; All Modulations: Variable offsets for the general filter buffer
;------------------------------------------------------------------------------

.if DEF_V32 == 1
.equ    NECCoefs1I,          128 
.equ    NECCoefs2I,          208 
.equ    NECCoefs3I,          288
.equ    FECCoefs1I,          368
.equ    SIPLDlyLine,         448
.equ    mdmIpBpDly,          488
.else
.equ    mdmIpBpDly,          184
.equ    SIPLDlyLine,         192
.endif

;******************************************************************************
; END OF FILE
;******************************************************************************
