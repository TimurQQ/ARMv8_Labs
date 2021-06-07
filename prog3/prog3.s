	.arch armv8-a
//4. Удалить из строки слова, первый символ которых не совпадает с первым символом последнего слова в строке.
	.data
mes1:
	.ascii "Enter filename: "
	.equ len, .-mes1
mes2:
	.ascii "Enter string: "
	.equ mes2_len, .-mes2
str:
	.skip 1024
space:
	.ascii " "	
enter:
	.ascii "\n"
filename:
	.skip 256
	.text
	.global _start
	.type _start, %function
_start:
	mov x0, #1 // std-вывод сообщения из буфера по x1
	adr x1, mes1
	mov x2, len
	mov x8, #64
	svc #0
	mov x0, #0 // std-ввод сообщения в буфер по x1
	adr x1, filename
	mov x2, #256
	mov x8, #63
	svc #0 // считали имя файла
	sub x0, x0, #1 // получили указатель на последнюю букву имени файла (\n)
	strb wzr, [x1, x0]
L0:
	mov x0, #-100
	adr x1, filename
	mov x2, #0x241
	mov x3, #0600
	mov x8, #56
	svc #0 // попытались открыть файл
	mov x21, x0
	b L1
L_Enter:
	mov x0, x21
	adr x1, enter
	mov x2, #1
	mov x8, #64
	svc #0
L1:
	mov x0, #1
	adr x1, mes2
	mov x2, mes2_len
	mov x8, #64
	svc #0 // Приглашение ввести строку Пользователю stdout
	mov x0, #0
	adr x1, str
	mov x2, #1023
	mov x8, #63
	svc #0 // Считывание строки, введённой пользователем через stdin
	cmp x0, #0
	ble L8
	sub x0, x0, #1
	mov x20, x0
	strb wzr, [x1, x0]
	adr x1, str
	mov w28, #0 // Флаг того, что слово не первое
L2:
	// Считываем все пробелы до следующего слова
	ldrb w0, [x1], #1
	cbz w0, C // Произошёл конец строки (нуль-байт)
	cmp w0, ' '
	beq L2
	sub x2, x1, #1 // Начало слова. Все пробелы до него считаны
L3:
	// Считываем слово целиком до пробела или \0
	ldrb w0, [x1], #1
	cbz w0, L4 // Переход если после слова стоит нуль-байт
	cmp w0, ' ' 
	bne L3 // Если после слова стоит пробел, переходим на L4
	//Слово закончилось
L4:
	mov x5, x2 // Запомнили первую букву последнего слова
	ldrb w5, [x5]
	b L2 // Снова считываем пробелы до следующего слова, если не было перехода на C (не было конца строки)
C:
	adr x1, str
L5: // Here we go again
	ldrb w0, [x1], #1
	cbz w0, L_Enter // Нашли нульбайт, при записи строки в файл. Значит надо закончить запись этой строки и перейти к вводу новой
	cmp w0, ' ' // Пропускаем пробелы до слова
	beq L5
	sub x2, x1, #1 // Начало слова
	ldrb w27, [x2]
	cmp w27, w5 // Сравниваем первые буквы слов
	bne L7 // Если не равны, скипаем слово
C1:
	cmp w28, #0
	mov w28, #1
	mov x26, x1
	mov x27, x2
	beq L6
	// пробельный символ перед словом
	adr x1, space
	mov x0, x21
	mov x2, #1
	mov x8, #64
	svc #0
	mov x2, x27
	mov x1, x26
L6:
	mov x0, x21
	mov x26, x1
	mov x1, x2 // Пишем первый символ слова в файл
	mov x2, #1
	mov x8, #64
	svc #0
	//Записать каждый байт слова в файл
	mov x1, x26 // Возвращаем на место текущий символ (не первый)
	ldrb w0, [x1], #1
	cbz w0, L_Enter
	cmp w0, ' '
	sub x2, x1, #1
	bne L6
	b L5
L7:
	//Скипнуть слово
	ldrb w0, [x1], #1
	cmp w0, ' '
	bne L7
	// Увидели пробельный символ
	b L5 // Снова считываем все пробелы до следующего слова.
L8:
	mov x0, x21
	mov x8, #57
	svc #0
_exit:
	mov x0, #0
	mov x8, #93
	svc #0
	.size   _start, .-_start
