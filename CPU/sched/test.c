#include <sched.h>
#include<stdio.h>
#include<stdlib.h>

int  main() {
    printf("%d\n", sched_getscheduler(1));
    printf("%d\n", sched_getscheduler(2));
    printf("%d\n", sched_getscheduler(18662));
    printf("%d\n", sched_getscheduler(31223));
    printf("%d\n", sched_getscheduler(31224));
    printf("%d\n", sched_getscheduler(31225));
    printf("%d\n", sched_getscheduler(31226));
}
