/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               DTMFBuf.S                                          *
;  Date:                   24th May, 2004                                     *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.50.00                               *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;  Revision History:                                                          *
; ----------------------------------------------------------------------------*
; Rev:   Date:              Details:                                Who:      *
; ----------------------------------------------------------------------------*
; 0.1   11 Sept   2002   Code Created                                Rajiv    *
; 0.2   16 Sept   2002   Code Reviewed                               Raghava  *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  DTMF Detector implementation for Microchip's dsPIC30F 16-bit MCU.          *
;                                                                             *
;  Description:                                                               *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;  DTMFDetection:                                                             *
;  ======================                                                     *
;  Description: This Function detects the Valid DTMF digit.                   *
;                                                                             *
;  Input:  w0 = inputType                                                     *
;          w1 = Buffer address                                                *
;          w2 = Address of digitdetect variable                               *
;                                                                             *
;  Output: w0 = process type                                                  *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2,w4,w6,w9,w10      used not restored                              *
;                                                                             *
;  Functions Called:  MemCopy, FrameProcess                                   *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     0 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   10                                         *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     DTMFDetection:   146                                                    *
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
;     DTMFDetection:  Depends on the frame type                               *
;                                                                             *
;*****************************************************************************/

; -----------------------------------------------------------------------------
;   INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "Detconst.inc"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _DTMFDetection
;    .section  .libdtmf, "x"
    .section  .text

; -----------------------------------------------------------------------------
;  Description:  This function performs the Buffer Management and processes  
;                the frame and detects the DTMF digits. 
; -----------------------------------------------------------------------------
_DTMFDetection:

    push       w2                      ;save the address of digitdetect
    cp0        DTMFsubframeCount       ;chk subframecount
    bra        nz, APPEND_20SAMP

    mov        w1, w0
    mov        #DTMFworkBuff, w1       ;Address of the working buffer
    mov        #80, w2                 ;Loop count

    call       _MemCopy                ;copy the samples into working buffer

    mov        #BUFFER_DELAY, w0       ;Return Buffer Delay
    push       w0

    mov        #1, w5
    mov        w5, DTMFsubframeCount   ;Increment the subframe count

    bra        EXIT_DTMFDETECT

APPEND_20SAMP:

    mov       DTMFsubframeCount, w9
    cp        w9, #1                   ;Chk if subframecount is 1
    bra        nz, APPEND_40SAMP

    mov        w0, w4
    mov        w1, w0
    push       w1

    mov        #160, w6                ;offset to the working buffer
    mov        #DTMFworkBuff, w1
    add        w1, w6, w1
    mov        #20, w2                 ;Copy 20 samples into working buffer

    call       _MemCopy                ;Buffer is now contains 100 samples
                                       ;and can be sent for frame processing

    mov        #LEFT_JUSTIFIED, w0
    cp         w4, w0                  ;Chk input type
    bra        nz, PROCESS_FRAME
    mov        #DTMFworkBuff, w10
    
    do         #99, END_SHIFT          ;If left justified, do right justiified
    mov        [w10], w6               ;for all samples of the buffer
    asr        w6, #2, w6
    mov        w6, [w10++]
END_SHIFT:
    nop
PROCESS_FRAME:
    call       _FrameProcess           ;Process the frame of 100 samples
    pop        w1
    mov        #40, w6
    push       w0                      ;save the process type
    add        w1, w6, w0              ;Update the input buffer
    mov        #DTMFworkBuff, w1
    mov        #60, w2                 ;Loop count
    
    call       _MemCopy                ;copy the samples to working buffer
        
    mov        #2, w0
    mov        w0, DTMFsubframeCount   ;Increment the subframecount 

    bra        EXIT_DTMFDETECT

APPEND_40SAMP:

    mov       DTMFsubframeCount, w9
    cp        w9, #2                    ;Chk if subframecount is 2
    bra        nz, APPEND_60SAMP

    mov        w0, w4
    mov        w1, w0
    push       w1

    mov        #120, w6
    mov        #DTMFworkBuff, w1
    add        w1, w6, w1              ;Add the offset to the working buffer
    mov        #40, w2                 ;Loop count

    call       _MemCopy                ;Copy the samples into working buffer

    mov        #LEFT_JUSTIFIED, w0
    cp         w4, w0                  ;Chk input type
    bra        nz, PROCESS_FRAME1
    mov        #DTMFworkBuff, w10
    
    do         #99, END_SHIFT1         ;If left justified, do right justiified
    mov        [w10], w6               ;for all samples of the buffer
    asr        w6, #2, w6

    mov        w6, [w10++]
END_SHIFT1:
    nop
        
PROCESS_FRAME1:
    call       _FrameProcess           ;Process the frame of 100 samples
    pop        w1
    mov        #80, w6
    push       w0
    add        w1, w6, w0              ;Update the input buffer
    mov        #DTMFworkBuff, w1
    mov        #40, w2
    
    call       _MemCopy                ;Copy the samples for next processing
        
    mov        #3, w0
    mov        w0, DTMFsubframeCount   ;Increment the subframecount

    bra        EXIT_DTMFDETECT
    
APPEND_60SAMP:

    mov       DTMFsubframeCount, w9
    cp        w9, #3                   ;Chk if subframecount is 3
    bra        nz, APPEND_80SAMP

    mov        w0, w4
    mov        w1, w0
    push       w1

    mov        #80, w6
    mov        #DTMFworkBuff, w1
    add        w1, w6, w1              ;Add the offset to the working buffer
    mov        #60, w2                 ;Loop count

    call       _MemCopy                ;Copy the samples into working buffer

    mov        #LEFT_JUSTIFIED, w0
    cp         w4, w0                  ;Chk input type
    bra        nz, PROCESS_FRAME2
    mov        #DTMFworkBuff, w10
    
    do         #99, END_SHIFT2         ;If left justified, do right justiified
    mov        [w10], w6               ;for all samples of the buffer
    asr        w6, #2, w6
    mov        w6, [w10++]
END_SHIFT2:
    nop

PROCESS_FRAME2:
    call       _FrameProcess           ;Process the frame of 100 samples
    pop        w1
    mov        #120, w6
    push       w0
    add        w1, w6, w0              ;Update the input buffer
    mov        #DTMFworkBuff, w1
    mov        #20, w2
    
    call       _MemCopy                ;Copy the samples for next processing
        
    mov        #4, w0
    mov        w0, DTMFsubframeCount   ;Increment subframecount

    bra        EXIT_DTMFDETECT

APPEND_80SAMP:

    mov       DTMFsubframeCount, w9
    cp        w9, #4                   ;Chk if subframecount is 4
    bra        nz, APPEND_80SAMP

    mov        w0, w4
    mov        w1, w0
    push       w1

    mov        #40, w6
    mov        #DTMFworkBuff, w1
    add        w1, w6, w1              ;Add the offset to the working buffer
    mov        #80, w2                 ;Loop count

    call       _MemCopy                ;Copy the samples into working buffer

    mov        #LEFT_JUSTIFIED, w0
    cp         w4, w0                  ;Chk input type
    bra        nz, PROCESS_FRAME3
    mov        #DTMFworkBuff, w10
    
    do         #99, END_SHIFT3         ;If left justified, do right justiified
    mov        [w10], w6               ;for all samples of the buffer
    asr        w6, #2, w6

    mov        w6, [w10++]
END_SHIFT3:
    nop
        
PROCESS_FRAME3:
    call       _FrameProcess           ;Process the frame of 100 samples
    pop        w1
    push       w0
    clr        DTMFsubframeCount       ;Reset the subframecount

EXIT_DTMFDETECT:
    pop        w0                      ;Return the process type
    pop        w2
    mov        DTMFcurrentDigit, w1
    mov        w1, [w2]                ;Save the current digit as digit detect
    
    return
; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------

