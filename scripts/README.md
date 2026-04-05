# Scripts

This directory contains automation and support scripts used by the project.

Not every script here is part of the normal day-to-day flow. Some are core workflow tools, while others are debugging or maintenance helpers.

## Main Script Families

### `test_driving/`

This is the most important script subtree in normal development.

It contains:

- `test_driver.py`: main regression runner
- `test_catalog.yml`: test inventory and regression definitions
- `README.md`: usage overview

Use this subtree when you want to:

- list available tests
- run unit regressions
- run full-system assembly tests
- run full-system C-program tests

### `pipeline_dumping/`

This subtree supports pipeline-state dump generation and post-processing.

Use it when you want more observability during debug, especially for full-system runs. It is useful, but it is not the primary entry point for normal regressions.

### `csr_codegen/`

This subtree generates CSR-related files from the CSR spreadsheet source.

Use it when the CSR definition data changes and the generated RTL, macros, headers, or verification artifacts need to be refreshed.

### `signal_name_updates/`

This subtree contains maintenance utilities for bulk signal-name changes and related migration tasks.

This is not part of the normal regression flow.

### Top-Level Helper

- `test_vector_generator.py`

This is a standalone helper for generating directed vector inputs.

## What Is Part Of The Normal Flow

Most day-to-day work uses:

- `scripts/test_driving/`

Sometimes uses:

- `scripts/pipeline_dumping/`
- `scripts/csr_codegen/`

Usually one-off or maintenance:

- `scripts/signal_name_updates/`
- `scripts/test_vector_generator.py`

## Generated Outputs

Some of these scripts create or update artifacts elsewhere in the repo, including:

- `sim_results/`
- `filelists/`
- generated CSR-related files
- debug dump outputs

Before editing generated outputs directly, check whether they are produced by one of the scripts in this directory.

## Related Docs

- [scripts/test_driving/README.md](/home/wozniak/projects/riscv_pipelined/scripts/test_driving/README.md)
- [scripts/pipeline_dumping/README.md](/home/wozniak/projects/riscv_pipelined/scripts/pipeline_dumping/README.md)
- [scripts/csr_codegen/README.md](/home/wozniak/projects/riscv_pipelined/scripts/csr_codegen/README.md)
- [docs/getting_started.md](/home/wozniak/projects/riscv_pipelined/docs/getting_started.md)
