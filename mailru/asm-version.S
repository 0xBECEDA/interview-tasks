	.file	   "asm-version.s"
	.section	.rodata

allocation_error_msg:
	.string	"NULL pointer. Allocation memory error!\n"

	.text

	.globl	main
	.type	main, @function

main:

    pushq	%rbp                   # пролог
	movq	%rsp, %rbp

    subq	$200, %rsp             # резерв памяти

    movq	stdin(%rip), %rdx      # грузим адрес stdin

    leaq	-72(%rbp), %rdi        # грузим адрес, куда следует записывать прочитанное
	movl	$64, %esi              # кол-во байт, которые надо считать
	call	fgets

    xorl	%eax, %eax

    movl	$32, %edx              # устанавливаем базу системы счисления
    leaq	-72(%rbp), %rdi        # грузим адрес, откуда чистать строку
	call	strtoul


    leaq	-72(%rbp), %rdx        # сравниваем прочитаное с тем, что получили на вход
    cmpq	 %rdx, %rax
	jne	     success
    jmp      exit

success:
    mov	    %rax, -80(%rbp)        # сохранили число, полученное из строки

    mov     $64, %rcx              # установили счетчик

count_bits:                        # считаем, сколько бит занимает число
    rcl     $1, %rax
    jb      stop_count
    dec     %rcx
    jmp     count_bits

stop_count:
    mov	    %rcx, -88(%rbp)        # сохранили кол-во бит, которое занимает число

allocate_memory:                   # выделяем память
    mov     -80(%rbp), %rax

    add      $1, %rcx              # добавляем 1, чтоб учесть перевод строки
    imul     %rax, %rcx            # посчитали, сколько байт нужно для всех чисел от
                                   # 0 до прочитанного из stdin

    mov	    %rcx, -142(%rbp)       # сохранили это кол-во байт

    mov	    -142(%rbp), %rdi       # выделяем нужное кол-во памяти
    call	malloc

    cmp     $0, %rax               # проверяем возвращенный указатель
    je      allocation_error

allocation_success:
    mov     %rax, -102(%rbp)       # сохранили указатель на выделенную память
    mov     %rax, -118(%rbp)

    mov     $0, %rbx               # загрузили начальное значение для генератора чисел
    mov     %rbx, -110(%rbp)

    mov     $0b1100000000000000000000000000000000000000000000000000000000000000, %rdx
    mov    -88(%rbp), %rcx

    mov     $64, %rax
    sub     %rcx, %rax

    jmp     create_check_number

allocation_error:                        # в случае если память выделить не удалось

    mov	    $allocation_error_msg, %rdi  # печатаем сообщение об ошибке и выходим из проги
	movl	$0, %eax
	call	puts
    jmp     exit

create_check_number:                     # создаем число-проверку
    shr     $1, %rdx
    dec     %rax

    cmp     $0, %rax
    jne     create_check_number

    mov     %rdx, -150(%rbp)             # сохраняем число-проверку
    mov     %rdx, -158(%rbp)

generate_params:                   # генерируем числа-параметры
    mov   -110(%rbp), %rbx         # получили текущее значение
    cmp   -80(%rbp), %rbx          # сравниваем с введенным пользователем числом
    je     print_in_stdout         # если равны - мы досигли максимума, выход

    inc    %rbx                    # иначе увеличить значение
    mov    %rbx, -110(%rbp)        # сохранить обновленное значение в стеке

    mov    -150(%rbp), %rax
    mov    %rax, -158(%rbp)

loop:
    mov   -110(%rbp),  %rdx        # взяли число-парамер
    mov   -158(%rbp),  %rbx        # взяли число-проверку

    and   %rbx, %rdx               # обнулить лишние разряды, результат в rdx
    cmp   $1, -158(%rbp)
    je    prepare_num
    cmp   %rdx, -158(%rbp)
    je    generate_params

    mov   -158(%rbp),  %rbx
    shr    $1, %rbx
    mov    %rbx, -158(%rbp)
    jmp    loop

prepare_num:
    mov	    -88(%rbp), %rcx        # получили счетчик (сколько бит занимет число)
    mov     -110(%rbp), %rbx       # получили число-параметр

    mov     $64, %rax              # высчитываем, сколько старших разрядов надо пропустить
    sub     %rcx, %rax
    mov     %rax, %rcx

scroll_zero_bits:                 # сдвинули биты, чтоб пропустить старшие нулевые разряды
    rcl     $1, %rbx
    dec     %rcx
    cmp     $0, %rcx

    ja      scroll_zero_bits
    mov	    -88(%rbp), %rcx

print_num_into_memory:            # заполняем выделенную память числами
    rcl     $1, %rbx
    dec     %rcx

    jnb     print_0               # если влаг cf = 0, то идем печатать 0, иначе 1

print_1:
    mov     -118(%rbp), %rax      # получаем адрес, куда будем записывать число

    movl     $49, (%rax)          # записываем его аски-код

    add     $1, %rax              # сдвигаемся на 1 байт и сохраняем новый указатель
    mov     %rax, -118(%rbp)

    cmp     $0, %rcx              # число кончилось?
    jne     print_num_into_memory # нет, печаетаем дальше

    movl    $10, (%rax)           # иначе записать аски-код перевода строки
    add     $1, %rax              # сдвинуться на байт и сохранить новый указатель
    mov     %rax, -118(%rbp)

    jmp     generate_params       # генерим новое число

print_0:                          # все аналогично, только в память пишется 0
    mov     -118(%rbp), %rax

    movl     $48, (%rax)

    add     $1, %rax
    mov     %rax, -118(%rbp)

    cmp     $0, %rcx
    jne     print_num_into_memory

    movl    $10, (%rax)
    add     $1, %rax
    mov     %rax, -118(%rbp)

    jmp      generate_params

print_in_stdout:                 # вывод всех чисел из выделенной памяти
    mov $1, %rdi
    mov -102(%rbp), %rsi
    mov -142(%rbp), %rdx

    call write

exit:
    add     $200, %rsp
	movl	$0, %eax
	leave
	ret
