
;******************************************************************************
;File Name:   DETCONST.INC
;******************************************************************************

    .equ LEFT_JUSTIFIED,         1     ; 16 bit input, right shift
    .equ RIGHT_JUSTIFIED,        0     ; 14 bit input, no right shift

    .equ NUM,                    100   ; mem buffer length
    .equ FLEN,                   80    ; length of the input buffer

    .equ BUFFER_DELAY,           5     ; during subframe count = 0
    .equ VALID_DIGIT_FRAME,      0     ; valid DTMF digit just detected
    .equ POSSIBLE_DIGIT_FRAME,   1     ; a valid digit may be present 
    .equ DIGIT_DETECTED,         2
    .equ PAUSE_AFTER_DIGIT_FRAME,4     ; silence period after the digit
    .equ NOT_A_DIGIT_FRAME,      6     ; frame not a part of DTMF digit
    .equ ERROR_FRAME,           -1     ; error in frame
    .equ TONE_SHAPE_TEST,        3     ; a tone has been detected
                                       ; shape test in progress

    .equ NO,                     0     ; false flag
    .equ YES,                    1     ; true flag

    .equ THR_STDTWI,        11626   ; threshold for standard twist (-5dB) 
    .equ THR_REVTWI,         4628   ; threshold for reverse twist (-8.6dB) 
    .equ THR_ROWREL,         1000   ; threshold for row's relative peak (-12dB)
    .equ THR_ROW2nd,          200   ; threshold for row's 2nd har ratio (-12dB)
    .equ THR_COLREL,         1000   ; threshold colomn's reative peak (-12dB)
    .equ THR_COL2nd,          200   ; threshold for col's 2nd harmonic (-12db)



    .global DTMFEnergyThreshold        ;Silence Threshold
    .global DTMFSilenceThreshold       ;Energy Threshold
    .global DTMFworkBuff               ;DTMF working Buffer
    .global DTMFframeType              ;frame type
    .global DTMFshapeTest              ;Enable/Disable Shape Test
    .global DTMFcurrentDigit           ;Current Digit detected
    .global DTMFdeclaredDigit          ;Digit stored in previous frame
    .global DTMFsubframeCount          ;counter for subframes
    .global DTMFsilenceCount           ;counter for silence
    .global DTMFinputType              ;input pattern type
    .global DTMFframe                  ;frame

;******************************************************************************
;    END OF FILE
;******************************************************************************

