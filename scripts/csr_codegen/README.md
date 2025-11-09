# Overview

This flow automates the generation of **Control and Status Register (CSR)** files from a single spreadsheet source of truth.
It converts the specification in [`csr_spec.xlsx`](spreadsheets/csr_spec.xlsx) into all required RTL, testbench, and macro files, ensuring consistency between documentation, implementation, and verification.

The flow is driven by [`csr_codegen.py`](csr_codegen.py), which parses the spreadsheet and produces structured outputs used throughout the project.

---

# Usage

Basic command-line help is available with:

**./csr_codegen.py -h**

A typical command using all major options is:

**./csr_codegen.py <spreadsheet_path> <rtl_output_dir> <tb_output_dir> <macro_output_dir> <cdef_output_dir>**

- `<spreadsheet_path>` specifies the input Excel file defining all CSRs.
- `<rtl_output_dir>` is the directory where generated RTL files are placed.
- `<tb_output_dir>` is the directory where the generated testbench files are written.
- `<macro_output_dir>` is the directory for generated macro definitions.
- `<cdef_output_dir>` is the directory where the generated C header file containing CSR address definitions is written.

The generated files are automatically copied to the project’s `outputs/` directory for integration with the rest of the design and test infrastructure.

---

# CSR Specification

The CSR specification spreadsheet (`csr_spec.xlsx`) defines all CSR-related information, including:
- **Name** – The CSR name as used in RTL and software.
- **Address** – The CSR address within the system.
- **Privilege** - The CSR system privelge
- **Access** – Read-only, write-only, or read/write permissions.
- **Reset Value** – Default value upon reset.
- **Behavior** - Whether the CSR has special behavior associated with it
- **Description** – Functional purpose or usage notes.

This structure allows the Python generation flow to maintain a consistent CSR map across all layers of the project.

---

# Output Artifacts

The CSR generation flow produces:
- **RTL Modules** – Auto-generated CSR register file and associated logic.
- **Testbench Templates** – Used to verify correctness of generated CSRs.
- **Macro Definitions** – Verilog macros for CSR addresses and field offsets.
- **C Header File** – Defines CSR register addresses and names for use in C-based software tests and firmware.

These outputs ensure that all CSR-related files remain synchronized, reducing manual effort and preventing mismatches between documentation and hardware implementation.

---

# Shell Script Wrapper

For convenience, the flow includes a shell script (`run_csr_gen.sh`) that automates path setup and file generation for workspaces following the standard Git repository layout.
This script ensures consistent behavior and file placement without requiring manual argument entry.

To run the flow using the default project structure:

**./run_csr_gen.sh**

### Script Behavior

1. Determines the project root relative to its Git-tracked location.
2. Defines all input and output paths automatically:
    - Spreadsheet: `docs/spreadsheets/csr_spec.xlsx`
    - RTL Output: `rtl/csr_regfile.sv`
    - Testbench Output: `tb/csr_regfile_tb.sv`
    - Macro Output: `common/includes/csr_macros.sv`
    - C Define Output: `common/includes/csr_defs.h`
3. Executes `csr_codegen.py` with these paths.
4. Copies all generated files into the local `./outputs/` directory for easy access.

This ensures the CSR generation flow can be reproduced in one command, maintaining a consistent and automated design process across environments.
