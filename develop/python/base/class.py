# -*- coding: utf-8 -*-

class base(object):
    def __init__(self):
        print("i am parent")
        self.data=[]

    def add(self, x):
        self.data.append(x)
        # will call chid's plus for super(child, self)
        return self.plus(1, 2)   
    
    def plus(self, a, b):
        return a+b-1

class child(base):
    def __init__(self):
        self.data=[]
        bb=super(child, self).add("wlm")


        print("bb is %s" % bb)


    def plus(self, a, b):
        return a+b

#print(super(child, self).add("wlm1"))
#import pdb; pdb.set_trace()
chd = child()

#chd.add("wlm")
print(chd)
#print(chd.data)
#print(chd.plus(2, 3))

