;
; Pompeii II
; Assembler Macros
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
;
; We keep our assembler macro constants in here.
; This includes all constants that refer to zero page RAM.
;

; ************* Assembler Macro Constants ****************
CLRSCN  = $e55f                 ; clear screen kernel method
BACKGROUND_COLOR = $900f        ; Register that stores the border color for the VIC.
SCREEN_RAM = $1E00              ; This is the location of screen memory
SCREEN_COLOR_RAM = $9600        ; The location of screen color memory.
SCREEN_AUX_COLOR = $900E        ; Aux color. High bits are the color. Low bits are the volume.
JOYSTICK_1_DDR = $9113          ; Set this to zero to enable joystick input
JOYSTICK_2_DDR = $9122          ; Set this to zero to enable joystick input
JOYSTICK_1_IN = $9111           ; Read most bits of joystick input from here
JOYSTICK_2_IN = $9120           ; Read one more bit of joystick input from here.

MAIN_CHAR_PTR = $9005           ; This address determines where we look for character maps.
MAIN_CUSTOM_PTR = $FF           ; This points us to 7168 ($1c00) for our char map.

; Clock/timing stuff
MAIN_CLK = $A0                  ; Points to the memory map of the hardware clock. A0-A2 is the HW clock.
MAIN_TICKRATE = 2               ; Tick is called every MAIN_TICKRATE jiffies.

; Lava Stuff.
LAVA_LCG_MULT = 33              ; Multiplier for LCG
LAVA_LCG_CONST = 1              ; Addition constant for LCG
LAVA_LCG_SEED = 32000           ; Initial seed value for the LCG (Should be 16 bits)
LAVA_DANGER_CHAR = 27           ; Character 27 is a lava tile.
LAVA_SAFE_CHAR = 32             ; Character 32 is a space.
LAVA_COLOR = 2                  ; Lava is red
LAVA_START_OFFSET = 22          ; Generate lava at this offset so we have room on top for the player's score
LAVA_SCREEN_OFFSET = LAVA_START_OFFSET + $100 ; Used for generating lava on the latter half of the screen.
LAVA_SCREEN2_SIZE = $e4
LAVA_DEFAULT_THRESHOLD = 128

; Phase Stuff
PHASE_DEFAULT_INTERVAL = 50     ; The phase is changed after this number of ticks.

; Player Stuff
PLAYER_MOVE_INTERVAL = 2        ; The player is allowed to move with this many ticks in delay
PLAYER_CHAR_SAFE = $3e          ; Character code of player.
PLAYER_CHAR_DANGER = $3f        ; Character code of player.
KEYBOARDBUFFER = #$0277         ; keyboard buffer
KEYPRESS = #$00C5               ; read from here to get key press
KEYBUFFERCOUNTER = #$00C6       ; keyboard buffer counter
SCREEN0 = #SCREEN_RAM           ; start of SCREEN memory 7680
SCREEN1 = #SCREEN_RAM+176       ; start of second part of SCREEN memory 7856
SCREEN2 = #SCREEN_RAM+2*(176)   ; start of third part of SCREEN memory 8032
SCREEN_COLOR0 = #SCREEN_COLOR_RAM
SCREEN_COLOR1 = #SCREEN_COLOR_RAM+176
SCREEN_COLOR2 = #SCREEN_COLOR_RAM+2*(176)

P1_KEY_LEFT = 17
P1_KEY_RIGHT = 18
P1_KEY_UP = 9
P1_KEY_DOWN = 41
P2_KEY_LEFT = 20
P2_KEY_RIGHT = 21
P2_KEY_UP = 12
P2_KEY_DOWN = 44

KEY_1 = 0
KEY_2 = 56
KEY_NONE = 64
KEY_SPACE = 32

; SFX Stuff
SFX_RUMBLE = 135                ; A low C tone for the noise speaker for the warning state
SFX_QUIET = 0                   ; A constant used for quieting any speaker making noise
SFX_LOWSOUND = $900A            ; The low sound register
SFX_MIDSOUND = $900B            ; The mid sound register
SFX_NOISE = $900D               ; The noise sound register
SFX_VOLUME = $900E              ; Volume register

; ************* Assembler Macros ****************

    ; /////////////////////////////////////////////
    ; Player position wrapping function.
    ; Usage: player_wrap <player_num>
    MAC PLAYER_WRAP

    LDA player{1}_x         ; Test x location
    CMP #$15                ; Is it overflowing to the right?
    BNE .checkP{1}XLeft     ; If not, check next.

    LDA #-1                 ; If so, set it to leftmost.
    STA player{1}_x
    JMP .checkP{1}YTop      ; And start checking y values for p1.
.checkP{1}XLeft:
    CMP #$-2                ; Are we overflowing to the left?
    BNE .checkP{1}YTop      ; If not, check next.
    LDA #$14
    STA player{1}_x         ; And fall through to checking y.
.checkP{1}YTop:
    LDA player{1}_y
    CMP #$0                 ; Are we overflowing up top?
    BNE .checkP{1}YBot      ; If not, check next
    LDA #$16                ; If so, set to bottom.
    STA player{1}_y
    JMP .checkP{1}End
.checkP{1}YBot:
    CMP #$17                ; Are we overflowing on bottom?
    BNE .checkP{1}End       ; If not, check next
    LDA #$1                 ; If so, set to bottom.
    STA player{1}_y         ; And fall through to checking p2.
.checkP{1}End:

    ENDM

    ; /////////////////////////////////////////////
    ; Usage: player_print <player_num>
    ; y offset is moded with 7, and looped through to get the y offset
    ; The x offset is added to the y offset and store in X
    ; The y offset is reloaded into the Accumulator and divided by 8 to find the screen offset
    ; The character is printed to the right screen + offset
    MAC PLAYER_PRINT

    CLC
    LDA player{1}_y
    AND #$07                ; Mod 7
    TAX                     ; Save to X
    LDA #00
.p{1}_printLoop:            ; Loop to calculate the y offset
    CPX #00                 ; See if send of SCREEN
    BEQ .p{1}_print         ; Branch out
    ADC #$15                ; Add one row
    DEX                     ; Decrement x
    JMP .p{1}_printLoop
.p{1}_print:
    ADC player{1}_x         ; Add x offset
    TAX                     ; Save to x
    STX player{1}_offset    ; Save to offset
    LDA player{1}_y
    LSR                     ; Divide by 8
    LSR
    LSR
    CMP #0                  ;see if at SCREEN 0
    BEQ .p{1}_screen0
    CMP #01                 ;see if at screen 1
    BEQ .p{1}_screen1
    PLAYER_PRINT_CHAR {1},2 ; Screen region 2
    JMP .p{1}_end
.p{1}_screen0:
    PLAYER_PRINT_CHAR {1},0 ; Screen region 0
    JMP .p{1}_end
.p{1}_screen1:
    PLAYER_PRINT_CHAR {1},1 ; Screen region 1
.p{1}_end:
    ENDM

    ; /////////////////////////////////////////////
    ; Usage: player_print_char <player_num>,<screen_num>
    ; Assumes x contains the offset into the screen region.
    MAC PLAYER_PRINT_CHAR

    LDA SCREEN{2},x             ; Get the tile in the position that we'll put the player.
    STA player{1}_underTile     ; Save it to the player's underTile variable.

    CMP #LAVA_DANGER_CHAR
    BNE .next{1}_{2}
    LDA #PLAYER_CHAR_DANGER     ; Load the player's sprite.
    JMP .printChar{1}_{2}
.next{1}_{2}:
    LDA #PLAYER_CHAR_SAFE       ; Load the player's sprite.
.printChar{1}_{2}:
    STA SCREEN{2},x             ; Put it on the screen at the offset x.

    ; Store the color of the tile the player is stepping on
    LDA SCREEN_COLOR{2},X
    STA player{1}_underTile_color

    ; Write color into the square
    LDA player{1}_color
    ORA #8
    STA SCREEN_COLOR{2},X

    ENDM

    ; /////////////////////////////////////////////
    ; Usage: player_clear <player_num>
    ; Load the y offset into A
    ; Load calculate offset into x
    ; Divide A by 8 to get SCREEN number
    ; Check SCREEN number then print with offset in x
    MAC PLAYER_CLEAR
    LDA player{1}_y             ; Load player 1 y location
    LDX player{1}_offset        ; Load offset
    LSR                         ; Divide by 8
    LSR
    LSR
    CMP #0                      ; Check which screen region the player is in.
    BEQ .p{1}_screen0
    CMP #$01
    BEQ .p{1}_screen1
    PLAYER_CLEAR_CHAR {1},2     ; Screen region 2
    JMP .p{1}_end
.p{1}_screen0:
    PLAYER_CLEAR_CHAR {1},0     ; Screen region 0
    JMP .p{1}_end
.p{1}_screen1:
    PLAYER_CLEAR_CHAR {1},1     ; Screen region 1
.p{1}_end:
    ENDM

    ; /////////////////////////////////////////////
    ; Usage: player_clear_char <player_num>,<screen_num>
    ; Assumes x contains the offset into the screen region.
    MAC PLAYER_CLEAR_CHAR

    LDA player{1}_underTile         ; Get the tile underneath the player
    STA SCREEN{2},X                 ; Put it on the screen
    LDA player{1}_underTile_color   ; Do the same for the color
    STA SCREEN_COLOR{2},X           ; Put it on the screen.

    ENDM

    ; /////////////////////////////////////////////
    ; Usage: end_if_singleplayer
    ; Jumps to .end if we're playing a singleplayer game.
    MAC END_IF_SINGLEPLAYER

    LDA global_numPlayers
    CMP #2
    BEQ .p2_present
    RTS
.p2_present:

    ENDM

    ; /////////////////////////////////////////////
    ; Usage: PRINT_STR <string label>, <screen offset>
    ; Prints a null-terminated string to the screen, at an offset from the start of screen memory.
    MAC PRINT_STR

    LDX #0
.print_{1}:
    LDA {1},X        ; Location of string.
    CMP #0                      ; Check null terminator
    BEQ .print_{1}_end      ; If we're at the null terminator, exit.

    STA SCREEN_RAM+{2},X       ; Print that char to the screen
    LDA #$1                     ; Text Color
    STA SCREEN_COLOR_RAM+{2},X ; Set the color
    INX
    JMP .print_{1}          ; Iterate!
.print_{1}_end:

    ENDM

    ; /////////////////////////////////////////////
    ; Usage: PRINT_STR_COLOR <string label>, <screen offset>, <color>
    ; Prints a null-terminated string to the screen, at an offset from the start of screen memory.
    ; Same as above, but this lets you specify color
    MAC PRINT_STR_COLOR

    LDX #0
.print_{1}:
    LDA {1},X        ; Location of string.
    CMP #0                      ; Check null terminator
    BEQ .print_{1}_end      ; If we're at the null terminator, exit.

    STA SCREEN_RAM+{2},X       ; Print that char to the screen
    LDA #{3}                     ; Text Color
    STA SCREEN_COLOR_RAM+{2},X ; Set the color
    INX
    JMP .print_{1}          ; Iterate!
.print_{1}_end:

    ENDM
