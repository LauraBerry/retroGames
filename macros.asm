;
; Pompeii II
; Assembler Macros
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
; 
; We keep our assembler macro constants in here.
; This includes all constants that refer to zero page RAM.
;

; ************* Assembler Macro Constants ****************
BACKGROUND_COLOR = $900f       ; Register that stores the border color for the VIC.

MAIN_CHAR_PTR = $9005          ; This address determines where we look for character maps.
MAIN_CUSTOM_PTR = $FF          ; This points us to 7168 ($1c00) for our char map.

; Clock/timing stuff
MAIN_CLK = $A2                 ; Points to the memory map of the hardware clock. We probably only need the lowest order byte.
MAIN_TICKRATE = 5              ; Tick is called every MAIN_TICKRATE jiffies.

; LCG Stuff.
LAVA_LCG_MULT = 33             ; Multiplier for LCG
LAVA_LCG_CONST = 1             ; Addition constant for LCG
LAVA_LCG_SEED = 32000          ; Initial seed value for the LCG (Should be 16 bits)



; ************* Assembler Macros ****************

; Put any macros here.
