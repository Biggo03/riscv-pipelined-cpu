//////////////////////////////////////////////
//             FUNCTIONAL MACROS            //
//////////////////////////////////////////////
`define CHECK(cond, msg, arg1=, arg2=) \
    assert(cond) else begin \
        $error(msg, arg1, arg2); \
        error_cnt++; \
    end

//////////////////////////////////////////////
//             TESTING MACROS               //
//////////////////////////////////////////////
`define TEST_PASS 32'hABCD1234
`define TEST_FAIL 32'hDEADBEEF

//////////////////////////////////////////////
//             HIERARCHY MACROS             //
//////////////////////////////////////////////
`define DATA_PATH_HIER riscv_top_tb.u_riscv_top.u_pipelined_riscv_core.u_data_path
`define HAZARD_UNIT_HIER riscv_top_tb.u_riscv_top.u_pipelined_riscv_core.u_hazard_unit
`define CONTROL_UNIT_HIER riscv_top_tb.u_riscv_top.u_pipelined_riscv_core.u_control_unit
`define ICACHE_HIER riscv_top_tb.u_riscv_top.u_icache_l1
