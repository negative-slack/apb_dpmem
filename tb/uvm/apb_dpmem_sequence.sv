`ifndef APB_DPMEM_SEQUENCE__SV
`define APB_DPMEM_SEQUENCE__SV 

`include "apb_dpmem_defines.sv"

class apb_dpmem_sequence extends uvm_sequence #(apb_dpmem_transaction);

  ///////////////////////////////////////////////////////////////////////////////
  // Declaration of Sequence utils
  //////////////////////////////////////////////////////////////////////////////
  `uvm_object_utils(apb_dpmem_sequence)

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : new
  // Description : sequence constructor
  //////////////////////////////////////////////////////////////////////////////
  function new(string name = "apb_dpmem_sequence");
    super.new(name);
  endfunction

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : body 
  // Description : Body of sequence to send randomized transaction through
  // sequencer to driver
  //////////////////////////////////////////////////////////////////////////////
  virtual task body();
    for (int i = 0; i < `NO_OF_TRANSACTIONS; i++) begin
      req = apb_dpmem_sequence::type_id::create("req");
      start_item(req);
      assert (req.randomize());
      `uvm_info(get_full_name(), $sformatf("RANDOMIZED TRANSACTION FROM SEQUENCE"), UVM_LOW);
      req.print();
      finish_item(req);
      get_response(rsp);
    end
  endtask

endclass

`endif
