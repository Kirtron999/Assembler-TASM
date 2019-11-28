.model small ; модель сегментации памяти 'small'
.stack 100h  ; выделение памяти на стек 256 байт

.data ; начало описания сегмента данных
	;lowerBound db ?
	;upperBound db ?
	lines db 3
	columns db 3
	checkNumber db 3
	reserve db ?
	choice db ?
	buff db 6 dup(' ')
	minus db ' '
	tmp db ?
	non0 db 0
	temppp db 0
	sum db ?
	side db ?
	pointer db ?
	dop db 0
	welcomeMsg db 'TASM HW-1. Matrix handling','$'
	setColumns db 'Set amount of columns in matrix: ','$'
	setLines db 'Set amount of lines in matrix: ','$'
	nextStep db 'Press any key to continue','$'
	cntMsg db 'To enter matrix press any key','$'
	toMenu db 'Press any key to return to menu','$'
	possibleActs db 'Choose possible action:','$'
	actTransposition db 'Enter 1 to matrix transposition','$'
	actA db 'Enter 2 to do ex.A','$'
	actB db 'Enter 3 to do ex.B','$'
	actC db 'Enter 4 to do ex.C','$'
	outputM db 'Enter 5 to output matrix','$'
	actExit db 'Any other key to exit','$'
	actAInput db 'Enter number to check: ','$'
	actAAmount db 'Amount of values:','$'
	actBAmount db 'Amount of nonzero lines:','$'
	actCSum db 'Sum =','$'
	yourChoice db 'Your choice: ','$'
	mas db ?
.code  ; начало описания сегмента кода

start:
	mPushReg macro
		push ax
		push bx
		push cx
		push dx
	endm
	
	mPopReg macro
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
	
	mMatrixInfo macro
		mPushReg
		
		mov ah, lines
		inc ah
		mSetXY 0, ah
		mPrintStr matrixSize
		inc ah
		mSetXY 0, ah
		mPrintStr possibleActs
		inc ah
		mSetXY 0, ah
		mPrintStr actTransposition
		inc ah
		mSetXY 0, ah
		mPrintStr actExit
		
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
		lea bx, buff + 5
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
			lea dx, buff
			mov ah, 9
			int 21h
	endm
	
	mInRow macro line
		local kostilyara
		local negativen
		local str2dec
		local exitIn
		local newNumber
		
		mov si, 668h
		mov dx, 666h
		mov cl, 240d
		mov byte ptr[si - 2], cl
		mov ax, 0
		mov bp, ax
		mov al, columns
		mov pointer, al
		
		mSetXY 0, line
		mov ah, 0Ah
		int 21h
		
		newNumber:
		mov di, 0Ah
		mov ax, 0h
		mov cl, 1
		mov bl, [si]
		cmp bl, 2Dh
		JE negativen
		jmp str2dec
		
		negativen:
			mov cl, 0FFh
			inc si
			
		str2dec:
			mov bx, 0
			mov bl, [si]
			inc si
			cmp bl, 0Dh
			JE exitIn
			cmp bl, 20h
			JE exitIn
			sub bl, '0'
			mul di
			add ax, bx
			jmp str2dec
		
		exitIn:
			imul cl
			push si
			push bx
			mov si, bp
			mov bx, 0
			mov bl, dop
			mov byte ptr ds:mas[si + bx], al
			pop bx
			pop si
			inc bp
			mov ax, bp
			mov ah, 0
			cmp al, pointer
			JNL kostilyara
			jmp newNumber
			kostilyara:
			mov al, dop
			add al, columns
			mov dop, al
	endm
	
	mPrintMatrix macro
		local newLine
		local newElem
		
		mov cl, lines
		mov bx, 0
		mov si, 0	
		
		newLine:
			mov ch, lines
			sub ch, cl
			mSetXY 0, ch
			newElem:
				mov ch, byte ptr ds:mas[bx + si]
				push bx
				push si
				mOut ch
				pop si
				pop bx
				inc si
				mov ax, 0
				mov al, columns
				cmp si, ax
				JL newElem
		mov si, 0
		mov ax, 0
		mov al, columns
		add bx, ax
		dec cl
		cmp cl, 0
		JG newLine
		
	endm
	
	mTransposition macro 
		local newLine
		local newElem
		local kostiul
		local enddd
		
		mov tmp, 0
		mov cl, columns
		mov bx, 0
		mov si, 0
		
		newLine:
			mov ch, lines
			sub ch, cl
			mSetXY 0, ch
			newElem:
				mov ch, byte ptr ds:mas[bx + si]
				push bx
				push si
				mOut ch
				pop si
				pop bx
				mov ax, 0
				mov al, columns
				add bx, ax
				inc tmp
				mov al, tmp
				cmp al, lines
				JL newElem
		mov bx, 0
		mov tmp, bl
		inc si
		dec cl
		cmp cl, 0
		JNG kostiul
		jmp newLine
		kostiul:
	endm
	
	mNonzero macro
		local newLine
		local newElem
		local nxt
		local nnz
		
		mov cl, lines
		mov bx, 0
		mov si, 0
		mov ax, 0
		
		newLine:
			mov ax, 0
			mov ch, lines
			sub ch, cl
			newElem:
				add al, byte ptr ds:mas[bx + si]
				cmp al, 0
				JNE nxt
				inc ah
				nxt:
				inc si
				mov dx, 0
				mov dl, columns
				cmp si, dx
				JL newElem
		cmp ah, 0
		JNE nnz
		inc non0
		nnz:
		mov si, 0
		mov dx, 0
		mov dl, columns
		add bx, dx
		dec cl
		cmp cl, 0
		JG newLine
		mSetXY 0,0
		mPrintStr actBAmount
		mOut non0
		
	endm
	
	mValue macro
		local newLine
		local newElem
		local nxt
		local kostil
		
		mov cl, lines
		mov bx, 0
		mov si, 0
		
		newLine:
			mov ax, 0
			mov ch, lines
			sub ch, cl
			mSetXY 0, ch
			newElem:
				mov al, byte ptr ds:mas[bx + si]
				cmp al, checkNumber
				JNL nxt
				inc ah
				nxt:
				inc si
				mov dx, 0
				mov dl, columns
				cmp si, dx
				JL newElem
		mov reserve, ah
		push bx
		push ax
		push si
		push dx
		mOut reserve
		pop dx
		pop si
		pop ax
		pop bx
		mov si, 0
		mov dx, 0
		mov dl, columns
		add bx, dx
		dec cl
		cmp cl, 0
		JNG kostil
		jmp newLine
		kostil:
		
	endm
	
	mTriangleSum macro
		local newLine
		local newElem
		local sideInit
		
		mov al, lines
		cmp al, columns	
		JLE sideInit
		mov al, columns
		mov side, al
		sideInit:
			mov al, lines
			mov side, al
		
		mov cl, side
		mov bx, 0
		mov si, 0	
		
		mov al, 0
		mov pointer, al
		mov sum, al
		newLine:
			newElem:
				mov ch, byte ptr ds:mas[bx + si]
				add sum, ch
				inc si
				mov ax, 0
				mov al, pointer
				cmp si, ax
				JLE newElem
		inc pointer
		mov si, 0
		mov ax, 0
		mov al, side
		add bx, ax
		dec cl
		cmp cl, 0
		JG newLine
		
		mSetXY 0,0
		mov dl, sum
		mOut dl
	endm
	
	mIn macro number, x, y, string
		local negativen
		local str2dec
		local exitIn
		mov si, 668h
		mov dx, 666h
		mov cl, 7
		mov byte ptr[si - 2], cl
		
		mSetXY x, y
		mPrintStr string
		mov ah, 0Ah
		int 21h
		
		mov di, 0Ah
		mov ax, 0
		mov cl, 1
		mov bl,[si]
		cmp bl, 2Dh
		JE negativen
		jmp str2dec
		
		negativen:
			mov cl, 0FFh
			inc si
			
		str2dec:
			mov bx, 0
			mov bl, [si]
			inc si
			cmp bl, 0Dh
			JE exitIn
			sub bl, '0'
			mul di
			add ax, bx
			jmp str2dec
		
		exitIn:
			imul cl
			mov number, al
	endm
    ; обновить регистр адреса начала сегмента данных
    ; через регистр ax
    mov ax, @data
    mov ds, ax
	mov buff + 5, '$'
	
	mClr 0, 184Fh
	mSetXY 0, 0
	mPrintStr welcomeMsg
	mIn lines, 0, 1, setLines
	mIn columns, 0, 2, setColumns
	mSetXY 0, 3
	mPrintStr cntMsg
	mov ah, 7h
	int 21h
	
	mClr 0, 184Fh
	mov ch, 0
	mov cl, lines
	
	newRow:
	push cx
	push bp
	mInRow ch
	pop bp
	pop cx
	inc ch
	cmp ch, cl
	JNL kostl
	jmp newRow
	kostl:
	
	mSetXY 0, lines
	mPrintStr nextStep
	mov ah, 7h
	int 21h
	
	menuMain:
	mClr 0, 184Fh
	mSetXY 0, 0
	mPrintStr possibleActs
	mSetXY 0, 1
	mPrintStr actTransposition
	mSetXY 0, 2
	mPrintStr actA
	mSetXY 0, 3
	mPrintStr actB
	mSetXY 0, 4
	mPrintStr actC
	mSetXY 0, 5
	mPrintStr outputM
	mSetXY 0, 6
	mPrintStr actExit
	mIn choice, 0, 7, yourChoice
	mov al, choice
	cmp al, 5
	JE output
	cmp al, 1
	JNE k1
	jmp Transp
	k1:
	cmp al, 2	
	JNE k2
	jmp valCheck
	k2:
	cmp al, 3
	JNE k3
	jmp nZero
	k3:
	cmp al, 4
	JNE k4
	jmp trSum
	k4:
	jmp exit
	
	
	output:
	mClr 0, 184Fh
	mPrintMatrix
	mov ah, 7h
	int 21h
	jmp menuMain
	
	Transp:
	mClr 0, 184Fh
	mTransposition
	mov ah, 7h
	int 21h
	jmp menuMain
	
	nZero:
	mClr 0, 184Fh
	mNonzero
	mov ah, 7h
	int 21h
	jmp menuMain
	
	valCheck:
	mClr 0, 184Fh
	mIn checkNumber, 0, 0, actAInput
	mValue
	mov ah, 7h
	int 21h
	jmp menuMain
	
	trSum:
	mClr 0, 184Fh
	mTriangleSum
	mov ah, 7h
	int 21h
	jmp menuMain
	
    ; вызов сервиса DOS для завершения программы
	exit:
		
		
		
		mov ax, 4c00h
		int 21h
end start