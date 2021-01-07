# Makefile
all:		inv_170070038.bin inv_170070038.sym inv_170070038.lst

inv_170070038.bin:	inv_170070038.out
		./hex2000 -boot -b -o inv_170070038.bin inv_170070038.out

inv_170070038.out:	inv_170070038.obj regdefs.obj
		./lnk2000 -o inv_170070038.out --entry_point=MAIN cla6.cmd \
		inv_170070038.obj \
		regdefs.obj

inv_170070038.sym:	inv_170070038.out
		./nm2000 -o inv_170070038.sym -a inv_170070038.out

inv_170070038.lst:	inv_170070038.out
		./dis2000 -1 --c2000_format=28 inv_170070038.out > inv_170070038.lst

inv_170070038.obj:	inv_170070038.asm
		./asm2000 -v28 --cla_support=cla1 inv_170070038.asm

regdefs.obj:	regdefs.asm
		./asm2000 -v28 regdefs.asm

clean:
		rm -f *.out *.obj *.bin *.sym *.lst
