#include <stdio.h>
#include <stdlib.h>

int cac(int cnt) {
    int ret = 0;
    if (cnt == 1) return 1;
    else if (cnt == 2) return 2;
    else  ret += cac(cnt-1) + cac(cnt -2);
    return ret;
}

int main() {
    char in[20];
    gets(in);
    int f1=1; 
    int f2=2;
    int fn=0;
    printf("%d\n", cac(atoi(in)));
    return 0;
}
