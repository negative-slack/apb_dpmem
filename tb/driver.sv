class driver;

  virtual apb_if dri_intf;
  mailbox gen2dri_mbx;
  event dri_ended;

  transaction trans;

  function new(virtual apb_if dri_intf, mailbox gen2dri_mbx, event dri_ended);
    this.dri_intf = dri_intf;
    this.gen2dri_mbx = gen2dri_mbx;
    this.dri_ended = dri_ended;
  endfunction

  task cycle();
    @(dri_intf.driver_cb);
  endtask : cycle

  task idle_state();
    dri_intf.driver_cb.PSEL <= 0;  // low 
    dri_intf.driver_cb.PADDR <= '0;
    dri_intf.driver_cb.PWRITE <= 0;
    dri_intf.driver_cb.PWDATA <= '0;
    dri_intf.driver_cb.PENABLE <= 0;  // low
  endtask

  task setup_state(input addr_t paddr, logic pwrite, data_t pwdata);
    dri_intf.driver_cb.PSEL <= 1;  // high
    dri_intf.driver_cb.PADDR <= paddr;
    dri_intf.driver_cb.PWRITE <= pwrite;
    dri_intf.driver_cb.PWDATA <= pwdata;
    dri_intf.driver_cb.PENABLE <= 0;  // low
  endtask

  task access_state();
    dri_intf.driver_cb.PSEL <= 1;  // high
    dri_intf.driver_cb.PENABLE <= 1;  // high
  endtask

  task drive();
    dri_intf.driver_cb.PRESETn <= trans.PRESETn;

    if (!trans.PRESETn) begin
      #20;
      dri_intf.driver_cb.PRESETn <= 1;
    end else begin

      idle_state();
      cycle();

      setup_state(trans.req.paddr, trans.req.pwrite, trans.req.pwdata);
      cycle();

      access_state();
      cycle();

      wait (dri_intf.driver_cb.PREADY == 1);
      idle_state();

    end
  endtask

  task main();
    forever begin
      gen2dri_mbx.get(trans);
      drive();
      trans.display("DRIVER");
    end
    ->dri_ended;
  endtask : main

endclass : driver
