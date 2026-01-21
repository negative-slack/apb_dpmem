`ifndef APB_DPMEM_SEQUENCE_ITEM__SV
`define APB_DPMEM_SEQUENCE_ITEM__SV 

class apb_dpmem_sequence_item extends uvm_sequence_item;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of apb_dpmem sequence item (transaction) fields
  //////////////////////////////////////////////////////////////////////////////
  rand apb_req_t req;
  apb_rsp_t rsp;
  rand bit b2b_tnxs;  // 0: no b2b_tnxs, 1: there is a b2b_tnxs
  rand int unsigned idle_cycles;  // if b2b_txns is asserted, the # of idle_cycles = 0
  // below varaibles only help to constraint the paddr 
  rand int one_hot_index;
  rand int start_position;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Utility and Field macros,
  //////////////////////////////////////////////////////////////////////////////
  `uvm_object_utils_begin(apb_dpmem_sequence_item)
    `uvm_field_int(req, UVM_ALL_ON)
    `uvm_field_int(rsp, UVM_ALL_ON)
    `uvm_field_int(b2b_tnxs, UVM_ALL_ON)
    `uvm_field_int(idle_cycles, UVM_ALL_ON)
    `uvm_field_int(one_hot_index, UVM_ALL_ON)
    `uvm_field_int(start_position, UVM_ALL_ON)
  `uvm_object_utils_end

  //////////////////////////////////////////////////////////////////////////////
  // Constructor
  //////////////////////////////////////////////////////////////////////////////
  function new(string name = "apb_dpmem_sequence_item");
    super.new(name);
  endfunction : new

endclass

`endif
