`timescale 1ns / 1ps
//==============================================================//
//  Module:       csr_reg_file
//  File:         csr_reg_file.sv
//  Description:  Auto-generated CSR register file.
//
//                 This module defines all supported CSRs along with
//                 their reset values, access permissions, and address
//                 decoding logic. The structure and content of this file
//                 are generated automatically from the CSR specification
//                 (YAML/Excel source).
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        - This file is partially auto-generated.
//                - Do not edit auto-generated sections directly; they may
//                  be overwritten by regeneration scripts.
//==============================================================//
`include "instr_macros.sv"
`include "csr_macros.sv"

module csr_regfile (
    // -- Clk and Reset --
    input logic         clk_i,
    input logic         reset_i,

    // -- Write Signals --
    input logic         csr_we_i,
    input logic [11:0]  csr_waddr_i,
    input logic [31:0]  csr_wdata_i,

    // -- Read Signals --
    input  logic [11:0] csr_raddr_i,
    output logic [31:0] csr_rdata_o,

    // -- Other --
    input logic         retire_w_i
);

    // csr signal definitions

    // Bottom 32-bits storing number of cycles
    logic [31:0] mcycle_q;
    logic [31:0] mcycle_next;

    // Top 32-bits storing number of cycles
    logic [31:0] mcycleh_q;
    logic [31:0] mcycleh_next;

    // Bottom 32-bits storing number of instructions retired
    logic [31:0] minstret_q;
    logic [31:0] minstret_next;

    // Top 32-bits storing number of instructions retired
    logic [31:0] minstreth_q;
    logic [31:0] minstreth_next;


    // Write logic (only implementing specific registers as of now)
    always_ff @(posedge clk_i) begin : csr_write_ff
        if (reset_i) begin
            mcycle_q    <= 32'h0;
            mcycleh_q   <= 32'h0;
            minstret_q  <= 32'h0;
            minstreth_q <= 32'h0;
        end else begin
            mcycle_q    <= mcycle_next;
            mcycleh_q   <= mcycleh_next;
            minstret_q  <= minstret_next;
            minstreth_q <= minstreth_next;
        end
    end

    // Read logic
    always_comb begin : csr_read_comb
        unique case (csr_raddr_i)
            `MCYCLE_ADDR   : csr_rdata_o = (csr_we_i && csr_waddr_i == csr_raddr_i) ? csr_wdata_i : mcycle_q;
            `MCYCLEH_ADDR  : csr_rdata_o = (csr_we_i && csr_waddr_i == csr_raddr_i) ? csr_wdata_i : mcycleh_q;
            `MINSTRET_ADDR : csr_rdata_o = (csr_we_i && csr_waddr_i == csr_raddr_i) ? csr_wdata_i : minstret_q;
            `MINSTRETH_ADDR: csr_rdata_o = (csr_we_i && csr_waddr_i == csr_raddr_i) ? csr_wdata_i : minstreth_q;
            default: csr_rdata_o = 32'h0;
        endcase
    end

    always_comb begin : csr_next_comb
        // Standard writable registers

        // Following registers next cycle behaviour manually generated:
        //mcycle mcycleh minstret minstreth

        // mcycle handelling
        mcycle_next = (csr_we_i && csr_waddr_i == `MCYCLE_ADDR) ? csr_wdata_i : mcycle_q + 1;

        //mcycleh handelling
        if (~csr_we_i || csr_waddr_i != `MCYCLEH_ADDR) begin
            mcycleh_next = mcycleh_q + (mcycle_q == 32'hFFFF_FFFF);
        end else begin
            mcycleh_next = csr_wdata_i;
        end

        // minstret handelling
        if (~csr_we_i || csr_waddr_i != `MINSTRET_ADDR) begin
            minstret_next = (retire_w_i) ? minstret_q + 1 : minstret_q;
        end else begin
            minstret_next = csr_wdata_i;
        end

        // minstreth handelling
        if (~csr_we_i || csr_waddr_i != `MINSTRETH_ADDR) begin
            minstreth_next = (retire_w_i) ? minstreth_q + (minstret_q == 32'hFFFF_FFFF) : minstret_q;
        end else begin
            minstreth_next = csr_wdata_i;
        end
    end

endmodule
