/********************************************
 *  Copyright (c) 2025 
 *  Author: negative-slack (Nader Alnatsheh).
 *  All rights reserved.
 *******************************************/

`include "../../src/apb_if.sv"
`include "../../src/apb_dp_mem.sv"

module top;

  bit clk;

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

  apb_if top_intf (.PCLK(clk));

  test t1 (.test_intf(top_intf));

  apb_dp_mem dut (.apb_slave(top_intf.slv_mp));

  bind apb_if apb_assertions apb_asserts_dut (.assert_intf(top_intf.monitor_mp));

endmodule
