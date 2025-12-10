// MIT License

// Copyright (c) 2025 negative-slack (Nader Alnatsheh)

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

`ifndef TRANSACTION__SV
`define TRANSACTION__SV 

import apb_pkg::*;

class Transaction;

  rand apb_req_t req;
  apb_rsp_t rsp;
  rand bit b2b_tnxs;  // 0: no b2b_tnxs, 1: there is a b2b_tnxs
  rand int unsigned idle_cycles;  // if b2b_txns is asserted, the # of idle_cycles = 0

  // below varaibles only help to constraint the paddr 
  rand int one_hot_index;
  rand int start_position;

  // constraint to generate only one hot state values for the paddr
  // as an e.g. ; 0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0,80, 0x100
  // I was asked this constraint question by a broadcom engineer in 01/25
  constraint paddr_one_hot_index {
    one_hot_index inside {[0 : 9]};
    req.paddr == 1 << one_hot_index;
  }

  // constraint to generate a paddr value which has binary all 1s grouped together 
  // as an e.g, 00_1111_1000, 00_0011_1110, etc . . .
  // constraint paddr_all_1s_grouped_together {
  //   one_hot_index inside {[1 : 10]};
  //   start_position inside {[0 : 9]};
  //   req.paddr == ((1 << one_hot_index) - 1) << start_position;
  // }

  // constraint to distribute the presetn 
  constraint presetn_dist_c {
    req.PRESETn dist {
      0 :/ 2,  // 2% (it actually appeared 13 times)
      1 :/ 98  // 98% (it actually appeared 987 times)
    };

    // req.PRESETn dist {
    //   0 := 20,  // 20/1000 
    //   1 := 980  // 980/1000 
    // };

  }

  // constraint to distribute the pwrite 
  constraint pwrite_dist_c {
    req.pwrite dist {
      0 :/ 50,  // 50% (it appeared exactly 496 times)
      1 :/ 50  // 50% (it appeared exactly 504 times)
    };
  }

  // // constraint to set pwdata to 0 if it is a read operation ! 
  // constraint pwrite_pwdata_c {(req.pwrite == 0) -> (req.pwdata == 0);}

  // // constraint to set pstrb to 0 if it is a read operation !
  // // according to the specs below "Section 3.2": 
  // // For read transfers, the Requester must drive all bits of PSTRB LOW.
  // constraint pwrite_pstrb_c {(req.pwrite == 0) -> (req.pstrb == 0);}

  // // constraint for pstrb to never be 0 when pwrite is 1
  // constraint pwrite_pstrb_c1 {(req.pwrite == 1) -> (req.pstrb != 0);}

  // all the three single constraints above could be combined in a one simple if/else statement since they are related to the pwrite as below
  constraint pwrite_pwdata_pstrb_c {
    if (!req.pwrite) {
      req.pwdata == 0;
      req.pstrb == 0;
    } else {
      req.pstrb != 0;
    }
  }

  // constraint to choose the number of idle_cycles between 1 - 5
  constraint idle_cycles_c {idle_cycles inside {[0 : 5]};}

  // constraint to set the # of idle cycles to 0, when it is a b2b transactions ! 
  constraint b2b_idle_cycles_c {(b2b_tnxs == 1) -> (idle_cycles == 0);}

  constraint b2b_idle_dist {
    b2b_tnxs dist {
      0 :/ 20,
      1 :/ 80
    };
  }

  function void display(string module_name);
    if (module_name == "Generator" || module_name == "DRIVER") begin
      $display("");
      $display("-------------------------");
      $display("- %s", module_name);
      $display("-------------------------");
      $display(
          "t=%0.3f ns, \nPRESETn=%0b, PADDR=%0h, PWRITE=%0b, PWDATA=%0h, PSTRB=%0b, b2b_tnxs=%0b, idle_cycles=%0d",  //
          $time, req.PRESETn, req.paddr, req.pwrite, req.pwdata, req.pstrb, b2b_tnxs, idle_cycles);
    end else begin
      $display("");
      $display("-------------------------");
      $display("- %s", module_name);
      $display("-------------------------");
      $display(
          "t=%0.3f ns, \nINPUT SIGNALS: PRESETn=%0b, PADDR=0x%0h, PWRITE=%0b, PWDATA=0x%0h, PSTRB=%0b, \nOUTPUT SIGNLAS: PREADY=%0b, PRDATA=0x%0h, PSLVERR=%0b, DPMEM=0x%0h",  //
          $time,  //
          req.PRESETn, req.paddr, req.pwrite, req.pwdata, req.pstrb,  ///
          rsp.pready, rsp.prdata, rsp.pslverr, top.dut.MEM[req.paddr]);
    end
  endfunction : display

endclass : Transaction

`endif
