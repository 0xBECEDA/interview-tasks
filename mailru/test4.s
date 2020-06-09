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
    mov     (%rsp), %rsi
    call    printf

    mov     $0b011, %rbx
    pushq   %rbx

    mov     $format4, %rdi
    mov     (%rsp), %rsi
    call    printf

    mov     $16, %rcx
    push    %rcx

    mov     $format4, %rdi
    mov     %rsp, %rsi
    call    printf

    nop
    xor     %rax, %rax
	popq	%rbp
	ret
