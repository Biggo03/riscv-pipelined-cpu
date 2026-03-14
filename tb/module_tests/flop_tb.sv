`timescale 1ns / 1ps
`include "misc_tasks.sv"

//==============================================================//
//  Module:       flop_tb
//  File:         flop_tb.sv
//  Description:  Testbench for the flop module.
//
//                 This testbench verifies:
//                   - Registered propagation on clock edges
//                   - Enable-controlled hold behavior
//                   - Reset clearing behavior
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   None.
//
//  Notes:        Sequential behavior is checked with simple timed stimulus.
//==============================================================//
module flop_tb();

    logic        clk;
    logic        en;
    logic        reset;
    logic [31:0] D;
    logic [31:0] Q;

    flop u_DUT (
        .clk_i                          (clk),
        .en                             (en),
        .reset                          (reset),
        .D                              (D),
        .Q                              (Q)
    );

    initial begin

        dump_setup;

        //Initialize clock
        clk = 0;

        //Initialize register and base values
        reset = 1; en = 0; D = 1; #10; reset = 0; #10;

        //enable register
        en = 1; #10;

        //Ensure Q changes with D accordingly
        assert (Q == 1) else $fatal(1, "Propogation Error");

        D = 2; #10;
        assert (Q == 2) else $fatal(1, "Propogation Error");

        //Ensure Q does not change when register not enabled
        en = 0; #10;

        D = 4; #10;
        assert (Q == 2) else $fatal(1, "enable Error");

        //Ensure reset works properly (synchronous)
        reset = 1; #10;
        assert (Q == 0) else $fatal(1, "reset Error");

        $display("TEST PASSED");
        $finish;
    end


    //Generate clock signal
    always begin
        #5; clk = ~clk;
    end

endmodule
