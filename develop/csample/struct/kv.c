#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct kv {
    int key;
    int len;
    char value[2048];
};

struct kv kvs[3] = {};

int main() {
	int i, k=3, n=0;
	char *temp = "wlm";	
	for (i = 0; i<k; i++)
	{
	     kvs[i].key = i;
	     kvs[i].len = sizeof(temp);
	     //memcpy(kvs[i].value, temp, kvs[i].len);

         /* memmove is thread-safe */
	     memmove(kvs[i].value, temp, kvs[i].len);
         printf("%d %d %s\n", sizeof(kvs), i, kvs[i].value);
	}
}
