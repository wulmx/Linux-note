# -*- coding: utf-8 -*-

class base:
    def __init__(self):
        self.data=[]

    def add(self, x):
        self.data.append(x)

class child(base):
    def plus(self, a, b):
        return a+b

chd = child()
chd.add("wlm")
print(chd.data)
print(chd.plus(2, 3))

