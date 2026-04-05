# Test Inputs

This directory contains non-RTL inputs used by verification and software-program flows.

The contents fall into three main groups:

- compiled or buildable processor programs
- directed vector files for leaf-module tests

## Directory Layout

### `compiled_programs/`

This is the main program-build subtree used by the current system-test flow.

It contains:

- assembly tests
- bare-metal C programs
- shared startup and linker files
- makefiles for building hex images, ELFs, and dumps

Start with [compiled_programs/README.md](/home/wozniak/projects/riscv_pipelined/test_inputs/compiled_programs/README.md).

### `vectors/`

This contains plain-text directed test vectors for lower-level module tests.

Examples include vectors for:

- ALU behavior
- extension logic
- reduction logic

These are mainly useful when reading or maintaining the corresponding module testbenches.

## What The System Test Flow Uses

For normal end-to-end program execution, the important subtree is:

- `test_inputs/compiled_programs/`

The regression driver searches there for program hex files and passes them into simulation.

## Generated Vs. Source Files

This directory contains a mix of hand-edited files and generated artifacts.

Examples of hand-edited inputs:

- assembly source
- C source
- linker script
- startup code
- makefiles
- vector text files

Examples of generated artifacts:

- `.elf`
- `.dump`
- `.hex`
- `.o`
- `.map`

If you are about to edit a generated file here, check the surrounding makefile or README first.

## Related Docs

- [compiled_programs/README.md](/home/wozniak/projects/riscv_pipelined/test_inputs/compiled_programs/README.md)
- [docs/getting_started.md](/home/wozniak/projects/riscv_pipelined/docs/getting_started.md)
- [tb/README.md](/home/wozniak/projects/riscv_pipelined/tb/README.md)
