;
; Pompeii II
; SFX Functions
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
; 
; This is where the state of each of the speakers is changed
;


sfx_squelch:			; This quiets any possible sound
    LDY #SFX_QUIET
    STY SFX_LOWSOUND
    STY SFX_MIDSOUND
    STY SFX_NOISE
    RTS

sfx_rumble:			; This is used to handle the audio queue that accompanies a warning state
    LDY #SFX_RUMBLE		; Load the rumble tone
    STY SFX_NOISE		; Store tone in the Noise speaker register

    LDX sfx_warningCount	; Load the rubble countdown
    BNE sfx_rumbleEnd		; If the rumble continues, decrement and return

    LDX #SFX_INTERVAL		; Load a fresh counter value
    STX sfx_warningCount	; Reset the counter value

sfx_rumbleEnd:
    DEC sfx_warningCount	; Decrement the warning counter
    RTS
