// import apb_pkg::*;

class driver;

  virtual apb_if vif;
  transaction trans;
  mailbox gen2dri_mbx;

  function new(virtual apb_if vif, mailbox gen2dri_mbx);
    this.vif = vif;
    this.gen2dri_mbx = gen2dri_mbx;
  endfunction

  // cycle_start
  task cycle_start;
    @(posedge vif.master_dv.PCLK);
  endtask : cycle_start

  task main();
    forever begin
      gen2dri_mbx.get(trans);
      if (trans.PWRITE == 1) begin
        apb_write(trans.PADDR, trans.PWRITE, trans.PWDATA);
      end else begin
        apb_read(trans.PADDR);
      end
      trans.display("DRIVER");
    end

  endtask : main

  task apb_write(addr_t paddr, bit pwrite, data_t pwdata);
    cycle_start();
    vif.master.PADDR <= paddr;
    vif.master.PWRITE <= 1;
    vif.master.PSEL <= 1;
    vif.master.PENABLE <= 0;
    vif.master.PWDATA <= pwdata;

    cycle_start();
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
    cycle_start();
    vif.master.PADDR <= paddr;
    vif.master.PWRITE <= 0;
    vif.master.PSEL <= 1;
    vif.master.PENABLE <= 0;

    cycle_start();
    vif.master.PADDR <= paddr;
    vif.master.PWRITE <= 0;
    vif.master.PSEL <= 1;
    vif.master.PENABLE <= 1;  // HIGH NOW

    wait (vif.master.PREADY == 1);
    vif.master.PSEL <= 0;
    vif.master.PENABLE <= 0;
  endtask

endclass : driver
