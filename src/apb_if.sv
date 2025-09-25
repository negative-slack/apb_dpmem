interface apb_if (
    input bit PCLK,
    input bit PRESETn
);
  import apb_pkg::*;

  addr_t PADDR;  // address to write to or read from!
  logic  PWRITE;  // 1: write, 0: read
  logic  PSEL;  // slave select
  logic  PENABLE;  // 2nd/subsequent cycle of the apb protocol
  data_t PWDATA;  // write data value

  data_t PRDATA;
  logic  PREADY;

  clocking master_cb @(posedge PCLK);
    default input #1step output #1ns;
    input PRDATA, PREADY;
    output PADDR, PWRITE, PSEL, PENABLE, PWDATA;
  endclocking

  clocking slave_cb @(posedge PCLK);
    default input #1step output #1ns;
    input PADDR, PWRITE, PSEL, PENABLE, PWDATA;
    output PRDATA, PREADY;
  endclocking

  modport master(input PCLK, PRESETn, PRDATA, PREADY, output PADDR, PWRITE, PSEL, PENABLE, PWDATA);

  modport slave(input PCLK, PRESETn, PADDR, PWRITE, PSEL, PENABLE, PWDATA, output PRDATA, PREADY);

  modport master_dv(input PCLK, PRESETn, clocking master_cb);

  modport slave_dv(input PCLK, PRESETn, clocking slave_cb);

endinterface
