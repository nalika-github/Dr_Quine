; Grace
%define SELF "; Grace%1$c%%define SELF %2$c%3$s%2$c%1$c%%define GLOBAL_MAIN global main%1$c%%define MAIN main:%1$c%1$csection .data%1$cself db SELF, 0%1$ckidsname db %2$cGrace_kid.s%2$c, 0%1$c%1$csection .text%1$cextern dprintf%1$cGLOBAL_MAIN%1$c%1$c%%macro GRACE 0%1$cMAIN%1$cpush rbp%1$cmov rbp, rsp%1$clea rdi, [rel kidsname]%1$cmov rsi, 0x241%1$cmov rdx, 0644q%1$cmov rax, 2%1$csyscall%1$ccmp rax, 0%1$cjb .ret%1$c%1$cmov rdi, rax%1$clea rsi, [rel self]%1$cmov rdx, 10%1$cmov rcx, 34%1$clea r8, [rel self]%1$ccall dprintf%1$c.ret:%1$cleave%1$cret%1$c%%endmacro%1$cGRACE%1$c"
%define GLOBAL_MAIN global main
%define MAIN main:

section .data
self db SELF, 0
kidsname db "Grace_kid.s", 0

section .text
extern dprintf
GLOBAL_MAIN

%macro GRACE 0
MAIN
push rbp                ; set up base pointer
mov rbp, rsp            ; set up base pointer
lea rdi, [rel kidsname] ; prepare filename for syscall
mov rsi, 0x241          ; prepare flags for syscall
mov rdx, 0644q          ; prepare mode for syscall
mov rax, 2              ; syscall: sys_open
syscall                 ; invoke syscall
cmp rax, 0              ; check if syscall returned an error
jb .ret                 ; if error, jump to return

mov rdi, rax            ; file descriptor
lea rsi, [rel self]     ; prepare buffer for dprintf
mov rdx, 10             ; prepare newline character
mov rcx, 34             ; prepare double quote character
lea r8, [rel self]      ; prepare self for dprintf
call dprintf            ; call dprintf to write to file
.ret:                   ; return label
leave                   ; restore base pointer
ret                     ; return from main
%endmacro
GRACE                   ; run the GRACE macro
