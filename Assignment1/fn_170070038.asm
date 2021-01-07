
	.def q15inv
	.def q15exp
	.def q11mpy

	.data
VarA:	.word	0x0			;variable storing x for loop multiplication
VarB:	.word	0x7fff			;variable storing x^n for the loop
VarC:	.word	0x7fff			;variable storing the cumulative and initially 1
VarC1:	.word	0x1fff			;substitute for 1 in case of 2 right shifts
VarC2:	.word	0x07ff			;substitute for 1 in case of 4 right shifts
rem:	.word	0x0			;remainder for the division using repetitive subtraction
m1:	.word	0x0			;first multiplicant
m2:	.word	0x0			;second multiplicant
p1:	.word	0x0			;product
test:	.word	0x0			;variable used to store the scaled x
test1:	.word	0x8000			;variable used to compare x for positive and negative
	.text



q15inv:
	mov	@VarA, AH		;VarA = AH
	mov	@AR1, #7		;AR1 = 7 for loop
	mov	@VarB, AH		;VarB = AH
	mov	AL,#0			;AL = 0
	sfr	ACC,#4			;AH shifted right by 4 bits
	mov	@test,AH		;test = AH>>4
	mov	AL,@VarA		;AL = x
	mov	AH,@test1		;AH = 8000
	cmp	AH,@AL			;if AH>AL => HI=1 (+ve number and so scaling by 16)
	mov	AL,@test		;AL = x/16
	mov	@VarB,AL,HI		;VarB = x/16 if HI=1
	mov	AH,@VarC2		;AH = ~1/16 (0x0001 will be added later on)
	mov	@VarC,AH,HI		;VarC = 1/16 if HI=1
	mov	AL, @VarC		;AL = VarC
	add	AL, @VarB		;AL = AL + VarB
	mov	@VarC, AL		;VarC = VarC + VarB (1/16 + x/16) OR (1 + x) depending on HI
loop1:	mov	T, @VarB		;T = (x/16)*x^(n) loop starts here
	mpy	ACC, T, @VarA		;ACC = x*T
	movh	@VarB, ACC<<1		;VarB = x*VarB (Q15 multiplication)
	mov	AL, @VarC		;AL = VarC
	add	AL, @VarB		;AL = AL+VarB
	mov	@VarC, AL		;VarC = AL
	banz	loop1, AR1--		;postdecrement of AR1 and going back to loop 7 times
	mov	AL, @VarC		;AL = VarC
	add	AL, #0x0001		;AL = AL + 0x0001 that we missed earlier
	mov	@VarC, AL		;VarC = AL
	mov	AH, @VarC		;AH = result final
	mov	@VarC,#0x7fff		;VarC = 0x7fff for other function call since used in other routine
	lretr				;return

q15exp:
	mov	@VarA, AH		;VarA = AH
	mov	@AR1, #8		;AR1 = 7 for loop
	mov	@AR2, #1		;AR2 = 1 declared to deal with the factorial
	mov	@VarB, AH		;VarB = AH
	mov	AL,#0			;AL = 0
	sfr	ACC,#2			;AH shifted right by 2 bits
	mov	@test,AH		;test = AH>>2
	mov	AL,@VarA		;AL = x
	mov	AH,@test1		;AH = 8000
	cmp	AH,@AL			;if AH>AL => HI=1 (+ve number and so scaling by 4)
	mov	AL,@test		;AL = x/4
	mov	@VarB,AL,HI		;VarB = x/4 if HI=1
	mov	AH,@VarC1		;AH = ~1/4 (0x0001 will be added later on)
	mov	@VarC,AH,HI		;VarC = 1/4 if HI=1
	mov	AL, @VarC		;AL = VarC
	add	AL, @VarB		;AL = AL + VarB
	mov	@VarC, AL		;VarC = VarC + VarB (1/4 + x/4) OR (1 + x) depending on HI
loop2:	mov	T, @VarB		;T = (x/16)*x^(n) loop starts here
	mpy	ACC, T, @VarA		;ACC = x*T
	movh	@VarB, ACC<<1		;VarB = x*VarB (Q15 multiplication)
	clrc	TC			;clear TC flag used as sign
	add	@AR2,#1			;increment AR2 to divide the product by AR2
	mov	ACC,@AR2 << 16		;AH = AR2 (denominator)
	abstc	ACC			;absolute value
	mov	T,@AH			;T = Denominator
	mov	ACC,@VarB << 16		;AH = VarB (numerator)
	abstc	ACC			;absolute value
	movu	ACC,@AH			;AH = 0, AL = numerator
	rpt	#15			;repeat 15 times
	||subcu	ACC,@T			;conditional subtraction with the denominator
	mov	@rem,AH			;remainder
	mov	ACC,@AL << 16		;AH = quotient
	negtc	ACC			;negate if TC=1
	mov	@VarB,AH		;VarB = quotient which given back to loop to (*x/AR2)		
	mov	AL, @VarC		;AL = VarC (cumilative)
	add	AL, @VarB		;AL = AL+VarB
	mov	@VarC, AL		;VarC = AL
	banz	loop2, AR1--		;branching and post-decrement
	mov	AL, @VarC		;AL = VarC
	add	AL, #0x0001		;AL = AL+0x0001
	mov	@VarC, AL		;VarC = AL
	mov	AH, @VarC		;AH = VarC
	mov	@VarC,#0x7fff		;VarC = 0x7fff for other routines
	lretr				;return

q11mpy:
	mov	@m1, AL			;m1 = AL
	mov	@m2, AH			;m2 = AH
	mov	T,@m1			;T = m1
	mpy	ACC,T,@m2		;ACC = m1*m2 (Q31)
	movh	@p1,ACC<<1		;p1 = Q16 of the product
	;movw	AH,@p1			;AH = p1
	and	AH,@p1,#0xfff0		;AH = BITWISE AND of p1 and 0xfff0 to get Q11
	lretr				;return

	.end
	
