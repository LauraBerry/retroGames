#
# makefile
# konrad, 2016-10-15 01:39
# Used to build the programs. Generates a symbol table and list file too.
# Clean removes the built files.
# change the FNAME variable for a different program name.
# if assembly file is "derp.asm" then FNAME=derp will work.
#

FNAME=main
ASM=dasm

all:
	$(ASM) $(FNAME).asm -v3 -o$(FNAME).prg # -l$(FNAME).lst -s$(FNAME).sym

clean:
	rm $(FNAME).prg $(FNAME).lst $(FNAME).sym

# vim:ft=make
#
