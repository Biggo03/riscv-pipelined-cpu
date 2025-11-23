#!/usr/bin/env python3

import argparse
import logging
import itertools
import yaml
import os
import re

###################################################
#                General Functions                #
###################################################
def parse_range(s):
    try:
        start, end = tuple(map(int, s.split(',')))
        return [start, end]
    except ValueError:
        raise argparse.ArgumentTypeError("Range must be in the format start,end (e.g. 0,100)")

def parse_args():
    parser = argparse.ArgumentParser(
        description="Process the raw output from a system level simulation"
    )

    parser.add_argument(
        "dump_path",
        type=str,
        help="path to the file containing the raw pipeline dump information"
    )

    parser.add_argument(
        "--macro_file", "-m",
        type=str,
        default=argparse.SUPPRESS,
        help="path to the file containing macros to map signal values to (default: ../../common/include/control_macros.sv)"
    )

    parser.add_argument(
        "-p", "--pipeline_stages",
        nargs="+",
        default=["de", "ex", "mem", "wb"],
        help="list of pipeline stages to include in the processed results (defaults to all stages)"
    )

    parser.add_argument(
        "-c", "--cycle_range",
        type=parse_range,
        default=tuple([1, 999999999]),
        help="range of cycles to include in processed results (defaults to 1,-999999999). Input in format low_cycle,high_cycle."
    )

    parser.add_argument(
        "-s", "--signal_categories",
        nargs="+",
        default=["meta", "control", "data"],
        help="what signal categories to include in processed results (defaults to all signal categories)"
    )

    parser.add_argument(
        "-o", "--output_dir",
        type=str,
        default=argparse.SUPPRESS,
        help="Directory to write processed outputs (defaults to directory the dump file is located in)"
    )

    return parser.parse_args()

def setup_logger(log_name, level=logging.INFO):
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

    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(logging.Formatter(
        "[%(levelname)s] %(message)s"
    ))

    logger.addHandler(console_handler)

    return logger

def load_yaml(yaml_path):

    try:
        with open(yaml_path, "r") as f:
            yaml_data = yaml.safe_load(f)
    except:
        print(f"could not open yaml fie {'yaml_path'}")
        yaml_data = {}

    return yaml_data

###################################################
#                  Sub-Functions                  #
###################################################
def parse_macros(macro_file_path):

    macro_map = {}

    with open(macro_file_path, "r") as f:
        active_signal = ""
        for line in f:
            signal_re = re.search(r'//\s+(\w+)\s+//', line)
            if (signal_re):
                active_signal = signal_re.group(1)
                macro_map[active_signal] = {}

            macro_re = re.search(rf"`define (\w+)\s+[0-9]+'(\w+)$", line)
            if (macro_re):
                    macro_name = macro_re.group(1)
                    # match with dumping format
                    macro_value = macro_re.group(2).replace("b", "0b").replace("h", "0x")
                    macro_map[active_signal][macro_value] = macro_name

    return macro_map

def insert_macro(signal_val, signal_macro_mapping):

    # if macro mapping is found, return macro name
    for macro_val, macro_name in signal_macro_mapping.items():
        if (signal_val == macro_val):
            return macro_name

    # if no mapping found, return original value
    return signal_val

###################################################
#                   Main Functions                #
###################################################
def parse_raw_dump(dump_path, output_dir, macro_map, pipeline_stages, cycle_range, signal_categories, logger):

    dump_data = load_yaml(dump_path)

    low_cycle = cycle_range[0]
    # cap cycle range
    if (len(dump_data) < cycle_range[1]):
        high_cycle = len(dump_data)
    else:
        high_cycle = cycle_range[1]

    logger.info(f"cycle_range: {low_cycle}:{high_cycle}")
    logger.info(f"stages: {pipeline_stages}")
    logger.info(f"signal categories: {signal_categories}")

    parsed_data = {}
    for cycle, stage, signal_category in itertools.product(range(low_cycle, high_cycle+1), pipeline_stages, signal_categories):
        try:
            parsed_data.setdefault(cycle, {}).setdefault(stage, {}).setdefault(signal_category, {})

            for signal_name, signal_val in dump_data[cycle][stage][signal_category].items():
                signal_macro_mapping = macro_map.get(signal_name, {})

                parsed_data[cycle][stage][signal_category][signal_name] = insert_macro(signal_val, signal_macro_mapping)
        except:
            logger.warning(f"could not parse data for cycle: {cycle}, stage {stage}, category: {signal_category}")

    # special handelling for hazarf unit data (not same format)
    for cycle in range(low_cycle, high_cycle+1):
        try:
            for hazard_category in dump_data[cycle]["hazard_unit"].keys():
                for signal_name, signal_val in dump_data[cycle]["hazard_unit"][hazard_category].items():
                    parsed_data.setdefault(cycle, {}).setdefault("hazard_unit", {}).setdefault(hazard_category, {})

                    if (hazard_category == "forward"):
                        signal_macro_mapping = macro_map.get("forward", {})
                    else:
                        signal_macro_mapping = macro_map.get(signal_name, {})

                    parsed_data[cycle]["hazard_unit"][hazard_category][signal_name] = insert_macro(signal_val, signal_macro_mapping)
        except:
            logger.warning(f"could not parse hazard data for cycle: {cycle}")


    with open(f"{output_dir}/processed_pipeline_dump.yml", "w") as f:
        yaml.safe_dump(parsed_data, f, sort_keys=False)

    return

def main():
    args = parse_args()
    logger = setup_logger("post_process_logger")

    script_dir = os.path.dirname(os.path.abspath(__file__))
    if (not hasattr(args, "macro_file")):
        macro_file = os.path.abspath(f"{script_dir}/../../common/includes/control_macros.sv")
    else:
        macro_file = args.macro_file

    if (not hasattr(args, "output_dir")):
        output_dir = os.path.dirname(args.dump_path)
    else:
        output_dir = args.output_dir

    macro_map = parse_macros(macro_file)

    parse_raw_dump(args.dump_path, output_dir, macro_map, args.pipeline_stages, args.cycle_range, args.signal_categories, logger)

    return

if __name__ == "__main__":
    main()
