import apb_pkg::*;

class transaction;

  rand logic PRESETn;
  rand apb_req_t req;
  apb_rsp_t rsp;

  constraint dist_c {

    PRESETn dist {
      0 :/ 2,
      1 :/ 98
    };

    req.pwrite dist {
      0 :/ 50,
      1 :/ 50
    };

  }

  constraint pwdata_read_c {(req.pwrite == 0) -> (req.pwdata == 0);}

  function void display(string module_name);
    $display("-------------------------");
    $display("- %s ", module_name);
    $display("-------------------------");
    $display("t=%0.3f ns,  PADDR=%0h, PWRITE=%0b, PWDATA=%0h",  //
             $time, req.paddr, req.pwrite, req.pwdata);
  endfunction : display

endclass : transaction
