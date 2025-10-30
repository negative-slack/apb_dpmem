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

  // task drive();
  //   dri_intf.driver_cb.PRESETn <= trans.PRESETn;

  //   if (dri_intf.driver_cb.PRESETn) begin
  //     #20;
  //     dri_intf.driver_cb.PRESETn <= 1;
  //   end else begin
  //     cycle();

  //     idle_state();
  //     cycle();

  //     setup_state(trans.req.paddr, trans.req.pwrite, trans.req.pwdata);
  //     cycle();

  //     access_state();
  //     cycle();

  //     wait (dri_intf.driver_cb.PREADY == 1);

  //   end
  // endtask
  task drive();
    dri_intf.driver_cb.PRESETn <= trans.PRESETn;

    // Wait for reset to propagate
    // cycle();

    if (!trans.PRESETn) begin  // 🎯 Read from monitor clocking
      #20;
      dri_intf.driver_cb.PRESETn <= 1;
      cycle();  // Wait for reset release to propagate
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

/*
task apb_write(input logic presetn, addr_t paddr, logic pwrite, data_t pwdata);

    // setup_phase
    cycle_start();
    dri_intf.driver_dv.PRESETn <= presetn;
    dri_intf.driver_dv.driver_cb.PADDR <= paddr;
    dri_intf.driver_dv.driver_cb.PWRITE <= 1;
    dri_intf.driver_dv.driver_cb.PSEL <= 1;
    dri_intf.driver_dv.driver_cb.PENABLE <= 0;
    dri_intf.driver_dv.driver_cb.PWDATA <= pwdata;

    // access_phase
    cycle_start();
    dri_intf.driver_dv.driver_cb.PENABLE <= 1;  // HIGH NOW

    wait (dri_intf.driver_dv.driver_cb.PREADY == 1);
    // cycle_start();
    dri_intf.driver_dv.driver_cb.PADDR <= 0;
    dri_intf.driver_dv.driver_cb.PWRITE <= 0;
    dri_intf.driver_dv.driver_cb.PSEL <= 0;
    dri_intf.driver_dv.driver_cb.PENABLE <= 0;
    dri_intf.driver_dv.driver_cb.PWDATA <= 0;
  endtask

  task apb_read(input logic presetn, addr_t paddr, output data_t prdata);

    cycle_start();
    dri_intf.driver_dv.PRESETn <= presetn;
    dri_intf.driver_dv.driver_cb.PADDR <= paddr;
    dri_intf.driver_dv.driver_cb.PWRITE <= 0;
    dri_intf.driver_dv.driver_cb.PSEL <= 1;
    dri_intf.driver_dv.driver_cb.PENABLE <= 0;

    cycle_start();
    dri_intf.driver_dv.driver_cb.PENABLE <= 1;  // HIGH NOW

    wait (dri_intf.driver_dv.driver_cb.PREADY == 1);
    prdata = dri_intf.driver_dv.driver_cb.PRDATA;

    // cycle_start();
    dri_intf.driver_dv.driver_cb.PADDR <= 0;
    dri_intf.driver_dv.driver_cb.PWRITE <= 0;
    dri_intf.driver_dv.driver_cb.PSEL <= 0;
    dri_intf.driver_dv.driver_cb.PENABLE <= 0;
  endtask

        if (trans.PRESETn) begin
        if (trans.req.pwrite == 1) begin
          apb_write(trans.PRESETn, trans.req.paddr, trans.req.pwrite, trans.req.pwdata);
        end else begin
          apb_read(trans.PRESETn, trans.req.paddr, trans.rsp.prdata);
        end

*/
