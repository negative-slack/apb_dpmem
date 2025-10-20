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
      if (trans.req.pwrite == 1) begin
        apb_write(trans.req.paddr, trans.req.pwrite, trans.req.pwdata);
      end else begin
        apb_read(trans.req.paddr, trans.rsp.prdata);
      end
      trans.display("DRIVER");
    end
  endtask : main

  // cycle_start
  task cycle_start;
    @(posedge vif.master_dv.PCLK);
  endtask : cycle_start

  task apb_write(input addr_t paddr, bit pwrite, data_t pwdata);
    // setup_phase
    cycle_start();
    vif.master_dv.master_cb.PADDR <= paddr;
    vif.master_dv.master_cb.PWRITE <= 1;
    vif.master_dv.master_cb.PSEL <= 1;
    vif.master_dv.master_cb.PENABLE <= 0;
    vif.master_dv.master_cb.PWDATA <= pwdata;
    // access_phase
    cycle_start();
    vif.master_dv.master_cb.PENABLE <= 1;  // HIGH NOW
    wait (vif.master_dv.master_cb.PREADY == 1);
    vif.master_dv.master_cb.PADDR <= 0;
    vif.master_dv.master_cb.PWRITE <= 0;
    vif.master_dv.master_cb.PSEL <= 0;
    vif.master_dv.master_cb.PENABLE <= 0;
    vif.master_dv.master_cb.PWDATA <= 0;
  endtask

  task apb_read(input addr_t paddr, output data_t prdata);
    cycle_start();
    vif.master_dv.master_cb.PADDR <= paddr;
    vif.master_dv.master_cb.PWRITE <= 0;
    vif.master_dv.master_cb.PSEL <= 1;
    vif.master_dv.master_cb.PENABLE <= 0;
    cycle_start();
    vif.master_dv.master_cb.PENABLE <= 1;  // HIGH NOW
    wait (vif.master_dv.master_cb.PREADY == 1);
    vif.master_dv.master_cb.PADDR <= 0;
    vif.master_dv.master_cb.PWRITE <= 0;
    vif.master_dv.master_cb.PSEL <= 0;
    vif.master_dv.master_cb.PENABLE <= 0;
  endtask

endclass : driver
