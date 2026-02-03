`ifndef APB_DPMEM_DRIVER__SV
`define APB_DPMEM_DRIVER__SV 

// Because of this WARNING below I decalred the input outside the class ! 
// WARNING: [VRFC 10-9281] package import cannot be inside a class
import apb_dpmem_pkg::*;

class apb_dpmem_driver extends uvm_driver #(apb_dpmem_transaction);

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of component utils to register with factory 
  //////////////////////////////////////////////////////////////////////////////
  `uvm_component_utils(apb_dpmem_driver)

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Transaction item 
  //////////////////////////////////////////////////////////////////////////////
  // apb_dpmem_transaction req;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Virtual interface 
  //////////////////////////////////////////////////////////////////////////////
  virtual apb_if.driver_dv vif;

  ///////////////////////////////////////////////////////////////////////////////
  // Declaration of Analysis ports and exports 
  // Description : Broadcasts a value to all subscribers implementing a uvm_analysis_imp.
  // broadcasting the transactions signals to the ref models
  // (basically whatever the driver sees as a transaction, it will be send to the ref model to calculate the expected transactions) 
  ///////////////////////////////////////////////////////////////////////////////
  uvm_analysis_port #(apb_dpmem_transaction) dri2rm_port;

  //////////////////////////////////////////////////////////////////////////////
  // Method name : new 
  // Description : Creates and initializes an instance of this class using the
  //               normal constructor arguments for uvm_component: 
  //               - name is the name of the instance,
  //               - parent is the handle to the hierarchical parent, if any. 
  //////////////////////////////////////////////////////////////////////////////
  function new(string name, uvm_component parent);
    super.new(name, parent);
    dri2rm_port = new("dri2rm_port", this);
  endfunction : new

  `define DRI vif.driver_cb

  task cycle();
    @(`DRI);
  endtask : cycle

  task idle_state();
    `DRI.PSEL <= 0;  // low 
    `DRI.PADDR <= '0;
    `DRI.PWRITE <= 0;
    `DRI.PWDATA <= '0;
    `DRI.PSTRB <= '0;
    `DRI.PENABLE <= 0;  // low
  endtask : idle_state

  task setup_state(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);
    `DRI.PSEL <= 1;  // high
    `DRI.PADDR <= paddr;
    `DRI.PWRITE <= pwrite;
    `DRI.PWDATA <= pwdata;
    `DRI.PSTRB <= pstrb;
    `DRI.PENABLE <= 0;  // low
  endtask : setup_state

  task access_state();
    `DRI.PSEL <= 1;  // high
    `DRI.PENABLE <= 1;  // high
  endtask : access_state

  task drive_b2b_tnxs(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);
    // start directly from the setup_state
    setup_state(paddr, pstrb, pwrite, pwdata);
    cycle();

    access_state();
    wait (`DRI.PREADY == 1);
  endtask : drive_b2b_tnxs

  task drive_tnxs_w_idle(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);
    if (req.idle_cycles > 0) begin  // idle cycle here anywhere between 1 and 5
      repeat (req.idle_cycles) begin
        idle_state();
        cycle();
      end

      setup_state(paddr, pstrb, pwrite, pwdata);
      cycle();

      access_state();
      wait (`DRI.PREADY == 1);

    end else begin
      idle_state();
      cycle();

      setup_state(paddr, pstrb, pwrite, pwdata);
      cycle();

      access_state();
      wait (`DRI.PREADY == 1);
    end
  endtask : drive_tnxs_w_idle

  // deassert presetn for 1 clock cycle only !
  task resetn();
    idle_state();
    cycle();
    `DRI.PRESETn <= 1;
  endtask : resetn

  task drive();
    `DRI.PRESETn <= req.presetn;

    if (!req.presetn) begin
      resetn();
    end else if (!req.b2b_tnxs) begin
      drive_tnxs_w_idle(req.paddr, req.pstrb, req.pwrite, req.pwdata);
    end else begin
      drive_b2b_tnxs(req.paddr, req.pstrb, req.pwrite, req.pwdata);
    end
  endtask : drive

  `undef DRI

  //////////////////////////////////////////////////////////////////////////////
  // Method name : build_phase 
  // Description : construct the components 
  //////////////////////////////////////////////////////////////////////////////
  /*
  Declaration : uvm_config_db#(int)::set(this, "*", "A")
  Discription : All of the functions in uvm_config_db#(T) are static,
               so they must be called using the :: operator.
  */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    end
  endfunction : build_phase

  //////////////////////////////////////////////////////////////////////////////
  // Method name : run_phase 
  // Description : Drive the transaction info to DUT
  ////////////////////////////////////////////////////////////////////////////// 

  /* Ports :
      seq_item_port	Derived driver classes should use this port to request items from the sequencer.
  */

  /*  Method      : get_next_item
      Declaretion : virtual task get_next_item (output 	REQ 	t)
      Description : Retrieves the next available item from a sequence. 
  */

  /*  Method      : item_done
      Declaretion : virtual function void item_done (RSP item = null)
      Description : Indicates that the request is completed.
  */

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM DRIVER"), UVM_LOW);
      req.print();
      dri2rm_port.write(req);
      seq_item_port.item_done();
    end
  endtask : run_phase

endclass : apb_dpmem_driver

`endif
