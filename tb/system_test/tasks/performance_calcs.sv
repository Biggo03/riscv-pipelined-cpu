task automatic calculate_cycle_metrics(
    input  int  total_cycles,
    input  int  retire_cnt,

    output real ipc,
    output real cpi
);
begin
    if (total_cycles == 0) begin
        ipc = 0.0;
        cpi = 0.0;
    end else if (retire_cnt == 0) begin
        ipc = 0.0;
        cpi = total_cycles;  // infinite CPI becomes “all cycles per retire”
    end else begin
        ipc = retire_cnt / real'(total_cycles);
        cpi = total_cycles / real'(retire_cnt);
    end
end
endtask;

task automatic calculate_op_metrics(
    input  int  retire_cnt,
    input  int  alu_op_cnt,
    input  int  load_op_cnt,
    input  int  store_op_cnt,
    input  int  branch_op_cnt,

    output real percent_alu_op,
    output real percent_load_op,
    output real percent_store_op,
    output real percent_branch_op
);
begin
    if (retire_cnt == 0) begin
        percent_alu_op    = 0.0;
        percent_load_op   = 0.0;
        percent_store_op  = 0.0;
        percent_branch_op = 0.0;
    end else begin
        percent_alu_op    = alu_op_cnt    / real'(retire_cnt);
        percent_load_op   = load_op_cnt   / real'(retire_cnt);
        percent_store_op  = store_op_cnt  / real'(retire_cnt);
        percent_branch_op = branch_op_cnt / real'(retire_cnt);
    end
end
endtask;

task automatic calculate_stall_metrics(
    input  int  total_cycles,
    input  int  load_stall_cnt,
    input  int  branch_mispredict_stall_cycles,
    input  int  icache_miss_stall_cycles,

    output int  total_stall_cycles,
    output real total_stall_rate,
    output real percent_load_stall,
    output real percent_branch_stall,
    output real percent_icache_stall
);
begin
    // Total stalls
    total_stall_cycles = load_stall_cnt +
                         branch_mispredict_stall_cycles +
                         icache_miss_stall_cycles;

    // Stall rate vs total cycles
    if (total_cycles == 0) begin
        total_stall_rate = 0.0;
    end else begin
        total_stall_rate = total_stall_cycles / real'(total_cycles);
    end

    // Stall mix (each category as % of total stall cycles)
    if (total_stall_cycles == 0) begin
        percent_load_stall   = 0.0;
        percent_branch_stall = 0.0;
        percent_icache_stall = 0.0;
    end else begin
        percent_load_stall   = load_stall_cnt                 / real'(total_stall_cycles);
        percent_branch_stall = branch_mispredict_stall_cycles / real'(total_stall_cycles);
        percent_icache_stall = icache_miss_stall_cycles       / real'(total_stall_cycles);
    end
end
endtask

task automatic calculate_branch_metrics(
    input  int  branch_op_cnt,
    input  int  branch_mispredict_cnt,

    output real mispredict_rate,
    output real prediction_accuracy
);
begin
    if (branch_op_cnt == 0) begin
        mispredict_rate = 0.0;
    end else begin
        mispredict_rate = branch_mispredict_cnt / real'(branch_op_cnt);
        prediction_accuracy = 1.0 - mispredict_rate;
    end
end
endtask;

task automatic calculate_icache_metrics(
    input  int  retire_cnt,
    input  int  icache_miss_cnt,

    output real hit_rate
);
begin
    if (retire_cnt == 0) begin
        hit_rate = 0.0;
    end else begin
        hit_rate = 1.0 - (icache_miss_cnt / real'(retire_cnt));
    end
end
endtask;

task automatic print_perf_summary(
    input int fd,

    input int total_cycles,
    input int retire_cnt,

    input int alu_op_cnt,
    input int load_op_cnt,
    input int store_op_cnt,
    input int branch_op_cnt,

    input int branch_mispredict_cnt,

    input int load_stall_cnt,
    input int branch_mispredict_stall_cycles,
    input int icache_miss_cnt,
    input int icache_miss_stall_cycles
);

    real ipc;
    real cpi;

    real percent_alu;
    real percent_load;
    real percent_store;
    real percent_branch;

    int  total_stalls;
    real stall_rate;

    real percent_load_stall;
    real percent_branch_stall;
    real percent_icache_stall;

    real mispredict_rate;
    real prediction_accuracy;

    real icache_hit_rate;
begin
    // Cycle metrics
    calculate_cycle_metrics(
        .total_cycles (total_cycles),
        .retire_cnt   (retire_cnt),
        .ipc          (ipc),
        .cpi          (cpi)
    );


    // Operation mix
    calculate_op_metrics(
        .retire_cnt       (retire_cnt),
        .alu_op_cnt       (alu_op_cnt),
        .load_op_cnt      (load_op_cnt),
        .store_op_cnt     (store_op_cnt),
        .branch_op_cnt    (branch_op_cnt),
        .percent_alu_op   (percent_alu),
        .percent_load_op  (percent_load),
        .percent_store_op (percent_store),
        .percent_branch_op(percent_branch)
    );


    // Stall metrics + stall mix (updated call)
    calculate_stall_metrics(
        .total_cycles                   (total_cycles),
        .load_stall_cnt                 (load_stall_cnt),
        .branch_mispredict_stall_cycles (branch_mispredict_stall_cycles),
        .icache_miss_stall_cycles       (icache_miss_stall_cycles),
        .total_stall_cycles             (total_stalls),
        .total_stall_rate               (stall_rate),
        .percent_load_stall             (percent_load_stall),
        .percent_branch_stall           (percent_branch_stall),
        .percent_icache_stall           (percent_icache_stall)
    );


    // Branch metrics
    calculate_branch_metrics(
        .branch_op_cnt       (branch_op_cnt),
        .branch_mispredict_cnt(branch_mispredict_cnt),
        .mispredict_rate     (mispredict_rate),
        .prediction_accuracy (prediction_accuracy)
    );


    // I-cache metrics
    calculate_icache_metrics(
        .retire_cnt      (retire_cnt),
        .icache_miss_cnt (icache_miss_cnt),
        .hit_rate        (icache_hit_rate)
    );

    // Print summary
    $fdisplay(fd, "\n========================================");
    $fdisplay(fd, "           Performance Summary          ");
    $fdisplay(fd, "========================================");

    $fdisplay(fd, "Cycles:                      %0d", total_cycles);
    $fdisplay(fd, "Instructions Retired:        %0d", retire_cnt);
    $fdisplay(fd, "IPC:                         %0.3f", ipc);
    $fdisplay(fd, "CPI:                         %0.3f", cpi);

    // -------------------------------------------------
    // Total Operation Counts
    // -------------------------------------------------
    $fdisplay(fd, "\n--- Total Operation Counts ---");
    $fdisplay(fd, "ALU Ops:                    %0d", alu_op_cnt);
    $fdisplay(fd, "Load Ops:                   %0d", load_op_cnt);
    $fdisplay(fd, "Store Ops:                  %0d", store_op_cnt);
    $fdisplay(fd, "Branch Ops:                 %0d", branch_op_cnt);

    // -------------------------------------------------
    // Operation Mix
    // -------------------------------------------------
    $fdisplay(fd, "\n--- Operation Mix ---");
    $fdisplay(fd, "ALU Ops:                    %0.2f%%", percent_alu    * 100.0);
    $fdisplay(fd, "Load Ops:                   %0.2f%%", percent_load   * 100.0);
    $fdisplay(fd, "Store Ops:                  %0.2f%%", percent_store  * 100.0);
    $fdisplay(fd, "Branch Ops:                 %0.2f%%", percent_branch * 100.0);

    // -------------------------------------------------
    // Stalls
    // -------------------------------------------------
    $fdisplay(fd, "\n--- Stalls ---");
    $fdisplay(fd, "Total Stall Cycles:         %0d", total_stalls);
    $fdisplay(fd, "Load Stall Cycles:          %0d", load_stall_cnt);
    $fdisplay(fd, "Branch Stall Cycles:        %0d", branch_mispredict_stall_cycles);
    $fdisplay(fd, "Icache Miss Stall Cycles:   %0d", icache_miss_stall_cycles);
    $fdisplay(fd, "Overall Stall Rate:         %0.2f%%", stall_rate * 100.0);

    // -------------------------------------------------
    // Stall Mix
    // -------------------------------------------------
    $fdisplay(fd, "\n--- Total Stall Mix ---");
    $fdisplay(fd, "Load Stall Contribution:    %0.2f%%", percent_load_stall   * 100.0);
    $fdisplay(fd, "Branch Stall Contribution:  %0.2f%%", percent_branch_stall * 100.0);
    $fdisplay(fd, "Icache Stall Contribution:  %0.2f%%", percent_icache_stall * 100.0);

    // -------------------------------------------------
    // Branch Predictor
    // -------------------------------------------------
    $fdisplay(fd, "\n--- Branch Predictor ---");
    $fdisplay(fd, "Branch Ops:                 %0d", branch_op_cnt);
    $fdisplay(fd, "Mispredicts:                %0d", branch_mispredict_cnt);
    $fdisplay(fd, "Mispredict Rate:            %0.2f%%", mispredict_rate * 100.0);
    $fdisplay(fd, "Prediction Accuracy:        %0.2f%%", prediction_accuracy * 100.0);

    // -------------------------------------------------
    // I-Cache
    // -------------------------------------------------
    $fdisplay(fd, "\n--- I-Cache ---");
    $fdisplay(fd, "Miss Count:                 %0d", icache_miss_cnt);
    $fdisplay(fd, "Hit Rate:                   %0.2f%%", icache_hit_rate * 100.0);

    $fdisplay(fd, "========================================\n");
end
endtask
