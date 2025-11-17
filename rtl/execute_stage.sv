`timescale 1ns / 1ps
//==============================================================//
//  Module:       execute_stage
//  File:         execute_stage.sv
//  Description:  All logic contained within the Execute pipeline stage, along with its pipeline register.
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

module execute_stage (
    // Clock & reset_i
    input  logic        clk_i,
    input  logic        reset_i,

    // Data inputs
    input  logic [31:0] instr_de_i,
    input  logic [31:0] reg_data_1_de_i,
    input  logic [31:0] reg_data_2_de_i,
    input  logic [31:0] csr_result_mem_i,
    input  logic [31:0] csr_result_wb_i,
    input  logic [31:0] result_wb_i,
    input  logic [31:0] forward_data_mem_i,
    input  logic [31:0] pc_de_i,
    input  logic [31:0] pc_plus4_de_i,
    input  logic [31:0] imm_ext_de_i,
    input  logic [31:0] pred_pc_target_de_i,
    input  logic [31:0] csr_rdata_de_i,
    input  logic [11:0] csr_addr_de_i,
    input  logic [4:0]  rd_de_i,
    input  logic [4:0]  rs1_de_i,
    input  logic [4:0]  rs2_de_i,

    // Control inputs
    input  logic        valid_de_i,
    input  logic [2:0]  funct3_de_i,
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
    input  logic [1:0]  forward_a_ex_i,
    input  logic [1:0]  forward_b_ex_i,
    input  logic [1:0]  forward_csr_ex_i,
    input  logic        flush_ex_i,
    input  logic        stall_ex_i,
    input  logic        pc_src_pred_de_i,

    // Data outputs
    output logic [31:0] instr_ex_o,
    output logic [31:0] alu_result_ex_o,
    output logic [31:0] write_data_ex_o,
    output logic [31:0] pc_target_ex_o,
    output logic [31:0] pc_plus4_ex_o,
    output logic [31:0] imm_ext_ex_o,
    output logic [31:0] pc_ex_o,
    output logic [31:0] csr_result_ex_o,
    output logic [31:0] csr_data_ex_o,
    output logic [11:0] csr_addr_ex_o,
    output logic [4:0]  rs1_ex_o,
    output logic [4:0]  rs2_ex_o,
    output logic [4:0]  rd_ex_o,
    output logic [2:0]  funct3_ex_o,
    output logic        neg_flag_o,
    output logic        zero_flag_o,
    output logic        carry_flag_o,
    output logic        v_flag_o,

    // Control outputs
    output logic        valid_ex_o,
    output logic [2:0]  width_src_ex_o,
    output logic [2:0]  result_src_ex_o,
    output logic [1:0]  branch_op_ex_o,
    output logic        mem_write_ex_o,
    output logic        reg_write_ex_o,
    output logic        csr_we_ex_o,
    output logic        pc_src_pred_ex_o,
    output logic        target_match_ex_o
);

    // ----- Pipeline data types -----
    typedef struct packed {
        logic [31:0] pc;
        logic [31:0] instr;
        logic        valid;
    } ex_meta_t;

    typedef struct packed {
        logic [2:0]  funct3;
        logic [3:0]  alu_control;
        logic        alu_src;
        logic [2:0]  result_src;
        logic [2:0]  width_src;
        logic [1:0]  branch_op;
        logic        pc_base_src;
        logic        pc_src_pred;
        logic        mem_write;
        logic        reg_write;
        logic [1:0]  csr_control;
        logic        csr_we;
        logic        csr_src;
    } ex_control_t;

    typedef struct packed {
        logic [4:0]  rd;
        logic [4:0]  rs1;
        logic [4:0]  rs2;
        logic [31:0] reg_data_1;
        logic [31:0] reg_data_2;
        logic [31:0] imm_ext;
        logic [31:0] pc_plus4;
        logic [31:0] pred_pc_target;
        logic [11:0] csr_addr;
        logic [31:0] csr_data;
    } ex_data_t;

    typedef struct packed {
        ex_meta_t    meta;
        ex_control_t control;
        ex_data_t    data;
    } ex_bundle_t;

    // ----- Parameters -----
    localparam REG_WIDTH = $bits(ex_bundle_t);

    // ----- Execute pipeline register -----
    ex_bundle_t inputs_ex;
    ex_bundle_t outputs_ex;

    // ----- Execute stage outputs -----
    logic [31:0] reg_data_1_ex;
    logic [31:0] reg_data_2_ex;
    logic [31:0] pred_pc_target_ex;
    logic [3:0]  alu_control_ex;
    logic [1:0]  csr_control_ex;
    logic        csr_src_ex;
    logic        pc_base_src_ex;
    logic        alu_src_ex;

    // ----- Execute stage intermediates -----
    logic [31:0] src_a_ex;
    logic [31:0] src_b_ex;
    logic [31:0] pc_base_ex;
    logic [31:0] csr_op_a_ex;
    logic [31:0] csr_rdata_ex;

    assign inputs_ex = {
        // Meta Signals
        pc_de_i,
        instr_de_i,
        valid_de_i,

        // Control Signals
        funct3_de_i,
        alu_control_de_i,
        alu_src_de_i,
        result_src_de_i,
        width_src_de_i,
        branch_op_de_i,
        pc_base_src_de_i,
        pc_src_pred_de_i,
        mem_write_de_i,
        reg_write_de_i,
        csr_control_de_i,
        csr_we_de_i,
        csr_src_de_i,

        // Data Signals
        rd_de_i,
        rs1_de_i,
        rs2_de_i,
        reg_data_1_de_i,
        reg_data_2_de_i,
        imm_ext_de_i,
        pc_plus4_de_i,
        pred_pc_target_de_i,
        csr_addr_de_i,
        csr_rdata_de_i
    };

    flop #(
        .WIDTH                          (REG_WIDTH)
    ) u_execute_reg (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .en                             (~stall_ex_i),
        .reset                          (reset_i | flush_ex_i),

        // data input
        .D                              (inputs_ex),

        // data output
        .Q                              (outputs_ex)
    );

    assign {
        // Meta Signals
        pc_ex_o,
        instr_ex_o,
        valid_ex_o,

        // Control Signals
        funct3_ex_o,
        alu_control_ex,
        alu_src_ex,
        result_src_ex_o,
        width_src_ex_o,
        branch_op_ex_o,
        pc_base_src_ex,
        pc_src_pred_ex_o,
        mem_write_ex_o,
        reg_write_ex_o,
        csr_control_ex,
        csr_we_ex_o,
        csr_src_ex,

        // Data Signals
        rd_ex_o,
        rs1_ex_o,
        rs2_ex_o,
        reg_data_1_ex,
        reg_data_2_ex,
        imm_ext_ex_o,
        pc_plus4_ex_o,
        pred_pc_target_ex,
        csr_addr_ex_o,
        csr_rdata_ex
    } = outputs_ex;

   // Check Branch Prediction
    always_comb begin
        if (pc_target_ex_o == pred_pc_target_ex) target_match_ex_o = 1;
        else                                   target_match_ex_o = 0;
    end

    // Multiplexer Logic
    always_comb begin : ex_multiplexers
        // a forward mux
        case (forward_a_ex_i)
            `NO_FORWARD:     src_a_ex = reg_data_1_ex;
            `WB_FORWARD:     src_a_ex = result_wb_i;
            `MEM_FORWARD:    src_a_ex = forward_data_mem_i;
            default:         src_a_ex = 0;
        endcase

        // b forward mux
        case (forward_b_ex_i)
            `NO_FORWARD:     write_data_ex_o = reg_data_2_ex;
            `WB_FORWARD:     write_data_ex_o = result_wb_i;
            `MEM_FORWARD:    write_data_ex_o = forward_data_mem_i;
            default:         write_data_ex_o = 0;
        endcase

        // csr_forward_mux
        case (forward_csr_ex_i)
            `NO_FORWARD:     csr_data_ex_o = csr_rdata_de_i;
            `WB_FORWARD:     csr_data_ex_o = csr_result_wb_i;
            `MEM_FORWARD:    csr_data_ex_o = csr_result_mem_i;
            default:         csr_data_ex_o = 0;
        endcase

        // csr mux
        case (csr_src_ex)
            `CSR_SRC_REG: csr_op_a_ex = src_a_ex;
            `CSR_SRC_IMM: csr_op_a_ex = imm_ext_ex_o;
            default:      csr_op_a_ex = 0;
        endcase

        //src b mux
        case (alu_src_ex)
            `ALU_SRC_WD:     src_b_ex = write_data_ex_o;
            `ALU_SRC_IMM:    src_b_ex = imm_ext_ex_o;
            default:         src_b_ex = 0;
        endcase

        // pc_target mux
        case (pc_base_src_ex)
            `PC_BASE_PC:     pc_base_ex = pc_ex_o;
            `PC_BASE_SRCA:   pc_base_ex = src_a_ex;
            default:         pc_base_ex = 0;
        endcase
    end

    //Arithmetic units:
    alu u_alu (
        // Control inputs
        .alu_control_i                  (alu_control_ex),

        // data inputs
        .A                              (src_a_ex),
        .B                              (src_b_ex),

        // data outputs
        .alu_result_o                   (alu_result_ex_o),

        // Status flag outputs
        .neg_flag_o                     (neg_flag_o),
        .zero_flag_o                    (zero_flag_o),
        .carry_flag_o                   (carry_flag_o),
        .v_flag_o                       (v_flag_o)
    );

    csr_alu u_csr_alu (
        .csr_control_i                  (csr_control_ex),

        .csr_op_a_i                     (csr_op_a_ex),
        .csr_data_i                     (csr_data_ex_o),

        .csr_result_o                   (csr_result_ex_o)
    );

    adder u_pc_target_adder (
        // data inputs
        .a                              (pc_base_ex),
        .b                              (imm_ext_ex_o),

        // data output
        .y                              (pc_target_ex_o)
    );

endmodule
