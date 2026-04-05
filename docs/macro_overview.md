# Macro Overview

This document focuses on the macros that actually change build or simulation behavior.

It is split into:

- RTL-facing behavior macros
- Testbench-facing behavior macros
- Short summaries of the static macro include files

Intentionally excluded:

- All CSR-specific macros
- `common/includes/csr_macros.sv`
- CSR-related entries in `common/includes/control_macros.sv`

## RTL Behavior Macros

These are the macros that matter most when compiling or configuring the design.

### `SIM`

- Purpose: Enables simulation-only RTL behavior.
- Where used: [rtl/riscv_top.sv](/home/wozniak/projects/riscv_pipelined/rtl/riscv_top.sv)
- Effect: Under `SIM`, `riscv_top` instantiates `main_mem_model` to feed cache refill data during simulation.
- Where it comes from: Added by the regression driver in [scripts/test_driving/test_driver.py](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_driver.py).

### `NO_ICACHE`

- Purpose: Bypasses the instruction cache path.
- Where used: [rtl/riscv_top.sv](/home/wozniak/projects/riscv_pipelined/rtl/riscv_top.sv)
- Effect: When defined, the top level instantiates `instr_mem` directly instead of `icache_l1`.
- Where it comes from: Optional compile-time define. It is not injected by default by the main test driver.

### `INSTR_HEX_FILE`

- Purpose: Supplies the instruction memory image path.
- Where used:
  - [rtl/instr_mem.sv](/home/wozniak/projects/riscv_pipelined/rtl/instr_mem.sv)
  - [tb/system_test/main_mem_model.sv](/home/wozniak/projects/riscv_pipelined/tb/system_test/main_mem_model.sv)
- Effect: Passed to `$readmemh(...)` to initialize instruction storage.
- Where it comes from: Added by [scripts/test_driving/test_driver.py](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_driver.py) for system tests when a matching `.text.hex` file is found.

### `DATA_HEX_FILE`

- Purpose: Supplies the data memory image path.
- Where used: [rtl/data_mem.sv](/home/wozniak/projects/riscv_pipelined/rtl/data_mem.sv)
- Effect: Passed to `$readmemh(...)` to initialize data memory contents.
- Where it comes from: Added by [scripts/test_driving/test_driver.py](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_driver.py) for system tests when a matching `.data.hex` file is found.

## Testbench Behavior Macros

These macros are used by the testbench and monitoring infrastructure to change what gets emitted or how simulation artifacts are written.

### `DUMP_FILE`

- Purpose: Selects the VCD output filename.
- Where used: [tb/common/misc_tasks.sv](/home/wozniak/projects/riscv_pipelined/tb/common/misc_tasks.sv)
- Effect: If defined, `dump_setup` calls `$dumpfile(`DUMP_FILE)` and enables waveform dumping.
- Where it comes from: Added by [scripts/test_driving/test_driver.py](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_driver.py) for all regression runs.

### `DUMP_PATH`

- Purpose: Selects the output directory for auxiliary logs.
- Where used:
  - [tb/system_test/riscv_top_tb.sv](/home/wozniak/projects/riscv_pipelined/tb/system_test/riscv_top_tb.sv)
  - [tb/system_test/monitors/pipeline_monitor.sv](/home/wozniak/projects/riscv_pipelined/tb/system_test/monitors/pipeline_monitor.sv)
- Effect: Controls where pipeline dumps and performance logs are written.
- Where it comes from: Added by [scripts/test_driving/test_driver.py](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_driver.py) for all regression runs.

### `PIPELINE_DUMP`

- Purpose: Gates raw pipeline-state dumping.
- Where used:
  - [tb/system_test/riscv_top_tb.sv](/home/wozniak/projects/riscv_pipelined/tb/system_test/riscv_top_tb.sv)
  - [tb/system_test/monitors/pipeline_monitor.sv](/home/wozniak/projects/riscv_pipelined/tb/system_test/monitors/pipeline_monitor.sv)
- Effect:
  - Opens `raw_pipeline_dump.yml`
  - Enables per-cycle dump task execution
- Where it comes from: Optional compile-time define. It is not added by default by the main test driver.

### `PERF_CYCLE_DUMP`

- Purpose: Gates cycle-by-cycle event logging in the performance monitor.
- Where used: [tb/system_test/monitors/performance_monitor.sv](/home/wozniak/projects/riscv_pipelined/tb/system_test/monitors/performance_monitor.sv)
- Effect: Adds detailed event lines such as load stalls, branch mispredictions, and icache misses to the performance log.
- Where it comes from: Optional compile-time define. It is not added by default by the main test driver.

### `C_PROGRAM`

- Purpose: Intended to gate C-program-specific I/O behavior.
- Where used:
  - Mentioned in [tb/system_test/riscv_top_tb.sv](/home/wozniak/projects/riscv_pipelined/tb/system_test/riscv_top_tb.sv)
  - Added by [scripts/test_driving/test_driver.py](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_driver.py) for tests tagged `c_program`
- Current status: The corresponding `ifdef` blocks in `riscv_top_tb.sv` are commented out, so this define is currently available in the flow but not actively changing runtime behavior.

## Static Macro Files

These files define constant encodings and helper macros that are included by RTL or testbench code. They do matter, but they are mostly fixed symbolic names rather than compile-time behavior switches.

### RTL Static Macro Files

#### [common/includes/control_macros.sv](/home/wozniak/projects/riscv_pipelined/common/includes/control_macros.sv)

Contains symbolic encodings for non-CSR control signals, including:

- register-write enables
- immediate-source selection
- ALU source selection
- memory-write control
- result-source selection
- branch-op selection
- width processing control
- ALU op and ALU control encodings
- width result encodings
- PC source and PC base selection
- forwarding-source selection

This file is mainly consumed by decode, execute, fetch, hazard, memory, and cache-control RTL.

#### [common/includes/instr_macros.sv](/home/wozniak/projects/riscv_pipelined/common/includes/instr_macros.sv)

Contains symbolic instruction-field constants, including:

- opcode values
- `funct3` decode values for branch, ALU, and width handling
- `NOP_INSTR`

This file is mainly used by the decoder path and by system-test monitoring code that classifies instructions.

### Testbench Static Macro File

#### [tb/common/tb_macros.sv](/home/wozniak/projects/riscv_pipelined/tb/common/tb_macros.sv)

Contains three kinds of static testbench macros:

- `CHECK(...)`
  - standard non-fatal assertion helper that increments `error_cnt`
- `TEST_PASS` / `TEST_FAIL`
  - magic completion values used by the top-level system testbench
- hierarchy aliases such as `DATA_PATH_HIER`, `HAZARD_UNIT_HIER`, and `ICACHE_HIER`
  - shorten long hierarchical references in dump tasks and monitors

## Practical Summary

If you are trying to understand what macros actually change behavior during simulation, focus on:

- `SIM`
- `NO_ICACHE`
- `INSTR_HEX_FILE`
- `DATA_HEX_FILE`
- `DUMP_FILE`
- `DUMP_PATH`
- `PIPELINE_DUMP`
- `PERF_CYCLE_DUMP`
- `C_PROGRAM`

If you are trying to understand symbolic encodings used throughout the RTL, start with:

- [common/includes/control_macros.sv](/home/wozniak/projects/riscv_pipelined/common/includes/control_macros.sv)
- [common/includes/instr_macros.sv](/home/wozniak/projects/riscv_pipelined/common/includes/instr_macros.sv)

If you are trying to understand shared verification helpers, start with:

- [tb/common/tb_macros.sv](/home/wozniak/projects/riscv_pipelined/tb/common/tb_macros.sv)
- [tb/common/misc_tasks.sv](/home/wozniak/projects/riscv_pipelined/tb/common/misc_tasks.sv)
