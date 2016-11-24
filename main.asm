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
    LDA #MAIN_CUSTOM_PTR    ; Grab the code for our custom charmap.
    STA MAIN_CHAR_PTR       ; This is where the machine determines our char map.

    ; Set up the screen
    JSR CLRSCN              ; Clear the screen (Using kernal method. May need to change.)
    LDA #12                 ; Background/border color. White on black.
    STA BACKGROUND_COLOR

    JSR sfx_volume          ; Turn the volume up
main_loop:                  ; Does menu stuff. Launches into the actual game.
    ; Do main menu stuff here.
	JSR player_mode_menu_init	; Display the main menu. Get the number of players in register A
	STA global_numPlayers		; Store this in our number of players registers

    JSR score_init
    LDA #0
    STA global_gameState
; Runs the game. Calls tick() at set intervals until a game over setate is reached.
	
	;open 1 or 2 player menu
	;controls for which one has the curser beside it.
	; when enter is pressed jump to main_game_loop other wise keep shoing menu
	
main_game_loop:
    ; Calculate and store the time for our next tick.
    
    ; Zero out the main clock.
    LDA #0
    STA MAIN_CLK
    STA MAIN_CLK+1
    STA MAIN_CLK+2

    JSR main_tick               ; Call tick()

    ; Check if we died.
    LDA global_gameState
    CMP #2
    BCS main_game_over

main_game_wait_loop:
    LDA MAIN_CLK+2              ; Load the LSB of the main clock
    CMP #MAIN_TICKRATE          ; If its counted past our tickrate
    BCS main_game_loop          ; Loop to the next tick
    JMP main_game_wait_loop     ; Else, wait.

    JMP main_game_loop
main_game_over:
	JSR sfx_stop_noise
    JSR CLRSCN                  ; Clear the screen (Using kernal method.)
    JSR menu_gameover           ; Print "GAME OVER"

endLoop:                    ; TODO: Remove this. Let them start a new game.
    JMP endLoop             ; Loop until they reset the machine

    JMP main_loop           ; Always jump back to main function (title screen) at game over.

; This is the tick function. This is called to update our game every frame.
main_tick: SUBROUTINE       ; Tick function for the main game loop.
    JSR player_sched        ; Player Movement
    JSR phase_sched         ; If need be, change the lava's phase (Safe, Warning, Danger)
    JSR lava_generate_sched ; Lava Generation
    JSR sfx_mute_sched      ; Call function for checking game state and rumbling if appropriate
    JSR sfx_jukebox         ; Call to music function

    RTS

    ; Game logic files. The order of these shouldn't matter.
    include "menu.asm"
    include "lava.asm"
    include "score.asm"
    include "phase.asm"
    include "player.asm"
    include "sfx.asm"

    ; Data file. It sits in memory after the code, before the font.
    include "data.asm"

    ; This is our font file. Include it last. It maps to memory location 7168
    include "font.asm"

