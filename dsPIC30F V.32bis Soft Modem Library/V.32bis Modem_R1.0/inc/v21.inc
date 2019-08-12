;******************************************************************************
; File Name:   V21.H
;******************************************************************************

;------------------------------------------------------------------------------
; V.21& B103 State Machine Module constant defines
;------------------------------------------------------------------------------

.equ         V21BAUDRATE,          300   ;V.21 Symbol Rate(300 Symbols/sec)
.equ         V21IPFACTOR,          7200/V21BAUDRATE ;Interpolation Factor(=24)
.equ         V21SAMPLESPERBAUD,    V21IPFACTOR ;Number of samples in a symbol
.equ         V21SAMPLESPERBAUDBY2, V21IPFACTOR/2

.equ         FMARKANSADV,          0x3aab  ;Phase advance for 1650 Hz 
.equ         FSPACEANSADV,         0x41c7  ;Phase advance for 1850 Hz 
.equ         FMARKORGADV,          0x22d8  ;Phase advance for 980 Hz
.equ         FSPACEORGADV,         0x29f5  ;Phase Advance for 1180 Hz

.equ         V21B1ANS,             0x02e0  ;Linear interpolation coefficients
.equ         V21B1ORG,             0x7b00  ;for shifting the samples by pi/2

.equ         V21BPFILTERLEN,       41      ;V.21 band pass filter length 

.equ         B103FMARKANSADV,      0x4F1C  ;Phase advance for 2225 Hz 
.equ         B103FSPACEANSADV,     0x47FF  ;Phase advance for 2025 Hz 
.equ         B103FMARKORGADV,      0x2D27  ;Phase advance for 1270 Hz
.equ         B103FSPACEORGADV,     0x260B  ;Phase Advance for 1070 Hz

.equ         B103B1ANS,            0xEA00  ;Linear interpolation coefficients
.equ         B103B1ORG,            0x4800  ;for shifting the samples by pi/2



;******************************************************************************
;    END OF FILE
;******************************************************************************
