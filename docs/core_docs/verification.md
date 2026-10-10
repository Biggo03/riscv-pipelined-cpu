# Verification

The project uses module-level testbenches and full-system program tests, driven through a common Python regression flow.

## Test Structure

### Module Tests

Module testbenches are located in `tb/module_tests/`.

They provide focused verification of individual RTL blocks such as:

- ALU and decoders
- register file and immediate generation
- hazard logic
- branch-prediction blocks
- CSR logic
- cache and memory blocks

### System Tests

Full-system tests use [`tb/system_test/riscv_top_tb.sv`](../../tb/system_test/riscv_top_tb.sv).

These tests execute assembly or bare-metal C programs on the complete processor and verify:

- instruction execution
- pipeline and hazard behavior
- branching
- memory access
- CSR behavior
- software startup and linking
- end-to-end program completion

## Test Driver

Tests are executed through [`scripts/test_driving/test_driver.py`](../../scripts/test_driving/test_driver.py).

Available tests and regressions are defined in [`test_catalog.yml`](../../scripts/test_driving/test_catalog.yml).

Common regressions include:

- `component_smoke`
- `system_smoke`
- `c_smoke`

Example:

```bash
cd scripts/test_driving

./test_driver.py -l
./test_driver.py -r component_smoke
./test_driver.py -r system_smoke
./test_driver.py -r c_smoke
```

Each test produces its outputs under:

```text
sim_results/<test_name>/
```

## Program Tests

Assembly and C programs are built under `test_inputs/compiled_programs/`.

System tests use:

```text
<test_name>.text.hex
<test_name>.data.hex
```

The test driver locates these files and passes them into simulation through compile-time macros.

See the [program build flow](../../test_inputs/compiled_programs/README.md) for software build details.

## Pass/Fail

Module tests handle pass/fail through their local assertions and checking logic.

System programs signal completion through the `mtest_status` CSR:

- `0xABCD1234` – pass
- `0xDEADBEEF` – fail

The system testbench monitors writes to this CSR and terminates the simulation when either value is observed.

A cycle timeout is also used to terminate tests that fail to complete.

## Debug and Performance Output

Verification runs can produce:

- simulation logs
- VCD waveforms
- performance summaries
- optional pipeline dumps

System tests include performance monitoring for:

- cycles and retired instructions
- instruction mix
- IPC and CPI
- load stalls
- branch mispredictions and penalty cycles
- instruction-cache misses and penalty cycles

Detailed per-cycle pipeline and performance logging can be enabled with the compile-time macros documented in [`docs/macro_overview.md`](../macro_overview.md).
