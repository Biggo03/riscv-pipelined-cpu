`timescale 1ns / 1ps
`include "misc_tasks.sv"

//==============================================================//
//  Module:       write_decoder_tb
//  File:         write_decoder_tb.sv
//  Description:  Testbench for the write_decoder module.
//
//                 This testbench verifies:
//                   - One-hot enable generation
//                   - Register-index to enable decode behavior
//                   - No-spurious-bit behavior across all 32 outputs
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   None.
//
//  Notes:        Exhaustively sweeps all 5-bit register indices.
//==============================================================//
module write_decoder_tb();

    logic [4:0]  A;
    logic        WE;
    logic [31:0] en;
    int          enExpected;

    write_decoder u_DUT (
        .A                              (A),
        .WE                             (WE),
        .en                             (en)
    );


    initial begin

        dump_setup;
        WE = 1;

        for (int i = 0; i < 32; i++) begin
            A = i;
            enExpected = 2**(i);

            #10;

            assert (enExpected == en) else $fatal(1, "Error");

        end

        $display("TEST PASSED");
        $finish;

    end

endmodule
