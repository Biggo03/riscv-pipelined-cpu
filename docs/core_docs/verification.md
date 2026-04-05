# Verification

This document describes the verification flow that exists in the repository today. It is intentionally workflow-focused rather than a long-term verification specification.

## What The Current Flow Covers

The active verification setup has three main layers:

- module-level testbenches for individual RTL blocks
- full-system tests that run assembly programs and bare-metal C programs on the processor
- supporting monitors, logs, waveforms, and program-build infrastructure

The main goal at this stage is practical regression testing and debug support, not formal coverage closure.

## Main Entry Points

Start with:

1. [tb/README.md](/home/wozniak/projects/riscv_pipelined/tb/README.md)
2. [scripts/test_driving/README.md](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/README.md)
3. [scripts/test_driving/test_catalog.yml](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_catalog.yml)
4. [scripts/test_driving/test_driver.py](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_driver.py)

## Verification Structure

### Module Tests

Module tests live in `tb/module_tests/`.

These are used for:

- focused debugging of single RTL blocks
- fast smoke testing of foundational modules
- catching local regressions before moving to full-system runs

Typical covered areas include:

- ALU and arithmetic helpers
- decoders
- register file and immediate extension
- hazard logic
- CSR blocks
- memory and cache support blocks
- branch-prediction support blocks

### System Tests

System tests use [tb/system_test/riscv_top_tb.sv](/home/wozniak/projects/riscv_pipelined/tb/system_test/riscv_top_tb.sv).

These tests run full programs on the processor and are used for:

- instruction-level end-to-end validation
- pipeline-control validation in realistic execution
- startup/linker/runtime validation for C programs
- performance logging and debug dumps

The system flow depends on program images built under [test_inputs/compiled_programs/](/home/wozniak/projects/riscv_pipelined/test_inputs/compiled_programs).

## Test Selection And Execution

The normal entry point is [scripts/test_driving/test_driver.py](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_driver.py).

The driver:

- reads [scripts/test_driving/test_catalog.yml](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_catalog.yml)
- expands named regressions into individual tests
- chooses the correct testbench
- generates a compile filelist in `filelists/`
- compiles with Icarus Verilog
- runs the produced simulation executable
- writes logs and artifacts into `sim_results/<test_name>/`

The test catalog currently groups tests into practical regression buckets such as:

- `component_smoke`
- `system_smoke`
- `c_smoke`

## Program Inputs

Full-system tests consume program images produced from:

- hand-written assembly tests in `test_inputs/compiled_programs/basic_asm_tests/`
- bare-metal C programs in `test_inputs/compiled_programs/c_programs/`

The test driver automatically looks for matching:

- `<test_name>.text.hex`
- `<test_name>.data.hex`

and passes those paths into simulation through compile-time defines.

## Pass/Fail Behavior

### Module Tests

Module testbenches decide pass/fail locally through their own checking logic and assertions.

### System Tests

System tests determine completion in the top-level testbench.

The main mechanism is:

- the program writes a test-status value through the CSR path
- `riscv_top_tb.sv` watches writeback for the status CSR address
- a matching pass/fail value ends the run

There is also a timeout guard for tests that fail to terminate.

Assembly tests usually signal completion through macros in `test_inputs/compiled_programs/common/test_macros.s`, while C programs use the same top-level completion path through the runtime/testbench interface.

## Outputs And Debug Artifacts

The verification flow produces:

- compile-and-run logs
- `.vvp` simulation executables
- VCD waveforms
- performance logs for system tests
- optional pipeline dump output when enabled

Most of these artifacts are written under `sim_results/`.

## Monitoring Infrastructure

The system testbench includes supporting monitor and dump infrastructure under `tb/system_test/`.

This includes:

- `performance_monitor.sv` for cycle, retire, stall, branch, and cache-related event tracking
- `pipeline_monitor.sv` for raw pipeline-state dumping
- dump tasks and post-processing helpers for more readable debug output

This infrastructure is intended to shorten debug time and make end-to-end failures easier to inspect.

## Current Practical Scope

At the current stage, the verification flow is best thought of as:

- a working module-regression setup
- a working program-driven system-regression setup
- a set of useful observability tools for debugging and performance inspection

It is not yet a complete formal verification plan or coverage-driven signoff flow.

## Related Documents

- [tb/README.md](/home/wozniak/projects/riscv_pipelined/tb/README.md)
- [docs/getting_started.md](/home/wozniak/projects/riscv_pipelined/docs/getting_started.md)
- [scripts/test_driving/README.md](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/README.md)
- [test_inputs/compiled_programs/README.md](/home/wozniak/projects/riscv_pipelined/test_inputs/compiled_programs/README.md)
