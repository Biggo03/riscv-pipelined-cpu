`timescale 1ns / 1ps
//==============================================================//
//  Module:       hazard_unit
//  File:         hazard_unit.sv
//  Description:  Generates signals to control hazard handelling within the pipeline
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//
`include "control_macros.sv"

module hazard_unit (
    // Fetch stage inputs
    input  logic        instr_hit_fi_i,

    // Decode stage inputs
    input  logic [4:0]  rs1_de_i,
    input  logic [4:0]  rs2_de_i,

    // Execute stage inputs
    input  logic [4:0]  rs1_ex_i,
    input  logic [4:0]  rs2_ex_i,
    input  logic [4:0]  rd_ex_i,
    input  logic [11:0] csr_addr_ex_i,
    input  logic [2:0]  result_src_ex_i,
    input  logic [1:0]  pc_src_i,

    // Memory stage inputs
    input  logic [4:0]  rd_mem_i,
    input  logic        reg_write_mem_i,
    input  logic [11:0] csr_addr_mem_i,
    input  logic        csr_we_mem_i,

    // Writeback stage inputs
    input  logic [4:0]  rd_wb_i,
    input  logic        reg_write_wb_i,
    input  logic [11:0] csr_addr_wb_i,
    input  logic        csr_we_wb_i,

    // Branch predictor / cache inputs
    input  logic [1:0]  pc_src_reg_i,
    input  logic        ic_repl_permit_i,

    // Stall outputs
    output logic        stall_fi_o,
    output logic        stall_de_o,
    output logic        stall_ex_o,
    output logic        stall_mem_o,
    output logic        stall_wb_o,

    // Flush outputs
    output logic        flush_de_o,
    output logic        flush_ex_o,

    // Forwarding outputs
    output logic [1:0]  forward_a_ex_o,
    output logic [1:0]  forward_b_ex_o,
    output logic [1:0]  forward_csr_ex_o
);

    // ----- Hazard detection -----
    logic load_stall;

    //Forward logic
    always_comb begin

        //forward_a_ex_o
        if (((rs1_ex_i == rd_mem_i) & reg_write_mem_i) & (rs1_ex_i != 0)) forward_a_ex_o = `MEM_FORWARD;
        else if (((rs1_ex_i == rd_wb_i) & reg_write_wb_i) & (rs1_ex_i != 0)) forward_a_ex_o = `WB_FORWARD;
        else forward_a_ex_o = `NO_FORWARD;

        //forward_b_ex_o
        if (((rs2_ex_i == rd_mem_i) & reg_write_mem_i) & (rs2_ex_i != 0)) forward_b_ex_o = `MEM_FORWARD;
        else if (((rs2_ex_i == rd_wb_i) & reg_write_wb_i) & (rs2_ex_i != 0)) forward_b_ex_o = `WB_FORWARD;
        else forward_b_ex_o = `NO_FORWARD;

        //forward_csr
        if ((csr_addr_ex_i == csr_addr_mem_i) & csr_we_mem_i) forward_csr_ex_o = `MEM_FORWARD;
        else if ((csr_addr_ex_i == csr_addr_wb_i) & csr_we_wb_i) forward_csr_ex_o = `WB_FORWARD;
        else forward_csr_ex_o = `NO_FORWARD;
    end

    //stall and flush logic
    assign load_stall = (result_src_ex_i == `RESULT_MEM_DATA) & ((rs1_de_i == rd_ex_i) | (rs2_de_i == rd_ex_i));

    //Stalls
    assign stall_fi_o = (load_stall | ~instr_hit_fi_i) & ~pc_src_reg_i[1];
    assign stall_de_o = load_stall | ~instr_hit_fi_i;
    assign stall_ex_o = ~instr_hit_fi_i;
    assign stall_mem_o = ~instr_hit_fi_i;
    assign stall_wb_o = ~instr_hit_fi_i;

    //Flushes
    assign flush_ex_o = (pc_src_i[1] & (ic_repl_permit_i | pc_src_reg_i[1])) | load_stall;
    assign flush_de_o = pc_src_i[1];

endmodule
