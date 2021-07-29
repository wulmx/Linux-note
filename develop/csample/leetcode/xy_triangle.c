#include <stdio.h>
#include <stdlib.h>
#include <math.h>


/*
 * get the count of isosceles right triangle and 
 * get the max area of the triangles
 * condition: a*a + b*b = c*c
 * isosceles triangle area: a*a/2
 * 2 point distance: sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
 */
void cal_triangle(int *point, int n) {
    for (int i=0; i<n; i++) {
        printf("%d %d\n", *(point + i*2 + 0), *(point + i*2 + 1));
    }
    for (int i=0; i<n; i++) {
       for (int j=0; j<n; j++) {
           for (int k=0; k<n; k++) {
               int ax = *(point + i*2 +0);
               int ay = *(point + i*2 +1);
               int bx = *(point + j*2 +0);
               int by = *(point + j*2 +1);
               int cx = *(point + k*2 +0);
               int cy = *(point + k*2 +1);
               if(((ax != bx) || ay != by)) &&
                               ((bx != cx) || (by != cy)) &&
                               ((cx != ax) || (cy != ay))) {
                    int ad = sqrt(
               }
           } 
       } 
    }
    
}

int main() {
    int n;
    int ret = 0;
    printf("input the count of point\n");
    ret = scanf("%d", &n);
    if(ret == 1) printf("%d\n", n);
    int *point = (int *)malloc(sizeof(int) * 2 * n);
    printf("input the points\n");
    for (int i=0; i<n; i++) {
        scanf("%d %d", (point + i*2 + 0), (point + i*2 + 1));
    }
    cal_triangle(point, n);
    printf("%f\n", sqrt(2*2));
}
