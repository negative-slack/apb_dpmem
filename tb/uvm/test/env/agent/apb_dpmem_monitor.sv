`ifndef APB_DPMEM_MONITOR__SV
`define APB_DPMEM_MONITOR__SV 

class apb_dpmem_monitor extends uvm_monitor;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of component utils to register with factory 
  //////////////////////////////////////////////////////////////////////////////
  `uvm_component_utils(apb_dpmem_monitor)

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of the ACTUAL Transaction captured from the DUT  
  //////////////////////////////////////////////////////////////////////////////
  apb_dpmem_transaction act_trans;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Virtual interface 
  //////////////////////////////////////////////////////////////////////////////
  virtual apb_if vif;

  ///////////////////////////////////////////////////////////////////////////////
  // Declaration of Analysis ports and exports
  // broadcasting the ACTUAL transactions to the scoreboard, so we can compare them 
  // later with the expected transactions from the reference model
  ///////////////////////////////////////////////////////////////////////////////
  uvm_analysis_port #(apb_dpmem_transaction) mon2scb_port;

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : new 
  // Description : constructor
  ///////////////////////////////////////////////////////////////////////////////
  function new(string name, uvm_component parent);
    super.new(name, parent);
    act_trans = new();
    mon2scb_port = new("mon2scb_port", this);
  endfunction : new

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : build_phase 
  // Description : construct the components
  ///////////////////////////////////////////////////////////////////////////////
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction : build_phase

  `define MON vif.monitor_cb

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : collect_actual_trans 
  // Description : run task for collecting adder_4_bit transactions
  ///////////////////////////////////////////////////////////////////////////////
  task collect_trans();

    @(`MON);
    if (`MON.PRESETn)
      if (`MON.PSEL && `MON.PENABLE && `MON.PREADY) begin

        act_trans.presetn = `MON.PRESETn;

        act_trans.paddr   = `MON.PADDR;
        act_trans.pwrite  = `MON.PWRITE;
        act_trans.pwdata  = `MON.PWDATA;
        act_trans.pstrb   = `MON.PSTRB;

        act_trans.pready  = `MON.PREADY;
        act_trans.prdata  = `MON.PRDATA;
        act_trans.pslverr = `MON.PSLVERR;

        `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM MONITOR"), UVM_LOW);
        act_trans.print();
      end

  endtask

  `undef MON

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : run_phase 
  // Description : Extract the info from DUT via interface 
  ///////////////////////////////////////////////////////////////////////////////
  virtual task run_phase(uvm_phase phase);
    forever begin
      collect_trans();
      mon2scb_port.write(act_trans);
    end
  endtask : run_phase

endclass : apb_dpmem_monitor

`endif
