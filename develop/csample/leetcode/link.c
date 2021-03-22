#include "stdio.h"

#define OK 1
#define ERROR 0
#define TRUE 1
#define FALSE 0

#define MAXSIZE 20 /* 存储空间初始分配量 */

typedef int Status;/* Status是函数的类型,其值是函数结果状态代码，如OK等 */
typedef int ElemType;/* ElemType类型根据实际情况而定，这里假设为int */

typedef struct Node
{
    ElemType data;
    struct Node *next;
}Node;
/* 定义LinkList */
typedef struct Node *LinkList;

/* 初始化顺序线性表 */
Status InitList(LinkList *L)
{
    *L=(LinkList)malloc(sizeof(Node)); /* 产生头结点,并使L指向此头结点 */
    if(!(*L)) /* 存储分配失败 */
    {
        return ERROR;
    }
    (*L)->next=NULL; /* 指针域为空 */

    return OK;
}

/* 初始条件：顺序线性表L已存在。操作结果：返回L中数据元素个数 */
int ListLength(LinkList L)
{
    int i=0;
    LinkList p=L->next; /* p指向第一个结点 */
    while(p)
    {
        i++;
        p=p->next;
    }
    return i;
}

/* 初始条件：顺序线性表L已存在 */
/* 操作结果：依次对L的每个数据元素输出 */
Status ListTraverse(LinkList L)
{
    LinkList p=L->next;
    while(p)
    {
        visit(p->data);
        p=p->next;
    }
    printf("\n");
    return OK;
}

Status visit(ElemType c)
{
    printf("-> %d ",c);
    return OK;
}

/* 初始条件：顺序线性表L已存在,1≤i≤ListLength(L)， */
/* 操作结果：在L中第i个位置之前插入新的数据元素e，L的长度加1 */
Status ListInsert(LinkList *L,int i,ElemType e)
{
	int j;
	LinkList p,s;
	p = *L;     /* 声明一个结点 p，指向头结点 */
	j = 1;
	while (p && j < i)     /* 寻找第i个结点 */
	{
		p = p->next;
		++j;
	}
	if (!p || j > i)
		return ERROR;   /* 第i个元素不存在 */
	s = (LinkList)malloc(sizeof(Node));  /*  生成新结点(C语言标准函数) */
	s->data = e;
	s->next = p->next;      /* 将p的后继结点赋值给s的后继  */
	p->next = s;          /* 将s赋值给p的后继 */
	return OK;
}

int main()
{
    LinkList L;
    Status i;
    int j,k;
    char opp;

    i=InitList(&L);
    printf("链表L初始化完毕，ListLength(L)=%d\n",ListLength(L));

    printf("\n1.遍历操作 \n2.插入操作  \n0.退出 \n请选择你的操作：\n");
    while(opp != '0'){
        scanf("%c",&opp);
        switch(opp){
            case '1':
                ListTraverse(L);
                printf("\n");
                break;

            case '2':
                srand((unsigned)time(NULL));
                for(j=1;j<=10;j++)
                {
                    i=ListInsert(&L,1,rand()%100);
                }
                printf("在L的表头依次插入10个随机数后：");
                ListTraverse(L);
                printf("\n");
                break;

            case '0':
                exit(0);
        }
    }

}
