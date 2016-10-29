#
# makefile
# konrad, 2016-10-15 01:39
# Builds the program.
# Clean removes the built files.
#
# IN_NAME specifies what file we're compiling
# OUT_NAME specifies what the output .prg is called.
#

IN_NAME=main
OUT_NAME=pompeii2
ASM=dasm

all:
	$(ASM) $(IN_NAME).asm -v2 -o$(OUT_NAME).prg # -l$(IN_NAME).lst -s$(IN_NAME).sym

clean:
	rm -f $(OUT_NAME).prg $(OUT_NAME).lst $(OUT_NAME).sym

# vim:ft=make
#
