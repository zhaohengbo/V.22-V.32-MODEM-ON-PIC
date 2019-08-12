
;******************************************************************************
;FILE NAME:    SI3021CONFIG.INC
;******************************************************************************

/*-------------------------------------------------------------------------
 TX/Rx Gain Control Register Settings
--------------------------------------------------------------------------*/

    .equ R15_TXM,             0       ; Mutes the transmit signal 
                                      ; 1 = Mute 

    .equ R15_RXM,             0       ; Mutes the received signal
                                      ; 1 = Mute


    .equ R15_ARX,             0       ; Analog Receive Gain Selection
                                      ; 0 = 0 dB gain
                                      ; 1 = 3 dB gain
                                      ; 2 = 6 dB gain
                                      ; 3 = 9 dB gain
                                      ; 4 = 12 dB gain


    .equ R15_ATX,             0       ; Analog Transmit Attenuation Selection
                                      ; 0 = 0 dB attenuation
                                      ; 1 = 3 dB attenuation
                                      ; 2 = 6 dB attenuation
                                      ; 3 = 9 dB attenuation
                                      ; 4 = 12 dB attenuation 
 


/*-------------------------------------------------------------------------
 International Control Registers Settings
--------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------
 Chip Set Selction Options
--------------------------------------------------------------------------*/

    .equ DEF_Si3034,          1       ; Global Based Chip Set
    .equ DEF_Si3035,          0       ; FCC and JATE Based Chip Set 



/*-------------------------------------------------------------------------
 International Control Registers Settings
 [Default FCC Mode is selected]
--------------------------------------------------------------------------*/

    /* On-Hook Speed */ 
    .equ R16_OHS,             0       ; 0 = Si3034 executes fast on-hook
                                      ; 1 = Si3034 executes slow, controlled on-hook


    /* Ac termination select */
    .equ R16_ACT,             0       ; 0 = Selects real impedance
                                      ; 1 = Selects complex impedance


    /* IIR or FIR filter selection for transmit and receive filters */
    .equ R16_IIRE,            0       ; 0 = Enable FIR Filter
                                      ; 1 = Enable IIR Filter


    /* DC Termination select */
    .equ R16_DCT,             2       ; 1 = Japan mode
                                      ; 2 = FCC mode
                                      ; 3 = CTR21 mode

    /* Ringer Impedance selection */
    .equ R16_RZ,              0       ; 0 = Maximum (high) ringer impedance
                                      ; 1 = Synthesize ringer impedance


/* 
   Used to satisfy country requirements on ring detection. Signals below the lower level
   will not generate a ring detection; signals above the upper level are guaranteed
   to generate a ring detection
*/

    .equ R16_RT,              0       ; 0 = 11 to 22 Vrms
                                      ; 1 = 17 to 33 Vmrs


    /* Current Limit */
    .equ R17_LIM,             0       ; 0 = All other modes
                                      ; 1 = CTR21 mode


    /* Force Japan DC termination mode */
    .equ R18_FJM,             0       ; 0 = Normal gain
                                      ; 1 = Force Japan DC termination mode


    /* Line Voltage Adjust */
    .equ R18_VOL,             0       ; 0 = Normal
                                      ; 1 = -0.125V
                                      ; 2 = 0.25V
                                      ; 3 = 0.125V


/*-------------------------------------------------------------------------
 END OF FILE
--------------------------------------------------------------------------*/
