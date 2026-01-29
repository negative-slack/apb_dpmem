`ifndef APB_DPMEM_SCOREBOARD_PKG__SV
`define APB_DPMEM_SCOREBOARD_PKG__SV 

package apb_dpmem_scoreboard_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import apb_dpmem_agent_pkg::*;
  import apb_dpmem_ref_model_pkg::*;
  import apb_dpmem_coverage_pkg::*;

  //////////////////////////////////////////////////////////
  // include scoreboard files 
  /////////////////////////////////////////////////////////
  `include "apb_dpmem_scoreboard.sv"

endpackage

`endif
