#include <stdio.h>
#include <stdlib.h>


int twosum(int *lst, int cnt) {
    int i = 0;
    for (i = 0; i < cnt; i ++) {
        int j = 0;
        int tmp = 0;
        for (j; j < cnt; j++) {
                if (i != j) {
                        tmp = lst[i] - lst[j];
                        int k = 0;
                        for (k; k < cnt; k++) {
                            if (k != j && lst[k] == tmp) return 1;
                        }
                }
        }
    }
    return 0;
}

int main() {
   int ls[4] = {3, 1, 8, 9};
   printf("%d\n", twosum(ls, 4));

}
