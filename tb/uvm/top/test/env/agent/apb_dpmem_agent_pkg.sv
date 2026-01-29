`ifndef APB_DPMEM_AGENT_PKG__SV
`define APB_DPMEM_AGENT_PKG__SV 

package apb_dpmem_agent_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  //////////////////////////////////////////////////////////
  // include Agent components : sequencer, driver, monitor
  /////////////////////////////////////////////////////////
  `include "apb_dpmem_transaction.sv"
  `include "apb_dpmem_sequencer.sv"
  `include "apb_dpmem_driver.sv"
  `include "apb_dpmem_monitor.sv"
  `include "apb_dpmem_agent.sv"

endpackage : apb_dpmem_agent_pkg

`endif
