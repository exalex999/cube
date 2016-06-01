CC=gcc
CFLAGS=-std=c99

ASM=nasm
AFLAGS=-f elf64

all:cube

main.o: main.c
	$(CC) $(CFLAGS) -c main.c `sdl2-config --cflags` -lm
routines.o: routines.asm
	$(ASM) $(AFLAGS) routines.asm
cube: main.o routines.o
	$(CC) $(CFLAGS) main.o routines.o -o cube `sdl2-config --libs` -lm
clean: 
	rm *.o
	rm cube
