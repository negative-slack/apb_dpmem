`ifndef APB_DPMEM_AGENT__SV
`define APB_DPMEM_AGENT__SV 

class apb_dpmem_agent extends uvm_agent;

  ///////////////////////////////////////////////////////////////////////////////
  // Declaration of component utils 
  ///////////////////////////////////////////////////////////////////////////////
  `uvm_component_utils(apb_dpmem_agent)

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : new 
  // Description : constructor
  ///////////////////////////////////////////////////////////////////////////////
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  ///////////////////////////////////////////////////////////////////////////////
  // Declaration of UVM components such as.. driver, sequencer, monitor 
  ///////////////////////////////////////////////////////////////////////////////
  apb_dpmem_driver    driver;
  apb_dpmem_sequencer sequencer;
  apb_dpmem_monitor   monitor;

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : build-phase 
  // Description : construct the components such as.. driver,monitor,sequencer..etc
  ///////////////////////////////////////////////////////////////////////////////
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver = apb_dpmem_driver::type_id::create("driver", this);
    sequencer = apb_dpmem_sequencer::type_id::create("sequencer", this);
    monitor = apb_dpmem_monitor::type_id::create("monitor", this);
  endfunction : build_phase

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : connect_phase 
  // Description : connect tlm ports ande exports (ex: analysis port/exports) 
  ///////////////////////////////////////////////////////////////////////////////
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase

endclass : apb_dpmem_agent

`endif
