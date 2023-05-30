C_SOURCES = $(wildcard kernel/*.c drivers/*.c cpu/*.c libc/*.c)
HEADERS = $(wildcard kernel/headers/*.h drivers/headers/*.h cpu/headers/*.h libc/headers/*.h)
OBJ = ${C_SOURCES:.c=.o cpu/interrupt.o} 
CC = /home/kali/Escritorio/gccko/bin/i386-elf-gcc
CFLAGS = -ffreestanding -Wall -Wextra -fno-exceptions -m32


os-image.bin: boot/bootsect.bin kernel.bin
	cat $^ > os-image.bin

kernel.bin: boot/kernel_entry.o ${OBJ}
	i386-elf-ld -o $@ -Ttext 0x1000 $^ --oformat binary


run: os-image.bin
	qemu-system-i386 -fda os-image.bin


%.o: %.c ${HEADERS}
	${CC} ${CFLAGS} -c $< -o $@

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	rm -rf *.bin *.dis *.o os-image.bin *.elf
	rm -rf kernel/*.o boot/*.bin drivers/*.o boot/*.o cpu/*.o libc/*.o
