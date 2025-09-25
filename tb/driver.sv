import apb_pkg::*;

class driver;

  virtual apb_if vif;
  transaction trans;
  mailbox gen2dri_mbx;

  function new(virtual apb_if vif, mailbox gen2dri_mbx);
    this.vif = vif;
    this.gen2dri_mbx = gen2dri_mbx;
  endfunction

  task main();
    forever begin
      gen2dri_mbx.get(trans);
      if (trans.PWRITE == 1) begin
        @(posedge vif.master_dv.PCLK);
        apb_write(trans.PADDR, trans.PWRITE, trans.PWDATA);
      end else begin
        @(posedge vif.master.PCLK);
        apb_read(trans.PADDR);
      end
      trans.display("DRIVER");
    end

  endtask : main

  task apb_write(addr_t paddr, bit pwrite, data_t pwdata);
    // cc 1
    vif.master.PADDR <= paddr;
    vif.master.PWRITE <= 1;
    vif.master.PSEL <= 1;
    vif.master.PENABLE <= 0;
    vif.master.PWDATA <= pwdata;

    //cc 2
    @(posedge vif.master.PCLK);
    vif.master.PADDR <= paddr;
    vif.master.PWRITE <= 1;
    vif.master.PSEL <= 1;
    vif.master.PENABLE <= 1;  // HIGH NOW
    vif.master.PWDATA <= pwdata;

    wait (vif.master.PREADY == 1);
    vif.master.PSEL <= 0;
    vif.master.PENABLE <= 0;
  endtask

  task apb_read(addr_t paddr);
    vif.master.PADDR <= paddr;
    vif.master.PWRITE <= 0;
    vif.master.PSEL <= 1;
    vif.master.PENABLE <= 0;

    @(posedge vif.master.PCLK);
    vif.master.PADDR <= paddr;
    vif.master.PWRITE <= 0;
    vif.master.PSEL <= 1;
    vif.master.PENABLE <= 1;  // HIGH NOW

    wait (vif.master.PREADY == 1);
    vif.master.PSEL <= 0;
    vif.master.PENABLE <= 0;
  endtask


endclass : driver
