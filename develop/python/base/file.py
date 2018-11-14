# -*- coding: utf-8 -*-

path="test.txt"

# when using with, f.close() is't need. it will auto-close
with open(path, 'w') as f:
    list=['first line\n', 'second line\n']
    re=f.writelines(list)
    re1=f.write("just test file IO..\n")

print("writelines return %s" %re)
print("write return %s" %re1)

f= open(path, 'r')
for line in f:
    print("%s" %line)
f.close()
