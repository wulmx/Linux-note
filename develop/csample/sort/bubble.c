#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>

#define random(a, b)  (rand()>>19)%(b-a)+a
#define MILLION 1000000
#define LENGTH 6

void bubble(int len, int *a) {
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
}

void select_sort(int len, int *a) {
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
}

void quick_sort(int len, int *a) {
   int i=0, j=len-1, temp = a[0], t;
    while(i < j) {
        while(a[j] > temp && j > i) j--;
        while(a[i] <= temp && i < j) i++;
        if(i != j) { 
            t = a[i];
            a[i] = a[j];
            a[j] = t;
        } 
    }
    a[0]=a[i];
    a[i]=temp;
    quick_sort(i, a);
    quick_sort(len-i-1, a+i+1);
    return;
}

void traverse(int *a) {
    for (int k=0; k<LENGTH; k++) {
        printf("%d ", a[k]);
        printf("\n");
    }
}

int main() {
    printf("RAND_MAX is %lld\n", RAND_MAX>>16-1);
    long tps = sysconf(_SC_CLK_TCK);
    printf("_SC_CLK_TCK  is %ld\n", tps);
    int a[LENGTH] = {0};
    int len = LENGTH;
    for (int i=0; i<len; i++) {
        a[i] = random(1, LENGTH);
        printf("%d %d %6d\n", len, i, a[i]);
    }
    printf("\n");
    printf("-------------\n");
    printf("%d\n",sizeof(a)/sizeof(a[0]));
    int b[5] = {3, 5, 4, 8, 6};
	quick_sort(len, b);
	traverse(b);
	return 1;
    struct timespec tpstart;
    struct timespec tpend;
    long delta;
    clock_gettime(CLOCK_MONOTONIC, &tpstart);
    select_sort(len, a);
    clock_gettime(CLOCK_MONOTONIC, &tpend);
    delta = MILLION*(tpend.tv_sec-tpstart.tv_sec) + (tpend.tv_nsec-tpstart.tv_nsec)/1000;
    fprintf(stdout, "bubble took %ld microseconds\n", delta);
    clock_gettime(CLOCK_MONOTONIC, &tpstart);
    bubble(len, a);
    clock_gettime(CLOCK_MONOTONIC, &tpend);
    delta = MILLION*(tpend.tv_sec-tpstart.tv_sec) + (tpend.tv_nsec-tpstart.tv_nsec)/1000;
    fprintf(stdout, "bubble took %ld microseconds\n", delta);
    return 1;    
}
