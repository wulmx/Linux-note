#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct ListNode {
    int val;
    struct ListNode *next;
} node;

typedef struct node *list;

struct ListNode* addTwoNumbers(struct ListNode* l1, struct ListNode* l2){
    node * head = NULL;
    node * end = NULL;
    int n1 = 0;
    int n2 = 0;
    int carry = 0;
    int sum = 0;
    while(l1 || l2) {
       if(l1) {
           n1 = l1->val;
           l1 = l1->next;
       }
       if(l2) {
           n2 = l2->val;
           l2 = l2->next;
       }
       sum = (n1 + n2 + carry)%10;
       printf("sum is %d\n", sum);
       printf("carry is %d\n", carry);
       carry = (n1 + n2 + carry)/10;
       if (!head) {
           head = (node *)malloc(sizeof(node));
           head->val = sum;
           head->next = NULL;
       }
       else {
           end = (node *)malloc(sizeof(node));
           end->val = sum;
           end->next = head->next;
           head->next = end;
       }
    }
    if (carry > 0) {
        node *ca = (node*)malloc(sizeof(node));
        ca->val = carry;
        ca->next = head->next;
        head->next = ca;
    }
    return head;
}

node *  initlink(int *num, int len, node *head) {
    if (!head)
        head = (node *)malloc(sizeof(node));
    head->next = NULL;
    node *end = NULL;
    int i = 0;
    for(i; i<len; i++) {
        end = (node *)malloc(sizeof(node));
        end->val = num[i];
        end->next = head->next;
        head->next = end;
    }

    return head;
}

int insert(int index, int val, node *head) {
    int i = 0;
    node * oper = head;
    while (i<index) {
        oper = oper->next;
        i++;
    }
    node * ins = (node *)malloc(sizeof(node));
    ins->val = val;
    ins->next = oper->next;
    oper->next = ins;
}

int rm(int index, node *head) {
    int i = 0;
    node *oper = head;
    node *rm;
    while(i<index) {
        oper = oper->next;
        i++;
    }
    rm = oper->next;
    oper->next = oper->next->next;
    free(rm);
}

void traverse(node *list) {
    node *h = list;
    while(h) {
        printf("%d\t", h->val);
        h = h->next;
    }
    printf("\n");
}

int main() {
    int a[] = {3, 2, 8};
    int b[] = {8, 2, 8};
    node *l1 = (list)malloc(sizeof(node));
    //node *l1 = NULL;
    //node *l2 = (list)malloc(sizeof(node));
    node *l2 = NULL;
    //l1 = initlink(a, 3, l1);
    initlink(a, 3, l1);
    l2 = initlink(b, 3, l2);
    traverse(addTwoNumbers(l1, l2));
    traverse(l1);
    traverse(l2);
    insert(1, 7, l1);
    traverse(l1);
    rm(1, l1);
    traverse(l1);
    free(l1);
    free(l2);
}
