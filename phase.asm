;
; Pompeii II
; Lava Phase Manager
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
;
; Keeps track of the lava's state
;

;
; A function called every tick.
; Schedules when we change the lava phase
;
phase_sched: SUBROUTINE
    LDA phase_change_countdown      ; Load our countdown
    BNE .end                        ; If we're not scheduled to change phase, decrement and return.

    JSR phase_change                ; Otherwise, Change the phase
    LDA #PHASE_INTERVAL             ; Grab our phase change
    STA phase_change_countdown      ; Set it as our new countdown

.end:
    DEC phase_change_countdown      ; Decrement our countdown to the next phase change
    RTS

;
; Checks what the current state is, changes accordingly.
;
phase_change: SUBROUTINE
    INC global_lavaState            ; Increment the lava state.

    ; If the lava state is > 2, set it to zero.
    LDA global_lavaState
    CMP #3
    BNE .updateColor
    LDA #0
    STA global_lavaState

    LDA #1                          ; Schedule lava generation for next tick.
    STA lava_next_generation        ; We do this because we don't want to clear the screen and generate lava at the same time. Looks weird.
    INC score_p1                    ; Test by updating the score every tick. TODO: Remove this obviously.

    ; Change the lava color
.updateColor:
    LDX global_lavaState            ; Load the lava's state into X
    LDY phase_lavaColors,X          ; Get the color value for this state by indexing into a color array
    JSR phase_change_lava_color     ; Call the color change function, with the color in register Y.

    LDA global_lavaState            ; If we're in the warning state, beep.
    CMP #1
    BNE .end
    JSR sfx_rumble                  ; Otherwise, Change the phase
.end:
    RTS

;
; Change the color of each lava tile.
; Register Y contains the color we're writing
;
phase_change_lava_color: SUBROUTINE
    ; First, if the players are standing on lava tiles, update their colors.
    LDA player1_underTile           ; Get the tile P1 is on
    CMP #LAVA_DANGER_CHAR           ; Compare it to our lava character
    BNE .player2                    ; If they match,
    STY player1_underTile_color     ; Update the color (new color stored in Y)
.player2:                           ; Do the same for P2.
    LDA player2_underTile
    CMP #LAVA_DANGER_CHAR
    BNE .colorGameboard
    STY player2_underTile_color

.colorGameboard:                        ; End of player's undertile update stuff.
    LDX #0                              ; Loop Index
.loop:                                  ; This loop fills each character with lava (or not lava)
    ; First half of the screen.
    ; Only recolor lava tiles
    LDA SCREEN_RAM+LAVA_START_OFFSET,X  ; Load char value
    CMP #LAVA_DANGER_CHAR               ; Is it a lava tile?
    BNE .skip_colorchange               ; If not, skip the color change.

    TYA                                 ; Color is in Y. Store it.
    STA SCREEN_COLOR_RAM+LAVA_START_OFFSET,X

.skip_colorchange:
    ; This does stuff for the second half of the screen.
    TXA                                 ; Transfer loop counter to A for compare
    CMP #LAVA_SCREEN2_SIZE              ; Because we have this many characters in the latter half of the screen.
    BCS .end                            ; So if we've already written that many, don't outstep the screen buffer.

    ; Only recolor lava tiles
    LDA SCREEN_RAM+LAVA_SCREEN_OFFSET,X ; Load char value
    CMP #LAVA_DANGER_CHAR               ; Is it a lava tile?
    BNE .end                            ; If not, skip the color change.

    TYA                                 ; Color is in Y. Store it.
    STA SCREEN_COLOR_RAM+LAVA_SCREEN_OFFSET,X

.end:                                   ; Looping things.
    INX                                 ; Decrement Loop Counter
    BNE .loop    ; Iterate!
    RTS

