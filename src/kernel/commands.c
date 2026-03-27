#include "headers/commands.h"
#include "../cpu/headers/ports.h"
#include "../drivers/headers/screen.h"
#include "../libc/headers/string.h"
#include "../libc/headers/mem.h"

void dump_mem(uint32_t *esp, uint32_t values) {
    uint32_t i = 0;

    while (i < values) {
        if ((i) % 4 == 0){
            char var1[32] = "";
            hex_to_ascii((int)(esp + i), var1);
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
    kprint("Dumping stack...\n");
    register uint32_t *esp asm("esp");
    dump_mem(esp, 64);
}

void reboot(void) {
    kprint("Rebooting...\n");
    asm volatile ("cli");
    port_byte_out(0x64, 0xfe);
}

void help(void) {
    kprint("Available commands:\n");
    kprint("  HELP     - show this message\n");
    kprint("  POWEROFF - shut down the system\n");
    kprint("  REBOOT   - restart the system\n");
    kprint("  HALT     - halt the CPU\n");
    kprint("  MEM      - allocate a memory page\n");
    kprint("  STACK    - dump the stack\n");
}

void halt(void) {
    kprint("System halted.\n");
    asm volatile("hlt");
}

void mem(void) {
    kprint("Allocating a page...\n");
    uint32_t phys_addr;
    uint32_t page = kmalloc(1000, 1, &phys_addr);
    char page_str[16] = "";
    hex_to_ascii(page, page_str);
    char phys_str[16] = "";
    hex_to_ascii(phys_addr, phys_str);
    kprint("Page: ");
    kprint(page_str);
    kprint(", physical: ");
    kprint(phys_str);
    kprint("\n");
}

void terminal(void) {
    kprint("\n[BOOTA] >>> ");
}
