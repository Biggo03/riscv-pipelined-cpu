# Program Build Flow

## Target
ISA: rv32i_zicsr
ABI: ilp32
Toolchain: $(CROSS_COMPILE){gcc,objcopy,objdump}

## Memory Layout
IMEM 0x00000000, 32 KiB
DMEM 0x20000000, 32 KiB

.text/.init      -> IMEM / .text.hex
.rodata/.data/
.sdata           -> DMEM / .data.hex
.bss/.sbss       -> zeroed by _start.s

## Runtime
C programs enter through _start.s:
- initialize gp
- initialize sp
- clear .bss/.sbss
- call main

Assembly tests provide their own _start.

## Usage
make
make asm
make c
make clean
