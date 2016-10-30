;
; Pompeii II
; Data Definition
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
; 
; This is where we keep all the references to variables in our program
; This does not include zero page
;

    org 6168              ; This is where our data section starts. This can be changed.

; ************* Assembler Macro Constants ****************
CLRSCN  = $e55f                ; clear screen kernel method
BACKGROUND_COLOR = $900f       ; Register that stores the border color for the VIC.
SCREEN_RAM = $1E00             ; This is the location of screen memory
SCREEN_COLOR_RAM = $9600       ; The location of screen color memory.

MAIN_CHAR_PTR = $9005          ; This address determines where we look for character maps.
MAIN_CUSTOM_PTR = $FF          ; This points us to 7168 ($1c00) for our char map.

; Clock/timing stuff
MAIN_CLK = $A2                 ; Points to the memory map of the hardware clock. We probably only need the lowest order byte.
MAIN_TICKRATE = 4              ; Tick is called every MAIN_TICKRATE jiffies.

; Lava Stuff.
LAVA_INTERVAL = 20             ; A new lava pattern is generated every LAVA_INTERVAL ticks
LAVA_LCG_MULT = 33             ; Multiplier for LCG
LAVA_LCG_CONST = 1             ; Addition constant for LCG
LAVA_LCG_SEED = 32000          ; Initial seed value for the LCG (Should be 16 bits)
LAVA_DANGER_CHAR = 27          ; Character 27 is a lava tile.
LAVA_SAFE_CHAR = 32            ; Character 32 is a space.
LAVA_COLOR = 2                 ; Lava is red
LAVA_START_OFFSET = 22         ; Generate lava at this offset so we have room on top for the player's score
LAVA_SCREEN_OFFSET = LAVA_START_OFFSET + $100 ; Used for generating lava on the latter half of the screen.
LAVA_SCREEN2_SIZE = $e4

; Zero page stuff
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

