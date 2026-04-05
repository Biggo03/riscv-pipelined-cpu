# Workspace Overview

This document is a navigation map for the repository. Its purpose is to answer a simple question quickly: if you want to understand or change a part of the project, where do you start?

This is intentionally a workspace map, not an architecture specification. It points primarily to stable code and workflow entry points.

## Top-Level Layout

- `rtl/`: synthesizable processor RTL
- `tb/`: SystemVerilog verification code
- `test_inputs/`: program images, source programs, and directed vector inputs
- `scripts/`: automation for regressions, code generation, and debug utilities
- `docs/`: workspace, workflow, verification, and planning documentation
- `common/`: shared include files and board constraints
- `filelists/`: generated compile filelists used by the test flow
- `sim_results/`: simulation outputs and run artifacts
- `synthesis/`: synthesis-related inputs and technology files
- `archive/`: legacy material kept for reference, not active development

## If You Want To Understand The Processor

Start with the implementation, not the design docs:

1. [README.md](/home/wozniak/projects/riscv_pipelined/README.md)
2. [rtl/riscv_top.sv](/home/wozniak/projects/riscv_pipelined/rtl/riscv_top.sv)
3. [rtl/pipelined_riscv_core.sv](/home/wozniak/projects/riscv_pipelined/rtl/pipelined_riscv_core.sv)
4. the stage files in `rtl/`
5. the relevant testbench in `tb/`

Right now, the RTL and testbench code are the reliable source of truth for processor behavior.

## If You Want To Understand The RTL

The RTL is mostly organized by processor stage and subsystem:

- top-level integration: `rtl/riscv_top.sv`, `rtl/pipelined_riscv_core.sv`
- pipeline stages: `fetch_stage.sv`, `decode_stage.sv`, `execute_stage.sv`, `memory_stage.sv`, `writeback_stage.sv`
- datapath/control: `data_path.sv`, `control_unit.sv`, `hazard_unit.sv`
- branch handling: `branch_processing_unit.sv`, predictor-related files, branch control/resolution files
- memory path: `icache_l1.sv`, cache controller/set files, `instr_mem.sv`, `data_mem.sv`
- CSR path: `csr_decoder.sv`, `csr_alu.sv`, `csr_regfile.sv`
- support blocks: ALU, decoders, register file, immediate extender, write decoder, width decoder

If you are new to the codebase, read the top-level modules first and only then drill into the leaf blocks.

## If You Want To Understand Verification

Start here:

1. [tb/README.md](/home/wozniak/projects/riscv_pipelined/tb/README.md)
2. [scripts/test_driving/README.md](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/README.md)
3. [scripts/test_driving/test_catalog.yml](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/test_catalog.yml)
4. [tb/system_test/riscv_top_tb.sv](/home/wozniak/projects/riscv_pipelined/tb/system_test/riscv_top_tb.sv)

The verification code itself is split between:

- `tb/module_tests/` for unit and subsystem tests
- `tb/system_test/` for full-core program execution
- `scripts/test_driving/` for selection, compilation, execution, and result collection

## If You Want To Understand Program Execution

Start here:

1. [test_inputs/compiled_programs/README.md](/home/wozniak/projects/riscv_pipelined/test_inputs/compiled_programs/README.md)
2. `test_inputs/compiled_programs/linker.ld`
3. `test_inputs/compiled_programs/_start.s`
4. `test_inputs/compiled_programs/Makefile`

That subtree explains how assembly tests and C programs are turned into:

- instruction-memory hex images
- data-memory hex images
- ELF files
- disassembly dumps

Those images are then picked up by the system-test flow.

## If You Want To Understand The Scripts

The `scripts/` directory is organized by task family:

- `test_driving/`: main regression entry point
- `pipeline_dumping/`: pipeline dump generation and post-processing
- `csr_codegen/`: CSR file generation from spreadsheet data
- `signal_name_updates/`: rename/update utilities
- `test_vector_generator.py`: vector generation helper

Some scripts are part of the normal flow, while others are maintenance or debug tools. The most important operational script family is `scripts/test_driving/`.

## If You Want To Understand Shared Definitions

Look at:

- `common/includes/control_macros.sv`
- `common/includes/instr_macros.sv`
- `common/includes/csr_macros.sv`
- [docs/macro_overview.md](/home/wozniak/projects/riscv_pipelined/docs/macro_overview.md)

These files define the symbolic encodings that tie together RTL, testbench code, and generated infrastructure.

## Generated Vs. Source Material

It helps to separate the repository into source-like content and generated outputs:

- usually edited by hand: `rtl/`, `tb/`, `scripts/`, `docs/`, `common/`, most of `test_inputs/`
- generated during flows: `filelists/`, much of `sim_results/`, some checked-in program artifacts under `test_inputs/compiled_programs/`
- retained for historical reference: `archive/`

If you are not sure whether a file is generated, check the surrounding directory README or the script/makefile that produces it before editing.

## Recommended Reading Paths

For verification work:

1. `tb/README.md`
2. `scripts/test_driving/`
3. `tb/module_tests/` or `tb/system_test/`

For software/program-flow work:

1. `test_inputs/compiled_programs/README.md`
2. linker and startup files
3. system testbench and test driver

For project planning/status:

1. [docs/roadmap.md](/home/wozniak/projects/riscv_pipelined/docs/roadmap.md)
2. [docs/TODO.md](/home/wozniak/projects/riscv_pipelined/docs/TODO.md)
3. `docs/devlogs/`
