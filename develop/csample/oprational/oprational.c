#include <stdio.h>
#include <stdlib.h>
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
	printf("USHRT_MAX	is %u\n",   USHRT_MAX	);
	printf("SHRT_MAX	is %d\n",   SHRT_MAX	);
	printf("SHRT_MIN	is %d\n",   SHRT_MIN	);
	printf("INT_MAX		is %d\n",   INT_MAX		);
	printf("INT_MIN		is %d\n",   INT_MIN		);
	printf("UINT_MAX	is %u\n",   UINT_MAX	);
	printf("LONG_MAX	is %ld\n",   LONG_MAX	);
	printf("LONG_MIN	is %ld\n",   LONG_MIN	);
	printf("ULONG_MAX	is %ul\n",  ULONG_MAX	);
	printf("LLONG_MAX	is %lld\n",  LLONG_MAX	);
	printf("LLONG_MIN	is %lld\n",  LLONG_MIN	);
	printf("ULLONG_MAX	is %ull\n", ULLONG_MAX	);

}
