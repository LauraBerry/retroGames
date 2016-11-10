;
; VIC20 Test Program 6
; Lava Generator
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
;
; Generates a random pattern of lava.
; Random numbers generated using a 16 bit LCG. If bytes are above a threshold, the tile is lava.
;
; This contains a function that is meant to be called by the tick() function every update.
;

;
; A function called every tick.
; Schedules when we're going to draw the next lava pattern.
; This scheduler doesn't reset the counter after we've run the function.
;
lava_generate_sched: SUBROUTINE
    LDA lava_next_generation    ; Load our countdown
    BNE .end                    ; If we're not scheduled to generate lava, decrement and return.

    JSR lava_generate           ; Otherwise, generate the lava.

.end:
    DEC lava_next_generation    ; Decrement our countdown.
    RTS

;
; Generates a brand new pattern of lava on the screen using the LCG
;
lava_generate: SUBROUTINE
    LDX #0                              ; Loop Index
.mainLoop:                              ; This loop fills each character with lava (or not lava)
    JSR lava_lcg                        ; Generate the next random number

    ; First half of the screen.
    LDA lava_lcg_data                   ; Load the value of the LCG Data
    CMP lava_threshold                  ; Compare the value to the lava threshold
    BCS .isLava1                        ; If random number >= lava threshold, it's lava.
    LDA #LAVA_SAFE_CHAR                 ; Else, we're a normal tile
    JMP .writeTile1
.isLava1:
    LDA #LAVA_DANGER_CHAR               ; Lava tile!
.writeTile1:
    STA SCREEN_RAM+LAVA_START_OFFSET,X  ; Print that char to the screen

    ; All lava is created as black.
    LDA phase_lavaColors
    STA SCREEN_COLOR_RAM+LAVA_START_OFFSET,X

    ; This does stuff for the second half of the screen.
    TXA                                 ; Transfer loop counter to A for compare
    CMP #LAVA_SCREEN2_SIZE              ; Because we have this many characters in the latter half of the screen.
    BCS .end                            ; So if we've already written that many, don't outstep the screen buffer.

    LDA lava_lcg_data+1                 ; Load the second byte of the random number
    CMP lava_threshold                  ; Compare the value to the lava threshold
    BCS .isLava2                        ; If random number >= lava thresh, it's lava.
    LDA #LAVA_SAFE_CHAR                 ; Else, we're a normal tile
    JMP .writeTile2                     ; Run to the end of the screen.
.isLava2:
    LDA #LAVA_DANGER_CHAR               ; Lava tile!
.writeTile2:
    STA SCREEN_RAM+LAVA_SCREEN_OFFSET,X ; Print that char to the screen

    ; All lava is created as black.
    LDA phase_lavaColors
    STA SCREEN_COLOR_RAM+LAVA_SCREEN_OFFSET,X


.end:               ; Looping things.
    INX             ; Decrement Loop Counter
    BNE .mainLoop   ; Iterate!

    RTS

;
; Linear Congruential Generator for Random Numbers.
; lava_lcg_data holds the 16 bit random number
;
; Precondition: lava_lcg_data holds a 16 bit number. (The seed)
; Postcondition: lava_lcg_data = (33 * lava_lcg_data) + 1 % 2^16
;
; Preserves X register. Wipes away others.
:
lava_lcg: SUBROUTINE
    STX lava_lcg_reg_store  ; Store our X
    LDA lava_lcg_data       ; Save the high byte
    STA lava_lcg_tmp_data   ; (In the temp place)
    LDA lava_lcg_data+1     ; Save the low byte
    STA lava_lcg_tmp_data+1 ; (In the temp place)

    ; Multiply by 32 by left shifting.
    CLC                     ; Clean this filth.
    LDX #5                  ; 32 = 2^5. 5 left shifts.
.shift:             ; Do our shifts through the carry (5 times)
    ROL lava_lcg_data+1     ; Left shift low bits
    ROL lava_lcg_data       ; Left Shift the carry into high bits.
    CLC                     ; Discard the highest bit we shift out.
    DEX                     ; Loop index decrement
    BPL .shift      ; Loopishness

    ; To multiply by 33, add the original value again.
    LDA lava_lcg_data+1     ; Get the new low bytes
    ADC lava_lcg_tmp_data+1 ; Add the old low bytes
    STA lava_lcg_data+1     ; Store the low byte back
    LDA lava_lcg_data       ; Load the high byte
    ADC lava_lcg_tmp_data   ; Add the old high bytes (also adds the carry bit.)
    STA lava_lcg_data       ; Store the high bytes back

    ; Increment the values. If there's overflow, carry it over.
    LDA lava_lcg_data+1     ; Grab the low byte
    ADC #LAVA_LCG_CONST     ; Add c
    STA lava_lcg_data+1     ; Store it back
    LDA lava_lcg_data       ; Load high byte
    ADC #0                  ; Add carry to it.

    CLC                     ; Clear our carry
    LDX lava_lcg_reg_store  ; Restore our X
    RTS                     ; Return to Sender

