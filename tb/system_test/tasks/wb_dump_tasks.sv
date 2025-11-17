//==============================================================//
//  Task File:    wb_dump_tasks.sv
//  Description:  Auto-generated dump tasks for the 'wb'
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

task automatic dump_wb(int reg_dump_handle);
    $fdisplay(reg_dump_handle, "  wb:");
    dump_wb_meta(reg_dump_handle);
    dump_wb_control(reg_dump_handle);
    dump_wb_data(reg_dump_handle);
endtask

task automatic dump_wb_meta(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    meta:");
    $fdisplay(reg_dump_handle, "      instr: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.meta.instr);
    $fdisplay(reg_dump_handle, "      valid: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.meta.valid);
end
endtask;

task automatic dump_wb_control(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    control:");
    $fdisplay(reg_dump_handle, "      result_src: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.control.result_src);
    $fdisplay(reg_dump_handle, "      reg_write: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.control.reg_write);
    $fdisplay(reg_dump_handle, "      csr_we: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.control.csr_we);
end
endtask;

task automatic dump_wb_data(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    data:");
    $fdisplay(reg_dump_handle, "      rd: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.data.rd);
    $fdisplay(reg_dump_handle, "      alu_result: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.data.alu_result);
    $fdisplay(reg_dump_handle, "      reduced_data: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.data.reduced_data);
    $fdisplay(reg_dump_handle, "      pc_target: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.data.pc_target);
    $fdisplay(reg_dump_handle, "      pc_plus4: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.data.pc_plus4);
    $fdisplay(reg_dump_handle, "      imm_ext: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.data.imm_ext);
    $fdisplay(reg_dump_handle, "      csr_result: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.data.csr_result);
    $fdisplay(reg_dump_handle, "      csr_addr: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.data.csr_addr);
    $fdisplay(reg_dump_handle, "      csr_data: 0x%h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.data.csr_data);
end
endtask;
