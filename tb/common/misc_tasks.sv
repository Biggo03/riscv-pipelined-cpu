task automatic dump_setup;
  begin
    `ifdef DUMP_FILE
      $display("Dumping VCD to: %s", `DUMP_FILE);
      $dumpfile(`DUMP_FILE);
    `else
      $display("Unable to dump VCD\nPlease supply a DUMP_FILE");
    `endif
    $dumpvars;
  end
endtask
