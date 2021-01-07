* cla6.asm:
	
	.ref	CLA_REGS_MCTL
	.ref	CLA_REGS_MVECT1
	.ref	CLA_REGS_MIER
	.ref	MEMCFG_REGS_LSX_MEMSEL
	.ref	MEMCFG_REGS_LSX_CLAPGM
	
	.global	MAIN
	
* CPU part:
	.data		; CPU data storage
input	.float	6.0	; input value
result	.float	0.0	; \result=e^(input) upto 5 terms approximation result returned by the CLA
	
	.text
MAIN:
	;; Set up CLA registers
	EALLOW
	movw	DP, #CLA_REGS_MCTL
	movw	@CLA_REGS_MCTL, #0x02 ; CLA soft reset
	nop
	movw	@CLA_REGS_MCTL, #0x04 ; Enable IACK to start CLA Tasks

	;; Set CLA VECT1 for Task 1 program in LS5 RAM Block
	movw	@CLA_REGS_MVECT1, #0xa800 
	;; Enable the starting of Task 1
	movw	@CLA_REGS_MIER, #0x0001
	;; Map LS5 and LS4 RAM blocks to CLA
	;; LS5 is PROGMEM and LS4 is DATAMEM
	movw	DP, #MEMCFG_REGS_LSX_MEMSEL
	movw	@MEMCFG_REGS_LSX_MEMSEL, #0x0500
	movw	@MEMCFG_REGS_LSX_CLAPGM, #0x0020
	EDIS
	;; The above completes the CLA program setup

	;; Place the CLA input into cla_in in CLA data memory
	movw	DP, #input
	movl	ACC, @input
	movw	DP, #cla_in
	movl	@cla_in, ACC	; CLA input in cla_in
	;; Set Bit-0 of the cstatus word to 1
	;; This is used for checking CLA task completion
	movw	DP, #cstatus
	or	@cstatus, #0x1

	iack	#0x0001	; Start Task 1 on CLA

check:	tbit	@cstatus, #0x0	; Check if Bit-0 of cstatus is 0
	sb	-1, TC		; If no, loop back to "check"
	movl	ACC, @retval	; If yes, CLA code run is finished
	;; The CLA output result is now in ACC. We are done.
	
	movw	DP, #result	; Copy the CLA result from ACC
	movl	@result, ACC	; into result
	
spin:	lb	spin		; End of the MAIN CPU program


	
* CLA part:			; Refer TRM
	.sect	"cla_dmem"	; CLA Data memory (LS4 memory block)
cla_in	.float	0.0		; Argument passed by the MAIN program
retval	.float	0.0		; stores the final answer
cstatus	.word	0xffff		; Bit-0 indicates CLA program completion
	
	
	.sect	"cla_pmem"	; CLA Program memory (LS5 memory block)

	MMOV32	MR0, @cla_in			;MR0 = x
	MMOV32	MR1, @cla_in			;MR1 = x
	MADDF32	MR2, MR0, #1.0			;MR2 = 1+x
	MMPYF32	MR1, MR0, MR1			;MR1 = x^2
	MMPYF32	MR3, MR1, #0.5			;MR3 = (x^2)/2
	MADDF32	MR2, MR3, MR2			;MR2 = 1 + x + (x^2)/2
	MMPYF32	MR1, MR0, MR1			;MR1 = x^3
	MMPYF32	MR3, MR1, #0.16666666		;MR3 = (x^3)/6
	MADDF32	MR2, MR3, MR2			;MR2 = 1 + x + (x^2)/2 + (x^3)/6
	MMPYF32	MR1, MR0, MR1			;MR1 = x^4
	MMPYF32	MR3, MR1, #0.04166666		;MR3 = (x^4)/24
	MADDF32	MR2, MR3, MR2			;MR2 = 1 + x + (x^2)/2 + (x^3)/6 + (x^4)/24
	MMOV32	@retval, MR2			;retval=exponent value upto 5 terms (i = 0 to 4)
	
	MMOVI16	MAR0, #0x0000	; Clear cstatus Bit-0 to indicate
	MMOV16	@cstatus, MAR0	; CLA task completion
	
	MSTOP
	
	.end
