
;
; A function called every tick.
; Schedules when we change the lava phase
;
phase_sched:
    LDA phase_change_countdown    ; Load our countdown
    BNE phase_sched_end             ; If we're not scheduled to change phase, decrement and return.

    JSR phase_change           ; Otherwise, Change the phase
    LDA #PHASE_INTERVAL          ; Grab our phase change
    STA phase_change_countdown    ; Set it as our new countdown

phase_sched_end:
    DEC phase_change_countdown    ; Decrement our countdown to the next phase change
    RTS

;
; Checks what the current state is, changes accordingly.
;
phase_change:						
    ; Increment the lava state.
    INC global_lavaState


    ; If the lava state is 
    LDA global_lavaState
    CMP #3
    BNE next
    LDA #0
    STA global_lavaState
next:

;	LDA global_lavaState			
;	cmp #00							;check if lava state is 0 (safe state, screen is black)
;	BNE phase_change_warningState
;	LDA #01							;set lava state to 1 (warning state, screen has yellow)
;	STA global_lavaState
;	jmp wait3_return
;phase_change_warningState:       
;	LDA global_lavaState
;	CMP #01							;check if lava state is 1 (warning state, screen has yellow)
;	BNE phase_change_deadlyState
;	LDA #02							;set lava state to 2 (deadly state, screen has red on it)
;	STA global_lavaState
;	jmp wait3_return
;phase_change_deadlyState:
;	LDA #00							;set lava state to 0 (safe state, screen is black)
;	JMP wait3_return
;
;wait3_return:

    ; Change the lava color
    LDX global_lavaState
    LDY phase_lavaColors,X
    JSR phase_change_lava_color
	RTS								;return statement

;
; Change the color of each lava tile.
; Register Y contains the color we're writing
;
phase_change_lava_color:
    LDX #0                              ; Loop Index
phase_change_lava_color_loop:              ; This loop fills each character with lava (or not lava)
    ; First half of the screen.
    TYA
    STA SCREEN_COLOR_RAM+LAVA_START_OFFSET,X

    ; This does stuff for the second half of the screen.
    TXA                                 ; Transfer loop counter to A for compare
    CMP #LAVA_SCREEN2_SIZE              ; Because we have this many characters in the latter half of the screen.
    BCS change_lava_color_genLoop_end   ; So if we've already written that many, don't outstep the screen buffer.
    TYA
    STA SCREEN_COLOR_RAM+LAVA_SCREEN_OFFSET,X

change_lava_color_genLoop_end:          ; Looping things.
    INX                                 ; Decrement Loop Counter
    BNE phase_change_lava_color_loop       ; Iterate!
    RTS

