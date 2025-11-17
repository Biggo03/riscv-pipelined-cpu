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

module pipeline_monitor (
    input logic clk_i,
    input logic reset_i
);

initial begin
    int reg_dump_handle;
    fd = $fopen({`DUMP_PATH, "/register_dump.yml"}, "w");
    if (fd == 0) begin
        $fatal("ERROR: Could not open dump_output.txt");
    end
end

always_ff @(negedge clk_i) begin
    if (~reset_i) begin
        $fdisplay(reg_dump_handle, "cycle: %d", riscv_top_tb.cycle_monitor.cycle_cnt);
        dump_de(reg_dump_handle);
        dump_ex(reg_dump_handle);
        dump_mem(reg_dump_handle);
        dump_wb(reg_dump_handle);
    end
end

endmodule;
