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
score_init:
    ; Print score string
    LDX #$06                ; 'SCORE: " is 7 characters
score_print:
    LDA score_str,X         ; Location of SCORE string.
    STA SCREEN_RAM,X        ; Print that char to the screen
    LDA #$0                 ; Color Black
    STA SCREEN_COLOR_RAM,X  ; Set the color
    DEX                     ; Decrement Loop Counter
    BPL score_print         ; Iterate!
    RTS

;
; Updates the score on the top.
;
score_update:                   ; This code is run over and over to update the score displayed.
    LDA score_p1                ; Grab our score
    JSR score_getDigits         ; Subroutine that fills the digits array in memory

    ; Print the number as a Character representation
    ; Just use the array of digits to output it.
    ; Number display codes start at $30, end at $39
    LDX #$02                    ; Loop 3 times. (1 for each digit)
score_print_digits:
    CLC                         ; Make sure we start by clearing our carry bit.
    LDA score_p1_digits,X       ; Load this digit
    ADC #$30                    ; Add $30 to make it a display code
    STA SCREEN_RAM+$7,X         ; Print to Screen

    ; TODO: Might not need to set color every time we do this.
    LDA #$0                     ; Color Black
    STA SCREEN_COLOR_RAM+$7,X   ; Set the color

    DEX                         ; Loop Decrement
    BPL score_print_digits      ; Loopyness

    RTS

;
; Takes the value of A, and spits out decimal digits into the array 'score_p1_digits'
;
score_getDigits:
    LDX #0                  ; Start by zeroing out our digits.
    STX score_p1_digits
    STX score_p1_digits+1
    STX score_p1_digits+2

score_getDig_hunds:
    CLC
    CMP #100                ; Is our value >= 100?
    BCC score_getDig_tens   ; If not, check the tens
    SBC #100                ; If so, subtract 100
    INC score_p1_digits     ; And increment the hundreds place.
    JMP score_getDig_hunds  ; And check again for the hundreds

score_getDig_tens:
    CLC
    CMP #10                 ; Is our value >= 10?
    BCC score_getDig_ones   ; If not, check the hundreds
    SBC #10                 ; If so, subtract 10
    INC score_p1_digits+1   ; And increment the tens place.
    JMP score_getDig_tens   ; And check again for the tens

score_getDig_ones:
    STA score_p1_digits+2   ; The remainder is our ones place.
    INC score_p1            ; Update the score every tick. TODO: Remove this obviously.
    RTS                     ; We're done. Return to caller.
