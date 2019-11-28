.model small; модель сегментации памяти 'large'
.stack 100h  ; выделение памяти на стек 256 байт

.data ; начало описания сегмента данных
;===========================
	CR = 0Dh
	LF = 0Ah
	amount db 0
	FileName db "D:\Users\Desktop\asm11new\sentence.txt0", "$" ;имя файла в формате ASCIIZ строки
	FDescr dw ? ;ячейка для хранения дискриптора
	NewFile db "newfile.txt0", "$"
	lineSize db 0
	buffo db 7 dup(' ')
	minus db ' '
	FDescrNew dw ? ;для хранения дискриптора нового файла
	Buffer db ? ;буфер для хранения символа строки
	String db 200 dup('$') ;буфер для хранения строки
	index db 0 ;впомогательная переменная
	MessageError1 db CR, LF, "File was not opened !", "$"
	MessageError2 db CR, LF, "File was not read !", "$"
	MessageError3 db CR, LF, "File was not founded!", "$"
	MessageError4 db CR, LF, "File was not created!", "$"
	MessageError5 db CR, LF, "Error in writing in the file!", "$"
	MessageError6 db CR, LF, "File was not closed", "$"
	MessageEnd db CR, LF, "Program was successfully finished!", "$"
;===========================
	
.code  ; начало описания сегмента кода
	mPushReg macro
		push ax
		push bx
		push cx
		push dx
		push si
		push di
	endm
	
	mPopReg macro
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
	endm
	
	mPrintStr macro string
		mPushReg
		
		lea dx, string
		mov ah, 9
		int 21h
	
		mPopReg
	endm
	
	mClr macro trcx, trdx
		mPushReg
		
		mov ax, 0600h
		mov bh, 3h
		mov cx, trcx
		mov dx, trdx
		int 10h
		
		mPopReg
	endm
	
	mSetXY macro x, y
		mPushReg
		
		mov ah, 2
		mov dh, y
		mov dl, x
		mov bh, 0
		int 10h
		
		mPopReg
	endm
	
	mOut macro number
	local negative
	local digSplit
	local print
		mov ax, 0
		mov al, number
		mov bx, 0
		mov si, 0Ah
		cmp al, bl
		lea bx, buffo + 6
		JL negative
		jmp digSplit
		
		negative:
			neg al
			mov minus, '-'
			jmp digSplit
		
		digSplit:
			mov dx, 0
			div si
			add dx, '0'
			dec bx
			mov byte ptr[bx], dl
			cmp ax, 0
			JE print
			jmp digSplit
		
		print:
			dec bx
			mov dl, minus
			mov byte ptr[bx], dl
	endm
	
start:
	mov ax, @data
	mov ds, ax
	mov es, ax
	
	cld
	
	mClr 0, 184Fh
	mSetXY 0, 0
	;ввод строки
	;mov dx, 666h
	;mov cl, 200d
	;mov si, dx
	;mov byte ptr[si], cl
	;mov ah, 0Ah
	;int 21h
	
	M1:
	;создание файла
	;mov ah, 3ch ;создать новый файл
	;xor cx, cx
	;lea dx, FileName ;адрес имени файла
	;int 21h ;выпонить
	;mov FDescr, ax ;дискриптор файла
	;jnc M2 ;если ошибок нет, выполнить программу дальше
	;jmp Er3 ;файл не был создан
	
	M2:
	;запись в файл
	;mov ah, 40h
	;mov bx, FDescr
	;xor cx, cx
	;mov cl, byte ptr [si + 1]
	;mov dx, si
	;add dx, 2
	;int 21h
	;jnc M3
	;jmp Er4

	M3:
	;закрытие файла
	;mov ah, 3eh ;функция закрытия файла
	;mov bx, FDescr
	;int 21h
	;jnc M4
	;jmp Er5
	
	M4:
	;открытие файла на чтение
	mov ah, 3Dh
	xor al, al ;открыть файл для чтения
	lea dx, FileName ;адрес имени файла
	xor cx, cx ;открыть файл без указания атрибутов
	int 21h ;выполнить прерывание
	mov FDescr, ax ;получить дескриптор файла
	jnc M13 ;eсли ошибок нет, выполнить программу дальше
	jmp Er1 ;файл не был открыт
	
	M13:
	xor ax, ax
	mov ah, 3ch ;создать новый файл
	xor cx, cx
	mov dx, offset NewFile ;адрес имени файла
	int 21h ;выпонить
	mov FDescrNew, ax ;дискриптор файла
	jnc M5 ;если ошибок нет, выполнить программу дальше
	jmp Er3 ;файл не был создан
	;переместить указатель на начало файла
	;mov ah, 42h
	;mov bx, FDescr
	;xor cx, cx
	;xor dx, dx
	;xor al, al
	;int 21h
	;jnc Er1
	
	M5:
	;чтение из файла
	mov ah, 3fh ;чтение из файла
	mov bx, FDescr ;дескриптор нужного файла
	mov cx, 1 ;количество считываемых символов
	mov dx, offset Buffer ;адрес буфера для приема
	int 21h ;выполнить
	jnc M6 ;если нет ошибки -> продолжить чтение
	jmp Er2 ;если ошибка -> выход
	M6:
		cmp ax, 0 ;если ax=0(число считанных байтов) -> файл кончился -> выход
		je M7 ;если ax=0 -> sf=1
		mov al, Buffer
		xor bx, bx
		mov bl, index
		mov String[bx], al
		inc bx
		mov index, bl
	jmp M5
	
	M7:
	;закрытие файла
	xor dx, dx
	xor cx, cx
	xor al, al
	mov ah, 3eh ;функция закрытия файла
	mov bx, FDescr
	int 21h
	jnc M8
	jmp Er5
	
	M8:
	;работа с полученной строкой
	wSplit:
	lea dx, String
	mov si, dx
	
	;mov cx, 0
	;mov cl, byte ptr[si + 1]
	;inc cl
	;mov di, si
	;add di, 2
	mov cx, 355d
	mov ax, 0
	mov al, '$'
	lea di, String
	repnz scasb
	sub di, si
	mov dx, di
	mov lineSize, dl
	lea dx, String
	lea si, String
	lea di, String
	
	xor cx, cx
	mov cl, lineSize
	mov ax, 0
	mov al, ' '
	;mov amountOfBytes, 0
	split:
		repnz scasb
		
		cmp cx, 0
		JE kstl
		inc amount
		
		again:
		cmp cx, 0
		JE kstl
		
		mov si, di
		mov bl, byte ptr[si]
		cmp bl, ' '
		jne miss
		dec cx
		inc di
		jmp again
		miss:
		
		jmp split
		kstl:
		
		inc amount
	
	mOut amount
	
	M10:
	;запись в файл
	mov ah, 40h
	mov bx, FDescrNew
	mov cx, 7
	mov dx, offset buffo
	int 21h
	jnc M11
	jmp Er4
	
	M11:
	;закрытие нового файла
	mov ah, 3eh ;функция закрытия файла
	mov bx, FDescrNew
	int 21h
	jnc M12
	jmp Er5
	
	M12:
	;успешное завершение работы программы
	mPrintStr MessageEnd
	jmp Exit
	
	
	Er1:
	;файл не был найден
	cmp ax, 02h
	jne MErr
	mPrintStr MessageError3
	jmp Exit
	
	MErr:
	;файл не был открыт
	mPrintStr MessageError1
	jmp Exit
	
	Er2:
	;файл не был прочтен
	mPrintStr MessageError2
	jmp Exit

	Er3:
	;файл не был создан
	mPrintStr MessageError4
	jmp Exit
	
	Er4:
	;ошибка при записи в файл
	mPrintStr MessageError5
	jmp Exit

	Er5:
	;файл не был закрыт
	mPrintStr MessageError6
	jmp Exit
	
	Exit:
	mov ah, 07h ;задержка экрана
	int 21h
	;завершение программы
	mov ax, 4c00h
	int 21h
	
end start