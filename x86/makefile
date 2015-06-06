CC = gcc -m32
NASM = nasm

a.exe : xpandbmp24.o main.o
	$(CC) xpandbmp24.o main.o -o a.exe

xpandbmp24.o : xpandbmp24.asm
	$(NASM) -f elf xpandbmp24.asm -o xpandbmp24.o

main.o: main.c
	$(CC) -c main.c -o main.o
