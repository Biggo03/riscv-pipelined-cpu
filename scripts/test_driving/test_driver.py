#!/usr/bin/env python3

import argparse
import yaml
import subprocess
import os
import logging
import re
from pathlib import Path
from ordered_set import OrderedSet

def parse_args():
    parser = argparse.ArgumentParser(
        description="Run regressions, test groups, or individual tests."
    )

    parser.add_argument(
        "-r", "--regressions",
        nargs="+",
        default=[],
        help="list of regressions to run"
    )

    parser.add_argument(
        "-t", "--tests",
        nargs="+",
        default=[],
        help="list of tests to run"
    )

    parser.add_argument(
        "-D", "--defines",
        nargs="+",
        default=[],
        help="list of additional defines to apply to test"
    )

    # Optional argument: output directory
    parser.add_argument(
        "-o", "--output_dir",
        type=str,
        default="../../sim_results",
        help="Directory to write test outputs (default: ../../sim_results)"
    )

    parser.add_argument(
        "-l", "--list_tests",
        action="store_true",
        help="Lists all currently supported tests, then exits the program"
    )

    return parser.parse_args()

def setup_logger(log_name, log_file_path, level=logging.INFO):
    """
    Creates and returns a logger with console and file output.

    Args:
        log_name: Unique name for the logger (e.g., "test", "alu_tb").
        log_file_path: Path to the log file to write to.
        level: Logging level (default: logging.INFO)

    Returns:
        A configured logging.Logger object.
    """
    logger = logging.getLogger(log_name)
    logger.setLevel(level)

    # Prevent duplicate handlers if the logger is called multiple times
    if logger.hasHandlers():
        return logger

    # Ensure log directory exists
    Path(log_file_path).parent.mkdir(parents=True, exist_ok=True)

    # File handler
    file_handler = logging.FileHandler(log_file_path, mode='w')
    file_handler.setFormatter(logging.Formatter(
        "%(asctime)s [%(levelname)s] %(message)s"
    ))

    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(logging.Formatter(
        "[%(levelname)s] %(message)s"
    ))

    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    return logger

def load_yaml(yaml_path):
    try:
        with open(yaml_path, "r") as f:
            yaml_data = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: File not found at {yaml_path}")
        yaml_data = None
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}")
        yaml_data = None

    return yaml_data

def list_tests(test_catalog):
    asm_tests = {}
    c_tests = {}
    unit_tests = {}

    for test_name, test_info in test_catalog["tests"].items():
        if ("asm" in test_info["tags"]):
            asm_tests[test_name] = test_info
        elif ("c_program" in test_info["tags"]):
            c_tests[test_name] = test_info
        elif ("unit" in test_info["tags"]):
            unit_tests[test_name] = test_info

    print("="*40)
    print("=UNIT TESTS")
    print("="*40)
    for test in unit_tests.keys():
        print(test)

    print("="*40)
    print("=ASM TESTS")
    print("="*40)
    for test in asm_tests.keys():
        print(test)

    print("="*40)
    print("=C TESTS")
    print("="*40)
    for test in c_tests.keys():
        print(test)

    return

def select_active_tests(regressions, tests, test_catalog):
    """
    Gets all test information related to recieved tests

    Args:
        regressions: List of regressions to run
        tests: List of individual tests to run
        test_catalog: Dict containing test information

    Returns:
        active_test_info: dict containing info for tests that are to be run
    """
    test_logger = logging.getLogger("test_logger")

    tests = OrderedSet(tests)
    active_test_info = {}
    for regression in regressions:
        try:
            for test in test_catalog["regressions"][regression]:
                tests.add(test)
        except:
            test_logger.warning(f"unable to find regression: {regression}")

    for test in tests:
        try:
            active_test_info[test] = test_catalog["tests"][test]
        except Exception as e:
            test_logger.warning(f"Unable to find test: {test} in test list")

    test_logger.info(f"running tests: {', '.join(tests)}")

    return active_test_info

def get_module_paths(rtl_dir, module_path, module_paths=None):
    """
    Parses file for the instantiaion of modules.
    Requires module instance names to start with "u_"

    Args:
        rtl_dir: Location of all RTL files
        module_path: Path to the module currently being parsed
        module_paths: running list of paths to included modules
    """
    if module_paths is None:
        module_paths = []

    module_pattern = re.compile(r"u_[^\s]+\s\(")

    with open(module_path, "r") as f:
        for line in f:
            if (re.search(module_pattern, line)):
                module = line.split()[0]
                sub_module_path = rtl_dir.joinpath(f"{module}.sv")

                if sub_module_path.exists():
                    module_paths.append(sub_module_path.resolve())
                    get_module_paths(rtl_dir, sub_module_path, module_paths)

    #Remove duplicates while preserving order
    module_paths = list(dict.fromkeys(module_paths))

    return module_paths

def gen_run_cmd(test_name, test_info, dir_paths, defines):

    test_logger = logging.getLogger("test_logger")

    defines = list(defines)
    defines.extend(test_info["defines"])

    # -- Included directories ---
    inc_dirs = [
        str(dir_paths["include_dir"]),
        str(dir_paths["tb_include_dir"])
    ]

    # -- Module Libraries ---
    module_libs = [dir_paths["common_tb"]]

    if ("system" in test_info["tags"]):
        module_libs.append(os.path.dirname(dir_paths["tb_path"]))
    # --- Source files ---
    src_files = [dir_paths["tb_path"]]


    # --- Defines ---
    defines.append(f'DUMP_PATH="{dir_paths["test_out_dir"]}/{test_name}.vcd"')
    defines.append(f'SIM')

    # System specific defines
    if ("system" in test_info["tags"]):
        instr_match = next(dir_paths["hex_path"].rglob(f"{test_name}.text.hex"), None)
        data_match = next(dir_paths["hex_path"].rglob(f"{test_name}.data.hex"), None)

        if (instr_match):
            dir_paths["instr_path"] = instr_match.resolve()
            defines.append(f"INSTR_HEX_FILE=\"{dir_paths['instr_path']}\"")
        else:
            test_logger.warning(f"Could not find instruction file for: {test_name}")

        if (data_match):
            data_path = data_match.resolve()
            defines.append(f"DATA_HEX_FILE=\"{data_path}\"")
        elif ("c_program" in test_info["tag"]):
            test_logger.warning(f"Could not find data file for : {test_name}")

    # --- Flags ---
    iverilog_flags = [
        "-g2012",
        "-Wall",
        "-Wextra",
        "-Wimplicit",
        "-Wno-timescale",
        "-Wno-fatal",
        "-Winfloop",
        "-Wportbind",
        "-Wmultidriver",
        "-Wwidth",
        "-Wselect-range",
        "-Wcaseincomplete",
        "-Wno-sensitivity-entire",
        "-Wno-sensitivity-incomplete",
        "-Wno-sensitivity-complete",
        "-pfileline=1",
        "-Ttyp",
        "-DDEBUG_BUILD",
    ]

    # --- File list ---
    module_paths = get_module_paths(dir_paths["rtl_dir"], dir_paths["tb_path"])
    if ("system" in test_info["tags"]):
        filelist = dir_paths["filelist_dir"] / "top.f"
    else:
        filelist = dir_paths["filelist_dir"] / f"{test_name}.f"
    with open (filelist, "w") as f:
        f.write("\n".join(map(str, module_paths)) + "\n")

    # --- Create command ---
    run_cmd = ["iverilog"]
    run_cmd.extend(iverilog_flags)

    for inc_dir in inc_dirs:
        run_cmd.extend(["-I", inc_dir])

    for module_lib in module_libs:
        run_cmd.extend(["-y", module_lib])
        run_cmd.extend(["-Y", ".sv"])

    for define in defines:
        run_cmd.extend(["-D", define])

    run_cmd.extend(["-f", filelist])

    for src in src_files:
        run_cmd.append(src)

    run_cmd.extend(["-o", f"{dir_paths['test_out_dir']}/{test_name}.vvp"])

    # Ensure everything is of proper type
    for i in range(len(run_cmd)):
        run_cmd[i] = str(run_cmd[i])

    return run_cmd

def setup_paths(test_name, tb_file, top_out_dir):

    dir_paths = {}

    dir_paths["proj_dir"]        = Path(__file__).resolve().parent.parent.parent
    dir_paths["rtl_dir"]         = dir_paths["proj_dir"] / "rtl"
    dir_paths["include_dir"]     = dir_paths["proj_dir"] / "common" / "includes"
    dir_paths["filelist_dir"]    = dir_paths["proj_dir"] / "filelists"
    dir_paths["tb_path"]         = dir_paths["proj_dir"] / "tb" / tb_file
    dir_paths["tb_include_dir"]  = dir_paths["proj_dir"].joinpath("tb", "common")
    dir_paths["common_tb"]       = dir_paths["proj_dir"].joinpath("tb", "common")
    dir_paths["hex_path"]        = dir_paths["proj_dir"] / "test_inputs" / "compiled_programs"

    dir_paths["test_out_dir"]    = top_out_dir / test_name

    os.makedirs(dir_paths["test_out_dir"], exist_ok=True)
    os.makedirs(dir_paths["filelist_dir"], exist_ok=True)
    subprocess.run(f"rm -rf {dir_paths['test_out_dir']}/*", shell=True)

    return dir_paths

def run_test(test_name, test_info, defines, top_out_dir, result_info):
    """
    Runs a specific testbench using Icarus Verilog

    Args:
        test_name: Name of the test
        tb_file: Name of the testbench file
        test_out_dir: Where the outputs of the test are placed
    """
    test_logger = logging.getLogger("test_logger")

    if ("system" in test_info["tags"]):
        tb_file = f"system_test/{test_info['tb']}"
    else:
        tb_file = f"module_tests/{test_info['tb']}"

    dir_paths = setup_paths(test_name, tb_file, top_out_dir)
    run_cmd = gen_run_cmd(test_name, test_info, dir_paths, defines)

    # --- Run compilation and simulation ---
    test_passed = False
    warning_present = False
    log_path = Path(dir_paths['test_out_dir']) / f"{test_name}.log"
    with open(log_path, "w") as log_file:
        try:
            log_file.write(f"Compilation command:\n {' '.join(run_cmd)}\n")
            process = subprocess.Popen(run_cmd, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=dir_paths["proj_dir"])
            for line in process.stdout:
                log_file.write(f"{line}\n")
            log_file.write(f"Compilation of {test_name} complete\n")

            process.wait()

            log_file.write(f"Beginning simulation of test: {test_name}...\n")
            process = subprocess.Popen([f"{dir_paths['test_out_dir']}/{test_name}.vvp"], text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=dir_paths["proj_dir"])
            for line in process.stdout:
                log_file.write(f"{line}\n")
                if "TEST PASSED" in line:
                    test_passed = True
                if ("WARNING" in line.upper() and "VCD" not in line.upper()):
                    warning_present = True

            process.wait()
        except:
            test_passed = False

    if (test_passed == True):
        result_info["PASSED_TESTS"][test_name] = dir_paths['test_out_dir']
        test_logger.info(f"{test_name} PASSED")
    else:
        result_info["FAILED_TESTS"][test_name] = dir_paths['test_out_dir']
        test_logger.info(f"{test_name} FAILED")
    if (warning_present == True):
        result_info["WARNING_TESTS"][test_name] = dir_paths['test_out_dir']
        test_logger.info(f"{test_name} CONTAINS WARNINGS")

    return

def run_all_tests(active_test_info, defines, top_out_dir, result_info):

    os.makedirs(top_out_dir, exist_ok=True)

    for test_name, test_info in active_test_info.items():
        run_test(test_name, test_info, defines, top_out_dir, result_info)

def generate_report(result_info, test_logger):
    # Report results
    passed_tests = result_info["PASSED_TESTS"]
    failed_tests = result_info["FAILED_TESTS"]
    warning_tests = result_info["WARNING_TESTS"]

    if (len(passed_tests) != 0):
        test_logger.info("====================PASSED TESTS ====================")
        for test in passed_tests.keys():
            test_logger.info(f"{test}: {passed_tests[test]}")
    else:
        test_logger.info("==================== NO TESTS PASS====================")

    if (len(failed_tests) != 0):
        test_logger.info("====================FAILED TESTS ====================")
        for test in failed_tests.keys():
            test_logger.info(f"{test}: {failed_tests[test]}")
    else:
        test_logger.info("==================== NO TESTS FAILED ====================")

    if (len(warning_tests) != 0):
        test_logger.info("==================== TESTS WITH WARNINGS ====================")
        for test in warning_tests.keys():
            test_logger.info(f"{test}: {warning_tests[test]}")

    test_logger.info(f"==================== SUMMARY ====================")
    test_logger.info(f"Total PASSED tests: {len(passed_tests)}")
    test_logger.info(f"Total FAILED tests: {len(failed_tests)}")

def main():
    args = parse_args()
    test_logger = setup_logger("test_logger", f"{args.output_dir}/test_run.log")
    test_catalog = load_yaml("test_catalog.yml")

    if (args.list_tests):
        list_tests(test_catalog)
        return
    elif (args.regressions == [] and args.tests == []):
        test_logger.error("No regressions or tests provided")
        return

    active_test_info = select_active_tests(args.regressions, args.tests, test_catalog)

    top_out_dir = Path(os.path.abspath(args.output_dir))
    result_info = {"PASSED_TESTS": {}, "FAILED_TESTS": {}, "WARNING_TESTS": {}}

    run_all_tests(active_test_info, args.defines, top_out_dir, result_info)
    generate_report(result_info, test_logger)

if __name__ == "__main__":
    main()
