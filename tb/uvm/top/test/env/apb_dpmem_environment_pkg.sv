`ifndef APB_DPMEM_ENVIRONMENT_PKG__SV
`define APB_DPMEM_ENVIRONMENT_PKG__SV 

package adder_4_bit_env_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  //////////////////////////////////////////////////////////
  // importing packages : agent,ref model, register ...
  /////////////////////////////////////////////////////////
  import apb_dpmem_agent_pkg::*;
  import apb_dpmem_ref_model_pkg::*;

  //////////////////////////////////////////////////////////
  // include top env files 
  /////////////////////////////////////////////////////////
  `include "../subscriber/apb_dpmem_coverage.sv"
  `include "../scoreboard/apb_dpmem_scoreboard.sv"
  `include "../env/apb_dpmem_environment.sv"

endpackage

`endif
