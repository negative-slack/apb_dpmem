class monitor;

  `define MON mon_intf.monitor_cb

  virtual apb_if mon_intf;
  mailbox mon2scb_mbx;
  transaction trans;

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

endclass : monitor
