; Colleen
%define SELF "; Colleen%1$c%%define SELF %2$c%3$s%2$c%1$csection .data%1$c    ; This comment is inside data section%1$c    fmt db SELF, 0%1$csection .text%1$c    global main%1$c    extern printf%1$cmain:%1$c    push rbp%1$c    mov rbp, rsp%1$c    lea rdi, [rel fmt]%1$c    mov rsi, 10%1$c    mov rdx, 34%1$c    lea rcx, [rel fmt]%1$c    mov r8, 34%1$c    xor rax, rax%1$c    call printf%1$c    xor rax, rax%1$c    leave%1$c    ret%1$c"
section .data
    ; This comment is inside data section
    fmt db SELF, 0
section .text
    global main
    extern printf
main:
    push rbp
    mov rbp, rsp
    lea rdi, [rel fmt]
    mov rsi, 10
    mov rdx, 34
    lea rcx, [rel fmt]
    mov r8, 34
    xor rax, rax
    call printf
    xor rax, rax
    leave
    ret
