;
; Pompeii II
; SFX Functions
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
; 
; This is where the state of each of the speakers is changed
;

sfx_mute_sched:
    LDA sfx_warningCount        ; Load our countdown
    BNE sfx_mute_sched_end ; If we're not scheduled to generate lava, decrement and return.

    JSR sfx_squelch           ; Otherwise, generate the lava.

sfx_mute_sched_end:
    DEC sfx_warningCount    ; Decrement our countdown.
    RTS

sfx_volume:			; Turn the volume up
    LDY #15
    STY SFX_VOLUME

sfx_squelch:			; This stops the rumble tone
    LDY #SFX_QUIET
    STY SFX_NOISE
    RTS

sfx_rumble:			; This is used to handle the audio queue that accompanies a warning state
;    LDA global_lavaState	; Load current lava state
;    CMP #1			; Check to see if the lava state is yellow (warning)
;    BNE sfx_rumbleEnd		; If not yellow, reset counter and return


    ; Load tone and countdown
    LDA #SFX_INTERVAL
    STA sfx_warningCount

    LDY #SFX_RUMBLE		; Load the rumble tone
    STY SFX_NOISE		; Store tone in the Noise speaker register

;    LDA sfx_warningCount	; Load the rubble countdown
;    BNE sfx_rumbleEnd		; If the rumble continues, decrement and return
;
;sfx_rumble_counterUpdate:
;    LDX #SFX_INTERVAL		; Load a fresh counter value
;    STX sfx_warningCount	; Reset the counter value

sfx_rumbleEnd:
;    BEQ sfx_squelch		; If sfx_count is zero, stop rumbling
;    DEC sfx_warningCount	; Decrement the warning counter
    RTS
