#include<stdio.h>
#include<stdlib.h>

int main() {
    int a[] = {3, 1, 6, 5};
    int len = sizeof(a)/sizeof(a[0]);
    printf("%d\n",sizeof(a));
    for (int i=0; i<len; i++) {
        int temp = 0;
        for(int j=0; j<len; j++) {
            //printf("%d, %d\n", a[i],a[j]);
            if(a[i] > a[j]) {
                temp = a[i];
                a[i] = a[j];
                a[j] = temp;
            }
        }
    }
    for (int k=0; k<len; k++) {
        printf("%d ", a[k]);
        printf("\n");
    }
}
