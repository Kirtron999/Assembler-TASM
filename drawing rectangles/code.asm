.model tiny ; модель сегментации памяти типа "tiny"(для com файла)
.code
org 100h ;выделяем стек(для com файла)
 
start:
    call waitForAnyKey
    lea dx, handler
    call initClick
    call drawMode
    call exit
ret 
 
drawSomething:
    mov ax, x_FirstClick
    mov x1, ax
    mov ax, x_SecondClick
    mov x2, ax
    mov ax, y_FirstClick
    mov y1, ax
    mov ax, y_SecondClick
    mov y2, ax
    call drawXLine
    call drawYLine
    mov ax, x_SecondClick
    mov x1, ax
    mov ax, x_FirstClick
    mov x2, ax
    mov ax, y_SecondClick
    mov y1, ax
    mov ax, y_FirstClick
    mov y2, ax
    call drawXLine
    call drawYLine
	
	;сбрасываем координаты
	mov x_FirstClick, -1
	mov y_FirstClick, -1
	mov x_SecondClick, -1
	mov y_SecondClick, -1
ret
 
drawYLine:
    ; y1 - начало линии
    ; y2 - конец линии
    ; x1 - x позиция
    mov ax, y1
    cmp ax, y2
    je exit_DrawYLine
    mov ax, y1
    mov y, ax
    mov ax, x1
    mov x, ax
    jmp calc_DrawYLine
dec_DrawYLine:
    dec y
    jmp calc_DrawYLine
inc_DrawYLine:
    inc y
calc_DrawYLine:
    call drawPoint
    cmp dx, y2
    jl inc_DrawYLine
    jg dec_DrawYLine
	call drawPoint
exit_DrawYLine:
ret
 
drawXLine:
    ; x1 - начало линии
    ; x2 - конец линии
    ; y1 - y координата
    mov ax, x1
    cmp ax, x2
    je exit_DrawXLine
    mov ax, x1
    mov x, ax 
    mov ax, y1
    mov y, ax 
    jmp calc_DrawXLine
dec_DrawXLine:
    dec x
    jmp calc_DrawXLine
inc_DrawXLine:
    inc x
    jmp calc_DrawXLine
calc_DrawXLine:
    call drawPoint
    cmp cx, x2
    jl inc_DrawXLine
    jg dec_DrawXLine
	call drawPoint
exit_DrawXLine:
ret
 
drawPoint:
    mov al, 07h     ; задаем цвет точки(в данном случае белый)
    mov bh, 0	
    mov cx, x
    mov dx, y
    mov ah, 0ch     ; номер функции прерывания вывода графической точки на экран
    int 10h
ret
 
waitForAnyKey:
    lea dx, startMessage          
    mov ah,09h
    int 21h
    mov ah,10h      ; ожидать нажатия любой клавиши
    int 16h
ret
 
initClick:
    mov ax, 0
    int 33h
    mov ax, 0ch
    mov cx, 0Ah      ; обработчик событий для нажатий правой и левой клавиш мыши
    int 33h
ret
 
drawMode:
    mov ax,0012h    ; установить видеорежим 640х480
    int 10h
	mov ax, 1       ; показать курсор мыши
    int 33h
    mov ah,10h      ; выйти, если будет нажата какая-либо клавиша
    int 16h
ret
 
exit:
    mov ax,0ch
    mov cx,00h      ; удалить обработчик событий мыши
    int 33h
    mov ax,3        ; установить текстовый режим
    int 10h
ret
 
handler:
	xor bx, bx
	mov bl, 00001000b
	and ax, bx
	cmp ax, 8
    je secondClick_handler
    ; получение координат точки от нажатия левой клавиши мыши
    mov x_FirstClick, cx ; cx - x координата
    mov y_FirstClick, dx ; dx - y координата
	cmp x_SecondClick, -1 ; проверка, есть ли вторая точка для построения прямоугольника
	je exit_handler
    jmp drawing
secondClick_handler:
    ; получение координат точки от нажатия правой клавиши мыши
    mov x_SecondClick, cx
    mov y_SecondClick, dx
	cmp x_FirstClick, -1 ; проверка, есть ли первая точка для построения прямоугольника
	je exit_handler
	drawing:
    call drawSomething
    jmp exit_handler
exit_handler:
retf
 
.data
startMessage db 'Press any key to start...',10,13,'$'
x_FirstClick dw -1
y_FirstClick dw -1
x_SecondClick dw -1
y_SecondClick dw -1
x1 dw 0
y1 dw 0
x2 dw 0
y2 dw 0
x dw 0
y dw 0
 
end start
