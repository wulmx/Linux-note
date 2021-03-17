/*
 * On success, the PID of the child process is returned in the parent, 
 * and 0 is returned in the child. 
 * On failure, -1 is returned in  the  parent
 *
 * fork 是通过复制父进程的内存生成一个子进程，存在父子关系，进程的内存锁及信号量
 * 不会继承。
 * exec 设计目的则是在通过fork生成的进程中加载应用程序，具体可以看下面的例子
 * # ./p1
 * this is parent context can get the child pid 1795334 ret is 1795335
 * this is child context 1795335 ret is 0
 * root       58008       1  0  2020 ?        00:00:02 /usr/bin/abrt-dump-journal-oops -fxtD
 * root      133398       1  0  2020 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
 * root     1795334 1794332  0 07:26 pts/2    00:00:00 ps -ef
 * root     1795335 1795334  0 07:26 pts/2    00:00:00 grep ps
 *
 */
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void)
{
	pid_t pid;
	int fd[2];

	pipe(fd);
	pid = fork();

	if (pid == 0) {  //child
        printf("this is child context %d ret is %d\n", getpid(), pid);
		close(fd[1]);	                //子进程从管道中读数据，关闭写端
		dup2(fd[0], STDIN_FILENO);		//让wc从管道中读取数据
		//execlp("wc", "wc", "-l", NULL);	//wc命令默认从标准读入取数据
        execlp("grep", "grep", "ps", NULL);
	} else {
        printf("this is parent context can get the child pid %d ret is %d\n", getpid(), pid);
		close(fd[0]);	//父进程向管道中写数据，关闭读端
		dup2(fd[1], STDOUT_FILENO);		//将ls的结果写入管道中
		//execlp("ls", "ls", NULL);		//ls输出结果默认对应屏幕
        execlp("ps", "ps", "-ef", NULL);
	}
    sleep(3);
	return 0;
}

