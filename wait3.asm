;
; Pompeii II
; wait3
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
; 
; this program waits 3 seconds and updates the lavaState variable
;

wait3:
	LDA wait3_lcg_currTicks			;load current amount of ticks left into A
	CMP #00							;check if there are zero ticks left 
	BEQ wait3_timeUp				; if so change the lavaState
	DEC								;if not decrease the current amount of ticks by 1
	STA wait3_lcg_currTicks
	JMP wait3
wait3_timeUp:						
	LDA global_lavaState			
	cmp #00							;check if lava state is 0 (safe state, screen is black)
	BNE wait3_warningState
	LDA #01							;set lava state to 1 (warning state, screen has yellow)
	STA global_lavaState
	jmp wait3_return
wait3_warningState:
	LDA global_lavaState
	CMP #01							;check if lava state is 1 (warning state, screen has yellow)
	BNE wait3_deadlyState
	LDA #02							;set lava state to 2 (deadly state, screen has red on it)
	STA global_lavaState
	jmp wait3_return
wait3_deadlyState:
	LDA #00							;set lava state to 0 (safe state, screen is black)
	JMP wait3_return

wait3_return:
	LDA #26							;re-set ticks to number that will cause a 3 second wait itme (TODO: update number may need to change)
	STA wait3_lcg_currTicks
	RTS								;return statement







; Data file. It sits in memory after the code, before the font.
    include "data.asm"
