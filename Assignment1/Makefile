all:		170070038.bin 170070038.lst

170070038.bin:	170070038.out
		./hex2000 -boot -b -o 170070038.bin 170070038.out

170070038.lst:	170070038.out
		./dis2000 --all --c2000_format=28 170070038.out > 170070038.lst

170070038.out:	main.obj fn_170070038.obj
		./lnk2000 -o 170070038.out --entry_point=MAIN functions.cmd main.obj fn_170070038.obj

main.obj:	main.asm
		./asm2000 -v28 main.asm

fn_170070038.obj:	fn_170070038.asm
			./asm2000 -v28 fn_170070038.asm

clean:
		rm -f *.obj *.out *.bin *.lst
