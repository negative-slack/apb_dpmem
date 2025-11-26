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

`include "../../src/apb_if.sv"
`include "../../src/apb_dpmem.sv"

module top;

  bit clk;
  bit resetn;

  // clk generation
  initial begin
    clk = 1;
    forever begin
      #5;
      clk = ~clk;
    end
  end

  initial begin
    $dumpfile("apb.vcd");
    $dumpvars(0, top);
  end

  apb_if top_intf (
      .PCLK(clk),
      .PRESETn(resetn)
  );

  Test t1 (.test_intf(top_intf));

  apb_dpmem dut (.apb_slave(top_intf.slv_mp));

  bind apb_if apb_assertions apb_asserts_dut (.assert_intf(top_intf.monitor_mp));

endmodule : top
