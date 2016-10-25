; ************* Program Constants ****************
CLRSCN  = $e55f
COLORMAP = $900f		  ;background color
AUXCOLOR = $9600		  ;aux color
RDTIM = $FFDE             ; Read Clock Kernel Method

; ************* Assembly Code ***************

;DASM VIC20 BASIC stub --------------------------------------|
          processor 6502
          org 4097		   	;4097 ; start of program area

;labels
chrout  = $ffd2

basicStub: 
		dc.w basicEnd		; 4 byte pointer to next line of basic
		dc.w 2013		; 4 byte (can be any number for the most part)
		hex  9e			; 1 byte Basic token for SYS
		hex  20			; ascii for space = 32
		hex  34 31 31 30	; hex for asci 4110
		hex 00
basicEnd:	hex 00 00        	; The next BASIC line would start here

;End of DASM VIC20 BASIC stub ---------------------------------|

start:
	LDA 00
	STA game_state			;initalize game_state to zero (game not over)
	STA color_value			;initalize screen color value to black
	STA loop_var
	STA COLORMAP
	STA AUXCOLOR
	JSR RDTIM     			 ;busy loop to make the program wait 3 seconds                     
	JSR delay
gameloop:
	LDA color_value			;write what ever is in to COLORMAP and AUXCOLOR			                     
	JSR delay_3_sec			;busy loop to make the program wait 3 seconds 
	LDA loop_var
	CMP #00
	BNE yellow					;if A!=0 move to next color
	LDA #0						;make screen black
	STA color_value
	LDA #01
	STA loop_var

	LDA game_state
	CMP #01
	BNE gameloop
	JMP finish

;make screen yellow	
yellow:						
	LDA loop_var
	CMP #01
	BNE red						;if A!= 1 move to next color
	LDA #07
	STA color_value
	LDA #02
	STA loop_var
	jmp gameloop
;make screen red	
red:							
	LDA #02
	STA color_value
	LDA #0						;re-set X to 0 so on next loop screen will go black.
	STA loop_var
	jmp gameloop


finish:

delay:
    JSR RDTIM               ; Read the time
    ADC #10					; add 10
    STA next_inc      		; Put it in memory
wait_loop:                  ; This is weird and I'm not sure it's totally uniform
    JSR RDTIM               ; Read the system timer
    CMP next_inc      		; Check the time against our stored value
    BNE wait_loop           ; if time != next_increment, loop
    RTS
	
delay_3_sec:
    JSR RDTIM               ; Read the time
    ADC #$AA				; wait 3 seconds
    STA next_inc      		; Put it in memory
_wait_loop:                  ; This is weird and I'm not sure it's totally uniform
    JSR RDTIM               ; Read the system timer
    CMP next_inc      		; Check the time against our stored value
    BNE _wait_loop           ; if time != next_increment, loop
    RTS
;**************** DATA Section ****************************
next_inc: byte 0 

color_value: byte 0				;0==black, 7== yellow, 2== red

loop_var: byte 0				;0 == black, 1== yellow, 2== red

touched_lava: byte 0		;0== no lava touched, 1== lava touched

game_state: byte 0