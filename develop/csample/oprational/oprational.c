#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define u16 unsigned short
#define s16 short
#define USHRT_MAX	((u16)(~0U))
#define SHRT_MAX	((s16)(USHRT_MAX>>1))
#define SHRT_MIN	((s16)(-SHRT_MAX - 1))
#define INT_MAX		((int)(~0U>>1))
#define INT_MIN		(-INT_MAX - 1)
#define UINT_MAX	(~0U)
#define LONG_MAX	((long)(~0UL>>1))
#define LONG_MIN	(-LONG_MAX - 1)
#define ULONG_MAX	(~0UL)
#define LLONG_MAX	((long long)(~0ULL>>1))
#define LLONG_MIN	(-LLONG_MAX - 1)
#define ULLONG_MAX	(~0ULL)
#define PAGE_SHIFT  12
#define PAGE_SIZE   (1UL << PAGE_SHIFT)
#define PAGE_MASK   (~(PAGE_SIZE - 1))

int main(int *args, int argv[])
{
    int cluster = 10;
    int item = 1001;
    int out = 0;
    printf("%d\n", ((cluster)&0xfff));
    printf("%d\n", ((cluster)&0xfff<<10));
    printf("%d\n", ((item)&0x3ff));
    out = ((((cluster)&0xfff)<<10)|((item)&0x3ff));
    printf("%d\n", out);
	printf("USHRT_MAX	is %d %u\n",   sizeof(USHRT_MAX), USHRT_MAX	);
	printf("SHRT_MAX	is %d %d\n",   sizeof(SHRT_MAX ),   SHRT_MAX	);
	printf("SHRT_MIN	is %d %d\n",   sizeof(SHRT_MIN ),   SHRT_MIN	);
	printf("INT_MAX		is %d %d\n",   sizeof(INT_MAX  ),   INT_MAX		);
	printf("INT_MIN		is %d %d\n",   sizeof(INT_MIN  ),   INT_MIN		);
	printf("UINT_MAX	is %d %u\n",   sizeof(UINT_MAX ),   UINT_MAX	);
	printf("LONG_MAX	is %d %ld\n",  sizeof( LONG_MAX),  LONG_MAX	);
	printf("LONG_MIN	is %d %ld\n",  sizeof( LONG_MIN),  LONG_MIN	);
	printf("ULONG_MAX	is %d %uld\n",  sizeof(ULONG_MAX), ULONG_MAX	);
	printf("LLONG_MAX	is %d %lld\n", sizeof( LLONG_MAX),  LLONG_MAX	);
	printf("LLONG_MIN	is %d %lld\n", sizeof( LLONG_MIN),  LLONG_MIN	);
	printf("ULLONG_MAX	is %d %ulld\n", sizeof(ULLONG_MAX), ULLONG_MAX	);
	printf("PAGE_SIZE	is %d %ulld\n", sizeof(PAGE_SIZE), PAGE_SIZE	);
	printf("PAGE_MASK	is %d %ulld\n", sizeof(PAGE_MASK), PAGE_MASK	);

}
