`ifndef APB_DPMEM_SEQUENCE_PKG__SV
`define APB_DPMEM_SEQUENCE_PKG__SV 

package apb_dpmem_sequence_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import apb_dpmem_agent_pkg::*;
  import apb_dpmem_ref_model_pkg::*;
  import apb_dpmem_coverage_pkg::*;
  import apb_dpmem_scoreboard_pkg::*;
  import apb_dpmem_environment_pkg::*;

  //////////////////////////////////////////////////////////
  // include top env files 
  /////////////////////////////////////////////////////////
//   `include "../env/subscriber/apb_dpmem_coverage.sv"
//   `include "../env/scoreboard/apb_dpmem_scoreboard.sv"
//   `include "../env/apb_dpmem_environment.sv"
  `include "./apb_dpmem_sequence.sv"

endpackage

`endif
