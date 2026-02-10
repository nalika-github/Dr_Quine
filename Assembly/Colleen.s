; Colleen
%define SELF "; Colleen%1$c%%define SELF %2$c%3$s%2$c%1$csection .data%1$c    ; This comment is inside data section%1$c    fmt db SELF, 0%1$csection .text%1$c    global main%1$c    extern printf%1$cmain:%1$c    push rbp%1$c    mov rbp, rsp%1$c    lea rdi, [rel fmt]%1$c    mov rsi, 10%1$c    mov rdx, 34%1$c    lea rcx, [rel fmt]%1$c    mov r8, 34%1$c    xor rax, rax%1$c    call printf%1$c    xor rax, rax%1$c    leave%1$c    ret%1$c"
section .data
    ; This comment is inside data section
    fmt db SELF, 0
section .text
    global main
    extern printf
main:
    push rbp            ; set up base pointer
    mov rbp, rsp        ; set up base pointer
    lea rdi, [rel fmt]  ; prepare format string
    mov rsi, 10         ; prepare newline character
    mov rdx, 34         ; prepare double quote character
    lea rcx, [rel fmt]  ; prepare fmt for printf
    mov r8, 34          ; prepare double quote character
    xor rax, rax        ; clear rax for variadic function
    call printf         ; call printf(fmt, 10, 34, fmt, 34);
    xor rax, rax        ; clear rax for return
    leave               ; restore base pointer
    ret                 ; return from main
