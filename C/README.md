# Dr_Quine - C Language

## เกี่ยวกับโปรเจค

Dr_Quine คือโปรเจคที่สร้างโปรแกรม self-replicating (Quine) 3 แบบในภาษา C

---

## 1. Colleen.c - Basic Quine

### หลักการทำงาน
โปรแกรมที่พิมพ์โค้ดของตัวเองออกมาทาง stdout

### โครงสร้างโค้ด

```c
/* Colleen */
#include <stdio.h>

/*
    This comment is outside main
*/

void ft(void)
{
    /* This comment is inside function */
    char *s = "...format string...";
    printf(s, 10,10,10,34,s,34,10,10,10,10);
}

int main(void)
{
    /*
        This comment is inside main
    */
    ft();
    return (0);
}
```

### เทคนิค Quine แบบ C

**1. Format String เก็บโครงสร้างทั้งหมด:**
```c
char *s = "/* Colleen */%c#include <stdio.h>%c%c/*%c...%c*/%c%cvoid ft(void)...";
```

**2. Arguments คือ:**
- `10` = `\n` (newline)
- `34` = `"` (double quote)
- `s` = pointer to format string itself

**3. การใส่ quote รอบ string:**
```c
printf("%c%s%c", 34, s, 34);
// output: "...string..."
```

### Flow การทำงาน

1. `main()` เรียก `ft()`
2. `ft()` ประกาศ `char *s` พร้อม format string
3. `printf(s, ...)` แทนที่ `%c`, `%s` ด้วย arguments
4. ผลลัพธ์คือโค้ดทั้งหมดเหมือนต้นฉบับ

### Compile & Run
```bash
gcc -Wall -Wextra -Werror src/Colleen.c -o exc/Colleen
./exc/Colleen > tmp_Colleen
diff src/Colleen.c tmp_Colleen  # ควรไม่มีความแตกต่าง
```

### จุดที่ต้องระวัง
- **ห้ามมี newline ท้ายไฟล์** (หลัง closing brace)
- Format string ต้อง escape `"` และ `%` ให้ถูก
- จำนวน arguments ต้องตรงกับจำนวน `%c` และ `%s`

---

## 2. Grace.c - File Creator Quine

### หลักการทำงาน
สร้างไฟล์ `Grace_kid.c` ที่เหมือนกับตัวเองทุกอย่าง โดย**ไม่อ่านไฟล์ต้นฉบับ**

### โครงสร้างโค้ด

```c
/* Grace */
#include <stdio.h>
#include <stdlib.h>

#define FILE_NAME "Grace_kid.c"
#define CODE "...format string..."

void grace(void)
{
    FILE *f = fopen(FILE_NAME, "w");
    if (f == NULL)
        return;
    fprintf(f, CODE, 10,10,10,34,FILE_NAME,34,10,34,CODE,34,10,34,34,10,10);
    fclose(f);
}

int main(void)
{
    grace();
    return (0);
}
```

### เทคนิค #define Macro

**1. แยก filename เป็น macro:**
```c
#define FILE_NAME "Grace_kid.c"
```
ทำให้ง่ายต่อการเปลี่ยนชื่อไฟล์

**2. Format String ใน #define:**
```c
#define CODE "/* Grace */%c#include <stdio.h>%c..."
```
เก็บโครงสร้างทั้งหมดไว้ใน macro

**3. ใช้ fprintf แทน printf:**
```c
fprintf(file, FORMAT, args...);
// เขียนลงไฟล์แทนพิมพ์ออก stdout
```

### Arguments ที่ใช้ (17 ตัว)

```c
fprintf(f, CODE,
    10,             // %c = \n หลัง #include <stdio.h>
    10,             // %c = \n
    10,             // %c = \n
    34,             // %c = " ก่อน FILE_NAME
    FILE_NAME,      // %s = "Grace_kid.c"
    34,             // %c = " หลัง FILE_NAME
    10,             // %c = \n
    34,             // %c = " ก่อน CODE
    CODE,           // %s = format string
    34,             // %c = " หลัง CODE
    10,             // %c = \n
    34,             // %c = " ในโค้ด
    34,             // %c = " ในโค้ด
    10,             // %c = \n
    10              // %c = \n
);
```

### Flow การทำงาน

1. `main()` เรียก `grace()`
2. เปิดไฟล์ `Grace_kid.c` ด้วย `fopen()`
3. `fprintf()` เขียนโครงสร้างลงไฟล์
4. ปิดไฟล์ด้วย `fclose()`
5. ไฟล์ที่ได้เหมือนต้นฉบับทุกประการ

### Compile & Run
```bash
gcc -Wall -Wextra -Werror src/Grace.c -o exc/Grace
./exc/Grace
diff src/Grace.c Grace_kid.c  # ควรไม่มีความแตกต่าง
```

### Error Handling
```c
if (f == NULL)
    return;  // ถ้าเปิดไฟล์ไม่ได้ ออกทันที
```

---

## 3. Sully.c - Self-Decrementing Quine

### หลักการทำงาน
- เริ่มด้วย `int i = 5`
- สร้าง `Sully_4.c` (i - 1)
- compile และรัน `Sully_4` → สร้าง `Sully_3.c`
- วนต่อจนถึง `Sully_0.c`
- **Sully_0 จะไม่ compile หรือรันต่อ**

### โครงสร้างโค้ด

```c
/* Sully */
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    int i = 5;
    char *s = "...format string...";
    char filename[100];
    char cmd[500];
    FILE *f;
    
    if (i <= 0)
        return (0);
    
    // สร้างชื่อไฟล์ Sully_(i-1).c
    sprintf(filename, "Sully_%d.c", i - 1);
    
    // เปิดไฟล์
    f = fopen(filename, "w");
    if (f == NULL)
        return (1);
    
    // เขียนโค้ดลงไฟล์ (i-1)
    fprintf(f, s, 10,10,10,10,10,i-1,...);
    fclose(f);
    
    // ถ้า i-1 > 0 ให้ compile และ execute
    if (i - 1 > 0)
    {
        sprintf(cmd, "gcc Sully_%d.c -o Sully_%d && ./Sully_%d", 
                i-1, i-1, i-1);
        system(cmd);
    }
    
    return (0);
}
```

### Flow การทำงาน (Step by Step)

**Sully.c (i=5) รัน:**
```
1. เช็ค i <= 0? → No
2. สร้าง "Sully_4.c" พร้อม i = 4
3. เช็ค i-1 > 0? (4 > 0) → Yes
4. gcc Sully_4.c -o Sully_4 && ./Sully_4
```

**Sully_4 (i=4) รัน:**
```
1. เช็ค i <= 0? → No
2. สร้าง "Sully_3.c" พร้อม i = 3
3. เช็ค i-1 > 0? (3 > 0) → Yes
4. gcc Sully_3.c -o Sully_3 && ./Sully_3
```

**...วนต่อ...**

**Sully_1 (i=1) รัน:**
```
1. เช็ค i <= 0? → No
2. สร้าง "Sully_0.c" พร้อม i = 0
3. เช็ค i-1 > 0? (0 > 0) → No
4. ไม่ compile, ไม่รัน → จบ
```

### ไฟล์ทั้งหมดที่ถูกสร้าง (10 ไฟล์)

```
Sully_4.c, Sully_4
Sully_3.c, Sully_3
Sully_2.c, Sully_2
Sully_1.c, Sully_1
Sully_0.c          (ไม่มี executable)
```

### Format String Arguments (31 ตัว)

```c
fprintf(f, s,
    10, 10, 10, 10, 10,  // newlines หลัง includes
    i - 1,               // %d = ค่า i ใหม่
    10,                  // newline
    34,                  // " quote
    s,                   // %s format string
    34,                  // " quote
    10, 10,              // newlines
    ...
    // รวม 31 arguments
);
```

### ข้อสำคัญ!

**1. ต้องเช็ค i ก่อนทำอะไร:**
```c
if (i <= 0)
    return (0);  // ไม่ทำอะไรถ้า i <= 0
```

**2. ต้องเช็คก่อน compile/execute:**
```c
if (i - 1 > 0)  // Sully_0 จะไม่ถูกรัน
    system(cmd);
```

**3. ทุกรอบ i ลดลง 1:**
```c
sprintf(filename, "Sully_%d.c", i - 1);
fprintf(f, s, ..., i - 1, ...);
```

### Compile & Run
```bash
gcc -Wall -Wextra -Werror src/Sully.c -o exc/Sully
./exc/Sully

# ตรวจสอบไฟล์ที่ถูกสร้าง
ls Sully_*.c  # ควรได้ Sully_4.c ~ Sully_0.c
ls Sully_[0-9]  # ควรได้ Sully_4 ~ Sully_1 (ไม่มี Sully_0)

# ตรวจสอบ i value
grep "int i" src/Sully.c  # i = 5
grep "int i" Sully_4.c    # i = 4
grep "int i" Sully_0.c    # i = 0
```

---

## เทคนิคสำคัญที่ใช้ทั่วทั้ง 3 โปรแกรม

### 1. Quine Pattern
```c
char *s = "format string with %c%s%c";
printf(s, 34, s, 34);
// output: "format string with "...""
```

### 2. Comment Placement
- Comment นอก function
- Comment ใน function
- Comment ใน main

### 3. String Formatting

**ใส่ newline:**
```c
printf("Line1%cLine2", 10);  // 10 = \n
```

**ใส่ quote:**
```c
printf("%c%s%c", 34, str, 34);  // 34 = "
// output: "str"
```

**ใส่ตัวเลข:**
```c
printf("i = %d", i);
```

### 4. File Operations

**เปิดไฟล์:**
```c
FILE *f = fopen("filename.c", "w");
if (f == NULL)
    return;  // error handling
```

**เขียนไฟล์:**
```c
fprintf(f, format, args...);
```

**ปิดไฟล์:**
```c
fclose(f);
```

### 5. System Commands

**รัน shell command:**
```c
system("gcc file.c -o file && ./file");
```

**สร้าง command string:**
```c
char cmd[500];
sprintf(cmd, "gcc Sully_%d.c -o Sully_%d", i, i);
system(cmd);
```

---

## ข้อควรระวัง

### 1. Format String Counting
- นับ `%c`, `%s`, `%d` ให้ถูกต้อง
- Arguments ต้องตรงกับจำนวน format specifier
- **ผิดทำให้ segmentation fault**

### 2. Trailing Newline
- **Colleen และ Sully**: ห้ามมี newline หลัง `}`
- **Grace**: ต้องมี newline หลัง `}`

### 3. Escaping
- `"` = ใช้ `%c` กับ 34
- `\n` = ใช้ `%c` กับ 10
- `%% ` = escape % ใน format string (ถ้าต้องการพิมพ์ %)

### 4. Macro ใน Grace
```c
#define FILE_NAME "Grace_kid.c"
#define CODE "..."
```
ต้องอยู่ก่อน function definitions

---

## Debugging Tips

### ดูค่า format string
```bash
# Compile with debug info
gcc -g src/Colleen.c -o Colleen_debug

# Run with gdb
gdb ./Colleen_debug
(gdb) break ft
(gdb) run
(gdb) print s
```

### เช็ค output
```bash
./exc/Colleen > output.c
diff src/Colleen.c output.c
```

### นับ arguments
```python
# Python script เพื่อนับ %
format_str = "...your format string..."
print("% count:", format_str.count('%c') + format_str.count('%s') + format_str.count('%d'))
```

---

## Testing

```bash
# Build all
make

# Test Colleen
./exc/Colleen > tmp_Colleen
diff src/Colleen.c tmp_Colleen

# Test Grace  
./exc/Grace
diff src/Grace.c Grace_kid.c

# Test Sully
./exc/Sully
ls Sully_*.c | wc -l  # Should be 5 files
diff src/Sully.c Sully_0.c  # Only i value should differ
```

---

## Project Structure

```
C/
├── src/
│   ├── Colleen.c   # Basic quine
│   ├── Grace.c     # File creator
│   └── Sully.c     # Self-decrementing
├── obj/            # Object files
├── exc/            # Executables
├── Makefile
└── README.md
```

---

## References

- [Quine (computing) - Wikipedia](https://en.wikipedia.org/wiki/Quine_(computing))
- [The Quine Page](https://www.nyx.net/~gthompso/quine.htm)
- [C printf format](https://www.cplusplus.com/reference/cstdio/printf/)
