////////////////////////////////////////
// AUTO-GENERATED CSR REGISTER MACROS //
////////////////////////////////////////
`define MCYCLE_ADDR            12'hB00 // Bottom 32-bits storing number of cycles
`define MCYCLEH_ADDR           12'hB80 // Top 32-bits storing number of cycles
`define MINSTRET_ADDR          12'hB02 // Bottom 32-bits storing number of instructions retired
`define MINSTRETH_ADDR         12'hB82 // Top 32-bits storing number of instructions retired
`define MSTATUS_ADDR           12'h300 // machine status register (currently only used for testing)
`define MDBG_ADDR              12'h7A0 // Custom register for holding debug info during testing
`define MTEST_STATUS_ADDR      12'h7C0 // Custom register for handling test success/failure in simulation
