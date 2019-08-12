
/******************************************************************************
;                                                                             *
;    Author              :                                                    *
;    Company             :                                                    *
;    Filename            :  bin2dec.c                                         *
;    Date                :  06/07/2004                                        *
;                                                                             *
;                                                                             *
;    Other Files Required: p30F6014.gld, p30f6014.inc                         *
;    Tools Used:MPLAB IDE       : 6.52.00                                     *
;               ASM30 Assembler : 1.20.01                                     *
;               Linker          : 1.20.01                                     *
;                                                                             *
;    Devices Supported by this file:                                          *
;                        dsPIC 30F6014                                        *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Additional Notes:                                                        *
;                                                                             *
;    adc2dec: This routine converts A/D conversion results from binary        * 
;    to decimal assuming that the max A/D value of "0xFFF" represents         *
;    exactly 5.0 volts. The result is stored in ASCII form.                   *
;                                                                             * 	 
;                                                                             *
;    Routine uses a successive approximation algorithm to perform the         *
;    conversion                                                               *
;                                                                             *
;*****************************************************************************/



//Provide the following variables global scope
char adones=0;
char adtenths=0;
char adhundredths=0;
char adthousandths=0;

// -----------------------------------------------------------------------------
// Subroutine: ADC Binary to Decimal Conversion
// -----------------------------------------------------------------------------
void adc2dec( unsigned int ADRES )
{
	 adones = 0;					//reset values
	 adtenths = 0;
	 adhundredths = 0;
	 adthousandths = 0;
	 
	 while ( ADRES > 0x0 )
	 {
	  	if( ADRES > 0x333 )		    //test for 1 volt or greater
		{
			adones++;			    //increment 1 volt counter
			ADRES -= 0x334;			//subtract 1 volt
		}
		else if( ADRES > 0x51 && ADRES <= 0x333 )		
		{
			if (adtenths < 9)
		   	{
			  adtenths++;			//increment tenths
			}
			else 
			{
			  adones++;			    //tenths has rolled over
			  adtenths = 0;			//so increment ones and reset tenths
			}
			ADRES -=0x52;
		}
		else if(ADRES > 0x8 && ADRES <= 0x51)		
		{
			if (adhundredths < 9)
			{
				adhundredths++;		//increment hundreths
			}
			else 
			{
				
				adhundredths = 0;	//reset hundredths
				if (adtenths < 9)
		   		{
			  		adtenths++;		//and increment tenths
				}
				else 
				{
			 	 	adones++;		//unless tenths has rolled over
			  		adtenths = 0;	//so increment ones and reset tenths
				}
			}
			ADRES -= 0x9;
		}
		else if(ADRES >= 0x1 && ADRES <= 0x8)		
		{
			if (adthousandths < 9)
			{
				adthousandths++;	//increment thousandths
			}
			else
			{					    //unless thousands has rolled over
				adthousandths = 0;	//so reset thousands 
				if (adhundredths < 9)		
				{
					adhundredths++;	//and increment hundreths
				}
				else 
				{				    //unless hundredths has rolled over
					adhundredths = 0;	//so reset hundredths
					if (adtenths < 9)
		   			{
			  			adtenths++;	    //and increment tenths
					}
					else 
					{
			 	 		adones++;		//unless tenths has rolled over
			  			adtenths = 0;	//so increment ones and reset tenths
					}
				}
			}
			ADRES -= 1;
		}
		
	 }
	 
	adones += 0x30;			           //convert all values to ascii
	adtenths += 0x30;
	adhundredths += 0x30;
	adthousandths += 0x30;	
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
