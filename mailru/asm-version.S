	.file	"asm-version.s"
	.section	.rodata

format:
    .string "%d"

format0:
    .string "\n"

format1:
    .string "number is %d\n"

format2:
    .string "true\n"

format3:
    .string "false\n"

    .global main
    .type	main, @function
    .text

# проверяет, есть ли у числа единицы в соседних битах

loop:
    pop     %rbx    # взять со стека число-проверку
    pop     %rdx    # взять со стека число-параметр

    mov     %rdx, %rax    # запомнить число-параметр
    mov     %rbx, %rsi    # запомнили число-проверку

    and     %rbx, %rdx    # обнулить лишние разряды, результат в rdx
    cmp     $1, %rsi      # сравниваем число-проверку с единицей
    je      true          # если равны, то выходим через exit_true
    cmp     %rdx, %rsi    # иначе сравниваем результат обнуления с числом-проверкой
    je      false         # если равны, выходм через exit_false

    shr     $1, %rsi      # иначе сдвинули 1 бит вправо у числа-проверки
    push     %rax         # отправили число-параметр в стек
    push     %rsi         # отправили число-проверку в стек

    jmp     loop

# генерирует числа-параметры, которые надо проанализировать
generate_params:
    pop   %rbx                       # получаем число-параметр прошлой итерации
    cmp   $0b1111111111111111, %rbx  # достигли максимального значения?

    je    exit                       # да, выходим

    inc   %rbx                       # нет, инкрементируем значение
    push  %rbx                       # отправляем значение-параметр в стек
    mov   $0b1100000000000000, %rax  # отправляем начальное число-проверку в стек
    push  %rax

    jmp   loop

# печатает число в бинарном представлении
print_bin_number:

    pop     %rcx            # получить счетчик
    pop     %rbx            # получить число, которое будем печатать
    rcl     $1, %bx
    dec     %rcx

    jnb     print_0         # если влаг cf = 0, то идем печатать 0
    jmp     print_1         # иначе идем печатать 1

print_1:
    push    %rcx            # сохраняем счетчик

    mov     $1, %rsi        # печатаем 1
    mov     $format, %rdi
    xor     %rax, %rax
    call    printf

    pop     %rcx            # проверяем счетчик
    cmp     $0, %rcx        # если 0, то оформляем конец числа
    je      end_of_num

    push    %rbx            # иначе отправляем число и счетчик в стек, выводим биты дальше
    push    %rcx
    jmp     print_bin_number

print_0:
    push    %rcx            # производим действия, аналогичные в print_1,
                            # но печатаем 0
    mov     $0, %rsi
    mov     $format, %rdi
    xor     %rax, %rax
    call    printf

    pop     %rcx
    cmp     $0, %rcx
    je      end_of_num

    push    %rbx
    push    %rcx

    jmp     print_bin_number

# оформляет конец строки выводимого бинарного числа
end_of_num:
    mov     $format0, %rdi  # печать перевода строки
    call    puts

    jmp     generate_params

main:
    pushq	%rbp
    mov     %rsp, %rbp

    mov     $0, %rdx      # начальное значение числа-параметра
    push    %rdx          # пушим его в стек

 	jmp     generate_params

# выход из программы
exit:
    nop
    xor     %rax, %rax
	popq	%rbp
	ret

# ветка выполняется в случае, если у числа нет единиц в соседних битах
true:
    push    %rax          # отправляем число-параметр в стек
    push    %rax

    mov     $16, %rcx     # устанавливаем счетчик битов
    push    %rcx

    jmp     print_bin_number

# ветка выполняется в случае, если число имеет соседствующие единицы
false:
    push    %rax
    #mov     $format3, %rdi
    #call    puts
    jmp     generate_params
