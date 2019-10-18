#include<stdio.h>
#include<stdlib.h>
#include<string.h>

void rmDuplicate1(char str[]);
void rmDuplicate2(char str1[], char str2[]);
void rmDuplicate3(char str[]);
void zipString(char str[], char str1[]);
void zipString1(char *input, int len, char *output);
void maxstring(char *input, int len, char *output);



void itoa(int n, char s[])
 {
     int i, sign;

     if ((sign = n) < 0)  /* record sign */
         n = -n;          /* make n positive */
     i = 0;
     do {       /* generate digits in reverse order */
         s[i++] = n % 10 + '0';   /* get next digit */
     } while ((n /= 10) > 0);     /* delete it */
     if (sign < 0)
         s[i++] = '-';
     s[i] = '\0';
     reverse(s);
} 

/* reverse:  reverse string s in place */
 void reverse(char s[])
 {
     int i, j;
     char c;

     for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
         c = s[i];
         s[i] = s[j];
         s[j] = c;
     }
}  

 main()
{
    char str[] = "CCB";
    printf("=====================================\n");
    printf("%s, %d, %d\n", str, sizeof(str), strlen(str));
    rmDuplicate1(str);

    char str1[] = "AABBCCdd";
    char str2[10];
    printf("=====================================\n");
    printf("%s, %d, %d\n", str2, sizeof(str2), strlen(str2));
    rmDuplicate2(str1, str2);

    char str3[] = "AABBCCdd";
    printf("=====================================\n");
    printf("%s, %d, %d\n", str3, sizeof(str3), strlen(str3));
    rmDuplicate3(str3);

    printf("=====================================\n");
    char str4[] = "aabbbc";
    char str5[10];

    printf("%s--%s\n", str4, str5);
    zipString(str4, str5);
    printf("%s--%s\n", str4, str5);

    printf("=====================================\n");
    char *input = "aabbbc";
    int len = strlen(input);
    char *output = (char *)malloc(sizeof(char) * len);
    zipString1(input, len, output);
    printf("%s--%s\n", input, output);

    printf("=====================================\n");
    char *input1 = "aaabbbbbcccccccczzzzzzzz";
    int len1 = strlen(input1);
    char *output1 = (char *)malloc(sizeof(char) * len);
    printf("%d %s %s\n", len1, input1, output1);
    maxString(input1, len1, output);
}

/* use \0 instead of duplicate char */
void rmDuplicate1(char str[]) {
    int cnt = strlen(str);
    int p = 0;
    int i = 0;
    int j = 0;

    for (i; i<cnt; i++)
    {
        if (str[i] != '\0')
            str[p++] = str[i];

        for (j=i+1; j<cnt; j++) {
            if (str[j] == str[i]) {
                str[j] = '\0';
            }
        }

        str[p] = '\0';
    }
    printf("%s, %d, %d \n", str, sizeof(str), strlen(str));

    char temp = NULL;

    /* bubble sort */ 
    for (i=0; i<strlen(str); i++){
        for(j=i+1; j<strlen(str); j++) {
            if (str[i] > str[j]) {
                temp = str[i];
                str[i] = str[j];
                str[j] = temp;
            }
        }
    }

    printf("%s, %d, %d\n", str, sizeof(str), strlen(str));

}

/* use a new array */
void rmDuplicate2(char str1[], char str2[]) {
    int cnt1 = strlen(str1);
    int cnt2 = 0;
    int flag = 0;
    int i = 0;
    int j = 0;

    for (i; i<cnt1; i++) {
        flag = 0;
        for(j; j<cnt2; j++) {
            if (str1[i] == str2[j])  flag = 1;
        }

        if (flag == 0)  str2[cnt2++] = str1[i];
    }
    str2[cnt2] = '\0';
    printf("%s, %d, %d\n", str2, sizeof(str2), strlen(str2));
}

void rmDuplicate3(char str[]) {
    int len = strlen(str);
    int ascii[128] = {0};
    int p = 0;
    int i;

    for (i=0; i<len; i++) {
        if (ascii[str[i]] == 0) {
            ascii[str[i]] = 1;
            str[p++] = str[i];
        }
    }
    str[p] = '\0';
    printf("%s, %d, %d\n", str, sizeof(str), strlen(str));
}


void zipString(char str[], char str1[]) {
    int len = strlen(str);
    int i = 0;
    int j = 0;
    int p = 1;


    for (i; i<len; i++) {
        printf("%d--\n", i);
        while (str[i] != '\0' && str[i] == str[i+1]) {
            printf("i i+1 is %c %c\n", str[i], str[i+1]);
            p++;
            i++;
        }
        printf("p is %d\n", p);
        if (p == 1) {
            str1[j] = str[i];
            j++;
        }
        else{
            /* for linux c has't itoa, so can't  int(4byte) -> char(int) */
            str1[j] = p + '0';
            //itoa(p, & str1[j]);
            str1[j+1] = str[i];
            j = j+2;
            p = 1;
        }
    }
    str1[j] = '\0';
    printf("output is %s\n", str1);
}

void zipString1(char *input, int len, char *output) {
    int i = 0;
    int j = 0;
    int p = 1;

    for (i; i<len; i++) {
        printf("%d--\n", i);
        while (input[i] != '\0' && input[i] == input[i+1]) {
            printf("i i+1 is %c %c\n", input[i], input[i+1]);
            p++;
            i++;
        }
        printf("p is %d\n", p);
        if (p == 1) {
            output[j] = input[i];
            j++;
        }
        else{
            /* for linux c has't itoa, so can't  int(4byte) -> char(int) */
            //str1[j] = (char)p;
            itoa(p, & output[j]);
            output[j+1] = input[i];
            j = j+2;
            p = 1;
        }
    }
    output[j] = '\0';
    printf("output is %s\n", output);
}

void maxString(char * input, int len, char * output) {
    int count[10];
    char element[10];
    int i = 0;
    int j = 0;
    int p = 1;
    int maxcnt = 0;
    char maxasc = '0';
    for (i; i<len; i++) {
        printf("%d--\n", i);
        
        while (input[i] != '\0' && input[i] == input[i+1]) {
            printf("i i+1 is %c %c\n", input[i], input[i+1]);
            p++;
            i++;
        }
        count[j] = (int)p;
        if (p > maxcnt) maxcnt = p;

        element[j] = input[i];
        if (input[i] > maxasc) maxasc = input[i];

        printf("==%d %c\n", count[j], element[j]);
        p = 1;
        j++;
    }

    for (i=0; i<maxcnt; i++) {
        output[i] = maxasc;
    }
    printf("output is %s\n", output);
}
