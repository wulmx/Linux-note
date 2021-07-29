# -*- coding: utf-8 -*-
import sys

inpt = [x for x in sys.argv[1].split('0')]

cnt = 0
for e in inpt:
    if e:
        cnt += len(e)

print(cnt)
