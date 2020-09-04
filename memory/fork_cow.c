#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> 
#include <stddef.h>
#include <sys/mman.h>

#define MAP_SIZE 2*1024*1024
int data = 10;

int child_process() {
    printf("child proc %d, data %d\n", getpid(), data);
    data = 20;
    printf("child proc %d, data %d\n", getpid(), data);
    exit(0);
}

int main() {
    int pid;
    unsigned char *m;
    m = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
    int i;

#if 1
    int ret;
    ret = madvise(m, MAP_SIZE, MADV_MERGEABLE);
    if (ret) {
        printf("failed to enable ksm\n");
    } else {
        printf("succ to enable ksm\n");
    }
#endif

    for (i=0; i<MAP_SIZE; i++) m[i] = 10;
    pid = fork();

    if (pid == -1) exit(-1);

    if (pid == 0) {
        //child_process();
        printf("child proc %d, data %d\n", getpid(), data);
        while(1);
    } else {
        data = 20;
        printf("parent proc %d, data %d\n", getpid(), data);
        sleep(30);
        /* COW */
        for (i=0; i<MAP_SIZE; i++) m[i] = 20;
        printf("COW is done\n");
        while(1);
        //exit(0);
    }
}
