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
  data_t scb_mem[0:`MEM_DEPTH-1];

  int scb_read_match_cnt;

  function new(mailbox mon2scb_mbx, event scb_ended);
    this.mon2scb_mbx = mon2scb_mbx;
    this.scb_ended   = scb_ended;
  endfunction

  function void write_display(string module_name);
    $display("");
    $display("+-------------------------+");
    $display("- %s", module_name);
    $display("+-------------------------+");
    $display(" Time: %0.3f ns", $time);
    $display("");
    $display("  PADDR:           0x%8h", trans.paddr,);
    $display("  PWRITE:          %b", trans.pwrite_string(trans.pwrite));
    $display("  PWDATA:          0x%8h", trans.pwdata);
    $display("  PSTRB:           %b", trans.pstrb);
    $display("  MEM BEFORE WRITE:0x%8h:", scb_mem[trans.paddr]);
    $display("  MEM AFTER WRITE: 0x%8h:", top.dut.MEM[trans.paddr]);
    $display("+-------------------------+");
  endfunction

  function void read_display(string module_name);
    $display("");
    $display("+-------------------------+");
    $display("- %s", module_name);
    $display("+-------------------------+");
    $display(" Time: %0.3f ns", $time);
    $display("");
    $display("  PADDR:    0x%8h", trans.paddr,);
    $display("  PWRITE:   %b", trans.pwrite_string(trans.pwrite));
    $display("  SCB_MEM:  0x%8h:", scb_mem[trans.paddr]);
    $display("  PRDATA:   0x%8h:", trans.prdata);
    $display("");
  endfunction

  task run();
    forever begin
      mon2scb_mbx.get(trans);
      if (trans.pwrite) begin
        write_display("SCOREBOARD");
        if (!(trans.paddr >= 10'h0 && trans.paddr <= 10'hf)) begin
          for (int i = 0; i < `APB_STRB_WIDTH; i++) begin
            if (trans.pstrb[i]) begin
              scb_mem[trans.paddr][(i*8)+:8] = trans.pwdata[(i*8)+:8];
            end
          end
        end
      end else begin
        assert (trans.prdata == scb_mem[trans.paddr])
        else
          $error(
              "Scoreboard ERROR; THERE IS A MISMATCH at addr %0h: expected %0h, got %0h",
              trans.paddr,
              scb_mem[trans.paddr],
              trans.prdata
          );
        if (trans.prdata == scb_mem[trans.paddr]) begin
          scb_read_match_cnt++;
          read_display("SCOREBOARD");
          $display("Scoreboard MATCH! \nThe READ Counter = %0d", scb_read_match_cnt);
          $display("+-------------------------+");
        end
      end
    end
    ->scb_ended;
  endtask : run

endclass : Scoreboard

`endif
