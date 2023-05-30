global _start;
BITS 32

_start:
    [extern kernel_main]
    call kernel_main 
    jmp $