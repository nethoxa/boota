ORG 0x7c00
KERNEL_OFFSET equ 0x1000
    mov [BOOT_DRIVE], dl
    mov bp, 0x9000                  ; stack
    mov sp, bp

    mov bx, MSG_REAL_MODE 
    call print_rm
    call print_rm_carry

    call load_kernel
    call switch 
    jmp $                            ; NOP

%include "boot/real/print.asm"
%include "boot/real/disk.asm"
%include "boot/real/switch.asm"
%include "boot/protected/gdt.asm"
%include "boot/protected/print.asm"

BITS 16
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_rm
    call print_rm_carry

    mov bx, KERNEL_OFFSET 
    mov dh, 31 
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

BITS 32
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    call KERNEL_OFFSET 
    jmp $                           ; NOP


BOOT_DRIVE db 0
MSG_REAL_MODE db "Hola desde 16 bits en modo real", 0
MSG_PROT_MODE db "Hola desde 32 bits en modo protegido", 0
MSG_LOAD_KERNEL db "Cargando kernel de memoria...", 0


times 510 - ($-$$) db 0
dw 0xaa55
