#include "../cpu/headers/isr.h"
#include "../drivers/headers/screen.h"
#include "headers/kernel.h"
#include "../libc/headers/string.h"
#include "../libc/headers/mem.h"
#include "headers/commands.h"

#include <stdint.h>

void kernel_main() {
    init_memory();
    isr_install();
    irq_install();

    asm volatile("int $2");
    asm volatile("int $3");
    kprint("\n");
    kprint("Welcome to BOOTA");
    kprint("\n");
    help();
    terminal();
}

void user_input(char *input) {
    if (strcmp(input, "POWEROFF") == 0) {
        poweroff();

    } else if (strcmp(input, "STACK") == 0) {
        print_stack();

    } else if (strcmp(input, "REBOOT") == 0) {
        reboot();
    } else if (strcmp(input, "HELP") == 0) {
        help();
    } else if (strcmp(input, "HALT") == 0) {
        halt();
    } else if (strcmp(input, "MEM") == 0) {
        mem();
    } else {
        kprint("Unknown command: ");
        kprint(input);
        kprint("\n");
    }

    terminal();
}
