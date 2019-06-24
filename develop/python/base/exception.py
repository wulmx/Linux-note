# -*- coding: utf-8 -*-

age=input("please input your age:")
if age=="":
    raise Exception("age must not be empty")

try:
    out=int(age)
    print("your age is: %s" %out)
except Exception as err:
    print(err)
finally:
    print("Game over")
