//==============================================================//
//  Module:       pipeline_monitor
//  File:         pipeline_monitor.sv
//  Description:  Top-level pipeline monitoring module. This module
//                aggregates all per-stage dump tasks and writes
//                YAML-formatted snapshots of each pipeline stage
//                to the output path specified by `DUMP_PATH`.
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        This file is auto-generated. Any modifications
//                should be made in the generator scripts or the
//                associated Jinja template.
//==============================================================//
`include "de_dump_tasks.sv"
`include "ex_dump_tasks.sv"
`include "mem_dump_tasks.sv"
`include "wb_dump_tasks.sv"
`include "hazard_dump_tasks.sv"

`ifdef PIPELINE_DUMP
    int reg_dump_handle;

    initial begin
        reg_dump_handle = $fopen({`DUMP_PATH, "/raw_pipeline_dump.yml"}, "w");
        if (reg_dump_handle == 0) begin
            $fatal(1, "ERROR: Could not open raw_pipeline_dump.yml");
        end
    end

    always @(negedge clk) begin
        if (~reset) begin
            $fdisplay(reg_dump_handle, "%0d:", riscv_top_tb.u_performance_monitor.cycle_cnt);
            dump_de(reg_dump_handle);
            dump_ex(reg_dump_handle);
            dump_mem(reg_dump_handle);
            dump_wb(reg_dump_handle);
            dump_hazard_unit(reg_dump_handle);
        end
    end

`endif
