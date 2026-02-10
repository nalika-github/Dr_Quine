; i = 5
%define SELF "; i = %1$d%2$c%%define SELF %3$c%4$s%3$c%2$csection .data%2$c    i dq %1$d%2$c    filename_fmt db %3$cSully_%%d.s%3$c,0%2$c    mode db %3$cw%3$c,0%2$c    compile_fmt db %3$cnasm -f elf64 Sully_%%d.s -o Sully_%%d.o && gcc -no-pie Sully_%%d.o -o Sully_%%d && ./Sully_%%d%3$c,0%2$c    code_fmt db SELF, 0%2$csection .bss%2$c    filename resb 256%2$c    cmd resb 512%2$csection .text%2$c    global main%2$c    extern sprintf, fopen, fprintf, fclose, system%2$cmain:%2$c    push rbp%2$c    mov rbp, rsp%2$c    sub rsp, 32%2$c    mov rax, [rel i]%2$c    mov [rbp-8], rax%2$c    cmp rax, 0%2$c    jle .exit%2$c    dec rax%2$c    mov [rbp-16], rax%2$c    lea rdi, [rel filename]%2$c    lea rsi, [rel filename_fmt]%2$c    mov rdx, rax%2$c    xor rax, rax%2$c    call sprintf%2$c    lea rdi, [rel filename]%2$c    lea rsi, [rel mode]%2$c    call fopen%2$c    cmp rax, 0%2$c    je .exit%2$c    mov [rbp-24], rax%2$c    mov rdi, rax%2$c    lea rsi, [rel code_fmt]%2$c    mov rax, [rbp-16]%2$c    mov rdx, rax%2$c    mov rcx, 10%2$c    mov r8, 34%2$c    lea r9, [rel code_fmt]%2$c    mov qword [rsp], 34%2$c    xor rax, rax%2$c    call fprintf%2$c    mov rdi, [rbp-24]%2$c    call fclose%2$c    mov rax, [rbp-16]%2$c    cmp rax, 0%2$c    jle .exit%2$c    lea rdi, [rel cmd]%2$c    lea rsi, [rel compile_fmt]%2$c    mov rdx, rax%2$c    mov rcx, rax%2$c    mov r8, rax%2$c    mov r9, rax%2$c    mov [rsp], rax%2$c    xor rax, rax%2$c    call sprintf%2$c    lea rdi, [rel cmd]%2$c    call system%2$c.exit:%2$c    xor rax, rax%2$c    leave%2$c    ret%2$c"
section .data
    i dq 5
    filename_fmt db "Sully_%d.s",0
    mode db "w",0
    compile_fmt db "nasm -f elf64 Sully_%d.s -o Sully_%d.o && gcc -no-pie Sully_%d.o -o Sully_%d && ./Sully_%d",0
    code_fmt db SELF, 0
section .bss
    filename resb 256
    cmd resb 512
section .text
    global main
    extern sprintf, fopen, fprintf, fclose, system
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov rax, [rel i]
    mov [rbp-8], rax
    cmp rax, 0
    jle .exit
    dec rax
    mov [rbp-16], rax
    lea rdi, [rel filename]
    lea rsi, [rel filename_fmt]
    mov rdx, rax
    xor rax, rax
    call sprintf
    lea rdi, [rel filename]
    lea rsi, [rel mode]
    call fopen
    cmp rax, 0
    je .exit
    mov [rbp-24], rax
    mov rdi, rax
    lea rsi, [rel code_fmt]
    mov rax, [rbp-16]
    mov rdx, rax
    mov rcx, 10
    mov r8, 34
    lea r9, [rel code_fmt]
    mov qword [rsp], 34
    xor rax, rax
    call fprintf
    mov rdi, [rbp-24]
    call fclose
    mov rax, [rbp-16]
    cmp rax, 0
    jle .exit
    lea rdi, [rel cmd]
    lea rsi, [rel compile_fmt]
    mov rdx, rax
    mov rcx, rax
    mov r8, rax
    mov r9, rax
    mov [rsp], rax
    xor rax, rax
    call sprintf
    lea rdi, [rel cmd]
    call system
.exit:
    xor rax, rax
    leave
    ret
