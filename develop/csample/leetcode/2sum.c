#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* 
 * https://leetcode-cn.com/problems/two-sum/
 * 给定一组数据，和目标数值，找出数组中2数之和等于目标数值的数的下标
*/

int * twoSum(int* nums, int numsSize, int target, int *ret) {
	int i,j = 0;
	int delta = 0;
	for(i=0; i<numsSize; i++) {
		delta = target - nums[i];
		for(j=0;  j<numsSize; j++) {
			if(j != i && delta == nums[j]) {
				printf("%d %d\n", i, j);
				ret[0] = i;
				ret[1] = j;
				return ret;
			}
		}	
	}
		    
}

int main() {
	int nums[4] = {2,7,11,15};
	int target = 26;
	int ret[2];
	twoSum(nums, 4, target, ret);
	printf("%d\n", ret[0]);
}
