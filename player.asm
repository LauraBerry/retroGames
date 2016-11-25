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
; Get the keyboard input.
;
move_players: SUBROUTINE
    LDA KEYPRESS            ;load input from keyboard
    CMP #KEY_NONE           ;see if no key is pressed
    BEQ .end                ;if no key is pressed quit out
    LDX KEYBUFFERCOUNTER    ;see how many keys are in buffer

.playerMove:
    ; Check player 1's movements
    ; TODO: Use joystick for some movements.
    CMP #P1_KEY_LEFT
    BNE .checkp1Right       ; If they're not holding the button, continue
    DEC player1_x           ; Move.
    JMP .player_buffer      ; Go to next key.
.checkp1Right:
    CMP #P1_KEY_RIGHT
    BNE .checkp1Up
    INC player1_x           ; Move.
    JMP .player_buffer      ; Go to next key.
.checkp1Up:
    CMP #P1_KEY_UP
    BNE .checkp1Down
    DEC player1_y           ; Move.
    JMP .player_buffer      ; Go to next key.
.checkp1Down:
    CMP #P1_KEY_DOWN
    BNE .check_p2
    INC player1_y           ; Move.
    JMP .player_buffer      ; Go to next key.

.check_p2:                  ; Check if it's a 2p game.
    LDA global_numPlayers   ; Load number of players
    CMP #2                  ; Is it 2p?
    BNE .player_buffer      ; If not, end.

    ; Check player 2's movements
.checkp2Left:
    CMP #P2_KEY_LEFT
    BNE .checkp2Right       ; If they're not holding the button, continue
    DEC player2_x           ; Move.
    JMP .player_buffer      ; Go to next key.
.checkp2Right:
    CMP #P2_KEY_RIGHT
    BNE .checkp2Up
    INC player2_x           ; Move.
    JMP .player_buffer      ; Go to next key.
.checkp2Up:
    CMP #P2_KEY_UP
    BNE .checkp2Down
    DEC player2_y           ; Move.
    JMP .player_buffer      ; Go to next key.
.checkp2Down:
    CMP #P2_KEY_DOWN
    BNE .player_buffer
    INC player2_y           ; Move.
    JMP .player_buffer      ; Go to next key.

.player_buffer:
    CPX #00
    BEQ .end                ;if no more keys in buffer branch
    DEX                     ;decrement buffer
    LDA KEYBOARDBUFFER,x    ;load key from buffer
    JMP .playerMove         ;check for movement

.end:
    LDY #$00
    STY KEYBUFFERCOUNTER    ;reset the keyboard buffer
    RTS
