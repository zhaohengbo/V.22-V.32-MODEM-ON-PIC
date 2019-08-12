;******************************************************************************
; File Name:   VIT.INC
;******************************************************************************

;------------------------------------------------------------------------------
; Viterbi Decoder DM variables length defineations
;------------------------------------------------------------------------------
    .equ NOOFSTATES,    8
    .equ WNDWSIZE,      20 

    .equ SIZEOFVITDEC_NBSS,    16        ;size of the Vit Decoder data 
    .equ SIZEOFVITDEC_BSS,     188       ;size of the Vit Decoder data 

;------------------------------------------------------------------------------
; Viterbi Decoder: Global definations of variables
;------------------------------------------------------------------------------

    .global VitBitsPerBaud
    .global VitWndwCntr
    .global VitRowsNo
    .global VitPtrToConstell
    .global VitRotate
    .global VitBoundValue
    .global VitMBoundValue
    .global VitDescrShift
    .global VitFinalBits
    .global VitDiffDecTabPtr
    .global VitY12nm1Rx
    .global VitMinDstI
    .global VitMinDstQ
    .global VitPastStatesTabPtr
    .global VitIndexToPath
    .global VitOldMinPath
    .global VitNoOfBreaks
    .global VitCodeShift

    .global VitBitPatsTab
    .global VitDistsTab
    .global VitAccumDists
    .global VitTmpAccumDists
    .global VitPathStatesTab
    .global VitPathInputsTab

;******************************************************************************
; END OF FILE
;******************************************************************************
