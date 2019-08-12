;******************************************************************************
;FILE NAME:     SI3021_OUTPUTS.INC
;******************************************************************************

.equ  minus_one,                   0x8000
.equ  minus_one_with_secondary,    0x8001

.equ  plus_one,                    0x7FFE
.equ  plus_one_with_secondary,     0x7FFF

;******************************************************************************
; Si3021 Register Address Summary (Table 22, Si3034-Rev. 2.01)
; Read Control Address has bit 13 set 
; Write Control Address has bit 13 clear
;******************************************************************************

.equ  Read_Control_1,               0x2100  ; Register 1        
.equ  Write_Control_1,              0x0100

.equ  Read_Control_2,               0x2200  ; Register 2
.equ  Write_Control_2,              0x0200

.equ  Read_Control_3,               0x2300  ; Registers 3 and 4 are reserved.
.equ  Read_Control_4,               0x2400

.equ  Read_DAA_Control_1,           0x2500  ; Register 5
.equ  Write_DAA_Control_1,          0x0500

.equ  Read_DAA_Control_2,           0x2600  ; Register 6
.equ  Write_DAA_Control_2,          0x0600

.equ  Read_PLL1_Divide_N1,          0x2700  ; Register 7
.equ  Write_PLL1_Divide_N1,         0x0700

.equ  Read_PLL1_Divide_M1,          0x2800  ; Register 8
.equ  Write_PLL1_Divide_M1,         0x0800

.equ  Read_PLL2_Div_Mult_N2_M2,     0x2900  ; Register 9
.equ  Write_PLL2_Div_Mult_N2_M2,    0x0900

.equ  Read_PLL_Control,             0x2A00  ; Register 10
.equ  Write_PLL_Control,            0x0A00

.equ  Read_ChipA_Revision,          0x2B00  ; Register 11

.equ  Read_Line_Side_Status,        0x2C00  ; Register 12
.equ  Write_Line_Side_Status,       0x0C00

.equ  Read_ChipB_Revision,          0x2D00  ; Register 13
.equ  Write_ChipB_Revision,         0x0D00

.equ  Read_Daisy_Chain_Control,     0x2E00  ; Regiser 14
.equ  Write_Daisy_Chain_Control,    0x0E00

.equ  Read_TX_RX_Gain_Control,      0x2F00  ; Register 15
.equ  Write_TX_RX_Gain_Control,     0x0F00

.equ  Read_International_Control1,  0x3000  ; Register 16
.equ  Write_International_Control1, 0x1000  

.equ  Read_International_Control2,  0x3100  ; Regiser 17
.equ  Write_International_Control2, 0x1100

.equ  Read_International_Control3,  0x3200  ; Register 18
.equ  Write_International_Control3, 0x1200

.equ  Read_International_Control4,  0x3300  ; Register 19
.equ  Write_International_Control4, 0x1300


; for Si3035 DAA only

.equ  Read_IIR_Filter_Control,      0x3000  ; Register 16
.equ  Write_IIR_Filter_Control,     0x1000  

;******************************************************************************
; END OF FILE
;******************************************************************************
