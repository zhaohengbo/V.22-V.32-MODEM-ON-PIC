#undef byte
#undef word16
#undef word32
#define byte unsigned char
#define word16 unsigned short
#define sign_word16 signed short
#define word32 unsigned long
#ifndef NULL
#define NULL ((void *) 0)
#endif
#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

#if 1
/* status return values */
#define K_OK 0x00				/* successful call */
#define K_TIMEOUT 0x01			/* either time period ran out, or task woken by K_Task_Wake */
#define K_NOT_WAITING 0x02		/* task not waiting */
#define K_ERROR 0xff				/* general purpose error */

byte K_Task_Create(byte);	/* create task. */
byte K_Task_Start(byte);		/* start task */
byte K_Task_Wait(word16);	/*	have task wait, with or without time period */
byte K_Task_Wake(byte);		/* wake a task that was waiting. */
void K_Task_End(void);		/* must be called by all task prior to end brace. */
byte K_Task_Kill(byte);		/* kill task */

byte K_Event_Wait(byte,word16,byte);	/* wait on event, with/without time period */
byte K_Event_Sig(byte,byte);		/* signal an event */
#define K_Event_Signal(A,B,C) K_Event_Sig(B,C)		/* signal an event */
byte K_Event_Reset(byte,byte);				/* reset event bits */

void K_Task_Coop_Sched(void);		/* do a cooperative task switch. */

void K_OS_Init(void);		/* initialize CMX */
void K_OS_Start(void);		/* enter CMX OS */
void K_OS_Tick_Update(void);		/* called by interrupt, system tick */

void K_OS_Disable_Interrupts(void);		/* disable interrupts */
void K_OS_Enable_Interrupts(void);		/* enable interrupts */
void K_OS_Save_Interrupts(void);			/* save then disable interrupts */
void K_OS_Restore_Interrupts(void);		/* restore interrupts */
void K_OS_Intrp_Entry(void);				/* called by interrupts, entry */
void K_OS_Intrp_Exit(void);				/* called by interrupts, exit */

/* Not to be called by user!!! */
void K_I_Timer_Task(void);				/* CMX's timer task */

/* structure of task's ROM parameters */
typedef struct 
{	/* task function address, stack start address, priority */
	void (*task_addr)(void);		/* the task's CODE address */
	word16 *system_stack;	/* task system stack start address */
	byte init_priority;		/* the priority of this task */
} ROM_TCB;	/* NOTE:  5 byte structure */


#endif
