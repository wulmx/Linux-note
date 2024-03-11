1. ��������p��&p�����
1�� p��ʾָ��ָ������ͻ���ֵ�ĵ�ַ����������ָ��ָ������ݡ�
2�� &p��ʾֻ������ĵ�ַ����������ָ�뱾��

int   a = 12;
int   *b = &a;
int   **c = &b;   #*������������������Ľ����
��������壺

���ʽ		�൱�ı��ʽ 	��ַ
a		12		0xc
b		&a	 	0x7ffcf9c19444
*b		a,12		0xc
c		&b		0x7ffcf9c19438
*c		b,&a		0x7ffcf9c19444
**c		*b,a,12		0xc

1) **c = *b = a = 12
2) *c = b = &a
3) c = &b

output:
a addr is 0xc, is the 12 hex.
&a addr is 0x7ffcf9c19444
b addr is a's addr, it's equal to &a 0x7ffcf9c19444
*b is a 0xc
&b is addr of itself 0x7ffcf9c19438.
c addr is addr of b 0x7ffcf9c19438
*c addr is b's addr(wrong) 0x7ffcf9c19444
*c addr is the value of a and b(wrong) . 0x7ffcf9c19444
*c addr is the addr of &a and b . 0x7ffcf9c19444
**c addr is the value of a and *b  0xc
note1:       int *a; then pass a to a function is wrong.
explanation: Your mistake is that you have passed an uninitialized integer
             pointer to a function and then used the pointer. What you probably
             intended to do was to automatically allocate an integer on the stack
             and then pass the address of said integer to the function.
             The key thing is to remember that when you do int *c you are allocating 
             a pointer, when you do int c you are allocating an integer. If you wish 
             to modify a variable passed to a function, the typical pattern in C is to 
             pass the address of said variable but you first need to allocate the proper type, 
             in this case an int and not an int *. You can then use the address of operator & 
             to obtain the address of the relevant data which you then pass as the function argument.
