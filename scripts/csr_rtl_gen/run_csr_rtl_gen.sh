#!/bin/bash
set -e  # Exit on error
set -u  # Treat unset variables as errors

# ------------------------------------------------------------
#  Root setup
# ------------------------------------------------------------
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" #Assumes file hasn't been moved from git location

mkdir -p "./outputs"
# ------------------------------------------------------------
#  Input and Output Paths
# ------------------------------------------------------------
SPREADSHEET_PATH="$PROJECT_ROOT/docs/spreadsheets/csr_spec.xlsx"

RTL_OUTPUT_PATH="$PROJECT_ROOT/rtl/csr_regfile.sv"
TB_OUTPUT_PATH="$PROJECT_ROOT/tb/csr_regfile_tb.sv"
MACRO_OUTPUT_PATH="$PROJECT_ROOT/common/includes/csr_macros.sv"
# ------------------------------------------------------------
#  Generate CSR Files
# ------------------------------------------------------------
echo "[INFO] Generating CSR files..."
python3 csr_rtl_generator.py \
    "$SPREADSHEET_PATH" \
    "$RTL_OUTPUT_PATH" \
    "$TB_OUTPUT_PATH" \
    "$MACRO_OUTPUT_PATH"
# ------------------------------------------------------------
#  Copy Outputs to ./outputs
# ------------------------------------------------------------
echo "[INFO] Copying generated files to ./outputs..."
cp "$RTL_OUTPUT_PATH" "./outputs"
cp "$TB_OUTPUT_PATH" "./outputs"
cp "$MACRO_OUTPUT_PATH" "./outputs"
