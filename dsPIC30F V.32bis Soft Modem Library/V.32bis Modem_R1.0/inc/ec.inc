;******************************************************************************
; File Name:   EC.H
;******************************************************************************

;------------------------------------------------------------------------------
; Echo canceller Module constant defines
;------------------------------------------------------------------------------

    .equ NECSPAN,         40            ;Maximum of 16 msecs at 2400 baud rate
    .equ NECHOMAXDELAY,   60            ;Maximum of 25 msecs at 2400 baud rate
    .equ NECDELAY,        NECSPAN/2     ;Delay through the NEC
    .equ FECSPAN,         40            ;Maximum of 16 msecs at 2400 baud rate
    .equ MAXBULKDELAY,    250           ;Maximum of 104ms at 2400 baud rate
    .equ FECDELAY,        FECSPAN/2     ;Delay through the NEC

;------------------------------------------------------------------------------
; Echo Canceller Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ SIZEOFNEC_BSS_1,   4
    .equ SIZEOFNEC_BSS_2,   12
    .equ SIZEOFNEC_BSS_3,   9

    .equ SIZEOFNEC_XBSS_1,  40
    .equ SIZEOFNEC_XBSS_2,  120

    .equ SIZEOFNEC_YBSS_1,  120
    .equ SIZEOFNEC_YBSS_2,  40

    .equ SIZEOFFEC_BSS_1,   4
    .equ SIZEOFFEC_BSS_2,   10
    .equ SIZEOFFEC_BSS_3,   9

    .equ SIZEOFEC_XBSS_1,   40
    .equ SIZEOFEC_XBSS_2,   120

    .equ SIZEOFFEC_YBSS_1,  40
    .equ SIZEOFFEC_YBSS_2,  80
    .equ SIZEOFFEC_YBSS_3,  40

;------------------------------------------------------------------------------
; Echo Canceller Module: Global definations of variables
;------------------------------------------------------------------------------

    .global  NECBaudClkSet             ;Reference factor for IP factor
    .global  NECBaudClk                ;Reference factor for baud rate
    .global  NECUpdateEnable           ;Enable/Disable NEC filter adaption
    .global  NECSwitch                 ;Switching between bauds

;    .global  NECReference              ;reference symbol buffer
    .global  NECRefPtrR                ;Read Index to NEC reference symbol buf
    .global  NECRefPtrW                ;Write Index to NEC reference symbol buf
    .global  NECBaudCntr               ;Bauds counter for NEC cancellation
    .global  NECDelay                  ;Delay in Near end echo
    .global  NECDlIndex                ;Index to NEC filter delay line
    .global  NECBeta                   ;Step size factor for LMS algorithm
    .global  NECCarAdv                 ;Carrier advance factor
    .global  NECCarPhase               ;Carrier phase factor
    .global  NECOpSample               ;Output sample after echo cancellation
    .global  NECCoefShift              ;Scaling factor filter coefficients
    .global  NECCoefPtrI               ;Pointer filter NEC CoefsI
    .global  NECCoefPtrQ               ;Pointer filter NEC CoefsQ

    .global  FECBaudClkSet             ;Reference factor for IP factor
    .global  FECBaudClk                ;Reference factor for baud rate
    .global  FECUpdateEnable           ;Enable/Disable NEC filter adaption
    .global  FECSwitch                 ;Switching between bauds

;    .global  FECReference              ;Reference symbol buffer for FEC
    .global  FECRefPtrR                ;Read Index to FEC reference symbol buf
    .global  FECRefPtrW                ;Write Index to FEC reference symbol buf
    .global  FECBaudCntr               ;Bauds counter for FEC
    .global  FECDlIndex                ;Index to FEC filter delay line
    .global  FECBeta                   ;Step size for FEC filter adaption
    .global  FECBetaSet                ;Initial Step size for FEC filter adapt
    .global  FECCoefShift              ;Scaling factor filter coefficients
    .global  FECCoefPtrI               ;Pointer filter FEC CoefsI
    .global  FECCoefPtrQ               ;Pointer filter FEC CoefsQ

    .global  ECEnable                  ;Enable/Disable echo cancellation

    .global  ECTotalBauds              ;Total number of bauds for EC training
    .global  ECCarAdv                  ;Carrier advance factor
    .global  ECOpSample                ;Echo cancelled sample
    .global  ECRoundTripDelay          ;Round trip delay in connection
    .global  ECBulkDelay               ;Estimated bulk delay for the far echo
    .global  ECResidue                 ;Residue factor of echo canceller
    .global  ECCoefShift               ;Coef Shift factor
    .global  ECTrnFlag                 ;EC Train Flag
    .global  ECFECRefPtr               ;FEC Reference pointer
    .global  ECFECBufferLength         ;FEC Buffer Length

    .global  NECCoefs1I                ;Sample 1 NEC I Coefs
    .global  NECCoefs1Q                ;Sample 1 NEC Q Coefs
    .global  NECCoefs2I                ;Sample 2 NEC I Coefs
    .global  NECCoefs2Q                ;Sample 2 NEC Q Coefs
    .global  NECCoefs3I                ;Sample 3 NEC I Coefs
    .global  NECCoefs3Q                ;Sample 3 NEC Q Coefs

    .global  FECCoefs1I                ;Sample 1 FEC I Coefs
    .global  FECCoefs1Q                ;Sample 1 FEC Q Coefs
    .global  FECCoefs2I                ;Sample 2 FEC I Coefs
    .global  FECCoefs2Q                ;Sample 2 FEC Q Coefs
    .global  FECCoefs3I                ;Sample 3 FEC I Coefs
    .global  FECCoefs3Q                ;Sample 3 FEC Q Coefs

    .global  NECDlyLineI               ;NEC I Delay Line
    .global  NECDlyLineQ               ;NEC Q Delay Line

    .global  FECDlyLineI               ;FEC I Delay Line
    .global  FECDlyLineQ               ;FEC Q Delay Line
    .global  FECOpSample

    .global  ECBaudBits
 
    .global  NECStartPhase
    .global  NECStart
    .global  NECRefSymbolR
    .global  NECRefSymbolI
    .global  NECTxSwitch
    .global  NECSymbolsI
    .global  NECSymbolsQ
    .global  NECSymbolCntr

    .global  FECStartPhase
    .global  FECStart
    .global  FECCarPhase
    .global  FECRefSymbolR
    .global  FECRefSymbolI
    .global  FECTxSwitch
    .global  FECSymbolsI
    .global  FECSymbolsQ
    .global  FECSymbolCntr

    .global  NECRefBaudBits
    .global  FECRefBaudBits

    .global  ECSineTabPtr
    .global  NECSineTabIndex 
    .global  FECSineTabIndex

;******************************************************************************
; END OF FILE
;******************************************************************************
