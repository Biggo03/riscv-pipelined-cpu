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
        case(funct3_i[1:0])
            2'b01:      csr_control_o = `CSR_PASS;
            2'b10:      csr_control_o = `CSR_SET;
            2'b11:      csr_control_o = `CSR_CLEAR;
            default:    csr_control_o = `CSR_NA;
        endcase

        case(funct3_i[2])
            1'b0:       csr_src_o = `CSR_SRC_REG;
            1'b1:       csr_src_o = `CSR_SRC_IMM;
            default:    csr_src_o = `CSR_SRC_NA;
        endcase
    end

endmodule
