;******************************************************************************
;File Name:   SIPL.H
;******************************************************************************
;------------------------------------------------------------------------------
; SIPL Module constant defines
;------------------------------------------------------------------------------

.equ SIPL_LENGTH,    20                ;SIPL filter length
.equ SIPL_OPBUF,     2                 ;SIPL output buffer
.equ IPF,            512               ;Interpolation factor
.equ NFM1,           511                
.equ SIPL_DELAY,     SIPL_LENGTH/2     ;SIPL filter delay

;------------------------------------------------------------------------------
; SIPL Module: Global definations of variables
;------------------------------------------------------------------------------

.global    SIPLPrevPhase               ;Previous phase adjustment
.global    SIPLCoefBuf                 ;sipl coefficients buffer
.global    SIPLOutput                  ;Sipl output sample buffer
.global    SIPLDlyPtr                  ;Sipl filter delay line pointer
.global    SIPLDlyEnd                  ;Pointer to end of SIPL delay line
.global    SIPLDlyLine                 ;Sipl filter delay line


;******************************************************************************
;    END OF FILE
;******************************************************************************
