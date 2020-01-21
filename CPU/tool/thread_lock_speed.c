/* 
 gcc -g -Wall thread_lock_speed.c -lpthread -o spin
 * thread_lock_speed.c

   This program employs POSIX threads that increment the same global
   variable, synchronizing their access using either a mutex or a spinlock.
   Command-line arguments allow the user to specify:

   * The number of threads that will increment the global variable.
   * The number of "outer loops" that each thread will execute using
     the lock/unlock APIs (either mutexes or spin locks).
   * The number "inner loops" executed for each "outer loop" step.
     Each inner loop iteration increments the global variable by 1.

   By default, the threads use mutexes to synchronize their access to
   the global variable. Specifying the "-s" option causes spin locks
   to be employed instead.

   The idea is to vary the number of threads and number of inner loops
   while using time(1) to measure the real and CPU time consumed by the
   program. In some scenarios (e.g., many threads, large "inner loop"
   values), mutexes will perform better, while in others (few threads,
   small "inner loop" value), spin locks are likely to be better.
*/
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>

static volatile int glob = 0;
static pthread_spinlock_t splock;
static pthread_mutex_t mtx;
static int useMutex = 0;
static int numOuterLoops;
static int numInnerLoops;
static int usleep_time = 0;

static void *
threadFunc(void *arg)
{
    int s,j,k;

    for (j = 0; j < numOuterLoops; j++) {
        if (useMutex) {
            s = pthread_mutex_lock(&mtx);
            if (s != 0) {
                printf("pthread_mutex_lock error, %d\n", s);
                exit(1);
            }
        } else {
            s = pthread_spin_lock(&splock);
            if (s != 0) {
                printf("pthread_spin_lock error, %d\n", s);
                exit(1);
            }
        }

        for (k = 0; k < numInnerLoops; k++) {
            usleep(usleep_time);
            glob++;
        }

        if (useMutex) {
            s = pthread_mutex_unlock(&mtx);
            if (s != 0) {
                printf("pthread_mutex_unlock error, %d\n", s);
                exit(1);
            }
        } else {
            s = pthread_spin_unlock(&splock);
            if (s != 0) {
                printf("pthread_spin_unlock error, %d\n", s);
                exit(1);
            }
        }
    }

    return NULL;
}

static void
usageError(char *pname)
{
    fprintf(stderr,
            "Usage: %s [-s] num-threads "
            "[num-inner-loops [num-outer-loops]]\n", pname);
    fprintf(stderr,
            "    -q   Don't print verbose messages\n");
    fprintf(stderr,
            "    -s   Use spin locks (instead of the default mutexes)\n");
    exit(EXIT_FAILURE);
}

int
main(int argc, char *argv[])
{
    int opt, s, j;
    int numThreads;
    pthread_t *thread;
    int verbose;

    /* Prevent runaway/forgotten process from burning up CPU time forever */

    alarm(120);         /* Unhandled SIGALRM will kill process */

    useMutex = 1;
    verbose = 1;
    while ((opt = getopt(argc, argv, "qs")) != -1) {
        switch (opt) {
        case 'q':
            verbose = 0;
            break;
        case 's':
            useMutex = 0;
            break;
        default:
            usageError(argv[0]);
        }
    }

    if (optind >= argc)
        usageError(argv[0]);

    numThreads = atoi(argv[optind]);
    numInnerLoops = (optind + 1 < argc) ? atoi(argv[optind + 1]) : 1;
    numOuterLoops = (optind + 2 < argc) ? atoi(argv[optind + 2]) : 10000000;
    usleep_time = (optind + 3 < argc) ? atoi(argv[optind + 3]) : 0;

    if (verbose) {
        printf("Using %s\n", useMutex ? "mutexes" : "spin locks");
        printf("\tthreads: %d; outer loops: %d; inner loops: %d usleep_time: %d\n",
                numThreads, numOuterLoops, numInnerLoops, usleep_time);
    }
    thread = calloc(numThreads, sizeof(pthread_t));
    if (thread == NULL) {
        printf("calloc error\n");
        exit(1);
    }

    if (useMutex) {
        s = pthread_mutex_init(&mtx, NULL);
        if (s != 0) {
            printf("pthread_mutex_init error, %d\n", s);
            exit(1);
        }
    } else {
        s = pthread_spin_init(&splock, 0);
        if (s != 0) {
            printf("pthread_spin_init error, %d\n", s);
            exit(1);
        }
    }

    for (j = 0; j < numThreads; j++) {
        s = pthread_create(&thread[j], NULL, threadFunc, NULL);
        if (s != 0) {
            printf("pthread_create error, %d\n", s);
            exit(1);
        }
    }
    for (j = 0; j < numThreads; j++) {
        s = pthread_join(thread[j], NULL);
        if (s != 0) {
            printf("pthread_join error, %d\n", s);
            exit(1);
        }
    }

    if (verbose)
        printf("glob = %d\n", glob);
    exit(EXIT_SUCCESS);
}
