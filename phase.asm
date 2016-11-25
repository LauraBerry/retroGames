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
    BNE .decrement                  ; If we're not scheduled to change phase, decrement and return.

    JSR phase_change                ; Otherwise, Change the phase
    LDA #PHASE_INTERVAL             ; Grab our phase change
    STA phase_change_countdown      ; Set it as our new countdown

.decrement:
    DEC phase_change_countdown      ; Decrement our countdown to the next phase change

    ; Check if we're in the danger state.
    LDA global_lavaState
    CMP #2
    BNE .end

    ; Check if P1 has died.
    LDA player1_underTile
    CMP #LAVA_DANGER_CHAR
    BNE .check_p2
    LDA #3
    STA global_gameState

.check_p2:                  ; Check if it's a 2p game.
    LDA global_numPlayers   ; Load number of players
    CMP #2                  ; Is it 2p?
    BNE .end                ; If not, end.

    ; Otherwise, check if P2 has died.
    LDA player2_underTile
    CMP #LAVA_DANGER_CHAR
    BNE .end
    LDA #2
    STA global_gameState

.end:
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
    LDA #0                          ; Set the lava state to zero
    STA global_lavaState            ; Store it

    LDA #1                          ; Schedule lava generation for next tick.
    STA lava_next_generation        ; We do this because we don't want to clear the screen and generate lava at the same time. Looks weird.

    ; Change the lava color
.updateColor:
    ; New lava color updating code.
    LDA #$0F                        ; Load bitmask
    AND SCREEN_AUX_COLOR            ; Clear the aux color we're using for the screen
    STA SCREEN_AUX_COLOR
    
    LDX global_lavaState            ; Load the lavastate into X
    LDA phase_lavaColors,X          ; Get the color value for this state by indexing into a color array
    ASL                             ; Shift into the high bits.
    ASL
    ASL
    ASL
    ORA SCREEN_AUX_COLOR            ; Store it in the aux color. (Use high bits.)
    STA SCREEN_AUX_COLOR

    LDA global_lavaState            ; If we're in the warning state, beep.
    CMP #1
    BNE .end
    JSR sfx_rumble                  ; Otherwise, Change the phase
.end:
    RTS

