import apb_pkg::*;

class transaction;

  rand addr_t PADDR;
  rand bit    PWRITE;
  bit         PSEL;
  bit         PENABLE;
  rand data_t PWDATA;

  data_t      PRDATA;
  bit         PREADY;

  function void display(string module_name);
    $display("-------------------------");
    $display("- %s ", module_name);
    $display("-------------------------");
    $display(
        "t=%0t, PADDR=%0h, PWRITE=%0b, PSEL=%0b, PENABLE=%0b, PWDATA=%0h, PRDATA=%0h, PREADY=%0b",
        $time, PADDR, PWRITE, PSEL, PENABLE, PWDATA, PRDATA, PREADY);
  endfunction : display

endclass : transaction
