	.arch armv8-a
// SelectionSort for the columns (Descending)
	.data
	.align 1
matrix:
	.hword -1, 0
	.hword -2, 5
	.hword -3, 8
	.hword -4, 3
	.hword -5, 4
	.hword -6, 2
	.hword -7, 6
	.hword -8, 7
	.hword -9, 9
	.hword -10, 1
n:
	.byte 10
m:
	.byte 2
	.text
	.align 2
	.global _start
	.type _start, %function
_start:
	adr x0, matrix
	adr x1, n
	ldrb w1, [x1]
	sub w1, w1, #1 // Кол-во номеров строк - 1
	adr x2, m
	ldrb w2, [x2] // Кол-во столбцов
	mov w4, #0
C:
	cmp w4, w2
	bge L4
	mov w3, #0 // Номер, рассматриваемого на замену элемента
L0:
	cmp w3, w1
	bge L3
	mov w5, w3 // Номер элемента, с которым будем сравнивать (0 элемент)
	mov w6, w3 // Номер текущего максимума
	smull x7, w6, w2
	add x7, x7, x4
	ldrsh w7, [x0, x7, lsl #1] // Значение текущего максимума
L1:
	add w5, w5, #1 // Номер следующей строчки
	cmp w5, w1
	bgt L2
	smull x8, w5, w2 // Номер ячейки памяти в линейном расположении матрицы 
	add x8, x8, x4
	ldrsh w9, [x0, x8, lsl #1] // Значение, с которым будем сравнивать текущий максимум
	cmp w9, w7 // Сравниваем значение текущего максимума с рассматриваемым числом
	ble L1
	//Случай если рассматриваемый элемент больше текущего максимума
	mov w6, w5 // Меняем индекс текущего максимума
	mov w7, w9 // Меняем значение текущего максимума
	b L1
L2:
	// Случай, когда мы в очередной раз прошли весь массив сверху до низу
	smull x9, w3, w2
	add x9, x9, x4
	ldrsh w10, [x0, x9, lsl #1]
	smull x11, w6, w2
	add x11, x11, x4
	strh w10, [x0, x11, lsl #1]
	strh w7, [x0, x9, lsl #1]
	add w3, w3, #1
	b L0
L3:
	add w4, w4, #1
	b C
L4:
	// Конец
	mov x0, #0
	mov x8, #93
	svc #0
	.size	_start, .-_start
