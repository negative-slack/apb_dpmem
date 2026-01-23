`ifndef APB_DPMEM_SEQUENCER__SV
`define APB_DPMEM_SEQUENCER__SV 

class apb_dpmem_sequencer extends uvm_sequencer #(apb_dpmem_transaction);

  `uvm_component_utils(apb_dpmem_sequencer);

  ///////////////////////////////////////////////////////////////////////////////
  // Constructor
  ///////////////////////////////////////////////////////////////////////////////
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass

`endif
