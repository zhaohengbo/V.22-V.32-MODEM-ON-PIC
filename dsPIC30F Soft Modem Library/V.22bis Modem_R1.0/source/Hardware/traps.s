;******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               Traps.S                                            *
;  Date:                   25th Nov,2002                                      *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.43.00.0                             *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;   Here the Exception Traps Service Routines have been implemented. User     *
;   specific code may be required for these traps.                            *
;******************************************************************************

; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

.include "p30f6014.inc"        

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

         .text
        .global  __ReservedTrap0
        .global  __OscillatorFail
        .global  __AddressError
        .global  __StackError 
        .global  __MathError
        .global  __ReservedTrap5
        .global  __ReservedTrap6
        .global  __ReservedTrap7
        
        .global  __AltReservedTrap0
        .global  __AltOscillatorFail
        .global  __AltAddressError
        .global  __AltStackError 
        .global  __AltMathError
        .global  __AltReservedTrap5
        .global  __AltReservedTrap6
        .global  __AltReservedTrap7
        
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------

/* Reserved Trap0 Placeholder */
__ReservedTrap0:
RsvTrap0:
        nop
        bra   RsvTrap0
        retfie    

/* Oscillator Fail Trap */
__OscillatorFail:
OscFail:
        nop
        bra   OscFail
        bclr  INTCON1, #OSCFAIL
        retfie        

/* Address Error Trap */
__AddressError:
AddErr: 
        nop       
;        bra   AddErr   
        bclr  INTCON1, #ADDRERR   
        retfie    

/* Stack Error Trap */        
__StackError:
StackErr:
        nop       
        bra   StackErr        
       	bclr  INTCON1, #STKERR   
		retfie	   
  
/* Math Error Trap */
__MathError:
MathErr:
        nop    
		bra   MathErr
		bclr  INTCON1, #MATHERR
		retfie
        
/* Reserved Trap5 Placeholder */
__ReservedTrap5: 
RsvTrap5:
        nop
        bra   RsvTrap5
        retfie     

/* Reserved Trap6 Placeholder */        
__ReservedTrap6:        
RsvTrap6:
        nop
        bra   RsvTrap6
        retfie    
 
/* Reserved Trap7 Placeholder */       
__ReservedTrap7:        
RsvTrap7:
        nop
        bra   RsvTrap7
        retfie  
        


/* Alternate Exception Vector handlers if ALTIVT = 1, INTCON2<15> */


/* Alternate Reserved Trap0 Placeholder */       
__AltReservedTrap0:
AltRsvTrap0:
        nop
        bra   AltRsvTrap0
        retfie   

/* Alternate Oscillator Fail Trap */
__AltOscillatorFail:
AltOscFail:
        nop
        bra   AltOscFail
        bclr  INTCON1, #OSCFAIL
        retfie        

/* Alternate Address Error Trap */
__AltAddressError:
AltAddErr: 
        nop       
        bra   AltAddErr   
        bclr  INTCON1, #ADDRERR   
        retfie    

/* Alternate Stack Error Trap */          
__AltStackError:
AltStackErr:
        nop       
        bra   AltStackErr        
       	bclr  INTCON1, #STKERR   
		retfie	      

/* Alternate Math Error Trap */
__AltMathError:
AltMathErr:
        nop    
		bra   AltMathErr
		bclr  INTCON1, #MATHERR
		retfie    
        
/* Alternate Reserved Trap5 Placeholder */    
__AltReservedTrap5: 
AltRsvTrap5:
        nop
        bra   AltRsvTrap5
        retfie    

/* Alternate Reserved Trap6 Placeholder */            
__AltReservedTrap6:        
AltRsvTrap6:
        nop
        bra   AltRsvTrap6
        retfie      
 
/* Alternate Reserved Trap7 Placeholder */           
__AltReservedTrap7:        
AltRsvTrap7:
        nop
        bra   AltRsvTrap7
        retfie   
                                    
         .end

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------
