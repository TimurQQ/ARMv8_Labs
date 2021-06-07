	.arch armv8-a
// A^2 - B^2 - (A + B) * (A - B)
// одинарная точность. Максимальный размер 20x20
	.data
mes:
	.string "%f "
mes1:
	.string "Program \"%s\" need input file in the parameters\n"
mes2:
	.string "Incorrect format of the input file - \"%s\"\n"
mes3:
	.string "Dimension of matrixes must be <=20"
intform:
	.string "%d"
floatform:
	.string "%f"
new_line:
	.string "\n"
mode:
	.string "r"
	.text
	.align 2
	.global main
	.type main, %function
	.equ progname, 32
	.equ filename, 40
	.equ fileptr, 48
	.equ n, 56
	.equ matrixA, 64
	.equ matrixB, 1664
	.equ resMatrL, 3264
	.equ resMatrR, 4864
	.equ resMatrTmp, 6464
main:
	mov x9, #8064
	sub sp, sp, x9
	stp x29, x30, [sp]
	stp x27, x28, [sp, #16]
	mov x29, sp
	cmp w0, #2
	beq OPEN_FILE
	adr x0, stderr
	ldr x0, [x0]
	ldr x2, [x1] // Загрузили имя нашей программы
	adr x1, mes1
	bl fprintf
ERR_EXIT:
	mov w0, #1 // Будет возвращено 1
	ldp x29, x30, [sp]
	mov x9, #8064
	add sp, sp, x9
	ret
OPEN_FILE:
	ldr x0, [x1]
	str x0, [x29, progname]
	ldr x0, [x1, #8]
	str x0, [x29, filename]
	adr x1, mode
	bl fopen
	cbnz x0, READ_FILE
	ldr x0, [x29, filename]
	bl perror
	b ERR_EXIT
READ_FILE:
	str x0, [x29, fileptr]
	adr x1, intform
	add x2, x29, n
	bl fscanf
	cmp w0, #1
	beq CHECK_INT
	ldr x0, [x29, fileptr]
	bl fclose
	adr x0, stderr
	ldr x0, [x0]
	adr x1, mes2
	ldr x2, [x29, filename]
	bl fprintf
	b ERR_EXIT
CHECK_INT:
	mov x27, #0 // номер считываемого элемента
	ldr x28, [x29, n]
	cmp x28, #0
	ble DIM_ERROR
	cmp x28, #20
	bgt DIM_ERROR
	// Всё норм с размером. Начинаем читать построчно 1ю матрицу
	mul x28, x28, x28
	b READ_A
DIM_ERROR:
	ldr x0, [x29, fileptr]
	bl fclose
	adr x0, stderr
	ldr x0, [x0]
	adr x1, mes3
	bl fprintf
	b ERR_EXIT
READ_A:
	ldr x0, [x29, fileptr]
	adr x1, floatform
	add x2, x29, matrixA
	add x2, x2, x27, lsl #2
	bl fscanf
	cmp w0, #1
	beq 0f
	ldr x0, [x29, fileptr]
	bl fclose
	adr x0, stderr
	ldr x0, [x0]
	adr x1, mes2
	bl fprintf
	b ERR_EXIT
0: 
	add x27, x27, #1
	cmp x27, x28
	bne READ_A
	mov x27, #0
READ_B:
	ldr x0, [x29, fileptr]
	adr x1, floatform
	add x2, x29, matrixB
	add x2, x2, x27, lsl #2
	bl fscanf
	cmp w0, #1
	beq 0f
	ldr x0, [x29, fileptr]
	bl fclose
	adr x0, stderr
	ldr x0, [x0]
	adr x1, mes2
	bl fprintf
	b ERR_EXIT
0:
	add x27, x27, #1
	cmp x27, x28
	bne READ_B
	ldr x0, [x29, fileptr]
	bl fclose
CALC:
	//A + B
	mov x4, resMatrL
	add x0, x29, x4
	add x1, x29, matrixA
	add x2, x29, matrixB
	add x3, x29, n
	ldr x3, [x3]
	bl matrix_sum
	//B - A
	mov x4, resMatrR
	add x0, x29, x4
	add x1, x29, matrixB
	add x2, x29, matrixA
	add x3, x29, n
	ldr x3, [x3]
	bl matrix_sub
	// (1) * (2)
	mov x4, resMatrL
	mov x5, resMatrR
	mov x6, resMatrTmp
	add x0, x29, x6
	add x1, x29, x4
	add x2, x29, x5
	add x3, x29, n
	ldr x3, [x3]
	bl matmul
	//B^2
	mov x4, resMatrR
	add x0, x29, x4
	add x1, x29, matrixB
	add x2, x29, matrixB
	add x3, x29, n
	ldr x3, [x3]
	bl matmul
	//(1) * (2) - B^2
	mov x4, resMatrL
	mov x5, resMatrR
	mov x6, resMatrTmp
	add x0, x29, x4
	add x1, x29, x6
	add x2, x29, x5
	add x3, x29, n
	ldr x3, [x3]
	bl matrix_sub
	//A^2
	mov x5, resMatrR
	add x0, x29, x5
	add x1, x29, matrixA
	add x2, x29, matrixA
	add x3, x29, n
	ldr x3, [x3]
	bl matmul
	// + A^2
	mov x4, resMatrL
	mov x5, resMatrR
	mov x6, resMatrTmp
	add x0, x29, x6
	add x1, x29, x4
	add x2, x29, x5
	add x3, x29, n
	ldr x3, [x3]
	bl matrix_sum
PRINT_RES:
	mov x4, resMatrTmp
	add x26, x29, x4
	ldr x28, [x29, n]
	mul x28, x28, x28
	bl print_matrix
EXIT:
	mov w0, #0
	ldp x29, x30, [sp]
	ldp x27, x28, [sp, #16]
	mov x25, #6464
	add sp, sp, x25
	ret
	.size main, .-main
	.global matrix_sum
	.type matrix_sum, %function
matrix_sum: 
//x0 - адрес, куда записать результирующую матрицу
//x1 - left operand
//x2 - right operand
//x3 - размер строк и столбцов матрицы
	mov x7, #0
	mul x8, x3, x3
R:
	ldr s0, [x1, x7, lsl#2]
	ldr s1, [x2, x7, lsl#2]
	fadd s2, s1, s0
	str s2, [x0, x7, lsl#2]
	add x7, x7, #1
	cmp x7, x8
	bne R
	ret
	.size matrix_sum, .-matrix_sum
	
	.global matrix_sub
	.type matrix_sub, %function
matrix_sub:
//x0 - адрес, куда записать результирующую матрицу
//x1 - left operand
//x2 - right operand
//x3 - размер строк и столбцов матрицы
	mov x7, #0
	mul x8, x3, x3
L:
	ldr s0, [x1, x7, lsl#2]
	ldr s1, [x2, x7, lsl#2]
	fsub s2, s0, s1
	str s2, [x0, x7, lsl#2]
	add x7, x7, #1
	cmp x7, x8
	bne L
	ret
	.size matrix_sub, .-matrix_sub
	.global print_matrix
	.type print_matrix, %function
// x26 - matrix, x28=n^2
print_matrix:
	mov x27, #0
	mov x22, x30
START:
	ldr s0, [x26, x27, lsl#2]
	fcvt d0, s0
	adr x0, mes
	bl printf
	ldr x23, [x29, n]
	add x27, x27, #1
	sdiv x24, x27, x23
	mul x24, x24, x23
	cmp x24, x27
	beq ADDSPACE
E:
	cmp x27, x28
	blo START
	mov x30, x22
	ret
ADDSPACE:
	adr x0, new_line
	bl printf
	b E
	.size print_matrix, .-print_matrix
	
	.global matmul
	.type matmul, %function
// x0 - адрес, куда записать результирующую матрицу
// x1 - адрес первого операнда (матрицы слева)
// x2 - адрес второго операнда (матрицы справа)
// x3 - кол-во строк и столбцов в матрицах
matmul:
	mov x7, #0
	mul x8, x3, x3 // кол-во элементов в матрице
SCALAR_MUL:
	mov x4, #0
	fmov s0, wzr
MUL:
	mov x5, x7
	udiv x5, x5, x3
	mul x5, x5, x3
	add x5, x5, x4

	udiv x6, x7, x3
	mul x6, x3, x6
	sub x6, x7, x6
	mul x9, x4, x3
	add x6, x6, x9
	
	//x5 - индекс по первой матрице
	//x6 - индекс по второй матрицу
	ldr s1, [x1, x5, lsl #2]
	ldr s2, [x2, x6, lsl #2]
	fmul s3, s1, s2
	fadd s0, s0, s3
	add x4, x4, #1
	cmp x4, x3
	bne MUL

	str s0, [x0, x7, lsl #2]
	add x7, x7, #1
	cmp x7, x8
	bne SCALAR_MUL
	ret
	.size matmul, .-matmul
