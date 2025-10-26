`timescale 1ns / 1ps
`include "control_macros.sv"
`include "tb_macros.sv"

module csr_alu_tb();

    localparam int WIDTH = 32;

    // tb signals
    int error_cnt;

    // DUT signals
    logic [1:0] csr_control_i;

    logic [WIDTH-1:0] operand_a_i;
    logic [WIDTH-1:0] operand_b_i;

    logic [WIDTH-1:0]  csr_result_o;

    csr_alu u_DUT (
        .csr_control_i       (csr_control_i),

        .operand_b_i        (operand_b_i),
        .operand_a_i        (operand_a_i),

        .csr_result_o       (csr_result_o)
    );

    initial begin
        $display("=== Starting csr_alu basic test ===");

        dump_setup;

        // ---------- Test 1: CSR_SET ----------
        operand_a_i     = 32'hFFFF_FFFF;
        operand_b_i     = 32'h0000_0000;
        csr_control_i   = `CSR_SET;
        #1;
        `CHECK(csr_result_o == (operand_b_i | operand_a_i), "CSR_SET failed: got %h, expected %h", csr_result_o, (operand_b_i | operand_a_i));

        // ---------- Test 2: CSR_CLEAR ----------
        operand_a_i     = 32'h0000_00FF;
        operand_b_i     = 32'hFFFF_FFFF;
        csr_control_i   = `CSR_CLEAR;
        #1;
        `CHECK(csr_result_o == (operand_b_i & ~operand_a_i), "CSR_CLEAR failed: got %h, expected %h", csr_result_o, (operand_b_i & ~operand_a_i));

        // ---------- Test 3: CSR_PASS ----------
        operand_a_i     = 32'hDEAD_BEEF;
        operand_b_i     = 32'h1234_5678;
        csr_control_i   = `CSR_PASS;
        #1;
        `CHECK(csr_result_o == operand_a_i, "CSR_PASS failed: got %h, expected %h", csr_result_o, operand_a_i);

        if (error_cnt == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
    end

endmodule
