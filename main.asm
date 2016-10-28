;
; Pompeii II
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
; 
; This is the main entrypoint for the program.
; Provides the BASIC stub, loads the font, and includes the other files.
;

; ************* Program Constants ****************
CHAR_PTR = $9005          ; This address determines where we look for character maps.
CUSTOM_PTR = $FF          ; This points us to 7168 ($1c00) for our char map.

; ************* DASM VIC20 BASIC stub ************
    processor 6502
    org 4097                ; start of program area

main_basicStub: 
    dc.w main_basicEnd      ; 4 byte pointer to next line of basic
    dc.w 2013               ; 4 byte (can be any number for the most part)
    hex  9e                 ; 1 byte Basic token for SYS
    hex  20                 ; ascii for space = 32
    hex  34 31 31 30        ; hex for asci 4110
    hex 00
main_basicEnd:
    hex 00 00               ; The next BASIC line would start here

; ************* Assembly Code ***************
main_func:
    ; ==THIS SETS UP THE FONT==
    ; Include this line and the inlclude line at the end to use this font.
    ; Point us to our new character map.
    LDA #CUSTOM_PTR         ; Grab the code for our custom charmap.
    STA CHAR_PTR            ; This is where the machine determines our char map.

    ; Actual code goes here
    jmp main_func

    ; This is our font file. Include it last. It maps to memory location 7168
    include "font.asm"
