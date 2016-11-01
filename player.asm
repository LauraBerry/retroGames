;
; Pompeii II
; Player movement manager
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
; 
; Provides methods to move the player around the screen.
;

;
; A function called every tick.
; Schedules when the player is allowed to move again.
;
player_sched:
    LDA player_move_countdown      ; Load our countdown
    BNE player_sched_end           ; If we're not scheduled to change phase, decrement and return.

    JSR player_move                ; Otherwise, Change the phase
    LDA #PLAYER_MOVE_INTERVAL      ; Grab our phase change
    STA player_move_countdown      ; Set it as our new countdown

player_sched_end:
    DEC player_move_countdown      ; Decrement our countdown to the next phase change
    RTS

;
; Read user input
; Move the player(s) one square based on input
;
player_move:
    ; TODO: This.
    RTS
