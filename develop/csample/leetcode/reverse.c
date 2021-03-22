#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INT_MAX		((int)(~0U>>1))
#define INT_MIN		(-INT_MAX - 1)

int reverse(int x){
    char buf[11] = {0};
    if (abs(x) >= 0) {
        sprintf(buf, "%d", x);
        printf("%s\n", buf);
        int temp = 0;
        for(int i=0; i<strlen(buf)/2; i++) {
             temp = buf[i];
             buf[i] = buf[strlen(buf) -i - 1];
             buf[strlen(buf) -i - 1] = temp;
        }
        printf("%s\n", buf);
        return atol(buf);
    } else {
        printf("0\n");
    }
}

int reverse1(int x) {
	int rev = 0;
    while (x != 0) {
        int pop = x % 10;
        x /= 10;
        if (rev > INT_MAX/10 || (rev == INT_MAX / 10 && pop > 7)) return 0;
        if (rev < INT_MIN/10 || (rev == INT_MIN / 10 && pop < -8)) return 0;
        rev = rev * 10 + pop;
    }
    return rev;
}

int main() {
    printf("%d\n", reverse1(351)); 
    long long b = reverse1(2147483647); 
    printf("output is %lld\n", b); 
    long long a = 3147483647;
    printf("%lld\n", reverse1(a));
    printf("%d\n", reverse1(a)); 
      
 }
