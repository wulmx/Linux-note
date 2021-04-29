#include <stdio.h>
#include <stdlib.h>

int rm_ele_o1(int *a, int val, int len) {
    int j = 0;
    int temp = 0;
    for(int i=0; i<len; i++) {
        if (a[i] != val) {
            a[j] = a[i];
            j ++;
        }
        printf("%d, %d, %d ,%d, %d\n", sizeof(a), a[i], a[j], i, j);
    }
    return j;
}

int main() {
    int a[] = {3, 4, 2, 3};
    for(int i=0; i<4; i++) printf("%d\t", a[i]);
    printf("\n");
    printf("%d\n", rm_ele_o1(a, 3, 4));
    for(int i=0; i<4; i++) printf("%d\t", a[i]);
    printf("\n");
}
