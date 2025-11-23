#!/usr/bin/env python3

import argparse
import yaml
import os
from jinja2 import Environment, FileSystemLoader
import re

###################################################
#                General Functions                #
###################################################
def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate dumping tasks, and a pipeline monitor file"
    )

    parser.add_argument(
        "--rtl_dir", "-r",
        type=str,
        default=argparse.SUPPRESS,
        help="Path to rtl directory (defaults to: ../../rtl)"
    )

    parser.add_argument(
        "-o", "--output_dir",
        type=str,
        default=argparse.SUPPRESS,
        help="Directory to write test outputs (default: ../../tb/system_test)"
    )

    return parser.parse_args()

def load_yaml(yaml_path):
    try:
        with open(yaml_path, "r") as f:
            yaml_data = yaml.safe_load(f)
    except:
        print(f"could not open yaml fie {'yaml_path'}")
        yaml_data = {}

    return yaml_data

###################################################
#               Pipeline Stage Parsing            #
###################################################
def parse_stage_structs(module_path, stage_name):
    """
    Extracts field names from the pipeline register structs (meta, data, control)
    for the given pipeline stage.
    """
    struct_fields = {}
    fields = []
    parsing_struct = False

    with open(module_path, "r") as f:
        for line in f:
            start_match = re.search(r'typedef struct packed', line)
            end_match = re.search(rf'}}[\s]+{stage_name}_(meta|data|control|bundle)_t;', line)

            # Continue and detect start of new struct
            if (not parsing_struct):
                if (start_match):
                    parsing_struct = True
                    fields = []
                continue

            # if reaches here, parsing struct.
            if (end_match):
                parsing_struct = False

                category = end_match.group(1)

                if (category != "bundle"):
                    struct_fields[category] = fields
            else:
                line = line.strip().strip(";").split()
                if (line):
                    fields.append(line[-1])

    return struct_fields

def parse_all_stages(rtl_dir, stage_metadata):
    for stage in stage_metadata.keys():
        module_path = f"{rtl_dir}/{stage_metadata[stage].get('module', '')}"

        struct_fields = parse_stage_structs(module_path, stage)

        stage_metadata[stage]["struct_fields"] = struct_fields

    return stage_metadata

###################################################
#               Hazard Unit Parsing               #
###################################################
def parse_hazard_unit(hazard_unit_path):

    hazard_unit_info = {}
    valid_sections = ["stall", "flush", "forward"]

    for section in valid_sections:
        hazard_unit_info[section] = []

    section = ""

    with open(hazard_unit_path, "r") as f:
        for line in f:
            if ("Stall outputs" in line):
                section = "stall"
                continue
            elif ("Flush outputs" in line):
                section = "flush"
                continue
            elif ("Forwarding outputs" in line):
                section = "forward"
                continue

            if (section in valid_sections and "output" in line):
                line = line.strip().replace(",", "").split()
                hazard_unit_info[section].append(line[-1])
            elif (section == "forward" and ");" in line):
                break

    return hazard_unit_info

###################################################
#               Output Generation                 #
###################################################
def gen_stage_dump_tasks(output_dir, stage_metadata, indent_levels):

    env = Environment(loader=FileSystemLoader("templates"))
    stage_dump_template = env.get_template("stage_dump_template.sv.j2")

    for stage_name, stage_info in stage_metadata.items():
        stage_dump_task_output = stage_dump_template.render(stage_name=stage_name,
                                                            hierarchy=stage_info["hierarchy"],
                                                            struct_fields=stage_info["struct_fields"],
                                                            indent_levels=indent_levels)

        with open(f"{output_dir}/{stage_name}_dump_tasks.sv", "w") as f:
            f.write(stage_dump_task_output)

    return

def gen_pipeline_monitor(output_dir, stage_metadata):
    env = Environment(loader=FileSystemLoader("templates"))
    pipeline_monitor_template = env.get_template("pipeline_monitor_template.sv.j2")

    monitor_output = pipeline_monitor_template.render(stages=stage_metadata.keys())

    with open(f"{output_dir}/pipeline_monitor.sv", "w") as f:
        f.write(monitor_output)

def gen_hazard_unit_dump_task(output_dir, hazard_unit_info, indent_levels):
    env = Environment(loader=FileSystemLoader("templates"))
    hazard_dump_template = env.get_template("hazard_dump_template.sv.j2")

    hazard_dump_output = hazard_dump_template.render(hazard_info=hazard_unit_info,
                                                     indent_levels=indent_levels)

    with open(f"{output_dir}/hazard_dump_tasks.sv", "w") as f:
        f.write(hazard_dump_output)

    return

def main():

    # Parse args
    args = parse_args()

    script_dir = os.path.dirname(os.path.abspath(__file__))
    if (not hasattr(args, "rtl_dir")):
        rtl_dir = os.path.abspath(f"{script_dir}/../../rtl/")
    else:
        rtl_dir = args.rtl_dir

    if (not hasattr(args, "output_dir")):
        output_dir = os.path.abspath(f"{script_dir}/../../tb/system_test")
    else:
        output_dir = args.output_dir

    # Make output dir
    os.makedirs(f"{output_dir}/tasks", exist_ok=True)
    os.makedirs(f"{output_dir}/monitors", exist_ok=True)

    # Parse data
    stage_metadata = load_yaml("./stage_metadata.yml")
    stage_metadata = parse_all_stages(rtl_dir, stage_metadata)

    hazard_unit_info = parse_hazard_unit(f"{rtl_dir}/hazard_unit.sv")

    # Generate outputs
    indent_levels = {"stage": "  ",
                     "category": "    ",
                     "signal": "      "}

    gen_stage_dump_tasks(f"{output_dir}/tasks", stage_metadata, indent_levels)
    gen_pipeline_monitor(f"{output_dir}/monitors", stage_metadata)
    gen_hazard_unit_dump_task(f"{output_dir}/tasks", hazard_unit_info, indent_levels)

if __name__ == "__main__":
    main()
