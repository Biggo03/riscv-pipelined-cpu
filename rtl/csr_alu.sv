`timescale 1ns / 1ps
//==============================================================//
//  Module:       csr_alu
//  File:         csr_alu.sv
//  Description:  performs csr related arithmetic operations
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:  WIDTH: The width of the operands
//
//  Notes:        N/A
//==============================================================//
`include "control_macros.sv"

module csr_alu #(
    parameter int WIDTH = 32
) (
    // Control inputs
    input  logic [1:0] csr_control_i,

    // Data inputs
    input  logic [WIDTH-1:0] csr_op_a_i, //rs1 or immediate data
    input  logic [WIDTH-1:0] csr_data_i, // csr data

    // Data output
    output logic [WIDTH-1:0] csr_result_o
);

    always_comb begin
        case(csr_control_i)
             `CSR_SET:      csr_result_o = csr_op_a_i | csr_data_i;
             `CSR_CLEAR:    csr_result_o = ~(csr_op_a_i) & csr_data_i;
             `CSR_PASS:     csr_result_o = csr_op_a_i;
             default:       csr_result_o = 0;
        endcase
    end

endmodule
