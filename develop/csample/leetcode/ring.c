#include <stdio.h>
#include <stdlib.h>


typedef struct Node {
    int val;
    struct Node *next;
} node;

void init_ring1(node **head, int len, int has) {
    *head = (node *)malloc(sizeof(node));
    (*head)->val = 0;
    (*head)->next = NULL;
    node *p = *head;
    while(len >= 0) {
        node *n = (node *)malloc(sizeof(node));
        n->val = len;
        n->next = NULL;
        p->next = n;
        p = n;
        len--;
    }
    if (has)
        p->next = *head;
}

node * init_ring(int len) {
    node *head = (node *)malloc(sizeof(node));
    head->val = 0;
    head->next = NULL;
    node *p = head;
    node *p1;
    while(len > 0) {
        node *n = (node *)malloc(sizeof(node));
        n->val = len;
        n->next = NULL;
        p->next = n;
        p = n;
        if (len == 3) p1 = n;
        len--;
    }
    p->next = p1;
    //p->next = head;
    return head;
}

void traverse(node *l) {
    int i = 20;
    while(l->next && i) {
        printf("%d\t", l->val);
        l = l->next;
        i--;
    }
    printf("\n");
}

int has_ring(node *l) {
    node *slowp = l;
    node *fastp = l->next;
    while (slowp != fastp) {
        if (fastp == NULL || fastp->next == NULL) return 0;
        if (slowp->next)  slowp = slowp->next;
        else return 0;
        if(fastp->next->next) fastp = fastp->next->next;
        else return 0;
    }
    return 1;
}

int find_lastn(node *l, int n) {
    node *slow = l;
    node *fast = l; 
    while (n>=0) {
        fast = fast->next;
        n--;
    }
    while(fast) {
        fast = fast->next;
        slow = slow->next;
    }
    return slow->val;
}

int find_mid(node *l) {
    node *slow = l;
    node *fast = l;
    while(fast != NULL && fast->next != NULL) {
        slow = slow->next;
        fast = fast->next->next;
    }
    return slow->val;
}

int main() {
    traverse(init_ring(6));
    node *l1;
    init_ring1(&l1, 6, 1);
    traverse(l1);
    if(has_ring(l1)) printf("has ring\n");
    else printf("has not ring\n");
    node *l2;
    init_ring1(&l2, 7, 0);
    traverse(l2);
    printf("last 3 is %d\n", find_lastn(l2, 3));
    traverse(l2);
    printf("mid is %d\n", find_mid(l2));
}
