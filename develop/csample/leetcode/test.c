#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct stu {
    int id;
    long long le[2];
    char name[10];
}__attribute__((aligned(4))) stu; 
//}__attribute__((packed)) stu; 


int main() {
    int a[3] = {1, 2, 3};
    int *b;
    int c[] = {1, 2};
    char name[10] = "wlmdx";
    printf("%d, %p,  %d, %p, %d, %d, %d, %s, %c\n", sizeof(a), a, sizeof(b), &b, sizeof(c), sizeof(name), strlen(name), name, name[0]);
    printf("%d, %d, %d\n", sizeof(stu), sizeof(int), sizeof(name));
}
