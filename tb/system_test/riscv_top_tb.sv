`timescale 1ns / 1ps
//==============================================================//
//  Module:       riscv_top_tb
//  File:         riscv_top_tb.sv
//  Description:  Top-level SystemVerilog testbench for the
//                pipelined RISC-V processor. Provides clock and
//                reset generation, pass/fail detection, timeout
//                monitoring, pipeline dump initialization, and
//                performance monitoring infrastructure.
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Notes:        - This testbench instantiates the DUT,
//                  performance monitor, and pipeline monitor.
//                - All file handles for dumping and logging are
//                  initialized here for consistency and clarity.
//==============================================================//

`include "tb_macros.sv"
`include "misc_tasks.sv"
`include "performance_calcs.sv"

 module riscv_top_tb();

    //------------------------------------------------------
    //  Testbench Signals
    //------------------------------------------------------
    logic        clk;
    logic        reset;

    logic [31:0] write_data_mem;
    logic [31:0] alu_result_mem;
    logic        mem_write_mem;

    logic        test_complete;

    //------------------------------------------------------
    //  DUT Instantiation
    //------------------------------------------------------
    riscv_top u_riscv_top (
        // Clock & reset
        .clk_i                          (clk),
        .reset_i                        (reset),

        // Memory outputs
        .write_data_mem_o               (write_data_mem),
        .alu_result_mem_o               (alu_result_mem),
        .mem_write_mem_o                (mem_write_mem)
    );

    //------------------------------------------------------
    //  Clock & Reset Generation
    //------------------------------------------------------
    initial begin : signal_init
        dump_setup;

        test_complete = 0;
        clk           = 0;
        reset         = 1;
        #20;
        reset         = 0;
    end

    always begin : clk_gen
        clk = ~clk;
        #5;
    end

    //------------------------------------------------------
    //  File Handle Initialization
    //------------------------------------------------------
    int reg_dump_handle;
    int perf_dump_handle;
    initial begin : file_handle_init
        `ifdef PIPELINE_DUMP
            reg_dump_handle = $fopen({`DUMP_PATH, "/raw_pipeline_dump.yml"}, "w");
            if (reg_dump_handle == 0) begin
                $fatal(1, "ERROR: Could not open raw_pipeline_dump.yml");
            end
        `endif

        perf_dump_handle = $fopen({`DUMP_PATH, "/performance_dump.log"}, "w");
        if (perf_dump_handle == 0) begin
            $fatal(1, "ERROR: Could not open performance_dump.log");
        end
    end

    //------------------------------------------------------
    //  Test Completion Monitor (pass/fail/timeout)
    //------------------------------------------------------
    always @(negedge clk) begin : pass_monitor
        if (u_performance_monitor.cycle_cnt > 500000) begin
            $display("TEST TIMEOUT");
            test_complete = 1'b1;
        end

        if (`DATA_PATH_HIER.csr_we_wb_o && `DATA_PATH_HIER.csr_addr_wb_o == `MTEST_STATUS_ADDR) begin
            if (`DATA_PATH_HIER.csr_result_wb == `TEST_PASS) begin
                $display("TEST PASSED");
                test_complete = 1'b1;
            end else if (`DATA_PATH_HIER.csr_result_wb == `TEST_FAIL) begin
                $display("TEST FAILED");
                test_complete = 1'b1;
            end
        end
    end

    // ------------------------------------------------------------
    //  End-of-test
    // ------------------------------------------------------------
    initial begin
        wait(test_complete);
        repeat(15)@(posedge clk);
        print_perf_summary(
            .fd                                   (perf_dump_handle),

            .total_cycles                         (u_performance_monitor.cycle_cnt),
            .retire_cnt                           (u_performance_monitor.retire_cnt),

            .alu_op_cnt                           (u_performance_monitor.alu_op_cnt),
            .load_op_cnt                          (u_performance_monitor.load_op_cnt),
            .store_op_cnt                         (u_performance_monitor.store_op_cnt),
            .branch_op_cnt                        (u_performance_monitor.branch_op_cnt),

            .branch_mispredict_cnt                (u_performance_monitor.branch_mispredict_cnt),

            .load_stall_cnt                       (u_performance_monitor.load_stall_cnt),
            .branch_mispredict_stall_cycles       (u_performance_monitor.branch_mispredict_stall_cycles),
            .icache_miss_cnt                      (u_performance_monitor.icache_miss_cnt),
            .icache_miss_stall_cycles             (u_performance_monitor.icache_miss_stall_cycles)
        );
        #10;
        $finish;
    end

    //------------------------------------------------------
    //  Monitor Instantiations
    //------------------------------------------------------
    performance_monitor u_performance_monitor (
        // Clock & reset
        .clk_i            (clk),
        .reset_i          (reset),

        .valid_wb_i       (`DATA_PATH_HIER.valid_wb),
        .stall_wb_i       (`DATA_PATH_HIER.stall_wb_i),
        .instr_wb_i       (`DATA_PATH_HIER.instr_wb),

        .load_stall_i     (`HAZARD_UNIT_HIER.load_stall),

        .pc_src_i         (u_riscv_top.u_pipelined_riscv_core.pc_src),

        .instr_hit_fi_i   (`ICACHE_HIER.instr_hit_fi_o),
        .flush_ex_i       (`HAZARD_UNIT_HIER.flush_ex_o),

        .perf_dump_handle (perf_dump_handle)
    );


    `include "pipeline_monitor.sv"

endmodule
