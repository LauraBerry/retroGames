;
; Pompeii II
; Player movement manager
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
; 
; Provides methods to move the player around the screen.
;

;
; A function called every tick.
; Schedules when the player is allowed to move again.
;
player_sched:
    LDA player_move_countdown      ; Load our countdown
    BNE player_sched_end           ; If we're not scheduled to change phase, decrement and return.

    JSR player_move                ; Otherwise, Change the phase
    LDA #PLAYER_MOVE_INTERVAL      ; Grab our phase change
    STA player_move_countdown      ; Set it as our new countdown

player_sched_end:
    DEC player_move_countdown      ; Decrement our countdown to the next phase change
    RTS

;
; Read user input
; Move the player(s) one square based on input
;

;y goes from 0 to 22
;x goes from 0 to 21


player_move:
    JSR player_clear
	JSR move_keyboardstart
    RTS
;--------------start of player movement code
;------table for magic numbers
;key	number	
;A		17		
;D		18		
;W		09		
;S 		41		
;J		20		
;L		21		
;I		12		
;K		44		
;----move here so the code can branch to it, if left with the other code it will be out of range
;----player 2 move right
;will loop to the left of SCREEN if at right of SCREEN
player2right:
	LDY player_2x		;load current x position
	CPY #$14		;see if at right edge of SCREEN
	BEQ	player2rightat	
	INY				;move right
	STY player_2x		;save new position
	JMP player_buffer
player2rightat:	
	LDY #00			;move to left edge of SCREEN
	STY player_2x		;save new position
	JMP player_buffer
;----player 2 move down
;will loop to the top if at the bottom of SCREEN	
player2down:
	LDY player_2y		;load current y position
	CPY #$16 		;see if at bottom of SCREEN
	BEQ player2downat		
	INY				;move down
	STY player_2y		;save new position
	JMP player_buffer
player2downat:
	LDY #$01		;move to top of SCREEN
	STY player_2y	;save to new position
	JMP player_buffer

;----player 2 move up
;will loop to bottom if at the top of SCREEN
player2up:
	LDY player_2y	;load current y position
	CPY #$01		;see if at top of SCREEN
	BEQ player2upat
	DEY				;move up
	STY player_2y	;save to new position
	JMP player_buffer
player2upat:
	LDY #$16		;move to bottom of SCREEN
	STY player_2y	;save to new position
	JMP player_buffer

	
;----start of getting keyboard input
move_keyboardstart:
	LDA KEYPRESS	;load input from keyboard
	CMP	#64			;see if no key is pressed
	BEQ player_bufferend	;if no key is pressed quit out
	LDX KEYBUFFERCOUNTER	;see how many keys are in buffer

playercharacter:
	CMP #17	;player one move left key *WILL NOT WORK IF NOT MAGI
	BEQ player1left
	CMP #18	;player one move right key *WILL NOT WORK IF NOT MAGIC NUMBER*
	BEQ player1right
	CMP #9	;player one move up key *WILL NOT WORK IF NOT MAGIC NUMBER*
	BEQ player1up
	CMP #41	;player one move down key *WILL NOT WORK IF NOT MAGIC NUMBER*
	BEQ player1down
	CMP #20 ;player two move left key
	BEQ player2left
	CMP #21 ;player two move right key
	BEQ player2right
	CMP #12	;player two move up key
	BEQ player2up
	CMP #44	;player two move down key
	BEQ player2down
player_buffer:
	CPX #00
	BEQ	player_bufferend	;if no more keys in buffer branch
	DEX						;decrement buffer
	LDA KEYBOARDBUFFER,x	;load key from buffer
	JMP	playercharacter		;check for movement

player_bufferend:
	LDY #$00
	STY KEYBUFFERCOUNTER	;reset the keyboard buffer
	JMP player_print		;return from subroutine
	

;----player 1 move left
player1left:
	LDY player_1x	;load current x position 
	CPY #$00		;see if at left edge of SCREEN
	BEQ	player1leftat		
	DEY				;move left
	STY player_1x		;save new position
	JMP player_buffer
player1leftat:	
	LDY #$15			;move to right edge of SCREEN
	STY player_1x		;save new position
	JMP player_buffer

;----player 1 move right
player1right:
	LDY player_1x		;load current x position
	CPY #$14		;see if at right edge of SCREEN
	BEQ	player1rightat	
	INY				;move right
	STY player_1x		;save new position
	JMP player_buffer
player1rightat:	
	LDY #00			;move to left edge of SCREEN
	STY player_1x		;save new position
	JMP player_buffer

;----player 1 move down	
player1down:
	LDY player_1y		;load current y position
	CPY #$16 		;see if at bottom of SCREEN
	BEQ player1downat		
	INY				;move down
	STY player_1y		;save new position
	JMP player_buffer
player1downat:
	LDY #$01		;move to top of SCREEN
	STY player_1y		;save to new position
	JMP player_buffer

;----player 1 move up
player1up:
	LDY player_1y		;load current y position
	CPY #$01		;see if at top of SCREEN
	BEQ player1upat
	DEY				;move up
	STY player_1y		;save to new position
	JMP player_buffer
player1upat:
	LDY #$16		;move to bottom of SCREEN
	STY player_1y		;save to new position
	JMP player_buffer
	
;----player 2 move left
;will loop to right of SCREEN if at the left of SCREEN
player2left:
	LDY player_2x	;load current x position 
	CPY #$00		;see if at left edge of SCREEN
	BEQ	player2leftat		
	DEY				;move left
	STY player_2x		;save new position
	JMP player_buffer
player2leftat:	
	LDY #$15			;move to right edge of SCREEN
	STY player_2x		;save new position
	JMP player_buffer


;-----end of player movement


;----start of print character, will print both character---------
;y offset is moded with 7, and looped through to get the y offset
;the x offset is added to the y offset and store in X
;the y offset is reloaded into the Accumulator and divided by 8 to find the screen offset
;the character is printed to the right screen + offset
player_print:
	CLC
	LDA player_1y
	AND #$07		;mod 7
	TAX				;save to X
	LDA #00
;loop to calculate the y offset
player1_printloop:	
	CPX #00			;see if send of SCREEN
	BEQ player1_print	;branch out
	ADC	#$15			;add one row
	DEX				;decrement x
	JMP player1_printloop
;print player 1 to SCREEN
player1_print:
	ADC player_1x	;add x offset
	TAX				;save to x
	STX	player_1offset	;save to offset
	LDA player_1y
	CLC				;divide by 8
	LSR				;	
	CLC				;
	LSR				;
	CLC				;
	LSR				;
	CLC
	CMP #0			;see if at SCREEN 0
	BEQ player1_screen0
	CMP #01		;see if at screen 1
	BEQ player1_screen1

    ; Store the tile the player is stepping on.
    LDA SCREEN2,x
    STA player1_underTile
    
	LDA	#PLAYER_CHAR
	STA SCREEN2,x	;store to SCREEN

    ; Store the color of the tile the player is stepping on
    LDA SCREEN_COLOR_RAM+352,X
    STA player1_underTile_color

    ; Write player1's color into the square
    LDA player_1color
    STA SCREEN_COLOR_RAM+352,X

	JMP player_print2
player1_screen0:	
    ; Store the char the player is stepping on.
    LDA SCREEN,x
    STA player1_underTile

    ; Write the player's char
	LDA	#PLAYER_CHAR
	STA SCREEN,x	;save to SCREEN

    ; Store the color of the tile the player is stepping on
    LDA SCREEN_COLOR_RAM,X
    STA player1_underTile_color

    ; Write player1's color into the square
    LDA player_1color
    STA SCREEN_COLOR_RAM,X

	JMP player_print2
player1_screen1:	
    ; Store the tile the player is stepping on.
    LDA SCREEN1,x
    STA player1_underTile

	LDA	#PLAYER_CHAR
	STA SCREEN1,x	;print to SCREEN

    ; Store the color of the tile the player is stepping on
    LDA SCREEN_COLOR_RAM+176,X
    STA player1_underTile_color

    ; Write player1's color into the square
    LDA player_1color
    STA SCREEN_COLOR_RAM+176,X

	
player_print2:
	CLC
	LDA player_2y
	AND #$07		;mod 7
	TAX				;save to X
	LDA #00
;loop to calculate the y offset
player2_printloop:	
	CPX #00			;see if send of SCREEN
	BEQ player2_print	;branch out
	ADC	#$15		;add one row
	DEX				;decrement x
	JMP player2_printloop
;print player 2 to SCREEN
player2_print:
	ADC player_2x	;add x offset
	TAX				;save to x
	STX	player_2offset	;save offset
	LDA player_2y
	CLC				;divide by 8
	LSR				;	
	CLC				;
	LSR				;
	CLC				;
	LSR				;
	CLC
	CMP #0			;see if at SCREEN 0
	BEQ player2_screen0
	CMP #$01		;see if at screen 1
	BEQ player2_screen1
    ; Store the tile the player is stepping on.
    LDA SCREEN2,x
    STA player2_underTile

	LDA	#PLAYER_CHAR		;print to screen 2
	STA SCREEN2,x	;store to SCREEN

    ; Store the color of the tile the player is stepping on
    LDA SCREEN_COLOR_RAM+352,X
    STA player2_underTile_color

    ; Write player's color into the square
    LDA player_2color
    STA SCREEN_COLOR_RAM+352,X

	RTS
player2_screen0:	
    ; Store the tile the player is stepping on.
    LDA SCREEN,x
    STA player2_underTile

	LDA	#PLAYER_CHAR
	STA SCREEN,x	;save to SCREEN

    ; Store the color of the tile the player is stepping on
    LDA SCREEN_COLOR_RAM,X
    STA player2_underTile_color

    ; Write color into the square
    LDA player_2color
    STA SCREEN_COLOR_RAM,X

	RTS
player2_screen1:	
    ; Store the tile the player is stepping on.
    LDA SCREEN1,x
    STA player2_underTile

	LDA	#PLAYER_CHAR
	STA SCREEN1,x	;print to SCREEN

    ; Store the color of the tile the player is stepping on
    LDA SCREEN_COLOR_RAM+176,X
    STA player2_underTile_color

    ; Write color into the square
    LDA player_2color
    STA SCREEN_COLOR_RAM+176,X
	RTS
	
;-----clear both character from SCREEN-------------
;load the y offset into A
;load calculate offset into x
;divide A by 8 to get SCREEN number
;check SCREEN number then print with offset in x
player_clear:
	LDA player_1y	;load player 1 y location
	LDX	player_1offset	;load offset
	CLC				;divide by 8
	LSR				;	
	CLC				;
	LSR				;
	CLC				;
	LSR				;
	CMP #0			;see if at SCREEN 0
	BEQ player1_clear0
	CMP #$01		;see if at screen 1
	BEQ player1_clear1
	LDA	player1_underTile			;print to screen 2
	STA SCREEN2,x	;store to SCREEN

    ; Write player1's color into the square
    LDA player1_underTile_color
    STA SCREEN_COLOR_RAM+352,X

	JMP player2_clear
player1_clear0:	
	LDA	player1_underTile
	STA SCREEN,x	;save to SCREEN

    ; Write player1's color into the square
    LDA player1_underTile_color
    STA SCREEN_COLOR_RAM,X

	JMP player2_clear
player1_clear1:	
	LDA	player1_underTile
	STA SCREEN1,x	;print to SCREEN
    ; Write player1's color into the square
    LDA player1_underTile_color
    STA SCREEN_COLOR_RAM+176,X

player2_clear	
	LDA player_2y	;load player 2 y location
	LDX	player_2offset	;load offset
	CLC				;divide by 8
	LSR				;	
	CLC				;
	LSR				;
	CLC				;
	LSR				;
	CMP #0			;see if at SCREEN 0
	BEQ player2_clear0
	CMP #$01		;see if at screen 1
	BEQ player2_clear1
	LDA	player2_underTile			;print to screen 2
	STA SCREEN2,x	;store to SCREEN

    ; Write color into the square
    LDA player2_underTile_color
    STA SCREEN_COLOR_RAM+352,X
	RTS
player2_clear0:	
	LDA	player2_underTile
	STA SCREEN,x	;save to SCREEN

    ; Write color into the square
    LDA player2_underTile_color
    STA SCREEN_COLOR_RAM,X
	RTS
player2_clear1:	
	LDA	player2_underTile
	STA SCREEN1,x	;print to SCREEN

    ; Write color into the square
    LDA player2_underTile_color
    STA SCREEN_COLOR_RAM+176,X
	RTS
