#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

/*
 * vfork 与 fork的主要区别
 * 1) 会直接占用父进程的内存空间，从而导致父进程暂时挂起，
 * 2) 当子进程退出运行后才会恢复父进程。
 * 3) vfork 保证子进程先执行，而fork不确定。
 *
 * fork/vfork -> kernel/fork.c  do_fork()->copy_process->wake_up_new_task
 *
 * -- vfork output --
 *  # ./vf
 *  Before create son, the father's count is:1
 *  This is son: 2 (0x7fffb68880d8). : 1795538
 *  I'm father: 3 (0x7fffb68880d8), his pid is: 1795537
 * -- fork output --
 *  # ./f
 *  Before create son, the father's count is:1
 *  I'm father: 2 (0x7ffeebd3a4f8), his pid is: 1795546
 *  This is son: 2 (0x7ffeebd3a4f8). : 1795547
 *
 */
int main(void)
{
    int count = 1;
    int child;

    printf("Before create son, the father's count is:%d\n", count);
    //if((child = fork())< 0)
    if((child = vfork())< 0)
    {
        perror("fork error : ");
    }
    else if(child == 0)     // fork return 0 in the child
    {
        printf("This is son: %d (%p). : %d\n", ++count, &count, getpid());
        sleep(3);
        exit(0);
    }
    else                    // the PID of the child process is returned in the parent
    {
        printf("I'm father: %d (%p), his pid is: %d\n", ++count, &count, getpid());
        exit(0);
    }

    return EXIT_SUCCESS;
}
