import apb_pkg::*;

class monitor;

  virtual apb_if monitor_vif;

  mailbox mon2scb_mbx;

  function new(virtual apb_if monitor_vif, mailbox mon2scb_mbx);
    this.monitor_vif = monitor_vif;
    this.mon2scb_mbx = mon2scb_mbx;
  endfunction

  task main();
    transaction trans;
    forever begin
      @(posedge monitor_vif.PCLK);

      if (monitor_vif.PSEL && monitor_vif.PENABLE && monitor_vif.PREADY) begin
        trans = new();

        trans.req.paddr = apb_rw_t'(monitor_vif.PADDR);
        trans.req.pwrite = apb_rw_t'(monitor_vif.PWRITE);
        if (trans.req.pwrite) begin
          trans.req.pwdata = monitor_vif.PWDATA;
        end else begin
          trans.rsp.prdata = monitor_vif.PRDATA;
        end
        trans.rsp.pready = monitor_vif.PREADY;

        trans.display("MONITOR");
        mon2scb_mbx.put(trans);
      end
    end
  endtask

endclass : monitor
