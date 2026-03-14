`timescale 1ns / 1ps
`include "misc_tasks.sv"

//==============================================================//
//  Module:       instr_mem_tb
//  File:         instr_mem_tb.sv
//  Description:  Testbench for the instr_mem module.
//
//                 This testbench verifies:
//                   - Instruction readback against a reference memory image
//                   - Instruction-hit status behavior
//                   - Replacement-permit status behavior
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   None.
//
//  Notes:        Loads the same program image into the testbench for comparison.
//==============================================================//
module instr_mem_tb();

    // Stimulus, output
    logic [31:0] pc_f;
    logic [31:0] instr_f;

    // Copy of memory to compare against
    logic [31:0] RAM [127:0];

    // Instantiate DUT
    instr_mem u_DUT (
        // Address & data inputs
        .addr                           (pc_f),

        // data outputs
        .rd_o                           (instr_f),

        // Status outputs
        .instr_hit_f_o                  (instr_hit_f),
        .ic_repl_permit_o               (ic_repl_permit)
    );

    initial begin

        dump_setup;

        //Read file containing expected contents
        $readmemh("test_inputs/riscvprograms/riscvprogram_7.txt", RAM);

        for (int i = 0; i < 64; i++) begin
            pc_f = (i * 4);

            #10;

            assert (instr_f === RAM[i]) else $fatal(1, "Error");
            assert (instr_hit_f === 1'b1) else $fatal(1, "Error");
            assert (ic_repl_permit === 1'b1) else $fatal(1, "Error");

        end

        $display("TEST PASSED");
        $finish;

    end

endmodule
