# RISC-V Processor Project

A from-scratch RV32I + Zicsr processor implemented in SystemVerilog, developed to explore computer architecture, pipelining, caching, verification, and performance analysis through hands-on design.

## Overview

The processor currently includes:

- Five-stage pipelined execution
- Hazard detection and forwarding
- Two-level branch prediction
- L1 instruction cache
- RV32I instruction support with Zicsr
- Bare-metal C and assembly program support
- Cycle-accurate performance monitoring
- Python-based regression and test automation
- FPGA-oriented, synthesizable RTL

The RTL and testbench are the source of truth for detailed implementation behavior. Documentation is intentionally kept focused on workflows, interfaces, and non-obvious project conventions.

## Repository Structure

- **rtl/** – Synthesizable SystemVerilog processor RTL
- **tb/** – Module and full-system verification
- **common/** – Shared RTL and testbench include files
- **scripts/** – Regression, code-generation, and debug tooling
- **test_inputs/** – Assembly/C test programs and software build flow
- **docs/** – Active project documentation and roadmap
- **archive/** – Legacy files retained for reference

## Getting Started

See [docs/getting_started.md](docs/getting_started.md) for environment setup, program builds, and common regression commands.

Useful references:

- [RTL module map](rtl/README.md)
- [Verification flow](docs/core_docs/verification.md)
- [Supported instructions](docs/core_docs/supported_instructions.md)
- [Program build flow](test_inputs/compiled_programs/README.md)
- [Compile-time macros](docs/macro_overview.md)
- [Project roadmap](docs/roadmap.md)
