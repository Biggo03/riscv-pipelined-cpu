`timescale 1ns / 1ps
`include "misc_tasks.sv"

//==============================================================//
//  Module:       reduce_tb
//  File:         reduce_tb.sv
//  Description:  Testbench for the reduce module.
//
//                 This testbench verifies:
//                   - Width-based result reduction from regression vectors
//                   - Truncation behavior across supported widths
//                   - Representative vector-file regression coverage
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   None.
//
//  Notes:        Uses an external test vector file for expected outputs.
//==============================================================//
module reduce_tb();

    logic [31:0] BaseResult;
    logic [2:0]  width_src;
    logic [31:0] result;
    logic [31:0] ResultExpected;

    int file;
    int read;
    int test_num;

    reduce u_DUT (
        .BaseResult                     (BaseResult),
        .width_src_i                    (width_src),
        .result_o                       (result)
    );

    initial begin

        dump_setup;

        read = 0;

        file = $fopen("test_inputs/vectors/reduce_test_vectors.txt", "r");

        if (file == 0) begin
            $fatal(1, "ERROR: Could not open test vector file");
        end else begin
            $display("Vector file opened succesfully");
        end


        //Iterate through file
        while (!$feof(file)) begin
            read = $fscanf(file, "%b %b %b\n", BaseResult, width_src, ResultExpected);

            //Ensure file reads correct number of elements
            if (read == 3) begin
                #1;
                assert (result == ResultExpected) else begin
                    $fatal(1, "Error: width_src = %b, BaseResult = %b\nExpected output: %b\nActual output:   %b",
                       width_src, BaseResult, ResultExpected, result);
                end

            end else begin
                $fatal(1, "Incorrect number of elements read");
            end

        end


        $display("TEST PASSED");
        $fclose(file);

        $finish;



    end


endmodule
