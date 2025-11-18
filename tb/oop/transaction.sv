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
  rand logic back_to_back_xfers;
  rand int unsigned idle_cycles;

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

  constraint pwrite_pwdata_c {(req.pwrite == 0) -> (req.pwdata == 0);}

  constraint pwrite_pstrb_c {(req.pwrite == 0) -> (req.pstrb == 0);}

  constraint idle_cycles_c {idle_cycles inside {[0 : 5]};}
  constraint b2b_psel_c {(back_to_back_xfers == 1) -> (idle_cycles == 0);}

  function void display(string module_name);
    $display("-------------------------");
    $display("- %s ", module_name);
    $display("-------------------------");
    $display(
        "t=%0.3f ns, PADDR=%0h, PSTRB=%0b, PWRITE=%0b, PWDATA=%0h, back_to_back_xfers=%0b, idle_cycles=%0d",  //
        $time, req.paddr, req.pstrb, req.pwrite, req.pwdata, back_to_back_xfers, idle_cycles);
  endfunction : display

endclass : Transaction

`endif
