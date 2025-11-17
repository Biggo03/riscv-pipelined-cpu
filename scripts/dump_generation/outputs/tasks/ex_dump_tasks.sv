//==============================================================//
//  Task File:    ex_dump_tasks.sv
//  Description:  Auto-generated dump tasks for the 'ex'
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

task automatic dump_ex(int fd);
    $fdisplay(fd, "  ex:");
    dump_ex_meta(fd);
    dump_ex_control(fd);
    dump_ex_data(fd);
endtask

task automatic dump_ex_meta(int fd);
begin
    $fdisplay(fd, "    meta:");
    $fdisplay(fd, "      pc: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.pc);
    $fdisplay(fd, "      instr: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.instr);
    $fdisplay(fd, "      valid: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.valid);
end
endtask;

task automatic dump_ex_control(int fd);
begin
    $fdisplay(fd, "    control:");
    $fdisplay(fd, "      funct3: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.funct3);
    $fdisplay(fd, "      alu_control: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.alu_control);
    $fdisplay(fd, "      alu_src: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.alu_src);
    $fdisplay(fd, "      result_src: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.result_src);
    $fdisplay(fd, "      width_src: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.width_src);
    $fdisplay(fd, "      branch_op: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.branch_op);
    $fdisplay(fd, "      pc_base_src: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.pc_base_src);
    $fdisplay(fd, "      pc_src_pred: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.pc_src_pred);
    $fdisplay(fd, "      mem_write: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.mem_write);
    $fdisplay(fd, "      reg_write: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.reg_write);
    $fdisplay(fd, "      csr_control: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.csr_control);
    $fdisplay(fd, "      csr_we: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.csr_we);
    $fdisplay(fd, "      csr_src: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.csr_src);
end
endtask;

task automatic dump_ex_data(int fd);
begin
    $fdisplay(fd, "    data:");
    $fdisplay(fd, "      rd: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.rd);
    $fdisplay(fd, "      rs1: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.rs1);
    $fdisplay(fd, "      rs2: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.rs2);
    $fdisplay(fd, "      reg_data_1: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.reg_data_1);
    $fdisplay(fd, "      reg_data_2: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.reg_data_2);
    $fdisplay(fd, "      imm_ext: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.imm_ext);
    $fdisplay(fd, "      pc_plus4: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.pc_plus4);
    $fdisplay(fd, "      pred_pc_target: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.pred_pc_target);
    $fdisplay(fd, "      csr_addr: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.csr_addr);
    $fdisplay(fd, "      csr_data: %0h", `DATA_PATH_HIER.u_execute_stage.outputs_ex.csr_data);
end
endtask;
