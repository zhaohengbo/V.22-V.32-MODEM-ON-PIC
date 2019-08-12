
#include <p30fxxxx.h>
#include "delay.h"



void Delay200uS(void)  		/* provides delay for atleast 200uS */
{
    unsigned int i;
    for( i=0; i<Delay200uS_count; i++ );
}

void Delay5mS(void)  		/* provides delay for atleast 5msec*/
{
    unsigned int i;
    for( i=0; i<Delay5mS_count; i++ );
}

void Delay15mS(void)  		/* provides delay for atleast 15msec */
{
    unsigned long i;
    for( i=0; i<Delay15mS_count; i++ );
}


void Delay100mS(void)  		/* provides delay for atleast 100msec */
{
    unsigned long i;
    for( i=0; i<Delay100mS_count; i++ );
}

void Delay_1S( void )          
{
 	unsigned int counthi, countlo;
    for ( counthi=0; counthi<Delay_1S_count; counthi++ )
       for ( countlo=0; countlo<65535; countlo++ );
 
}

/*********************************************************************
*                                                                    *
*                       Software License Agreement                   *
*                                                                    *
*   The software supplied herewith by Microchip Technology           *
*   Incorporated (the "Company") for its dsPIC controller            *
*   is intended and supplied to you, the Company's customer,         *
*   for use solely and exclusively on Microchip dsPIC                *
*   products. The software is owned by the Company and/or its        *
*   supplier, and is protected under applicable copyright laws. All  *
*   rights are reserved. Any use in violation of the foregoing       *
*   restrictions may subject the user to criminal sanctions under    *
*   applicable laws, as well as to civil liability for the breach of *
*   the terms and conditions of this license.                        *
*                                                                    *
*   THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION.  NO           *
*   WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING,    *
*   BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND    *
*   FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE     *
*   COMPANY SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL,  *
*   INCIDENTAL OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.  *
*                                                                    *
*********************************************************************/

// -----------------------------------------------------------------------------
//         END OF FILE
// -----------------------------------------------------------------------------
