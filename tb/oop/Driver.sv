// MIT License

// Copyright (c) 2025 negative-slack (Nader Alnatsheh)

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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

  // deassert presetn for 1 clock cycles !
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
    `DRI.PSTRB <= '0;
    `DRI.PENABLE <= 0;  // low
  endtask

  task setup_state(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);
    `DRI.PSEL <= 1;  // high
    `DRI.PADDR <= paddr;
    `DRI.PWRITE <= pwrite;
    `DRI.PWDATA <= pwdata;
    `DRI.PSTRB <= pstrb;
    `DRI.PENABLE <= 0;  // low
  endtask

  task access_state();
    `DRI.PSEL <= 1;  // high
    `DRI.PENABLE <= 1;  // high
  endtask

  task drive_b2b_tnxs(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);
    // start directly from the setup_state
    setup_state(paddr, pstrb, pwrite, pwdata);
    cycle();

    access_state();
    wait (`DRI.PREADY == 1);
  endtask

  task drive_tnxs_w_idle(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);
    if (trans.idle_cycles > 0) begin  // idle cycle here anywhere between 1 and 5
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
    `DRI.PRESETn <= trans.presetn;

    if (!trans.presetn) begin
      resetn();
    end else if (!trans.b2b_tnxs) begin
      drive_tnxs_w_idle(trans.paddr, trans.pstrb, trans.pwrite, trans.pwdata);
    end else begin
      drive_b2b_tnxs(trans.paddr, trans.pstrb, trans.pwrite, trans.pwdata);
    end
  endtask

  task run();
    for (int i = 0; i < `NUM_OF_TRANSACTIONS; i++) begin
      gen2dri_mbx.get(trans);
      drive();
      $display("");
      trans.display("DRIVER");
    end
    ->dri_ended;
  endtask : run

  `undef DRI

endclass : Driver

`endif
