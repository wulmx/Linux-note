#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv)
{
        char *p1, *p2, *p3;
        char c;
        int i;

        p1 = sbrk(0);
        // 我们脱离C库的管理，直接切入内核。
        p2 = sbrk(4096);
        p3 = sbrk(4096);

        printf("p1:%p  p2:%p  p3:%p\n", p1, p2, p3);

        memset(p3, 'a', 4096);
        // 1.此处观察p3的地址对应的页表项以及实际读出物理页面确认内容是不是'a'
        // 2.观察和p3虚拟地址紧邻着的上一个4096大小的地址空间的页表项。
        getchar();

        c = p2[120];  // read p2
        // 3.再次实验上述的第2点
        getchar();

        memset(p2, 'b', 4096);
        // 4.再次实验上述的第2点
        getchar();
}
