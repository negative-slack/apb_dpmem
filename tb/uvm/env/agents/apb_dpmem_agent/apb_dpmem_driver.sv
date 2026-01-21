`ifndef APB_DPMEM_SEQUENCER__SV
`define APB_DPMEM_SEQUENCER__SV 

class apb_dpmem_driver extends uvm_driver #(apb_dpmem_sequence_item);

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Transaction item 
  //////////////////////////////////////////////////////////////////////////////
  apb_dpmem_sequence_item trans;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Virtual interface 
  //////////////////////////////////////////////////////////////////////////////
  virtual apb_if dri_intf;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of component utils to register with factory 
  //////////////////////////////////////////////////////////////////////////////
  `uvm_component_utils(apb_dpmem_driver)
  uvm_analysis_port #(apb_dpmem_sequence_item) drv2rm_port;  // driver to ref model ! 

  //////////////////////////////////////////////////////////////////////////////
  // Method name : new 
  // Description : constructor 
  //////////////////////////////////////////////////////////////////////////////
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  `define DRI dri_intf.driver_cb

  //////////////////////////////////////////////////////////////////////////////
  // Method name : build_phase 
  // Description : construct the components 
  //////////////////////////////////////////////////////////////////////////////
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "intf", dri_intf))
      `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    drv2rm_port = new("drv2rm_port", this);
  endfunction : build_phase

  task cycle();
    @(`DRI);
  endtask : cycle

  // deassert presetn for 1 clock cycles !
  task resetn();
    idle_state();
    // repeat (5)
    cycle();
    `DRI.PRESETn <= 1;
  endtask : resetn

  task idle_state();
    `DRI.PSEL <= 0;  // low 
    `DRI.PADDR <= '0;
    `DRI.PWRITE <= 0;
    `DRI.PWDATA <= '0;
    `DRI.PSTRB <= '0;
    `DRI.PENABLE <= 0;  // low
  endtask

  task setup_state(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);
    `DRI.PSEL <= 1;  // high
    `DRI.PADDR <= paddr;
    `DRI.PWRITE <= pwrite;
    `DRI.PWDATA <= pwdata;
    `DRI.PSTRB <= pstrb;
    `DRI.PENABLE <= 0;  // low
  endtask

  task access_state();
    `DRI.PSEL <= 1;  // high
    `DRI.PENABLE <= 1;  // high
  endtask

  task drive_b2b_tnxs(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);
    // start directly from the setup_state
    setup_state(paddr, pstrb, pwrite, pwdata);
    cycle();

    access_state();
    wait (`DRI.PREADY == 1);
  endtask

  task drive_tnxs_w_idle(input addr_t paddr, strb_t pstrb, logic pwrite, data_t pwdata);
    if (trans.idle_cycles > 0) begin  // idle cycle here anywhere between 1 and 5
      repeat (trans.idle_cycles) begin
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
  endtask

  task drive();
    `DRI.PRESETn <= trans.req.PRESETn;

    if (!trans.req.PRESETn) begin
      resetn();
    end else if (!trans.b2b_tnxs) begin
      drive_tnxs_w_idle(trans.req.paddr, trans.req.pstrb, trans.req.pwrite, trans.req.pwdata);
    end else begin
      drive_b2b_tnxs(trans.req.paddr, trans.req.pstrb, trans.req.pwrite, trans.req.pwdata);
    end
  endtask

  //////////////////////////////////////////////////////////////////////////////
  // Method name : run_phase 
  // Description : Drive the transaction info to DUT
  //////////////////////////////////////////////////////////////////////////////
  virtual task run_phase();
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      `uvm_info(get_full_name(), $sformatf("TRANSACTION FROM DRIVER"), UVM_LOW);
      req.print();
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      drv2rm_port.write(rsp);
      seq_item_port.item_done();
      seq_item_port.put(rsp);
    end

  endtask : run

  `undef DRI

endclass
`endif
