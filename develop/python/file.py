# -*- coding: utf-8 -*-
import os, sys
import shutil
import string

# delete/modify file's one-line  
with open("/root/11.txt", "r+") as tmp:
	buf=tmp.read().split("\n")
	tmp.seek(0)
	tmp.truncate()
	for line in buf:
		print line
		if "bind" in line:
			line=""
		if line:
			tmp.write(line+"\n")
	#tmp.seek(2)
	tmp.write("last line\n")

# append
with open("/root/11.txt", "a+") as tmp:
	a="bind"
	b="xxx"
	line=("%s %s %s" %("bind", a, b))
	tmp.write(line + "\n")

with open("/root/11.txt", "r+") as tmp:
	print "888",tmp.read().split("\n")
