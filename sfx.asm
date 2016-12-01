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
    LDA phase_interval      ; Load the phase interval.
    LSR                     ; Goes for half the phase interval.
    STA sfx_warningCount

    LDY #SFX_RUMBLE         ; Load the rumble tone
    STY SFX_NOISE           ; Store tone in the Noise speaker register
    RTS

; This is the routine that gets called to play the background music
sfx_jukebox: SUBROUTINE
    LDY sfx_theme_timing,sfx_current_note     ; Load Y as current note duration
    LDX sfx_current_tick                      ; Load X as current count
    INX                                       ; Increment tick count
    STX sfx_current_tick                      ; Update tick counter
    CPY sfx_current_tick                      ; Compare current tick count with note duration
    BNE .sfx_jukebox_end                      ; End music if timer is not finished
    LDX #SFX_QUIET                            ; Load X with 0
    STX sfx_current_tick                      ; Reset timer to 0
    LDX sfx_current_note                      ; Load Y with current note index
    INX                                       ; Increment note index
    CPX #19                                   ; Compare Y with total number of notes
    BNE .sfx_jukebox_change
    LDX #SFX_QUIET                            ; Load X with 0
.sfx_jukebox_change:
    STX sfx_current_note                      ; Store note index
    LDA sfx_theme_notes,X                     ; Load A with current note value
    STA SFX_LOWSOUND                          ; Store note value in the low speaker register
.sfx_jukebox_end:
    RTS

; Function that stops the music 
sfx_stop_noise: SUBROUTINE
    LDX #SFX_QUIET
    STX SFX_LOWSOUND
    STX SFX_NOISE
    RTS
