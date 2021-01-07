osc_170070038.bin:	osc_170070038.out
		./hex2000 -boot -b -o osc_170070038.bin osc_170070038.out

osc_170070038.out:	osc_170070038.obj regdefs.obj
		./lnk2000 -o osc_170070038.out --entry_point=MAIN ttest.cmd \
		osc_170070038.obj \
		regdefs.obj

osc_170070038.obj:	osc_170070038.asm
		./asm2000 -v28 osc_170070038.asm

regdefs.obj:	regdefs.asm
		./asm2000 -v28 regdefs.asm

clean:		
		rm -f *.out *.obj *.bin
