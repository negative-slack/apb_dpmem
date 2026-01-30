`ifndef APB_DPMEM_ENVIRONMENT__SV
`define APB_DPMEM_ENVIRONMENT__SV 

class apb_dpmem_environment extends uvm_env;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of component utils to register with factory 
  //////////////////////////////////////////////////////////////////////////////
  `uvm_component_utils(apb_dpmem_environment)

  //////////////////////////////////////////////////////////////////////////////
  // declare agent, ref_model, coverage, and scoreboard instances
  //////////////////////////////////////////////////////////////////////////////
  apb_dpmem_agent                             apb_dpmem_agnt;
  apb_dpmem_ref_model                         apb_dpmem_rfm;
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
    apb_dpmem_rfm  = apb_dpmem_ref_model::type_id::create("apb_dpmem_rfm", this);
    apb_dpmem_cvg  = apb_dpmem_coverage::type_id::create("apb_dpmem_cvg", this);
    apb_dpmem_scb  = apb_dpmem_scoreboard::type_id::create("apb_dpmem_scb", this);
  endfunction : build_phase

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : connect_phase 
  // Description : connect tlm ports ande exports (ex: analysis port/exports) 
  ///////////////////////////////////////////////////////////////////////////////
  function void connect_phase(uvm_phase phase);
    apb_dpmem_agnt.driver.dri2rm_port.connect(
        apb_dpmem_rfm.rm_export); // connect ports to send the tnxs seen by the driver to the ref model
    apb_dpmem_agnt.monitor.mon2scb_port.connect(
        apb_dpmem_scb.mon2scb_export); //connect ports to send the tnxs seen by the monitor to the scb 
    apb_dpmem_rfm.rm2scb_port.connect(
        apb_dpmem_scb.rm2scb_export); //connect ports to send the tnxs calculated by the ref model to the scb 
    apb_dpmem_agnt.monitor.mon2scb_port.connect(
        apb_dpmem_cvg.analysis_export);  // connect the monitor actual tnxs to the coverage
  endfunction : connect_phase

endclass : apb_dpmem_environment

`endif
