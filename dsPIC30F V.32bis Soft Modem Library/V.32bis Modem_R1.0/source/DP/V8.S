;******************************************************************************
;  Author:                 Third-Party Developer                              *
;  Filename:               V8.S                                               *
;  Date:                   19th August,2002                                   *
;                                                                             *
;  Tools used:             MPLAB IDE -> 6.43.00.0                             *
;                          Language tools -> 1.20.01                          *
;                                                                             *
;  Linker File:            p30f6014.gld                                       *
;                                                                             *
;  Revision History:                                                          *
; ----------------------------------------------------------------------------*
; Rev:     Date:                 Details:                           Who:      *
; ----------------------------------------------------------------------------*
; 0.1   19 August 2002         Code Created                         Rajiv     *
; 0.2   21 August 2002         Code Reviewed                        Raghava   *
;                                                                             *
;******************************************************************************
;  Notes:                                                                     *
;  ======                                                                     *
;  V8 State Machine implementation for Microchip's dsPIC30F 16-bit MCU        *
;                                                                             *
;  Description: This function implements the ITU-T Recommendation V.8 for     *
;               signals to be exchanged between DCEs over the PSTN when a     *
;               session of data transfer needs to be established.             *
;               This provides the following features:                         *
;               A means to determine automatically, prior to initiation of    *
;               modem hand shake, the best available operational mode         *
;               between the two DCEs connected via the PSTN Timely            *
;               indication to CMEs on the V-series modualtion to be employed  *
;               in any new session of data transmission. A means to enable a  *
;               PSTN call to be passed on automatically to an appropriate     *
;               DCE with minimal potential for adversely affecting existing   *
;               DCEs.                                                         *
;                                                                             *
;  Module Re-entrancy:                                                        *
;  Module re-entrancy is not supported                                        *
;                                                                             *
;******************************************************************************
;  SetDefV8Codes                                                              *
;  ======================                                                     *
;  Description: This function initializes the CM/JM Coding sequence for       *
;               V.32/V.22Bis/V.21 Modems                                      *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w2,w4,w5,w8             used not restored                             *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************

;******************************************************************************
;  V8Originate                                                                *
;  ======================                                                     *
;  Description: This function initialises the parameters for originate mode   *
;                of V8 hand shake.                                            *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2                   used not restored                             *
;                                                                             *
;  Functions Called:   ClearV8Vars, SetDefV8Codes                             *
;                                                                             *
;******************************************************************************

;******************************************************************************
;  V8OrgPhase3                                                                *
;  ======================                                                     *
;  Description: This function performs the different phases of V8             *
;                   originate mode of hand shake                              *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w8,w13            used not restored                             *
;                                                                             *
;  Functions Called:   StartV21                                               *
;                                                                             *
;******************************************************************************

;******************************************************************************
;  V8OrgPhase4                                                                *
;  ======================                                                     *
;  Description: This function performs the different phases of V8             *
;                   originate mode of hand shake                              *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w2                      used not restored                             *
;                                                                             *
;  Functions Called:   BufferV8Info, SetMinEnergyLevel                        *
;                                                                             *
;******************************************************************************

;******************************************************************************
;  V8OrgPhase401                                                              *
;  ======================                                                     *
;  Description: This function performs the different phases of V8             *
;                   originate mode of hand shake                              *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w2,w8                   used not restored                             *
;                                                                             *
;  Functions Called:   SetIdleTransmiter,SetIdleReceiver                      *
;                                                                             *
;******************************************************************************

;******************************************************************************
;  V8OrgPhase5                                                                *
;  ======================                                                     *
;  Description: This function performs the different phases of V8             *
;                   originate mode of hand shake                              *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2                   used not restored                             *
;                                                                             *
;  Functions Called:   SetIdleTransmiter,SetIdleReceiver                      *
;                                                                             *
;******************************************************************************

;******************************************************************************
;  StartOrgProc                                                               *
;  ======================                                                     *
;  Description: This function calls the terminating V8 hand shake function    *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1                      used not restored                             *
;                                                                             *
;  Functions Called:   EndV8                                                  *
;                                                                             *
;******************************************************************************

;******************************************************************************
;  EndV8                                                                      *
;  ======================                                                     *
;  Description: This function terminates the V8 handshake and start           *
;               the selected hand shake.                                      *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w2                      used not restored                             *
;                                                                             *
;  Functions Called:     SetIdleTransmiter,SetIdleReceiver, StartV32,         *
;                        StartV21, StartV23, StartV22                         *
;                                                                             *
;******************************************************************************

;******************************************************************************
;  V8Answer                                                                   *
;  ======================                                                     *
;  Description: This function performs the different phase of V8              *
;               answer mode of hand shake.                                    *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w3                used not restored                             *
;                                                                             *
;  Functions Called:   ClearStruct, V21RxModem                                *
;                                                                             *
;******************************************************************************

;******************************************************************************
;  V8AnsPhase2                                                                *
;  ======================                                                     *
;  Description: This function performs the different phase of V8              *
;               answer mode of hand shake.                                    *
;  ======================                                                     *
;  Input:                                                                     *
;       void                                                                  *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w2,w3,w8,w13            used not restored                             *
;                                                                             *
;  Functions Called:   V21TxModem,BufferV8Info, SetMinEnergyLevel,            *
;                      SetDefV8codes                                          *
;******************************************************************************

;******************************************************************************
;  V8AnsPhase3                                                                *
;  ======================                                                     *
;  Description: This function performs the different phase of V8              *
;               answer mode of hand shake.                                    *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2                   used not restored                             *
;                                                                             *
;  Functions Called:   SetIdleTransmiter,SetIdleReceiver                      *
;                                                                             *
;******************************************************************************

;******************************************************************************
;  StartAnsProc                                                               *
;  ======================                                                     *
;  Description: This function calls the terminating V8 hand shake function    *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1                      used not restored                             *
;                                                                             *
;  Functions Called:   EndV8                                                  *
;                                                                             *
;******************************************************************************
;
;******************************************************************************
;  V8InfoTransmiter                                                           *
;  ======================                                                     *
;  Description: This function is used to transmit V8 information bits         *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        Bit,ready for Transmission                                           *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1,w2,w4,w5,w8          used not restored                             *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;
;******************************************************************************
;  BufferV8Info                                                               *
;  ======================                                                     *
;  Description: This function is used to buffer the received V8 octets.       *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w2,w4                   used not restored                             *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;
;******************************************************************************
;  TestV8Info                                                                 *
;  ======================                                                     *
;  Description: This function is used to test the received V8 info octets.    *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w2,w3,w4,w5,w8,w9       used not restored                             *
;                                                                             *
;  Functions Called:   None                                                   *
;                                                                             *
;******************************************************************************
;  ClearV8Vars                                                                *
;  ======================                                                     *
;  Description: This function clears V8 related variables.                    *
;  ======================                                                     *
;  Input:                                                                     *
;        void                                                                 *
;                                                                             *
;  Output:                                                                    *
;        void                                                                 *
;                                                                             *
;  System Resource usage:                                                     *
;    w0,w1                      used not restored                             *
;                                                                             *
;  Functions Called:   ClearStruct                                            *
;                                                                             *
;******************************************************************************
;******************************************************************************
;                                                                             *
;  DO and REPEAT instruction usage (Instance and DO loop level)               *
;     1 level DO instruction                                                  *
;     1 level REPEAT instruction                                              *
;                                                                             *
;  Stack Usage in 16-bit Words :   0                                          *
;                                                                             *
;  Instructions in Module (PM Usage in Instruction Words):                    *
;     SetDefV8Codes:       52                                                 *
;     V8Originate:         13                                                 *
;     V8OrgPhase3:         27                                                 *
;     V8OrgPhase4:         10                                                 *
;     V8OrgPhase401:       30                                                 *
;     V8OrgPhase5:         16                                                 *
;     StartOrgProc:         8                                                 *
;     EndV8:               38                                                 *
;     V8Answer:            13                                                 *
;     V8AnsPhase2:         26                                                 *
;     V8AnsPhase3:         27                                                 *
;     StartAnsProc:         8                                                 *
;     V8InfoTransmiter:    50                                                 *
;     BufferV8Info:        34                                                 *
;     TestV8Info:          60                                                 *
;     ClearV8Vars:         13                                                 *
;                                                                             *
;  Module Constants stored in Program Memory (PM Usage in Instruction Words): *
;     None                                                                    *
;                                                                             *
;  Initialized Data Memory Usage 16-bit Words:                                *
;     None                                                                    *
;                                                                             *
;  Uninitialized Data Memory Usage for module 16-bit Words:                   *
;                                                                             *
;    .nbss:     SIZEOFV8_NBSS                                                 *
;    .ybss:     SIZEOFV8_YBSS+SIZEOFV8_YBSS_1                                 *
;                                                                             *
;  Module Instruction Cycle Count                                             *
;     SetDefV8Codes:       54                                                 *
;     V8Originate:         15                                                 *
;     V8OrgPhase3:         37                                                 *
;     V8OrgPhase4:         12                                                 *
;     V8OrgPhase401:       24                                                 *
;     V8OrgPhase5:         18                                                 *
;     StartOrgProc:        10                                                 *
;     EndV8:               19                                                 *
;     V8Answer:            15                                                 *
;     V8AnsPhase2:         36                                                 *
;     V8AnsPhase3:         28                                                 *
;     StartAnsProc:        10                                                 *
;     V8InfoTransmiter:    52                                                 *
;     BufferV8Info:        27                                                 *
;     TestV8Info:          (50+5*RxStrLen)                                    *
;     ClearV8Vars:         15                                                 *
;                                                                             *
;*****************************************************************************/
; -----------------------------------------------------------------------------
;    INCLUDE FILES
; -----------------------------------------------------------------------------

    .include "V8.inc"
    .include "modem.inc"
    .include "data.inc"
    .include "apiasm.inc"
    .include "defs.inc"

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.if DEF_V8 == 1
              
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _SetDefV8Codes
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: This function initializes the information octets for the
;              signals CM and JM according to the coding format specified
;              in ITU-T V.8.These signals consists of a repeated sequence
;              of bits. A sequence consists of 10 ones(Fill bits) followed
;              by 10 bits for synchronization and then information bearing
;              octets. Each octet being preceded by a start-bit(ZERO) and 
;              followed by a stop-bit(ONE).
;         
;              CM/JM Coding sequence for V.32/V.22Bis/V.21 Modems
;              Bit Order MSB to LSB while sending.
; -----------------------------------------------------------------------------
               
_SetDefV8Codes:

    mov        #mdmFilterBuffer, w0
    mov        #V8DefV8Octets, w2      ;w2 points to V8 info octets buffer
    add        w0, w2, w2    
    
    mov        #0xc1, w0
    mov.b      w0, [w2++]            ;Call Function 
    
    mov        #0x05, w0
    mov.b      w0, [w2++]            ;Modulation Modes, MODN_1
    
    mov        #0x10, w0
    mov.b      w0, [w2++]            ;Modulation Modes, MODN_2
    
    mov        #0x10, w0
    mov.b      w0, [w2++]            ;Modulation Modes, MODN_3
    
    mov        #0x07, w0
    mov.b      w0, [w2++]            ;V90 Availability
    
    mov        #0x2a, w0
    mov.b      w0, [w2++]            ;Calls for LAPM Protocol
    
    mov        #0x0d, w0
    mov.b      w0, [w2++]            ;PSTN Access
    
    clr        w4
    mov.b      ucHS_Mode, wreg
    mov.b      w0, w4
    
    mov        #ANSWER, w0
    and.b      modemMode, wreg         ;Check if modem is in Ans mode
    bra        z, ENABLE_VSTD

    mov        V8RemDetails, w5
    and        w4, w5, w4              ;Set the modes
    
ENABLE_VSTD:

    and       w4, #ENABLE_V32, w5
    bra       z, TOENABLE_V22
    
    mov       #mdmFilterBuffer, w2
    mov       #V8DefV8Octets, w8
    add       w8, w2, w8
    clr       w2
    mov.b     [w8+#MODN_2], w2
    ior       #V32DataModem, w2        ;Enable v32
    mov.b     w2, [w8+#MODN_2]
    
TOENABLE_V22:    

    and       w4, #ENABLE_V22, w5
    bra       z, TOENABLE_V21
    
    mov       #mdmFilterBuffer, w2
    mov       #V8DefV8Octets, w8
    add       w2, w8, w8
    clr       w2
    mov.b     [w8+#MODN_2], w2
    ior       #V22DataModem, w2        ;Enable V22
    mov.b     w2, [w8+#MODN_2]
    
TOENABLE_V21:

    and       w4, #ENABLE_V21, w5
    bra       z, TOENABLE_V23
    
    mov       #mdmFilterBuffer, w2
    mov       #V8DefV8Octets, w8
    add       w2, w8, w8
    
    clr       w2
    mov.b     [w8+#MODN_3], w2
    ior       #V21DataModem, w2
    mov.b     w2, [w8+#MODN_3]         ;Enable V21
            
TOENABLE_V23:
    mov       #ENABLE_V23, w2
    and       w4, w2, w5
    bra       z, EXIT_DEFCODE
    
    mov       #mdmFilterBuffer, w2
    mov       #V8DefV8Octets, w8
    add       w2, w8, w8
    
    clr       w2
    mov.b     [w8+#MODN_3], w2
    ior       #V23FullDuplex, w2       ;Enable V23
    mov.b     w2, [w8+#MODN_3]

EXIT_DEFCODE:

    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
 
    .global _V8Originate
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: This function is called when the modem is in originate mode.
;                  This function performs the following operations.
;              1.  It clears the all the parameters of V.8 data structure
;              2.  It initializes the CM/JM Coding sequence for V.32/
;                  V.22Bis/V.21 Modems by calling the function SetDefV8Codes.
;              3.  Initializes the ModemManager to V8OrgPhase3 for the next 
;                  phase of V8.
; -----------------------------------------------------------------------------
               

_V8Originate:

    rcall       ClearV8Vars
        
    mov        #handle(_V8OrgPhase3), w2
    clr        w1
    mov        w2, modemManager        ;Initializes ModemManager for Next phase
                                       ; of V.8
    mov        #8000, w0
        
    mov        w0,modemTimerA
    mov        w1,modemTimerA+2        ;Set up a timer of 1 sec
    
    call       _SetDefV8Codes          ;Initialize V8 octets  
    
.if DEF_DEBUG == 1
    
    mov        #V8_SILENCE_TX, w0
    call       _SendDebugInfo
.endif        
    
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V8OrgPhase3
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: This function performs the following functions.
;               1.  Waits for ModemTimer to elapse(Silence transmission) and 
;                   then,
;               2.  Initializes the parameters for V21 receiver for the 
;                   reception of V21 modulated JM sequence.
;               3.  Initializes the receive data format(Buffer the bits LSB to 
;                   MSB by eliminating the START/STOP bits
;               4   Initializes the parameters for V21 transmitter for the 
;                   transmission of CM sequence, modulating V21
;               5.  Initializes the transmit data format for the transmission 
;                   of bits starting from MSB to LSB.
;               6.  Initializes the following parameters for the transmission 
;                   of CM sequence.
;                   a.  V8TxBitCounterSet is set to V8CMSTRINGLEN
;                   b.  V8TxBitCounter is reset to 0
;                   c.  V8State is set to V8SENDINGCM
;                   d.  Information octets buffer pointer is initialized to
;                       V8 codes buffer.            
;                   e.  V8 codes buffer is filled with V8 octets 
; -----------------------------------------------------------------------------

_V8OrgPhase3:

    mov        modemTimerA, w0
    mov        modemTimerA+2, w1

    sub        w0, #0, w0
    subb       w1, #0, w1

    bra        nz, EXIT_ORGPHASE3      ;Chk if Timer has been elapsed   
    
    mov        #handle(_V8OrgPhase4), w2
    mov        w2, modemManager
    
    call       _StartV21               ;Initializes parameters for reception of
                                       ;V21 modulated JM sequence
    mov        #(~V21MODE), w0
  
    and.b      modemMode
    
    mov        #handle(_PutLsb2MsbSS), w2
    mov        #handle(_V8InfoTransmiter), w1
    mov        w2, dataRxBitFn         ;Init transmit data format from MSB-LSB
    mov        w1, dataTxBitFn         ;Init V21 transmitter parameters
    
    mov        #V8CMSTRINGLEN, w0
    mov.b      wreg, V8TxByteCounterSet;Set Counter for Length of CM sequence
    
    clr.b       V8TxByteCounter
    
    mov        #mdmFilterBuffer, w1
    mov        #V8DefV8Octets, w8
    add        w1, w8, w8
    mov        #V8Codes, w13
    add        w1, w13, w13
    
    repeat     #7
    
    mov.b      [w8++], [w13++]         ;Copy the CM octets to V8 Codes buffer
    
    clr.b      mdmRxSmpCntr     
    clr.b      mdmTxSmpCntr            ;Reset transmit and Receive counters
    
    mov        #(0x10|RATE_7200), w0
    mov.b      wreg, mdmRCTxRatio    

.if DEF_DEBUG == 1
    mov        #V8_SEND_CM, w0
    call       _SendDebugInfo
.endif        

EXIT_ORGPHASE3:
    return
    
   
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V8OrgPhase4
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: In this function BufferV8Info function is called for the 
;              buffering of the received V8 octets(JM sequence). It waits
;              till the JM sequence is received,it then initializes the 
;              ModemManager for the next phase of V8. 
; -----------------------------------------------------------------------------

_V8OrgPhase4:

    call        _BufferV8Info          ;Buffer the Received bits(JM sequence)
    
    mov         #V8RXSTRINGFLAG, w0
    and.b       V8State, wreg
    bra         z, EXIT_V8ORGPHASE4    ;If JM sequence is not received, return
    
    mov         #handle(_V8OrgPhase401), w2
    mov         w2, modemManager       ;Initialize for next phase of V8
.if DEF_DEBUG == 1
    mov        #V8_DETECT_JM, w0
    call       _SendDebugInfo
.endif        

    call        _SetMinEnergyLevel     ;Set min energy level of received signal

EXIT_V8ORGPHASE4:    

    return

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _V8OrgPhase401
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: After the detection of JM sequence, transmission of CM 
;              sequence is terminated by sending remaining bits of the 
;              last sequence. If no compatible mode is present in the 
;              remote modem, the connection will be terminated by setting
;              the modem hangup. If there is a compatible mode is present 
;              in the remote modem, it acknowledges the JM reception by 
;              sending the CJ sequence. The CJ transmission is initialized 
;              by initializing the following parameters.
;               a.  V8 codes buffer is filled with CJ octets.
;               b.  V8TxBitCounterSet is set to V8CJSTRINGLEN
;               c.  V8TxBitCounter is reset to 0
;               d.  Information octets buffer pointer is initialized to
;                   V8 codes buffer.            
;               f.  V8TXSTRINGEND bit in V8State is cleared.
; -----------------------------------------------------------------------------

_V8OrgPhase401:

    mov         #V8TXSTRINGEND, w0
    and.b       V8State, wreg
    bra         z, EXIT_V8ORGPHASE401  ;Is JM Detected
    
    cp0.b       dataTxBitCnt
    bra         nz, EXIT_V8ORGPHASE401
    
    clr         w0
    mov         #(~V8TXSTRINGEND), w0
         
    and.b       V8State                ;After Receiving JM, finish the 
                                       ;transmission if remaining bits of 
                                       ;CM sequence.
    mov         #(ENABLE_V32 | ENABLE_V22 | ENABLE_V21 | ENABLE_V23), w0
    and         V8RemDetails, wreg
    bra         nz, FOUND_MODE         ;Hang up the modem if remote 
    mov         #1, w0                 ;modem does not have any compatible mode
    mov.b       wreg, mdmHangUp
    
    call        _SetIdleTransmitter     ;Set Transmitter to IDLE
    call        _SetIdleReceiver       ;Set receiver to IDLE
    
    mov         #handle(_NullFunction), w0
    mov         w0, modemManager
    return
    
FOUND_MODE:
.if DEF_DEBUG == 1
    mov        #V8_CJ_TX, w0
    call       _SendDebugInfo
.endif        
    mov         #mdmFilterBuffer, w0
    mov         #V8Codes, w8
    add         w0, w8, w8
    
    clr.b       [w8++]
    clr.b       [w8++]
    clr.b       [w8]                   ;Initialize the V8Codes buffer for 
                                       ;CJ transmission
    clr.b       V8TxByteCounter        ;Reset Transmit byte counter
    
    mov         #V8CJSTRINGLEN, w0
    mov.b       wreg, V8TxByteCounterSet;Initialize the CJ string length
    
    mov         #handle(_V8OrgPhase5), w2
    mov         w2, modemManager       ;Set modemManager to next phase of V8
    
EXIT_V8ORGPHASE401:
    
    return        


; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V8OrgPhase5
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: This function waits till the transmission of CJ sequence is
;              completed, it then calls the function V.8 state machine is
;              is switched to next state of hand shake for terminating
;              the V8 hand shake
; -----------------------------------------------------------------------------

_V8OrgPhase5:

    mov         #V8TXSTRINGEND, w0
    and.b       V8State, wreg
    bra         z, EXIT_V8ORGPHASE5
    
    cp0.b       dataTxBitCnt
    bra         nz, EXIT_V8ORGPHASE5   ;Wait for the complete transmission of
                                       ;CJ sequence and terminate V8 hand shake
    
    call        _SetIdleTransmitter
    call        _SetIdleReceiver
    
    mov         #540, w0               ; 75ms silence
    clr         w1
    
    mov        w0,modemTimerA
    mov        #handle(_StartOrgProc), w2
    mov        w1,modemTimerA+2        ;Set the Timer
    mov        w2, modemManager        ;Init for next phase of V.8

EXIT_V8ORGPHASE5:

    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _StartOrgProc
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: This function calls the v8 termination function after 75 ms of
;              silence
; -----------------------------------------------------------------------------

_StartOrgProc:

    mov        modemTimerA, w0
    mov        modemTimerA+2, w1

    sub        w0, #0, w0
    subb       w1, #0, w1

    bra        nz, EXIT_STARTORG       ;Check if timer elapsed and then 
                                       ;terminate V.8 Hand shake

    call       _EndV8
    
EXIT_STARTORG:
    
    return            
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _EndV8
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: This function performs the following functions.
;              1.  ModemTransmiter, ModemReceiver and ModemManager are 
;                  initialized to IdleTransmiter,IdleReceiver and NullFunction 
;                  respectively. 
;              2.  It starts the hand shake of the best available optional mode
;                  between two DCEs.
; -----------------------------------------------------------------------------

_EndV8: 

    mov        #(~V21MODE), w0
    and.b      modemMode               ;Terminate V21 Mode

; Set ModemTransmiter,ModemReceiver and ModemManager to IdleTransmiter,
; IdleReceiver ans NullFunction respectively

    call       _SetIdleReceiver
    call       _SetIdleTransmitter
    
    clr        w0
    mov         #handle(_NullFunction), w2
    mov        w2, modemManager

;If auto V8 is disabled start the mode supported by both the modems    
 
    mov.b      ucHS_Mode, wreg
    and        V8RemDetails, wreg

;Start V32 hand shake if remote modem supports V32    

.if DEF_V32 == 1

    mov        #ENABLE_V32, w2
    and        w0, w2, w2
    bra        z, NO_V32MODE

    call       _StartV32    
    return

NO_V32MODE:
.endif

;Start V22 hand shake if remote modem supports V22

.if DEF_V22 == 1

    mov        #ENABLE_V22, w2
    and        w0, w2, w2
    bra        z, NO_V22MODE

    call       _StartV22    
    return

NO_V22MODE:
.endif

;Start V23 hand shake if remote modem supports V22

.if DEF_V23 == 1

    mov        #ENABLE_V23, w2
    and        w0, w2, w2
    bra        z, NO_V23MODE

.if DEF_DEBUG == 1
    mov        #ORIGINATE, w0
    and.b      modemMode, wreg         ;Check modem is in Originate mode
    bra        z, V23_ANS_MSG

    mov        #V23_ORG_START, w0
    call       _SendDebugInfo
    bra        EXIT_V23_START_MSG

V23_ANS_MSG:

    mov        #V23_ANS_START, w0
    call       _SendDebugInfo
EXIT_V23_START_MSG:
.endif

    call       _StartV23    
    return

NO_V23MODE:
.endif

;Start V21 hand shake if remote modem supports V22

.if DEF_V21 == 1

    mov        #ENABLE_V21, w2
    and        w0, w2, w2
    bra        z, NO_V21MODE
.if DEF_DEBUG == 1
    mov        #ORIGINATE, w0
    and.b      modemMode, wreg         ;Check modem is in Originate mode
    bra        z, V21_ANS_MSG

    mov        #V21_ORG_START, w0
    call       _SendDebugInfo
    bra        EXIT_V21_START_MSG

V21_ANS_MSG:

    mov        #V21_ANS_START, w0
    call       _SendDebugInfo
EXIT_V21_START_MSG:
.endif
    call       _StartV21    
    return

NO_V21MODE:
.endif

;Hang up the modem if there is no common supported mode

    mov        #1, w0
    mov.b      wreg, mdmHangUp
    
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V8Answer
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: This function is called when the modem is in answer mode.
;                  This function performs the following operations.
;              1.  Clears the all the parameters of V.8 data structure
;              4.  Initializes the parameters for V21 receiver for the 
;                  reception of V21 modulated CM sequence.
;              5.  Initializes the receive data format (Buffer the bits LSB to
;                  MSB by eliminating the START/STOP bits)
; -----------------------------------------------------------------------------

_V8Answer:

    rcall       ClearV8Vars
   
    call       _V21RxModem             ;Initialize V21 reception for the 
                                       ;reception of V21 modulated CM signal
    
    mov        #handle(_PutLsb2MsbSS), w2
    mov        #handle(_V8AnsPhase2), w3
    mov        w2, dataRxBitFn         ;Receive the information octets and 
                                       ;buffer them from LSB to MSB
                                       ;by removing start/stop bits
    mov        w3, modemManager        ;Init Modem Manager for next phase of V8
    
    mov        #(~V21MODE), w0
    and.b      modemMode
    
    return
    

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _V8AnsPhase2
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: In this function BufferV8Info function is called for the
;              buffering of the received V8 octets(CM sequence). It waits
;              for the reception of CM sequence. After receiving the CM 
;              sequence it initializes the transmission of JM sequence by
;              initializing the following parameters
;              a.  V8TxBitCounterSet is set to V8JMSTRINGLEN
;              b.  V8TxBitCounter is reset to 0
;              c.  Information octets buffer pointer is initialized to
;                  V8 codes buffer.            
;              d.  V8Octets(JM sequence) are prepared with reference to 
;                  received CM sequence
; -----------------------------------------------------------------------------
   
_V8AnsPhase2:

    call       _BufferV8Info           ;Buffer the CM sequence received
    
    mov        #V8RXSTRINGFLAG, w0
    and.b      V8State, wreg
    bra        z, EXIT_ANSPHASE2       ;Waits for reception of CM sequence

.if DEF_DEBUG == 1
    mov        #V8_CM_DETECT, w0
    call       _SendDebugInfo
.endif       

    call       _SetMinEnergyLevel
    
    mov        #V8JMSTRINGLEN, w0
    mov.b      wreg, V8TxByteCounterSet;Init for JM string length
    
    clr.b      V8TxByteCounter         ;Reset the Tx byte counter
    
    call       _V21TxModem             ;Initialize V21 transmission for the 
                                       ;transmission of V21 modulated JM signal
    
    mov        #(~V21MODE), w0
    and.b      modemMode
    
    mov        #handle(_V8InfoTransmiter), w2
    mov        #handle(_V8AnsPhase3), w3
    mov        w2, dataTxBitFn         ;Init V21 transmitter parameters
    mov        w3, modemManager
    
    clr.b      V8RxStrLen
    
    call       _SetDefV8Codes          ;Init V.8 Octets
    
    mov        #mdmFilterBuffer, w0
    mov        #V8DefV8Octets, w8
    add        w0, w8, w8
    mov        #V8Codes, w13
    add        w0, w13, w13
    
    repeat     #7
    
    mov.b      [w8++], [w13++]         ;Copy the JM octets to V8 Codes buffer 

.if DEF_DEBUG == 1
    mov        #V8_SEND_JM, w0
    call       _SendDebugInfo
.endif           

EXIT_ANSPHASE2:    

    return     
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

    .global _V8AnsPhase3
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: It waits for the CJ sequence for terminating the 
;              transmission of JM sequence. The alternate method of 
;              terminating JM transmission is the detection of remote 
;              signal energy loss, i.e if low energy is detected for 5 
;              Continuous 32 sample intervals,(AgcEnergyStat=0), JM
;              transmission is terminated. ModemTimer is initialized to 
;              wait for 75ms before starting the hand shake in the 
;              specified mode.
; -----------------------------------------------------------------------------

_V8AnsPhase3:       

    cp0.b      AGCHiEngCntr
    bra        z, SEND_SILENCE         
;If no signal is there on the line (i.e EnergyStat=0) after detecting
;CM sequence, this condition is taken as CJ received    
    
    mov        #RXDBYTE, w0
    and.b      modemStatus, wreg
    bra        z, EXIT_ANSPHASE3
;If received byte is not available return from the function
 
    mov        #(~RXDBYTE), w0
    and.b      modemStatus
    
    cp0.b      dataDataByte
    bra        z, CHK_STRLEN
    
    clr.b      V8RxStrLen
    return
CHK_STRLEN:    
    mov        #3, w0
    inc.b      V8RxStrLen
    cp.b       V8RxStrLen
;If 3 bytes received are zeros ,then initialize pointers for the
;next phase. 
    bra        z, SEND_SILENCE
    return

SEND_SILENCE:
.if DEF_DEBUG == 1
    mov        #V8_DETECT_CJ, w0
    call       _SendDebugInfo
.endif     

;Set the ModemTransmiter, ModemReceiver and ModemManager to
;IdleTransmiter,IdleReceiver ans StartAnsProc for starting
;the modem hand shake.    
    call       _SetIdleTransmitter
    call       _SetIdleReceiver
    
    mov        #540, w0
    mov        #handle(_StartAnsProc), w2
    clr        w1
    
    mov        w0, modemTimerA
    mov        w1, modemTimerA+2       ;Setup timer of 75ms for silence period
    mov        w2, modemManager
    
EXIT_ANSPHASE3:

   return       
   
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
   
    .global _StartAnsProc
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: This function waits for 75ms(ModemTimerA),and then 
;              terminates the V8 hand shake by calling the function EndV8.
; -----------------------------------------------------------------------------

_StartAnsProc:

    mov        modemTimerA, w0
    mov        modemTimerA+2, w1

    sub        w0, #0, w0
    subb       w1, #0, w1

    bra        nz, EXIT_STARTANS       ;Check if Timer has elapsed

    call       _EndV8                  ;Terminate V.8
    
EXIT_STARTANS:
    
    return            
   
   
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
   
    .global _V8InfoTransmiter
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: This function performs the following functions,
;              1.  Transmits fill bits and synchrinization bits 
;              1.  Get the transmit data word from the V8Codes buffer
;              2.  Transmit data length is set to 16,and V8TxBitCounter is
;                  updated.
;              3.  When One complete sequence of CM/JM has sent, the V8State is
;                  updated to V8TXSTRINGEND1.
;              4.  Binary 1 is transmited at the end of the one complete 
; -----------------------------------------------------------------------------

_V8InfoTransmiter:

    cp0.b      dataTxBitCnt
    bra        nz, EXTRACT_BIT
    
    mov        #V810ONES, w0           ;Check for ten ones
    and.b      V8State, wreg
    bra        nz, CHK_SYNCFLAG
;Transmit the sequence if the transmission of the sequence is not
;completed.

    mov        #V810ONES, w0
    ior.b      V8State
      
    mov        #(~(V8TXSTRINGEND+V8TXSYNCFLAG)), w0
    and.b      V8State
    
    mov        #0x3ff, w1
    mov        #10, w0
    mov        w1, dataTxDataWord
    mov.b      wreg, dataTxBitCnt  
    bra        EXTRACT_BIT

CHK_SYNCFLAG:
    mov        #V8TXSYNCFLAG, w0
    and.b      V8State, wreg           ;check for synchronization
    bra        nz, UPD_DATAWORD
    
    mov        #V8TXSYNCFLAG, w0
    ior.b      V8State    
    mov        #0x03c0, w1
    mov        #10, w0
    mov        w1, dataTxDataWord      ;Update Tx word
    mov.b      wreg, dataTxBitCnt  
    bra        EXTRACT_BIT
    
UPD_DATAWORD:
    mov        #mdmFilterBuffer, w0
    mov        #V8Codes, w8
    add        w8, w0, w8
    clr        w0
    clr        w4
    mov.b      V8TxByteCounter, wreg
    inc.b      V8TxByteCounter
    mov.b      [w8+w0], w4             ;Get the transmit data word from the V8 
                                       ;information octets buffer
    sl         w4, #1, w4
    mov        #0x200, w5
    ior        w4, w5, w5
    mov        w5, dataTxDataWord      ;store it in the transmit data word
    
    mov        #10, w0
    mov.b      wreg, dataTxBitCnt      ;Update the Tx bit counter
    
    mov.b      V8TxByteCounterSet, wreg
    cp.b       V8TxByteCounter
    bra        nz, EXTRACT_BIT
    
    mov        #V8TXSTRINGEND, w0
    ior.b      V8State                 ;If complete sequence is transmitted 
                                       ;set TXSTRINGEND bit in the V8 state
    mov        #(~V810ONES), w0
    and.b      V8State
    clr.b      V8TxByteCounter         ;Reset the Tx Byte counter
     
EXTRACT_BIT:
 
    mov      dataTxDataWord, w2
    and      w2, #1, w0
    
    lsr       w2, #1, w2
    mov       w2, dataTxDataWord
    dec.b     dataTxBitCnt
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _BufferV8Info   
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: This function is called to buffer the received v8 octets.
;                  This function performs the following functions
;              1.  Checks for the RXDBYTE flag and it aborts the 
;                  buffering process if the RXDBYTE flag is zero.
;              2.  Checks for the sync bits(0xE0),and initializes the receive
;                  V8 octets buffer pointer after the reception of sync bits.
;              3.  It starts updating the buffer with the received data.
; -----------------------------------------------------------------------------

_BufferV8Info:
    
    mov        #RXDBYTE, w0
    and.b      modemStatus, wreg
    bra        z, EXIT_BUFFERINFO
    
    mov        #(~RXDBYTE), w0
    and.b      modemStatus             ;Reset the RxBit bit in ModemStatus
    
    mov        #V8RXSYNCFLAG, w0
    and.b      V8State, wreg           ;If no Rxsync flag, no data received
    bra        nz, TESTV8
    mov        #0x00E0, w0
    cp.b       dataDataByte
    bra        nz, EXIT_BUFFERINFO
    
    mov        #V8RXSYNCFLAG, w0
    ior.b      V8State                 ;Check for the initial sync bits before
                                       ;buffering the actual V8 octets
    mov        #mdmFilterBuffer, w2
    mov        #V8RxBitStream1, w0
    add        w2, w0, w0
    mov        w0, V8RxStrPtr
    return
    
TESTV8:

    mov        #0x00E0, w0
    cp.b       dataDataByte
    bra        nz, LIMITTO15BYTES  
;Test for sync bits(0xE0) for the consecutive sequences        
    call       _TestV8Info
    bra        EXIT_BUFFERINFO
    
LIMITTO15BYTES:

    mov        V8RxStrPtr, w2
    mov.b      dataDataByte, wreg
    clr        w4
    mov.b      w0, w4
    mov.b      V8RxStrLen, wreg
    mov.b      w4, [w2+w0]             ;Update the receive V8 octets buffer
                                       ;with the received byte
    
;Update the receive buffer index for storing the next byte and reset
;the index if it reaches the end of the buffer

    clr        w0
    mov.b      V8RxStrLen, wreg
    add        #1, w0
    and        #15, w0
    mov.b      wreg, V8RxStrLen

EXIT_BUFFERINFO:
    
    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
    
    .global _TestV8Info   
    .section  .libsm, "x"

; -----------------------------------------------------------------------------
; DESCRIPTION: This function performs the following functions
;              1.  initializes the receive V8 octets buffer pointer for the
;                  reception of 2 complete CM/JM sequences.
;              2.  After the reception of 2 complete sequences, V8RXSTRINGFLAG
;                  is set if two sequences are equal.
;              3.  Analysis of Remote modem capabilities is done
; -----------------------------------------------------------------------------

_TestV8Info:
    
    mov        #mdmFilterBuffer, w3
    mov        #V8RxBitStream1, w0
    add        w0, w3, w0
    cp         V8RxStrPtr
    bra        nz, SETPOINTER
    
    mov        #V8RxBitStream2, w0     ;Initialize the IInd receive V8 octets 
    add        w3, w0, w0
    mov        w0, V8RxStrPtr          ;buffer pointer(V8RxBitStream2)
    bra        CHK_RXSTRLEN

SETPOINTER:
    
    mov        w0, V8RxStrPtr          ;Initialize the Ist receive V8 octets 

CHK_RXSTRLEN:    
    cp0.b      V8RxStrLen              ;buffer pointer(V8RxBitStream1)
    bra        z, EXIT_TESTV8INFO
    
    clr        w0
    mov.b      V8RxStrLen, wreg
    
    mov        #0, w3                  ;Length of string received
    
    mov        #mdmFilterBuffer, w4
    mov        #V8RxBitStream1, w8
    add        w4, w8, w8
    mov        #V8RxBitStream2, w9
    add        w4, w9, w9
    
V8_STR_CMP:
       
    mov.b      [w8++], w4              ;Fetch data from Ist received octets
    mov.b      [w9++], w5              ;Fetch data from IInd received octets
    
    cp.b       w4, w5                  ;check both are equal
    bra        nz, OUT_LP              ;If not equal skip

END_LP:
    inc        w3, w3                  ;Increment length of string
  
    dec        w0,w0
    cp0        w0
    bra        nz,V8_STR_CMP

OUT_LP:

    clr        V8RemDetails
    mov        w3, w0
    cp.b       V8RxStrLen              ;Check exact length of string received
    bra        nz, EXIT_TESTV8INFO
    
    mov        #V8RXSTRINGFLAG, w0
    ior.b      V8State
    
    mov        #mdmFilterBuffer, w2
    mov        #V8RxBitStream1, w8
    add        w8, w2, w8
    mov.b      [w8+2], w2
;If two sequences are equal, the details are extracted from the received 
;CM/JM sequence and stored in RemDetails
    
    clr        w4
    mov        #V32DataModem, w4
    and.b      w2, w4, w4
    bra        z, TO_V22MODEM
    mov        #ENABLE_V32, w0         ;Enable V32
    ior        V8RemDetails
;    bra        EXIT_TESTV8INFO

TO_V22MODEM:
    
    clr        w4
    mov        #V22DataModem, w4
    and.b      w2, w4, w4
    bra        z, TO_V21MODEM
    mov        #ENABLE_V22, w0         ;Enable V22
    ior        V8RemDetails
;    bra        EXIT_TESTV8INFO  
    
TO_V21MODEM:

    mov.b      [w8+3], w2
    clr        w4
    mov        #V21DataModem, w4
    and.b      w2, w4, w4
    bra        z, TO_V23MODEM
    mov        #ENABLE_V21, w0         ;Enable V21
    ior        V8RemDetails
;    bra        EXIT_TESTV8INFO      
    
TO_V23MODEM:

    clr        w4
    mov        #V23FullDuplex, w4
    and.b      w2, w4, w4
    bra        z, EXIT_TESTV8INFO
    mov        #ENABLE_V23, w0         ;Enable V23
    ior        V8RemDetails   
    
EXIT_TESTV8INFO:

    clr.b      V8RxStrLen
    return    
        
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
 
    .global ClearV8Vars
    .section  .libsm, "x"
    
ClearV8Vars:

    mov        #V8State, w0
    mov        #SIZEOFV8_BSS_1, w1      ;Length of V.8 data structure
    call       _ClearStructByte         ;Clears all the Parameters of V.8

    mov        #V8RemDetails, w0
    mov        #SIZEOFV8_BSS_2, w1      ;Length of V.8 data structure
    call       _ClearStruct            ;Clears all the Parameters of V.8
            
    mov       #mdmFilterBuffer, w1
    mov       #V8DefV8Octets, w0
    add       w1, w0, w0
    
    mov        #SIZEOFV8_YBSS_1, w1      ;Length of V.8 data structure
    call       _ClearStruct            ;Clears all the Parameters of V.8

    mov        #mdmFilterBuffer, w1
    mov        #V8RxBitStream1, w0
    add        w0, w1, w0
    mov        #SIZEOFV8_YBSS, w1      ;Length of V.8 data structure
    
    call       _ClearStruct            ;Clears all the Parameters of V.8

    return
    
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

.endif

; -----------------------------------------------------------------------------
;    END OF FILE
; -----------------------------------------------------------------------------

                  
