	.global PIEACK
	.global PIEIER1
	.global TINT0
	.global TIMER0TIM
	.global TIMER0TIMH
	.global TIMER0PRD
	.global TIMER0PRDH
	.global TIMER0TCR
	.global TIMER0TPR
	.global TIMER0TPRH

PIEACK	.set	0x0ce1
PIEIER1 .set	0x0ce2

TINT0	.set	0x0d4c

;; TIMER_0 Registers

TIMER0TIM	.set	0x0c00 		; Counter reg low
TIMER0TIMH	.set	0x0c01 		; Counter reg high
TIMER0PRD	.set	0x0c02 		; Period reg low
TIMER0PRDH	.set	0x0c03 		; Period reg high
TIMER0TCR	.set	0x0c04 		; Control reg
TIMER0TPR	.set	0x0c06 		; Prescale reg low
TIMER0TPRH	.set	0x0c07 		; Prescale reg high
