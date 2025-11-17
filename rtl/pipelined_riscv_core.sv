`timescale 1ns / 1ps
//==============================================================//
//  Module:       pipelined_riscv_core
//  File:         pipelined_riscv_core.sv
//  Description:  Combination of all components of pipelined riscv core
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   WIDTH  - data width
//
//  Notes:        N/A
//==============================================================//

module pipelined_riscv_core (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Instruction fetch inputs
    input  logic [31:0] instr_fi_i,
    input  logic        instr_hit_fi_i,
    input  logic        ic_repl_permit_i,

    // Memory data inputs
    input  logic [31:0] read_data_mem_i,

    // pc outputs
    output logic [31:0] pc_fi_o,

    // ALU & memory outputs
    output logic [31:0] alu_result_mem_o,
    output logic [31:0] write_data_mem_o,

    // Control outputs
    output logic [2:0]  width_src_mem_o,
    output logic [1:0]  branch_op_ex_o,
    output logic [1:0]  pc_src_reg_o,
    output logic        mem_write_mem_o
);

    // ----- Control unit inputs -----
    logic [6:0] op_de;
    logic [2:0] funct3_de;
    logic [6:0] funct7_de;

    // ----- Control unit outputs -----
    logic [2:0] imm_src_de;
    logic [2:0] result_src_de;
    logic [1:0] branch_op_de;
    logic       alu_src_de;
    logic       pc_base_src_de;
    logic       reg_write_de;
    logic       mem_write_de;
    logic       csr_we_de;
    logic [3:0] alu_control_de;
    logic [2:0] width_src_de;
    logic [1:0] csr_control_de;
    logic       csr_src_de;

    // ----- Hazard control unit inputs -----
    logic [4:0]  rs1_de;
    logic [4:0]  rs2_de;
    logic [11:0] csr_addr_ex;
    logic [4:0]  rs1_ex;
    logic [4:0]  rs2_ex;
    logic [4:0]  rd_ex;
    logic [2:0]  result_src_ex;
    logic [11:0] csr_addr_mem;
    logic [4:0]  rd_mem;
    logic [11:0] csr_addr_wb;
    logic [4:0]  rd_wb;
    logic        reg_write_mem;
    logic        reg_write_wb;
    logic        csr_we_mem;
    logic        csr_we_wb;

    // ----- Hazard control unit outputs -----
    logic [1:0] forward_a_ex;
    logic [1:0] forward_b_ex;
    logic [1:0] forward_csr_ex;
    logic       stall_fi;
    logic       stall_de;
    logic       stall_ex;
    logic       stall_mem;
    logic       stall_wb;
    logic       flush_de;
    logic       flush_ex;

    // ----- Branch processing unit inputs -----
    logic        neg_flag;
    logic        zero_flag;
    logic        carry_flag;
    logic        v_flag;
    logic [2:0]  funct3_ex;
    logic [31:0] pc_ex;
    logic [31:0] pc_target_ex;
    logic        target_match_ex;
    logic        pc_src_pred_ex;

    // ----- Branch processing unit outputs -----
    logic [31:0] pred_pc_target_fi;
    logic [1:0]  pc_src;
    logic        pc_src_pred_fi;


    control_unit u_control_unit (
        // Instruction decode inputs
        .op_de_i                         (op_de),
        .funct3_de_i                     (funct3_de),
        .funct7_de_i                     (funct7_de),

        // Control outputs
        .imm_src_de_o                    (imm_src_de),
        .result_src_de_o                 (result_src_de),
        .branch_op_de_o                  (branch_op_de),
        .alu_src_de_o                    (alu_src_de),
        .pc_base_src_de_o                (pc_base_src_de),
        .mem_write_de_o                  (mem_write_de),
        .reg_write_de_o                  (reg_write_de),
        .csr_we_de_o                     (csr_we_de),
        .alu_control_de_o                (alu_control_de),
        .width_src_de_o                  (width_src_de),
        .csr_control_de_o                (csr_control_de),
        .csr_src_de_o                    (csr_src_de)
    );


    hazard_unit u_hazard_unit (
        // Fetch stage inputs
        .instr_hit_fi_i                 (instr_hit_fi_i),

        // Decode stage inputs
        .rs1_de_i                        (rs1_de),
        .rs2_de_i                        (rs2_de),

        // Execute stage inputs
        .rs1_ex_i                        (rs1_ex),
        .rs2_ex_i                        (rs2_ex),
        .rd_ex_i                         (rd_ex),
        .csr_addr_ex_i                   (csr_addr_ex),
        .result_src_ex_i                 (result_src_ex),
        .pc_src_i                       (pc_src),

        // Memory stage inputs
        .rd_mem_i                         (rd_mem),
        .reg_write_mem_i                  (reg_write_mem),
        .csr_addr_mem_i                   (csr_addr_mem),
        .csr_we_mem_i                     (csr_we_mem),

        // Writeback stage inputs
        .rd_wb_i                         (rd_wb),
        .reg_write_wb_i                  (reg_write_wb),
        .csr_addr_wb_i                   (csr_addr_wb),
        .csr_we_wb_i                     (csr_we_wb),

        // Branch predictor / cache inputs
        .pc_src_reg_i                   (pc_src_reg_o),
        .ic_repl_permit_i               (ic_repl_permit_i),

        // stall outputs
        .stall_fi_o                      (stall_fi),
        .stall_de_o                      (stall_de),
        .stall_ex_o                      (stall_ex),
        .stall_mem_o                      (stall_mem),
        .stall_wb_o                      (stall_wb),

        // flush outputs
        .flush_de_o                      (flush_de),
        .flush_ex_o                      (flush_ex),

        // Forwarding outputs
        .forward_a_ex_o                  (forward_a_ex),
        .forward_b_ex_o                  (forward_b_ex),
        .forward_csr_ex_o                (forward_csr_ex)
    );

    branch_processing_unit u_branch_processing_unit (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Status flag inputs
        .neg_flag_i                     (neg_flag),
        .zero_flag_i                    (zero_flag),
        .carry_flag_i                   (carry_flag),
        .v_flag_i                       (v_flag),

        // Pipeline control inputs
        .stall_ex_i                      (stall_ex),
        .flush_ex_i                      (flush_ex),

        // Instruction decode inputs
        .funct3_ex_i                     (funct3_ex),
        .branch_op_ex_i                  (branch_op_ex_o),
        .instr_fi_i                      (instr_fi_i),

        // pc inputs
        .pc_fi_i                         (pc_fi_o[9:0]),
        .pc_ex_i                         (pc_ex[9:0]),
        .pc_target_ex_i                  (pc_target_ex),

        // Branch predictor inputs
        .target_match_ex_i               (target_match_ex),
        .pc_src_pred_ex_i                (pc_src_pred_ex),

        // Control outputs
        .pc_src_o                       (pc_src),
        .pc_src_reg_o                   (pc_src_reg_o),

        // Predictor outputs
        .pred_pc_target_fi_o             (pred_pc_target_fi),
        .pc_src_pred_fi_o                (pc_src_pred_fi)
    );

    data_path u_data_path (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Instruction fetch inputs
        .instr_fi_i                      (instr_fi_i),
        .pred_pc_target_fi_i             (pred_pc_target_fi),
        .pc_src_i                       (pc_src),
        .pc_src_pred_fi_i                (pc_src_pred_fi),

        // Memory inputs
        .read_data_mem_i                  (read_data_mem_i),

        // Control inputs
        .imm_src_de_i                    (imm_src_de),
        .result_src_de_i                 (result_src_de),
        .branch_op_de_i                  (branch_op_de),
        .alu_src_de_i                    (alu_src_de),
        .pc_base_src_de_i                (pc_base_src_de),
        .reg_write_de_i                  (reg_write_de),
        .mem_write_de_i                  (mem_write_de),
        .csr_we_de_i                     (csr_we_de),
        .alu_control_de_i                (alu_control_de),
        .width_src_de_i                  (width_src_de),
        .csr_control_de_i                (csr_control_de),
        .csr_src_de_i                    (csr_src_de),
        .forward_a_ex_i                  (forward_a_ex),
        .forward_b_ex_i                  (forward_b_ex),
        .forward_csr_ex_i                (forward_csr_ex),
        .flush_de_i                      (flush_de),
        .flush_ex_i                      (flush_ex),
        .stall_de_i                      (stall_de),
        .stall_fi_i                      (stall_fi),
        .stall_ex_i                      (stall_ex),
        .stall_mem_i                      (stall_mem),
        .stall_wb_i                      (stall_wb),

        // data outputs
        .alu_result_mem_o                 (alu_result_mem_o),
        .write_data_mem_o                 (write_data_mem_o),
        .pc_fi_o                         (pc_fi_o),
        .width_src_mem_o                  (width_src_mem_o),
        .mem_write_mem_o                  (mem_write_mem_o),

        // Control outputs
        .op_de_o                         (op_de),
        .funct3_de_o                     (funct3_de),
        .funct3_ex_o                     (funct3_ex),
        .funct7_de_o                     (funct7_de),
        .branch_op_ex_o                  (branch_op_ex_o),
        .neg_flag_o                     (neg_flag),
        .zero_flag_o                    (zero_flag),
        .carry_flag_o                   (carry_flag),
        .v_flag_o                       (v_flag),
        .pc_ex_o                         (pc_ex),
        .pc_target_ex_o                  (pc_target_ex),
        .pc_src_pred_ex_o                (pc_src_pred_ex),
        .target_match_ex_o               (target_match_ex),
        .rs1_de_o                        (rs1_de),
        .rs2_de_o                        (rs2_de),
        .csr_addr_ex_o                   (csr_addr_ex),
        .rs1_ex_o                        (rs1_ex),
        .rs2_ex_o                        (rs2_ex),
        .rd_ex_o                         (rd_ex),
        .result_src_ex_o                 (result_src_ex),
        .csr_addr_mem_o                   (csr_addr_mem),
        .rd_mem_o                         (rd_mem),
        .csr_addr_wb_o                   (csr_addr_wb),
        .rd_wb_o                         (rd_wb),
        .reg_write_mem_o                  (reg_write_mem),
        .reg_write_wb_o                  (reg_write_wb),
        .csr_we_mem_o                     (csr_we_mem),
        .csr_we_wb_o                     (csr_we_wb)
    );

endmodule
