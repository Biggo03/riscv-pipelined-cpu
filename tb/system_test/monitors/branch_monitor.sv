`include "instr_macros.sv"

module branch_monitor (
    input logic       clk_i,
    input logic       reset_i,

    input logic [1:0] branch_op_e_i,
    input logic [1:0] pc_src_i
);

    int branch_mispredictions;



endmodule
