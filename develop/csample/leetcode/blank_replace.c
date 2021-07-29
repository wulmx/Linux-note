#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int replace_blank(char *s, char *dest) {
    int i = 0;
    char tmp[2];
    for(i; i<strlen(s); i++) {
        sprintf(tmp, "%c", s[i]);
        if(!strcmp(tmp, " ")) {
            strcat(dest, "%20");
        } else {
            strcat(dest, tmp);
        }
    }    
    return 1;
}


char * replace_blank1(char *s) {
    int i = 0;
    char *dest;
    dest = (char *)malloc(sizeof(char) * 1000);
    char tmp[2];
    for(i; i<strlen(s); i++) {
        sprintf(tmp, "%c", s[i]);
        printf("%d\n", strlen(tmp));
        tmp[strlen(tmp)+1] = '\0';
        if(!strcmp(tmp, " ")) {
            strcat(dest, "%20");
        } else {
            strcat(dest, tmp);
        }
    }    
    return dest;
}

char * replace_blank2(char *s) {
    int i = 0;
    char *dest;
    dest = (char *)malloc(sizeof(char) * 30);
    char tmp[2];
    for(i; i<strlen(s); i++) {
        sprintf(tmp, "%c", s[i]);
        tmp[sizeof(tmp)-1] = '\0';
        if(!strcmp(tmp, " ")) {
            strcat(dest, "%20");
        } else {
            strcat(dest, tmp);
        }
    }    
    return dest;
}
char* replaceSpace(char* s){
    char *dest;
    dest = (char *)malloc(sizeof(char)*10001);
    int i = 0;
    char tmp[3];
    for(i; i<strlen(s); i++) {
        sprintf(tmp, "%c", s[i]);
        tmp[strlen(tmp)+1] = '\0';
        if(!strcmp(tmp, " ")) {
            strcat(dest, "%20");
        } else {
            strcat(dest, tmp);
        }   
    }    
    dest[strlen(dest)+1] = '\0';
    return dest;
}

char * replaceLocal(char *s) {
    int numb = 0;
    int alen = 0;
    int len = 0;
    for (int i=0; s[i] != '\0'; i++) {
        len++;
        if (s[i] == ' ') numb++;
    }
    int len1 = strlen(s);
    alen = len + numb * 2;
    for (int i=len-1; i>=0; i--) {
        if (s[i] == ' ') {
            s[alen--] = '0';
            s[alen--] = '2';
            s[alen--] = '%';
        } else {
            s[alen--] = s[i];
        }
    }
    return s;
}

int main(int argc, char * argv[]) {
    char s[20] ="i am wlm.  ";
    char *s1 =" wlm1";
    char s3[30] = "hello world ";
    printf("%s\n", replaceLocal(s3));
    printf("%d %d %c %d %d\n", sizeof(s1), strlen(s1), s1[2], sizeof(s), strlen(s));
    //char s[20]="   ";
    char *dest;
    dest = (char *)malloc(sizeof(char) * 30);
    //printf("%d\n", replace_blank(s, dest));
    printf("%s\n", replace_blank1(s));
    printf("%d %d %s\n", strlen(s), s[2], s);
    free(dest);
    char *s2 = "We are happy.";
    printf("%s\n", replaceSpace(s2));

}
