`timescale 1ns / 1ps
//==============================================================//
//  Module:       csr_decoder
//  File:         csr_decoder.sv
//  Description:  performs decoding for the csr_control signal
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
`include "instr_macros.sv"

module csr_decoder (
    input  logic [2:0] funct3_i,

    output logic [1:0] csr_control_o,
    output logic       csr_src_o
);

    always_comb begin
        casez(funct3_i)
            3'b?01:      csr_control_o = `CSR_PASS;
            3'b?10:      csr_control_o = `CSR_SET;
            3'b?11:      csr_control_o = `CSR_CLEAR;
            default:     csr_control_o = `CSR_NA;
        endcase

        casez(funct3_i)
            3'b0??:       csr_src_o = `CSR_SRC_REG;
            3'b1??:       csr_src_o = `CSR_SRC_IMM;
            default:      csr_src_o = `CSR_SRC_NA;
        endcase
    end

endmodule
