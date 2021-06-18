#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>
#include <pthread.h>

#define MILLION 1000000
/*
 * argv[1] = N KB
 * argv[2] = unit is 2^N Byte
 * argv[3] = usleep  us  tunning the cpu usage
 * argv[4] = memory r/w frequency (if argv[4] <= size  r/w part of mem range, 
 * 	     else r/w all of mem range)  argv[4] == 0 will all range 
 * 	     can increase the sys when argv[4] < argv[2], the smaller the sys will higher
 * argv[5] -p  mmap  -m malloc   NULL calloc
 * size:  1<<argv[2]
 * loop:  argv[1] * (1<<10) / size 
 * eg: ./mem_take 5000000 20 1000 1000
 * 5000000KB 1MB 1000us (r/w 0-1000byte part of 1MB)
 * ./mem_take 10000000 20 1000 0 : loop finished took 52554 ms  73.0%us,  7.3%sy
 * ./mem_take 10000000 20 5000 0 : 41.7%us,  4.3%sy, 
 * ./mem_take 10000000 20 1000 10 : loop finished took 15277 ms 5.0%us, 26.5%sy
 */
int main(int argc, char *argv[]) {
        
	struct timespec tpstart;
	struct timespec tpend;
	long delta;
	clock_gettime(CLOCK_MONOTONIC, &tpstart);
	unsigned long nSizeInChar = atoi(argv[1]);
        int type;
        if (argv[2] == NULL)  type = 0;
        else type = atoi(argv[2]);
        long size = 1<<type;
        long loop = nSizeInChar * (1<<10) / size;
	printf("need allocated MEM(KB) is : %d\n", nSizeInChar);
	printf("loop times is : %d\n", loop);
	printf("allocate size is : %d Byte\n", size);
	
	//char *pMemData[loop];
	long i=0;
	long j=0;
	long cnt=1;
	if (argv[4] != NULL)  cnt = 1<<atoi(argv[4]);
	if (atoi(argv[4]) == 0)
       	    printf("range times is : %ld times\n", 1<<atoi(argv[2]));
	else
       	    printf("range times is : %ld times\n", cnt);

	for (i = 0; i < loop; i++)
	{
            char *pMemData;
	    if (argv[5] != NULL && strcmp("-p", argv[5]) == 0 )  pMemData = mmap(NULL, size, PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	    else if (argv[5] != NULL && strcmp("-m", argv[5]) == 0 ) {
	        pMemData = (char *)malloc(sizeof(char) * size);
                memset(pMemData , 0x41 , size);
	    }
	    else {
	        pMemData = (char *)calloc(sizeof(char) * size, sizeof(char));
                memset(pMemData , 0x41 , size);
	    }

	    /* read and write part of memory for tunning cpu sys/user */
	    if (cnt > 1) {
	        if (cnt <= size) for (j=0; j < cnt; j++) *(pMemData+j) = 10;
	        else for (j = 0; j < size; j++) *(pMemData+j) = 10;
	    } else {
	        for (j = 0; j < size; j++) *(pMemData+j) = 10;
	    }

            if (argv[3] != NULL) usleep(atoi(argv[3]));
	}
	clock_gettime(CLOCK_MONOTONIC, &tpend);
	delta = MILLION*(tpend.tv_sec-tpstart.tv_sec) + (tpend.tv_nsec-tpstart.tv_nsec)/1000;
	printf("loop finished took %ld ms\n", delta/1000);
	if (argv[6] != NULL && !strcmp("-e", argv[6])) exit(0);
	while (1)
	{
		sleep(10000);
	}

	return 0;
}
