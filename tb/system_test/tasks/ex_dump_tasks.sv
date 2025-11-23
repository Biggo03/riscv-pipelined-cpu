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

task automatic dump_ex(int reg_dump_handle);
    $fdisplay(reg_dump_handle, "  ex:");
    dump_ex_meta(reg_dump_handle);
    dump_ex_control(reg_dump_handle);
    dump_ex_data(reg_dump_handle);
endtask

task automatic dump_ex_meta(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    meta:");
    $fdisplay(reg_dump_handle, "      pc: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.meta.pc);
    $fdisplay(reg_dump_handle, "      instr: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.meta.instr);
    $fdisplay(reg_dump_handle, "      valid: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.meta.valid);
end
endtask;

task automatic dump_ex_control(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    control:");
    $fdisplay(reg_dump_handle, "      funct3: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.funct3);
    $fdisplay(reg_dump_handle, "      alu_control: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.alu_control);
    $fdisplay(reg_dump_handle, "      alu_src: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.alu_src);
    $fdisplay(reg_dump_handle, "      result_src: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.result_src);
    $fdisplay(reg_dump_handle, "      width_src: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.width_src);
    $fdisplay(reg_dump_handle, "      branch_op: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.branch_op);
    $fdisplay(reg_dump_handle, "      pc_base_src: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.pc_base_src);
    $fdisplay(reg_dump_handle, "      pc_src_pred: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.pc_src_pred);
    $fdisplay(reg_dump_handle, "      mem_write: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.mem_write);
    $fdisplay(reg_dump_handle, "      reg_write: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.reg_write);
    $fdisplay(reg_dump_handle, "      csr_control: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.csr_control);
    $fdisplay(reg_dump_handle, "      csr_we: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.csr_we);
    $fdisplay(reg_dump_handle, "      csr_src: \"0b%b\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.control.csr_src);
end
endtask;

task automatic dump_ex_data(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    data:");
    $fdisplay(reg_dump_handle, "      rd: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.data.rd);
    $fdisplay(reg_dump_handle, "      rs1: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.data.rs1);
    $fdisplay(reg_dump_handle, "      rs2: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.data.rs2);
    $fdisplay(reg_dump_handle, "      reg_data_1: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.data.reg_data_1);
    $fdisplay(reg_dump_handle, "      reg_data_2: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.data.reg_data_2);
    $fdisplay(reg_dump_handle, "      imm_ext: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.data.imm_ext);
    $fdisplay(reg_dump_handle, "      pc_plus4: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.data.pc_plus4);
    $fdisplay(reg_dump_handle, "      pred_pc_target: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.data.pred_pc_target);
    $fdisplay(reg_dump_handle, "      csr_addr: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.data.csr_addr);
    $fdisplay(reg_dump_handle, "      csr_data: \"0x%h\"", `DATA_PATH_HIER.u_execute_stage.outputs_ex.data.csr_data);
end
endtask;
