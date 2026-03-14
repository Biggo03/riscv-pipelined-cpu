`timescale 1ns / 1ps
`include "misc_tasks.sv"
`include "control_macros.sv"
`include "tb_macros.sv"

//==============================================================//
//  Module:       imm_extend_tb
//  File:         imm_extend_tb.sv
//  Description:  Testbench for the imm_extend module.
//
//                 This testbench verifies:
//                   - Immediate extension from regression vectors
//                   - Sign and zero extension behavior by immediate source
//                   - CSR immediate expansion behavior
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   None.
//
//  Notes:        Uses vector-driven checks plus a direct CSR-immediate case.
//==============================================================//
module imm_extend_tb();

    logic [31:7] instr;
    logic [2:0]  imm_src;
    logic [31:0] imm_ext;
    logic [31:0] ImmExtExpected;

    int error_cnt;

    int file;
    int read;
    int test_num;

    imm_extend u_DUT (
        .instr_i                        (instr),
        .imm_src_i                      (imm_src),
        .imm_ext_o                      (imm_ext)
    );

    initial begin

        dump_setup;

        read = 0;

        file = $fopen("test_inputs/vectors/ext_unit_test_vectors.txt", "r");

        if (file == 0) begin
            $fatal(1, "ERROR: Could not open test vector file");
        end else begin
            $display("Vector file opened succesfully");
        end


        //Iterate through file
        while (!$feof(file)) begin
            read = $fscanf(file, "%b %b %b\n", instr, imm_src, ImmExtExpected);

            //Ensure file reads correct number of elements
            if (read == 3) begin
                #1;
                assert (imm_ext == ImmExtExpected) else begin
                    $fatal(1, "Error: imm_src = %b, instr = %b\nExpected output: %b\nActual output:   %b",
                       imm_src, instr, ImmExtExpected,imm_ext);
                end

            end else begin
                $fatal(1, "Incorrect number of elements read");
            end

        end

        instr[19:15] = 5'b11010;
        imm_src = `CSR_EXT;
        $display("imm_src: %b", imm_src);
        #1;
        $display("imm_ext: %b", imm_ext);

        `CHECK(imm_ext == {27'b0, 5'b11010}, "CSR extension failed");

        $display("TEST PASSED");
        $fclose(file);
        $finish;

    end


endmodule
