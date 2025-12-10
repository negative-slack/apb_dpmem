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

`ifndef SCOREBOARD__SV
`define SCOREBOARD__SV 

class Scoreboard;

  Transaction trans;
  mailbox mon2scb_mbx;
  event scb_ended;

  // define scoreboard memory
  localparam MEM_DEPTH = 1 << `APB_ADDR_WIDTH;
  data_t scb_mem[0:MEM_DEPTH-1];

  int scb_read_match_cnt;

  function new(mailbox mon2scb_mbx, event scb_ended);
    this.mon2scb_mbx = mon2scb_mbx;
    this.scb_ended   = scb_ended;
  endfunction

  function void display(string module_name);
    $display("");
    $display("+-------------------------+");
    $display("- %s", module_name);
    $display("+-------------------------+");
    $display(" Time: %0.3f ns", $time);
    $display("");
    $display("  PADDR:           0x%8h", trans.req.paddr,);
    $display("  PWRITE:          %b", trans.req.pwrite);
    $display("  PWDATA:          0x%8h", trans.req.pwdata);
    $display("  PSTRB:           %b", trans.req.pstrb);
    $display("  MEM BEFORE WRITE:0x%8h:", scb_mem[trans.req.paddr]);
    $display("  MEM AFTER WRITE: 0x%8h:", top.dut.MEM[trans.req.paddr]);
    $display("+-------------------------+");
  endfunction

  task run();
    for (int i = 0; i < Generator::num_tnxs; ++i) begin
      mon2scb_mbx.get(trans);
      display("SCOREBOARD");
      if (trans.req.pwrite) begin
        if (!(trans.req.paddr >= 10'h0 && trans.req.paddr <= 10'hf)) begin
          for (int i = 0; i < `APB_STRB_WIDTH; i++) begin
            if (trans.req.pstrb[i]) begin
              scb_mem[trans.req.paddr][(i*8)+:8] = trans.req.pwdata[(i*8)+:8];
            end
          end
        end
      end else begin
        assert (trans.rsp.prdata == scb_mem[trans.req.paddr])
        else
          $error(
              "Scoreboard ERROR; THERE IS A MISMATCH at addr %0h: expected %0h, got %0h",
              trans.req.paddr,
              scb_mem[trans.req.paddr],
              trans.rsp.prdata
          );
        if (trans.rsp.prdata == scb_mem[trans.req.paddr]) begin
          scb_read_match_cnt++;
          $display("Scoreboard MATCH! READ Counter = %0d", scb_read_match_cnt);
        end
      end
    end
    ->scb_ended;
  endtask : run

endclass : Scoreboard

`endif
