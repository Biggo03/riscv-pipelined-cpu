`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 09/12/2024 09:34:38 PM
// Design Name:
// Module Name: top_level_TB
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`include "tb_macros.sv"
`include "misc_tasks.sv"

 module riscv_top_tb();

    logic        clk;
    logic        reset;

    logic [31:0] write_data_mem;
    logic [31:0] alu_result_mem;
    logic        mem_write_mem;

    int cycle_cnt;

    riscv_top u_riscv_top (
        // Clock & reset
        .clk_i                          (clk),
        .reset_i                        (reset),

        // Memory outputs
        .write_data_mem_o                 (write_data_mem),
        .alu_result_mem_o                 (alu_result_mem),
        .mem_write_mem_o                  (mem_write_mem)
    );

    cycle_monitor u_cycle_monitor (
        // Clock & reset
        .clk_i          (clk),
        .reset_i        (reset),

        .valid_wb_i      (`DATA_PATH_HIER.valid_wb),
        .stall_wb_i      (`DATA_PATH_HIER.stall_wb_i),
        .instr_wb_i      (`DATA_PATH_HIER.instr_wb)
    );

    initial begin
        dump_setup;

        cycle_cnt = 0;
        clk = 0;
        reset = 1; #20; reset = 0;
    end

    always begin
        clk = ~clk;
        #5;
    end

    always @(negedge clk) begin

        if (u_cycle_monitor.cycle_cnt > 1000000) $finish;

        `ifndef C_PROGRAMS
            if (`DATA_PATH_HIER.csr_we_wb_o && `DATA_PATH_HIER.csr_addr_wb_o == `MTEST_STATUS_ADDR) begin
                if (`DATA_PATH_HIER.csr_result_wb == `TEST_PASS) begin
                    $display("TEST PASSED");
                    $finish;
                end else if (`DATA_PATH_HIER.csr_result_wb == `TEST_FAIL) begin
                    $display("TEST FAILED");
                    $finish;
                end
            end
        `endif

    end

    `include "pipeline_monitor.sv"

endmodule
