##
# Assembler used:           Clang
# Assembly syntax:          x86 Intel
# CPU architecture:         Intel x86-64
# Platform architecture:    PC
# OS architecture:          Linux
##
# Program to demonstrate the SystemV AMD64 ABI while interfacing with the C library
# Will print out command-line arguments and argument count
# 
# Compile with: clang -fPIE -s uppercaser-linux-c.s -o uppercaser-linux-c
# 
# Author: @theonekevin on GitHub
##

.intel_syntax noprefix
.global main
.extern printf
.extern exit

.text

main:
    push    rbp
    mov     rbp, rsp

    # System V AMD64 ABI:
    #   rdi = argc (int, zero-extended en 64 bits)
    #   rsi = argv (char **)
    mov     r12, rdi            # r12 = argc
    mov     r13, rsi            # r13 = argv

    dec     r12                 # on ignore argv[0] → nombre d'arguments "utiles"

    # printf("Number of args: %d\n", argc-1)
    lea     rdi, [rip+msg1]     # 1er argument (format)
    mov     rsi, r12            # 2ème argument = argc-1
    xor     eax, eax            # aucun registre vectoriel utilisé (varargs)
    call    printf

    # Boucle sur les arguments
    mov     r14, 1              # i = 1
    add     r13, 8              # argv = &argv[1]

Lcompare:
    cmp     r12, r14
    jl      Lexit               # si i > argc-1 → fin

Lloop:
    # printf("Arg %d is \"%s\"\n", i, argv[i])
    lea     rdi, [rip+msg2]     # format
    mov     rsi, r14            # i
    mov     rdx, [r13]          # argv[i]
    xor     eax, eax
    call    printf

    inc     r14                 # i++
    add     r13, 8              # argv++
    jmp     Lcompare

Lexit:
    xor     edi, edi            # code de retour = 0
    call    exit                # ne revient pas

.data

msg1: .asciz "Number of args: %d\n"
msg2: .asciz "Arg %d is \"%s\"\n"
