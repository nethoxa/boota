print_rm:
    pusha

    print_rm_start:
        mov al, [bx]        ; bx = string[i]
        cmp al, 0           ; '\0'
        je print_rm_end

        mov ah, 0x0e        ; tty
        int 0x10 

        add bx, 1
        jmp print_rm_start

    print_rm_end:
        popa
        ret



print_rm_carry:
    pusha
    
    mov ah, 0x0e
    mov al, 0x0a ; newline char
    int 0x10
    mov al, 0x0d ; carriage return
    int 0x10
    
    popa
    ret


print_rm_hex:
    pusha

    mov cx, 0 

    print_rm_hex_start:
        cmp cx, 4 
        je print_rm_hex_end
        
        mov ax, dx 
        and ax, 0x000f                  ; mask
        add al, 0x30                    ; 0-9
        cmp al, 0x39 ;                  ; A-F
        jle print_rm_hex_next
        add al, 7                       ; 'A' is ASCII 65 instead of 58, so 65-58=7

    print_rm_hex_next:
        mov bx, HEX_OUT + 5
        sub bx, cx 
        mov [bx], al
        ror dx, 4                       ; 0x1234 -> 0x4123 -> 0x3412 -> 0x2341 -> 0x1234

        add cx, 1
        jmp print_rm_hex_start

    print_rm_hex_end:
        mov bx, HEX_OUT
        call print_rm

        popa
        ret

HEX_OUT:
    db '0x0000',0 ; reserve memory for our new string
