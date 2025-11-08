# Project Roadmap

This roadmap outlines the current direction and development priorities for the RISC-V processor project.
It emphasizes focus and sequence — completing one area of work before progressing to the next.

---

## Current Stage: Consolidation and Alignment

The processor has exited the refactor phase and now includes greater functionality than before, including a working benchmark flow for Dhrystone and a unified verification framework.
The design is stable, synthesizable, and ready for structured enhancement.

The focus of this stage is to ensure **consistency, observability, and correctness** across the project before pursuing new architectural features.

---

## Active Areas of Work

Current areas of active development are limited and sequential.
Each area will be completed before new work begins.

### 1. Documentation Consistency
- Standardize terminology and formatting across all specification and block documents.
- Verify that control signals, CSR references, and architectural descriptions are consistent across specs, spreadsheets, and RTL.
- Finalize the structure of `docs/` as the permanent foundation for future documentation.

### 2. Performance Monitoring and Instrumentation
- Collect detailed cycle and instruction information through the top level testbench
- Begin collecting key performance metrics in reports/logs
  - Total cycles
  - Instructions retired
  - Instruction mix
    - ALU ops count
    - Loads count
    - Stores count
    - Branches/jumps count
  - IPC and CPI
  - Load stalls
  - Branch misprediction penalty cycles
  - Branches executed
  - Branch mispredicts
  - Branch misprediction rate
  - I-cache misses
    - I-cache miss penalty cycles
- Automate result extraction and reporting

---

## Next Focus Area

### Sixth Pipeline stage and RV32M support
After documentation and performance monitoring are further developed, architectural work will shift toward adding a sixth pipeline stage and implementing the RV32M extension (hardware multiply/divide).

This stage deepens the pipeline to separate ALU operations from longer-latency arithmetic, enabling higher fmax and improving execution throughput on real workloads that depend on multiplication or division. Introducing this pipeline depth before adding the data cache reduces overall complexity:

The pipeline structure becomes stable before memory-system integration.

Hazard logic and forwarding paths only need to be updated once.

Multi-cycle operations are cleaner to schedule in a deeper pipeline.

This expansion prepares the processor for more advanced microarchitectural work and avoids rework that would result from adding RV32M or deepening the pipeline after data-cache integration.

---

## Future Direction

After the completion of performance monitoring work, development will shift toward the next major expansion phase.
Two parallel directions are planned — one focused on architectural growth, and the other on integration and practical usability.
The order in which these are pursued is intentionally undecided.

### Architectural Expansion
This path focuses on deepening the processor’s microarchitecture and instruction set support:
- Introduce a **sixth pipeline stage** to improve timing and accommodate more complex operations.
- Implement the **RV32M extension**, adding hardware multiplication and division instructions that motivate the deeper pipeline structure.
- Add a **data cache** and define the unified memory interface between instruction and data caches.

These changes represent the next stage of architectural maturity, bringing the design closer to a complete and efficient RISC-V core.

### Integration and Practical Enhancements
This path focuses on improving system-level functionality and real-world usability:
- Add **UART support** for program output, debugging, and FPGA interaction.
- Integrate essential I/O peripherals and control registers required for on-board execution.
- Expand benchmarking capabilities to include programs utilizing these hardware interfaces.

These enhancements will move the design from a simulation-only environment toward an interactive, FPGA-deployable system.

---

The specific order of development between these two paths will be determined organically.
Both represent core components of the processor’s continued evolution toward a complete, usable, and measurable hardware system.

---

## Continuous Infrastructure Development

Alongside architectural and integration work, ongoing improvement of the project’s supporting infrastructure will continue.
This includes all software, documentation, and tooling surrounding the hardware design that enable efficient development and clear communication.

### Focus Areas
- **Software Toolchain:** Improve the compilation and linking flow for C and assembly programs, ensuring consistent and reproducible builds.
- **Test Infrastructure:** Extend the Python-based test driver for more flexible test configuration, improved result reporting, and easier integration of new benchmarks.
- **Documentation and Visualization:** Continue refining existing documentation for clarity and consistency, and expand the use of diagrams to illustrate architecture, data flow, and module relationships.
- **Project Organization:** Maintain a clean, scalable repository structure with clear separation between specifications, RTL, verification, and supporting materials.

Infrastructure development will remain an ongoing effort throughout all stages of the project, ensuring that each new feature or subsystem is supported by reliable tooling and clear documentation.

---

## Guiding Principles

- Maintain a narrow focus — complete one defined area before expanding scope.
- Keep documentation and implementation synchronized.
- Use measurement and verification to drive future design choices.
- Prioritize correctness, consistency, and understanding over speed of development.

---

## Complted Milestones:

### CSR implementation (Nov. 6th)
- Implemented baseline CSR registrs (mcycle, minstret, mstatus, etc.).
- Added CSR instruction decoding (CSRRW, CSRRS, CSRRC, and immediate variants).
- Integrated CSR read/write paths into the pipeline and forwarding logic.
- Verified correctness with directed assembly tests.
