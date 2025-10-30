`include "../src/apb_if.sv"

module top;

  bit clk;

  // clk generation
  initial begin
    clk = 0;
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

  bind apb_if apb_assertions apb_asserts_inst (.intf(top_intf.assert_mp));

endmodule

  // initial begin
  //   apb_if.slave.PRESETn = 1;
  //   apb_if.slave.PSEL = 0;
  //   apb_if.slave.PADDR = '0;
  //   apb_if.slave.PWRITE = 0;
  //   apb_if.slave.PWDATA = 32'hDEADDEAD;
  //   apb_if.slave.PENABLE = 0;
  // end