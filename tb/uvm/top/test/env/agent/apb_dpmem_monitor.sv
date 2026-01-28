`ifndef APB_DPMEM_MONITOR__SV
`define APB_DPMEM_MONITOR__SV 

class apb_dpmem_monitor extends uvm_monitor;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of component utils to register with factory 
  //////////////////////////////////////////////////////////////////////////////
  `uvm_component_utils(apb_dpmem_monitor)

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Transaction item 
  //////////////////////////////////////////////////////////////////////////////
  apb_dpmem_sequence_item trans;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Virtual interface 
  //////////////////////////////////////////////////////////////////////////////
  virtual apb_if vif;

  ///////////////////////////////////////////////////////////////////////////////
  // Declaration of Analysis ports and exports
  // broadcasting the dut signals ? 
  ///////////////////////////////////////////////////////////////////////////////
  uvm_analysis_port #(apb_dpmem_sequence_item) mon2sb_ap;

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : new 
  // Description : constructor
  ///////////////////////////////////////////////////////////////////////////////
  function new(string name, uvm_component parent);
    super.new(name, parent);
    trans = new();
    mon2sb_ap = new("mon2sb_ap", this);
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

      if (`MON.PSEL && `MON.PENABLE && `MON.PREADY) begin

        trans = new();

        trans.PRESETn = `MON.PRESETn;

        trans.paddr = `MON.PADDR;
        trans.pwrite = `MON.PWRITE;
        trans.pwdata = `MON.PWDATA;
        trans.pstrb = `MON.PSTRB;

        trans.pready = `MON.PREADY;
        trans.prdata = `MON.PRDATA;
        trans.pslverr = `MON.PSLVERR;

        `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM MONITOR"), UVM_LOW);
        trans.print();
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
      mon2sb_ap.write(trans);
    end
  endtask : run_phase

endclass : apb_dpmem_monitor

`endif
