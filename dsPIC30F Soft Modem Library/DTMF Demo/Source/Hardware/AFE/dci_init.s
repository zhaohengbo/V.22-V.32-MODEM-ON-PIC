/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               dci_init.S                                         *
;  Date:                   24th May, 2004                                     *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.50.00                               *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;   Here the initialization of DCI Registers has been done.                   *
;                                                                             *
;******************************************************************************
;  Init_DCI                                                                   *
;  ======================                                                     *
;  Description: This function initializes the DCI I/O Signals, also configures*
;               the data for Positive edge or Negative Edge triggered         *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    DCICON, TRISF,TRISG,RSCON,TSCON,IFS2                                     *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   0                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     Init_DCI:                  27                                           *
;                                                                             *
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
;     Init_DCI:                  27                                           *
;                                                                             *
;*****************************************************************************/


; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "p30f6014.inc"
    .include "Si3021_mode.inc"
     
;..............................................................................
;..............................................................................

        .global  _Init_DCI
        .text
         
;..............................................................................
; Subroutine: Initialization of DCI module
; General module setup code first
;..............................................................................

_Init_DCI:
; ensure DCI module is placed in known state       
          CLR   DCICON1
          CLR   DCICON2
          CLR   DCICON3     

; general pin direction independent of Master/Slave mode           
        BSET  TRISF, #RF6               ; make codec reset switch "OR" node an input 
        BCLR  TRISG, #RG13              ; CSDO output
        BSET  TRISG, #RG12              ; CSDI input

; receive slot enable
        BSET  RSCON, #0                 ; set receive slot 1 enable 
        
; transmit slot enable
        BSET  TSCON, #0                 ; set transmit slot 1 enable

; Frame sync mode (bits 1:0)
        BCLR  DCICON1, #COFSM0
        BCLR  DCICON1, #COFSM1         ; set for multichannel frame sync mode

; data justification control
        BSET  DCICON1, #DJST           ; data xmit/rx begins 1 clock after Fs pulse

; sample clock edge control bit
        BCLR DCICON1, #CSCKE           ; data changes on rising, sampled on falling

; ******************************************************************************
;  Si3021 is Master Controller / DCI Slave    (Errata workaround)
; ******************************************************************************
.if Si3021_Master_E == 1 

; ensure port pins are set correctly          
        BSET  TRISG, #RG15              ; COFS input driven by Si3021
        BSET  TRISG, #RG14              ; CSCK input driven by Si3021

        MOV   #0b0000000111101111, W0   ; data word size is 16-bits (bits 3:0)
        MOV   W0, DCICON2               ; data frame is 16 words (bits 8:5)

; set buffer length control (4 data words will be buffered between interrupts)
        BSET  DCICON2, #BLEN1
        BSET  DCICON2, #BLEN0          ; 4 words buffered per interrupt
                
        CLR   DCICON3                  ; ensure bit clock count = 0

; frame sync direction control        
        BSET  DCICON1, #COFSD          ; frame sync driven by Si3021

; clock is input from Si3000
        BSET  DCICON1, #CSCKD          ; clock is input to DCI from Si3021


; receive slot enable
        BSET  RSCON, #1                ; enable time slot 1
        BSET  RSCON, #8                ; enable time slot 8
        BSET  RSCON, #9                ; enable time slot 9    
                    
; transmit slot enable
        BSET  TSCON, #1                ; enable time slot 1 (for errata)
        BSET  TSCON, #8                ; enable time slot 8 
        BSET  TSCON, #9                ; enable time slot 9 (for errata)

.endif    

        BCLR   IFS2, #DCIIF            ; ensure flag is reset
        RETURN
        
        .end

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------
