; шаблон для зачётного задания №1 (калькулятор) с использованием стековых фреймов
.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8

stack segment para stack use16
db 65530 dup(?)
stack ends

data segment para public use16
str1 db 256 dup(?)
str2 db "Hello, World!","$"

num1 db 5 dup(?)
num2 db 5 dup(?)
operand db 1 dup(?)

data ends

code segment para public use16

assume cs:code,ds:data,ss:stack

; void putchar(int c)
; выводит символ на экран (младший байт переданного аргумента)
_putchar:
    push bp
    mov bp, sp
    
    mov dx, word ptr [bp + arg1]
    mov ah, 02h
    int 21h
    
    mov sp, bp
    pop bp
    ret
    
; int getchar()
; читает символ с клавиатуры и возвращает его (считанный символ - младший байт регистра ax)
_getchar:
    push bp
    mov bp, sp
    
    mov ah, 01h
    int 21h
    
    mov sp, bp
    pop bp
    ret

; int strlen(const char *str)
; находит длинну строки (до завершающего нуля), адрес которой является аргументом
_strlen: 
    push bp
    mov bp, sp
    
    mov bx, word ptr [bp + arg1] 
    xor ax, ax ; счётчик (ax)

lencyc:    
    cmp byte ptr [bx], 0
    je lenret
    inc ax
    inc bx
    jmp lencyc
    
lenret:    
    mov sp, bp
    pop bp
    ret
    
; void putstr(const char *str)
; выводит строку на экран (до завершающего нуля), адрес которой передан в качестве аргумента
_putstr: 
    push bp
    mov bp, sp
    
    ; находим длину строки
    push word ptr [bp + arg1] 
    call _strlen
    add sp, 2
    
    ; выводим строку
    mov cx, ax
    mov dx, word ptr [bp + arg1]
    mov ah, 40h
    mov bx, 1
    int 21h
    
    mov sp, bp
    pop bp
    ret
    
; void getstr(const char *str, int max_len)
; читает строку с клавиатуры (либо max_len байт, либо до перевода строки) и сохраняет её в память, 
; при этом дописывает в конец строки завершающий 0
_getstr:
    push bp
    mov bp, sp
    
    ; чтение строки
    mov cx, word ptr [bp + arg2]
    mov dx, word ptr [bp + arg1]
    mov ah, 3fh
    mov bx, 0
    int 21h
    
    ; добавление в конец завершающего нуля
    mov bx, word ptr [bp + arg1]
    add bx, ax ; добавляем к адресу начала строки длину считанной строки
    sub bx, 2 ; убираем из строки возврат каретки (\r) и перевод строки (\n)
    mov byte ptr [bx], 0

    mov sp, bp
    pop bp
    ret

; void putnewline()
; выводит на экран возврат каретки (\r) и перевод строки (\n), т.е. переводит вывод на новую строку
_putnewline:
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

; void exit(int code)
; завершает работу программы с кодом, переданным в качетве аргумента (кодом является младший байт аргумента)  
_exit:
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + arg1]
    mov ah, 4ch
	int 21h
    
    mov sp, bp
    pop bp
    ret
    
; void exit0()
; завершает работу программы с кодом 0 
_exit0:
    push bp
    mov bp, sp
    
    mov dx, 0
    push dx
    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret
    
; int atoi(const char *str)
; функция перевода строки в число
_atoi: 
    push bp
    mov bp, sp
    
    mov sp, bp
    pop bp
    ret

; void itoa(int num, char *str)
; функция перевода числа в строку    
_itoa: 
    push bp
    mov bp, sp
    
    mov sp, bp
    pop bp
    ret

; int check(const char *input_line)    
; функция проверки введённой строки на соответствие формату
; функция возвращает 1, если строка удовлетворяет формату, иначе возвращает 0
; при выполнении дополнительного задания, функция возвращает код 0 в случае успеха иначе код ошибки и при этом устанавливает флаг CF в 1. 
_check: 
    push bp
    mov bp, sp
    
    mov sp, bp
    pop bp
    ret

; void calc()    
; функция калькулятора (вызывает нужные функции: чтения строки, проверки строки, 
; перевода строк в числа, выполнения математической операции и вывода результата)
; при выполнении дополнительного задания, выводит соответствующее коду ошибки сообщение, если вызываемая функция завершилась неуспешно. 
_calc: 
    push bp
    mov bp, sp
    
    mov sp, bp
    pop bp
    ret

start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    
    mov dx, offset str2 
    mov ah, 09h        
    int 21h     
    
    call _calc
    call _exit0

code ends

end start