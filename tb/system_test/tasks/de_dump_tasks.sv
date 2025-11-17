//==============================================================//
//  Task File:    de_dump_tasks.sv
//  Description:  Auto-generated dump tasks for the 'de'
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

task automatic dump_de(int reg_dump_handle);
    $fdisplay(reg_dump_handle, "  de:");
    dump_de_meta(reg_dump_handle);
    dump_de_control(reg_dump_handle);
    dump_de_data(reg_dump_handle);
endtask

task automatic dump_de_meta(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    meta:");
    $fdisplay(reg_dump_handle, "      pc: 0x%h", `DATA_PATH_HIER.u_decode_stage.outputs_de.meta.pc);
    $fdisplay(reg_dump_handle, "      instr: 0x%h", `DATA_PATH_HIER.u_decode_stage.outputs_de.meta.instr);
    $fdisplay(reg_dump_handle, "      valid: 0x%h", `DATA_PATH_HIER.u_decode_stage.outputs_de.meta.valid);
end
endtask;

task automatic dump_de_control(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    control:");
    $fdisplay(reg_dump_handle, "      pc_src_pred: 0x%h", `DATA_PATH_HIER.u_decode_stage.outputs_de.control.pc_src_pred);
end
endtask;

task automatic dump_de_data(int reg_dump_handle);
begin
    $fdisplay(reg_dump_handle, "    data:");
    $fdisplay(reg_dump_handle, "      pc_plus4: 0x%h", `DATA_PATH_HIER.u_decode_stage.outputs_de.data.pc_plus4);
    $fdisplay(reg_dump_handle, "      pred_pc_target: 0x%h", `DATA_PATH_HIER.u_decode_stage.outputs_de.data.pred_pc_target);
end
endtask;
