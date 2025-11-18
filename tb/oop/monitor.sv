/********************************************
 *  Copyright (c) 2025 
 *  Author: negative-slack (Nader Alnatsheh).
 *  All rights reserved.
 *******************************************/

`ifndef MONITOR__SV
`define MONITOR__SV 

class Monitor;

  virtual apb_if mon_intf;
  mailbox mon2scb_mbx;
  Transaction trans;

  `define MON mon_intf.monitor_cb

  function new(virtual apb_if mon_intf, mailbox mon2scb_mbx);
    this.mon_intf = mon_intf;
    this.mon2scb_mbx = mon2scb_mbx;
  endfunction

  task run();

    forever begin
      @(`MON);

      if (`MON.PSEL && `MON.PENABLE && `MON.PREADY) begin

        trans = new();

        trans.req.paddr = `MON.PADDR;
        trans.req.pstrb = `MON.PSTRB;
        trans.req.pwrite = `MON.PWRITE;
        if (trans.req.pwrite) begin
          trans.req.pwdata = `MON.PWDATA;
        end else begin
          trans.rsp.prdata = `MON.PRDATA;
        end
        trans.rsp.pready = `MON.PREADY;
        trans.display("MONITOR");
        mon2scb_mbx.put(trans);
      end
    end

  endtask

  `undef MON

endclass : Monitor

`endif
