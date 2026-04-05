# `compiled_programs`

This directory contains the bare-metal test programs used to generate instruction-memory and data-memory images for the RISC-V core.

## Directory layout

- `basic_asm_tests/`: hand-written assembly tests
- `c_programs/`: bare-metal C tests
- `common/`: shared headers and assembly macros

## Memory map

`linker.ld` defines a simple split memory system:

| Region | Origin | Size | Purpose |
| --- | --- | --- | --- |
| `IMEM` | `0x00000000` | `32K` | Executable code (`.text`, `.init`) |
| `DMEM` | `0x20000000` | `32K` | Constants, initialized data, zero-init data, heap, stack |

### Section placement

- `.text`: placed in `IMEM`
- `.init`: placed in `IMEM`
- `.rodata`: placed in `DMEM`
- `.data`: placed in `DMEM`
- `.sdata`: placed in `DMEM`
- `.sbss`: placed in `DMEM` as `NOLOAD`
- `.bss`: placed in `DMEM` as `NOLOAD`

### Important linker behavior

This linker script does not define a ROM-to-RAM copy for initialized data. Instead:

- code is emitted into `.text.hex`
- C data payloads are emitted separately into `.data.hex`
- `.bss` and `.sbss` are not stored in the hex files and must start as zero

In other words, the intended load model is:

- preload instruction memory from `.text.hex`
- preload data memory from `.data.hex` for C programs
- let startup clear `.bss` and `.sbss`

## Startup file

`_start.s` is the runtime entry point for the C programs. Its job is minimal and explicit:

1. Load `gp` from `__global_pointer$`
2. Load `sp` from `__stack_top`
3. Subtract 16 bytes and align `sp` to a 16-byte boundary
4. Zero the `.bss` range
5. Zero the `.sbss` range
6. Call `main`
7. If `main` returns, loop forever

This file does not:

- copy `.data` from one memory region to another
- install interrupt vectors
- initialize a C library runtime
- provide an exit path

### Assembly tests vs. `_start.s`

The assembly tests under `basic_asm_tests/` do not use `_start.s` in the current top-level flow. Each assembly test defines its own `_start` label directly in its `.s` file.

Most of those tests include `common/test_macros.s`, which provides:

- `SIGNAL_TEST_PASS`
- `SIGNAL_TEST_FAIL`

Those macros write status values to CSR `0x7C0`, which is the testbench-facing pass/fail signal path.

## Makefiles

### Top-level `Makefile`

The top-level `Makefile` is the entry point for this directory. In practice, you use it to build either all programs, only the assembly tests, or only the C tests.

Common usage:

```sh
make
make asm
make c
make clean
```

### `make_asm.mk`

This makefile builds the self-contained assembly tests under `basic_asm_tests/`. Each test provides its own `_start` entry point, so this flow is independent of the shared C runtime startup file.

At a high level, the assembly flow produces an ELF for inspection, a disassembly dump, and an instruction-memory hex image for simulation.

### `make_c.mk`

This makefile builds the bare-metal C programs under `c_programs/`. Unlike the assembly flow, it uses the shared startup code in `_start.s` before entering `main`.

### Build flow

1. Compile `_start.s` once into `_start.o`
2. For each program directory, link `_start.o` with every `.c` file in that directory
3. Generate disassembly and hex images from the ELF

At a high level, the C flow produces an ELF, a disassembly dump, an instruction-memory hex image, and a separate data-memory hex image.

## Adding a new program

### New assembly test

1. Create a new subdirectory under `basic_asm_tests/`
2. Add a single `.s` file with the same basename as the directory
3. Define `_start` inside that file
4. Run `make asm`

### New C test

1. Create a new subdirectory under `c_programs/`
2. Add one or more `.c` files
3. Implement `main`
4. Run `make c`

## Practical load model

For simulation or memory initialization, the usual mapping is:

- load `<prog>.text.hex` into instruction memory at `0x00000000`
- load `<prog>.data.hex` into data memory at `0x20000000` for C programs
- for assembly-only tests, only instruction memory is typically needed unless the testbench preloads RAM separately

## Miscellaneous notes

- The checked-in `.map` files are examples/reference artifacts; the current top-level makefiles do not generate `.map` files.
- The top-level flow assumes the RISC-V ELF toolchain binaries and `hexdump` are available on `PATH`.
