;
; Pompeii II
; Main Program
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
; 
; This is the main entrypoint for the program.
; Provides the BASIC stub, loads the font, and includes the other files.
;

; ************* Program Constants ****************
    include "macros.asm"

; ************* DASM VIC20 BASIC stub ************
    processor 6502
    org 4097                ; start of program area

main_basicStub: 
    dc.w main_basicEnd      ; 4 byte pointer to next line of basic
    dc.w 2013               ; 4 byte (can be any number for the most part)
    hex 9e                  ; 1 byte Basic token for SYS
    hex 20                  ; ascii for space = 32
    hex 34 31 31 30         ; hex for asci 4110
    hex 00
main_basicEnd:
    hex 00 00               ; The next BASIC line would start here

; ************* Assembly Code ***************
    ; ==THIS SETS UP THE FONT==
    ; Point us to our new character map. Must have included the font at the end.
    LDA #CUSTOM_PTR         ; Grab the code for our custom charmap.
    STA CHAR_PTR            ; This is where the machine determines our char map.

main_loop:                  ; Does menu stuff. Launches into the actual game.

    ; Do main menu stuff here.

; Runs the game. Calls tick() at set intervals until a game over setate is reached.
game_loop:                  
    ; TODO: Call tick()
    ; TODO: Wait for next tick
    ; TODO: If game is over, break out of game loop

    jmp main_func           ; Jump back to the main function

    ; Data file. It sits in memory after the code, before the font.
    include "data.asm"

    ; This is our font file. Include it last. It maps to memory location 7168
    include "font.asm"

