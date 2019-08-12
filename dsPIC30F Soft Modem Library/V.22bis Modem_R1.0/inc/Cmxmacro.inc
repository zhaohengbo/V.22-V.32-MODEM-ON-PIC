	.global _K_Task_Create
	.global	_K_Task_Start
	.global	_K_Task_Wait
	.global	_K_Task_Wake
	.global	_K_Task_End
	.global	_K_Task_Kill
	.global	_K_Event_Wait
	.global	_K_Event_Sig
	.global	_K_Event_Reset
	.global	_K_Task_Coop_Sched
	.global	_K_OS_Init
	.global	_K_OS_Start
	.global	_K_OS_Tick_Update
	.global	_K_OS_Disable_Interrupts
	.global	_K_OS_Enable_Interrupts
	.global	_K_OS_Save_Interrupts
	.global	_K_OS_Restore_Interrupts
	.global	_K_OS_Intrp_Entry
	.global	_K_OS_Intrp_Exit

.macro K_Task_Create task_num
	mov.b	#\task_num,w0
	rcall	_K_Task_Create
 .endm

.macro K_Task_Start task_num
	mov.b	#\task_num,w0
	rcall	_K_Task_Start
 .endm

.macro K_Task_Wait time
	mov	#\time,w0
	rcall	_K_Task_Wait
 .endm

.macro K_Task_Wake task_num
	mov.b	#\task_num,w0
	rcall	_K_Task_Wake
 .endm

.macro K_Task_End
	rcall	_K_Task_End
 .endm

.macro K_Task_Kill task_num
	mov.b	#\task_num,w0
	rcall	_K_Task_Kill
 .endm

.macro K_Event_Wait match,time,mode
	mov.b	#\mode,w2
	mov	#\time,w1
	mov.b	#\match,w0
	rcall	_K_Event_Wait
 .endm

.macro K_Event_Signal mode,task_num,event
	mov.b	#\event,w1
	mov.b	#\task_num,w0
	rcall	_K_Event_Sig
 .endm

.macro K_Event_Reset task_num,event
	mov.b	#\event,w1
	mov.b	#\task_num,w0
	rcall	_K_Event_Reset
 .endm

.macro K_Task_Coop_Sched
	rcall	_K_Task_Coop_Sched
 .endm

.macro K_OS_Init
	rcall	_K_OS_Init
 .endm

.macro K_OS_Start
	rcall	_K_OS_Start
 .endm

.macro K_OS_Tick_Update
	rcall	_K_OS_Tick_Update
 .endm

.macro K_OS_Disable_Interrupts
	rcall	_K_OS_Disable_Interrupts
 .endm

.macro K_OS_Enable_Interrupts
	rcall	_K_OS_Enable_Interrupts
 .endm

.macro K_OS_Save_Interrupts
	rcall	_K_OS_Save_Interrupts
 .endm

.macro K_OS_Restore_Interrupts
	rcall	_K_OS_Restore_Interrupts
 .endm

.macro K_OS_Intrp_Entry
	rcall	_K_OS_Intrp_Entry
 .endm

.macro K_OS_Intrp_Exit
	rcall	_K_OS_Intrp_Exit
 .endm



