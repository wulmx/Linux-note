/*
 * compile method
 * # gcc -g -o gt `pkg-config --cflags --libs glib-2.0 gthread-2.0` gthread.c
 * `pkg-config --cflags --libs glib-2.0 gthread-2.0`
 */

#include <glib.h>
static gboolean t1_end = FALSE;
static gboolean t2_end = FALSE;

typedef struct _Arg Arg;

struct _Arg
{
    GMainLoop* loop;
    gint max;
};

typedef struct {
    GMutex mx;
} Mutex;

Mutex *mutex;

void    run_1(Arg *arg)
{
    int i ;
     
    for(i=0; i<arg->max; i++)
    {
        if(g_mutex_trylock(&mutex->mx) == FALSE)
        {
            g_print("%d : thread 2 locked the mutex \n", i);
            g_mutex_unlock(&mutex->mx);
        }
        else
        {
            g_usleep(10);
        }
    }
    t1_end = TRUE;
}

void    run_2(Arg *arg)
{
    int i;
    for(i=0; i<arg->max; i++)
    {
        if(g_mutex_trylock(&mutex->mx) == FALSE)
        {
            g_print("%d : thread 1 locked mutex \n", i);
            //g_print("%d ：线程1锁定了互斥对象\n", i);
            g_mutex_unlock(&mutex->mx);
        }
        else
        {
            g_usleep(10);
        }
    }
    t2_end = TRUE;
}

void run_3(Arg *arg)
{
    for(;;)
    {
        if(t1_end && t2_end)
        {
            g_main_loop_quit(arg->loop);
            break;
        }
    }
}

int main(int argc, char *argv[])
{
    GMainLoop *mloop;
    Arg *arg;
     
    // since 2.32, g_thread_init has been deprecated
    //if(!g_thread_supported())
    //    g_thread_init(NULL);
    mloop = g_main_loop_new(NULL, FALSE);
     
    arg = g_new(Arg, 1);
    arg->loop = mloop;
    arg->max = 11;
         
    // since 2.32, g_thread_create has been deprecated
    //mutex = g_mutex_new();
    //g_thread_create(run_1, arg, TRUE, NULL);
    //g_thread_create(run_2, arg, TRUE, NULL);
    //g_thread_create(run_3, arg, TRUE, NULL);
    mutex = g_new(Mutex, 1);
    g_mutex_init(&mutex->mx);
    g_thread_new("thread1", (GThreadFunc)run_1, arg);
    g_thread_new("thread2", (GThreadFunc)run_2, arg);
    g_thread_new("thread3", (GThreadFunc)run_3, arg);
     
    g_main_loop_run(mloop);
    g_print("thread3 cancel\n");
    g_mutex_clear(&mutex->mx);
    g_print("release mutex object\n"); 
    g_free(arg);
    g_print("free memory\n");
}
