BITS 16
switch:
    cli

    ; Enable A20 line via fast A20 gate
    in al, 0x92
    or al, 0x02
    and al, 0xFE       ; avoid triggering fast reset (bit 0)
    out 0x92, al

    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1         ; enable protected mode
    mov cr0, eax
    jmp CODE_SEG:init_pm

BITS 32
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    call BEGIN_PM
