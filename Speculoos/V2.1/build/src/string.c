#include<stdio.h>


int main()
{

    int a=0;
    int b=1;
    int c=0;
    char buff[20];

    int i=10;
    int j=0;

   
    printf("calcul of i= %d = %x first terms of Fibo, i is at address : %x \n",i,i,&i);
   
        printf("Enter name for database\n");
        scanf("%s",buff);
   
            printf(buff);

                printf("valeur de i = %d\n",i);

        for(j=0;j<i;j++)
        {
           c = a +b;
           a = b;
           b = c;
            printf("%d\n",c);
          
        }





return 0;

}
