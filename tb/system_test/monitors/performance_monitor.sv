`include "instr_macros.sv"

module performance_monitor (
    // general signals
    input logic        clk_i,
    input logic        reset_i,

    // op count related signals
    input logic        valid_wb_i,
    input logic        stall_wb_i,
    input logic [31:0] instr_wb_i,

    // load stall related signals
    input logic       load_stall_i,

    // branch related signals
    input logic [1:0]  pc_src_i,

    // cache related signals
    input logic        instr_hit_fi_i,
    input logic        flush_ex_i,

    // file handle
    input int          perf_dump_handle
);

    int cycle_cnt;

    int retire_cnt;
    int alu_op_cnt;
    int load_op_cnt;
    int store_op_cnt;
    int branch_op_cnt;

    logic retire_wb;

    always_ff @(posedge clk_i) begin : cycle_monitor
        if (reset_i) cycle_cnt <= 0;
        else cycle_cnt <= cycle_cnt + 1;
    end

    always @(negedge clk_i) begin : op_monitor
        if (reset_i) begin
            retire_cnt    <= 0;
            alu_op_cnt    <= 0;
            load_op_cnt   <= 0;
            store_op_cnt  <= 0;
            branch_op_cnt <= 0;
        end else if (retire_wb & (instr_wb_i != `NOP_INSTR)) begin
            retire_cnt    <= retire_cnt + 1;

            unique case (instr_wb_i[6:0])
                // alu ops
                `R_TYPE_OP:      alu_op_cnt <= alu_op_cnt + 1;
                `I_TYPE_ALU_OP:  alu_op_cnt <= alu_op_cnt + 1;
                `AUIPC_OP:       alu_op_cnt <= alu_op_cnt + 1;
                `LUI_OP:         alu_op_cnt <= alu_op_cnt + 1;

                // branch ops
                `B_TYPE_OP:      branch_op_cnt <= branch_op_cnt + 1;
                `JAL_OP:         branch_op_cnt <= branch_op_cnt + 1;
                `JALR_OP:        branch_op_cnt <= branch_op_cnt + 1;

                // load ops
                `I_TYPE_LOAD_OP: load_op_cnt <= load_op_cnt +1;

                // store ops
                `S_TYPE_OP:      store_op_cnt <= store_op_cnt + 1;
            endcase
        end
    end

    assign retire_wb = valid_wb_i & ~stall_wb_i;

    int load_stall_cnt;
    always @(negedge clk_i) begin : load_stall_monitor
        if (reset_i) begin
            load_stall_cnt <= 0;
        end else if (load_stall_i && instr_hit_fi_i) begin
            load_stall_cnt <= load_stall_cnt + 1;
            `ifdef PERF_CYCLE_DUMP
                $fdisplay(perf_dump_handle, "cycle %0d: load stall", cycle_cnt);
            `endif
        end
    end

    int branch_mispredict_cnt;
    int branch_mispredict_stall_cycles;
    always @(negedge clk_i) begin : branch_monitor
        if (reset_i) begin
            branch_mispredict_cnt <= 0;
            branch_mispredict_stall_cycles <= 0;
        end else if (pc_src_i[1] && flush_ex_i) begin
            branch_mispredict_cnt          <= branch_mispredict_cnt + 1;
            branch_mispredict_stall_cycles <= branch_mispredict_stall_cycles + 1;
            `ifdef PERF_CYCLE_DUMP
                $fdisplay(perf_dump_handle, "cycle %0d: branch misprediction", cycle_cnt);
            `endif
        end else if (pc_src_i[1]) begin
            branch_mispredict_stall_cycles <= branch_mispredict_stall_cycles + 1;
        end
    end

    logic instr_hit_fi_reg;
    logic flush_ex_reg;
    always_ff @(posedge clk_i) begin
        instr_hit_fi_reg <= instr_hit_fi_i;
        flush_ex_reg     <= flush_ex_i;
    end

    int icache_miss_cnt;
    int icache_miss_stall_cycles;
    always @(negedge clk_i) begin : icache_monitor
        if (reset_i) begin
            icache_miss_cnt <= 0;
            icache_miss_stall_cycles <= 0;
        end else if ((~instr_hit_fi_i && instr_hit_fi_reg) || (~instr_hit_fi_i && flush_ex_reg)) begin
            icache_miss_cnt <= icache_miss_cnt + 1;
            icache_miss_stall_cycles <= icache_miss_stall_cycles + 1;
            `ifdef PERF_CYCLE_DUMP
                $fdisplay(perf_dump_handle, "cycle %0d: icache miss", cycle_cnt);
            `endif
        end else if (~instr_hit_fi_i) begin
            icache_miss_stall_cycles <= icache_miss_stall_cycles + 1;
        end
    end

endmodule
