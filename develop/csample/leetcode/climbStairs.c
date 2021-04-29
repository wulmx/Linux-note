#include <stdio.h>
#include <stdlib.h>

int climbStairs(int n) {
    int p = 0, q = 0, r = 1;
    for (int i=1; i<=n; i++) {
        p = q;
        q = r;
        r = p + q;
    }
    return r;
}


int main() {
    printf("%d\n", climbStairs(5));
    return 1;
}
