#include <stdio.h>
#include <stdlib.h>

/*
 * static 未初始化，global未初始化的 -> BSS
 * static 初始化，global初始化的, 变量在BSS而内容在 data
 * 栈stack的地址向下增长
 * 堆heap的地址向上增长
 */
int k1 = 1;
int k2;
static int k3 = 2;
static int k4;
static int k5 = 2;
int k6 = 8;

//const char *str1 = "wlm";

int main( )
{   static int m1=2, m2;
    int i = 1;
    char *p;
    char str[10] = "hello";
    char *var1 = "123456";
    char *var2 = "abcdef";
    int *p1=malloc(4);
    int *p2=malloc(4);
    free(p1);
    free(p2);
    printf("栈区-变量地址\n");
    printf("                i：%p\n", &i);
    printf("                p：%p\n", &p);
    printf("              str：%p\n", str);
    printf("\n堆区-动态申请地址\n");
    printf("                   %p\n", p1);
    printf("                   %p\n", p2);
    printf("\n.bss段\n");
    printf("全局外部无初值 k2：%p\n", &k2);
    printf("静态外部无初值 k4：%p\n", &k4);
    printf("静态内部无初值 m2：%p\n", &m2);
    printf("\n.data段\n");
    printf("全局外部有初值 k1：%p\n", &k1);
    printf("静态外部有初值 k3：%p\n", &k3);
    printf("静态内部有初值 m1：%p\n", &m1);
    printf("\n常量区\n");
    printf("文字常量地址     ：%p\n",var1);
    printf("文字常量地址     ：%p\n",var2);
    printf("\n代码区\n");
    printf("程序区地址       ：%p\n",&main);
    //sleep(60);
    return 0;
}

