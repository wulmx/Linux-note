# -*- coding: utf-8 -*-

import sys

def twosum(lst):
    i = 0
    for e in lst:
        j = 0
        for e1 in lst:
            if i != j:
                tmp1 = lst[i] - lst[j]
                k = 0
                for e2 in lst:
                    if j != k and tmp1 == e2: 
                        print("Y")
                        exit(0)
                    k += 1
            j += 1
        i += 1
    print("N")

ls = [2, 1, 8, 12, 2]
twosum(ls)
