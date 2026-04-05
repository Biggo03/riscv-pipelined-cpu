# Getting Started

This document is a practical starting point for working in the repository. It is aimed at someone who wants to read the project, run the common flows, and know where results end up.

It intentionally focuses on current workflows and code entry points. It does not rely on architecture/spec documentation being complete.

## Recommended First Read

Before running anything, read:

1. [README.md](/home/wozniak/projects/riscv_pipelined/README.md)
2. [docs/workspace_overview.md](/home/wozniak/projects/riscv_pipelined/docs/workspace_overview.md)
3. [tb/README.md](/home/wozniak/projects/riscv_pipelined/tb/README.md)
4. [test_inputs/compiled_programs/README.md](/home/wozniak/projects/riscv_pipelined/test_inputs/compiled_programs/README.md)
5. [rtl/riscv_top.sv](/home/wozniak/projects/riscv_pipelined/rtl/riscv_top.sv) and [rtl/pipelined_riscv_core.sv](/home/wozniak/projects/riscv_pipelined/rtl/pipelined_riscv_core.sv)

That sequence gives you the project goal, repository map, verification structure, program-build flow, and the main implementation entry points.

## Common Tools

The day-to-day flows in this workspace rely on:

- Python 3
- Icarus Verilog (`iverilog`)
- the RISC-V ELF toolchain used by `test_inputs/compiled_programs`
- `make`
- `hexdump`
- optionally GTKWave for waveform inspection

## First Useful Commands

### List available tests

From [scripts/test_driving/](/home/wozniak/projects/riscv_pipelined/scripts/test_driving):

```sh
cd scripts/test_driving
./test_driver.py -l
```

This prints the currently defined unit, assembly, and C-program tests from `test_catalog.yml`.

### Run a small module regression

```sh
cd scripts/test_driving
./test_driver.py -r component_smoke
```

Use this when you want a quick check of the common RTL building blocks.

### Run assembly-program system tests

```sh
cd scripts/test_driving
./test_driver.py -r system_smoke
```

Use this when you want to verify end-to-end execution of the directed assembly programs.

### Run C-program system tests

```sh
cd scripts/test_driving
./test_driver.py -r c_smoke
```

Use this when you want to verify the startup code, linker layout, and bare-metal C flow.

### Run one specific test

```sh
cd scripts/test_driving
./test_driver.py -t hazard_unit
./test_driver.py -t basic_execution
```

This is the usual path when debugging one module or one program.

## Where Outputs Go

By default, the regression driver writes results under [sim_results/](/home/wozniak/projects/riscv_pipelined/sim_results).

Each test gets its own directory, typically containing:

- compile-and-run log
- generated `.vvp`
- VCD waveform
- performance log for system tests
- optional pipeline dump output when enabled

The driver also writes generated filelists into [filelists/](/home/wozniak/projects/riscv_pipelined/filelists).

## Building Program Images

Program images are built separately from simulation.

From [test_inputs/compiled_programs/](/home/wozniak/projects/riscv_pipelined/test_inputs/compiled_programs):

```sh
make
make asm
make c
make clean
```

This flow generates the hex files that the system-test flow later loads.

Use:

- `make asm` for directed assembly tests
- `make c` for bare-metal C programs

For the memory model and startup behavior, see [test_inputs/compiled_programs/README.md](/home/wozniak/projects/riscv_pipelined/test_inputs/compiled_programs/README.md).

## A Typical Debug Loop

When working on one RTL issue, the practical loop is:

1. Identify whether it is local to one module or only visible in full-system runs.
2. Run the smallest relevant test from `scripts/test_driving/test_catalog.yml`.
3. Inspect the test log and waveform in `sim_results/<test_name>/`.
4. If needed, rerun with extra defines such as pipeline dump support.
5. Only move to broader regressions after the focused test passes.

This keeps turnaround fast and makes failures easier to interpret.

## Understanding Pass/Fail

There are two common paths:

- module tests decide pass/fail inside their own testbench logic
- system tests detect completion through the top-level testbench by watching the test-status CSR writeback path

In the system flow, assembly tests typically signal pass/fail through test macros, and C programs complete through the same testbench-visible status mechanism.

## High-Value Files To Know

- [rtl/riscv_top.sv](/home/wozniak/projects/riscv_pipelined/rtl/riscv_top.sv): simulation/soc-facing top level
- [rtl/pipelined_riscv_core.sv](/home/wozniak/projects/riscv_pipelined/rtl/pipelined_riscv_core.sv): core integration point
- [tb/system_test/riscv_top_tb.sv](/home/wozniak/projects/riscv_pipelined/tb/system_test/riscv_top_tb.sv): full-system testbench
- [scripts/test_driving/test_driver.py](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_driver.py): main regression runner
- [scripts/test_driving/test_catalog.yml](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_catalog.yml): test inventory
- [test_inputs/compiled_programs/linker.ld](/home/wozniak/projects/riscv_pipelined/test_inputs/compiled_programs/linker.ld): memory layout for programs
- [test_inputs/compiled_programs/_start.s](/home/wozniak/projects/riscv_pipelined/test_inputs/compiled_programs/_start.s): C runtime entry

## What To Read Next

- If you are changing RTL: go to `rtl/` and the relevant module testbench in `tb/module_tests/`.
- If you are changing end-to-end behavior: read `tb/system_test/` and the program flow in `test_inputs/compiled_programs/`.
- If you are changing infrastructure: read `scripts/test_driving/`, `scripts/pipeline_dumping/`, or `scripts/csr_codegen/`.
- If you are trying to understand current project priorities: read [docs/roadmap.md](/home/wozniak/projects/riscv_pipelined/docs/roadmap.md) and [docs/TODO.md](/home/wozniak/projects/riscv_pipelined/docs/TODO.md).
