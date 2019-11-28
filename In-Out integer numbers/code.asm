.model small ; модель сегментации памяти 'small'
.stack 100h  ; выделение памяти на стек 256 байт

.data ; начало описания сегмента данных
	a db ?
	b db ?
	x db ?
	act1 db ?
	act2 db ?
	buff db 7 dup(' ')
	minus db ' '
	rem db 'Remind!','$'
	cnd1 db 'a>b -> X = (a-b)/(a+1)','$'
	cnd2 db 'a=b -> X = -66','$'
	cnd3 db 'a<b -> X = a - 5/b','$'
	cnt db 'Press any key to continue','$'
	welc db 'Enter number(-128 - 127) ','$'
	Astr db 'A:','$'
	Bstr db 'B:','$'
	rez db 'X =','$'
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
	
	mHello macro
		mPushReg
		
		mClr 0, 184Fh
		mSetXY 0, 0
		mPrintStr rem
		mSetXY 0, 1
		mPrintStr cnd1
		mSetXY 0, 2
		mPrintStr cnd2
		mSetXY 0, 3
		mPrintStr cnd3
		mSetXY 0, 4
		mPrintStr cnt
		
		mov ah, 7h
		int 21h
		mClr 0400h, 0420h
		
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
		lea bx, buff + 6
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
			mSetXY 0, 6
			mPrintStr rez
			mSetXY 3, 6
			lea dx, buff
			mov ah, 9
			int 21h
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
		mPrintStr welc
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
	mov buff + 6, '$'
	mHello
	mIn a, 0, 4, Astr
	mIn b, 0, 5, Bstr
	
	mov al, a
	cmp al, b
	JG op1 ; a>b -> (a-b)/(a+1)
	JE op2 ; a=b -> -66
	JL op3 ; a<b -> a - 5/b
	
	op1:
		mov al, a
		mov bl, b
		sub al, bl
		mov act1, al
	
		mov al, a
		inc al
		mov act2, al
	
		mov ax, 0
		mov al, act1
		idiv act2
		mov x, al
		jmp exit
	
	op2:
		mov x, 0BEh
		jmp exit
		
	op3:
		mov ax, 0
		mov al, 5
		idiv b
	
		mov bl, al
		mov ax, 0
		mov al, a
		sub al, bl
	
		mov x, al
		jmp exit
	
    ; вызов сервиса DOS для завершения программы
	exit:
		mOut x
		
		mov ah, 7h
		int 21h
		
		mov ax, 4c00h
		int 21h
		
end start