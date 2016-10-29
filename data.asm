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
global_example_state:
    byte 0

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
color_colorState: ;Number used to tell what state (safe, warning, danger) the game is in.
	byte 0			;0==black, 2== yellow, 3== red

color_colorValue:	;Number storing the value of the color for the lava tiles
	byte 0			;0== black, 7== yellow, 2== red

