`ifndef APB_DPMEM_TEST_PKG__SV
`define APB_DPMEM_TEST_PKG__SV 

package apb_dpmem_test_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import apb_dpmem_agent_pkg::*;
  import apb_dpmem_ref_model_pkg::*;
  import apb_dpmem_coverage_pkg::*;
  import apb_dpmem_scoreboard_pkg::*;
  import apb_dpmem_environment_pkg::*;
  import apb_dpmem_sequence_pkg::*;

  //////////////////////////////////////////////////////////
  // include test files 
  /////////////////////////////////////////////////////////
  `include "./apb_dpmem_test.sv"

endpackage

`endif
