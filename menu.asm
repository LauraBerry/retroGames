;
; Pompeii II
; Menu definitions
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
;
; This gives us our main menu and game over screen.
;


;
; Prints player mode menu 
; "- 1 PLAYER
;    2 PLAYER"
;
player_mode_menu_init: SUBROUTINE
	; Print Player 1 and player 2 menu strings
	LDX #0
.print_player1_str:
    LDA menu_one_Player_str,X   ; Location of string.
    CMP #0                      ; Check null terminator
    BEQ .print_player1_str_end       ; If we're at the null terminator, exit.

    STA SCREEN_RAM+$e4,X        ; Print that char to the screen
    LDA #$1                     ; Text Color
    STA SCREEN_COLOR_RAM+$e4,X  ; Set the color
    INX
    JMP .print_player1_str           ; Iterate!
.print_player1_str_end:

	LDX #0
.print_player2_str:
    LDA menu_two_Player_str,X   ; Location of string.
    CMP #0                      ; Check null terminator
    BEQ .print_player2_str_end       ; If we're at the null terminator, exit.

    STA SCREEN_RAM+$110,X        ; Print that char to the screen
    LDA #$1                     ; Text Color
    STA SCREEN_COLOR_RAM+$110,X  ; Set the color
    INX
    JMP .print_player2_str           ; Iterate!
.print_player2_str_end:

.input_loop:
	LDA KEYPRESS
	CMP #KEY_1
	BNE .check_two
	;set to one player
	LDA #1
	JMP .end
.check_two:
	CMP #KEY_2
	BNE .input_loop
	;set to two player
	LDA #2
.end
	RTS
	
;
; Prints "GAME OVER" To the center of the screen
; Prints the score.
; If relevant, prints the player that won.
;
menu_gameover: SUBROUTINE      
; Print GAME OVER
    LDX #0
.print_go_str:
    LDA global_gameover_str,X   ; Location of string.
    CMP #0                      ; Check null terminator
    BEQ .print_go_str_end       ; If we're at the null terminator, exit.

    STA SCREEN_RAM+$e2,X        ; Print that char to the screen
    LDA #$1                     ; Text Color
    STA SCREEN_COLOR_RAM+$e2,X  ; Set the color
    INX
    JMP .print_go_str           ; Iterate!
.print_go_str_end:

; Print the score
    LDX #0
.print_score_str:
    LDA score_str,X             ; Location of string.
    CMP #0                      ; Check null terminator
    BEQ .print_score_str_end    ; If we're at the null terminator, exit.

    STA SCREEN_RAM+$10e,X       ; Print that char to the screen
    LDA #$1                     ; Text Color
    STA SCREEN_COLOR_RAM+$10e,X ; Set the color
    INX
    JMP .print_score_str        ; Iterate!
.print_score_str_end:

    ; Print the score as a Character representation
    ; Just use the array of digits to output it.
    ; Number display codes start at $30, end at $39
    LDX #$02                    ; Loop 3 times. (1 for each digit)
.print_digits:
    CLC                         ; Make sure we start by clearing our carry bit.
    LDA score_p1_digits,X       ; Load this digit
    ADC #$30                    ; Add $30 to make it a display code
    STA SCREEN_RAM+$115,X         ; Print to Screen

    DEX                         ; Loop Decrement
    BPL .print_digits           ; Loopyness

; Check if we're printing a winner.
    LDA global_numPlayers       ; Load number of players
    CMP #$2                     ; If there are not 2
    BNE .end                    ; Skip printing the winner.

; Print who won.
    LDX #0
.print_winner_str:
    LDA global_playerWin_str,X  ; Location of string.
    CMP #0                      ; Check null terminator
    BEQ .print_winner_str_end   ; If we're at the null terminator, exit.

    STA SCREEN_RAM+$138,X       ; Print that char to the screen
    LDA #$1                     ; Text Color
    STA SCREEN_COLOR_RAM+$138,X ; Set the color
    INX
    JMP .print_winner_str       ; Iterate!
.print_winner_str_end:
    
; Print the actual player number.
    LDA global_gameState        ; 2 = p1 wins. 3 = p2 wins.
    ADC #$2E                    ; Turn it into a character code.
    STA SCREEN_RAM+$13f         ; Print to screen.


.end:
    RTS
	
