;
; VIC20 Test Program 6
; Color Chooser 
; (C) 2016 by Konrad Aust, Laura Berry, Andrew Lata, Yue Chen
;
; 
;
;***********************program constants ************************
COLORMAP = $900f		  ;background color
AUXCOLOR = $9600		  ;aux color

;*************************assembly code ********************
colorChoser_start:
	LDA global_lavaState						;read value in lavaState
	CMP #00										;is the lavaState in safe mode
	BNE colorChoser_warningColor				;if not jump to warning mode code
	STA colorChoser_lcg_colorValue				;store 0 into color value for black color
	LDA #01									
	STA global_lavaState						;set lavaState to warning mode
	RTS											;return(?)
colorChoser_warningColor:
	CMP #01										;is lavaState in warning mode:						
	BNE colorChoser_dangerZone					;if not jump to danger mode code
	LDA #07										
	STA colorChoser_lcg_colorValue				;store 7 into color value for yellow color
	LDA #02
	STA global_lavaState						;store 2 into lava state to change it to danger mode
	RTS
colorChoser_dangerZone:
	LDA #02
	STA colorChoser_lcg_colorValue				;stored 2 into color value for a red color
	LDA #00
	STA global_lavaState						;re-set lava state to safe mode
	RTS
; Data file. It sits in memory after the code, before the font.
    include "data.asm"