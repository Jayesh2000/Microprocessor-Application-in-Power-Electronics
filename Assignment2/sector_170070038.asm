
	.def sector

	.data
VarA:	.word	0x0123			
VarB:	.word	0x0
VarC:	.word	0x0
VarD:	.word	0x0
VarE:	.word	0x0
Resu:	.word	0x0		
	.text

Case0:	movw	@Resu,#0			;000
	b	call2,UNC
	lretr

Case1:	movw	@Resu,#1			;001
	b	call2,UNC
	lretr

Case2:	movw	@Resu,#2			;010
	b	call2,UNC
	lretr

Case3:	movw	@Resu,#3			;011
	b	call2,UNC
	lretr

Case4:	movw	@Resu,#4			;100
	b	call2,UNC
	lretr

Case5:	movw	@Resu,#5			;101
	b	call2,UNC
	lretr

Case6:	cmp	@VarB,#0
	b	Case7,EQ
	b	call,UNC

Case7:	mov	@Resu,#7			;111
	b	call,UNC

vdgvqg:	movw	AH,@VarC
	cmp	AH,@VarD		;comparing vd^2 and (vd^2+vg^2)/4
	b	Case5,GT
	b	Case0,LEQ
	lretr

vdgvql:	movw	AH,@VarC
	cmp	AH,@VarD		;comparing vd^2 and (vd^2+vg^2)/4
	b	Case4,GEQ
	b	Case3,LT
	lretr

vdlvqg:	movw	AH,@VarC
	cmp	AH,@VarD		;comparing vd^2 and (vd^2+vg^2)/4
	b	Case1,GEQ
	b	Case0,LT
	lretr

vdlvql:	movw	AH,@VarC	
	cmp	AH,@VarD		;comparing vd^2 and (vd^2+vg^2)/4
	b	Case2,GT
	b	Case3,LEQ
	lretr
	
vdg:	cmp	@VarA,#0		;comparing vg and 0
	b	vdgvqg,GEQ
	b	vdgvql,LT
	lretr

vdl:	cmp	@VarA,#0		;comparing vg and 0
	b	vdlvqg,GT
	b	vdlvql,LEQ
	lretr

sector:
	movw	DP, #VarA			
	movw	AH, *XAR7++		;AH = vq
	movw	AL, *XAR7++		;AL = vd
	movw	@VarA, AH		;VarA = vq
	movw	@VarB,AL		;VarB = vd
	mov	T,@VarB
	mpy	ACC,T,@VarB
	movh	@VarC,ACC<<1		;VarC = VarB^2 = vd*vd
	mov	T,@VarA
	mpy	ACC,T,@VarA
	movh	@VarD,ACC<<1		;VarD = VarA^2 = vq*vq
	mov	AH,@VarC
	mov	AL,#0	
	sfr	ACC,#2
	mov	@VarE,AH		;VarE = VarC/4
	mov	AH,@VarD
	mov	AL,#0	
	sfr	ACC,#2
	mov	@VarD,AH		;AH = vq*vq/4
	add	AH,@VarE		;AH = AH + vd*vd/4 = (vq^2 + vd^2)/4 
	mov	@VarD,AH		;VarD = (vq^2 + vd^2)/4		
	cmp	@VarB,#0		;comparing vd and 0
	b	vdg,GT
	b	vdl,LEQ
call2:	cmp	@VarA,#0
	b	Case6,EQ
call:	mov	AH,@Resu
	lretr
