#include "headers/commands.h"
#include "../cpu/headers/ports.h"
#include "../drivers/headers/screen.h"
#include "../libc/headers/string.h"
#include "../libc/headers/mem.h"

// auxiliar
void dump_mem(uint32_t *esp, uint32_t values) {
    uint32_t i = 0;

	while (i < values) {
		if ((i) % 4 == 0){
			char var1[32] = "";
			hex_to_ascii(esp + i, var1);
			kprint(var1);

			char var2[32] = "";
			hex_to_ascii(esp[i], var2);
		    kprint(var2);
		}

		if ((i+1) % 4 == 0)
			kprint("\n");

		i++;
	}
}

void poweroff(void) {
    port_word_out(0x604, 0x2000);
}


void print_stack(void) {
	kprint("Mostrando stack...");
	kprint("\n");
    register uint32_t *esp asm("esp");
    dump_mem(esp, 64);
}

void reboot(void) {
	kprint("Reiniciando...");
	kprint("\n");
	asm volatile ("cli");
	port_byte_out(0x64, 0xfe);
}

void help(void) {
	kprint("Este es el mensaje de ayuda\n");
	kprint("Los comandos implementados son:\n");
	kprint("- HELP -> mostrar este mensaje\n");
	kprint("- POWEROFF -> apagar el SO\n");
	kprint("- REBOOT -> reinicio del SO\n");
	kprint("- HALT -> llamada a halt brusca\n");
	kprint("- MEM -> reservar una pagina de memoria\n");
	kprint("- STACK -> mostrar el stack\n");
}

void halt(void) {
	kprint("AAAAAAAAAAAAAAAA");
	kprint("\n");
	asm("hlt");
}

void mem(void) {
	kprint("Reservando una pagina...\n");
	uint32_t phys_addr;
	uint32_t page = kmalloc(1000, 1, &phys_addr);
	char page_str[16] = "";
	hex_to_ascii(page, page_str);
	char phys_str[16] = "";
	hex_to_ascii(phys_addr, phys_str);
	kprint("Pagina: ");
	kprint(page_str);
	kprint(", memoria fisica: ");
	kprint(phys_str);
	kprint("\n");
}

void terminal(void) {
	kprint("\n");
	kprint("[TERMINAL] >>> ");
}