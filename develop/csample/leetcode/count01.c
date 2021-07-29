#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int count1(int input) {
    int cnt = 0;
    while(input) {
        input &= input -1;
        cnt ++;
    }
    return cnt;
}

int count1_t(int input) {
    int ret = 0;
    int i = 0;
    for(i=0; i<32; i++) {
        if((input & (1<<i))) ret++;
    }
    return ret;
}
int main(int argc, char *argv[]) {
        int num = atoi(argv[1]);
        printf("%d\n", count1(num));
        printf("%d\n", count1_t(num));
}
