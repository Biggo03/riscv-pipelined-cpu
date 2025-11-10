`timescale 1ns / 1ps
`include "misc_tasks.sv"
`include "csr_macros.sv"
`include "tb_macros.sv"
//==============================================================//
//  Module:       csr_reg_file_tb
//  File:         csr_reg_file_tb.sv
//  Description:  Testbench for CSR register file.
//
//                 This testbench verifies the functionality of the
//                 csr_reg_file module, including:
//                   - Reset value correctness
//                   - Read/write access behavior
//                   - Write-through behavior
//                   - Auto-increment register tracking (if applicable)
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   CLK_PERIOD — simulation clock period
//
//  Notes:        - This file may be partially auto-generated using Jinja.
//                - Manual sections (e.g., monitors or scoreboards) are
//                  safe to modify and extend.
//==============================================================//

module csr_reg_file_tb;

    // ------------------------------------------------------------
    //  Parameters
    // ------------------------------------------------------------
    localparam CLK_PERIOD = 10ns;

    // ------------------------------------------------------------
    //  u_dut Signals
    // ------------------------------------------------------------
    logic         clk_i;
    logic         reset_i;

    logic         csr_we_i;
    logic [11:0]  csr_waddr_i;
    logic [31:0]  csr_wdata_i;

    logic [11:0]  csr_raddr_i;
    logic [31:0]  csr_rdata_o;

    logic         retire_w_i;

    // ------------------------------------------------------------
    //  Testbench Signals
    // ------------------------------------------------------------
    logic [31:0] tb_rdata;
    logic [31:0] tb_wdata;

    logic [31:0] intermediate_data;

    logic [63:0] clk_counter;
    logic [63:0] retire_counter;
    int          error_cnt;
    // ------------------------------------------------------------
    //  Clock and Reset Generation
    // ------------------------------------------------------------
    initial begin
        clk_i = 0;
        forever #(CLK_PERIOD/2) clk_i = ~clk_i;
    end

    task automatic apply_reset();
    begin
        tb_rdata = 0;
        tb_wdata = 0;
        clk_counter = 0;
        retire_counter = 0;

        reset_i      = 1'b1;
        csr_we_i     = 1'b0;
        csr_waddr_i  = '0;
        csr_wdata_i  = '0;
        csr_raddr_i  = '0;
        retire_w_i   = 1'b1; //Active from start
        repeat (5) @(posedge clk_i);
        reset_i = 1'b0;
    end
    endtask

    // ------------------------------------------------------------
    //  Register Tasks
    // ------------------------------------------------------------
    task write_register(
        input logic [11:0] waddr,
        input logic [31:0] wdata
    );
    begin
        csr_we_i = 1'b1;
        csr_waddr_i = waddr;
        csr_wdata_i = wdata;
        $display("[%t] Writing data %h to address %h", $realtime, wdata, waddr);
        @(posedge clk_i);
        csr_we_i = 1'b0;
    end
    endtask

    //Read on falling edge of clock to allow for
    task read_register(
        input logic [11:0] raddr,
        output logic [31:0] rdata
    );
    begin
        csr_raddr_i = raddr;
        @(negedge clk_i);
        rdata = csr_rdata_o;
        $display("[%t] Read value %h from address %h", $realtime, rdata, raddr);
    end
    endtask

    task write_through(
        input logic [11:0] addr,
        input logic [31:0] wdata
    );
    begin
        @(posedge clk_i);
        // Check writethrough works in same cycle
        csr_waddr_i = addr;
        csr_raddr_i = addr;
        csr_wdata_i = wdata;
        csr_we_i = 1'b1;
        @(negedge clk_i); // Want to check mid-cycle to confirm writethrough
        `CHECK(csr_rdata_o === wdata, "[%t] Writethrough read failed at address %h", $realtime, addr);

        //Ensure value is actually written
        @(posedge clk_i);
        csr_waddr_i = 0;
        csr_we_i = 1'b0;
        @(negedge clk_i);
        `CHECK(csr_rdata_o === wdata, "[%t] Writethrough did not write after posedge at address %h", $realtime, addr);
    end
    endtask

    // ------------------------------------------------------------
    //  Counter logic
    // ------------------------------------------------------------
    always_ff @(posedge clk_i) begin : counter_logic
        if (~reset_i) begin
            clk_counter = clk_counter + 1;
            retire_counter = retire_w_i ? retire_counter + 1 : retire_counter;
        end else begin
            clk_counter = 0;
            retire_counter = 0;
        end
    end

    // ------------------------------------------------------------
    //  u_dut Instantiation
    // ------------------------------------------------------------
    csr_regfile u_dut (
      // -- Clk and Reset --
      .clk_i       (clk_i),
      .reset_i     (reset_i),

      // -- Write Signals --
      .csr_we_i    (csr_we_i),
      .csr_waddr_i (csr_waddr_i),
      .csr_wdata_i (csr_wdata_i),

      // -- Read Signals --
      .csr_raddr_i (csr_raddr_i),
      .csr_rdata_o (csr_rdata_o),

      // -- Other --
      .retire_w_i  (retire_w_i)
    );

    // ------------------------------------------------------------
    //  Test Sequence (Placeholder)
    // ------------------------------------------------------------
    initial begin

        dump_setup;

        $display("==== Starting CSR Register File Test ====");
        apply_reset();

        // Check reset
        $display("[%t] Beginning reset check...", $realtime);
        `CHECK(u_dut.mcycle_q === 32'h0, "mcycle reset value incorrect");
        `CHECK(u_dut.mcycleh_q === 32'h0, "mcycleh reset value incorrect");
        `CHECK(u_dut.minstret_q === 32'h0, "minstret reset value incorrect");
        `CHECK(u_dut.minstreth_q === 32'h0, "minstreth reset value incorrect");
        `CHECK(u_dut.mstatus_q === 32'h0, "mstatus reset value incorrect");
        `CHECK(u_dut.mtest_status_q === 32'h0, "mtest_status reset value incorrect");

        //Readcheck for standard registers
        $display("[%t] Beginning read check for standard registers...", $realtime);
        read_register(`MSTATUS_ADDR, tb_rdata);
        `CHECK(csr_rdata_o === 32'h0, "Reset check for mstatus failed");

        read_register(`MTEST_STATUS_ADDR, tb_rdata);
        `CHECK(csr_rdata_o === 32'h0, "Reset check for mtest_status failed");


        // Readcheck for special registers
        $display("[%t] Beginning read check for special registers...", $realtime);
        read_register(`MCYCLE_ADDR, tb_rdata);
        `CHECK(tb_rdata === clk_counter[31:0], "Read check for mcycle failed");

        read_register(`MCYCLEH_ADDR, tb_rdata);
        `CHECK(tb_rdata === clk_counter[63:32], "Read check for mcycleh failed");

        read_register(`MINSTRET_ADDR, tb_rdata);
        `CHECK(tb_rdata === retire_counter[31:0], "Read check for minstret failed");

        read_register(`MINSTRETH_ADDR, tb_rdata);
        `CHECK(tb_rdata === retire_counter[63:32], "Read check for minstreth failed");

        // Writecheck for all W access registers
        $display("[%t] Beginning write check for all writable registers...", $realtime);
        tb_wdata = $urandom();
        write_register(`MCYCLE_ADDR, tb_wdata);
        read_register(`MCYCLE_ADDR, tb_rdata);
        `CHECK(tb_rdata === tb_wdata, "Write check for mcycle failed");

        tb_wdata = $urandom();
        write_register(`MCYCLEH_ADDR, tb_wdata);
        read_register(`MCYCLEH_ADDR, tb_rdata);
        `CHECK(tb_rdata === tb_wdata, "Write check for mcycleh failed");

        tb_wdata = $urandom();
        write_register(`MINSTRET_ADDR, tb_wdata);
        read_register(`MINSTRET_ADDR, tb_rdata);
        `CHECK(tb_rdata === tb_wdata, "Write check for minstret failed");

        tb_wdata = $urandom();
        write_register(`MINSTRETH_ADDR, tb_wdata);
        read_register(`MINSTRETH_ADDR, tb_rdata);
        `CHECK(tb_rdata === tb_wdata, "Write check for minstreth failed");

        tb_wdata = $urandom();
        write_register(`MSTATUS_ADDR, tb_wdata);
        read_register(`MSTATUS_ADDR, tb_rdata);
        `CHECK(tb_rdata === tb_wdata, "Write check for mstatus failed");

        tb_wdata = $urandom();
        write_register(`MTEST_STATUS_ADDR, tb_wdata);
        read_register(`MTEST_STATUS_ADDR, tb_rdata);
        `CHECK(tb_rdata === tb_wdata, "Write check for mtest_status failed");


        // Writethrough check
        $display("[%t] Beginning writethrough check for all writable registers...", $realtime);
        tb_wdata = $urandom();
        write_through(`MCYCLE_ADDR, tb_wdata);

        tb_wdata = $urandom();
        write_through(`MCYCLEH_ADDR, tb_wdata);

        tb_wdata = $urandom();
        write_through(`MINSTRET_ADDR, tb_wdata);

        tb_wdata = $urandom();
        write_through(`MINSTRETH_ADDR, tb_wdata);

        tb_wdata = $urandom();
        write_through(`MSTATUS_ADDR, tb_wdata);

        tb_wdata = $urandom();
        write_through(`MTEST_STATUS_ADDR, tb_wdata);


        // reset all special registers
        $display("[%t] Resetting all special registers...", $realtime);
        write_register(`MCYCLE_ADDR, clk_counter[31:0]);
        write_register(`MCYCLEH_ADDR, clk_counter[63:32]);
        write_register(`MINSTRET_ADDR, retire_counter[31:0]);
        write_register(`MINSTRETH_ADDR, retire_counter[63:32]);

        // Counter top 32-bit increment check
        $display("[%t] Beginning top counter increment check...", $realtime);
        tb_wdata = 32'hFFFF_FFF0;
        write_register(`MCYCLE_ADDR, tb_wdata);
        write_register(`MINSTRET_ADDR, tb_wdata);
        repeat (32'hFFFF_FFFF - tb_wdata) @(posedge clk_i);

        read_register(`MCYCLEH_ADDR, tb_rdata);
        `CHECK(tb_rdata === 1'b1, "mcycleh increment failed");
        read_register(`MINSTRETH_ADDR, tb_rdata);
        `CHECK(tb_rdata === 1'b1, "minstreth increment failed");

        retire_w_i = 0;
        read_register(`MINSTRET_ADDR, intermediate_data);
        repeat (20) @(posedge clk_i);

        read_register(`MINSTRET_ADDR, tb_rdata);
        `CHECK(tb_rdata === intermediate_data, "minstret incrementing when retire_w_i low");

        #100;
        if (error_cnt == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
    end

endmodule
