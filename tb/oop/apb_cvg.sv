/********************************************
 *  Copyright (c) 2025 
 *  Author: negative-slack (Nader Alnatsheh).
 *  All rights reserved.
 *******************************************/

`ifndef APV_CVG__SV
`define APV_CVG__SV 

class apb_coverage;

  virtual apb_if cov_intf;

  covergroup apb_cg @(posedge cov_intf.PCLK);

    // address range coverage
    addr_cp: coverpoint cov_intf.PADDR {
      bins low_addr = {[0 : 255]};
      bins low_mid_addr = {[256 : 511]};
      bins high_mid_addr = {[512 : 767]};
      bins out_of_range = {[768 : 1023]};
    }

    // operation type coverage
    read_or_write_opn: coverpoint cov_intf.PWRITE {
      bins read = {0};  // read only
      bins write = {1};  // write only

      bins two_reads[] = (0 => 0);
      bins two_writes[] = (1 => 1);

      bins multiple_reads[] = (0 [* 3: 5]);
      bins multiple_writes[] = (1 [* 3: 5]);

      bins read_write[] = (0 => 1);
      bins write_read[] = (1 => 0);
    }

    // pslverr coverage
    error_cp: coverpoint cov_intf.PSLVERR {
      bins no_error = {0}; bins error = {1};
    }

  endgroup

  function new(virtual apb_if cov_intf);
    this.cov_intf = cov_intf;
    apb_cg = new();
  endfunction

  task run();
    forever begin
      @(posedge cov_intf.PCLK iff (cov_intf.PSEL && cov_intf.PENABLE && cov_intf.PREADY));
      apb_cg.sample();
    end
  endtask

endclass

`endif
