;
; Pompeii II
; Assembler Macros
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
; 
; We keep our assembler macro constants in here.
; This includes all constants that refer to zero page RAM.
;

; ************* Assembler Macro Constants ****************
CHAR_PTR = $9005          ; This address determines where we look for character maps.
CUSTOM_PTR = $FF          ; This points us to 7168 ($1c00) for our char map.

; LCG Stuff.
LCG_MULT = 33             ; Multiplier for LCG
LCG_CONST = 1             ; Addition constant for LCG
LCG_SEED = 32000          ; Initial seed value for the LCG (Should be 16 bits)
