# Testbenches

This directory contains the SystemVerilog verification code for the processor. It is split into small module-level tests and a full-system testbench that runs assembled or compiled programs on the core.

## Structure

- `common/`: shared macros and helper tasks used across testbenches
- `module_tests/`: directed testbenches for individual RTL blocks
- `system_test/`: top-level processor testbench, memory model, monitors, and dump tasks

## Module Tests

`module_tests/` is the path for block verification. Each testbench focuses on one RTL module or small subsystem and is typically used to debug local logic without running the full processor.

Examples:

- ALU, adder, decoder, and register file tests
- branch predictor support block tests
- cache and memory component tests
- hazard and CSR block tests

These tests are the right place to start when a failure appears isolated to one module.

## System Test

`system_test/riscv_top_tb.sv` is the full-chip simulation entry point used for assembly and C program runs.

At a high level it:

1. Instantiates `riscv_top`
2. Generates clock and reset
3. Loads waveform dumping
4. Instantiates performance and pipeline monitors
5. Detects program completion through the test-status CSR path
6. Times out long-running tests
7. Writes summary performance information before finishing

The full-system flow is program-driven:

- assembly tests and C programs are built under `test_inputs/compiled_programs/`
- the Python test driver passes the matching `.text.hex` and `.data.hex` files into simulation
- `main_mem_model.sv` provides refill data for the instruction-cache simulation path

## Common Helpers

`common/` contains shared verification utilities:

- `tb_macros.sv`: assertion helper, pass/fail constants, and common hierarchy aliases
- `misc_tasks.sv`: utility tasks such as VCD dump setup

These files keep the individual testbenches smaller and reduce repeated long hierarchical references.

## Monitors And Dump Tasks

The `system_test/monitors/` and `system_test/tasks/` directories support observability rather than core pass/fail logic.

- `performance_monitor.sv` tracks cycles, retired instructions, stalls, branch behavior, and cache events
- `pipeline_monitor.sv` emits raw per-cycle pipeline state when enabled
- the `*_dump_tasks.sv` files format stage-specific dump content
- `performance_calcs.sv` prints the end-of-test summary

This infrastructure is mainly for debugging, triage, and performance inspection after a run passes or fails.

## How This Directory Is Used

Normal test execution is driven by [scripts/test_driving/README.md](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/README.md) and [test_driver.py](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_driver.py), not by invoking `iverilog` manually.

The driver:

- selects tests from `scripts/test_driving/test_catalog.yml`
- chooses the correct testbench from `tb/`
- generates a filelist in `filelists/`
- compiles with Icarus Verilog
- runs the produced `.vvp`
- stores logs, VCDs, and monitor outputs under `sim_results/<test_name>/`

## When To Read What

- Start with `module_tests/` if you are debugging one RTL file.
- Start with `system_test/` if you are debugging program execution, pipeline control, cache behavior, or end-to-end regressions.
- Read `common/` if you need to understand how pass/fail detection, hierarchy aliases, or shared dump setup works.
