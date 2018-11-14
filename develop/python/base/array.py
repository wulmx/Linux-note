# -*- coding: utf-8 -*-
#!/usr/bin/python

# string is the same with array except append and del
word=['a', 'b', 'c', 'd', 'e', 'f', 'g']
#word="abcdefg"

# list all elements
a=word[0:]
print(a)

# last element
b=word[-1]
print(b)

# last 2 elements
c=word[-2:]
print(c)

# from end 3th and 4th element
d=word[-4:-2]
print(d)

# 1th and 2th element
e=word[0:2]
print(e)

# all elements except last 2 elemnt
f=word[:-2]
print(f)

# merge 2 array
g=word[0:3]+word[-2:]
print(g)

# add element into word
word.append('h')
print(word)

# remove element from word
del word[-1]
print(word)

