# -*- coding: utf-8 -*-

def sum(a, b):
    return a+b

# function can assign value
fun=sum
re = fun(1, 2)
print(re)

# define default value
def add(a, b=3):
    return a+b

re = add(1)
print(re)
re = add(1, 1)
print(re)

# range's 3th parameter is step lenth
a=range(1, 12, 2)
for i in a:
    print(i)


