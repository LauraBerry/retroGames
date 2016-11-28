;
; Pompeii II
; Player movement manager
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
;
; Provides methods to move the player around the screen.
;

;
; A function called every tick.
; Schedules when the player is allowed to move again.
;
player_sched: SUBROUTINE
    LDA player_move_countdown       ; Load our countdown
    BNE .end                        ; If we're not scheduled to move players, decrement and return.

    JSR player_move                 ; Otherwise, Change the phase
    LDA #PLAYER_MOVE_INTERVAL       ; Grab our phase change
    STA player_move_countdown       ; Set it as our new countdown

.end:
    DEC player_move_countdown       ; Decrement our countdown to the next phase change
    RTS

;
; Move the player
; Move the player(s) one square based on their input
;
player_move:
    JSR player_clear        ; Erase the players from the board.
    JSR move_players        ; Move the players based on user input
    JSR movement_wrap       ; Wrap the players around if they're outstepping their x and y bounds.
    JSR player_print        ; Redraw the players
    RTS

;
; Clear both characters from the screen
;
player_clear: SUBROUTINE
    PLAYER_CLEAR 1  ; We have a macro for clearing each player.
    END_IF_SINGLEPLAYER
    PLAYER_CLEAR 2
    RTS

;
; Check if players have outstepped screen bounds.
; If they have, wrap them around to the other side of the screen.
;
movement_wrap: SUBROUTINE
    PLAYER_WRAP 1   ; We have a macro for doing movement wrapping based on player number.
    END_IF_SINGLEPLAYER
    PLAYER_WRAP 2
    RTS

;
; Prints both characters to the screen.
;
player_print: SUBROUTINE
    PLAYER_PRINT 1          ; We have a macro for this too.
    END_IF_SINGLEPLAYER
    PLAYER_PRINT 2
    RTS

;
; Enables joystick input
; Grabs the joystick input
; Disables joystick input so we can use the keyboard.
; Returns 5 bits corresponding to user input.
; <right>,<up>,<down>,<left>
;
get_joystick: SUBROUTINE
    LDY #0                  ; Enable input mode
    STY JOYSTICK_2_DDR      ; Store to joystick DDR 2.

    LDA JOYSTICK_1_IN       ; Load joystick input
    LSR                     ; Shift it over.
    EOR #$F                 ; Weird. 0 is pressed, 1 is not pressed. We need to invert.
    AND #$F                 ; Clear the high bits.
    CLC

    BIT JOYSTICK_2_IN       ; Test bit 7 of joystick 2's input.
    BMI .end                ; If it's not set, we're going right.
    CLC                     ; Clear carry bit
    ADC #$1                 ; Add 1 to show we're going right.

.end:
    LDY #$FF                ; Turn back to keyboard mode.
    STY JOYSTICK_2_DDR      ; Store value to joystick DDR 2
    RTS

;
; Get the keyboard input.
;
move_players: SUBROUTINE

.player1Move:
    LDA KEYPRESS            ;load input from keyboard
    CMP #KEY_NONE           ;see if no key is pressed
    BEQ .player2Move        ;if no key is pressed quit out
    ;LDX KEYBUFFERCOUNTER    ;see how many keys are in buffer

    ; Check player 1's movements
    CMP #P1_KEY_LEFT
    BNE .checkp1Right       ; If they're not holding the button, continue
    DEC player1_x           ; Move.
    JMP .player2Move        ; Go to player 2's input routine
.checkp1Right:
    CMP #P1_KEY_RIGHT
    BNE .checkp1Up
    INC player1_x           ; Move.
    JMP .player2Move        ; Go to player 2's input routine
.checkp1Up:
    CMP #P1_KEY_UP
    BNE .checkp1Down
    DEC player1_y           ; Move.
    JMP .player2Move        ; Go to player 2's input routine
.checkp1Down:
    CMP #P1_KEY_DOWN
    BNE .player2Move  
    INC player1_y           ; Move.
    JMP .player2Move        ; Go to player 2's input routine

.player2Move                ; Check if it's a 2p game.
    LDY global_numPlayers   ; Load number of players
    CPY #2                  ; Is it 2p?
    BNE .end                ; If not, end.

    JSR get_joystick        ; Get joystick input for P2
    TAY                     ; Put it in register Y

.checkp2Right:              ; Basically the same as above.
    TYA                     ; Input value stored in Y.
    AND #$1                 ; Test direction
    BEQ .checkp2Left        ; If not this direction, go to next direction
    INC player2_x           ; Move the player
    JMP .end                ; Exit input routine
.checkp2Left:
    TYA
    AND #$8
    BEQ .checkp2Up
    DEC player2_x
    JMP .end
.checkp2Up:
    TYA
    AND #$2
    BEQ .checkp2Down
    DEC player2_y
    JMP .end
.checkp2Down:
    TYA
    AND #$4
    BEQ .end
    INC player2_y

.end:
    LDY #$00
    STY KEYBUFFERCOUNTER    ;reset the keyboard buffer
    RTS
