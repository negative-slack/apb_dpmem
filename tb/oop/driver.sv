/********************************************
 *  Copyright (c) 2025 
 *  Author: negative-slack (Nader Alnatsheh).
 *  All rights reserved.
 *******************************************/

`ifndef DRIVER__SV
`define DRIVER__SV 

class Driver;

  virtual apb_if dri_intf;
  mailbox gen2dri_mbx;
  event dri_ended;

  Transaction trans;

  `define DRI dri_intf.driver_cb

  function new(virtual apb_if dri_intf, mailbox gen2dri_mbx, event dri_ended);
    this.dri_intf = dri_intf;
    this.gen2dri_mbx = gen2dri_mbx;
    this.dri_ended = dri_ended;
  endfunction

  task cycle();
    @(`DRI);
  endtask : cycle

  // deassert presetn for 5 clock cycles !
  task resetn();
    idle_state();
    // repeat (5)
    cycle();
    `DRI.PRESETn <= 1;
  endtask : resetn

  task idle_state();
    `DRI.PSEL <= 0;  // low 
    `DRI.PADDR <= '0;
    `DRI.PWRITE <= 0;
    `DRI.PWDATA <= '0;
    `DRI.PENABLE <= 0;  // low
  endtask

  task setup_state(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);
    `DRI.PSEL <= 1;  // high
    `DRI.PADDR <= paddr;
    `DRI.PSTRB <= pstrb;
    `DRI.PWRITE <= pwrite;
    `DRI.PWDATA <= pwdata;
    `DRI.PENABLE <= 0;  // low
  endtask

  task access_state();
    `DRI.PSEL <= 1;  // high
    `DRI.PENABLE <= 1;  // high
  endtask

  task drive_b2b_xfers(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);

    setup_state(paddr, pstrb, pwrite, pwdata);
    cycle();

    access_state();
    wait (`DRI.PREADY == 1);

  endtask

  task drive_xfers_w_idle(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);
    if (trans.idle_cycles > 0) begin
      repeat (trans.idle_cycles) begin
        idle_state();
        cycle();
      end

      setup_state(paddr, pstrb, pwrite, pwdata);
      cycle();

      access_state();
      wait (`DRI.PREADY == 1);

    end else begin
      idle_state();
      cycle();

      setup_state(paddr, pstrb, pwrite, pwdata);
      cycle();

      access_state();
      wait (`DRI.PREADY == 1);
    end
  endtask

  task drive();
    `DRI.PRESETn <= trans.PRESETn;

    if (!trans.PRESETn) begin
      resetn();
    end else if (!trans.back_to_back_xfers) begin
      drive_xfers_w_idle(trans.req.paddr, trans.req.pstrb, trans.req.pwrite, trans.req.pwdata);
    end else begin
      drive_b2b_xfers(trans.req.paddr, trans.req.pstrb, trans.req.pwrite, trans.req.pwdata);
    end
  endtask

  task run();
    for (int i = 0; i < Generator::num_trans; i++) begin
      gen2dri_mbx.get(trans);
      drive();
      trans.display("DRIVER");
    end
    ->dri_ended;
  endtask : run

  `undef DRI

endclass : Driver

`endif
