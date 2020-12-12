#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// chown root escalation.elf
// chmod +s escalation.elf
// adduser usr

void shell()
{
    printf("\n==Attack==\nOpening a malicious shell\n");
    setuid(0);
    system("/bin/sh");
}

void vuln(int offset)
{
    int back = (int) shell;

    printf("Adresse de la fonction : %x\n",back);

    char buffer[32];
    char* ptr = &buffer[31];

    printf("Valeur du pointeur %p \n", ptr);
    ptr += offset;
    printf("Valeur du pointeur %p \n", ptr);

    *((long*)ptr) = 0x000025e4;

    printf("Valeur du pointeur %x \n", *ptr);

}

int main(int argc, char **argv)
{
    int offset = atoi(argv[1]); //13

    vuln(offset);
    printf("normal return \n\n");

    return 0;
}
