	.global	MAIN
	.ref sector

	.data
vq:	.word	0x5000			;store vq		
vd:	.word	0x4500			;store vd
result:	.word	0x0			;store result
	.text

MAIN:
	movw	DP, #vq			
	movl	XAR7,#vq			
	lcr	sector		
	mov	@result,AH		
spin:	lb	spin			

	.end
	
