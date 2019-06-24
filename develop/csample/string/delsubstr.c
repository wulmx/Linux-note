#include <string.h>
#include <stdio.h>
#include <stdlib.h>

/*
 * delete the substring of string
 * add by wulm 20190529
 */
int del_sub_string(char *src, char *dest, char *sub_str)
{
    int sub_str_count = 0;
    int num_len = strlen(sub_str);
    while (*src != '\0')
    {
        while (*src != *sub_str && *src != '\0')
        {
            *dest = *src;
            src++;
            dest++;
        }
        if (strncmp(src, sub_str, num_len) !=0 )
        {
            *dest = *src;
            src++;
            dest++;
            continue;
        }
        else
        {
            src += num_len;
            if ((char)*(src + 1) == '\"')
            {
                src += 2;
            }
            else if ((char)*(src + 2) == '\"')
            {
                src += 3;
            }
            sub_str_count++;
        }
    }
    *dest = '\0';
    return sub_str_count;
}


int main()
{
   // const char *src = "abcdefcd";
   char *src = "\
       [\
        {\"name\": \"sda\", \"capacity\": \"0.1\", \"num\": \"1\"},\
        {\"name\": \"sdb\", \"capacity\": \"0.2\", \"num\": \"22\"},\
        {\"name\": \"sdc\", \"capacity\": \"0.3\", \"num\": \"3\"},\
        {\"num\": \"14\", \"name\": \"sdd\", \"capacity\": \"0.4\"},\
        {\"name\": \"sde\", \"capacity\": \"0.5\", \"num\": \"15\"}\
        ]";
   //char *num = ",\"num\":";
   char *num = ", \"num\": \"";
   //char *num = "cd";
   char target[500];
   int count = del_sub_string(src, target, num);
   /*
   char *result = target;
   int num_len = strlen(num);
   while (*src != '\0')
   {
       while (*src != *num)
       {
           *result = *src;
           src++;
           result++;
       }
       if (strncmp(src, num, num_len) !=0 )
       {
           *result = *src;
           src++;
           result++;
           continue;
       }
       else
       {
           src += num_len;
           printf("=== %c ====\n", *(src +1));
           if ((char)*(src + 1) == '\"')
           {
               src += 2;
           }
           else if ((char)*(src +2) == '\"')
           {
               src += 3;
           }
       }
   }
   *result = '\0';
   */
   printf("%s==\n", target);
}
