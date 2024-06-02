.386


stack segment para stack
    db 65500 dup(?)
stack ends

data segment para public use16
    str_max db 6
    str_len db 0
    string db 6 dup('$')

    number dw 0
    str_num db 5 dup('$')
    new_line db 0dh,0ah,'$'

    value dw 12345
data ends

code segment para public use16
assume cs:code,ss:stack,ds:data 

start proc near
    mov ax,stack
    mov ss,ax 
    mov ax,data 
    mov ds,ax 

    mov dx,offset str_max
    call enter_
    
    mov di,offset string
    mov al,byte ptr [str_len]
    call atoi 

    add ax,word ptr[value]
    mov word ptr [number],ax

    mov ax,word ptr[number]
    mov di,offset str_num
    call itoa

    mov dx,offset str_num 
    call print_str

    mov ax,4c00h
    int 21h
    
    ret
start endp

enter_ proc near
    mov ah,0ah
    int 21h

    mov dx,offset new_line 
    mov ah,09h
    int 21h
    ret 
enter_ endp

print_str proc near
    mov ah,09h
    int 21h

    mov dx,offset new_line 
    mov ah,09h
    int 21h

    ret
print_str endp

atoi proc near
    push cx
    push dx ; в dx уже лежит адрес строки, а в cx - её длина
    push bx ; в регистре bx - адрес строки c числом, в регистре si - длина числа, функция возвращает в регистре di полученное число
    push bp 

    movzx cx,al ;загрузили длину строки
    mov bp,10
    xor ax,ax 
    xor bx,bx 


convert_atoi:
    mul bp ;резульат умножения в ax:dx

    mov bl,byte ptr[di] ;получаем посимвольно из строки
    inc di ;++идем дальше по строке
    sub bl,'0';получаем из строки значение  цифры '2'-'0' =  50 - 48 = 2

    add ax,bx 
    loop convert_atoi 
    ;восстанавливаем значения регистров
    pop bp
    pop bx 
    pop dx 
    pop cx
    ret 
atoi endp

itoa proc near
    push ax
    push cx 
    push bx
    push dx

    xor cx,cx
    mov bx,10 

convert_itoa:
    xor dx,dx
    div bx  ;в аx - частное в dx - остаток, те например для 123
    ;при первом делении будет ах - 12 dx 3 
    add dl,'0'; преобразуем обратно в аски
    push dx
    inc cx
    cmp ax,0 ; ax ?= 0
    jnz convert_itoa ;пока ax != 0 


to_string:
    pop dx ;извлекаем посимвольно из стэка
    mov byte ptr[di],dl
    inc di
    loop to_string 

    pop dx
    pop bx
    pop cx
    pop ax
    ret
itoa endp 

code ends
end start
