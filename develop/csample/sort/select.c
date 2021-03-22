#include<stdio.h>
#include<stdlib.h>

int main() {
    int a[] = {3, 1,12, 6, 5};
    int len = sizeof(a)/sizeof(a[0]);
    for (int i=0; i<len; i++) {
        int temp = 0;
        int max = a[i];
        int maxi = i;
        for(int j=i+1; j<len; j++) {
            if (a[j] > max) {
                max = a[j];
                maxi =  j;
            }
        }
        temp = a[i];
        a[i] = a[maxi];
        a[maxi] = temp;
    }
    for (int k=0; k<len; k++) {
        printf("%d ", a[k]);
        printf("\n");
    }
}
