`ifndef DRIVER__SV
`define DRIVER__SV 

class driver;

  virtual apb_if dri_intf;
  mailbox gen2dri_mbx;
  event dri_ended;

  transaction trans;

  `define DRI dri_intf.driver_cb

  function new(virtual apb_if dri_intf, mailbox gen2dri_mbx, event dri_ended);
    this.dri_intf = dri_intf;
    this.gen2dri_mbx = gen2dri_mbx;
    this.dri_ended = dri_ended;
  endfunction

  task cycle();
    @(`DRI);
  endtask : cycle

  task idle_state();
    `DRI.PSEL <= 0;  // low 
    `DRI.PADDR <= '0;
    `DRI.PWRITE <= 0;
    `DRI.PWDATA <= '0;
    `DRI.PENABLE <= 0;  // low
  endtask

  task setup_state(input addr_t paddr, logic pwrite, data_t pwdata);
    `DRI.PSEL <= 1;  // high
    `DRI.PADDR <= paddr;
    `DRI.PWRITE <= pwrite;
    `DRI.PWDATA <= pwdata;
    `DRI.PENABLE <= 0;  // low
  endtask

  task access_state();
    `DRI.PSEL <= 1;  // high
    `DRI.PENABLE <= 1;  // high
  endtask

  task drive();
    `DRI.PRESETn <= trans.PRESETn;

    if (!trans.PRESETn) begin
      cycle();
      `DRI.PRESETn <= 1;
    end else begin

      idle_state();

      cycle();
      setup_state(trans.req.paddr, trans.req.pwrite, trans.req.pwdata);

      cycle();
      access_state();

      wait (`DRI.PREADY == 1);

    end
  endtask

  task run();
    for (int i = 0; i < 1000; i++) begin
      gen2dri_mbx.get(trans);
      drive();
      trans.display("DRIVER");
    end
    ->dri_ended;
  endtask : run

  `undef DRI

endclass : driver

`endif
