;
; VIC20 Test Program 6
; Score Tracker
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
;
; This program draws the player's score on the top of the screen.
; A function to update the drawn score is also included.
;

;
; Prints player mode menu 
; "-1 PLAYER
;   2 PLAYER"
;
Player_mode_menu_init: SUBROUTINE
	LDX #$10                ; player mode strings are 10 characters
	LDY #$50
	LDA Player_Mode_selected
	CMP #1
	BNE print_player_2_selected
.print:
	LDA One_Player_Selected,X         				; Location of player1 string.
	STA SCREEN_RAM,Y       							; Print that char to the screen
    LDA #$1                 						; Color Black
    STA SCREEN_COLOR_RAM,X 							; Set the color
    DEX                     						; Decrement Loop Counter
	DEY
    BPL .print              						; Iterate!
	LDY #$60
.print_player_2
	LDA Two_Player_not_selected_str,X        		; Location of player2 string.
	STA SCREEN_RAM,Y       							; Print that char to the screen
    LDA #$1                 						; Color Black
    STA SCREEN_COLOR_RAM,X 							; Set the color
    DEX                     						; Decrement Loop Counter
	DEY
    BPL .print_player_2              				; Iterate!
    RTS
.print_player_2_selected:
	LDA One_Player_not_Selected,X         			; Location of player1 string.
    STA SCREEN_RAM,Y        						; Print that char to the screen
    LDA #$1                 						; Color Black
    STA SCREEN_COLOR_RAM,X  						; Set the color
    DEX                     						; Decrement Loop Counter
    BPL .print_player_2_selected		            ; Iterate!
    RTS
	LDY #$60
.print_player_2_2
	LDA Two_Player_selected_str,X        			; Location of player2 string.
	STA SCREEN_RAM,Y        						; Print that char to the screen
    LDA #$1                 						; Color Black
    STA SCREEN_COLOR_RAM,X  						; Set the color
    DEX                     						; Decrement Loop Counter
    BPL .print_player_2_2		            		; Iterate!
