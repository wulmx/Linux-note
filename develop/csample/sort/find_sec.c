#include <stdlib.h>
#include <stdio.h>

int FindSecMin(int arr[], int len)
{
    int sec_Min = 32767;
    //int Min = arr[0];
    int Min = 100;
    int i;
    for (i = 0; i < len; i++)
    {
        if (arr[i] < Min)
        {
            sec_Min = Min;
            Min = arr[i];
        }
        else {
            if (arr[i] < sec_Min)
                sec_Min = arr[i];
        }
    }
    printf("min is %d\n", Min);
    return sec_Min;
}

int FindSecMax(int arr[], int len)
{
    int sec_Max = -32767;
    int Max = arr[0];
    int i;
    for (i = 1; i < len; i++)
    {
        if (arr[i] > Max)
        {
            sec_Max = Max;
            Max = arr[i];
        }
        else
        {
            if (arr[i] > sec_Max)
                sec_Max = arr[i];
        }
    }

    return sec_Max;
}

int main(int argc, const char * argv[]) {

    //int arr[] = {1,2,6,7,3,4,9,5,8};
    int arr[] = {1, 2, 2};
    int len = sizeof(arr)/sizeof(int);

    printf("second max value %d\n", FindSecMax(arr, len));
    printf("second min value %d\n", FindSecMin(arr, len));
    return 0;
}
