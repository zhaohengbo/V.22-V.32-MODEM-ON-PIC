/******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               Basicop.S                                          *
;  Date:                   10th  September,2002                               *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.00.14                               *
;                          Language tools -> 1.00.00                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;  Revision History:                                                          *
; ----------------------------------------------------------------------------*
; Rev:   Date:              Details:                                Who:      *
; ----------------------------------------------------------------------------*
; 0.1   10 Sept   2002   Code Created                                Rajiv    *
; 0.2   16 Sept   2002   Code Reviewed                               Raghava  *
; 0.3   18 April  2004   DIVF instruction is used                    Raghava  *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  Basic operations implementation for Microchip's dsPIC30F 16-bit MCU.       *
;                                                                             *
;  Description: Here the Basic operations like Squareroot and Divide are      *
;               performed.                                                    *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;******************************************************************************
;  squareroot:                                                                *
;  ======================                                                     *
;  Description: This function computes the squareroot of a given number.      *
;                                                                             *
;  Input:  w0 w1 = Long Number                                                *
;                                                                             *
;  Output: w0 = squareroot of a long number                                   *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11         used not restored           *
;   ACC A, ACC B                                  used not restored           *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;  divide:                                                                    *
;  ======================                                                     *
;  Description: This function performs the division operation.                *
;                                                                             *
;  Input:  w0 = dividend                                                      *
;          w4 = divisor                                                       *
;                                                                             *
;  Output: w0 = Quotient                                                      *
;                                                                             *
;  System Resource usage:                                                     *
;   w0,w4,w8,w9                       used not restored                       *
;                                                                             *
;  Functions Called:  None                                                    *
;                                                                             *
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   5                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     squareroot:      45                                                     *
;     divide:          10                                                     *
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
;     squareroot:      Depends on the Number                                  *
;     divide:          27                                                     *
;                                                                             *
;*****************************************************************************/

    .global _squareroot
    .section  .libdtmf, "x"

; -----------------------------------------------------------------------------
;  Description:   This function comuptes the squareroot of a given number
; -----------------------------------------------------------------------------
_squareroot:

    clr        A
    clr        B
    mov        #0, w4
    mov        #0x1, w5                ; 0x10000
    
    mov        w4, w6
    mov        w4, w7                  ; count=0
    
    mov        w4, w8
    mov        w4, w9                  ; root=0
      
    sub        w0, w4, w4
    subb       w1, w5, w5
    bra        lt, NEXT                ; if(power >= 0x10000) 
    
    clr        w2
    clr        w3
    bset       w3, #14                 ; 1<<30
    bra        CHK_BIT                 ; skip else

NEXT:
    clr        w2
    clr        w3
    bset       w2, #14                 ; 1<<14

CHK_BIT:

    sub        w2, #0, w2
    subb       w3, #0, w3
    bra        z, EXIT_SQROOT          ; chk for non-zero number
    
    add        w6, #1, w6
    addc       w7, #0, w7              ; count++
    
    add        w2, w8, w10
    addc       w3, w9, w11             ; trial=root+bit
    
    sub        w0, w10, w4
    subb       w1, w11, w5
        
    bra        lt, NEXT1               ; if (power >= trial)
    
    mov        w4, w0
    mov        w5, w1                  ; power -= trial
    
    add        w10, w2, w8
    addc       w11, w3, w9             ; root = trial+bit
    
NEXT1:
     
    mov        w8, ACCAL
    mov        w9, ACCAH
    sftac      A, #1                   ; root >>= 1
    
    mov        ACCAL, w8
    mov        ACCAH, w9
      
    mov        w2, ACCBL
    mov        w3, ACCBH
    sftac      B, #2                   ; bit >>= 2
    
    mov        ACCBH, w3
    mov        ACCBL, w2               ; update bit
    bra        CHK_BIT
    
EXIT_SQROOT:

    mov        w8, w0                  ; return root
    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _divide
    .section  .libdtmf, "x"

; -----------------------------------------------------------------------------
;  Description:   This function performs the division operation using DIVF 
;                 instruction
; -----------------------------------------------------------------------------

_divide:

    push        w8
    push        w9                     ;Save the required registers
 
    mov         w0,w8                  ;w8 - Dividend
    mov         w4,w9                  ;w9 - Divisor

    repeat      #17
    divf        w8,w9                  ;Execute DIVF in the loop
    
EXIT_DIV:

    pop        w9
    pop        w8

    return                             ;Return the quotient in w0

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global Shiftleft    
    .section  .libdtmf, "x"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------


Shiftleft:    
    mov        #0xC000, w0
    mov        w0, w1
    and        ACCAH, wreg
    bra        z, SHIFT
    cp         w0, w1
    bra        nz, NO_SHIFT
SHIFT:    
    sftac      A, #-1
    bra        LAST

NO_SHIFT:
    mov        #0x8000, w0
    and        ACCAH, wreg
    bra        z, POSITIVE
    clr        A
    lac        w0, #0, A
    bra        LAST
POSITIVE:
    mov        #0x7FFF, w0
    mov        #0xffff, w1
    lac        w0, #0, A
    mov        w1, ACCAL    
LAST:
    return
            
    

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------

