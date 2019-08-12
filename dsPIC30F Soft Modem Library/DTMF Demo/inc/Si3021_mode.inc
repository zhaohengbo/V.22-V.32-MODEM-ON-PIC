

;******************************************************************************
;FILE NAME:    SI3021_MODE.INC
;******************************************************************************

;******************************************************************************
; currently there is an errata for the DCI module when it is configured as
; a slave device. In the slave mode the frame synce and clock signals
; are supplied by the external Codec device. It has been observed that when the 
; DCI is a slave and the errata deals with when the data is shifted out of the
; DCI relative to the frame sync pulse. Data MSb should shift out one clock after
; the frame sync pulse but infact it shifts out the MSb the same clock pulse as
; the frame sync.
;******************************************************************************

.equ   Si3021_Master_E, 1    ; DCI configured as Slave


;******************************************************************************
; END OF FILE
;******************************************************************************
