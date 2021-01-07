	.global MAIN
	.ref PIEACK
	.ref PIEIER1
	.ref TINT0
	.ref TIMER0PRD
	.ref TIMER0PRDH
	.ref TIMER0TCR

	.text
i_loc1:	.word	0xc000			;starting location of BUFFST_1
i_loc2:	.word	0xd000			;starting location of BUFFST_2
count1:	.word	0x0003			;count to get every 4th instance
count2:	.word	0x0003			;count to get every 4th instance
i_x:	.word	0x0000			;variable to store x
i_y:	.word	0x7fff			;variable to store y
h:	.word	0x0405			;omega*T
minush:	.word	0xfbfb			;-omega*T
temp:	.word	0x0001			;temporary registor


exit_1:
	lretr				;exit subroutine

put_value_1:
	mov	*XAR1++, AH		;moving AH to location stored in AR1
	movw	@i_loc1,AR1		;updating location register
	sub	@count1,#3		;making count again 0 so that we get every 4th instant
	lretr

put_value_2:
	mov	*XAR2++,AH		
	movw	@i_loc2,AR2		
	sub	@count2,#3
	lretr
	

BUFFST_1:
	movw	AL, @i_loc1		;moving address to AL 
	movw	AR1, AL			;moving address to AR1
	cmp	AR1,#0xd000		;to check if RAM block is full or not
	sb	exit_1,EQ		;if RAM block is full then exit
	cmp	@count1, #3		;see if it is 4th instant or not
	sb	put_value_1,EQ		;if it is 4th instant then go to put_value sub-routine
	add	@count1,#1		;if not the 4th instant then increase count
	lretr

BUFFST_2:
	movw	AL, @i_loc2
	movw	AR2,AL
	cmp	AR2,#0xe000
	sb	exit_1,EQ
	cmp	@count2,#3
	sb	put_value_2,EQ
	add	@count2,#1
	lretr
	
corner_1:
	mov	@i_x,#0x8001		;to check for the corner case of overflow in x
	b	back_1,UNC
corner_2:
	mov	@i_y,#0x7fff		;to check for the corner case of overflow in y
	b	back_2,UNC
	
INTEGRATOR:
	push	DP
	movw	DP, #i_x		;initializing DPP
	movw	AH,@i_x			;moving x in AH
	lcr	BUFFST_1		;calling the buffer subroutine
	movw	AH,@i_y			;moving y in AH
	lcr	BUFFST_2		;calling the buffer subroutine
	
	mov	T,@i_y			;T = y
	mpy	ACC,T,@h		;ACC = T*h
	movh	@temp,ACC<<1		;making it Q15 and storing in temporary register
	mov	AH,@temp		;AH = temp
	add	@i_x,AH			;x = x + temp or x = x + omega*T*y
	b	corner_1,OV		;check for overflow condition
back_1:	mov	T,@i_x			;T = x
	mpy	ACC,T,@minush		;ACC = -T*h
	movh	@temp,ACC<<1		;making it Q15 and storing in temporary register
	;mov	AL,@i_y			;AL = y
	mov	AL,@temp		;AL = temp
	add	@i_y,AL			;y = y + temp or y = y - omega*T*x
	b	corner_2,OV		;check for overflow condition
back_2:	pop	DP
	lretr

MAIN:
	setc	OBJMODE
	clrc	AMODE

	;; Set up the Timer_0 interrupt 1.7 vector at 0xd4c

	EALLOW
	movw	DP, #TINT0 			; Address 0xd4c for Interrupt 1.7
	movl	XAR7, #TIMER_0_ISR
	movl	@TINT0, XAR7
	EDIS

	;; Set up the Timer-0 period

	movw	DP, #TIMER0PRD 			; Timer_0 regs start at 0xc00
	movw	@TIMER0PRD, #0x2000 		; Set the PRD Low reg
	movw	@TIMER0PRDH, #0x0000 		; Set the PRD High reg

	;; Enable the Timer_0 interrupt at 1.7
	;; First enable Timer_0 interrupt 1.7 in PIEIER1
	;; Second enable interrupt in TIMER0TCR
	;; Third enable Interrupt Group 1 in the IER

	movw	DP, #PIEIER1
	or	@PIEIER1, #0x40
	movw	DP, #TIMER0TCR 			; TIMER0TCR is at 0xc04
	or	@TIMER0TCR, #0xc000 		; Set the TIE bit in TIMER0TCR
	or	IER, #0x0001 			; Enable Interrupt Group 1
	clrc	INTM
spin:	lb spin

TIMER_0_ISR:
	lcr	INTEGRATOR			; Increment the contents of myver by 1
	;; Re-enable the Timer_0 interrupt by ACKnowledging it
	movw	DP, #PIEACK 			; PIEACK is at 0xce1
	or	@PIEACK, #0x0001 		; ACK to PIE Group 1
	IRET

.end
