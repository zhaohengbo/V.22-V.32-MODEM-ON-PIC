
/* Use one #define per the device speed selection. Base XTAL on board is
   7.3728 MHz. Depending on PLL selection final device speed will be
   7.3728 MIPs (for XTx4PLL) or
   14.745600 MIPs (for XTx8PLL) or
   29.491200 MIPs (for XTx16PLL) or  

   This file is included in the following source code files and is used to
   adjust timing specific parameters based on the instruction cycle rate:
   Files:
   init_Uart.s
   device_config.s
*/
/* Set ONLY ONE of the following equates to a TRUE state */

.equ  XTx4PLL,    0    
.equ  XTx8PLL,    1
.equ  XTx16PLL,   0


; -----------------------------------------------------------------------------
;         END OF FILE
; -----------------------------------------------------------------------------
