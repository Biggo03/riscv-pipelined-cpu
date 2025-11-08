# Overview

This flow drives **SystemVerilog tests** for RTL modules and **program tests** for the RISC-V processor using *Icarus Verilog*.
All regression and test information is defined in the [`test_catalog.yml`](test_catalog.yml), and tests are executed through [`test_driver.py`](test_driver.py).

The test driver supports running any combination of regressions and tests, accepts command-line defines, and produces organized output directories for each run.

---

# Usage

Basic command-line help is available with:

**./test_driver.py -h**

A typical command using all major options is:

**./test_driver.py -r [regressions] -t [tests] -D [defines] -o [output_dir]**

- `-r` specifies one or more regressions to run.
- `-t` adds individual tests (optional, can be used alone or with `-r`).
- `-D` passes compile-time defines to Icarus Verilog.
- `-o` sets the output directory for test results.

The driver will execute all tests included in the selected regressions, along with any explicitly listed tests, applying all defines provided on the command line.

---

# Test Catalog

The test catalog (`test_catalog.yml`) defines all available regressions and tests.
It contains two main sections:

### regressions
Lists named regressions, each containing a group of tests to be executed together.

### tests
Defines individual tests, each specifying:
- **tb** – Testbench file used.
- **defines** – Defines always applied for this test.
- **tags** – Metadata used by the test driver.

**Note:** The most important tag is **`system`**, which indicates that the test uses a full program image.
For such tests, input files are located under `test_inputs`.
