import apb_pkg::*;

class transaction;

  rand apb_req_t req;
  apb_rsp_t rsp;

  constraint c1 {req.paddr < 3;}

  function void display(string module_name);
    $display("-------------------------");
    $display("- %s ", module_name);
    $display("-------------------------");
    $display("t=%0t, PADDR=%0h, PWRITE=%0b, PWDATA=%0h",  /////
             $time, req.paddr, req.pwrite, req.pwdata);
  endfunction : display

endclass : transaction
