


//-----------------------------------------------------------------------------
// LCD function prototypes


/******	LCD FUNCTION PROTOYPES ******/

void Init_LCD( void );		    // initialize display		
void lcd_cmd( char cmd );	        // write command to lcd
void lcd_data( char data );		    // write data to lcd
void Puts_LCD ( unsigned char *data, unsigned char count );


/*****	LCD COMMAND FUCNTION PROTOTYPES  *****/
#define cursor_right()  lcd_cmd( 0x14 )
#define cursor_left()   lcd_cmd( 0x10 )
#define display_shift() lcd_cmd( 0x1C )
#define home_clr()      lcd_cmd( 0x01 )
#define home_it()       lcd_cmd( 0x02 )
#define line_2()        lcd_cmd( 0xC0 )
