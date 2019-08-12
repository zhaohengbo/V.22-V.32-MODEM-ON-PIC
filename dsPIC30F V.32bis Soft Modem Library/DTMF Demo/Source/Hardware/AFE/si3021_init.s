/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               si3021_init.S                                      *
;  Date:                   24th May, 2004                                     *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.50.00                               *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Other Files Required:   p30F6014.gld, p30f6014.inc                         *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;        The following functionalities have been implemented in this module   *
;     * si3034 Programming                                                    *
;     * Changing the sampling rate                                            *
;     * on/off hook control                                                   *
;     * speaker off control                                                *
;                                                                             *
;******************************************************************************
;  Init_Si3021                                                                *
;  ======================                                                     *
;  Description: This function initializes si3034 codec/DAA.                   *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    DCISTAT,TXBUF,RXBUF,TRISG,LATG,PORTG,w0,w1                               *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  go_on_hook                                                                 *
;  ======================                                                     *
;  Description: This function makes the modem to go on hook.                  *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    DCIIE,DCISTAT,TXBUF,w0                                                   *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  go_off_hook                                                                *
;  ======================                                                     *
;  Description: This function makes the modem to go off hook.                 *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    DCIIE,DCISTAT,TXBUF,w0                                                   *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   0                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     Init_Si3021:                  40                                        *
;     go_on_hook:                   14                                        *
;     go_off_hook:                  32                                        *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;     None                                                                    *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     Init_Si3021:           Depends on the Pulse duration and Hardware       *
;     go_on_hook:            Depends on TMPTY bit                             *
;     go_off_hook:           Depends on TMPTY bit                             *
;                                                                             *
;*****************************************************************************/


; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

    
    .include "p30f6014.inc"
    .include "Si3021_outputs.inc"
    .include "Si3021config.inc"
    .include "codecasm.inc"
  
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.equ  rst_3021,  8
.equ  OFFHK,     7
.equ  RGDT,      9
.equ  FC,        6

;..............................................................................
; Global Declarations:
;..............................................................................

    .global  _Init_Si3021
    .text


;******************************************************************************
; Subroutine: Initialization of Si3021 Codec
;******************************************************************************

_Init_Si3021:
; init for OFFHK pin
    BSET  LATG, #OFFHK                 ;ensure RG7 (OFFHK pin) is high
    BCLR  TRISG, #OFFHK                ;set pin to output

; init for RGDT pin
    BSET  TRISG, #RGDT                 ;ensure ring detect pin is input    

; init for FC pin (optional pin to request secondary frame)
    BCLR  LATG, #FC                    ;ensure pin state is low
    BCLR  TRISG, #FC                   ;ensure pin is output            
        
    BSET  LATG, #rst_3021              ;set Si3021 reset pin high
    BCLR  TRISG, #rst_3021             ;set pin as output 
        
    
;******************************************************************************
; DCI Module Errata operation !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; 
; Implementing all 4 TXBUF registers to reduce interrupt frequency
;******************************************************************************
        
; WRITE to PLL1_Divide_N1 Control Register 7

    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_PLL1_Divide_N1 >> 1, W0
    IOR  #0x001f >> 1, W0
    MOV  W0, TXBUF2                    ;0x071f (set sampling Fs @ 8000)
    MOV  #0x8000, W0
    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame
        
; synchronize DCI with Si3021 to ensure first frame synce is aligned with TXBUF0

    BCLR  LATG, #rst_3021
    BCLR  TRISG, #rst_3021             ;ensure pin is output 
    REPEAT  #150 
    NOP                                ;minimum pulse of 5uS
    BSET  LATG, #rst_3021              ;release codec 
    NOP
    
    BSET  DCICON1, #DCIEN              ;enable DCI module

; this ensures the first primary and secondary frame use current data         

not_empty1:

    BTSS  DCISTAT, #TMPTY
    BRA   not_empty1

; at this point we are ready to load the TXBUF registers again

        
;******************************************************************************

; WRITE to PLL1_Divide_M1 Control Register 8

    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)
        
    MOV  #Write_PLL1_Divide_M1 >> 1, W0
    IOR  #0x00e0 >>1, W0
    MOV  W0, TXBUF2                    ;0x08e0 (set sampling Fs @ 8000)
    MOV  #0x0000, W0
    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

not_empty2:

    BTSS  DCISTAT, #TMPTY
    BRA   not_empty2

; at this point we are ready to load the TXBUF registers again
        
        
;******************************************************************************

; WRITE to Write_PLL_Control Register 10

    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_PLL_Control >> 1, W0
    IOR  #0x0001 >>1, W0
    MOV  W0, TXBUF2                    ;0x0A01 (set CGM = 1, use 25/16 ratio)
    MOV  #0x8000, W0
    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

not_empty3:

    BTSS  DCISTAT, #TMPTY
    BRA   not_empty3

; at this point we are ready to load the TXBUF registers again

        
;******************************************************************************

; WRITE to PLL2_Div_Mult_N2_M2 Control Register 9

    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_PLL2_Div_Mult_N2_M2 >> 1, W0
    IOR  #0x0089 >> 1, W0
    MOV  W0, TXBUF2                    ;N2 - 9, M2 - 10 (Fs @ 8000Hz)
    MOV  #0x8000, W0
    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

not_empty4:

    BTSS  DCISTAT, #TMPTY
    BRA   not_empty4

; at this point we are ready to load the TXBUF registers again

;******************************************************************************

; WRITE to TX/RX Gain Control Register 15

    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_TX_RX_Gain_Control >> 1, W0

    MOV  #R15_ATX << 4,W1
    MOV  #R15_ARX,W2    
    IOR  W1,W2,W1 

.if R15_TXM == 1
    BSET  W1, #7
.endif

.if R15_RXM == 1
    BSET  W1, #3
.endif
    ASR    W1,#1,W1
    IOR    W1,W0,W0 
   
    MOV  W0, TXBUF2                    ;N2 - 9, M2 - 10 (Fs @ 8000Hz)
.if (R15_ARX == 1 || R15_ARX == 3)
    MOV  #0x8000, W0
.endif
.if (R15_ARX == 0 || R15_ARX == 4)
    MOV  #0x0000, W0
.endif

    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

not_emptyr15:

    BTSS  DCISTAT, #TMPTY
    BRA   not_emptyr15

; at this point we are ready to load the TXBUF registers again


.if DEF_Si3034 == 1

;******************************************************************************

; WRITE to International Control 1 - Register 16

    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_International_Control1 >> 1, W0

    CLR  W1
    MOV  #R16_DCT << 2,W1

.if R16_OHS == 1
    BSET W1, #6
.endif   

.if R16_ACT == 1
    BSET W1, #5
.endif

.if R16_IIRE == 1
    BSET W1, #4
.endif

.if R16_RZ == 1
    BSET W1, #1
.endif
 
.if R16_RT == 1
    BSET W1, #0
.endif
    ASR  W1,#1,W1
    IOR  W1,W0,W0

    MOV  W0, TXBUF2                    
    MOV  #0x0000, W0
.if R16_RT == 1
    MOV  #0x8000, W0
.endif
    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

wait_reg16_1:

   BTSS  DCISTAT, #TMPTY
   BRA   wait_reg16_1

; at this point we are ready to load the TXBUF registers again

;******************************************************************************

; WRITE to International Control 2 - Register 17

    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_International_Control2 >> 1, W0

    MOV  #R17_LIM << 3,W1
    ASR  W1,#1,W1
    IOR  W1,W0,W0

    MOV  W0, TXBUF2                    
    MOV  #0x0000, W0
    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

wait_reg17_1:

    BTSS  DCISTAT, #TMPTY
    BRA   wait_reg17_1

; at this point we are ready to load the TXBUF registers again


;******************************************************************************

; WRITE to International Control 3 - Register 18

    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_International_Control3 >> 1, W0

    CLR  W1
    MOV  #R18_VOL << 3,W1

.if R16_DCT == 2

.if R18_FJM == 1
    BSET W1, #5
.endif

.endif   
    ASR  W1,#1,W1
    IOR  W1,W0,W0

    MOV  W0, TXBUF2                    
    MOV  #0x0000, W0
    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

wait_reg18_1:

    BTSS  DCISTAT, #TMPTY
    BRA   wait_reg18_1

; at this point we are ready to load the TXBUF registers again

.endif

;******************************************************************************

.if DEF_Si3035 == 1

; WRITE to International Control 1 - Register 16

    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_International_Control1 >> 1, W0

    MOV  #0x0008,W1
  
.if R16_IIRE == 1
    BSET W1, #4
.endif

    ASR  W1,#1,W1
    IOR  W1,W0,W0

    MOV  W0, TXBUF2                    
    MOV  #0x0000, W0
    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

wait_reg16_2:

   BTSS  DCISTAT, #TMPTY
   BRA   wait_reg16_2

.endif

;******************************************************************************

; simple check for testing overflow bit functionality
    BTSS  DCISTAT, #ROV
    BRA   EN_LS_CHIP
        
    MOV   RXBUF0, W0
    MOV   RXBUF1, W0
    MOV   RXBUF2, W0
    MOV   RXBUF3, W0

;******************************************************************************

EN_LS_CHIP:

; **********************************************
; enable the LINE SIDE CHIP here
; **********************************************

; WRITE DAA_Control_2 - Register 6

    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_DAA_Control_2 >> 1, W0
    IOR  #0x0080 >> 1, W0

    MOV  W0, TXBUF2                    ;0x0680 - Charge pump configuretion
    MOV  #0x0000, W0
    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

    BCLR  IFS2, #DCIIF                 ;reset ISR flag

wait_pdl:

    BTSS  DCISTAT, #TMPTY
    BRA   wait_pdl


; ***** Some delay for to allow calibration to occur **************************

    MOV  #0x042, W1
outer1: 
    MOV  #0xFFFF, W0
inner1:    
    DEC  W0, W0
    BRA  NZ, inner1
    DEC  W1, W1
    BRA  NZ, outer1        

    BSET   IEC2, #DCIIE                   ;enable interrupts
    nop                        
    nop 
                
    RETURN

;******************************************************************************
; DESCRIPTION:  This function makes the Si3034 to go on Hook
;******************************************************************************

    .global  _go_on_hook
    .text

_go_on_hook:


; WRITE to DAA_Control_1 - Register 5

    BCLR   IEC2, #DCIIE                ;disable interrupts
        
    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_DAA_Control_1 >> 1, W0
    IOR  #0x0000 >> 1, W0              ;On- Off- Control Register
    MOV  W0, TXBUF2                    ;0x0500
    MOV  #0x0000, W0
    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

on_hook_wait:

    BTSS  DCISTAT, #TMPTY
    BRA   on_hook_wait

    BSET   IEC2, #DCIIE                  ;Enable interrupts

    return;
        
;******************************************************************************
; DESCRIPTION:  This function makes the Si3034 to go off Hook
;******************************************************************************

    .global  _go_off_hook
    .text

_go_off_hook:
    
    BCLR   IEC2, #DCIIE                   ;disable interrupts

; WRITE to DAA_Control_1 - Register 5

    MOV  W0,W1
 
    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_DAA_Control_1 >> 1, W0
    IOR  #0x0001 >> 1, W0              ;On- Off- Control Register
    MOV  W0, TXBUF2                    ;0x0501
    MOV  #0x8000, W0
    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

wait_off_hook1:

    BTSS  DCISTAT, #TMPTY
    BRA   wait_off_hook1

; at this point we are ready to load the TXBUF registers again

; **********************************************
; enable the LINE SIDE CHIP here
; **********************************************

; WRITE DAA_Control_2 - Register 6

    MOV  #plus_one_with_secondary >> 1, W0
    MOV  W0, TXBUF0
    MOV  #0x8000, W0
    MOV  W0, TXBUF1                    ;extra write for setting MSbit of TS1 (LSbit of TS0)

    MOV  #Write_DAA_Control_2 >> 1, W0
    BSET W1,#7
    ASR  W1,#1,W2
    IOR  W0,W2,W0
    MOV  W0, TXBUF2                    

    MOV  #0x8000, W0
    BTSS W1,#0
    MOV  #0x0000, W0

    MOV  W0, TXBUF3                    ;extra write for LSb of secondary frame

    BCLR  IFS2, #DCIIF                 ;reset ISR flag

wait_off_hook2:

    BTSS  DCISTAT, #TMPTY
    BRA   wait_off_hook2

;******Dealy ******************************************************************

    MOV  #0x042, W1
ofh_out_delay1: 
    MOV  #0xFFFF, W0
ofh_in_delay1:    
    DEC  W0, W0
    BRA  NZ, ofh_in_delay1
    DEC  W1, W1
    BRA  NZ, ofh_out_delay1

    BSET   IEC2, #DCIIE                   ;Enable interrupts

    return;
 
;******************************************************************************
;    END OF FILE
;******************************************************************************
          
 
