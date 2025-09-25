module top;

  virtual apb_if vif;

  bit clk;
  bit rst_n;

  // clk generation
  initial begin
    clk = 1;
    forever begin
      #10;
      clk = ~clk;
    end
  end

  // reset_n generate for two clock cycles
  task reset_n();
    rst_n = 1'b0;
    @(negedge clk);
    @(negedge clk);
    rst_n = 1'b1;
  endtask

  vif intf_t (
      clk,
      rst_n
  );

  test t1 (intf_t);

  apb dut (apb_if.slave(intf_t));

  initial begin
    $dumpfile("apb.vcd");
    $dumpvars(0, top);
  end

  /*
  apb dut (
      .PCLK(intf_t.PCLK),
      .PRESETn(intf_t.PRESETn),
      .PADDR(intf_t.PADDR),
      .PWRITE(intf_t.PWRITE),
      .PSEL(intf_t.PSEL),
      .PENABLE(intf_t.PENABLE),
      .PWDATA(intf_t.PWDATA),
      .PRDATA(intf_t.PDATA),
      .PREADY(intf_t.PREADY)
  );
*/
endmodule
