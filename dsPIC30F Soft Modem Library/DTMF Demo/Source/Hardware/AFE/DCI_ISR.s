/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               dci_ISR.S                                          *
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
;   Here the DCI ISR routine has been implemented to read and write samples.  *
;                                                                             *
;******************************************************************************
;  DCIInterrupt                                                               *
;  ======================                                                     *
;  Description: This DCI interrupt serivce routine writes and reads the data  *
;  to/from Codec Buffers.                                                     *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3,w4,w10,w11,TXBUF,RXBUF                                       *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     0 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   7                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     DCIInterrupt:                  53                                       *
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
;     DCIInterrupt:                  55                                       *
;                                                                             *
;*****************************************************************************/

.equ DEF_RTOS,    0

.if DEF_RTOS == 1
.equ SM_TASK_ROM_TCB_ID,     0x01
.equ SM_CODEC_EVENT,         0x01
.endif
; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

        .include "p30f6014.inc"
        .include "codecasm.inc"      

; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

.global __DCIInterrupt

__DCIInterrupt:        

    PUSH.D  w0
    PUSH.D  w2
    PUSH.D  w4
    PUSH.D  w6
    PUSH.D  w10                        ;Save the Register contents

.if DEF_RTOS == 1
	 K_OS_Intrp_Entry
.endif

    INC   _CodecIntrCntr               ;Increment the Interrupt counter

.if DEF_RTOS == 1
    mov    #40, w0
    cp     _CodecIntrCntr
    bra    lt,  NO_CODEC_EVENT
    nop

    K_Event_Signal 0,SM_TASK_ROM_TCB_ID,SM_CODEC_EVENT 

NO_CODEC_EVENT:
.endif

    MOV   #_CodecTxBuffer, w4          ;Get the codec tx buffer pointer
    MOV   _CodecTxRIndex, w1    

    sl    w1, #1, w3
                
    MOV   _CodecRxWIndex,w10           ;Codec rx buffer write index
    MOV   #_CodecRxBuffer, w11         ;rx buffer pointer

    MOV  [w4+w3], w2                   ;Get the data from CodecTX Buffer       

    INC  w1, w1                        ;Increment the Codec read Index

    MOV   #(CODECBUFLEN), w3
    cp    w1, w3                       ;Check the buffer boundary condition
    bra   nz, L1
    clr   w1                            
 L1:       
    mov  w1, _CodecTxRIndex            ;Update the CodecRIndex
        
    CLR   w3 
    BCLR  SR, #0                       ;reset carry bit
    RRC   w2, w2                       ;rotate LSb into carry 
    RRC   w3, w3                       ;rotate LSb into MSb for timeslot 1
    MOV   w2, TXBUF0                   ;load TX buffer for timeslot 0
    MOV   w3, TXBUF1                   ;load TX buffer for timeslot 1
      
; do nothing time slots for know        
    MOV  #0x0000, w0
    MOV  w0, TXBUF2                    ;load TX buffer for timeslot 8 
    MOV  #0x8000, w0
    MOV  w0, TXBUF3                    ;load TX buffer for timeslot 9

; save off data read                

    SL    w10, #1, w2        
        
    MOV   RXBUF0, w0                   ;read time slot 0
    MOV   RXBUF1, w1                   ;read time slot 1
    RLC   w1, w1                       ;compensate for errata
    RLC   w0, w0                       ;mask in LSb from previous time slot MSb

    MOV   w0, [w11+w2]    

    MOV   RXBUF2, w0                   ;read time slot 8
    MOV   RXBUF3, w1                   ;read time slot 9
        
    INC   w10, w10                     ;Increment the CodecWIndex
        
    MOV   #(CODECBUFLEN), w1
    cp    w10, w1                      ;Chk if CodecWIndex exceeds Max
    bra   nz, L2
    clr   w10                          ;reset the CodecWIndex
 L2:       
    MOV   w10, _CodecRxWIndex          ;Update codecWIndex

exit:
    BCLR  IFS2, #DCIIF                 ;ensure DCI interrupt flag is reset

.if DEF_RTOS == 1
    K_OS_Intrp_Exit
.endif

    POP.D  w10                         ;Retrive the saved registers
    POP.D  w6
    POP.D  w4
    POP.D  w2
    POP.D  w0
    disi   #1
    RETFIE                             ;return from Interrupt Service routine
         
                
   .end

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------
