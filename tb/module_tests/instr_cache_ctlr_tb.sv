`timescale 1ns / 1ps
`include "misc_tasks.sv"

//==============================================================//
//  Module:       instr_cache_ctlr_tb
//  File:         instr_cache_ctlr_tb.sv
//  Description:  Testbench for the instr_cache_ctlr module.
//
//                 This testbench verifies:
//                   - Active-set decode from the selected set index
//                   - Instruction hit indication from miss-array inputs
//                   - FSM behavior for branch hit, miss, and misprediction cases
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   None.
//
//  Notes:        Checks the DUT FSM state through the internal present_state signal.
//==============================================================//
module instr_cache_ctlr_tb();

    logic [5:0]  set;
    logic [63:0] miss_array;
    logic [63:0] active_array;
    logic        instr_hit_f;

    logic        clk;
    logic        reset;
    logic        branch_cache_miss;
    logic [1:0]  branch_op_e;
    logic        ic_repl_permit;

    instr_cache_ctlr u_DUT (
        .clk_i                          (clk),
        .reset_i                        (reset),
        .set_i                          (set),
        .miss_array_i                   (miss_array),
        .branch_cache_miss_i            (branch_cache_miss),
        .branch_op_ex_i                 (branch_op_e),
        .active_array_o                 (active_array),
        .instr_hit_fi_o                 (instr_hit_f),
        .ic_repl_permit_o               (ic_repl_permit)
    );

    always #5 clk = ~clk;

    task tick();
        @(posedge clk);
        #1;
    endtask

    initial begin
        dump_setup;
        clk = 0;
        reset = 1;
        branch_cache_miss = 0;
        branch_op_e = `NON_BRANCH;
        set = 0;
        miss_array = 64'h0123456789ABCDEF;

        // Check every set, including the most significant active-array bit.
        for (int i = 0; i < 64; i++) begin
            set = i;
            #1;
            assert(active_array === (64'b1 << i)) else $fatal(1, "Incorrect active array");
            assert(instr_hit_f === ~miss_array[i]) else $fatal(1, "Incorrect cache hit value");
            assert(!ic_repl_permit) else $fatal(1, "Replacement allowed during reset");
        end
        tick();
        @(negedge clk);
        reset = 0;
        miss_array = 0;
        #1;
        assert(ic_repl_permit && u_DUT.present_state == 0)
            else $fatal(1, "Non-branch hit must permit replacement");

        miss_array = '1;
        tick();
        assert(ic_repl_permit && u_DUT.present_state == 0)
            else $fatal(1, "Non-branch miss must not introduce a delay");

        // Hits no longer grant permission; they also must not start the delay.
        @(negedge clk);
        miss_array = 0;
        branch_op_e = `BRANCH;
        repeat (3) begin
            tick();
            assert(!ic_repl_permit && u_DUT.present_state == 0)
                else $fatal(1, "Branch hit must remain ready without permission");
        end

        // One blocked cycle, then continuous permission with the branch held.
        @(negedge clk);
        miss_array = '1;
        #1;
        assert(!ic_repl_permit && u_DUT.present_state == 0)
            else $fatal(1, "Branch miss must initially delay replacement");
        tick();
        repeat (10) begin
            assert(ic_repl_permit && u_DUT.present_state == 1)
                else $fatal(1, "Completed delay must continuously permit replacement");
            tick();
        end

        // The redirect pulse overrides completed delay and rearms the FSM.
        @(negedge clk);
        branch_cache_miss = 1;
        #1;
        assert(!ic_repl_permit) else $fatal(1, "Recovery pulse must block replacement");
        tick();
        assert(u_DUT.present_state == 0) else $fatal(1, "Recovery must rearm delay");
        @(negedge clk);
        branch_cache_miss = 0;
        #1;
        assert(!ic_repl_permit) else $fatal(1, "New address must receive its branch delay");
        tick();
        assert(ic_repl_permit && u_DUT.present_state == 1)
            else $fatal(1, "Replacement must resume after the new delay");

        // A hit rearms a completed delay without relying on recovery.
        @(negedge clk);
        miss_array = 0;
        tick();
        assert(u_DUT.present_state == 0 && !ic_repl_permit)
            else $fatal(1, "Hit must rearm delay");

        // A pulse on a hit must not start the delay from READY_TO_DELAY.
        @(negedge clk);
        branch_cache_miss = 1;
        tick();
        assert(u_DUT.present_state == 0 && !ic_repl_permit)
            else $fatal(1, "Pulse on a hit must remain ready");
        @(negedge clk);
        branch_cache_miss = 0;
        branch_op_e = `NON_BRANCH;
        #1;
        assert(ic_repl_permit) else $fatal(1, "Permission did not resume after pulse");

        $display("TEST PASSED");
        $finish;
    end
endmodule
