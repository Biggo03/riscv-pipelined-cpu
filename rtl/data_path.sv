`timescale 1ns / 1ps
//===================m==========================================//
//  Module:       data_path
//  File:         data_path.sv
//  Description:  All logic contained within the datapath
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module data_path (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // data inputs
    input  logic [31:0] instr_fi_i,
    input  logic [31:0] read_data_mem_i,
    input  logic [31:0] pred_pc_target_fi_i,

    // Control inputs
    input  logic [2:0]  imm_src_de_i,
    input  logic [2:0]  result_src_de_i,
    input  logic [1:0]  branch_op_de_i,
    input  logic        alu_src_de_i,
    input  logic        pc_base_src_de_i,
    input  logic        reg_write_de_i,
    input  logic        mem_write_de_i,
    input  logic        csr_we_de_i,
    input  logic [3:0]  alu_control_de_i,
    input  logic [2:0]  width_src_de_i,
    input  logic [1:0]  csr_control_de_i,
    input  logic        csr_src_de_i,
    input  logic [1:0]  pc_src_i,
    input  logic        pc_src_pred_fi_i,

    // Hazard control inputs
    input  logic [1:0]  forward_a_ex_i,
    input  logic [1:0]  forward_b_ex_i,
    input  logic [1:0]  forward_csr_ex_i,
    input  logic        flush_de_i,
    input  logic        flush_ex_i,
    input  logic        stall_de_i,
    input  logic        stall_fi_i,
    input  logic        stall_ex_i,
    input  logic        stall_mem_i,
    input  logic        stall_wb_i,

    // Memory outputs
    output logic [31:0] alu_result_mem_o,
    output logic [31:0] write_data_mem_o,
    output logic [31:0] pc_fi_o,
    output logic [2:0]  width_src_mem_o,
    output logic        mem_write_mem_o,

    // Control unit outputs
    output logic [6:0]  op_de_o,
    output logic [2:0]  funct3_de_o,
    output logic [2:0]  funct3_ex_o,
    output logic [6:0]  funct7_de_o,
    output logic [1:0]  branch_op_ex_o,
    output logic        neg_flag_o,
    output logic        zero_flag_o,
    output logic        carry_flag_o,
    output logic        v_flag_o,

    // Branch processing outputs
    output logic [31:0] pc_ex_o,
    output logic [31:0] pc_target_ex_o,  // Only need 10 LSBs
    output logic        pc_src_pred_ex_o,
    output logic        target_match_ex_o,

    // Hazard control outputs
    output logic [4:0]  rs1_de_o,
    output logic [4:0]  rs2_de_o,
    output logic [11:0] csr_addr_ex_o,
    output logic [4:0]  rs1_ex_o,
    output logic [4:0]  rs2_ex_o,
    output logic [4:0]  rd_ex_o,
    output logic [2:0]  result_src_ex_o,
    output logic [11:0] csr_addr_mem_o,
    output logic [4:0]  rd_mem_o,
    output logic [11:0] csr_addr_wb_o,
    output logic [4:0]  rd_wb_o,
    output logic        reg_write_mem_o,
    output logic        reg_write_wb_o,
    output logic        csr_we_mem_o,
    output logic        csr_we_wb_o
);

    // ----- Fetch stage -----
    logic [31:0] pc_plus4_fi;

    // ----- Decode stage -----
    logic [31:0] instr_de;
    logic [31:0] imm_ext_de;
    logic [31:0] pc_de;
    logic [31:0] pc_plus4_de;
    logic [31:0] pred_pc_target_de;
    logic [4:0]  rd_de;
    logic [11:0] csr_addr_de;
    logic        pc_src_pred_de;
    logic        valid_de;

    // ----- Execute stage -----
    logic [31:0] instr_ex;
    logic [31:0] alu_result_ex;
    logic [31:0] write_data_ex;
    logic [31:0] pc_plus4_ex;
    logic [31:0] imm_ext_ex;
    logic [31:0] csr_result_ex;
    logic [31:0] csr_data_ex;
    logic [2:0]  width_src_ex;
    logic [1:0]  csr_control_ex;
    logic        csr_src_ex;
    logic        mem_write_ex;
    logic        reg_write_ex;
    logic        csr_we_ex;
    logic        valid_ex;

    // ----- Memory stage -----
    logic [31:0] instr_mem;
    logic [31:0] reduced_data_mem;
    logic [31:0] pc_target_mem;
    logic [31:0] pc_plus4_mem;
    logic [31:0] imm_ext_mem;
    logic [31:0] csr_result_mem;
    logic [31:0] csr_data_mem;
    logic [31:0] forward_data_mem;
    logic [2:0]  result_src_mem;
    logic        valid_mem;

    // ----- Writeback stage -----
    logic [31:0] instr_wb;
    logic [31:0] result_wb;
    logic [31:0] csr_result_wb;
    logic [31:0] csr_data_wb;
    logic        valid_wb;
    logic        retire_wb;

    // ----- Register file -----
    logic [31:0] reg_data_1_de;
    logic [31:0] reg_data_2_de;

    // ----- CSR reg file -----
    logic [31:0] csr_rdata_de;

    fetch_stage u_fetch_stage (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // pc inputs
        .pc_target_ex_i                  (pc_target_ex_o),
        .pc_plus4_ex_i                   (pc_plus4_ex),
        .pred_pc_target_fi_i             (pred_pc_target_fi_i),
        .pc_src_i                       (pc_src_i),

        // Control inputs
        .stall_fi_i                      (stall_fi_i),

        // pc outputs
        .pc_fi_o                         (pc_fi_o),
        .pc_plus4_fi_o                   (pc_plus4_fi)
    );

    decode_stage u_decode_stage (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Instruction & pc inputs
        .instr_fi_i                      (instr_fi_i),
        .pc_fi_i                         (pc_fi_o),
        .pc_plus4_fi_i                   (pc_plus4_fi),
        .pred_pc_target_fi_i             (pred_pc_target_fi_i),
        .pc_src_pred_fi_i                (pc_src_pred_fi_i),

        // Control inputs
        .imm_src_de_i                    (imm_src_de_i),
        .stall_de_i                      (stall_de_i),
        .flush_de_i                      (flush_de_i),

        // data outputs
        .instr_de_o                      (instr_de),
        .imm_ext_de_o                    (imm_ext_de),
        .pred_pc_target_de_o             (pred_pc_target_de),
        .csr_addr_de_o                   (csr_addr_de),
        .pc_de_o                         (pc_de),
        .pc_plus4_de_o                   (pc_plus4_de),
        .rd_de_o                         (rd_de),
        .rs1_de_o                        (rs1_de_o),
        .rs2_de_o                        (rs2_de_o),
        .op_de_o                         (op_de_o),
        .funct3_de_o                     (funct3_de_o),
        .funct7_de_o                     (funct7_de_o),
        .pc_src_pred_de_o                (pc_src_pred_de),

        // Control Outputs
        .valid_de_o                      (valid_de)
    );

    execute_stage u_execute_stage (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // data inputs
        .instr_de_i                      (instr_de),
        .reg_data_1_de_i                 (reg_data_1_de),
        .reg_data_2_de_i                 (reg_data_2_de),
        .csr_result_mem_i                 (csr_result_mem),
        .csr_result_wb_i                 (csr_result_wb),
        .result_wb_i                     (result_wb),
        .forward_data_mem_i               (forward_data_mem),
        .pc_de_i                         (pc_de),
        .pc_plus4_de_i                   (pc_plus4_de),
        .imm_ext_de_i                    (imm_ext_de),
        .pred_pc_target_de_i             (pred_pc_target_de),
        .csr_rdata_de_i                  (csr_rdata_de),
        .csr_addr_de_i                   (csr_addr_de),

        // Control inputs
        .valid_de_i                      (valid_de),
        .funct3_de_i                     (funct3_de_o),
        .rd_de_i                         (rd_de),
        .rs1_de_i                        (rs1_de_o),
        .rs2_de_i                        (rs2_de_o),
        .result_src_de_i                 (result_src_de_i),
        .branch_op_de_i                  (branch_op_de_i),
        .alu_src_de_i                    (alu_src_de_i),
        .pc_base_src_de_i                (pc_base_src_de_i),
        .reg_write_de_i                  (reg_write_de_i),
        .mem_write_de_i                  (mem_write_de_i),
        .csr_we_de_i                     (csr_we_de_i),
        .alu_control_de_i                (alu_control_de_i),
        .width_src_de_i                  (width_src_de_i),
        .csr_control_de_i                (csr_control_de_i),
        .csr_src_de_i                    (csr_src_de_i),
        .forward_a_ex_i                  (forward_a_ex_i),
        .forward_b_ex_i                  (forward_b_ex_i),
        .forward_csr_ex_i                (forward_csr_ex_i),
        .flush_ex_i                      (flush_ex_i),
        .stall_ex_i                      (stall_ex_i),
        .pc_src_pred_de_i                (pc_src_pred_de),

        // data outputs
        .instr_ex_o                      (instr_ex),
        .alu_result_ex_o                 (alu_result_ex),
        .write_data_ex_o                 (write_data_ex),
        .pc_target_ex_o                  (pc_target_ex_o),
        .pc_plus4_ex_o                   (pc_plus4_ex),
        .imm_ext_ex_o                    (imm_ext_ex),
        .pc_ex_o                         (pc_ex_o),
        .csr_result_ex_o                 (csr_result_ex),
        .csr_data_ex_o                   (csr_data_ex),
        .csr_addr_ex_o                   (csr_addr_ex_o),
        .rs1_ex_o                        (rs1_ex_o),
        .rs2_ex_o                        (rs2_ex_o),
        .rd_ex_o                         (rd_ex_o),

        // Control outputs
        .valid_ex_o                      (valid_ex),
        .funct3_ex_o                     (funct3_ex_o),
        .neg_flag_o                     (neg_flag_o),
        .zero_flag_o                    (zero_flag_o),
        .carry_flag_o                   (carry_flag_o),
        .v_flag_o                       (v_flag_o),
        .width_src_ex_o                  (width_src_ex),
        .result_src_ex_o                 (result_src_ex_o),
        .branch_op_ex_o                  (branch_op_ex_o),
        .mem_write_ex_o                  (mem_write_ex),
        .reg_write_ex_o                  (reg_write_ex),
        .csr_we_ex_o                     (csr_we_ex),
        .pc_src_pred_ex_o                (pc_src_pred_ex_o),
        .target_match_ex_o               (target_match_ex_o)
    );

    memory_stage u_memory_stage (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // data inputs
        .instr_ex_i                      (instr_ex),
        .alu_result_ex_i                 (alu_result_ex),
        .write_data_ex_i                 (write_data_ex),
        .pc_target_ex_i                  (pc_target_ex_o),
        .pc_plus4_ex_i                   (pc_plus4_ex),
        .imm_ext_ex_i                    (imm_ext_ex),
        .read_data_mem_i                  (read_data_mem_i),
        .csr_result_ex_i                 (csr_result_ex),
        .csr_data_ex_i                   (csr_data_ex),
        .csr_addr_ex_i                   (csr_addr_ex_o),
        .rd_ex_i                         (rd_ex_o),

        // Control inputs
        .valid_ex_i                      (valid_ex),
        .width_src_ex_i                  (width_src_ex),
        .result_src_ex_i                 (result_src_ex_o),
        .mem_write_ex_i                  (mem_write_ex),
        .reg_write_ex_i                  (reg_write_ex),
        .csr_we_ex_i                     (csr_we_ex),
        .stall_mem_i                      (stall_mem_i),

        // data outputs
        .instr_mem_o                      (instr_mem),
        .reduced_data_mem_o               (reduced_data_mem),
        .alu_result_mem_o                 (alu_result_mem_o),
        .write_data_mem_o                 (write_data_mem_o),
        .pc_target_mem_o                  (pc_target_mem),
        .pc_plus4_mem_o                   (pc_plus4_mem),
        .imm_ext_mem_o                    (imm_ext_mem),
        .forward_data_mem_o               (forward_data_mem),
        .csr_result_mem_o                 (csr_result_mem),
        .csr_data_mem_o                   (csr_data_mem),
        .csr_addr_mem_o                   (csr_addr_mem_o),
        .rd_mem_o                         (rd_mem_o),

        // Control outputs
        .valid_mem_o                      (valid_mem),
        .result_src_mem_o                 (result_src_mem),
        .width_src_mem_o                  (width_src_mem_o),
        .mem_write_mem_o                  (mem_write_mem_o),
        .reg_write_mem_o                  (reg_write_mem_o),
        .csr_we_mem_o                     (csr_we_mem_o)
    );

    writeback_stage u_writeback_stage (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // data inputs
        .instr_mem_i                      (instr_mem),
        .alu_result_mem_i                 (alu_result_mem_o),
        .reduced_data_mem_i               (reduced_data_mem),
        .pc_target_mem_i                  (pc_target_mem),
        .pc_plus4_mem_i                   (pc_plus4_mem),
        .imm_ext_mem_i                    (imm_ext_mem),
        .csr_result_mem_i                 (csr_result_mem),
        .csr_data_mem_i                   (csr_data_mem),
        .csr_addr_mem_i                   (csr_addr_mem_o),
        .rd_mem_i                         (rd_mem_o),

        // Control inputs
        .valid_mem_i                      (valid_mem),
        .result_src_mem_i                 (result_src_mem),
        .reg_write_mem_i                  (reg_write_mem_o),
        .csr_we_mem_i                     (csr_we_mem_o),
        .stall_wb_i                      (stall_wb_i),

        // data outputs
        .instr_wb_o                      (instr_wb),
        .result_wb_o                     (result_wb),
        .csr_result_wb_o                 (csr_result_wb),
        .csr_addr_wb_o                   (csr_addr_wb_o),
        .rd_wb_o                         (rd_wb_o),

        // Control outputs
        .valid_wb_o                      (valid_wb),
        .retire_wb_o                     (retire_wb),
        .reg_write_wb_o                  (reg_write_wb_o),
        .csr_we_wb_o                     (csr_we_wb_o)
    );

    reg_file u_reg_file (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Register addresses
        .a1_i                           (rs1_de_o),
        .a2_i                           (rs2_de_o),
        .a3_i                           (rd_wb_o),

        // Write port
        .wd3_i                          (result_wb),
        .we3_i                          (reg_write_wb_o),

        // Read ports
        .reg_data_1_o                  (reg_data_1_de),
        .reg_data_2_o                  (reg_data_2_de)
    );

    csr_regfile u_csr_regfile (
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        .csr_we_i                       (csr_we_wb_o),
        .csr_waddr_i                    (csr_addr_wb_o),
        .csr_wdata_i                    (csr_result_wb),

        .csr_raddr_i                    (csr_addr_de),
        .csr_rdata_o                    (csr_rdata_de),

        .retire_wb_i                     (retire_wb)
    );

endmodule
