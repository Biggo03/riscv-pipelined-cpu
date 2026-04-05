# Documentation

This directory contains the active project documentation that is useful at the current stage of development.

The documentation set is intentionally biased toward:

- repository navigation
- current workflows
- verification flow
- program-build flow
- planning and development history

It is not currently a complete architecture-specification set. When the processor design settles again, more detailed design documentation can be rebuilt around the updated RTL.

## What To Read First

- [workspace_overview.md](/home/wozniak/projects/riscv_pipelined/docs/workspace_overview.md): where everything lives and what to read first
- [getting_started.md](/home/wozniak/projects/riscv_pipelined/docs/getting_started.md): first commands, common flows, and output locations
- [core_docs/verification.md](/home/wozniak/projects/riscv_pipelined/docs/core_docs/verification.md): current verification structure and test flow
- [macro_overview.md](/home/wozniak/projects/riscv_pipelined/docs/macro_overview.md): important build and simulation macros

## Directory Contents

### `core_docs/`

Contains the small set of active high-level documents that still map cleanly to the current codebase.

At the moment this is primarily:

- verification workflow
- supported-instruction reference

### `spreadsheets/`

Reference spreadsheets used by tooling and implementation work, including:

- instruction decode data
- CSR definitions
- control signal reference data

### `devlogs/`

Chronological implementation notes and design history. These are useful for understanding why parts of the repo look the way they do, but they are not a substitute for current workflow documentation.

### `roadmap.md`

Current development direction and active priorities.

### `TODO.md`

Shorter working task list.

### `style_guide.md`

Project writing and naming conventions.

## Documentation Policy

For this stage of the processor, a smaller and more accurate documentation set is more useful than a larger speculative one.

In practice that means:

- workflow docs should stay current
- repo-navigation docs should stay current
- placeholder design docs should not stay in the active documentation tree
- the RTL and testbench remain the source of truth for detailed behavior
