#include "../cpu/headers/isr.h"
#include "../drivers/headers/screen.h"
#include "headers/kernel.h"
#include "../libc/headers/string.h"
#include "../libc/headers/mem.h"
#include "headers/commands.h"

#include <stdint.h>

void kernel_main() {
    isr_install();
    irq_install();

    asm("int $2");
    asm("int $3");
    kprint("\n");
    kprint("Buenos dias");
    kprint("\n");
    help();
    kprint("\n");
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
        kprint("No te entiendo, has dicho ");
        kprint(input);
        kprint("\n");
    }

    terminal();
}
