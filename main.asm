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
main: SUBROUTINE                ; Main function. This is where our program starts.
    ; ==THIS SETS UP THE FONT==
    ; Point us to our new character map. Must have included the font at the end.
    LDA #MAIN_CUSTOM_PTR        ; Grab the code for our custom charmap.
    STA MAIN_CHAR_PTR           ; This is where the machine determines our char map.

    LDA #0                      ; Enable joystick input 1. Don't do 2 because that messes up the keyboard.
    STA JOYSTICK_1_DDR          ; Instead, enable 2 briefly when we need to read the joystick. Then disable.

.menu_loop:                     ; Does menu stuff. Launches into the actual game.
    ; Set up the screen
    JSR CLRSCN                  ; Clear the screen (Using kernal method. May need to change.)
    LDA #12                     ; Background/border color. White on black.
    STA BACKGROUND_COLOR        ; Store it.
    JSR sfx_volume              ; Turn DAT VOLUME UP

    ; Do main menu stuff here.
    JSR player_mode_menu_init   ; Display the main menu. Get the number of players in register A

    JSR score_init              ; Initialize the score display
    LDA #0                      ; Start the game state at zero.
    STA global_gameState        ; Store it.

    ; Seed the RNG with how many jiffies the user spent at the main menu.
    LDA MAIN_CLK+2              ; Load the low byte of main clock.
    STA lava_lcg_data+1         ; Store it to our seed.
    LDA MAIN_CLK+1              ; Load the middle byte of main clokc.
    STA lava_lcg_data           ; Store it to our seed.

.game_loop:                     ; Runs the game. Calls tick() at set intervals until a game over state is reached.
    LDA #0                      ; Zero out the main clock
    STA MAIN_CLK
    STA MAIN_CLK+1
    STA MAIN_CLK+2

    JSR main_tick           ; Call tick()

    ; Check if the game is over
    LDA global_gameState    ; Check gamestate
    CMP #2                  ; If gamestate >= 2
    BCS .game_over          ; Our game is over.

.game_wait_loop:
    LDA MAIN_CLK+2          ; Load the LSB of the main clock
    CMP #MAIN_TICKRATE      ; If its counted past our tickrate
    BCS .game_loop          ; Loop to the next tick
    JMP .game_wait_loop     ; Else, wait.

    JMP .game_loop          ; Iterate!
.game_over:                 ; When we hit here, it's game over.
    JSR sfx_stop_noise      ; Mute any noise.
    JSR CLRSCN              ; Clear the screen (Using kernal method.)
    JSR menu_gameover       ; Print "GAME OVER"

.input_loop:                ; Loop until the player presses space.
    LDA KEYPRESS            ; Load keypress
    CMP #KEY_SPACE          ; If they don't input a space
    BNE .input_loop         ; Keep reading input.

    JSR reset_gameState     ; Reset the game state.

    JMP .menu_loop          ; Always jump back to the title screen after gameover.

; This is the tick function. This is called to update our game every frame.
main_tick: SUBROUTINE       ; Tick function for the main game loop.
    JSR player_sched        ; Player Movement
    JSR phase_sched         ; If need be, change the lava's phase (Safe, Warning, Danger)
    JSR lava_generate_sched ; Lava Generation
    JSR sfx_mute_sched      ; Call function for checking game state and rumbling if appropriate
    JSR sfx_jukebox         ; Call to music function
    RTS

; This function resets game state variables when we start a new game.
reset_gameState: SUBROUTINE
    LDA #0
    STA global_gameState        ; Game state is at 0 to start.
    STA global_lavaState        ; Lava state is at 0 to start.
    STA sfx_current_note        ; Reset SFX variables.
    STA sfx_current_tick
    STA sfx_warningCount
    STA lava_next_generation    ; Countdowns should also be reset.
    STA player_move_countdown
    STA score_p1
    LDA #9
    STA player1_y               ; Reset player coordinates.
    STA player2_y
    LDA #1
    STA player1_x
    LDA #20
    STA player2_x
    LDA #LAVA_DEFAULT_THRESHOLD ; Difficulty stuff. Set default lava threshold.
    STA lava_threshold
    LDA #PHASE_DEFAULT_INTERVAL ; And lava phase interval.
    STA phase_interval          
    STA phase_change_countdown
    RTS

    ; //////////////////////////////////////////////////////
    ; Other assembly files to include
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

