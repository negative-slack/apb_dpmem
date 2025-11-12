/********************************************
 *  Copyright (c) 2025 
 *  Author: negative-slack (Nader Alnatsheh).
 *  All rights reserved.
 *******************************************/

`ifndef TRANSACTION__SV
`define TRANSACTION__SV 

import apb_pkg::*;

class Transaction;

  rand logic PRESETn;
  rand apb_req_t req;
  apb_rsp_t rsp;
  rand int pready_delay;

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

  constraint pready_delay_c {pready_delay inside {[0 : 4]};}

  function void display(string module_name);
    $display("-------------------------");
    $display("- %s ", module_name);
    $display("-------------------------");
    $display("t=%0.3f ns, PADDR=%0h, PWRITE=%0b, PWDATA=%0h, pready_delay=%0d",  //
             $time, req.paddr, req.pwrite, req.pwdata, pready_delay);
  endfunction : display

endclass : Transaction

`endif
