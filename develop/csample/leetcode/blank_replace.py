# -*- coding: utf-8 -*-

import sys

def blank_replace(input):
    a = input.split()
    ret=''
    i=1
    for e in a:
        if i != len(a):
            ret += e + "%20"
        else:
            ret += e
        i += 1

    return ret

print("%s" %blank_replace(sys.argv[1]))
