`ifndef APB_DPMEM_COVERAGE_PKG__SV
`define APB_DPMEM_COVERAGE_PKG__SV 

package apb_dpmem_coverage_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  //////////////////////////////////////////////////////////
  // importing packages : agent, ref model
  /////////////////////////////////////////////////////////
  import apb_dpmem_agent_pkg::*;
  import apb_dpmem_ref_model_pkg::*;

  //////////////////////////////////////////////////////////
  // include the coverage file 
  /////////////////////////////////////////////////////////
  `include "apb_dpmem_coverage.sv"

endpackage

`endif
