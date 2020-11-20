#include <pthread.h>
#include <stdio.h>
#include <sys/time.h>
#include <string.h>
#define MAX 10

pthread_t thread[3];
pthread_mutex_t mut;
int number=0, i;

void thread1()
{
        printf ("thread1 : I'm thread 1,starting...\n");

        for (i = 0; i < MAX; i++)
        {
                pthread_mutex_lock(&mut);
                printf("thread1 : number = %d\n",number);
                number++;
                pthread_mutex_unlock(&mut);
                sleep(2);
        }

        pthread_exit(NULL);
}

void thread2()
{
        printf("thread2 : I'm thread 2,starting...\n");

        for (i = 0; i < MAX; i++)
        {
                pthread_mutex_lock(&mut);
                printf("thread2 : number = %d\n",number);
                number++;
                pthread_mutex_unlock(&mut);
                sleep(3);
        }

        pthread_exit(NULL);
}

void thread3()
{
        printf("thread3 : I'm thread 3,starting...\n");

        for (; i < MAX * 2; i++)
        {
                pthread_mutex_lock(&mut);
                printf("thread3 : number = %d\n",number);
                number++;
                pthread_mutex_unlock(&mut);
                sleep(3);
        }

        pthread_exit(NULL);
}

void thread_create(void)
{
        int temp;
        memset(&thread, 0, sizeof(thread));     //comment1
        printf("***%d\n", thread[0]);
        /*创建线程*/
        if((temp = pthread_create(&thread[0], NULL, (void *)thread1, NULL)) != 0)  //comment2     
                printf("create thread1 failed!\n");
        else
                printf("create thread1 successed!\n");

        if((temp = pthread_create(&thread[1], NULL, (void *)thread2, NULL)) != 0)  //comment3
                printf("create thread failed!\n");
        else
                printf("create thread2 successed!\n");
}

void thread_wait(void)
{
        /*等待线程结束*/
        if(thread[0] !=0)
        {             
                //comment4    
                pthread_join(thread[0],NULL);
                printf("thread1 end !\n");
        }
        if(thread[1] !=0) 
        {  
                //comment5
                pthread_join(thread[1],NULL);
                printf("thread2 end !\n");
       }
}

int main()
{
        /*用默认属性初始化互斥锁*/
        pthread_mutex_init(&mut,NULL);
        thread_create();
        printf("%d\n", thread[0]);
        thread_wait();
        sleep(10);
        int temp;
        if((temp = pthread_create(&thread[2], NULL, (void *)thread3, NULL)) != 0)  //comment2     
                printf("create thread3 failed!\n");
        else
                printf("create thread3 successed!\n");
        printf("%d\n", thread[2]);
        if(thread[2] != 0)
        {             
                //comment4    
                pthread_join(thread[2], NULL);
                printf("thread3 end !\n");
        }

        return 0;
}

