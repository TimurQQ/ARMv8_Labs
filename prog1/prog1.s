	.arch armv8-a
//	res = a * c / b + d * b / e - c * c / (a * d)
	.data
	.align 3
res:
	.skip 8
a:
	.word 100000
d:
	.word 50000
e:
	.word 50000
c:
	.hword 10000
b:
	.byte 200
	.text
	.align 2
	.global _start
	.type _start, %function
_start:
	adr x0, a
	ldr w1, [x0]
	adr x0, d
	ldr w2, [x0]
	adr x0, e
	ldr w3, [x0]
	uxtw x3, w3
	adr x0, c
	ldrh w4, [x0]
	adr x0, b
	ldrb w5, [x0]
	uxtw x5, w5
	adr x0, res
	umull x6, w1, w4 // a * c
	cmp w5, #0 // b == 0
	beq ERROR_DIV_BY_ZERO
	udiv x6, x6, x5 // a * c / b
	umull x7, w2, w5 // d * b
	cmp w3, #0 // e == 0
	beq ERROR_DIV_BY_ZERO
	udiv x7, x7, x3 // d * b / e
	umull x8, w4, w4 // c * c
	umull x9, w1, w2 // a * d
	cmp x9, #0
	beq ERROR_DIV_BY_ZERO
	udiv x8, x8, x9 // c * c / (a * d) 
	adds x6, x6, x7 // expr1 = expr1 + expr2
	bcs ERROR_OVERFLOW
	subs x6, x6, x8 // expr1 = expr1 - expr3
	bcc ERROR_OVERFLOW
	str x6, [x0]
	mov x0, #0
end:
	mov x8, #93
	svc #0
	.size	_start, .-_start
ERROR_DIV_BY_ZERO:
	mov x0, #1
	b end
ERROR_OVERFLOW:
	mov x0, #2
	b end
