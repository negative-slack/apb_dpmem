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

`ifndef MONITOR__SV
`define MONITOR__SV 

class Monitor;

  virtual apb_if mon_intf;
  mailbox mon2scb_mbx;
  event mon_ended;

  Transaction trans;

  `define MON mon_intf.monitor_cb

  function new(virtual apb_if mon_intf, mailbox mon2scb_mbx, event mon_ended);
    this.mon_intf = mon_intf;
    this.mon2scb_mbx = mon2scb_mbx;
    this.mon_ended = mon_ended;
  endfunction

  task run();

    forever begin

      @(`MON);

      if (`MON.PSEL && `MON.PENABLE && `MON.PREADY) begin

        trans = new();

        trans.req.PRESETn = `MON.PRESETn;

        trans.req.paddr = `MON.PADDR;
        trans.req.pwrite = `MON.PWRITE;
        trans.req.pwdata = `MON.PWDATA;
        trans.req.pstrb = `MON.PSTRB;

        trans.rsp.pready = `MON.PREADY;
        trans.rsp.prdata = `MON.PRDATA;
        trans.rsp.pslverr = `MON.PSLVERR;

        trans.display("MONITOR");
        mon2scb_mbx.put(trans);
      end
    end
    ->mon_ended;
  endtask

  `undef MON

endclass : Monitor

`endif
