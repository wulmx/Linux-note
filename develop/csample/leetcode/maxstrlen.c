#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    char str1[] = "wlmmlm";
    char str2[] = "wlm";
    printf("%d, %d, %d, %d, %c\n", sizeof(str1), strlen(str1), sizeof(str2), sizeof(*str1), str2[3]);
    int cnt = 0;
    char tg[5];
    //tg[0] = 'w';
    //tg[1] = 'w';
    //printf("tg cnt is %s, %d, %d\n", tg, strlen(tg), sizeof(tg));
    for(int i=0; i<sizeof(str1); i++) {
        printf("%c\n", str1[i]);
        
        tg[i] = str1[i];
        for(int j=i+1; j<sizeof(str1); j++) {
            int flag = 0;
            cnt = strlen(tg);
            int temp = 0
            for(int k=0; k<cnt; k++) {
            //for(int k=0; k<strlen(tg); k++) {
                printf("tg cnt is %s, %d, %d, %d, %d %c %c\n", tg, strlen(tg),j, k, strncmp(&str1[j], &tg[k], 1), str1[j], tg[k]);
                if(!strncmp(&str1[j], &tg[k], 1)) {
                    printf("current cnt is %d\n", strlen(tg));
                    flag = 1;
                    break;
                }
                else {
                    temp ++;
                    tg[j] = str1[j];
                }
            }
            if (flag) break;
        }
    }

}
