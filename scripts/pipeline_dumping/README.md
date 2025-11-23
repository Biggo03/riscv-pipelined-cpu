# Pipeline Dump Tools

Tools for generating pipeline dump logic and post-processing dump output during debugging.

---

## 1. Dump Generation

**Script:** `gen_pipeline_dump.py`
Generates the pipeline monitor and per-stage dump tasks from the templates in `templates/`, using `stage_metadata.yml`.

### Usage
python gen_pipeline_dump.py [-h] [--rtl_dir RTL_DIR] [-o OUTPUT_DIR]

**Arguments:**

- `--rtl_dir, -r`
  Path to RTL directory (default: `../../rtl`)
- `--output_dir, -o`
  Directory to write generated files (default: `../../tb/system_test`)

Enable dumping in simulation via your testbench flag (e.g., `PIPELINE_DUMP`).

---

## 2. Dump Post-Processing

**Script:** `post_process_dump.py`
Processes the raw pipeline dump YAML and outputs a filtered, human-readable version with macro names mapped from values.

### Usage
python post_process_dump.py [-h] [--macro_file MACRO_FILE] [-p PIPELINE_STAGES ...] [-c CYCLE_RANGE] [-s SIGNAL_CATEGORIES ...] [-o OUTPUT_DIR] dump_path

**Positional:**

- `dump_path`
  Path to the raw pipeline dump file.

**Options:**

- `--macro_file, -m`
  Macro file for mapping values (default: `../../common/include/control_macros.sv`)
- `--pipeline_stages, -p`
  Pipeline stages to include (default: all)
- `--cycle_range, -c`
  Cycle range (`low,high`) (default: all)
- `--signal_categories, -s`
  Signal categories to include (default: all)
- `--output_dir, -o`
  Output directory (default: same directory as `dump_path`)

---

## 3. Notes

- These tools are **standalone** and used **only during debugging**.
- They are not part of the normal regression flow.
