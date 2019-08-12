
/*******************************************************************************
 File Name:   DETCONST.H
******************************************************************************/

#include "datatype.h"

#define LEFT_JUSTIFIED         1     // 16 bit input, right shift
#define RIGHT_JUSTIFIED        0     // 14 bit input, no right shift

#define NUM                    100   // mem buffer length
#define FLEN                   80    // length of the input buffer

#define BUFFER_DELAY           5     // during subframe count = 0
#define VALID_DIGIT_FRAME      0     // valid DTMF digit just detected
#define POSSIBLE_DIGIT_FRAME   1     // a valid digit may be present 
#define DIGIT_DETECTED         2
#define PAUSE_AFTER_DIGIT_FRAME 4    //  silence period after the digit
#define NOT_A_DIGIT_FRAME      6     // frame not a part of DTMF digit
#define ERROR_FRAME           -1     // error in frame
#define TONE_SHAPE_TEST        3     // a tone has been detected
                                         // shape test in progress
#define NO                     0     // false flag
#define YES                    1     // true flag

#define CODECBUFLEN            240

typedef struct {
    INT FrameLength;          //PCM frame Length specified
    INT *IN;                  //PCM samples bffer for receiver
    INT *OUT;                 //Buffer for filling modulated samples
} PCMDATASTRUCT;


INT DTMF_Detection(INT,INT*,INT*); 
 
/******************************************************************************
    END OF FILE
******************************************************************************/
