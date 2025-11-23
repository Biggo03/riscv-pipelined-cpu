//==============================================================//
//  Task File:    mem_dump_tasks.sv
//  Description:  Auto-generated dump tasks for the 'mem'
//                pipeline stage. Contains hierarchical field dumpers
//                for each struct category (meta, control, data),
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

task automatic dump_mem(int reg_dump_handle);
    $fdisplay(reg_dump_handle, "  mem:");
    dump_mem_meta(reg_dump_handle);
    dump_mem_control(reg_dump_handle);
    dump_mem_data(reg_dump_handle);
endtask

task automatic dump_mem_meta(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    meta:");
    $fdisplay(reg_dump_handle, "      instr: \"0x%h\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.meta.instr);
    $fdisplay(reg_dump_handle, "      valid: \"0x%h\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.meta.valid);
end
endtask;

task automatic dump_mem_control(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    control:");
    $fdisplay(reg_dump_handle, "      result_src: \"0b%b\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.control.result_src);
    $fdisplay(reg_dump_handle, "      width_src: \"0b%b\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.control.width_src);
    $fdisplay(reg_dump_handle, "      mem_write: \"0b%b\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.control.mem_write);
    $fdisplay(reg_dump_handle, "      reg_write: \"0b%b\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.control.reg_write);
    $fdisplay(reg_dump_handle, "      csr_we: \"0b%b\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.control.csr_we);
end
endtask;

task automatic dump_mem_data(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    data:");
    $fdisplay(reg_dump_handle, "      rd: \"0x%h\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.data.rd);
    $fdisplay(reg_dump_handle, "      alu_result: \"0x%h\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.data.alu_result);
    $fdisplay(reg_dump_handle, "      write_data: \"0x%h\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.data.write_data);
    $fdisplay(reg_dump_handle, "      pc_target: \"0x%h\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.data.pc_target);
    $fdisplay(reg_dump_handle, "      pc_plus4: \"0x%h\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.data.pc_plus4);
    $fdisplay(reg_dump_handle, "      imm_ext: \"0x%h\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.data.imm_ext);
    $fdisplay(reg_dump_handle, "      csr_result: \"0x%h\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.data.csr_result);
    $fdisplay(reg_dump_handle, "      csr_addr: \"0x%h\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.data.csr_addr);
    $fdisplay(reg_dump_handle, "      csr_data: \"0x%h\"", `DATA_PATH_HIER.u_memory_stage.outputs_mem.data.csr_data);
end
endtask;
