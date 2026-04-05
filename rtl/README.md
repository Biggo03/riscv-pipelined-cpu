# RTL

This directory contains the synthesizable SystemVerilog source for the processor.

At the current stage of the project, this directory is one of the main sources of truth for processor behavior.

## How The RTL Is Organized

The files are grouped loosely by role:

- top-level integration
- pipeline stages
- control and datapath coordination
- branch prediction and branch handling
- memory and cache path
- CSR support
- small reusable building blocks

## Main Entry Points

Start with these files:

- `riscv_top.sv`: top-level wrapper used by the system test flow
- `pipelined_riscv_core.sv`: core integration point
- `fetch_stage.sv`
- `decode_stage.sv`
- `execute_stage.sv`
- `memory_stage.sv`
- `writeback_stage.sv`

If you are new to the RTL, read the top-level integration files first, then the stage files, then the lower-level support modules.

## Useful File Groups

### Top Level

- `riscv_top.sv`
- `pipelined_riscv_core.sv`

These are the best starting points for understanding how the processor is assembled and what major submodules exist.

### Pipeline And Core Control

- `data_path.sv`
- `control_unit.sv`
- `hazard_unit.sv`
- the stage files

These files are where most execution flow and inter-stage behavior are coordinated.

### Branch Handling

- `branch_processing_unit.sv`
- `branch_predictor.sv`
- `branch_control_unit.sv`
- `branch_resolution_unit.sv`
- `branching_buffer.sv`
- `local_predictor.sv`
- `ghr.sv`

### Memory Path

- `icache_l1.sv`
- `instr_cache_ctlr.sv`
- `instr_cache_set_multi.sv`
- `instr_mem.sv`
- `data_mem.sv`

### CSR Path

- `csr_decoder.sv`
- `csr_alu.sv`
- `csr_regfile.sv`

### Building Blocks

- `alu.sv`
- `adder.sv`
- `reg_file.sv`
- `imm_extend.sv`
- `main_decoder.sv`
- `alu_decoder.sv`
- `width_decoder.sv`
- `write_decoder.sv`
- `flop.sv`
- `reduce.sv`

## How To Use This Directory

- If you are debugging one block, pair the RTL file with its matching testbench in `tb/module_tests/`.
- If you are debugging end-to-end execution, pair the top-level RTL with `tb/system_test/riscv_top_tb.sv`.
- If you are trying to understand compile-time behavior, also read `common/includes/` and [docs/macro_overview.md](/home/wozniak/projects/riscv_pipelined/docs/macro_overview.md).

## Related Docs

- [tb/README.md](/home/wozniak/projects/riscv_pipelined/tb/README.md)
- [docs/getting_started.md](/home/wozniak/projects/riscv_pipelined/docs/getting_started.md)
- [docs/workspace_overview.md](/home/wozniak/projects/riscv_pipelined/docs/workspace_overview.md)
