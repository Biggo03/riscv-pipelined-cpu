//==============================================================//
//  Task File:    _dump_tasks.sv
//  Description:  Auto-generated dump tasks for the ''
//                pipeline stage. Contains hierarchical field dumpers
//                for each struct category (stall, flush, forward),
//                used by the top-level pipeline_monitor.
//
//  Author:       Viggo Wozniak
//  Project:      RISC-V Processor
//  Repository:   https://github.com/Biggo03/RISC-V-Pipelined
//
//  Parameters:   N/A
//
//  Notes:        This file is auto-generated. Any modifications
//                should be made in the generator scripts or the
//                associated Jinja template. Do not edit manually.
//==============================================================//

task automatic dump_hazard_unit(int reg_dump_handle);
    $fdisplay(reg_dump_handle, "  hazard_unit:");
    dump_hazard_unit_stall(reg_dump_handle);
    dump_hazard_unit_flush(reg_dump_handle);
    dump_hazard_unit_forward(reg_dump_handle);
endtask

task automatic dump_hazard_unit_stall(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    stall:");
    $fdisplay(reg_dump_handle, "      stall_fi_o,: 0x%h", `HAZARD_UNIT_HIER.stall_fi_o,);
    $fdisplay(reg_dump_handle, "      stall_de_o,: 0x%h", `HAZARD_UNIT_HIER.stall_de_o,);
    $fdisplay(reg_dump_handle, "      stall_ex_o,: 0x%h", `HAZARD_UNIT_HIER.stall_ex_o,);
    $fdisplay(reg_dump_handle, "      stall_mem_o,: 0x%h", `HAZARD_UNIT_HIER.stall_mem_o,);
    $fdisplay(reg_dump_handle, "      stall_wb_o,: 0x%h", `HAZARD_UNIT_HIER.stall_wb_o,);
end
endtask;

task automatic dump_hazard_unit_flush(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    flush:");
    $fdisplay(reg_dump_handle, "      flush_de_o,: 0x%h", `HAZARD_UNIT_HIER.flush_de_o,);
    $fdisplay(reg_dump_handle, "      flush_ex_o,: 0x%h", `HAZARD_UNIT_HIER.flush_ex_o,);
end
endtask;

task automatic dump_hazard_unit_forward(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    forward:");
    $fdisplay(reg_dump_handle, "      forward_a_ex_o,: 0x%h", `HAZARD_UNIT_HIER.forward_a_ex_o,);
    $fdisplay(reg_dump_handle, "      forward_b_ex_o,: 0x%h", `HAZARD_UNIT_HIER.forward_b_ex_o,);
    $fdisplay(reg_dump_handle, "      forward_csr_ex_o: 0x%h", `HAZARD_UNIT_HIER.forward_csr_ex_o);
end
endtask;
