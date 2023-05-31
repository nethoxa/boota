# BOOTA
It's a joke between boot in English and 'bota' in Spanish (which is a type of shoe)... asghdfajsdfgahsdf

## Index
- [BOOTA](#boota)
  - [Index](#index)
  - [Layout](#layout)
  - [Video](#video)
  - [Comands](#comands)
  - [Description](#description)

## Layout
- `src` --- kernel source file
  - `boot` --- bootloader
  - `cpu` --- interruptions and drivers
  - `kernel` --- kernel
  - `libc` --- C libraries
  - `Makefile` --- Makefile
- `video` --- POC
- `os-dev.pdf` --- MUST-READ
- `README` --- this file
- `run` --- use it, really

## Video
https://github.com/erebus-eth/boota/assets/135072738/df9effd2-b2ea-46f6-a49f-0aa3e618b928

## Comands
El kernel implementa los siguientes comandos:

- HELP -> muestra un mensaje con la funcionalidad de cada comando
- POWER OFF -> apaga el sistema (en el caso de QEMU apaga la ventana)
- STACK -> muestra el stack en formato hexadecimal
- REBOOT -> reinicia la sesión (en el caso de QEMU hace un parpadeo y reinicia)
- HALT -> exit abrupto del sistema
- MEM -> reserva una página de memoria

En caso de meter algo que no esté permitido, devolverá el input del usuario por pantalla. Hay un [run](run) que automatiza todo, desde compilar hasta ejecutar. Si no quieres que elimine los archivos después de ejecutar, borra la línea 12 del archivo o dale a la opción 2.

## Description
Primero, empezamos definiendo una serie de [funciones](/src/boot/real/print.asm) para imprimir por pantalla en modo real:

- `print_rm` es cout en la consola usando tty
- `print_rm_carry` es para el '\n'
- `print_rm_hex` para mostrar en formato decimal (errores, stack...)

que serán usadas por la función de [lectura de disco](src/boot/real/disk.asm) para mostrar errores al cargar el kernel de disco. A futuro, se usará en un sistema de archivos o para optimizar el uso de la RAM con escrituras a disco (TL;DR no está implementado).

Seguimos con el cambio a modo protegido llamando a la función [switch](src/boot/real/switch.asm), que desactiva las interrupciones, carga el [descriptor GDT](src/boot/protected/gdt.asm), cambia el registro `cr0` a modo protegido y llama a [init_pm](src/boot/real/switch.asm), que inicializa el resto de registros, el stack y le da paso al módulo que inicializa el [kernel_entry](src/boot/kernel_entry.asm). Este a su vez llama al `main` del módulo del [kernel](src/kernel/kernel.c).

En el [kernel](src/kernel/kernel.c), se inicializan las rutinas de servicio de interrupción [(ISR)](src/cpu/isr.c) y las rutinas de petición de interrupción [(IRQ)](src/cpu/isr.c), registrando los callbacks

- `isr_handler` para las `ISRs`
- `irq_handler` para los `IRQs`

Por ahora, sólo tenemos dos `IRQs`, el [reloj](src/cpu/timer.c) y el [teclado](src/drivers/keyboard.c). Para el [teclado](src/drivers/keyboard.c), hay que definir primero una serie de [puertos](src/cpu/ports.c) con los que se comunica, de manera que podamos recibir las interrupciones provenientes de los dispositivos.

Para poder mostrar texto y una terminal básica, necesitamos trabajar con la [VGA](src/drivers/screen.c). Se implementan una serie de funciones que imprimen en el array de la [VGA](src/drivers/screen.c) los distintos caracteres que queramos, como al escribir en el teclado, así como para los mensajes que se envían desde el propio kernel.

Por último, el kernel implementa una serie de funciones que simulan los comandos usuales que se podrían esperar en una terminal de comandos.

Usamos una [librería](src/libc/) para definir las funciones auxiliares como `memcpy` o `strcmp` de C.
