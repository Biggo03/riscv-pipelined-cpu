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

task automatic dump_wb(int fd);
    $fdisplay(fd, "  wb:");
    dump_wb_meta(fd);
    dump_wb_control(fd);
    dump_wb_data(fd);
endtask

task automatic dump_wb_meta(int fd);
begin
    $fdisplay(fd, "    meta:");
    $fdisplay(fd, "      instr: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.instr);
    $fdisplay(fd, "      valid: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.valid);
end
endtask;

task automatic dump_wb_control(int fd);
begin
    $fdisplay(fd, "    control:");
    $fdisplay(fd, "      result_src: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.result_src);
    $fdisplay(fd, "      reg_write: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.reg_write);
    $fdisplay(fd, "      csr_we: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.csr_we);
end
endtask;

task automatic dump_wb_data(int fd);
begin
    $fdisplay(fd, "    data:");
    $fdisplay(fd, "      rd: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.rd);
    $fdisplay(fd, "      alu_result: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.alu_result);
    $fdisplay(fd, "      reduced_data: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.reduced_data);
    $fdisplay(fd, "      pc_target: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.pc_target);
    $fdisplay(fd, "      pc_plus4: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.pc_plus4);
    $fdisplay(fd, "      imm_ext: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.imm_ext);
    $fdisplay(fd, "      csr_result: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.csr_result);
    $fdisplay(fd, "      csr_addr: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.csr_addr);
    $fdisplay(fd, "      csr_data: %0h", `DATA_PATH_HIER.u_writeback_stage.outputs_wb.csr_data);
end
endtask;
