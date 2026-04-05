# RTL Style Guide

This repository already has a recognizable RTL style. When editing files under `rtl/`, follow the conventions below unless you are intentionally preserving a local legacy pattern in an older file.

## Scope

- This guidance is primarily for `rtl/*.sv`.
- A few older modules still use legacy naming or older Verilog constructs. Do not do broad cleanup renames unless the task explicitly asks for it.
- For new RTL, prefer the dominant modern style documented here.

## File Header Template

Use this header format at the top of RTL files:

```systemverilog
`timescale 1ns / 1ps
//==============================================================//
//  Module:       module_name
//  File:         module_name.sv
//  Description:  Short description of the module
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   WIDTH  - data width
//
//  Notes:        N/A
//==============================================================//
```

Guidance:

- `\`timescale 1ns / 1ps` goes first.
- The banner comment comes immediately after the timescale line.
- `\`include` lines go after the header and before the `module` declaration.
- Keep `Parameters` and `Notes` concise and factual.

## File Layout

Preferred file order:

1. `\`timescale`
2. Header banner
3. `\`include` macros, if needed
4. `module` declaration, with parameter block if applicable
5. Port list grouped by function with section comments
6. Internal declarations grouped by purpose
7. Combinational and sequential logic
8. Submodule instantiations
9. `endmodule`

Common section comment style:

```systemverilog
    // Clock & reset_i
    // Control inputs
    // Data inputs
    // Data outputs
    // ----- Intermediate signals -----
```

## Port And Signal Types

Preferred types:

- Use `logic` for ports and internal signals.
- Use `logic` arrays for memories unless a specific legacy module already uses `reg` for inferred RAM behavior.
- Use `typedef enum logic [...]` for FSM state types.
- Use `typedef struct packed` bundles for stage pipeline registers when packing many related fields.
- Use `localparam` for derived widths and internal constants.

Examples already used in the repo:

- `parameter int WIDTH = 32`
- `localparam REG_WIDTH = $bits(ex_bundle_t);`
- `typedef enum logic [1:0] { ... } state_t;`

Construct preference:

- Prefer `always_comb` for combinational logic.
- Prefer `always_ff @(posedge clk_i)` for sequential logic.
- Some legacy files still use `always @(*)` and `always @(posedge clk_i)`; keep those stable unless you are already making a focused cleanup.

## Naming Conventions

### General

- Use `lower_snake_case` for modules, signals, typedef names, and instances.
- Module filenames should match the module name: `module_name.sv`.
- Parameter names are typically uppercase: `WIDTH`, `S`, `E`, `B`.

### Port suffixes

- Inputs end in `_i`.
- Outputs end in `_o`.
- Internal stage-local signals usually omit direction suffixes.

Examples:

- `clk_i`, `reset_i`
- `alu_control_i`, `result_wb_o`
- `pc_fi`, `imm_ext_ex`, `csr_result_mem`

### Stage suffixes

Use these stage abbreviations consistently:

- `fi` = fetch
- `de` = decode
- `ex` = execute
- `mem` = memory
- `wb` = writeback

The stage token goes before the direction suffix:

- `instr_fi_i`
- `branch_op_ex_i`
- `result_src_mem_o`
- `reg_write_wb_o`

For internal non-port signals, keep the same stage token without `_i/_o`:

- `pc_plus4_fi`
- `instr_de`
- `alu_result_ex`
- `result_wb`

### Clock and reset

- Prefer `clk_i` and `reset_i`.
- Reset is generally active-high.
- In the dominant style, reset behavior is synchronous when implemented inside `always_ff @(posedge clk_i)`.

### Exceptions

Some older leaf modules still use short legacy names such as `A`, `B`, `WE`, `RD`, `Q`, `D`, `en`, or `op`. Do not rename public ports in those modules unless the task requires an interface update.

## Module Instantiation Style

Preferred style:

- Use named port connections, not positional connections.
- Use instance names prefixed with `u_`.
- When the module is instantiated once, prefer `u_<module_name>`.
- When multiple instances exist, use a descriptive suffix or generate-label context.
- Put parameter overrides above the instance.
- Group connections with the same interface comments used in the callee module.

Example:

```systemverilog
    my_module #(
        .WIDTH                          (32)
    ) u_my_module (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Control inputs
        .enable_i                       (enable),

        // Data outputs
        .result_o                       (result)
    );
```

Generate style:

- Use `genvar`.
- Label generated blocks with `begin : g_<name>`.

Example:

```systemverilog
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : g_regs
            ...
        end
    endgenerate
```

## Formatting

- Use 4-space indentation.
- Align declarations and port connections when practical, especially in module interfaces and instantiations.
- Keep one signal per line in port lists and named instantiations.
- Leave a blank line between major interface groups and logic sections.
- Keep inline comments short and technical.

## Behavioral Coding Style

- Prefer explicit default assignments in combinational blocks.
- Use `case`, `casez`, and enums for decode/FSM logic.
- Use `assign` for simple continuous wiring.
- Group related control/data fields when building pipeline bundles.
- When unpacking packed stage bundles, keep the pack and unpack ordering identical and comment each group.

## Macros And Includes

- Include macro files only when needed.
- Place includes after the header and before the `module` declaration.
- Common include files in this repo:
  - `control_macros.sv`
  - `instr_macros.sv`
  - `csr_macros.sv`

## Attributes And Special Cases

- Use synthesis attributes inline on declarations when required, for example:
  - `(* ram_style = "block" *)`
  - `(* ram_style = "distributed" *)`
  - `(* keep = "true" *)`
- Keep these attributes attached directly to the affected signal declaration or port.

## Legacy Hotspots

These files show older or less consistent style and should be treated carefully:

- `rtl/instr_mem.sv`
- `rtl/local_predictor.sv`
- `rtl/data_mem.sv`
- `rtl/write_decoder.sv`
- `rtl/flop.sv`

When editing them:

- Preserve public interfaces unless the task requires a coordinated rename.
- Prefer localized cleanup over style-only churn.
- If adding new logic, follow the dominant repo style around the new code.
