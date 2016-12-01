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
player_move: SUBROUTINE
    JSR player_clear        ; Erase the players from the board.
    JSR move_players        ; Move the players based on user input
    JSR movement_wrap       ; Wrap the players around if they're outstepping their x and y bounds.
    JSR collision_detect    ; Detects collision between P1 and P2.
    JSR player_print        ; Redraw the players

.end:
    RTS

;
; Clear both characters from the screen
;
player_clear: SUBROUTINE
    PLAYER_CLEAR 1          ; We have a macro for clearing each player.
    END_IF_SINGLEPLAYER
    PLAYER_CLEAR 2
    RTS

;
; Check if players have outstepped screen bounds.
; If they have, wrap them around to the other side of the screen.
;
movement_wrap: SUBROUTINE
    PLAYER_WRAP 1           ; We have a macro for doing movement wrapping based on player number.
    END_IF_SINGLEPLAYER
    PLAYER_WRAP 2
    RTS

;
; Detects if 2 players are occupying the same space.
;
collision_detect: SUBROUTINE
    LDA player1_x   ; Load player1's x
    CMP player2_x   ; Compare to P2's x
    BNE .end        ; if they're different, no collisions.

    LDA player1_y   ; Load player1's y
    CMP player2_y   ; CMP to p2's y
    BNE .end        ; If they're different, no collisions.

    ; Otherwise, move one of them back to their original position.
    ; If p2 moved, move them back.
    ; Else, if p1 moved, move them back.
    ; Input seems nicer on keyboard. So I'm giving priority to P1 here.
    ; Interestingly, players can move through eachother.
    ; They just can't move into the same space.

    ; Check if P2 moved.
    LDA player2_x       ; Compare X coord.
    CMP player2_x_old
    BNE .p2moved
    LDA player2_y       ; Compare Y coord.
    CMP player2_y_old
    BNE .p2moved
    JMP .p2stationary   ; If neither differ, they didn't move.

.p2moved:
    LDA player2_x_old   ; Move P2 back.
    STA player2_x
    LDA player2_y_old
    STA player2_y

.p2stationary:
    LDA player1_x_old   ; Move P1 Back.
    STA player1_x
    LDA player1_y_old
    STA player1_y

.end:
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
    ; First, store the current X and Y values of both players.
    LDA player1_x
    STA player1_x_old
    LDA player1_y
    STA player1_y_old
    LDA player2_x
    STA player2_x_old
    LDA player2_y
    STA player2_y_old

.player1Move:
    LDA KEYPRESS            ;load input from keyboard
    CMP #KEY_NONE           ;see if no key is pressed
    BEQ .player2Move        ;if no key is pressed quit out
    ;LDX KEYBUFFERCOUNTER    ;see how many keys are in buffer

    ; Check player 1's movements
    CMP #KEY_A
    BNE .checkp1Right       ; If they're not holding the button, continue
    DEC player1_x           ; Move.
    JMP .player2Move        ; Go to player 2's input routine
.checkp1Right:
    CMP #KEY_D
    BNE .checkp1Up
    INC player1_x           ; Move.
    JMP .player2Move        ; Go to player 2's input routine
.checkp1Up:
    CMP #KEY_W
    BNE .checkp1Down
    DEC player1_y           ; Move.
    JMP .player2Move        ; Go to player 2's input routine
.checkp1Down:
    CMP #KEY_S
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
.checkp2Left:               ; Do the same for the other directions.
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
    STY KEYBUFFERCOUNTER    ; Reset the keyboard buffer
    RTS
