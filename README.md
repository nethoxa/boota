# BOOTA

An x86 32-bit kernel and bootloader written from scratch in NASM assembly and C.

> The name comes from the English *boot* and Spanish *bota* (a shoe) -- I'm stupid nvm me.

## Build and Run

```bash
# Build the toolchain image (one-time)
docker build -t boota-env .

# Compile the kernel
docker run --rm -v "$(pwd)/src:/boota/src" boota-env make -C src

# Run in terminal
docker run --rm -it -v "$(pwd)/src:/boota/src" \
    boota-env qemu-system-i386 -drive format=raw,file=src/os-image.bin,if=floppy -display curses

# Clean
docker run --rm -v "$(pwd)/src:/boota/src" boota-env make -C src clean
```

### Boot Flow

```
 BIOS POST
  |
  v
 bootsect.asm            [16-bit real mode, loaded at 0x7C00]
  |-- Sets up stack at 0x9000
  |-- Loads 31 sectors from disk into 0x1000
  |-- Calls switch
  |
  v
 switch.asm              [real -> protected mode transition]
  |-- cli (disable interrupts)
  |-- Enable A20 line (fast gate, port 0x92)
  |-- lgdt (load GDT descriptor)
  |-- Set CR0 bit 0
  |-- Far jump to 32-bit code segment
  |
  v
 init_pm                 [32-bit protected mode]
  |-- Initialize segment registers (DS, SS, ES, FS, GS)
  |-- Set up protected mode stack at 0x90000
  |-- call KERNEL_OFFSET (0x1000)
  |
  v
 kernel_entry.asm        [kernel entry point]
  |-- call kernel_main()
  |
  v
 kernel.c                [C kernel]
  |-- init_memory()  -> Heap init from _kernel_end
  |-- isr_install()  -> IDT gates + PIC remapping
  |-- irq_install()  -> Timer (50 Hz) + Keyboard
  |-- terminal()     -> Interactive shell loop
```

### Memory Map

```
 Address         Size        Description
 ──────────────────────────────────────────────────────
 0x00000         1.25 KB     Real mode IVT + BIOS data area
 0x01000         ~15.5 KB    Kernel image (31 sectors)
 0x07C00         512 B       Bootloader (MBR)
 0x09000         --          Real mode stack base
 _kernel_end     grows up    Kernel heap (kmalloc, page-aligned)
 0x90000         grows down  Protected mode stack
 0xB8000         4000 B      VGA text mode buffer (80x25x2)
```

### Interrupt Layout

| Range   | Type          | Description                              |
|---------|---------------|------------------------------------------|
| 0-31    | ISR (CPU)     | CPU exceptions (Divide by Zero, Page Fault, GPF, etc.) |
| 32      | IRQ0          | Programmable Interval Timer (50 Hz)      |
| 33      | IRQ1          | PS/2 Keyboard                            |
| 34-47   | IRQ2-IRQ15    | Available (not currently used)           |

## Demo

https://github.com/nethoxa/boota/assets/135072738/d9774529-1529-4a56-bc6d-c51358a088c5

## Acknowledgments

- Nick Blundell, [*Writing a Simple Operating System -- from Scratch*](https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf)
- [OSDev Wiki](https://wiki.osdev.org/) -- an invaluable reference for x86 OS development
