disk_load:
    pusha
    push dx

    mov ah, 0x02            ; read
    mov al, dh              ; num de sectores
    mov cl, 0x02            ; sector actual, el 1 es el bootloader
    
    mov ch, 0x00            ; cilindro
    mov dh, 0x00            ; cabeza

    int 0x13      
    jc disk_error 

    pop dx
    cmp al, dh              ; BIOS pone en al el número de sectores leídos
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

DISK_ERROR: db "Error al leer de disco", 0
SECTORS_ERROR: db "Numero incorrecto de sectores leidos", 0
