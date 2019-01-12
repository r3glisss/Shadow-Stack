#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void foo(int i, int redirect) 
{
	char buffer[16];
	char *position = &buffer[15];

	printf("*Entrée dans foo*\n");
	printf("Taille buffer : %d\n", sizeof(buffer));
	printf("Adresse buffer[0] : %p\n", &buffer[0]);
	printf("Adresse buffer[15] : %p\n", &buffer[15]);

	position += i;

	printf("Position Stack : %p\n", position);

	*(position) = redirect;
}

int main(int argc, char* argv[])
{
	int i;//12 
	int redirect = (int) foo; //adresse de foo

	printf("*****START*****\n");

	i = atoi(argv[1]);
	printf("Argument : %d\n", i);

	printf("Adresse fct : %x\n", redirect);

	foo(i, redirect);

	printf("*****END*****\n");

	return 0;
}


