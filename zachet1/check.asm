_check: 
    push bp
    mov bp, sp
    
    mov si, word ptr [bp + arg1] ; адрес строки в si
    
    ; Проверяем, что строка не пустая
    mov al, byte ptr [si]
    cmp al, 0
    je check_error
    
    ; Проверяем первое число
    call _atoi ; пробуем конвертировать первое число
    jc check_error ; если конвертация не удалась, строка не соответствует формату
    
    ; Пропускаем пробел
    inc si
    mov al, byte ptr [si]
    cmp al, ' '
    je check_next
    jmp check_error
    
check_next:
    ; Проверяем операцию
    inc si
    mov al, byte ptr [si]
    cmp al, '+' ; поддерживаем только + операцию, остальные добавляются аналогично
    je check_operator_ok
    jmp check_error
    
check_operator_ok:
    ; Пропускаем пробел
    inc si
    mov al, byte ptr [si]
    cmp al, ' '
    je check_second_number
    jmp check_error
    
check_second_number:
    ; Пробуем конвертировать второе число
    inc si
    call _atoi
    jc check_error
    
    ; Проверка окончания строки
    inc si
    mov al, byte ptr [si]
    cmp al, 0
    jne check_error
    
    ; Все проверки пройдены успешно
    mov ax, 1 ; возвращаем 1 в случае успеха
    jmp check_end
    
check_error:
    stc ; устанавливаем флаг CF в 1, чтобы показать ошибку
    xor ax, ax ; возвращаем 0 в случае ошибки
    
check_end:
    mov sp, bp
    pop bp
    ret
