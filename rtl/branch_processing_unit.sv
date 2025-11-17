`timescale 1ns / 1ps
//==============================================================//
//  Module:       branch_processing_unit
//  File:         branch_processing_unit.sv
//  Description:  Unit encapsulating all modules related to branching
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module branch_processing_unit (
        // Clock & reset_i
        input  logic        clk_i,
        input  logic        reset_i,

        // Status flag inputs
        input  logic        neg_flag_i,
        input  logic        zero_flag_i,
        input  logic        carry_flag_i,
        input  logic        v_flag_i,

        // Pipeline control inputs
        input  logic        stall_ex_i,
        input  logic        flush_ex_i,

        // Instruction decode inputs
        input  logic [2:0]  funct3_ex_i,
        input  logic [1:0]  branch_op_ex_i,
        input  logic [31:0] instr_fi_i,

        // pc inputs
        input  logic [9:0]  pc_fi_i,
        input  logic [9:0]  pc_ex_i,
        input  logic [31:0] pc_target_ex_i,

        // Branch predictor inputs
        input  logic        target_match_ex_i,
        input  logic        pc_src_pred_ex_i,

        // Control outputs
        output logic [1:0]  pc_src_o,
        output logic [1:0]  pc_src_reg_o,

        // Branch predictor outputs
        output logic [31:0] pred_pc_target_fi_o,
        output logic        pc_src_pred_fi_o
    );

    logic pc_src_res_ex;

    branch_resolution_unit u_branch_resolution_unit (
        // Instruction decode inputs
        .funct3_i                       (funct3_ex_i),
        .branch_op_i                    (branch_op_ex_i),

        // Status flag inputs
        .neg_flag_i                     (neg_flag_i),
        .zero_flag_i                    (zero_flag_i),
        .carry_flag_i                   (carry_flag_i),
        .v_flag_i                       (v_flag_i),

        // Resolution output
        .pc_src_res_o                   (pc_src_res_ex)
    );

    branch_predictor u_branch_predictor (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Pipeline control inputs
        .stall_ex_i                      (stall_ex_i),

        // pc inputs
        .pc_fi_i                         (pc_fi_i),
        .pc_ex_i                         (pc_ex_i),
        .pc_target_ex_i                  (pc_target_ex_i),

        // Branch resolution inputs
        .pc_src_res_ex_i                 (pc_src_res_ex),
        .target_match_ex_i               (target_match_ex_i),
        .branch_op_ex_i                  (branch_op_ex_i),

        // Predictor outputs
        .pc_src_pred_fi_o                (pc_src_pred_fi_o),
        .pred_pc_target_fi_o             (pred_pc_target_fi_o)
    );

    branch_control_unit u_branch_control_unit (
        // Instruction decode inputs
        .op_fi_i                         (instr_fi_i[6:5]),

        // Predictor inputs
        .pc_src_pred_fi_i                (pc_src_pred_fi_o),
        .pc_src_pred_ex_i                (pc_src_pred_ex_i),

        // Branch resolution inputs
        .branch_op_ex_i                  (branch_op_ex_i),
        .target_match_ex_i               (target_match_ex_i),
        .pc_src_res_ex_i                 (pc_src_res_ex),

        // Control output
        .pc_src_o                       (pc_src_o)
    );

    flop #(
        .WIDTH                          (2)
    ) u_src_reg (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .en                             (1'b1),
        .reset                          (reset_i | flush_ex_i),

        // data_i input
        .D                              (pc_src_o),

        // data_i output
        .Q                              (pc_src_reg_o)
    );

endmodule
