`include "../src/apb_if.sv"

module top;

  bit clk;
  bit rst_n;

  // reset_n generate for two clock cycles
  initial begin
    rst_n = 1'b0;
    @(negedge clk);
    rst_n = 1'b1;
  end

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
  end

  apb_if intf_t (
      .PCLK(clk),
      .PRESETn(rst_n)
  );

  test t1 (intf_t);

  apb dut (.apb_slave(intf_t));

endmodule
