`ifndef APB_DPMEM_ENVIRONMENT__SV
`define APB_DPMEM_ENVIRONMENT__SV 

class apb_dpmem_environment extends uvm_env;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of component utils to register with factory 
  //////////////////////////////////////////////////////////////////////////////
  `uvm_component_utils(apb_dpmem_environment)

  //////////////////////////////////////////////////////////////////////////////
  // agent and scoreboard instance
  //////////////////////////////////////////////////////////////////////////////
  apb_dpmem_agent                             apb_dpmem_agnt;
  apb_dpmem_ref_model                         apb_dpmem_rm;
  apb_dpmem_coverage #(apb_dpmem_transaction) apb_dpmem_cvg;
  apb_dpmem_scoreboard                        apb_dpmem_scb;

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : new 
  // Description : constructor
  ///////////////////////////////////////////////////////////////////////////////
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : build-phase 
  // Description : construct the components such as.. agent, scoreboard 
  ///////////////////////////////////////////////////////////////////////////////
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_dpmem_agnt = apb_dpmem_agent::type_id::create("apb_dpmem_agnt", this);
    apb_dpmem_rm   = apb_dpmem_ref_model::type_id::create("apb_dpmem_rm", this);
    apb_dpmem_cvg  = apb_dpmem_coverage::type_id::create("apb_dpmem_cvg", this);
    apb_dpmem_scb  = apb_dpmem_scoreboard::type_id::create("apb_dpmem_scb", this);
  endfunction : build_phase

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : connect_phase 
  // Description : connect tlm ports ande exports (ex: analysis port/exports) 
  ///////////////////////////////////////////////////////////////////////////////
  function void connect_phase(uvm_phase phase);
    apb_dpmem_agnt.driver.dri2rm_port.connect(apb_dpmem_rm.rm_export);
    apb_dpmem_agnt.monitor.mon2scb_port.connect(apb_dpmem_scb.mon2scb_export);
    apb_dpmem_rm.rm2scb_port.connect(apb_dpmem_cvg.analysis_export);
    apb_dpmem_rm.rm2scb_port.connect(apb_dpmem_scb.rm2scb_export);
  endfunction : connect_phase

endclass : apb_dpmem_model_env

`endif
