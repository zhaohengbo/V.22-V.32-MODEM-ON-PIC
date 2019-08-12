
;------------------------------------------------------------------------------
; FILE NAME : DETTABLES.S
;------------------------------------------------------------------------------

    .include "dettables.inc"

.section .DTMFDET_TABLES, "r"

;Used for mapping the detected DTMF digit
digitmap:
.hword 35,04,05,06,14,15,16,24,25,26,07,17,27,37,34,36

;DTMF digits

digit:

.hword 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

;DTMF Detection coefficients
coeff:

.hword  27979, 26955, 25701, 24218, 19072, 16324, 13013, 9315
.hword  15013, 11582, 7549, 3032, -10565, -16502, -22318, -27471  

;------------------------------------------------------------------------------
; END OF FILE
;------------------------------------------------------------------------------
