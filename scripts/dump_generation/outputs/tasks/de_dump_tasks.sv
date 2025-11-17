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

task automatic dump_de(int fd);
    $fdisplay(fd, "  de:");
    dump_de_meta(fd);
    dump_de_control(fd);
    dump_de_data(fd);
endtask

task automatic dump_de_meta(int fd);
begin
    $fdisplay(fd, "    meta:");
    $fdisplay(fd, "      pc: %0h", `DATA_PATH_HIER.u_decode_stage.outputs_de.pc);
    $fdisplay(fd, "      instr: %0h", `DATA_PATH_HIER.u_decode_stage.outputs_de.instr);
    $fdisplay(fd, "      valid: %0h", `DATA_PATH_HIER.u_decode_stage.outputs_de.valid);
end
endtask;

task automatic dump_de_control(int fd);
begin
    $fdisplay(fd, "    control:");
    $fdisplay(fd, "      pc_src_pred: %0h", `DATA_PATH_HIER.u_decode_stage.outputs_de.pc_src_pred);
end
endtask;

task automatic dump_de_data(int fd);
begin
    $fdisplay(fd, "    data:");
    $fdisplay(fd, "      pc_plus4: %0h", `DATA_PATH_HIER.u_decode_stage.outputs_de.pc_plus4);
    $fdisplay(fd, "      pred_pc_target: %0h", `DATA_PATH_HIER.u_decode_stage.outputs_de.pred_pc_target);
end
endtask;
