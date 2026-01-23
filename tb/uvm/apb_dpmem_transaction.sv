`ifndef APB_DPMEM_TRANSACTION__SV
`define APB_DPMEM_TRANSACTION__SV 

`include "apb_dpmem_defines.sv"

class 
   extends uvm_sequence_item;

  typedef logic [`APB_ADDR_WIDTH-1:0] addr_t;
  typedef logic [`APB_DATA_WIDTH-1:0] data_t;
  typedef logic [`APB_STRB_WIDTH-1:0] strb_t;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of apb_dpmem transaction fields
  //////////////////////////////////////////////////////////////////////////////
  rand bit PRESETn;
  rand addr_t paddr;
  rand logic pwrite;
  rand data_t pwdata;
  rand strb_t pstrb;

  logic pready;
  data_t prdata;
  logic pslverr;

  // below variables are randomized to help if the next tnxs is b2b (w/o idle cycles) or not
  rand bit b2b_tnxs;  // 0: no b2b_tnxs, 1: there is a b2b_tnxs
  rand int unsigned idle_cycles;  // if b2b_txns is asserted, the # of idle_cycles = 0
  // below varaibles only help to constraint the paddr 
  rand int one_hot_index;
  rand int start_position;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Utility and Field Macros
  //////////////////////////////////////////////////////////////////////////////
  `uvm_object_utils_begin(apb_dpmem_transaction)

    `uvm_field_int(PRESETn, UVM_ALL_ON)
    `uvm_field_int(paddr, UVM_ALL_ON)
    `uvm_field_int(pwrite, UVM_ALL_ON)
    `uvm_field_int(pwdata, UVM_ALL_ON)
    `uvm_field_int(pstrb, UVM_ALL_ON)

    `uvm_field_int(b2b_tnxs, UVM_ALL_ON)
    `uvm_field_int(idle_cycles, UVM_ALL_ON)

  `uvm_object_utils_end

  //////////////////////////////////////////////////////////////////////////////
  // Method name : new 
  // Description : constructor 
  //////////////////////////////////////////////////////////////////////////////
  function new(string name = "apb_dpmem_transaction");
    super.new(name);
  endfunction : new

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Constraints
  //////////////////////////////////////////////////////////////////////////////

  // constraint to generate only one hot state values for the paddr
  // as an e.g. ; 0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0,80, 0x100
  // I was asked this constraint question by a broadcom engineer in 01/25
  constraint paddr_one_hot_index {
    one_hot_index inside {[0 : 9]};
    paddr == 1 << one_hot_index;
  }

  // constraint to generate a paddr value which has binary all 1s grouped together 
  // as an e.g, 00_1111_1000, 00_0011_1110, etc . . .
  // constraint paddr_all_1s_grouped_together {
  //   one_hot_index inside {[1 : 10]};
  //   start_position inside {[0 : 9]};
  //   paddr == ((1 << one_hot_index) - 1) << start_position;
  // }

  // constraint to only access the first 64B (first 16 addresses [0:15]) or last 64B (last 16 addresses [1008:1023]) region of a 1kB space
  // constraint paddr_c {req.paddr inside {[0 : 2 ** 4 - 1], [(2 ** 10 - 2 ** 4) : (2 ** 10 - 1)]};}

  // constraint to distribute the presetn 
  constraint presetn_dist_c {
    PRESETn dist {
      0 :/ 2,  // 2% (it actually appeared 13 times)
      1 :/ 98  // 98% (it actually appeared 987 times)
    };

    // PRESETn dist {
    //   0 := 20,  // 20/1000 
    //   1 := 980  // 980/1000 
    // };

  }

  // constraint to distribute the pwrite 
  constraint pwrite_dist_c {
    pwrite dist {
      0 :/ 50,  // 50% (it appeared exactly 496 times)
      1 :/ 50  // 50% (it appeared exactly 504 times)
    };
  }

  // // constraint to set pwdata to 0 if it is a read operation ! 
  // constraint pwrite_pwdata_c {(pwrite == 0) -> (pwdata == 0);}

  // // constraint to set pstrb to 0 if it is a read operation !
  // // according to the specs below "Section 3.2": 
  // // For read transfers, the Requester must drive all bits of PSTRB LOW.
  // constraint pwrite_pstrb_c {(pwrite == 0) -> (pstrb == 0);}

  // // constraint for pstrb to never be 0 when pwrite is 1
  // constraint pwrite_pstrb_c1 {(pwrite == 1) -> (pstrb != 0);}

  // all the three single constraints above could be combined in a one simple if/else statement since they are related to the pwrite as below
  constraint pwrite_pwdata_pstrb_c {
    if (!pwrite) {
      pwdata == 0;
      pstrb == 0;
    } else {
      pstrb != 0;
    }
  }

  // constraint to choose the number of idle_cycles between 0 - 5
  constraint idle_cycles_c {idle_cycles inside {[0 : 5]};}

  // constraint to set the # of idle cycles to 0, when it is a b2b transactions ! 
  constraint b2b_idle_cycles_c {(b2b_tnxs == 1) -> (idle_cycles == 0);}

  constraint b2b_idle_dist {
    b2b_tnxs dist {
      0 :/ 20,
      1 :/ 80
    };
  }

endclass

`endif
