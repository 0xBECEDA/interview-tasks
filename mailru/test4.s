	.file	"test3.s"
	.section	.rodata

format4:
    .string "addr is %p\n"


    .global main
    .type	main, @function
    .text

main:
    pushq	%rbp
    mov     %rsp, %rbp

    mov     $format4, %rdi
    mov     %rsp, %rsi
    xor     %rax, %rax
    call    printf

    mov     $0b011, %rbx
    pushq   %rbx

    mov     $format4, %rdi
    mov     %rsp, %rsi
    xor     %rax, %rax
    call    printf

    mov     $10, %rcx
    push    %rcx

    mov     $format4, %rdi
    mov     %rsp, %rsi
    xor     %rax, %rax
    call    printf

    nop
    xor     %rax, %rax
    popq    %rbx
    popq    %rcx
	popq	%rbp
	ret
