disk_load:
    pusha
    push dx

    mov ah, 0x02            ; read
    mov al, dh              ; number of sectors
    mov cl, 0x02            ; current sector (1 is the bootloader)

    mov ch, 0x00            ; cylinder
    mov dh, 0x00            ; head

    int 0x13
    jc disk_error

    pop dx
    cmp al, dh              ; BIOS sets al to the number of sectors read
    jne sectors_error

    popa
    ret


disk_error:
    mov bx, DISK_ERROR
    call print_rm
    call print_rm_carry

    mov dh, ah
    call print_rm_hex
    jmp disk_loop

sectors_error:
    mov bx, SECTORS_ERROR
    call print_rm

disk_loop:
    jmp $

DISK_ERROR: db "Disk read error", 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0
