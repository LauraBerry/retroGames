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
ZERO_X = $F1              ; The player's current x location 
ZERO_Y = $F2              ; The player's current y location 

; ************* Global Game State Variables ***************

; Any game state vars that are not in zero page go here.
global_lavaState:		;value used to decide if the game is in safe, warning or dangerous mode
	byte 2				;0==Safe(color =black), 1== warning(color = yellow), 2== dangerous(color= red). Start in danger because we pre-increment.
global_gameState:		;value used to decide if game is in a new game, game running or game over state
	byte 0				;0=game running, 1= new game, 2 = game over
	
; ************* Local Variables - General Memory ***************
; Define local variables in here.
main_next_tick:
    byte 0

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

; Score Stuff
score_p1:
    byte $0             ; This is our player's score. Goes to 255.
score_str:              ; String: "SCORE: \0"
    byte $13, $03, $0f, $12, $5, $2c, $20, $0
score_p1_digits:        ; The number of hundreds, tens, and ones in the player's score.
    byte 1,2,3

; Color Stuff	
colorChoser_lcg_colorValue:		;Number storing the value of the color for the lava tiles
	byte 0						;0== black, 7== yellow, 2== red

; Phase Stuff
phase_change_countdown:
    byte 0                      ; Number of ticks until the phase of the game changes
phase_lavaColors:
    byte 0,7,2                  ; Color values for lava when it's in safe, warning, danger

; Player Stuff
player_move_countdown:
    byte 0                      ; Number of ticks until the phase of the game changes

; SFX Stuff
sfx_warningCount:
    byte 0			; (Might be redundant) Used for counting the ticks of a warning state
