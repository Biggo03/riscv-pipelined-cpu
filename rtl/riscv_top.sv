`timescale 1ns / 1ps
//==============================================================//
//  Module:       riscv_top
//  File:         riscv_top.sv
//  Description:  Instantiation of all modules involved in the system
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        N/A
//==============================================================//

module riscv_top (
    // Clock & reset_i
    (* keep = "true" *) input  logic        clk_i,
    (* keep = "true" *) input  logic        reset_i,

    // Memory outputs
    (* keep = "true" *) output logic [31:0] write_data_mem_o,
    (* keep = "true" *) output logic [31:0] alu_result_mem_o,
    (* keep = "true" *) output logic        mem_write_mem_o
);

    // ----- Pipeline signals -----
    (* keep = "true" *) logic [31:0] pc_fi;
    (* keep = "true" *) logic [31:0] instr_fi;
    (* keep = "true" *) logic [31:0] read_data_mem;
    (* keep = "true" *) logic [2:0]  width_src_mem;

    // ----- Cache control -----
    (* keep = "true" *) logic        instr_hit_fi;
    (* keep = "true" *) logic        ic_repl_permit;
    (* keep = "true" *) logic        l2_repl_ready;
    (* keep = "true" *) logic [63:0] rep_word;

    // ----- Branch/control -----
    (* keep = "true" *) logic [1:0]  pc_src_reg;
    (* keep = "true" *) logic [1:0]  branch_op_ex;

    pipelined_riscv_core u_pipelined_riscv_core (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Instruction fetch inputs
        .instr_fi_i                      (instr_fi),
        .instr_hit_fi_i                  (instr_hit_fi),
        .ic_repl_permit_i               (ic_repl_permit),

        // Memory inputs
        .read_data_mem_i                  (read_data_mem),

        // pc outputs
        .pc_fi_o                         (pc_fi),

        // ALU & memory outputs
        .alu_result_mem_o                 (alu_result_mem_o),
        .write_data_mem_o                 (write_data_mem_o),

        // Control outputs
        .width_src_mem_o                  (width_src_mem),
        .branch_op_ex_o                  (branch_op_ex),
        .pc_src_reg_o                   (pc_src_reg),
        .mem_write_mem_o                  (mem_write_mem_o)
    );

`ifndef NO_ICACHE
    icache_l1 #( // u_icache_l1 (
        .S                              (32),
        .E                              (4),
        .B                              (64)
    ) u_icache_l1 (
        // Clock & reset_i
        .clk_i                          (clk_i),
        .reset_i                        (reset_i),

        // Control inputs
        .l2_repl_ready_i                (l2_repl_ready),
        .pc_src_reg_i                   (pc_src_reg),
        .branch_op_ex_i                  (branch_op_ex),

        // Address & data inputs
        .pc_fi_i                         (pc_fi),
        .rep_word_i                     (rep_word),

        // data outputs
        .instr_fi_o                      (instr_fi),

        // Status outputs
        .instr_hit_fi_o                  (instr_hit_fi),
        .ic_repl_permit_o               (ic_repl_permit)
    );

    `ifdef SIM
        main_mem_model u_main_mem (
            .clk_i                          (clk_i),
            .reset_i                        (reset_i),

            .addr_i                         (pc_fi),
            .ic_repl_permit_i               (ic_repl_permit),
            .cache_hit_i                    (instr_hit_fi),

            .rep_ready_o                    (l2_repl_ready),
            .rep_word_o                     (rep_word)
        );
    `endif

`else
    instr_mem u_instr_mem (
        // Address & data inputs
        .addr                           (pc_fi),

        // data outputs
        .rd_o                           (instr_fi),

        // Status outputs
        .instr_hit_fi_o                  (instr_hit_fi),
        .ic_repl_permit_o               (ic_repl_permit)
    );
`endif

    data_mem u_data_mem (
        // Clock & control inputs
        .clk_i                          (clk_i),
        .WE                             (mem_write_mem_o),
        .width_src                      (width_src_mem),

        // Address & write data inputs
        .A                              (alu_result_mem_o),
        .WD                             (write_data_mem_o),

        // Read data output
        .RD                             (read_data_mem)
    );

endmodule
