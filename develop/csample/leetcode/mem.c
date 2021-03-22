#include <stdio.h>
#include <string.h>
#include <stdlib.h>
/*
 * static 未初始化，global未初始化的 -> BSS
 * static 初始化，global初始化的-> data
 * 栈stack的地址向下增长
 * 堆heap的地址向上增长
 */
void before()
{
 
}
 
char g_buf[16];
char g_buf2[16];
char g_buf3[16];
char g_buf4[16];
char g_i_buf[]="123";
char g_i_buf2[]="123";
char g_i_buf3[]="123";
 
void after()
{
 
}
 
int main(int argc, char **argv)
{
        char l_buf[16];
        char l_buf2[16];
        char l_buf3[16];
        static char s_buf[16];
        static char s_buf2[16];
        static char s_buf3[16];
        char *p_buf;
        char *p_buf2;
        char *p_buf3;
 
        p_buf = (char *)malloc(sizeof(char) * 16);
        p_buf2 = (char *)malloc(sizeof(char) * 16);
        p_buf3 = (char *)malloc(sizeof(char) * 16);
 
        printf("g_buf: 0x%x\n", g_buf);
        printf("g_buf2: 0x%x\n", g_buf2);
        printf("g_buf3: 0x%x\n", g_buf3);
        printf("g_buf4: 0x%x\n", g_buf4);
 
        printf("g_i_buf: 0x%x\n", g_i_buf);
        printf("g_i_buf2: 0x%x\n", g_i_buf2);
        printf("g_i_buf3: 0x%x\n", g_i_buf3);
 
        printf("l_buf: 0x%x\n", l_buf);
        printf("l_buf2: 0x%x\n", l_buf2);
        printf("l_buf3: 0x%x\n", l_buf3);
 
        printf("s_buf: 0x%x\n", s_buf);
        printf("s_buf2: 0x%x\n", s_buf2);
        printf("s_buf3: 0x%x\n", s_buf3);
 
        printf("p_buf: 0x%x\n", p_buf);
        printf("p_buf2: 0x%x\n", p_buf2);
        printf("p_buf3: 0x%x\n", p_buf3);
 
        printf("before: 0x%x\n", before);
        printf("after: 0x%x\n", after);
        printf("main: 0x%x\n", main);
 
        if (argc > 1)
        {
                strcpy(l_buf, argv[1]);
        }
        return 0;
}
