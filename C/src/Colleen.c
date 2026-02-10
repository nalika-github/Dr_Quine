/* Colleen */
#include <stdio.h>

int main(void)
{
    /* This comment is inside main */
    char *s = "/* Colleen */%c#include <stdio.h>%c%cint main(void)%c{%c    /* This comment is inside main */%c    char *s = %c%s%c;%c    printf(s, 10,10,10,10,10,10,34,s,34,10,10,10,10);%c    return 0;%c}";
    printf(s, 10,10,10,10,10,10,34,s,34,10,10,10,10);
    return 0;
}