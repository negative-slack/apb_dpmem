interface apb_if(
        logic                   PCLK,
        logic                   PRESETn
    );
    import apb_pkg::*;

    logic [ADDR_WIDTH-1:0]  PADDR; // address to wite to or read from!
    logic                   PWRITE; // 1: write, 0: read
    logic                   PSEL; // slave select
    logic                   PENABLE; // 2nd/subsequent cycle of the apb protocol
    logic [DATA_WIDTH-1:0]  PWDATA; // write data value

    logic [DATA_WIDTH-1:0]  PRDATA;
    logic                   PREADY;
    
    modport master(input PCLK, PRESETn, PRDATA, PREADY,
        output PADDR, PWRITE, PSEL, PENABLE, PWDATA);

    modport slave(input PCLK, PRESETn, PADDR, PWRITE, PSEL, PENABLE, PWDATA,
        output PRDATA, PREADY);

endinterface