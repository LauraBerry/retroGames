;
; Pompeii II
; Assembler Macros
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
; 
; We keep our assembler macro constants in here.
; This includes all constants that refer to zero page RAM.
;

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

; Phase Stuff
PHASE_INTERVAL = 20             ; A new lava pattern is generated every LAVA_INTERVAL ticks

; SFX Stuff
SFX_RUMBLE = $93		; A low D tone for the noise speaker for the warning state (May not work, consider using $91)
SFX_SQUELCH = 0			; A constanct used for quieting any speaker making noise
SFX_LOWSOUND = $900A		; The low sound register
SFX_MIDSOUND = $900B		; The mid sound register
SFX_NOISE = $900D		; The noise sound register
SFX_INTERVAL = 20		; (might be redundant) The runble noise only lasts for SFX_INTERVAL ticks

; ************* Assembler Macros ****************

; Put any macros here.
