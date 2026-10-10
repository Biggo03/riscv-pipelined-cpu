# RISC-V Processor Project
A from-scratch RISC-V RV32I processor implemented in SystemVerilog, developed to explore computer architecture, pipelining, caching, and performance monitoring through hands-on design.

---

## Overview
This project implements a five-stage pipelined RISC-V processor with branch prediction, instruction caching, and an extensible verification and benchmarking framework.
It serves as both a learning platform and a demonstration of practical digital design.

**Key architectural components include:**
- Five-stage pipeline with hazard detection and forwarding
- Two-level branch prediction (local and global predictors)
- Instruction cache with LRU replacement
- Cycle-accurate performance measurement and benchmarking support
- Python-based test framework for regression and benchmark automation

The design targets FPGA implementation and is developed with synthesis compatibility in mind.

---

## Current Stage

The project is in a transition phase where the verification flow, tooling, and repository structure are more stable than the detailed design documentation.

At the moment:

- the RTL and testbench are the source of truth for detailed behavior
- the active documentation focuses on navigation, workflows, verification, and program build flow
- detailed architecture-specification documentation is intentionally limited until the next round of design changes settles

For current priorities, see the [project roadmap](docs/roadmap.md).

---

## Repository Structure

- **rtl/** – Processor source files (SystemVerilog)
- **tb/** – Testbenches and verification infrastructure
- **common/** – Global macro definitions used across RTL and testbench code
- **docs/** – Active documentation for workspace navigation, workflows, verification, and project planning
  - **workspace_overview.md** – Map of the repository and major entry points
  - **getting_started.md** – First commands, common flows, and output locations
  - **core_docs/** – Small set of active high-level docs such as verification and supported instructions
  - **spreadsheets/** – Signal, CSR, and instruction decode reference data
  - **devlogs/** – Chronological development logs
  - **roadmap.md** – Current development focus and long-term plans
  - **style_guide.md** – Naming, formatting, and documentation conventions
- **scripts/** – Build, simulation, and automation scripts
- **test_inputs/** – Software toolchain and test programs for the processor, including:
  - RISC-V C/assembly compilation flow and programs
  - Custom linker script and startup code
  - Makefile for building and running programs
  - Compiled binaries, and input/output vectors used for simulation and benchmarking
- **archive/** – Legacy or deprecated files retained for reference
- **README.md** – Repository overview (this file)

Start with:

1. [docs/workspace_overview.md](/home/wozniak/projects/riscv_pipelined/docs/workspace_overview.md)
2. [docs/getting_started.md](/home/wozniak/projects/riscv_pipelined/docs/getting_started.md)
3. [tb/README.md](/home/wozniak/projects/riscv_pipelined/tb/README.md)
4. [test_inputs/compiled_programs/README.md](/home/wozniak/projects/riscv_pipelined/test_inputs/compiled_programs/README.md)

---

## Goals
- Build a modular, readable RISC-V processor with emphasis on correctness and clarity
- Develop a strong verification infrastructure supporting benchmarking and analysis
- Gradually expand toward realistic architectural features such as caching, CSRs, and I/O peripherals

---

*This repository is an ongoing development effort intended to showcase digital design methodology, and continuous architectural improvement.*
