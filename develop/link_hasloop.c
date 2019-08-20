#include<stdio.h>
#include<stdlib.h>


typedef struct node
{
    int id;
    int data;
    struct node *next;
} NODE;

bool has_loop(NODE *head)
{
    NODE *slow = head->next;
    NODE *fast = slow->next;

    while(slow != NULL && fast != NULL)
    {
        if (slow == fast) return true;
        slow = slow->next;
        fast = fast->next;
        if (fast != NULL) fast = fast->next;
    }
    return false;
}


void push(struct Node** head_ref, void *new_data, size_t data_size, int id)
{
	// Allocate memory for node
	struct Node* new_node = (struct Node*)malloc(sizeof(struct Node));

	new_node->id = id;
	new_node->data = malloc(data_size);
	new_node->next = (*head_ref);

	// Copy contents of new_data to newly allocated memory.
	// Assumption: char takes 1 byte.
	int i;
	for (i=0; i<data_size; i++)
		*(char *)(new_node->data + i) = *(char *)(new_data + i);

	// Change head pointer as new node is added at the beginning
	(*head_ref) = new_node;
}

/* Function to print nodes in a given linked list. fpitr is used
to access the function to be used for printing current node data.
Note that different data types need different specifier in printf() */
void printList(struct Node *node, void (*fptr)(void *))
{
	while (node != NULL)
	{
		(*fptr)(node->data);
		node = node->next;
	}
}


void printFloat(void *f)
{
    printf(" %f", *(float *)f);
}

int main()
{
    NODE *head = NULL;
    int datasize = sizeof(int);
    int arr[] = {10, 20, 30, 40, 50}, i;

    for (i=0; i<5; i++}
    {
        push(& head, arr[i], datasize, i);
    }
    printList(head, printFloat);
    
}
