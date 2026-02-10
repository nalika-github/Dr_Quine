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
    push rbp                    ; set up base pointer
    mov rbp, rsp                ; set up base pointer
    sub rsp, 32                 ; allocate space on stack
    mov rax, [rel i]            ; load i
    mov [rbp-8], rax            ; store i at rbp-8
    cmp rax, 0                  ; if i <= 0
    jle .exit                   ; return 0;
    dec rax                     ; i - 1
    mov [rbp-16], rax           ; store i - 1 at rbp-16
    lea rdi, [rel filename]         ; prepare filename for sprintf
    lea rsi, [rel filename_fmt]     ; prepare format string
    mov rdx, rax                    ; prepare i-1
    xor rax, rax                    ; clear rax for variadic function
    call sprintf                    ; sprintf(filename, filename_fmt, i - 1);
    lea rdi, [rel filename]         ; prepare filename for fopen
    lea rsi, [rel mode]             ; prepare mode for fopen
    call fopen                      ; open file
    cmp rax, 0                      ; if file pointer is NULL
    je .exit                        ; return 0;
    mov [rbp-24], rax               ; store file pointer
    mov rdi, rax                    ; prepare file pointer for fprintf
    lea rsi, [rel code_fmt]         ; prepare format string for fprintf
    mov rax, [rbp-16]               ; load i - 1
    mov rdx, rax                    ; prepare i - 1 for fprintf
    mov rcx, 10                     ; prepare newline character
    mov r8, 34                      ; prepare double quote character
    lea r9, [rel code_fmt]          ; prepare code_fmt for fprintf
    mov qword [rsp], 34             ; prepare double quote character on stack
    xor rax, rax                    ; clear rax for variadic function
    call fprintf                    ; fprintf(file, code_fmt, i - 1, 10, 34, code_fmt, 34);
    mov rdi, [rbp-24]               ; prepare file pointer for fclose
    call fclose                     ; fclose(file);
    mov rax, [rbp-16]               ; load i - 1
    cmp rax, 0                      ; if i - 1 <= 0
    jle .exit                       ; return 0;
    lea rdi, [rel cmd]              ; prepare cmd for sprintf
    lea rsi, [rel compile_fmt]      ; prepare format string for sprintf
    mov rdx, rax                    ; prepare i - 1 for sprintf
    mov rcx, rax                    ; prepare i - 1 for sprintf
    mov r8, rax                     ; prepare i - 1 for sprintf
    mov r9, rax                     ; prepare i - 1 for sprintf
    mov [rsp], rax                  ; prepare i - 1 on stack
    xor rax, rax                    ; clear rax for variadic function
    call sprintf                    ; sprintf(cmd, compile_fmt, i - 1, i - 1, i - 1, i - 1, i - 1);
    lea rdi, [rel cmd]              ; prepare cmd for system
    call system                     ; system(cmd);
.exit:
    xor rax, rax                    ; return 0
    leave                           ; restore base pointer
    ret                             ; return from main
