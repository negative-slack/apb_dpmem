`include "../../src/apb.sv"

module top;

  bit clk;

  // clk generation
  initial begin
    clk = 1;
    forever begin
      #10;
      clk = ~clk;
    end
  end

  initial begin
    $dumpfile("apb.vcd");
    $dumpvars(0, top);
    #50000 $stop;
  end

  apb_if top_intf (.PCLK(clk));

  test t1 (top_intf);

  apb dut (.apb_slave(top_intf));

  bind apb_if apb_assertions apb_asserts_dut (.intf(top_intf.monitor_mp));

endmodule
