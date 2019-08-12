;******************************************************************************
; File Name:   CALLPROG.H
;******************************************************************************

;------------------------------------------------------------------------------
; Call Progress Module constant defines
;------------------------------------------------------------------------------

    .equ BUSY_TOLERENCE,        800     ;100ms tolerance in busy tone cadence
    .equ REORDER_TOLERENCE,     400     ;50ms tolerance in reorder tone cadence
    .equ RING_TOLERENCE,        1600    ;200ms tolerance in ring tone cadence

    .equ DIALTONE_DETECTED,        1
    .equ BUSYTONE_DETECTED,        2
    .equ REORDERTONE_DETECTED,     4
    .equ RINGBACKTONE_DETECTED,    8

    .equ    CLPRGDETECTBUSYTONE,        1
    .equ    CLPRGDETECTREORDERTONE,     2
    .equ    CLPRGDETECTRINGBACKTONE,    4
    .equ    CLPRGTXV25CNG,              2

;------------------------------------------------------------------------------
; CP Module DM variables length defineations
;------------------------------------------------------------------------------

    .equ  SIZEOFCP_NBSS, 48
    .equ  SIZEOFCP_YBSS, 12

;------------------------------------------------------------------------------
; CP Module: Global definations of variables
;------------------------------------------------------------------------------

    .global cpDTAPRunAvg        
    .global cpDTAPAvg           
    .global cpDTAPCntr            
    .global cpDTAPLevel           
    .global cpDTAPIp        
    
    .global cpDTToneStatus             ;Tone present/absence status
    .global cpDTThreshold              ;Threshold level for tone detection
    
    .global cpBTAPRunAvg        
    .global cpBTAPAvg           
    .global cpBTAPCntr            
    .global cpBTAPLevel           
    .global cpBTAPIp

    .global cpBTToneStatus             ;Tone present/absence status
    .global cpBTThreshold              ;Threshold level for tone detection
    
    .global cpRBTAPRunAvg        
    .global cpRBTAPAvg           
    .global cpRBTAPCntr            
    .global cpRBTAPLevel           
    .global cpRBTAPIp      

    .global cpRBTToneStatus            ;Tone present/absence status
    .global cpRBTThreshold             ;Threshold level for tone detection

    .global cpDTOnTimer
    .global cpDTOffTimer

    .global cpBTOnTimer
    .global cpBTOffTimer

    .global cpRBTOnTimer
    .global cpRBTOffTimer
    
    .global cpBTTransitions
    .global cpRTTransitions
    .global cpRBTTransitions

    .global cpBTStatusFilter
    .global cpRBTStatusFilter
    
    .global cpPrevBTStatus
    .global cpPrevRBTStatus

    .global cpCurBTStatus
    .global cpCurRBTStatus

    .global cpBusyOnTime
    .global cpBusyOffTime
    .global cpBusyCadence

    .global cpReorderOnTime
    .global cpReorderOffTime
    .global cpReorderCadence

    .global cpRingOnTime
    .global cpRingOffTime
    .global cpRingCadence
    .global cpCPStatus
    
    .global cpDTDelayLine              ;Tone filter delay line
    .global cpBTDelayLine
    .global cpRBTDelayLine

      
;******************************************************************************
; END OF FILE
;******************************************************************************
