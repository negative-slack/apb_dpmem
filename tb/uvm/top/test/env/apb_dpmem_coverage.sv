`ifndef APB_DPMEM_COVERAGE__SV
`define APB_DPMEM_COVERAGE__SV 

class apb_dpmem_coverage #(
    type T = apb_dpmem_transaction
) extends uvm_subscriber #(T);

  `uvm_component_utils(apb_dpmem_coverage);

  function new(string name = "apb_dpmem_coverage", uvm_component parent);
    super.new(name, parent);

  endfunction
  
endclass
`endif
