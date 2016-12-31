all: lynarr

lynarr: lynarr.o asm_io.o driver.c  cdecl.h
	 gcc -m32 -o lynarr lynarr.o driver.c asm_io.o
asm_io.o: asm_io.asm asm_io.inc
	nasm -f elf32 -d ELF_TYPE asm_io.asm
lynarr.o: lynarr.asm 
	nasm -f elf32 -o lynarr.o lynarr.asm
clean:
	rm *.o lynarr
