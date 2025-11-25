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

  rand int one_hot_index;
  rand int start_position;

  // // constraint to generate only one hot state values for the paddr
  // constraint paddr_one_hot_index {
  //   one_hot_index inside {[0 : 9]};
  //   req.paddr == 1 << one_hot_index;
  // }

  // constraint to generate a paddr value which has binary all 1s grouped together 
  constraint paddr_all_1s_grouped_together {
    one_hot_index inside {[1 : 10]};
    start_position inside {[0 : 9]};
    req.paddr == ((1 << one_hot_index) - 1) << start_position;
  }

  // constraint to distribute the presetn 
  constraint presetn_dist_c {
    PRESETn dist {
      0 :/ 2,  // 2% (it actually appeared 22 times)
      1 :/ 98  // 98% (it actually appeared 978 times)
    };
  }

  // constraint to distribute the pwrite 
  constraint pwrite_dist_c {
    req.pwrite dist {
      0 :/ 50,  // 50% (it appeared exactly 500 times)
      1 :/ 50  // 50% (it appeared exactly 500 times)
    };
  }

  // constraint to set pwdata to 0 if it is a read operation ! 
  constraint pwrite_pwdata_c {(req.pwrite == 0) -> (req.pwdata == 0);}

  // constraint to set pstrb to 0 if it is a read operation !
  // according to the specs below "Section 3.2": 
  // For read transfers, the Requester must drive all bits of PSTRB LOW.
  constraint pwrite_pstrb_c {(req.pwrite == 0) -> (req.pstrb == 0);}

  // constraint to choose the number of idle_cycles between 1 - 5
  constraint idle_cycles_c {idle_cycles inside {[1 : 5]};}

  // constraint to set the # of idle cycles to 0, when it is a b2b transactions ! 
  constraint b2b_psel_c {(back_to_back_xfers == 1) -> (idle_cycles == 0);}

  function void display(string module_name);
    $display("-------------------------");
    $display("- %s", module_name);
    $display("-------------------------");
    $display(
        "t=%0.3f ns, PADDR=%0h, PSTRB=%0b, PWRITE=%0b, PWDATA=%0h, back_to_back_xfers=%0b, idle_cycles=%0d",  //
        $time, req.paddr, req.pstrb, req.pwrite, req.pwdata, back_to_back_xfers, idle_cycles);
  endfunction : display

endclass : Transaction

`endif
