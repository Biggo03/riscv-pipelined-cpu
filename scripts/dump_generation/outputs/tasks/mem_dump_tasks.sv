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

task automatic dump_mem(int fd);
    $fdisplay(fd, "  mem:");
    dump_mem_meta(fd);
    dump_mem_control(fd);
    dump_mem_data(fd);
endtask

task automatic dump_mem_meta(int fd);
begin
    $fdisplay(fd, "    meta:");
    $fdisplay(fd, "      instr: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.instr);
    $fdisplay(fd, "      valid: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.valid);
end
endtask;

task automatic dump_mem_control(int fd);
begin
    $fdisplay(fd, "    control:");
    $fdisplay(fd, "      result_src: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.result_src);
    $fdisplay(fd, "      width_src: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.width_src);
    $fdisplay(fd, "      mem_write: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.mem_write);
    $fdisplay(fd, "      reg_write: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.reg_write);
    $fdisplay(fd, "      csr_we: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.csr_we);
end
endtask;

task automatic dump_mem_data(int fd);
begin
    $fdisplay(fd, "    data:");
    $fdisplay(fd, "      rd: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.rd);
    $fdisplay(fd, "      alu_result: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.alu_result);
    $fdisplay(fd, "      write_data: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.write_data);
    $fdisplay(fd, "      pc_target: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.pc_target);
    $fdisplay(fd, "      pc_plus4: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.pc_plus4);
    $fdisplay(fd, "      imm_ext: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.imm_ext);
    $fdisplay(fd, "      csr_result: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.csr_result);
    $fdisplay(fd, "      csr_addr: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.csr_addr);
    $fdisplay(fd, "      csr_data: %0h", `DATA_PATH_HIER.u_memory_stage.outputs_mem.csr_data);
end
endtask;
