#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    int i = 5;
    if (i <= 0)
        return 0;
    char filename[256];
    sprintf(filename, "Sully_%d.c", i - 1);
    FILE *f = fopen(filename, "w");
    if (!f)
        return 1;
    char *s = "#include <stdio.h>%c#include <stdlib.h>%c%cint main(void)%c{%c    int i = %d;%c    if (i <= 0)%c        return 0;%c    char filename[256];%c    sprintf(filename, %cSully_%%d.c%c, i - 1);%c    FILE *f = fopen(filename, %cw%c);%c    if (!f)%c        return 1;%c    char *s = %c%s%c;%c    fprintf(f, s, 10,10,10,10,10,i-1,10,10,10,10,34,34,10,34,34,10,10,10,34,s,34,10,10,10,10,34,34,10,10,10,10);%c    fclose(f);%c    char cmd[512];%c    sprintf(cmd, %cgcc -Wall -Wextra -Werror -o Sully_%%d %%s && ./Sully_%%d%c, i-1, filename, i-1);%c    if (i - 1 > 0)%c        system(cmd);%c    return 0;%c}";
    fprintf(f, s, 10,10,10,10,10,i-1,10,10,10,10,34,34,10,34,34,10,10,10,34,s,34,10,10,10,10,34,34,10,10,10,10);
    fclose(f);
    char cmd[512];
    sprintf(cmd, "gcc -Wall -Wextra -Werror -o Sully_%d %s && ./Sully_%d", i-1, filename, i-1);
    if (i - 1 > 0)
        system(cmd);
    return 0;
}