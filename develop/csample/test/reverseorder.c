#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int main() {
    char str[] = "hello";
    printf("%s, %d\n", str, strlen(str)); 
    int j,i = 0;
    char temp = NULL;
    int len = strlen(str);
    for (i; i<len/2; i++) {
        temp = str[i];
        str[i] = str[len - i - 1];
        str[len - i -1] = temp;
        printf("%c - %c\n", str[i], str[len -i - 1]);
    }
    printf("%s\n", str); 
}
