# RTL

Synthesizable SystemVerilog source for the processor.

## Top Level

- `riscv_top.sv`
- `pipelined_riscv_core.sv`

## Pipeline Stages

- `fetch_stage.sv`
- `decode_stage.sv`
- `execute_stage.sv`
- `memory_stage.sv`
- `writeback_stage.sv`

## Datapath and Control

- `data_path.sv`
- `control_unit.sv`
- `hazard_unit.sv`
- `main_decoder.sv`
- `alu_decoder.sv`
- `width_decoder.sv`
- `write_decoder.sv`

## Branch Prediction and Control

- `branch_processing_unit.sv`
- `branch_predictor.sv`
- `branch_control_unit.sv`
- `branch_resolution_unit.sv`
- `branching_buffer.sv`
- `local_predictor.sv`
- `ghr.sv`

## Memory and Cache

- `icache_l1.sv`
- `instr_cache_ctlr.sv`
- `instr_cache_set_multi.sv`
- `instr_mem.sv`
- `data_mem.sv`

## CSR

- `csr_decoder.sv`
- `csr_alu.sv`
- `csr_regfile.sv`

## Building Blocks

- `alu.sv`
- `adder.sv`
- `reg_file.sv`
- `imm_extend.sv`
- `flop.sv`
- `reduce.sv`
