.arch armv8-a
.text
.align 2
.global executor_asm
.type executor_asm, %function
executor_asm: 
// x0 - unsigned char* img 
// x1 - unsigned char* invert_img
// w2 - int width
// w3 - int height
// w4 - int channels
	mul w14, w2, w3 // width * height
	mul w14, w14, w4 // *channels
	add x5, x0, x14 // img + img_size
0:
	mov 	x7, x0
	mov 	x8, x1
FOR:
	cmp x7, x5
	beq End
	ldrb 	w11, [x7]
	ldrb 	w12, [x7, #8]
	ldrb 	w13, [x7, #16]
	mov 	w14, #255
	
	sub w15, w14, w11
	strb w15, [x8]
	sub w15, w14, w12
	strb w15, [x8, #8]
	sub w15, w14, w13
	strb w15, [x8, #16]

	add 	x8, x8, w4, sxtw
	add 	x7, x7, w4, sxtw
	b 		FOR
End:
	mov 	x0, x1
	ret
.size executor_asm, .-executor_asm
