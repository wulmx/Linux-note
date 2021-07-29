#include <stdio.h>
#include <stdlib.h>

int halfcnt(int *arr, int len) {
   int half = len/2;
   for (int i=0; i<len; i++) {
       int tmp = 0;
       for (int j=0; j<len; j++) {
            if (arr[j] == arr[i]) tmp++;
            if (tmp > half) return arr[i];
       }
   }
}
