# Directories
COMMON_DIR = common

# Toolchain
CROSS_COMPILE ?= riscv64-unknown-elf-

CC      := $(CROSS_COMPILE)gcc
OBJCOPY := $(CROSS_COMPILE)objcopy
OBJDUMP := $(CROSS_COMPILE)objdump

# RISC-V Target
ARCH = rv32i_zicsr
ABI  = ilp32

# Shared linker
LINKER    = linker.ld

include make_asm.mk
include make_c.mk

all: asm c

clean: asm-clean c-clean
