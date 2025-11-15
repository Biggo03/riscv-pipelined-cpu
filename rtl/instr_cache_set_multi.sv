`timescale 1ns / 1ps
//==============================================================//
//  Module:       instr_cache_set_multi
//  File:         instr_cache_set_multi.sv
//  Description:  A parameterized cache set module, implementing a LRU replacement policy
//                Takes multiple cycles to complete replacement
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   B: Size of block in bytes
//                num_tag_bits: Number of tag bits
//                E: Associativity
//
//  Notes:        This module assumes the L2 cache can't provide data in the same cycle as a miss
//==============================================================//

module instr_cache_set_multi #(
    parameter int B             = 64,
    parameter int num_tag_bits  = 20,
    parameter int E             = 4
) (
    // Clock & reset_i
    input  logic                    clk_i,
    input  logic                    reset_i,

    // Control inputs
    input  logic                    active_set_i,
    input  logic                    ic_repl_grant_i,

    // Address & data inputs
    input  logic [$clog2(B)-1:0]    block_i,
    input  logic [num_tag_bits-1:0] tag_i,
    input  logic [63:0]             rep_word_i,

    // data outputs
    output logic [31:0]             data_o,
    output logic                    cache_set_miss_o
);

    // ----- Parameters -----
    localparam b      = $clog2(B);
    localparam words  = B/4;

    // ----- tag_i + validity -----
    logic [num_tag_bits-1:0] block_tags   [E-1:0];
    logic [E-1:0]            valid_bits_d, valid_bits_q;
    logic [E-1:0]            matched_block;

    // ----- Replacement policy -----
    logic [$clog2(E)-1:0]       lru_bits_d [E-1:0];
    logic [$clog2(E)-1:0]       lru_bits_q [E-1:0];
    logic [$clog2(E)-1:0]       last_lru_status;
    logic [$clog2(E)-1:0]       next_fill_d, next_fill_q;
    logic [$clog2(E)-1:0]       removal_block_d, removal_block_q;
    logic [$clog2(words)-1:0]   rep_counter;
    logic                       ic_rep_active;
    logic                       rep_complete;

    // ----- data storage -----
    (* ram_style = "distributed" *)
    logic [63:0] set_data [(words*E)/2-1:0];

    // ----- block_i addressing -----
    logic [$clog2(words)-1:0] block_offset;
    logic [$clog2(E)-1:0]     out_set;

    // ----- state machine state type -----
    typedef enum logic [1:0] {
        MONITOR     = 2'b01,
        REPLACE     = 2'b10
    } icache_state_t;

    icache_state_t icache_state;
    icache_state_t next_icache_state;

    // ----- Looping constructs -----
    integer i;
    genvar n;

    assign ic_rep_active = cache_set_miss_o && active_set_i && ic_repl_grant_i;

    //tag_i and valid comparison logic
    always_comb begin

        matched_block = 0;
        cache_set_miss_o = 1;
        last_lru_status = 0;

        if (active_set_i) begin
             //Determine if a block matches
            for (i = 0; i < E; i = i + 1) begin
                if (valid_bits_q[i] == 1 && tag_i == block_tags[i]) begin
                    matched_block[i] = 1;
                    last_lru_status = lru_bits_q[i];
                end else begin
                    matched_block[i] = 0;
                end
            end

            //Declare a miss
            if (matched_block == 0) cache_set_miss_o = 1;
            else cache_set_miss_o = 0;

        end
    end


    always_ff @(posedge clk_i) begin : icache_fsm_seq
        if (reset_i) begin
            icache_state    <= MONITOR;
            valid_bits_q    <= 0;
            next_fill_q     <= 0;
            removal_block_q <= 0;

            for (i = 0; i < E; i = i + 1) begin
                lru_bits_q[i] <= 0;
            end
        end else begin
            icache_state    <= next_icache_state;
            valid_bits_q    <= valid_bits_d;
            next_fill_q     <= next_fill_d;
            removal_block_q <= removal_block_d;

            for (i = 0; i < E; i = i + 1) begin
                lru_bits_q[i] <= lru_bits_d[i];
            end
        end
    end

    always_comb begin : icache_fsm_comb

        unique case (icache_state)
            MONITOR:
            begin
                next_fill_d  = next_fill_q;
                valid_bits_d = valid_bits_q;

                // No replacement, update LRU bits
                if (active_set_i && ~cache_set_miss_o) begin
                    next_icache_state = MONITOR;

                    for (i = 0; i < E; i = i + 1) begin
                        if (~matched_block[i] && valid_bits_q[i] && lru_bits_q[i] < last_lru_status) begin
                            lru_bits_d[i] = lru_bits_q[i] + 1;
                        end else if (matched_block[i]) begin
                            lru_bits_d[i] = 0;
                        end else begin
                            lru_bits_d[i] = lru_bits_q[i];
                        end
                    end

                // update lru bits and replace
                end else if (ic_rep_active && valid_bits_q == '1) begin
                    next_icache_state = REPLACE;

                    for (i = 0; i < E; i = i + 1) begin
                        if (lru_bits_q[i] == E-1) lru_bits_d[i] = 0;
                        else                      lru_bits_d[i] = lru_bits_q[i] + 1;
                    end

                // Update LRU bits and fill cache
                end else if (ic_rep_active) begin
                    next_icache_state = REPLACE;
                    next_fill_d = next_fill_q + 1;

                    for (i = 0; i < E; i = i + 1) begin
                        if      (i == next_fill_q) lru_bits_d[i] = 0;
                        else if (i < next_fill_q)  lru_bits_d[i] = lru_bits_q[i] + 1;
                        else                       lru_bits_d[i] = lru_bits_q[i];
                    end

                end else begin
                    next_icache_state = MONITOR;
                    for (i = 0; i < E; i = i + 1) begin
                        lru_bits_d[i] = lru_bits_q[i];
                    end
                end

                if (valid_bits_q == '1) begin
                    for (i = 0; i < E; i = i + 1) begin
                        if (lru_bits_q[i] == E-1) removal_block_d = i;
                        else                      removal_block_d = removal_block_q;
                    end
                end else begin
                    removal_block_d = next_fill_q;
                end

            end

            REPLACE:
            begin
                next_fill_d     = next_fill_q;
                removal_block_d = removal_block_q;

                for (i = 0; i < E; i = i + 1) begin
                    lru_bits_d[i] = lru_bits_q[i];
                end

                if (rep_complete) begin
                    next_icache_state = MONITOR;
                    for (i = 0; i < E; i = i + 1) begin
                        if (i == removal_block_q) valid_bits_d[i] = 1'b1;
                        else                      valid_bits_d[i] = valid_bits_q[i];
                    end
                end else begin
                    next_icache_state = REPLACE;
                    valid_bits_d = valid_bits_q;
                end
            end
        endcase
    end

    assign rep_complete = rep_counter == (words/2)-1;

    //Replacement logic
    always @(posedge clk_i) begin
        if (ic_rep_active) begin
            set_data[(removal_block_q*words/2) + rep_counter] <= rep_word_i;
            //Replace tag and reset_i counter when replacement complete
            if (rep_complete) begin
                rep_counter <= 0;
                block_tags[removal_block_q] <= tag_i;
            end else begin
                rep_counter <= rep_counter + 1;
            end
        end else begin
            rep_counter <= 0;
        end
    end

    //Output logic
    always_comb begin
        if (matched_block != 0) begin
            for (i = 0; i < E; i = i + 1) begin
                if (matched_block[i]) out_set = i;
            end
        end else begin
            out_set = 0;
        end
    end

    assign block_offset = block_i[b-1:3];
    assign data_o = block_i[2] ? set_data[(out_set*words)/2 + block_offset][63:32] : set_data[(out_set*words)/2 + block_offset][31:0];

endmodule
