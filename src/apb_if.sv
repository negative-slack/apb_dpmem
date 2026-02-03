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

`ifndef APB_IF__SV
`define APB_IF__SV 

interface apb_if
  import apb_dpmem_pkg::*;
(
    input bit PCLK,    // system clk
    input bit PRESETn  // system reset negative
);

  // mst output signals : (a master example is an AHB2APB bridge)
  // below are the control signals of a single transaction
  logic PSEL;  // slave select, when asserted indicates the start of the transaction
  logic PENABLE;  // low indicates the first cycle of the transaction (setup state), and must be 1 in the following cycle > which indicates the 2nd/subsequent cycle (access state) of the apb protocol
  addr_t PADDR;  // address to write to or read from
  logic PWRITE;  // 0: read, 1: write
  // below signals have a value other than '0, only when PWRITE is asserted for a write transaction (will be controlled via a constraint)
  data_t PWDATA;  // write data value
  strb_t PSTRB;  // write strobe; indicates which byte lane to update during a write transaction (16 diff choice)

  // slv output signals
  logic PREADY; // only when PREADY is high it indicates the end of the tnx, read data is avaialbe at the same clock cycle with 0 delay. For a write tnxs, we update the memory after 1 delay cycle! (When PREADY = 0)
  data_t PRDATA;
  logic PSLVERR;

  /**************************************************
  / USE FOR SYNTHESIS
  **************************************************/
  modport slv_mp(
      input PCLK, PRESETn, PSEL, PADDR, PWRITE, PWDATA, PSTRB, PENABLE,
      output PREADY, PRDATA, PSLVERR
  );

  // modport mst_mp(
  //     output PSEL, PADDR, PWRITE, PWDATA, PSTRB, PENABLE,
  //     input PCLK, PRESETn, PREADY, PRDATA, PSLVERR
  // );

  /**************************************************
  / USED FOR VERIFICATION
  **************************************************/
  clocking driver_cb @(posedge PCLK);
    default input #1step output #1ns;
    input PREADY, PRDATA, PSLVERR;
    output PRESETn, PSEL, PADDR, PWRITE, PWDATA, PSTRB, PENABLE;
  endclocking

  clocking monitor_cb @(posedge PCLK);
    default input #1step;
    input PRESETn, PSEL, PADDR, PWRITE, PWDATA, PSTRB, PENABLE, PREADY, PRDATA, PSLVERR;
  endclocking

  modport driver_dv(clocking driver_cb);
  modport monitor_dv(clocking monitor_cb);

  // use for APB PROTOCOL assertions (will bind in the top class)
  modport sva_mp(
      input PCLK, PRESETn, PSEL, PADDR, PWRITE, PWDATA, PSTRB, PENABLE, PREADY, PRDATA, PSLVERR
  );

endinterface : apb_if

`endif
