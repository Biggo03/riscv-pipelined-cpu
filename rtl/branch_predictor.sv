`timescale 1ns / 1ps
//==============================================================//
//  Module:       branch_predictor
//  File:         branch_predictor.sv
//  Description:  Combination of GHR and BranchingBuffer in order to determine branch predictions
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module branch_predictor (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Pipeline control inputs
    input  logic        stall_ex_i,

    // pc inputs
    input  logic [9:0]  pc_fi_i,
    input  logic [9:0]  pc_ex_i,
    input  logic [31:0] pc_target_ex_i,

    // Branch resolution inputs
    input  logic        pc_src_res_ex_i,
    input  logic        target_match_ex_i,
    input  logic [1:0]  branch_op_ex_i,

    // Predictor outputs
    output logic        pc_src_pred_fi_o,
    output logic [31:0] pred_pc_target_fi_o
);

    // ---- Control signal ----
    logic [1:0] local_src;

    ghr u_ghr (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Control inputs
        .stall_ex_i                      (stall_ex_i),
        .branch_op_ex_i                  (branch_op_ex_i),
        .pc_src_res_ex_i                 (pc_src_res_ex_i),

        // Control output
        .local_src_o                    (local_src)
    );


    branching_buffer u_branching_buffer (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // pc & control inputs
        .pc_target_ex_i                  (pc_target_ex_i),
        .pc_fi_i                         (pc_fi_i),
        .pc_ex                           (pc_ex_i),
        .local_src_i                    (local_src),
        .pc_src_res_ex_i                 (pc_src_res_ex_i),
        .target_match_i                 (target_match_ex_i),
        .branch_op_ex_i                  (branch_op_ex_i),

        // Control outputs
        .pc_src_pred_fi_o                (pc_src_pred_fi_o),
        .pred_pc_target_fi_o             (pred_pc_target_fi_o)
    );

endmodule
