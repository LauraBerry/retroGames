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
    LDA #MAIN_CUSTOM_PTR         ; Grab the code for our custom charmap.
    STA MAIN_CHAR_PTR            ; This is where the machine determines our char map.

    ; Set up the screen
    JSR CLRSCN                   ; Clear the screen (Using kernal method. May need to change.)
    LDA #12                      ; Background/border color. White on black.
    STA BACKGROUND_COLOR


main_loop:                  ; Does menu stuff. Launches into the actual game.
    ; Do main menu stuff here.

    JSR score_init
; Runs the game. Calls tick() at set intervals until a game over setate is reached.
main_game_loop:
    ; Calculate our next tick value.
    LDA MAIN_CLK                ; Grab our current time.
    ADC #MAIN_TICKRATE          ; Add to it to get the time we'll execute our next tick.
    STA main_next_tick          ; Store it to memory.

    JSR main_tick

main_game_wait_loop:
    LDA MAIN_CLK                ; Grab our current time.
    CMP main_next_tick          ; Check the time against our stored value
    BNE main_game_wait_loop

    ; TODO: If game is over, break out of game loop

    JMP main_game_loop

    ; TODO: Game over stuff happens here.

    JMP main_loop           ; Always jump back to main function (title screen) at game over.

; This is the tick function. This is called to update our game every frame.
main_tick:                  ; Tick function for the main game loop.
    JSR phase_sched         ; If need be, change the lava's phase (Safe, Warning, Danger)
    JSR score_update
    RTS

    ; Game logic files. The order of these shouldn't matter.
    include "lava.asm"
    include "score.asm"
    include "phase.asm"

    ; Data file. It sits in memory after the code, before the font.
    include "data.asm"

    ; This is our font file. Include it last. It maps to memory location 7168
    include "font.asm"

    ; Sound effects data and operations will be executed here
    include "sfx.asm"

