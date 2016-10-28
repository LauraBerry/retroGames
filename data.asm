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
lava_lcg_data: ; Random number stored here. Initialize to the high and low seed bytes.
    byte >LCG_SEED,<LCG_SEED
lava_lcg_tmp_data:
    byte 0,0 ; Used for intermediate computation
color_lcg_colorState: ;Number used to tell what state (safe, warning, danger) the game is in.
	byte 0			;0==black, 2== yellow, 3== red

color_lcg_colorValue:	;Number storing the value of the color for the lava tiles
	byte 0			;0== black, 7== yellow, 2== red

