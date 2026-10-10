# Macro Overview

Quick reference for compile-time macros that must be provided externally.

| Macro | Purpose | Where Used | Effect | Where It Comes From |
| --- | --- | --- | --- | --- |
| `SIM` | Enables simulation-specific behavior | `rtl/riscv_top.sv` | Enables the simulation memory model | Added by `scripts/test_driving/test_driver.py` |
| `NO_ICACHE` | Bypasses the instruction cache | `rtl/riscv_top.sv` | Uses `instr_mem` directly instead of `icache_l1` | Optional compile-time define |
| `INSTR_HEX_FILE` | Specifies the instruction-memory image | `rtl/instr_mem.sv`, `tb/system_test/main_mem_model.sv` | Supplies the file used by `$readmemh` for instruction memory | Added by the test driver when an instruction image is available |
| `DATA_HEX_FILE` | Specifies the data-memory image | `rtl/data_mem.sv` | Supplies the file used by `$readmemh` for data memory | Added by the test driver when a data image is available |
| `DUMP_FILE` | Specifies the VCD waveform filename | `tb/common/misc_tasks.sv` | Sets the waveform output file | Added by the test driver |
| `DUMP_PATH` | Specifies the simulation output directory | System-test dump and monitoring code | Sets the location of simulation logs and dump files | Added by the test driver |
| `PIPELINE_DUMP` | Enables detailed pipeline dumping | System-test monitoring code | Enables per-cycle pipeline state dumps | Optional compile-time define |
| `PERF_CYCLE_DUMP` | Enables detailed performance-event logging | `tb/system_test/monitors/performance_monitor.sv` | Logs cycle-level stalls, misses, branch mispredicts, and related events | Optional compile-time define |
| `C_PROGRAM` | Identifies a test as a C program | System-test infrastructure | Enables C-program-specific simulation behavior where supported | Added by the test driver for tests tagged `c_program` |

## Macro Files

Static macros are defined in:

- [`common/includes/control_macros.sv`](../common/includes/control_macros.sv)
- [`common/includes/instr_macros.sv`](../common/includes/instr_macros.sv)
- [`common/includes/csr_macros.sv`](../common/includes/csr_macros.sv)
- [`tb/common/tb_macros.sv`](../tb/common/tb_macros.sv)
