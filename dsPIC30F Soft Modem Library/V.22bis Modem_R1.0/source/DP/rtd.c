
/*************************************************************************/
/* 
**  Filename:    rtd.C
**
**  Description:
**      This file is the part of the data pump file. application calls this
**      function to check the presence of the ring signal. 
*/
/***************************************************************************/

/*-------------------------------------------------------------------------
 INCLUDE FILES
--------------------------------------------------------------------------*/

#include "api_c.h"

/*-------------------------------------------------------------------------
--------------------------------------------------------------------------*/

UCHAR RingStart = 0;
UINT RingCount = 0;

/*-------------------------------------------------------------------------
--------------------------------------------------------------------------*/
__attribute__ ((__section__ (".libsm"), __space__(__prog__)))

UCHAR CheckRingTone(PCMDATASTRUCT *Pcm)
{
    INT Sample,i;
    UINT DPMsgParams[1];
    
    for(i=0;i<Pcm->FrameLength;i++)
    {
        Sample = Pcm->IN[i];

        if(!RingStart)
        {
            if(Sample == 0x7fff)
            {
                if(RingCount++ == 50)
                {
                    RingCount = 0;
                    RingStart = 1;    
                }
            }
            else RingCount = 0;
        }
        else if(RingStart == 1)
        {
            if(Sample == 0x8000)
            {
                if(RingCount++ == 4000)
                {
                    RingStart = 0;
                    RingCount = 0;
                    return (1);
                }
            }
            else RingCount = 0;
        }
    }
    return (0);
}

/*--------------------------------------------------------------------
             END OF FILE
---------------------------------------------------------------------*/
