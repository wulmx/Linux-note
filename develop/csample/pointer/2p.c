#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void change(int **p) {
	**p = 16;
	printf("p addr: %p *p addr: %p **p addr %p\n", p, *p, **p);
}

int main() {
	int a = 12;
	int *p = &a;
	int **p1 = &p;

	**p1 = 13;
	printf("%d\n", a);
	*p = 14;
	printf("%d\n", a);
	a = 15;
	printf("%d\n", a);

	change(&p);
	printf("%d &a addr is %p\n", a, &a);
}
