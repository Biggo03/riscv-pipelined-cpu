# Getting Started

1. Requirements
   - Python 3
   - Python packages from requirements.txt
   - Icarus Verilog >= 13
   - RISC-V GNU toolchain supporting rv32i_zicsr / ilp32
   - make
   - hexdump
   - GTKWave optional
   - Vivado optional for FPGA work

2. Python setup
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt

3. Build test programs
   cd test_inputs/compiled_programs
   make

4. Run regressions
   cd scripts/test_driving
   ./test_driver.py -l
   ./test_driver.py -r component_smoke
   ./test_driver.py -r system_smoke
   ./test_driver.py -r c_smoke

5. Outputs
   sim_results/<test_name>/
