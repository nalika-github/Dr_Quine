#include <stdio.h>

/* This program creates a copy of itself named Grace_kid.c */

#define FILE_NAME "Grace_kid.c"
#define CODE "#include <stdio.h>%c%c/* This program creates a copy of itself named Grace_kid.c */%c%c#define FILE_NAME %c%s%c%c#define CODE %c%s%c%c#define FT() int main(){FILE *f=fopen(FILE_NAME,%cw%c);if(f){fprintf(f,CODE,10,10,10,10,34,FILE_NAME,34,10,34,CODE,34,10,34,34,10,10);fclose(f);}return 0;}%c%cFT()"
#define FT() int main(){FILE *f=fopen(FILE_NAME,"w");if(f){fprintf(f,CODE,10,10,10,10,34,FILE_NAME,34,10,34,CODE,34,10,34,34,10,10);fclose(f);}return 0;}

FT()