;
; VIC20 Test Program 6
; Score Tracker
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
;
; This program draws the player's score on the top of the screen.
; A function to update the drawn score is also included.
;

;
; Prints "SCORE: " string for player(s)
;
score_init: SUBROUTINE
    ; Print score string
    LDX #$06                ; 'SCORE: " is 7 characters
.print:
    LDA score_str,X         ; Location of SCORE string.
    STA SCREEN_RAM,X        ; Print that char to the screen
    LDA #$1                 ; Color Black
    STA SCREEN_COLOR_RAM,X  ; Set the color
    DEX                     ; Decrement Loop Counter
    BPL .print              ; Iterate!
    RTS

;
; Updates the score on the top.
;
score_update: SUBROUTINE        ; This code is run over and over to update the score displayed.
    LDA score_p1                ; Grab our score
    JSR score_getDigits         ; Subroutine that fills the digits array in memory

    ; Print the number as a Character representation
    ; Just use the array of digits to output it.
    ; Number display codes start at $30, end at $39
    LDX #$02                    ; Loop 3 times. (1 for each digit)
.print_digits:
    CLC                         ; Make sure we start by clearing our carry bit.
    LDA score_p1_digits,X       ; Load this digit
    ADC #$30                    ; Add $30 to make it a display code
    STA SCREEN_RAM+$7,X         ; Print to Screen

    ; TODO: Might not need to set color every time we do this.
    LDA #$1                     ; Color Black
    STA SCREEN_COLOR_RAM+$7,X   ; Set the color

    DEX                         ; Loop Decrement
    BPL .print_digits           ; Loopyness

    JSR scale_difficulty        ; Change the difficulty to match the new score.

    RTS

;
; Takes the value of A, and spits out decimal digits into the array 'score_p1_digits'
;
score_getDigits: SUBROUTINE
    LDX #0                  ; Start by zeroing out our digits.
    STX score_p1_digits
    STX score_p1_digits+1
    STX score_p1_digits+2

.hundreds:
    CLC
    CMP #100                ; Is our value >= 100?
    BCC .tens               ; If not, check the tens
    SBC #100                ; If so, subtract 100
    INC score_p1_digits     ; And increment the hundreds place.
    JMP .hundreds           ; And check again for the hundreds

.tens:
    CLC
    CMP #10                 ; Is our value >= 10?
    BCC .ones               ; If not, check the hundreds
    SBC #10                 ; If so, subtract 10
    INC score_p1_digits+1   ; And increment the tens place.
    JMP .tens               ; And check again for the tens

.ones:
    STA score_p1_digits+2   ; The remainder is our ones place.
    RTS                     ; We're done. Return to caller.

;
; Sets the difficulty based on the current score.
;
scale_difficulty: SUBROUTINE
    ; Change background color
    ; 8-15 are the background colors we want to use.
    LDA score_p1                    ; Load player score.
    LSR                             ; Divide by 8.
    LSR
    LSR
    AND #$F                         ; Only use low bits.
    ORA #8                          ; Make sure bit 3 is set.
    STA BACKGROUND_COLOR            ; Store to background color.



    ; Set the lava threshold. A lower number means more tiles are lava.
    LDA score_p1                    ; Load Score
    LSR                             ; Divide by 4
    LSR
    STA lava_threshold              ; Store this in lava_threshold
    LDA #LAVA_DEFAULT_THRESHOLD     ; Load up the default threshold
    SBC lava_threshold              ; Threshold = default - (4 * score)
    STA lava_threshold              ; Store final value for threshold

    ; Set the phase interval. This gets lower as the player's score goes up.
    LDA score_p1
    LSR
    LSR
    LSR
    STA lava_phase_interval
    LDA #PHASE_DEFAULT_INTERVAL
    SBC lava_phase_interval
    STA lava_phase_interval

    RTS

