`timescale 1ns / 1ps
//==============================================================//
//  Module:       control_unit
//  File:         control_unit.sv
//  Description:  Control unit for pipelined riscv processor
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module control_unit (
    // Instruction decode inputs
    input  logic [6:0] op_de_i,
    input  logic [2:0] funct3_de_i,
    input  logic [6:0] funct7_de_i,

    // Main decoder outputs
    output logic [2:0] imm_src_de_o,
    output logic [2:0] result_src_de_o,
    output logic [1:0] branch_op_de_o,
    output logic       alu_src_de_o,
    output logic       pc_base_src_de_o,
    output logic       reg_write_de_o,
    output logic       mem_write_de_o,
    output logic       csr_we_de_o,

    // ALU decoder output
    output logic [3:0] alu_control_de_o,

    // Width decoder output
    output logic [2:0] width_src_de_o,

    // csr decoder output
    output logic [1:0] csr_control_de_o,
    output logic       csr_src_de_o
);


    // ----- Control signals -----
    logic [1:0] alu_op;
    logic width_op;

    main_decoder u_main_decoder (
        // Instruction decode input
        .op                             (op_de_i),

        // Control outputs
        .imm_src_o                      (imm_src_de_o),
        .result_src_o                   (result_src_de_o),
        .alu_op_o                       (alu_op),
        .branch_op_o                    (branch_op_de_o),
        .width_op_o                     (width_op),
        .alu_src_o                      (alu_src_de_o),
        .pc_base_src_o                  (pc_base_src_de_o),
        .reg_write_o                    (reg_write_de_o),
        .mem_write_o                    (mem_write_de_o),
        .csr_we_o                       (csr_we_de_o)
    );

    alu_decoder u_alu_decoder (
        // Instruction decode inputs
        .funct3_i                       (funct3_de_i),
        .alu_op_i                       (alu_op),
        .op                             (op_de_i),
        .funct7_i                       (funct7_de_i),

        // Control output
        .alu_control_o                  (alu_control_de_o)
    );

    width_decoder u_width_decoder (
        // Instruction decode inputs
        .funct3_i                       (funct3_de_i),
        .width_op_i                     (width_op),

        // Control output
        .width_src_o                    (width_src_de_o)
    );

    csr_decoder u_csr_decoder (
        // Control Input
        .funct3_i                       (funct3_de_i),

        // Control Output
        .csr_control_o                  (csr_control_de_o),
        .csr_src_o                      (csr_src_de_o)
    );

endmodule
