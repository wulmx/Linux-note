OBJS = test.o rbtree.o
CC = gcc

#-Wall          输出所有的警告信息。
#-O             在编译时进行优化。
#-g             表示编译debug版本。
CFLAGS = -Wall -O -g

helloworld : $(OBJS)
# TAB key is needed before command
	$(CC) $(OBJS) -o rbtest

test.o : test.c
	$(CC) $(CFLAGS) -c test.c -o test.o

rbtree.o : rbtree.c rbtree.h
	$(CC) $(CFLAGS) -c rbtree.c -o rbtree.o

clean:
	rm -rf *.o helloworld
