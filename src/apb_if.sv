`ifndef APB_IF__SV
`define APB_IF__SV 

interface apb_if (
    input bit PCLK
);

  import apb_pkg::*;

  // mst output
  logic  PRESETn;  // reset negative
  logic  PSEL;  // slave select
  addr_t PADDR;  // address to write to or read from
  logic  PWRITE;  // 0: read, 1: write 
  data_t PWDATA;  // write data value
  logic  PENABLE;  // 2nd/subsequent cycle of the apb protocol

  // slv output
  logic  PSLVERR;
  logic  PREADY;
  data_t PRDATA;

  clocking driver_cb @(posedge PCLK);
    // default input #1step output #1ns;
    input PSLVERR, PREADY, PRDATA;
    output PRESETn, PSEL, PADDR, PWRITE, PWDATA, PENABLE;
  endclocking

  clocking monitor_cb @(posedge PCLK);
    // default input #1step;
    input PRESETn, PSEL, PADDR, PWRITE, PWDATA, PENABLE, PSLVERR, PREADY, PRDATA;
  endclocking

  // use for synthesize
  modport slave(
      input PCLK, PRESETn, PSEL, PADDR, PWRITE, PWDATA, PENABLE,
      output PSLVERR, PREADY, PRDATA
  );

  // use for assertions (bind in the top class)
  modport monitor_mp(
      input PCLK, PRESETn, PSEL, PADDR, PWRITE, PWDATA, PENABLE, PSLVERR, PREADY, PRDATA
  );

  // use for verification
  modport driver_dv(clocking driver_cb);
  modport monitor_dv(clocking monitor_cb);

endinterface : apb_if

`endif
