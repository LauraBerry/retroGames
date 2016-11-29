;
; Pompeii II
; Data Definition
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
;
; This is where we keep all the references to variables in our program
; This does not include zero page
;

    org 6168              ; This is where our data section starts. This can be changed.

; ************* Game State Variables - Zero Page Memory ***************
; These are technically assembler macros.

; ************* Global Game State Variables ***************

; Any game state vars that are not in zero page go here.
global_lavaState:       ;value used to decide if the game is in safe, warning or dangerous mode
    byte 0              ;0==Safe(color =black), 1== warning(color = yellow), 2== dangerous(color= red). Start in danger because we pre-increment.
global_gameState:       ;value used to decide if game is in a new game, game running or game over state
    byte 0              ;0=new game, 1= game running, 2 = p1 wins, 3 = p2 wins, 4 = tie game.
global_gameover_str:    ; String: "GAME OVER\0"
    byte $7, $1, $d, $5, $20, $f, $16, $5, $12, $0
global_numPlayers:      ; 1 for 1-player game, 2 for 2-player game.
    byte $2
global_playerWin_str:   ; "PLAYER   WINS!\0"
    byte $10, $c, $1, $19, $5, $12, $20, $20, $20, $17, $9, $e, $13, $3b, $0
global_tie_str:         ; "TIE GAME\0"
    byte $14, $9, $5, $20, $7, $1, $d, $5, $0
global_restart_str: ; "SPACE TO RESTART"
    byte $13, $10, $1, $3, $5, $20, $14, $f, $20, $12, $5, $13, $14, $1, $12, $14, $0

; ************* SFX Variables - Music Arrays ***************
sfx_theme_notes:        ; This is our sequence of notes
    byte 191,201,207,209,191,0,191,201,207,209,215,209,201,207,0,201,209,191
sfx_theme_timing:       ; This is our sequence of timings corresponding to each note
    byte 10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,20,10,20
sfx_current_note:       ; Keeps track of the current location in the note array
    byte 0
sfx_current_tick:       ; Keeps track of the current timer between game ticks
    byte 0

; ************* Local Variables - General Memory ***************
; Define local variables in here.

; Title screen
menu_pompeii_str:                           ;Pompeii 2
    byte $10, $f, $d, $10, $5, $9, $9, $20, $32, $0

menu_sub_title:         ;a trial by fire
    byte $1, $20, $14, $12, $9, $1, $c, $20, $2, $19, $20, $6,  $9, $12, $5, $0

volcano_str_1:
    byte $20, $20, $1f, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1f, $0
volcano_str_2:
    byte $20, $20, $1e, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1e, $0
volcano_str_3:
    byte $20, $20, $20,$20, $1c, $1b, $1b, $1b, $1b, $1b, $1b, $1d, $0
volcano_str_4:
    byte $20, $20, $20,$20, $1f, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1f, $0
volcano_str_5:
    byte $20, $20, $20,$1f, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1f, $0
volcano_str_6:
    byte $20, $20,$1f, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1f, $0

;Player Mode
menu_one_Player_str:            ;"  1 PLAYER"
    byte $10, $12,$5, $13, $13,$20, $31,$20,$6,$f, $12, $20,$31, $20, $10, $c, $1, $19, $5, $12,$0
menu_two_Player_str:            ;"  2 PLAYER"
    byte $10, $12,$5, $13, $13,$20, $32,$20,$6,$f, $12,$20,$32, $20, $10, $c, $1, $19, $5, $12,$0
menu_player_mode_selected:              ;variable set to 1 if curser is beside "1 PLAYER"  and 2 if it is beside "2 PLAYER"
    byte 1

; Lava Stuff
lava_next_generation:   ; The number of ticks until we generate a new lava pattern. Init to zero so we instantly generate it.
    byte 0
lava_lcg_data:          ; Random number stored here. Initialize to the high and low seed bytes.
    byte >LAVA_LCG_SEED,<LAVA_LCG_SEED
lava_lcg_tmp_data:
    byte 0,0            ; Used for intermediate computation
lava_lcg_reg_store:
    byte 0

lava_threshold:         ; If generated random bytes are >= this value, the tile is lava.
    byte 128
lava_phase_interval:    ; Ticks between phases. Speed this up to make it more difficult.
    byte 50

; Score Stuff
score_p1:
    byte 0              ; This is our player's score. Goes to 255.
score_str:              ; String: "SCORE: \0"
    byte $13, $03, $0f, $12, $5, $2c, $20, $0
score_p1_digits:        ; The number of hundreds, tens, and ones in the player's score.
    byte 1,2,3

; Color Stuff
colorChoser_lcg_colorValue:     ;Number storing the value of the color for the lava tiles
    byte 0                      ;0== black, 7== yellow, 2== red

; Phase Stuff
phase_change_countdown:
    byte 50                     ; Number of ticks until the phase of the game changes
phase_lavaColors:
    byte 0,7,2                  ; Color values for lava when it's in safe, warning, danger

; SFX Stuff
sfx_warningCount:
    byte 0                      ; (Might be redundant) Used for counting the ticks of a warning state

; Player Stuff
player_move_countdown:
    byte 0                  ; Number of ticks until the phase of the game changes
player1_x:                  ; Player 1 x location
    byte 1
player2_x:                  ; Player 2 x location
    byte 20
player1_y:                  ; Player 1 y location
    byte 9
player2_y:                  ; Player 2 y location
    byte 9
player1_offset:             ; Calculated offset for player 1
    byte 0
player2_offset:             ; Calculated offset for player 2
    byte 0
player1_color:
    byte 4
player2_color:
    byte 6
player1_underTile:          ; The tile that is currently 'underneath' player 1
    byte #LAVA_SAFE_CHAR
player1_underTile_color:    ; The color of the tile underneath the player
    byte 0
player2_underTile:          ; The tile that is currently 'underneath' player 2
    byte #LAVA_SAFE_CHAR
player2_underTile_color:    ; The color of the tile underneath the player
    byte 0
