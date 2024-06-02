; шаблон для зачётного задания №1 (калькулятор) с использованием стековых фреймов
.386

arg1 equ 4
arg2 equ 6

stack segment para stack use16
    db 65530 dup(?)
stack ends

data segment para public use16
   
    ;- 12345 + -12345 - 15
    str_max db 15
    str_len db 0
    string db 15 dup('$')

    num1 db 8 dup('$')
    num2 db 8 dup('$')
    operand db 2 dup('$')

    strlen_num1 dw 0 
    razdel db 1 dup('$')
    strlen_num2 dw 0

    num1_calc dw ?
    num2_calc dw ?
 
    flag_negative db 0 ;!было

    num_sys dw 0 ;!тут 0,просто пока не добавил add num sys,10 or 16 в choice

    number dw 0
    str_num db 15 dup('$')
    new_line db 0dh,0ah,'$'

    no_error db 'no error', 0dh,0ah,'$'
    
    error_rng db 'error range', 0dh,0ah,'$'
    error_rng_atoh db 'error range atoh', 0dh,0ah,'$'
    string_cor db 'validnya stroka', 0dh,0ah,'$'

    ;!start_text
    choice db 'vvedite 1 - if 10, 2 - if hex', 0dh,0ah,'$'
    another_choice db 'necorrectniy vvod', 0dh,0ah,'$'
    ;!
    string_10 db '10', 0dh,0ah,'$'
    string_hex db 'hex', 0dh,0ah,'$'

    operand_okey db 'operand okey', 0dh,0ah,'$'
    operand_bad db 'operand bad', 0dh,0ah,'$'

    neval_ db 'nevalidnya stroka', 0dh,0ah,'$'
    valid db 'validnya stroka', 0dh,0ah,'$'

    err_parsing_ db 'err_parsing_', 0dh,0ah,'$'
    empty db 'empty ', 0dh,0ah,'$'

    value dw 12345

    result db 7 dup('$')
    ; result_hex db 4 dup('$')
    error_div_zero db 'error div zero', 0dh,0ah,'$'

data ends

code segment para public use16

assume cs:code,ds:data,ss:stack

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! exit
; завершает работу программы с кодом, переданным в качетве аргумента (кодом является младший байт аргумента)  
_exit:
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + arg1]

    mov ax,4c00h
    int 21h
    
    mov sp, bp
    pop bp
    ret
    
;?
; - строка не соответствует формату полностью (присутствуют буквы, нет второго операнда, проч.);
; - знак операции не является допустимым (?^& и т.п.);
; - недопустимые числа для операций деления (проверка на нулевой делитель, проверка на возможное переполнение частного).
; - число1 или число2 не входят в требуемый диапазон.
;?
; завершает работу программы с кодом 0 ;!тут если все ок,просто выходим
_exit_good:
    push bp
    mov bp, sp

    mov dx, 0
    push dx

    mov dx,offset no_error
    call print_str

    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret
; завершает работу программы с кодом 1 ;! это для ошибки,что недопустимое число
_exit_valid:
    push bp
    mov bp, sp
    
    mov dx, 1
    push dx
    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret
; завершает работу программы с кодом 2 ;! это для ошибки,что число превысило лимит
_exit_range:
    push bp
    mov bp, sp
    
    mov dx, 2
    push dx

    mov dx,offset error_rng
    call print_str

    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret
; завершает работу программы с кодом 3 ;! это для ошибки,что деление на 0
_exit_divzero:
    push bp
    mov bp, sp

    mov dx, 3
    push dx

    mov dx,offset error_div_zero
    call print_str

    call _exit
    add sp, 2

    mov sp, bp
    pop bp
    ret
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! конец exit

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! перевод в 10

check_rr:
    cmp ax,8000h
    ja _exit_range

    jmp exit_at
    
atoi proc near
	push bp
    mov bp, sp
	
	mov cx, word ptr [bp + arg1]
	sub cx,30h
    mov di, word ptr [bp + arg2]

	xor ax,ax
	xor bx,bx
	
	mov bl, byte ptr [di]
	cmp bl, '-'
	je skip_neg
	jmp cycle_atoi

skip_neg:
    ;!z,p = 0 стали
	add flag_negative, 1
	inc di
	dec cx
	
cycle_atoi: 
	mul num_sys ;!на метке выбора добавить 10or16
	mov bl, byte ptr [di]
    jo _exit_range
	inc di
	sub bl, '0'
	add ax, bx
	jo _exit_range
	loop cycle_atoi

	cmp flag_negative,1
	je umnoj_minus
	jmp exitatoi
	
umnoj_minus:
    xor bx,bx

	mov bx, -1
	mul bx ;!res * -1
	
exitatoi:

    ; mov sp, bp
    ; pop bp
    ; ret
    cmp flag_negative,0
    je check_rr ;!для переполнения проверка
    
    jmp exit_at

exit_at:
    cmp flag_negative,1
    je min_neg

	mov sp, bp
    pop bp
	ret
min_neg:
    dec flag_negative
    mov sp, bp
    pop bp
	ret

atoi endp

itoa proc near	
        push bp
        mov bp, sp
        
        mov ax , word ptr [bp + arg1]
        mov di, offset result
        mov cx, 0
        mov bx,10
        
        test ax, ax
        jns cycle_itoa

        neg ax
        mov byte ptr [di], '-'
        inc di
        
    cycle_itoa:
        mov dx, 0 
        div bx ;!получили символ
        add dl, '0' ;!записали его в формате строки
        push dx
        inc cx
        ;!делим пока ax !=0
        cmp ax,0
        jnz cycle_itoa
    write_str:
        pop dx
        mov byte ptr [di], dl
        inc di
        loop write_str

        mov byte ptr [di], 0
        mov byte ptr [di+1], '$'

        mov sp, bp
        pop bp
        ret
itoa endp

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! конец перевода в 10

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  hex 
atoh proc near

    ;! теперь буквы считывает верно
    push bp
    mov bp, sp

    mov di, word ptr [bp + arg2]

    mov cx, word ptr [bp + arg1]
    sub cx,30h
    mov ax, 0
    mov bx, 0
    mov bl, byte ptr [di]
    cmp bl, '-'
    ; je error_rangenumh
 
    cycle_atoh:
        ;! тут с концом считывания надо разобраться,в 0 записывается
        mov bl, byte ptr [di]
        inc di
        cmp bl, 39h
        ja a_f
        cmp bl, 30h
        jb error_range
        sub bl, 30h
        
        jmp continue_atoh

    a_f: 

        cmp bl, 61h
        jb error_range

        ;!!! посмотреть в com идею
        cmp bl,66h
        ja error_range
     
        sub bl,57h  ;! 61h - 57h = A
   
        jmp continue_atoh
      
    error_range:
        mov ah,09h
        mov dx, offset error_rng_atoh
        int 21h
        call _exit_range
    
    continue_atoh:

        ;!shl принцип работы,на примере abcd
        ;!ax изначально 0000,прочитали a,после shl и добавления bx, ax = 000A
        ;! след прочитали b,ax = 00A0, добавили bx, ax = 00AB
        ;! ax = 0AB0,add bx, ax = 0ABC... ax= ABC0, add bx , ax = ABCD exitatoh
        
        shl ax, 4
        add ax, bx

        mov bl, byte ptr [di]
        cmp bl,0 
        je exitatoh
        
        loop cycle_atoh

        jmp exitatoh
    
    exitatoh:
        mov sp, bp
        pop bp
        ret

atoh endp

itoh proc near

    push bp
    mov bp, sp

    lea si, result
    mov cx, 4
    mov bx, word ptr [bp + arg1]

    cycle_itoh:

        mov al, bh
        shr al, 4 ;!сдвигаем al вправо на 4 бита 
        ;!для получения каждой отдельной шестнадцатеричной цифры, чтобы затем преобразовать её в соответствующий символ и записать в строку результата.
        cmp al, 10
        jl for1_9
        add al, 'A' - 10 ;! поставить a,будет вывод маленьких
        jmp print_digit

    for1_9:
        add al, '0'

    print_digit:
        mov [si], al
        inc si
        shl bx, 4
        loop cycle_itoh
        ; mov ax, offset result
        mov sp, bp
        pop bp
        ret

itoh endp

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  конец hex

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ввод/вывод строки

;!!!!!dz7 - string.asm посмотреть!!!!!!
; читает строку с клавиатуры (либо max_len - 1 байт, либо до перевода строки) и сохраняет её в память, 
; при этом дописывает в конец строки завершающий 0
print_str proc near  ;!этот был до этого
    mov ah,09h
    int 21h 

    mov dx,offset new_line
    mov ah,09h
    int 21h
    ret
print_str endp

; выводит символ на экран (младший байт переданного аргумента)
_putchar proc near
    push bp
    mov bp, sp
    
    mov dx, word ptr [bp + arg1]
    mov ah, 02h
    int 21h
    
    mov sp, bp
    pop bp
    ret
_putchar endp  

_getstr proc near
    push bp
    mov bp, sp
    
    dec word ptr [bp + arg2] ; уменьшаем требуемую длину на 1 (max_len - 1)
    mov bx, word ptr [bp + arg1] ; адрес начала строки
    mov si, 0 ; счётчик
    mov cx, 15
 
getscyc: 
    ; cmp si, word ptr [bp + 6] ;! 4 - arg1 , 6 -arg2    ;!!!!!!ТУТ СРАВНИВАЮ С МАКСИМАЛЬНОЙ ДЛИНОЙ СТРОКИ
    cmp si,cx

    je getsret
    
    call _getchar
    
    cmp al, 10
    je getsret
    cmp al, 13
    je getsret
    
    mov byte ptr [bx], al
    inc bx
    inc si
    jmp getscyc
    
getsret:
    mov byte ptr [bx], 0 ;!тут был 0
    call _putnewline
    mov sp, bp
    pop bp
    ret
_getstr endp

; выводит на экран возврат каретки (\r) и перевод строки (\n), т.е. переводит вывод на новую строку
_putnewline proc near
    push bp
    mov bp, sp
    
    mov dx, 10
    push dx
    call _putchar
    add sp, 2
    
    mov dx, 13
    push dx
    call _putchar
    add sp, 2
    
    mov sp, bp
    pop bp
    ret
_putnewline endp

; читает символ с клавиатуры и возвращает его (считанный символ - младший байт (al) регистра ax)
_getchar proc near
    push bp
    mov bp, sp
    
    mov ah, 01h
    int 21h
    
    mov sp, bp
    pop bp
    ret
_getchar endp

 ;находит длинну строки (до завершающего нуля), адрес которой является аргументом
_strlen proc near
    push bp
    mov bp, sp
    
    mov bx, word ptr [bp + 4] 
    xor ax, ax ; счётчик (ax)

lencyc:    
    cmp byte ptr [bx], 0 ;!и тут был 0
    je lenret
    inc ax
    inc bx
    jmp lencyc
    
lenret:    
    mov sp, bp
    pop bp
    ret
_strlen endp
    
; выводит строку на экран (до завершающего нуля), адрес которой передан в качестве аргумента
_putstr proc near
    push bp
    mov bp, sp
    
    ; находим длину строки
    push word ptr [bp + 4] 
    call _strlen
    add sp, 2
    
    ; выводим строку
    mov cx, ax
    mov dx, word ptr [bp + 4]
    mov ah, 40h
    mov bx, 1
    int 21h
    
    mov sp, bp
    pop bp
    ret
_putstr endp
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! конец ввода/вывода

 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! start text 
start_text proc near 
    mov ah,09h
    mov dx, offset choice
    int 21h

    mov ah,01h
    int 21h
    sub al,'0'

    cmp al,1
    je calculate_10 ;! step_10
    cmp al,2 
    je calculate_hex ;! step_hex

    mov dx,offset new_line 
    mov ah,09h
    int 21h

    mov ah,09h
    mov dx,offset another_choice
    int 21h
    call _exit_valid

    ret
start_text endp
 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! end start_text
calculate_10 proc near

    push bp
    mov bp, sp 
    
    call _putnewline

    mov di,1

    mov sp, bp
    pop bp
    ret
calculate_10 endp

calculate_hex proc near

    push bp
    mov bp, sp 
    
    call _putnewline

    mov di,2

    mov sp, bp
    pop bp
    ret
calculate_hex endp

 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! выбираем куда кидать на проверку
my_choice proc near 

    cmp di,1
    je func_10
    cmp di,2 
    je func_hex

my_choice endp
 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! start check valid

;!!!!!!!!!!! start if al = '-',знак - должен стоять на первом месте
check_minus1 proc near 
    dec cx
    inc di
    cmp di,12h ;! первый символ 11h, 12 смотрим,потому что иначе дальше никак регистр di не увеличить,чтоб дальше по строке пошел
    je check_num1

    jmp nevalid_

check_minus1 endp

check_minus2 proc near 
    dec cx
    inc di
    cmp di,1Ah
    je check_num2

    jmp nevalid_

check_minus2 endp
;!!!!!!!!!!! end 

;!!!!!!!!!!! start ,что если num состоит из 6 символов,то на первом первом должен быть знак -
check_first1 proc near 
    dec cx
    cmp al,'-'
    je check_first1_to_back 

    jmp nevalid_

check_first1 endp

check_first1_to_back proc near 
    inc di
    jmp check_num1

check_first1_to_back endp

check_first2 proc near 
    dec cx
    cmp al,'-'
    je check_first2_to_back 

    jmp nevalid_

check_first2 endp

check_first2_to_back proc near 
    inc di
    jmp check_num2

check_first2_to_back endp
;!!!!!!!!!!! end

check_symbol_10 proc near

    mov dx,offset num1
    push dx 
    call _strlen 
    add sp,2
    mov cx,ax

    mov di,offset num1 ;0011

    check_num1:
        mov al,[di]

        cmp cx,6 ;! это не работает для проверки из 123456
        je check_first1

        cmp al,'-'
        je check_minus1

        cmp al, 30h
        jl nevalid_
        cmp al,39h
        jg nevalid_
        inc di
    loop check_num1

    xor dx,dx

    mov dx, offset num2
    push dx
    call _strlen
    mov cx,ax
    add sp, 2
    
    mov di,offset num2 ;0019
    check_num2:
        mov al,[di]

        cmp cx,6
        je check_first2

        cmp al,'-'
        je check_minus2

        cmp al, 30h
        jl nevalid_
        cmp al,39h
        jg nevalid_
        inc di
    loop check_num2

    cmp byte ptr [di], 0  ; Проверка на завершение строки
    jz end_of_string  ; Если конец строки достигнут, завершаем проверку
   
    end_of_string:
        mov dx, offset valid
        call print_str
        ret 

    nevalid_:

        mov dx, offset neval_
        call print_str

        call _exit_valid

check_symbol_10 endp 

check_bukva1 proc near
    cmp al, 61h
    jl nevalid_

    cmp al,66h
    jg nevalid_
    inc di 
    dec cx
    jmp check_hex1
check_bukva1 endp
;!61-66
check_bukva2 proc near
    cmp al, 61h
    jl nevalid_

    cmp al,66h
    jg nevalid_
    inc di
    dec cx
    jmp check_hex2

check_bukva2 endp

check_symbol_hex proc near 
    mov dx,offset num1
    push dx 
    call _strlen 
    add sp,2
    mov cx,ax

    mov di,offset num1 ;0011

    check_hex1:
        mov al,[di]
        cmp al,0
        je perexod

        cmp cx,5 ;! 5 если без -, поставить 6 если также,что hex число может быть с -
        je nevalid_

        ; cmp al,'-'
        ; je check_minus1

        cmp al, 30h
        jl nevalid_
        cmp al,39h
        jg check_bukva1
        inc di
    loop check_hex1
    perexod:
        xor dx,dx

        mov dx, offset num2
        push dx
        call _strlen
        mov cx,ax
        add sp, 2

        mov di,offset num2 ;0019

    check_hex2:
        mov al,[di]

        mov al,[di]
        cmp al,0
        je exit_perexod

        cmp cx,5 
        je nevalid_

        ; cmp al,'-'
        ; je check_minus2

        cmp al, 30h
        jl nevalid_
        cmp al,39h
        jg check_bukva2
        inc di
    loop check_hex2

    exit_perexod:
        cmp byte ptr [di], 0  ; Проверка на завершение строки
        jz end_of_string  ; Если конец строки достигнут, завершаем проверку
        ; jmp check_symbol  

    end_of_string_hex:
        mov dx, offset valid
        call print_str
        ret 

    nevalid_hex:

        mov dx, offset neval_
        call print_str

        call _exit_valid
check_symbol_hex endp
check_operand proc near 

    mov al, byte ptr [si]
; Сравниваем его с допустимыми операндами
; "+" - 0x2B
; "-" - 0x2D
; "*" - 0x2A
; "/" - 0x2F
; "%" - 0x25
    cmp al,2Bh
    je operand_ok
    cmp al,2Dh
    je operand_ok
    cmp al,2Ah
    je operand_ok
    cmp al, 2Fh
    je operand_ok
    cmp al, 25h
    je operand_ok

    ; Если не является допустимым операндом, переходим к обработке ошибки
    jmp err_oper

    operand_ok:
        mov dx,offset operand_okey
        call print_str

        jmp exit_check

    err_oper:
        mov dx, offset operand_bad
        call print_str

        ; Завершение программы с кодом ошибки
        call _exit_valid

    exit_check:
        ret

check_operand endp 

; count_minus_num1 proc near 
;     inc cx 
;     jmp back_to_num2
; count_minus_num1 endp

; count_minus_num2 proc near 

;     inc cx 
;     jmp back_to_operand
; count_minus_num2 endp

; count_minus_operand proc near
;     inc cx
;     cmp cx ,2 ;! -a - b => operand + -> flag_minus = -1, res  = (num1 + num2)*flag_minus, начинаем a c +1 индекса и b с +1
;     ; je 2_minus
;     cmp cx, 3 ;! -a - -b => (flag_minus * a) + b -> a c +1,b с +1
; count_minus_operand endp
; uproshenie_sum_neg proc near
;     ;!сделали условно проверки на знак у num1,num2,operand
;     ;! закинули в operand новое значение - если понадобилось 
;     ;! после этого кидаем в atoi

;     ;!я прохожусь по всей строке моей,и считаю количество минусов
;     ;! можно и не проходится по всей,а посмотреть на
;     ;! начало num1,num2,operand
;     ;?я могу это сделать,тк до этого проверил уже на корректность ввода
;     mov dx,offset string_10
;     call print_str

;     mov al, [num1]   
;     cmp al, '-' 
;     ;!jmp в счетчик cx ,который предназначен для подсчета '-'
;     je  count_minus_num1
;     back_to_num2:
;         mov al,[num2]
;         cmp al,'-'
;         je count_minus_num2
;     back_to_operand:
;         mov al,[operand]
;         cmp al,'-'
;         je count_minus_operand

;     ; jmp atoi

; uproshenie_sum_neg endp


; uproshenie_umn_del proc near 
;     mov dx,offset string_10
;     call print_str
;     ; jmp 
; uproshenie_umn_del endp
func_10 proc near ;! переименовать в func_10 и func_hex
    push bp
    mov bp, sp

    ; Загружаем адрес начала строки в DI
    add num_sys,10
    xor si,si
    xor al,al
    mov si,offset operand

    call check_operand
    xor si,si

    mov dx,offset string
    call check_symbol_10 ;!вроде норм
    ;!-32768 до 32767 
    mov dx, offset num1 ;! закинули начало num1
    push dx
    mov dx, strlen_num1 ;! ее длину
    push dx
    call atoi

    add sp, 4
	mov word ptr [num1_calc], ax
	
	mov dx, offset num2
    push dx
    mov dx, strlen_num2
    push dx
    call atoi
    add sp, 4
	mov word ptr [num2_calc], ax
	
	mov dx, offset num1_calc
    push dx
    mov dx, offset num2_calc
    push dx
    
    call _calc

    add sp, 4
	mov dx, ax
	push dx
	call print_result
	add sp,2
	jmp _exit_good

    ;! 

    ;!теперь надо определиться со знаком,пройтись по строке,посчитать количество минусов
    ;! это для + и -
    ;? -a - -b  = -a + b,  3 минуса -> a*-1 operand + b
    ;? -a - b = -1*( a + b), res *-1,operand +
    ;? -a + b =  a - b,operand - 
    ;? a + -b = a - b,operand -
    ;? a + b = a + b,operand + 

    ;!для умножения/деления
    ;? -a * -b = a * b = a * b,минусы не учитываем
    ;? -a * b = a * -b = - a*b, домножаем res на -1
    
    
    ;!сюда атои добавить
    ;! потом функцию calc
    ;!тут itoa,возвращаем результат
    exit_all_check:
        ; Восстанавливаем базовый указатель стека

        mov sp, bp
        pop bp
        ret

func_10 endp 

func_hex proc near

    push bp
    mov bp, sp

    add num_sys,16
    xor si,si
    xor al,al
    mov si,offset operand

    call check_operand
    xor si,si

    mov dx,offset string
    call check_symbol_hex ;!вроде норм
    ;!-8000 до 7FFF
    mov dx, offset num1 ;! закинули начало num1 (0011 начало)
    push dx
    mov dx, strlen_num1 ;! ее длину
    push dx

    call atoh

    add sp, 4
	mov word ptr [num1_calc], ax
	
	mov dx, offset num2
    push dx
    mov dx, strlen_num2
    push dx
    call atoh
    add sp, 4
	mov word ptr [num2_calc], ax
	
	mov dx, offset num1_calc
    push dx
    mov dx, offset num2_calc
    push dx
    
    ; cwd
    call _calc

    add sp, 4
	mov dx, ax
	push dx
	call print_result
	add sp,2
	jmp _exit_good
    ;!сюда atoh добавить
    ;! потом функцию calc
    ;!тут itoh,возвращаем результат
    exit_all_check_hex:
        ; Восстанавливаем базовый указатель стека

        mov sp, bp
        pop bp
        ret
func_hex endp

 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! end check valid


;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! start calculate
; функция калькулятора (вызывает нужные функции: чтения строки, проверки строки, 
; перевода строк в числа, выполнения математической операции и вывода результата)
; при выполнении дополнительного задания, выводит соответствующее коду ошибки сообщение, если вызываемая функция завершилась неуспешно. 
print_result proc near
	push bp
    mov bp, sp
	
	mov cx, word ptr [bp + arg1]
	push cx
	
	mov dx , cx
	push dx
	xor bx,bx
	call itoh
	add sp, 2
	
    mov dx , offset result
	push dx
	call print_str
	add sp, 2

    mov dx,offset new_line  
    mov ah,09h
    int 21h

	pop cx

    xor dx,dx
    ;!  10 вывод работает вроде
	mov dx , cx
	push dx
	xor bx,bx
	call itoa
	add sp, 2
	
	mov dx , offset result
	push dx
	call print_str
	add sp, 2
	
	mov sp, bp
    pop bp
	ret
print_result endp 

addition:
	add ax,bx
	jo _exit_range
	jmp exit_calculation

subtraction:
    ; xchg ax, bx

    sub ax,bx
    jo _exit_range
	jmp exit_calculation
multiplication:
    imul bx
    jo _exit_range
	jmp exit_calculation

division:
    ; xchg ax, bx
    cmp bx,0
    je _exit_divzero
    cwd ; Расширить знак из ax в dx (dx:ax становится 32-битным делимым)
    idiv bx
    jmp exit_calculation

remainder:
    ; xchg ax, bx
    cmp bx,0
    je _exit_divzero
    cwd ; Расширить знак из ax в dx (dx:ax становится 32-битным делимым)
    idiv bx
    mov ax,dx
    jmp exit_calculation

exit_calculation proc near 

    ; cmp num_sys,16
    ; je back_10

    mov sp, bp
    pop bp
    ret
exit_calculation endp

; back_10:
;     call atoi
;     add num_sys,1
;     jmp exit_calculation

_calc proc near
    push bp
    mov bp, sp

    xor ax,ax
	xor bx,bx
    mov si, word ptr [bp + arg2]
	mov ax,[si] ;! в bx лежит первое число bx было

	mov di, word ptr [bp + arg1]
	mov bx , [di] ;!ax второе число ;ax было
	
	cmp operand,'+'
	je addition

	cmp operand,'-'
	je subtraction

    cmp operand,'*'
	je multiplication

    cmp operand,'/'
	je division

    cmp operand,'%'
	je remainder


   _calc endp

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! end calculate 

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! start parsing

error_parsing:

    mov dx, offset err_parsing_
    call print_str

    call _exit_valid

empty_string:

    mov al, [bx]  ;!это для проверки после num1 на два пробела
    cmp al, 20h
    je error_parsing

    mov dx, offset empty
    call print_str

    call _exit_valid


count_negative_num1 proc near

    inc dx
    cmp dx,2
    je error_parsing

    inc bx          
    inc si 
    jmp  read_num1
count_negative_num1 endp
count_negative_num2 proc near

    inc dx
    cmp dx,2
    je error_parsing

    inc bx          
    inc si
    jmp  read_num2
count_negative_num2 endp

parsing_ proc near
    ;! goto ds:0 в data segment !!! начало дата сегмента

    push bp
    push bx 
    push si 
    push di 

    mov bp, sp

    xor si,si 
    xor di,di

    mov bx, word ptr [bp + arg1]

    mov al, [bx]
    cmp al, 0 ; Сравниваем первый символ с нулём
    je empty_string
    
    xor al,al

    mov si, offset num1   
    ; mov di, offset operand  

    mov cx,30h ;15 + 15 ;!еще раз + 15 потому что у si изначального регистр 11,и после первого же символа прочтенного,он кидает в ошибку
    xor dx,dx

read_num1:
    ; cmp cx,si ;!лишнее можно и через bx проверять
    ; je error_parsing
    cmp bx,9 ;!>6 символов num1 ,9 т.к bx с 2 начинается и если >7 символов,то ошибка
    je error_parsing

    mov al, [bx]
    cmp al, ' '
    je end_read_num1  
    mov [si], al  

    cmp al,'-'
    je count_negative_num1

    inc bx          
    inc si          
    jmp read_num1
end_read_num1:
   
    mov byte ptr [si], 0  ; Завершаем строку num1 нулевым байтом 
    mov al, [num1]
    cmp al, 24h
    je empty_string 

    mov al, [bx+1]  ;пробел пропустили,операнд записали
    cmp al, 24h
    je empty_string
    cmp al, 20h
    je empty_string

    mov di, offset operand  

    mov [di], al

    mov al, [bx+2]  ;пробел пропустили,операнд записали
    cmp al,' '
    jne error_parsing

    add bx, 3 ;пробел,операнд,пробел

    xor si, si
    mov si, offset num2
    mov cx,1Fh ;! если num2 состоит из 6> символов
    xor di,di
    xor dx,dx

read_num2:

    mov al, [bx] ;было +1
    mov [si], al  

    cmp al, 0
    je end_read_num2 

    cmp al, ' '
    je error_parsing
    
    cmp bx,11h ;!конец num2 это для 15 символов выход из num2
    je end_read_num2

    cmp al,'-'
    je count_negative_num2

    cmp cx,si
    je error_parsing ;! сюда закинуть,что число превысило максимум

    inc bx        
    inc si
    inc di

    cmp di,7
    je error_parsing     

    jmp read_num2

end_read_num2:

    mov byte ptr [si], 0  ; Завершаем строку num2 нулевым байтом
    mov al, [num2]
    cmp al, 24h
    je empty_string
    cmp al, 20h
    je error_parsing  

    mov sp, bp
    pop di
    pop si
    pop bx
    pop bp
    ret

parsing_ endp

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!end parsing

start: ; вызов функции calc (модифицировать главную функцию программы не требуется)

    mov ax,stack
    mov ss,ax 
    mov ax,data 
    mov ds,ax 

    call start_text

    push dx
    mov dx, offset string
    push dx
    call _getstr
    add sp, 4 ;!4 было

    ;парсим на 3 переменные
    mov bx, offset string 
    push bx
    call parsing_
    add sp, 2

    mov dx, offset num1
    call print_str
    ;!strlen 1
    mov dx,offset num1
    push dx 
    call _strlen 
    add sp,2
    add ax,30h
    add strlen_num1,ax 

    mov dx, offset operand
    call print_str

    mov dx, offset num2
    call print_str
    ;!strlen 2
    mov dx,offset num2
    push dx 
    call _strlen 
    add sp,2
    add ax,30h
    add strlen_num2,ax 

    ;!проверка strlenov
    ; mov dx,offset strlen_num1
    ; call print_str
    ; mov dx,offset strlen_num2
    ; call print_str
 

    push dx
    call my_choice

    mov ax,4c00h
    int 21h
    
    ret
code ends

end start

com proc near 
;!! comments 
;! если вводим первое число 5 знаков появляется мусор в конце
;! и если вводим второе число 4+ знака тоже мусор
;! при вводе 12345 + 1234 ( в памяти лежит 12345 + 1234 пробел)
;? исправил ошибки выше,дело было в том,что завершал еще раз строку 0
;? хотя в функциях считывания это делалось за меня

;!-12345 - любое,если какое-то число из 6 символов то в переменные некорректно записывает
    ;?выше работает вроде
;! -12345 - -12345 не работает - err_parsing_ 
;! видимо проблема не из-за чисел, для -1234 - -12345 работает все хорошо 
;? возможно проблема появляется <=> символов в строке  = 15


;!!!!!!!!!!!!! не работает из-за того,что вводим максимально возможное количество символов,после конца num2,считывать начинает по новой
;!!!! upd - работает вроде нормально считывание для 10,теперь надо проверку на пустой num1,и вообще пустую строку
;!! upd 1234567 + 123 исправить ---- исправил
;! upd проверку на 2 пробела тоже вроде добавил,также проверки на num1 <=6 & num2 <= 6, num1 != 0,num2 != 0,op != 0
;! 12345 - -123456 не проходит проверку upd исправил вроде добавление di счетчика

;! с проверками на 10 вроде норм,дальше делаем my_choice 

;!добавлять в конец num1 и num2  завершающий 0!!!! для дальнейшей работы оно надо 
;? добавил в конец num1,num2 0,увеличил место для num1.num2 на 1,т.к из-за этого нуля,получалось,что в памяти числа накладывались друг на друга
;!!! ввод числа с - некорректно,он не проверяет,что - должен только в начале стоять,
;!!! но это думаю можно в проверке 10 исправить,а не в parsing

;! -12345 + 123456 не работает upd rabotaet

;! атои -123 неправильно конвертируется ,без - все окей
;!UPD для отриц работает нормально

;! 150 - -150 = -300 неправильно

;!переполнение суммы не работает 
;?upd работает вроде

;! -32767 -1 выводит вроде число,но c мусором
;! выводит в hex нормально,но в 10 выводится вроде норм,но в конце еще последний символ выводит,который стоит у вывода в hex

;?upd работает вроде благодря 221.222 строкам
;! вроде осталось только hex доделать, 10-чная норм работает
;! 312 строчка

;!в общем проблема hexa сейчас заключается в том,что мой hex обрабатывает по сути верно,но не так,как в остальной части кода
;? те условно 125 + 125 должно быть 00fa, а у меня считается как 024a,что тоже является верным!
;! надо понять,как из 024a переводить в 00fa, тогда будет все чики пуки

;!!! можно попробовать сделать так,что если у нас выбран hex calc,то мы считаем значение,то,которое получится это оставляем
;!! и после этого,мы переводим обратно в 10 систему,и только потом обратно в hex,
;? те 125 + 125 = 024a -> 024a -> в десятичную -> из 10 в hex -> и выводим

;!! еще один подход возможно правильный,у меня считываются маленькие буквы в atoh,поэтому мне надо уменьшать аски код на 20,чтобы считывало как большую
;! и тогда возможно все будет супер ????

;! выбираю hex calc 15 + 15 = 002A, а должно быть  1E!!!!
;?upd я балбес,это норма

;! -,+ вроде работает нормально

;!32766 + 1 невалидная строка в hex 
;? невалидная,потому что проверка на длину num1 стоит

;! 12 / 3 равно 6  оказывается в моем калькуляторе
;? upd и это правильно......

;!!!!!! все что с цифрами только в hex calc работает нормально,
;!!!!!! и hex res выводит норм,но 10 res некорректно

;!! все,что с буквами идет плохо

;! c / 2 = 9 (должно быть 6)
;? upd работает корректно с hex,только вывод в 10чку после hex неверный!!!!

;! в hex max len num = 4, if > error range, max num = 7fff

;!!!!! починить вывод 10 в hex calc,убрать лишние строки,доделать возвращаемый код ошибок в dx

;! 212 + 212 hex res = 01a8, dec res = 424
;! dec calc, 212 + 212 = в ax,dx лежит 01a8 , itoh заходим
;! в si(011e) началао result,в bx 01a8
;! itoa заходим в ax,dx 01a8, в bx система счисления(10)
;!?
;! hex calc,212 + 212,itoh вернул 01a8,
;! itoa: в di(011e) начало result в ax,dx 01a8, в bx 10
;! когда идет push в dx, буквы закидываются как 3A,3B..,те + 30
;?должно быть наверное иначе ??

;!вроде все работает,дело было в том,что в itoa в регистр bx
;? upd работает неправильно закидывалась система счисления..

;!32770 + 1 error
;! 228 * -10 = 2280 !!

;!66666,77777,88888
com endp 
