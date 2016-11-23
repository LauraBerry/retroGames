;
; Pompeii II
; SFX Functions
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
;
; This is where the state of each of the speakers is changed
;

;
; A function called every tick.
; Schedules when we next mute the sound.
;
sfx_mute_sched: SUBROUTINE
    LDA sfx_warningCount    ; Load our countdown
    BNE .end                ; If we're not scheduled to generate lava, decrement and return.

    JSR sfx_squelch         ; Otherwise, generate the lava.

.end:
    DEC sfx_warningCount    ; Decrement our countdown.
    RTS

; Turns the volume up
sfx_volume: SUBROUTINE      ; Turn the volume up
    LDY #15
    STY SFX_VOLUME
    RTS

; Mutes sound.
sfx_squelch: SUBROUTINE
    LDY #SFX_QUIET
    STY SFX_NOISE
    RTS

; This is used to handle the audio queue that accompanies a warning state
sfx_rumble: SUBROUTINE
    ; Load tone and countdown
    LDA #SFX_INTERVAL
    STA sfx_warningCount

    LDY #SFX_RUMBLE     ; Load the rumble tone
    STY SFX_NOISE       ; Store tone in the Noise speaker register

;    LDA sfx_warningCount   ; Load the rubble countdown
;    BNE .end       ; If the rumble continues, decrement and return
;
;sfx_rumble_counterUpdate:
;    LDX #SFX_INTERVAL      ; Load a fresh counter value
;    STX sfx_warningCount   ; Reset the counter value

.end:
;    BEQ sfx_squelch        ; If sfx_count is zero, stop rumbling
;    DEC sfx_warningCount   ; Decrement the warning counter
    RTS

; This is the routine that gets called to play the background music
sfx_jukebox:
    LDY sfx_theme_timing,sfx_current_note     ; Load current note duration
    LDX sfx_current_tick                      ; Load current count
    INX
    STX sfx_current_tick
    CPY sfx_current_tick                      ; Compare current timer with note duration
    BNE .sfx_jukebox_end                      ; End music
    LDX SFX_QUIET                             ; Load X with 0
    STX sfx_current_tick                      ; Reset timer
    LDY sfx_current_note                      ; Load Y with current note index
    INY                                       ; Increment note index
    CPY #19                                   ; Compare Y with total number of notes
    BNE .sfx_jukebox_change
    STY SFX_QUIET                             ; Reset note index
.sfx_jukebox_change:
    STY sfx_current_note                      ; Store note index
    LDA sfx_theme_notes,Y                     ; Load A with current note value
    STA SFX_LOWSOUND                          ; Store note value in the low speaker register
.sfx_jukebox_end:
    RTS

    

