`timescale 1ns / 1ps
`include "misc_tasks.sv"
`include "tb_macros.sv"

//==============================================================//
//  Module:       hazard_unit_tb
//  File:         hazard_unit_tb.sv
//  Description:  Testbench for the hazard_unit module.
//
//                 This testbench verifies:
//                   - Execute-stage forwarding decisions
//                   - Load-use stall and flush behavior
//                   - Cache-miss and branch-mispredict interaction cases
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   None.
//
//  Notes:        Checks a single recovery pulse while EX is held through a long miss.
//==============================================================//
module hazard_unit_tb();

    // ---------------------------------------------------
    // Stimulus signals
    // ---------------------------------------------------
    logic clk = 0;
    logic reset;
    logic branch_cache_miss;

    always #5 clk = ~clk;

    // Fetch stage inputs
    logic       instr_hit_f;

    // Decode stage inputs
    logic [4:0] rs1_d;
    logic [4:0] rs2_d;

    // Execute stage inputs
    logic [4:0] rs1_e;
    logic [4:0] rs2_e;
    logic [4:0] rd_e;
    logic [11:0] csr_addr_e;
    logic [2:0] result_src_e;
    logic [1:0] pc_src;

    // Memory stage inputs
    logic [4:0] rd_m;
    logic       reg_write_m;
    logic [11:0] csr_addr_m;
    logic       csr_we_m;

    // Writeback stage inputs
    logic [4:0] rd_w;
    logic       reg_write_w;
    logic [11:0] csr_addr_w;
    logic       csr_we_w;

    // stall outputs
    logic       stall_f;
    logic       stall_d;
    logic       stall_e;
    logic       stall_m;
    logic       stall_w;

    // flush outputs
    logic       flush_d;
    logic       flush_e;

    // Forwarding outputs
    logic [1:0] forward_a_e;
    logic [1:0] forward_b_e;

    // ---------------------------------------------------
    // Expected results
    // ---------------------------------------------------
    logic [1:0] ForwardExpectedA;
    logic [1:0] ForwardExpectedB;

    int error_cnt;

    // ---------------------------------------------------
    // DUT instantiation
    // ---------------------------------------------------
    hazard_unit u_DUT (
        .clk_i                          (clk),
        .reset_i                        (reset),
        .branch_cache_miss_o            (branch_cache_miss),

        // Fetch stage inputs
        .instr_hit_fi_i                 (instr_hit_f),

        // Decode stage inputs
        .rs1_de_i                       (rs1_d),
        .rs2_de_i                       (rs2_d),

        // Execute stage inputs
        .rs1_ex_i                       (rs1_e),
        .rs2_ex_i                       (rs2_e),
        .rd_ex_i                        (rd_e),
        .csr_addr_ex_i                  (csr_addr_e),
        .result_src_ex_i                (result_src_e),
        .pc_src_i                       (pc_src),

        // Memory stage inputs
        .rd_mem_i                       (rd_m),
        .reg_write_mem_i                (reg_write_m),
        .csr_addr_mem_i                 (csr_addr_m),
        .csr_we_mem_i                   (csr_we_m),

        // Writeback stage inputs
        .rd_wb_i                        (rd_w),
        .reg_write_wb_i                 (reg_write_w),
        .csr_addr_wb_i                  (csr_addr_w),
        .csr_we_wb_i                    (csr_we_w),

        // stall outputs
        .stall_fi_o                     (stall_f),
        .stall_de_o                     (stall_d),
        .stall_ex_o                     (stall_e),
        .stall_mem_o                    (stall_m),
        .stall_wb_o                     (stall_w),

        // flush outputs
        .flush_de_o                     (flush_d),
        .flush_ex_o                     (flush_e),

        // Forwarding outputs
        .forward_a_ex_o                 (forward_a_e),
        .forward_b_ex_o                 (forward_b_e),
        .forward_csr_ex_o               ()
    );

    //Parameters to consolidate signal values
    localparam [1:0] NO_FORWARD = 2'b00;
    localparam [1:0] WB_FORWARD = 2'b01;
    localparam [1:0] MEM_FORWARD = 2'b10;


    task AssertForwardA();
        assert (ForwardExpectedA === forward_a_e) else $error(1, "Error: ForwardingAE doesn't match expected\nRs1E: %b, rd_m: %b, rd_w: %b, reg_write_m: %b reg_write_w: %b\nExpected Output: %b\nActual Output:   %b",
                                                              rs1_e, rd_m, rd_w, reg_write_m, reg_write_w, ForwardExpectedA, forward_a_e);

    endtask

    //Asserts correct outputs when checking functionality of forward_b_e
    task AssertForwardB();

        assert (ForwardExpectedB === forward_b_e) else $error(1, "Error: ForwardingAE doesn't match expected\nRs1E: %b, rd_m: %b, rd_w: %b, reg_write_m: %b reg_write_w: %b\nExpected Output: %b\nActual Output:   %b",
                                                              rs1_e, rd_m, rd_w, reg_write_m, reg_write_w, ForwardExpectedB, forward_b_e);
    endtask

    initial begin

        dump_setup;

        //Initial values
        reset = 1;
        error_cnt = 0;
        instr_hit_f = 1;
        rs1_d = 0;
        rs2_d = 0;
        rs1_e = 0;
        rs2_e = 0;
        rd_e = 0;
        csr_addr_e = 0;
        result_src_e = 0;
        pc_src = 0;
        rd_m = 0;
        reg_write_m = 0;
        csr_addr_m = 0;
        csr_we_m = 0;
        rd_w = 0;
        reg_write_w = 0;
        csr_addr_w = 0;
        csr_we_w = 0;
        #10;
        reset = 0;

        //Test all register combinations for ForwrdAE and forward_b_e
        for (int i = 0; i < 64; i++) begin

            //Do this so can test both types of forwarding
            if (i < 32) rd_m = i;
            else rd_w = i-32;

            for (int j = 0; j < 32; j++) begin

                rs1_e = j;
                rs2_e = j;

                //Test ForwardExpectedAE
                if (rs1_e === 0) ForwardExpectedA = NO_FORWARD;
                else if (rs1_e === rd_m & reg_write_m) ForwardExpectedA = MEM_FORWARD;
                else if (rs1_e === rd_w & reg_write_w) ForwardExpectedA = WB_FORWARD;
                else ForwardExpectedA = NO_FORWARD;

                #10;

                AssertForwardA();

                //Test ForwardExpectedBE
                if (rs2_e === 0) ForwardExpectedB = NO_FORWARD;
                else if (rs2_e === rd_m & reg_write_m) ForwardExpectedB = MEM_FORWARD;
                else if (rs2_e === rd_w & reg_write_w) ForwardExpectedB = WB_FORWARD;
                else ForwardExpectedB = NO_FORWARD;

                #10;

                AssertForwardB();

            end

        end

        $display("Forwarding Successful!");

        drive_no_hazard();
        expect_no_hazard();

        result_src_e = `RESULT_MEM_DATA;
        rs1_d = 1;
        rd_e = 1;
        #1;
        expect_load_hazard("rs1 Hazard Case");
        drive_no_hazard();

        result_src_e = `RESULT_MEM_DATA;
        rs2_d = 2;
        rd_e = 2;
        #1;
        expect_load_hazard("rs2 Hazard Case");
        drive_no_hazard();

        instr_hit_f = 0;
        #1;
        expect_cache_miss();
        pc_src = `PC_SRC_PRED_F;
        repeat (3) begin
            tick();
            assert(!branch_cache_miss && !flush_e && stall_f && stall_e && stall_m)
                else $fatal(1, "Correct prediction must not trigger branch recovery");
        end
        drive_no_hazard();

        // A cache hit flushes EX immediately, independently of cache permission.
        pc_src = `PC_SRC_TARGET_E;
        #1;
        expect_cache_hit_branch_miss();
        tick();
        assert(branch_cache_miss === 0)
            else $fatal(1, "Cache-hit redirect must not generate a recovery pulse");

        // The redirected target misses: fetch must hold its first instruction.
        @(negedge clk);
        pc_src = `PC_SRC_SEQ_F;
        instr_hit_f = 0;
        #1;
        assert(!branch_cache_miss && stall_f && stall_e && stall_m && !flush_e)
            else $fatal(1, "Cold target must stall fetch after a cache-hit redirect");
        tick();
        assert(!branch_cache_miss && stall_f)
            else $fatal(1, "Unexpected recovery pulse skipped a cold target");
        drive_no_hazard();
        tick();
        assert(branch_cache_miss === 0) else $fatal(1, "Branch pulse did not clear");

        // Keep the same mispredicted JALR in EX throughout a long miss.
        @(negedge clk);
        instr_hit_f = 0;
        pc_src = `PC_SRC_TARGET_E;
        #1;
        assert(stall_f && stall_e && stall_m && !flush_e)
            else $fatal(1, "EX must hold on initial branch/cache overlap");
        tick();
        assert(branch_cache_miss && !stall_f && stall_e && stall_m && !flush_e)
            else $fatal(1, "Redirect pulse must release only fetch, preserving EX");
        tick();
        repeat (8) begin
            assert(!branch_cache_miss && stall_f && stall_e && stall_m && !flush_e)
                else $fatal(1, "Held branch retriggered recovery or lost EX data");
            tick();
        end

        // Replacement completes: MEM can accept JALR and EX may be flushed.
        @(negedge clk);
        instr_hit_f = 1;
        #1;
        assert(!stall_m && flush_e && !branch_cache_miss)
            else $fatal(1, "JALR must advance before EX is cleared");
        tick();
        drive_no_hazard();
        tick();

        // A later branch must be able to generate a fresh pulse.
        @(negedge clk);
        instr_hit_f = 0;
        pc_src = `PC_SRC_SEQ_E;
        tick();
        assert(branch_cache_miss) else $fatal(1, "Recovery did not rearm for a new branch");
        @(negedge clk);
        reset = 1;
        tick();
        assert(!branch_cache_miss) else $fatal(1, "Reset must clear recovery pulse");
        @(negedge clk);
        pc_src = 0;
        reset = 0;
        tick();
        assert(!branch_cache_miss) else $fatal(1, "Unexpected pulse following reset");

        if (error_cnt != 0) $fatal(1, "Hazard checks failed: %0d", error_cnt);
        $display("TEST PASSED");
        $finish;
    end

    task tick();
        @(posedge clk);
        #1;
    endtask

    task drive_no_hazard();
        @(negedge clk);
        result_src_e = 0;
        rs1_d = 0;
        rs2_d = 0;
        rd_e = 1;
        instr_hit_f = 1;
        pc_src = 0;
        #1;
    endtask

    //Expect tasks
    task expect_no_hazard();
        `CHECK(stall_f == 0, "[%t] No hazard case: stall_f should be 0", $time)
        `CHECK(stall_d == 0, "[%t] No hazard case: stall_d should be 0", $time)
        `CHECK(stall_e == 0, "[%t] No hazard case: stall_e should be 0", $time)
        `CHECK(stall_m == 0, "[%t] No hazard case: stall_m should be 0", $time)
        `CHECK(stall_w == 0, "[%t] No hazard case: stall_w should be 0", $time)

        `CHECK(flush_d == 0, "[%t] No hazard case: flush_d should be 0", $time)
        `CHECK(flush_e == 0, "[%t] No hazard case: flush_e should be 0", $time)
    endtask

    task expect_load_hazard(input string variant);
        `CHECK(stall_f == 1, "[%t] %s: stall_f should be 1", $time, variant)
        `CHECK(stall_d == 1, "[%t] %s: stall_d should be 1", $time, variant)

        `CHECK(flush_e == 1, "[%t] %s: flush_e should be 1", $time, variant)
    endtask

    task expect_cache_miss();
        `CHECK(stall_f == 1, "[%t] Cache Miss Case: stall_f should be 1", $time)
        `CHECK(stall_d == 1, "[%t] Cache Miss Case: stall_d should be 1", $time)
        `CHECK(stall_e == 1, "[%t] Cache Miss Case: stall_e should be 1", $time)
        `CHECK(stall_m == 1, "[%t] Cache Miss Case: stall_m should be 1", $time)
        `CHECK(stall_w == 1, "[%t] Cache Miss Case: stall_w should be 1", $time)
    endtask

    task expect_cache_hit_branch_miss();
        `CHECK(stall_f == 0, "[%t] Cache Hit Branch Miss: stall_f should be 0", $time)
        `CHECK(stall_d == 0, "[%t] Cache Hit Branch Miss: stall_d should be 0", $time)
        `CHECK(stall_e == 0, "[%t] Cache Hit Branch Miss: stall_e should be 0", $time)
        `CHECK(stall_m == 0, "[%t] Cache Hit Branch Miss: stall_m should be 0", $time)
        `CHECK(stall_w == 0, "[%t] Cache Hit Branch Miss: stall_w should be 0", $time)

        `CHECK(flush_d == 1, "[%t] Cache Hit Branch Miss: flush_d should be 1", $time)
        `CHECK(flush_e == 1, "[%t] Cache Hit Branch Miss: flush_e should be 1", $time)
    endtask

endmodule
