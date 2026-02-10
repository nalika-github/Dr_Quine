# Dr_Quine - Assembly (NASM x86-64)

## เกี่ยวกับโปรเจค

Dr_Quine คือโปรเจคที่สร้างโปรแกรม self-replicating (Quine) 3 แบบในภาษา Assembly

---

## พื้นฐาน Assembly (NASM x86-64)

### โครงสร้างไฟล์ Assembly

ไฟล์ Assembly แบ่งออกเป็น **sections** หลัก 3 ส่วน:

```asm
section .data      ; เก็บข้อมูลที่มีค่าเริ่มต้น (read-write)
    msg db "Hello", 0
    num dq 42

section .bss       ; เก็บข้อมูลที่ยังไม่มีค่า (reserved space)
    buffer resb 256

section .text      ; เก็บโค้ดคำสั่ง (instructions)
    global main
    extern printf
main:
    ; code here
```

**ประเภทข้อมูล:**
- `db` - define byte (1 byte)
- `dw` - define word (2 bytes)
- `dd` - define double word (4 bytes)
- `dq` - define quad word (8 bytes)
- `resb` - reserve bytes (ใน .bss)

### Registers (x86-64)

**General Purpose Registers (รีจิสเตอร์ทั่วไป 64-bit):**

```
┌─────────┬──────────────────────────────────────────┐
│ 64-bit  │ ความหมาย                                │
├─────────┼──────────────────────────────────────────┤
│ rax     │ Accumulator, ค่าที่ return             │
│ rbx     │ Base register                           │
│ rcx     │ Counter, argument ตัวที่ 4             │
│ rdx     │ Data register, argument ตัวที่ 3       │
│ rsi     │ Source index, argument ตัวที่ 2        │
│ rdi     │ Destination index, argument ตัวที่ 1   │
│ rbp     │ Base pointer (stack frame)              │
│ rsp     │ Stack pointer                           │
│ r8-r15  │ รีจิสเตอร์ทั่วไปเพิ่มเติม                │
└─────────┴──────────────────────────────────────────┘
```

**การเข้าถึงขนาดที่ต่างกัน:**
```
┌──────┬──────┬──────┬──────┐
│  64  │  32  │  16  │   8  │
├──────┼──────┼──────┼──────┤
│ rax  │ eax  │  ax  │  al  │  (ah = high 8)
│ rbx  │ ebx  │  bx  │  bl  │
│ rcx  │ ecx  │  cx  │  cl  │
│ rdx  │ edx  │  dx  │  dl  │
│ rsi  │ esi  │  si  │ sil  │
│ rdi  │ edi  │  di  │ dil  │
└──────┴──────┴──────┴──────┘
```

**รีจิสเตอร์พิเศษ:**
- `rip` - Instruction pointer (ตัวชี้ตำแหน่งคำสั่ง)
- `rflags` - Flags register (เก็บ carry, zero, sign ฯลฯ)

### Instructions พื้นฐาน

#### 1. การย้ายข้อมูล (Data Movement)
```asm
mov rax, 42          ; rax = 42 (ค่าตายตัว)
mov rax, rbx         ; rax = rbx (รีจิสเตอร์ไปรีจิสเตอร์)
mov rax, [rbx]       ; rax = *rbx (โหลดจาก memory)
mov [rbx], rax       ; *rbx = rax (เก็บไปที่ memory)

lea rax, [rel msg]   ; rax = address ของ msg (load effective address)
```

**ความแตกต่าง `mov` vs `lea`:**
```asm
msg db "Hello", 0
mov rax, [rel msg]   ; rax = ค่าที่อยู่ใน msg (ชี้ไป)
lea rax, [rel msg]   ; rax = address ของ msg
```

#### 2. การคำนวณทางคณิตศาสตร์ (Arithmetic)
```asm
add rax, 5           ; rax += 5 (บวก)
sub rax, 3           ; rax -= 3 (ลบ)
inc rax              ; rax++ (เพิ่ม 1)
dec rax              ; rax-- (ลด 1)
imul rax, rbx        ; rax *= rbx (คูณแบบ signed)
idiv rbx             ; rax = rdx:rax / rbx, rdx = เศษที่เหลือ
```

#### 3. การดำเนินการทางตรรกะ (Logical Operations)
```asm
and rax, rbx         ; rax &= rbx (AND)
or  rax, rbx         ; rax |= rbx (OR)
xor rax, rax         ; rax ^= rax (เทคนิคทำให้เป็น 0: rax = 0)
not rax              ; rax = ~rax (NOT)
```

#### 4. การเปรียบเทียบและกระโดด (Comparison & Jumps)
```asm
cmp rax, rbx         ; เปรียบเทียบ rax กับ rbx (ตั้งค่า flags)
test rax, rax        ; ตรวจสอบว่า rax เป็น 0 หรือไม่

; Conditional jumps (กระโดดตามเงื่อนไข)
je  .label           ; กระโดดถ้าเท่ากัน (ZF=1)
jne .label           ; กระโดดถ้าไม่เท่ากัน (ZF=0)
jl  .label           ; กระโดดถ้าน้อยกว่า (SF≠OF)
jle .label           ; กระโดดถ้าน้อยกว่าหรือเท่ากัน
jg  .label           ; กระโดดถ้ามากกว่า
jge .label           ; กระโดดถ้ามากกว่าหรือเท่ากัน

; Unconditional jump (กระโดดไม่มีเงื่อนไข)
jmp .label           ; กระโดดเสมอ
```

**ตัวอย่าง:**
```asm
mov rax, 5
cmp rax, 10
jl  .less_than       ; ถ้า rax < 10, jump to .less_than
; code if rax >= 10
jmp .done
.less_than:
; code if rax < 10
.done:
```

#### 5. การจัดการ Stack (Stack Operations)
```asm
push rax             ; rsp -= 8; [rsp] = rax (เก็บค่าลง stack)
pop  rax             ; rax = [rsp]; rsp += 8 (ดึงค่าจาก stack)
```

**Stack เติบโตไปทางล่าง:**
```
ที่อยู่สูง (High Address)
    ↑
    │  push → rsp ลดลง
    │  pop  → rsp เพิ่มขึ้น
    ↓
ที่อยู่ต่ำ (Low Address)
```

### การเรียกใช้ฟังก์ชัน (Function Calls - System V ABI)

**Calling Convention (กฏการส่ง arguments):**

```asm
; Arguments (ตามลำดับ):
; rdi, rsi, rdx, rcx, r8, r9, [stack]

; ตัวอย่าง: printf(format, arg1, arg2, arg3)
lea rdi, [rel format]    ; arg ตัวที่ 1: format string
mov rsi, 10              ; arg ตัวที่ 2: ค่า 10
mov rdx, 34              ; arg ตัวที่ 3: ค่า 34
lea rcx, [rel mystr]     ; arg ตัวที่ 4: pointer
xor rax, rax             ; rax = 0 (ไม่มี vector registers)
call printf              ; เรียกฟังก์ชัน
```

**Function Prologue/Epilogue (เปิด/ปิดฟังก์ชัน):**

```asm
main:
    push rbp             ; เก็บ base pointer เดิม
    mov rbp, rsp         ; rbp = stack pointer ปัจจุบัน
    sub rsp, 32          ; จองพื้นที่ local 32 bytes
    
    ; เนื้อหาฟังก์ชัน...
    
    leave                ; เท่ากับ: mov rsp,rbp; pop rbp
    ret                  ; return ไปหา caller
```

**กฏ Stack Alignment:**
- Stack ต้อง aligned to 16 bytes ก่อน `call`
- `push rbp` = -8 bytes → ไม่ aligned
- `sub rsp, X` โดยที่ X % 16 == 8 → aligned แล้ว

```asm
push rbp             ; rsp -= 8 (now misaligned)
mov rbp, rsp
sub rsp, 32          ; rsp -= 32 (8+32=40, but relative difference is 32)
                     ; Now aligned for call
```

### Syntax เฉพาะของ NASM

#### 1. Position Independent Code (โค้ดที่ไม่ขึ้นกับตำแหน่ง)
```asm
; วิธีที่ไม่ดี - absolute addressing (แพ้ relocation)
mov rax, [msg]

; วิธีที่ดี - RIP-relative addressing
mov rax, [rel msg]
lea rdi, [rel format]
```

#### 2. Macros (%define)
```asm
%define NEWLINE 10
%define QUOTE 34

section .data
    msg db "Hello", NEWLINE, 0

section .text
    mov rsi, QUOTE       ; mov rsi, 34
```

**Macro with String:**
```asm
%define CODE "section .text%cmain:%c    ret%c"

; ใช้ในโค้ด:
lea rsi, [rel format]
; format db CODE, 0

; %c จะถูก replace ด้วย argument ที่ส่งไปใน printf
```

#### 3. Positional Arguments (printf-style)
```asm
; ใน format string:
; %1$c = argument ตัวที่ 1 เป็น char
; %2$s = argument ตัวที่ 2 เป็น string
; %3$d = argument ตัวที่ 3 เป็น int

section .data
    fmt db "Value: %1$d, Char: %2$c, String: %3$s", 0

section .text
    lea rdi, [rel fmt]
    mov rsi, 42          ; %1$d
    mov rdx, 65          ; %2$c = 'A'
    lea rcx, [rel str]   ; %3$s
    call printf
```

**การ Escape % ใน NASM:**
- `%` → ใช้ใน directive (`%define`)
- `%%` → กลายเป็น `%` ในโค้ด final

```asm
%define SELF "%%define SELF"
; จะได้: "%define SELF" ในไฟล์
```

### Syscalls (Linux x86-64)

**วิธีการ:**
```asm
mov rax, syscall_number
mov rdi, arg1
mov rsi, arg2
mov rdx, arg3
mov r10, arg4           ; หมายเหตุ: r10 ไม่ใช่ rcx
mov r8,  arg5
mov r9,  arg6
syscall                 ; เรียก kernel
; ค่าที่ return อยู่ใน rax
```

**Syscalls ที่ใช้บ่อย:**
```
┌────────┬──────────┬─────────────────────┐
│ หมายเลข │ ชื่อ     │ Arguments           │
├────────┼──────────┼─────────────────────┤
│   0    │ read     │ fd, buf, count      │
│   1    │ write    │ fd, buf, count      │
│   2    │ open     │ filename, flags, m  │
│   3    │ close    │ fd                  │
│  60    │ exit     │ status              │
└────────┴──────────┴─────────────────────┘
```

**ตัวอย่าง open:**
```asm
mov rax, 2               ; syscall: open
lea rdi, [rel filename]  ; const char *filename
mov rsi, 0x241           ; flags: O_WRONLY|O_CREAT|O_TRUNC
mov rdx, 0644o           ; mode: rw-r--r-- (octal)
syscall
; rax = file descriptor (หรือ -1 ถ้าเกิด error)
```

### รูปแบบการ Addressing หน่วยความจำ

```asm
mov rax, 42              ; immediate (ค่าตายตัว)
mov rax, rbx             ; register direct (ตรงจากรีจิสเตอร์)
mov rax, [rbx]           ; register indirect (ผ่าน pointer)
mov rax, [rbx + 8]       ; base + displacement
mov rax, [rbx + rcx*4]   ; base + index*scale
mov rax, [rbx + rcx*4 + 8] ; base + index*scale + displacement
```

**Scale:** 1, 2, 4, หรือ 8 (ใช้กับ array indexing)

```asm
; int array[10];
; array[5] = 100;
lea rbx, [rel array]
mov ecx, 5
mov dword [rbx + rcx*4], 100   ; 4 = sizeof(int)
```

### คอมเมนต์ (Comments)
```asm
; คอมเมนต์บรรทัดเดียว (ด้วย semicolon)

mov rax, 42    ; คอมเมนต์แบบ inline
```

---

## 1. Colleen.s - Quine พื้นฐาน

### หลักการทำงาน
โปรแกรมที่พิมพ์โค้ดของตัวเองออกมาทาง stdout (output มาตรฐาน)

### โครงสร้างโค้ด

```asm
section .data
    fmt db "; Colleen",10,"section .data",...
    ; format string ที่เก็บทั้งโปรแกรม
```

**เทคนิค:**
- ใช้ `printf` กับ format string
- format string เก็บโครงสร้างโปรแกรมทั้งหมด
- ใช้ `%c%s%c` เพื่อใส่ quote (34 = `"`)

**การใช้ %c%s%c:**
```asm
mov rsi, 34        ; rdx = " (double quote)
lea rdx, [rel fmt] ; r8 = pointer to string
mov rcx, 34        ; rcx = " (closing quote)
call printf        ; printf(fmt, 34, fmt, 34)
```

ผลลัพธ์: `"...format string..."`

### การ Compile และรัน
```bash
nasm -f elf64 Colleen.s -o obj/Colleen.o
gcc -no-pie obj/Colleen.o -o exc/Colleen
./exc/Colleen > tmp
diff Colleen.s tmp  # ควรไม่มีความแตกต่าง
```

---

## 2. Grace.s - Quine ที่สร้างไฟล์

### หลักการทำงาน
สร้างไฟล์ `Grace_kid.s` ที่เหมือนกับตัวเองทุกอย่าง โดยไม่อ่านไฟล์ต้นฉบับ

### โครงสร้างโค้ด

```asm
%define SELF "; Grace%1$c%%define SELF %2$c%3$s%2$c..."
%define GLOBAL_MAIN global main
%define MAIN main:

section .data
    self db SELF, 0
    kidsname db "Grace_kid.s", 0
```

**เทคนิค NASM %define:**
- `%define` = macro ของ NASM
- `%%macro` = escape % (จะกลายเป็น `%macro` ในไฟล์)
- `%1$c` = positional argument (แบบ printf)

**Positional Arguments:**
```asm
mov rdx, 10        ; %1$c = newline
mov rcx, 34        ; %2$c = "
lea r8, [rel self] ; %3$s = pointer to SELF string
call dprintf       ; dprintf(fd, SELF, 10, 34, SELF)
```

**การเปิดไฟล์ด้วย syscall:**
```asm
mov rax, 2         ; syscall number: open
lea rdi, [rel kidsname]
mov rsi, 0x241     ; O_WRONLY | O_CREAT | O_TRUNC
mov rdx, 0644q     ; permissions: rw-r--r--
syscall
```

### การ Compile และรัน
```bash
nasm -f elf64 Grace.s -o obj/Grace.o
gcc -no-pie obj/Grace.o -o exc/Grace
./exc/Grace
diff Grace.s Grace_kid.s  # ควรไม่มีความแตกต่าง
```

---

## 3. Sully.s - Quine ที่ลดค่าตัวเอง

### หลักการทำงาน
- เริ่มด้วย `i = 5` (comment บรรทัดแรก)
- สร้าง Sully_4.s (i = 4)
- Sully_4 compile และรัน → สร้าง Sully_3.s
- วนต่อจนถึง Sully_0.s
- **Sully_0.s ไม่ถูก compile หรือ execute**

### โครงสร้างโค้ด

```asm
; i = 5
%define SELF "; i = %1$d%2$c%%define SELF %3$c%4$s%3$c..."

section .data
    i dq 5
    filename_fmt db "Sully_%d.s",0
    compile_fmt db "nasm ... && gcc ... && ./Sully_%d",0
```

**Flow การทำงาน:**

1. **เช็ค i:**
   ```asm
   mov rax, [rel i]
   cmp rax, 0
   jle .exit          ; ถ้า i <= 0 ออกทันที
   ```

2. **สร้างไฟล์ Sully_(i-1).s:**
   ```asm
   dec rax            ; i - 1
   sprintf(filename, "Sully_%d.s", i-1)
   fopen(filename, "w")
   fprintf(fd, SELF, i-1, 10, 34, SELF, 34)
   fclose(fd)
   ```

3. **เช็คว่าควร compile/execute หรือไม่:**
   ```asm
   mov rax, [rbp-16]  ; i-1
   cmp rax, 0
   jle .exit          ; ถ้า i-1 <= 0 ไม่ compile (Sully_0)
   ```

4. **Compile และ Execute:**
   ```asm
   sprintf(cmd, "nasm ... Sully_%d && gcc ... && ./Sully_%d", i-1, ...)
   system(cmd)
   ```

**การใช้ Positional Arguments (%1$d, %2$c, ...):**
```asm
; fprintf(file, format, i-1, '\n', '"', self, '"')
mov rdx, rax       ; %1$d = i-1
mov rcx, 10        ; %2$c = newline
mov r8, 34         ; %3$c = "
lea r9, [rel code_fmt]  ; %4$s = SELF
mov qword [rsp], 34     ; stack: %5$c = " (closing)
```

### Stack Alignment สำคัญ!

System V ABI ต้องการ stack aligned to 16 bytes ก่อนเรียก function:
```asm
push rbp           ; -8 bytes
mov rbp, rsp
sub rsp, 32        ; จอง space (ต้องเป็นเลขคู่ * 8)
```

### การ Compile และรัน
```bash
# ในโฟลเดอร์ test/
nasm -f elf64 ../Sully.s -o Sully.o
gcc -no-pie Sully.o -o Sully
./Sully

# จะได้ไฟล์ทั้งหมด 15 ไฟล์:
# Sully, Sully.o
# Sully_4.s, Sully_4.o, Sully_4
# Sully_3.s, Sully_3.o, Sully_3
# Sully_2.s, Sully_2.o, Sully_2
# Sully_1.s, Sully_1.o, Sully_1
# Sully_0.s (ไม่มี .o และไฟล์ executable)
```

---

## เทคนิคสำคัญที่ใช้ทั่วทั้ง 3 โปรแกรม

### 1. เทคนิค Quine
```c
char *s = "format string with %s";
printf(s, s);  // พิมพ์ format string แล้วแทนค่า %s ด้วยตัวมันเอง
```

### 2. การ Escape อักขระพิเศษ
- ใช้ `%c` กับ ASCII 34 สำหรับเครื่องหมาย `"`
- NASM: `%%` → `%` (escape เครื่องหมาย percent)
- Format: `%1$c` = positional argument แรก

### 3. System V x86-64 Calling Convention

**Register สำหรับ arguments:**
1. `rdi` - arg1
2. `rsi` - arg2  
3. `rdx` - arg3
4. `rcx` - arg4
5. `r8`  - arg5
6. `r9`  - arg6
7. stack - arg7, arg8, ...

**ตัวอย่าง fprintf:**
```asm
mov rdi, file_descriptor
lea rsi, [rel format_string]
mov rdx, arg1
mov rcx, arg2
mov r8, arg3
mov r9, arg4
mov qword [rsp], arg5
call fprintf
```

### 4. Position Independent Code (PIC)

ใช้ `[rel label]` แทน `[label]`:
```asm
lea rdi, [rel format]  ; ได้ address ที่ถูกต้อง
mov rax, [rel i]       ; อ่านค่า i
```

---

## การ Debug (แก้ไขข้อผิดพลาด)

### ดูค่าใน Register
```bash
gdb ./exc/Colleen
(gdb) break main
(gdb) run
(gdb) info registers
(gdb) x/s $rsi  # ดู string ที่ rsi ชี้
```

### ดู Syscall
```bash
strace ./exc/Grace
# จะเห็น open, write, close calls
```

### ตรวจสอบ Stack Alignment
```bash
(gdb) p $rsp
# ควรลงท้ายด้วย 0 (ตัวเลขที่หารด้วย 16 ลงตัว)
```

---

## ข้อควรระวัง

1. **ห้ามมี trailing newline** ท้ายไฟล์ (ยกเว้น Grace)
2. **Stack alignment** - function call ต้อง aligned to 16 bytes
3. **gcc ต้องใช้ `-no-pie`** สำหรับ position independent executable
4. **Format string ต้องนับ % ให้ถูก** - ผิดทำให้ segfault
5. **syscall numbers แตกต่างกันใน macOS และ Linux**

---

## การทดสอบ (Testing)

```bash
# Build ทั้งหมด
make

# Test script อัตโนมัติ
./test.sh

# Test แต่ละตัวเอง
./exc/Colleen > tmp && diff Colleen.s tmp
./exc/Grace && diff Grace.s Grace_kid.s

# Test Sully ในโฟลเดอร์ย่อย
mkdir test && cd test
nasm -f elf64 ../Sully.s -o Sully.o
gcc -no-pie Sully.o -o Sully
./Sully
ls -al | grep Sully | wc -l  # ควรได้ 15 ไฟล์
```

---

## เอกสารอ้างอิง

- [คู่มือ NASM](https://www.nasm.us/doc/)
- [System V ABI](https://wiki.osdev.org/System_V_ABI)
- [ตาราง Linux Syscalls x86-64](https://filippo.io/linux-syscall-table/)
- [Quine (computing) - Wikipedia](https://en.wikipedia.org/wiki/Quine_(computing))
