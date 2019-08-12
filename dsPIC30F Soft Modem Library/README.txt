              dsPIC30F Soft-Modem Demo Support Readme File
              --------------------------------------------

9:04 AM 6/4/2004


-------------------------------------------------------------------
The dsPICDEM.net User's Guide (DS51471a.pdf), section 6.5 steps 4 and 6 
makes reference to a V22bisdemo.hex file.


These two steps should read as follows:

4. From the MPLAB IDE File manu, select Import. Select the correct .hex file for 
the dsPICDEM.net board you are using:

	dsPICDEM.net 1 Board --> dsPICSM_V22bisE_FCC_PCModem.hex
	dsPICDEM.net 2 Board --> dsPICSM_V22bisE_CTR_PCModem.hex


6. From the MPLAB IDE Programmer menu select Program. The dsPICSM_V22bisE_FCC_PCModem.hex
or dsPICSM_V22bisE_CTR_PCModem.hex file downloads to the dsPIC30F6014. The Output
Window records the process as it occurs and indicates completion by displaying
"MPLAB ICD 2 Ready".


Future revisions of the dsPICDEM.net User's Guide will incorporate these clarifications.




-------------------------------------------------------------------
The V.22bis Soft-Modem Library with full source code is provided on this CD.

Depending on your country PSTN characteristics some options may need to be
invoked and the soft-modem library may then need to be rebuilt for generation
of the appropriate .hex file.  Please refer to the dsPIC30F Soft-Modem Library
User's Guide for additional information.

