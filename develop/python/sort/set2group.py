# -*- coding:utf-8 -*-
#!/usr/bin/env python

import os,sys
import copy

dic={'kvm1': 1600, 'kvm2': 600, 'kvm3': 500, 'kvm4': 100, 'kvm5': 90, 'kvm6': 50}
print dic
dic=sorted(dic.items(), key=lambda item:item[1])
print dic
for i in range(-1, -4, -1):
	print dic[i][1]
sum=0
for k,v in dic:
	sum += v

print sum, sum/2
# Hello World program in Python
# coding=utf-8
import random

def test_input():
    arr = []
    for i in range(6):
        n = random.randint(1, 20)
        arr.append(n)
    return arr

arr = test_input()
#arr=[1, 11, 13, 14, 14, 19]
#arr=[3,8,2,6]
#arr=[4, 4, 4, 11, 16, 16]
arr.sort()
# 求和
def sum(a):
    s = 0
    for i in a:
        s += i
    return s



# 分离数组
def split_array(arr):
    # 获取数组并排序
    a = copy.deepcopy(list(arr))
    a.sort()
    print a

    # 另一个数组
    b = list()
    # 以上a,b作为待返回的数组

    # 计算数组大小
    n = len(a)

    #求和
    smr = sum(a)

    # 和的一半,简称半和
    hs = smr / 2
    print hs
    # 临时和
    s = 0
    cnt = 0
    # 从最大的数字开始遍历数组
    for i in range(-1, 0-n, -1):
        if abs(i) + cnt > n:
            break
        # 预判该数字加和结果
        ns = s + a[i]
	print s,a[i],arr[-n],i,a,b

        if ns > hs:
            # 如果超出半和则跳过
            continue
        else:
            # 如果未超过半和,则:
            # 1, 取该元素加和
            s += a[i]
            # 2, 从 a 中将元素转移到 b
            b.append(a[i])
            a.pop(i)
            print "pop", i
            cnt += 1
            # 如果最终和与半和之差,不够最小元素,则完成
            if abs(s - hs) <= arr[-n]:
                break
    return a, b

if __name__ == '__main__':
    # 测试:
    # [1,2,3,4,5] -> [1,2,5] & [3,4]
    # arr = test_input()
    print(split_array(arr))
