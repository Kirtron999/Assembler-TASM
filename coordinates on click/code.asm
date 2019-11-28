.model tiny
.code
	org 100h         ; СОМ-файл

	
start:
mOut macro number, row, message
	local negative
	local digSplit
	local print
	mov ax, number
	mov minus, ' '
	mov bx, 0
	mov si, 0Ah
	cmp ax, bx
	lea bx, buffo + 5
	JL negative
	jmp digSplit
		
	negative:
		neg ax
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
		
		mov ax, 1301h
		mov cx, 2
		lea bp, message
		mov bh, 0
		mov bl, 7
		mov dh, row
		mov dl, 0
		int 10h
		
		mov ax, 1301h
		mov cx, 5
		lea bp, buffo
		mov bh, 0
		mov bl, 7
		mov dh, row
		mov dl, 3
		int 10h
endm

mClrBuff macro
	lea si, cleanBuffo
	lea di, buffo
	mov cx, 5
	rep movsb
endm
	

	call waitForAnyKey
	mov ax, 12h    ; set video mode as 640x480
    int 10h
	mov ax, 0 ; сброс(инициализация) драйвера мыши
    int 33h
	mov ax, 1 ; показать курсор
	int 33h
    ;lea dx, handlerLeftClick
    ;call initLeftClick
	;lea dx, handlerRightClick
	call initClick
    call drawMode
    call exit
ret 

waitForAnyKey:
    lea dx, startMessage          
    mov ah,09h
    int 21h
    mov ah,10h      ; wait any key for exit
    int 16h
ret

initLeftClick:
	lea dx, handlerLeftClick
    mov ax, 0ch
    mov cx, 02h      ; event of left click
    int 33h
ret

initClick:
	lea dx, handler
	mov ax, 0ch
	mov cx, 0Ah ; event of right click
	int 33h
	
ret

drawMode:
    mov ah,10h      ; if pressed any key then exiting
    int 16h
ret

exit:
    mov ax,0ch
    mov cx,00h      ; cancel the handler
    int 33h
    mov ax,3        ; set TEXTMODE
    int 10h
ret

handlerLeftClick:
	mov ax, 03h
	int 33h
	mov xPos, cx
	mov yPos, dx
	mOut xPos, 0, xMessage
	mOut yPos, 1, yMessage
retf

handler:
	xor cx, cx
	mov cl, 00001000b
	and ax, cx
	cmp ax, 8
	jne lClick
	call exit
	jmp endHandler
	lClick:
		mov ax, 03h
		int 33h
		mov xPos, cx
		mov yPos, dx
		mClrBuff
		mOut xPos, 0, xMessage
		mClrBuff
		mOut yPos, 1, yMessage
	endHandler:
retf

.data
startMessage db 'Press any key to start...',10,13,'$'
xMessage db 'X:'
yMessage db 'Y:'
xPos dw ?
yPos dw ?
buffo db 5 dup(' ')
cleanBuffo db 5 dup(' ')
minus db ' '	

end start
