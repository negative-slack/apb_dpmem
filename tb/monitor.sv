class monitor;
  virtual apb_if mon_intf;
  mailbox mon2scb_mbx;

  function new(virtual apb_if mon_intf, mailbox mon2scb_mbx);
    this.mon_intf = mon_intf;
    this.mon2scb_mbx = mon2scb_mbx;
  endfunction

  task main();
    transaction trans;

    forever begin
      @(mon_intf.monitor_cb);

      if (mon_intf.monitor_cb.PSEL && 
          mon_intf.monitor_cb.PENABLE && 
          mon_intf.monitor_cb.PREADY) begin

        trans = new();

        trans.req.paddr = mon_intf.monitor_cb.PADDR;
        trans.req.pwrite = mon_intf.monitor_cb.PWRITE;
        trans.rsp.pready = mon_intf.monitor_cb.PREADY;
        if (trans.req.pwrite) begin
          trans.req.pwdata = mon_intf.monitor_cb.PWDATA;
        end else begin
          trans.rsp.prdata = mon_intf.monitor_cb.PRDATA;
        end

        trans.display("MONITOR");
        mon2scb_mbx.put(trans);
      end
    end

  endtask

endclass : monitor
