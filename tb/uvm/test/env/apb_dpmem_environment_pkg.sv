`ifndef APB_DPMEM_ENVIRONMENT_PKG__SV
`define APB_DPMEM_ENVIRONMENT_PKG__SV 

package apb_dpmem_environment_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import apb_dpmem_agent_pkg::*;
  import apb_dpmem_ref_model_pkg::*;
  import apb_dpmem_coverage_pkg::*;
  import apb_dpmem_scoreboard_pkg::*;

  //////////////////////////////////////////////////////////
  // include top env files 
  /////////////////////////////////////////////////////////
  // `include "./subscriber/apb_dpmem_coverage.sv"
  // `include "./scoreboard/apb_dpmem_scoreboard.sv"
  `include "./apb_dpmem_environment.sv"

endpackage

`endif
