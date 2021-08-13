#include <stdio.h>
#include <stdlib.h>
/**
 * Note: The returned array must be malloced, assume caller calls free().
 */
int* sortedSquares(int* nums, int numsSize, int* returnSize){
    int *nums_dest = (int *)malloc(sizeof(int) * numsSize);
    int *p1, *p2;
    int i =0;
    int neg = 0;
    int pos = 0;
    for (i=0; i<numsSize; i++) {
        if (nums[i] < 0 && nums[i+1] >= 0) {
            p1 = nums + i;
            p2 = nums + i + 1;
            neg = i;
            pos = i+1;
            printf("%d %d\n", *p1, *p2);
        }
    }
    int sq1, sq2;
    i = 0; 
    while(neg >=0 || pos < numsSize) {
            sq1 = *p1 * *p1;
            sq2 = *p2 * *p2;

            if (neg < 0 || sq1 > sq2) {
                nums_dest[i] = sq2;
                p2 += 1;
                pos++;
            } else {
                nums_dest[i] = sq1;
                p1 -=1;
                neg--;
            }
            printf("%d %d %d %d\n", sq1, sq2, i, nums_dest[i]);
            i++;
    }
    
    for(int i=0; i<4; i++) {
        printf("%d\n", nums_dest[i]);
    }
    return nums_dest;
}

int main() {
    int ar[4] = {-5, -4, 2, 3};
    int *dest;
    dest = sortedSquares(ar, 4, (int *) 4);
    for(int i=0; i<4; i++) {
        printf("%d\n", dest[i]);
    }
    free(dest);
}
