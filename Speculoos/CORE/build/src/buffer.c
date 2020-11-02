#include <stdio.h>
#include <string.h>

void exploit() 
{
	char vulnbuffer[16];
	char buffer[32];
	int redirect = (int) exploit; //adresse de exploit
	int offset = 32-4;

	printf("=====Exploit=====\n");
	printf("Adresse de la fct : Ox%x\n", redirect);
	memset(buffer, 0x41, 32);//On rempli le buffer de A
	buffer[offset+3] = redirect & 0xff; //On stocke le dernier octet de l'adresse
	buffer[offset+2] = (redirect >> 8) & 0xff;//On décale d'un octet pour stocker le 2nd octet de l'adresse
	buffer[offset+1] = (redirect >> 16) & 0xff;
	buffer[offset] = (redirect >> 24) & 0xff;

	printf("buffer[31] : 0x%x\n", buffer[offset+3]);
	printf("buffer[30] : 0x%x\n", buffer[offset+2]);
	printf("buffer[29] : 0x%x\n", buffer[offset+1]);
	printf("buffer[28] : 0x%x\n", buffer[offset]);
		
	memcpy(vulnbuffer, buffer, 32);
}

int main(int argc, char** argv)
{
	//int i;//start 28

	printf("*****START*****\n");
	//i = atoi(argv[1]);
	exploit();
	printf("*****END*****\n");

	return 0;
}
