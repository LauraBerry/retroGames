;
; Pompeii II
; Menu definitions
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
;
; This gives us our main menu and game over screen.
;

;
; Prints player mode menu 
; "- 1 PLAYER
;    2 PLAYER"
;2E for title
player_mode_menu_init: SUBROUTINE
    ; Print title and subtitle
    PRINT_STR menu_pompeii_str, $33
    PRINT_STR menu_sub_title, $5C

    ; Print the volcano
    PRINT_STR_COLOR volcano_str_1, $87, $2
    PRINT_STR_COLOR volcano_str_2, $9D, $2
    PRINT_STR_COLOR volcano_str_3, $B3, $2
    PRINT_STR_COLOR volcano_str_3, $C9, $2
    PRINT_STR_COLOR volcano_str_4, $DE, $5
    PRINT_STR_COLOR volcano_str_5, $F4, $5
    PRINT_STR_COLOR volcano_str_6, $10A, $5

    ; Print instructions for starting game
    PRINT_STR menu_one_Player_str, $135
    PRINT_STR menu_two_Player_str, $161

.input_loop:
    LDA KEYPRESS
    CMP #KEY_1
    BNE .check_two
    ;set to one player
    LDA #1
    STA global_numPlayers       ; Store this in our number of players registers
    JMP .end
.check_two:
    CMP #KEY_2
    BNE .input_loop
    ;set to two player
    LDA #2
    STA global_numPlayers       ; Store this in our number of players registers
.end:
    RTS
    
;
; Prints "GAME OVER" To the center of the screen
; Prints the score.
; If relevant, prints the player that won.
;
menu_gameover: SUBROUTINE      
    ; Print GAME OVER
    PRINT_STR global_gameover_str, $e2

    ; Print the score
    PRINT_STR score_str, $10e

    ; Print the score as a Character representation
    ; Just use the array of digits to output it.
    ; Number display codes start at $30, end at $39
    LDX #$02                    ; Loop 3 times. (1 for each digit)
.print_digits:
    CLC                         ; Make sure we start by clearing our carry bit.
    LDA score_p1_digits,X       ; Load this digit
    ADC #$30                    ; Add $30 to make it a display code
    STA SCREEN_RAM+$115,X       ; Print to Screen

    DEX                         ; Loop Decrement
    BPL .print_digits           ; Loopyness

    ; Check if we're printing a winner.
    LDA global_numPlayers       ; Load number of players
    CMP #$2                     ; If there are not 2
    BNE .multiplayer_end        ; Skip printing the winner.

    ; Check if it's a tie.
    LDA global_gameState        ; Load state
    CMP #$4                     ; Compare to value for tie game
    BNE .not_tie                ; If not a tie, print winner.

    ; If so, print the "TIE GAME" string.
    PRINT_STR global_tie_str, $13B

    JMP .multiplayer_end

; Print who won.
.not_tie:
    ; Print "PLAYER   WINS"
    PRINT_STR global_playerWin_str, $138
    
    ; Print the number of the player who wins inside that string.
    LDA global_gameState        ; 2 = p1 wins. 3 = p2 wins.
    ADC #$2E                    ; Turn it into a character code.
    STA SCREEN_RAM+$13f         ; Print to screen.

.multiplayer_end:
    ; Print restart instructions
    PRINT_STR global_restart_str, $179
.end:
    RTS
    
