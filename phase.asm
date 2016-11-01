
;
; A function called every tick.
; Schedules when we change the lava phase
;
phase_sched:
    LDA phase_change_countdown      ; Load our countdown
    BNE phase_sched_end             ; If we're not scheduled to change phase, decrement and return.

    JSR sfx_rumble                  ; Call function for checking game state and rumbling if appropriate
    JSR phase_change                ; Otherwise, Change the phase
    LDA #PHASE_INTERVAL             ; Grab our phase change
    STA phase_change_countdown      ; Set it as our new countdown

phase_sched_end:
    DEC phase_change_countdown      ; Decrement our countdown to the next phase change
    RTS

;
; Checks what the current state is, changes accordingly.
;
phase_change:						
    INC global_lavaState            ; Increment the lava state.

    ; If the lava state is > 2, set it to zero.
    LDA global_lavaState
    CMP #3
    BNE phase_change_updateColor
    LDA #0
    STA global_lavaState
    JSR lava_generate           ; Otherwise, generate the lava.

    ; Change the lava color
phase_change_updateColor:
    LDX global_lavaState            ; Load the lava's state into X
    LDY phase_lavaColors,X          ; Get the color value for this state by indexing into a color array
    JSR phase_change_lava_color     ; Call the color change function, with the color in register Y.
	RTS

;
; Change the color of each lava tile.
; Register Y contains the color we're writing
;
phase_change_lava_color:
    LDX #0                              ; Loop Index
phase_change_lava_color_loop:           ; This loop fills each character with lava (or not lava)
    ; First half of the screen.
    TYA
    STA SCREEN_COLOR_RAM+LAVA_START_OFFSET,X

    ; This does stuff for the second half of the screen.
    TXA                                 ; Transfer loop counter to A for compare
    CMP #LAVA_SCREEN2_SIZE              ; Because we have this many characters in the latter half of the screen.
    BCS change_lava_color_genLoop_end   ; So if we've already written that many, don't outstep the screen buffer.
    TYA
    STA SCREEN_COLOR_RAM+LAVA_SCREEN_OFFSET,X

change_lava_color_genLoop_end:          ; Looping things.
    INX                                 ; Decrement Loop Counter
    BNE phase_change_lava_color_loop    ; Iterate!
    RTS

