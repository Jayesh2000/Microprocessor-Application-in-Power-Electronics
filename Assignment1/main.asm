	.global	MAIN
	.ref q15inv
	.ref q15exp
	.ref q11mpy

	.data
a1:	.word	0xc120			;a1 for AH(testing)
a2:	.word	0x4120			;a2 for AL(testing)
result1:	.word	0x0		;result for inverse
result2:	.word	0x0		;result for multiply
result3:	.word	0x0		;result for exponential
	.text

MAIN:
spin:	movw	DP, #a1			;DP = a1
	movw	AH, @a1			;AH = a1
	movw	AL, @a2			;AL = a2
	lcr	q15inv			;q15inverse subroutine
	mov	@result1,AH		;store result in result1
	movw	AH, @a1			;AH = a1
	movw	AL, @a2			;AL = a2
	lcr	q11mpy			;q11mpy subroutine
	mov	@result2,AH		;store result in resunt2
	movw	AH, @a1			;AH = a1
	movw	AL, @a2			;AL = a2
	lcr	q15exp			;q15exp subroutine
	mov	@result3,AH		;store result in result3
	lb	spin			;goback to spin

	.end
	
