# Dr_Quine - Assembly (NASM x86-64)

## เกี่ยวกับโปรเจค

Dr_Quine คือโปรเจคที่สร้างโปรแกรม self-replicating (Quine) 3 แบบในภาษา Assembly

---

## 1. Colleen.s - Basic Quine

### หลักการทำงาน
โปรแกรมที่พิมพ์โค้ดของตัวเองออกมาทาง stdout

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

### Compile & Run
```bash
nasm -f elf64 Colleen.s -o obj/Colleen.o
gcc -no-pie obj/Colleen.o -o exc/Colleen
./exc/Colleen > tmp
diff Colleen.s tmp  # ควรไม่มีความแตกต่าง
```

---

## 2. Grace.s - File Creator Quine

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

### Compile & Run
```bash
nasm -f elf64 Grace.s -o obj/Grace.o
gcc -no-pie obj/Grace.o -o exc/Grace
./exc/Grace
diff Grace.s Grace_kid.s  # ควรไม่มีความแตกต่าง
```

---

## 3. Sully.s - Self-Decrementing Quine

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

### Compile & Run
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
# Sully_0.s (ไม่มี .o และ executable)
```

---

## เทคนิคสำคัญที่ใช้ทั่วทั้ง 3 โปรแกรม

### 1. Quine Technique
```c
char *s = "format string with %s";
printf(s, s);  // พิมพ์ format string แล้วแทนค่า %s ด้วยตัวมันเอง
```

### 2. Escaping Special Characters
- ใช้ `%c` กับ ASCII 34 สำหรับ `"`
- NASM: `%%` → `%` (escape percent)
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

## การ Debug

### ดู Register Values
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

### ดู Stack Alignment
```bash
(gdb) p $rsp
# ควร end ด้วย 0 (multiple of 16)
```

---

## ข้อควรระวัง

1. **ห้ามมี trailing newline** ท้ายไฟล์ (ยกเว้น Grace)
2. **Stack alignment** - function call ต้อง aligned to 16 bytes
3. **gcc ต้องใช้ `-no-pie`** สำหรับ position independent executable
4. **Format string ต้องนับ % ให้ถูก** - ผิดทำให้ segfault
5. **syscall numbers แตกต่างกันใน macOS และ Linux**

---

## Testing

```bash
# Build all
make

# Test individually
./exc/Colleen > tmp && diff Colleen.s tmp
./exc/Grace && diff Grace.s Grace_kid.s

# Test Sully in subdirectory
mkdir test && cd test
nasm -f elf64 ../Sully.s -o Sully.o
gcc -no-pie Sully.o -o Sully
./Sully
ls -al | grep Sully | wc -l  # Should be 15
```

---

## References

- [NASM Manual](https://www.nasm.us/doc/)
- [System V ABI](https://wiki.osdev.org/System_V_ABI)
- [Linux Syscalls x86-64](https://filippo.io/linux-syscall-table/)
- [Quine (computing)](https://en.wikipedia.org/wiki/Quine_(computing))
