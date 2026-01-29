`ifndef APB_DPMEM_SCOREBOARD__SV
`define APB_DPMEM_SCOREBOARD__SV 

class apb_dpmem_scoreboard extends uvm_scoreboard;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of component utils to register with factory 
  //////////////////////////////////////////////////////////////////////////////
  `uvm_component_utils(apb_dpmem_scoreboard)

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : new 
  // Description : constructor
  ///////////////////////////////////////////////////////////////////////////////
  function new(string name = "apb_dpmem_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  ////////////////////////////////////////////////////////////////////////////
  // PORTS to receive transactions
  ////////////////////////////////////////////////////////////////////////////

  // expected tnxs from the ref model
  uvm_analysis_export #(apb_dpmem_transaction) rm2scb_export;
  apb_dpmem_transaction exp_trans;

  // actual tnxs from the monitor`
  uvm_analysis_export #(apb_dpmem_transaction) mon2scb_export;
  apb_dpmem_transaction act_trans;

  // fifo tnxs
  uvm_tlm_analysis_fifo #(apb_dpmem_transaction) rm2scb_export_fifo;
  apb_dpmem_transaction exp_trans_fifo[$];

  uvm_tlm_analysis_fifo #(apb_dpmem_transaction) mon2scb_export_fifo;
  apb_dpmem_transaction act_trans_fifo[$];

  bit error;

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : build-phase 
  // Description : construct the components such as.. driver,monitor,sequencer..etc
  ///////////////////////////////////////////////////////////////////////////////
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    rm2scb_export = new("rm2scb_export", this);
    mon2scb_export = new("mon2scb_export", this);
    rm2scb_export_fifo = new("rm2scb_export_fifo", this);
    mon2scb_export_fifo = new("mon2scb_export_fifo", this);
  endfunction : build_phase

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : connect_phase 
  // Description : connect tlm ports ande exports (ex: analysis port/exports) 
  ///////////////////////////////////////////////////////////////////////////////
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm2scb_export.connect(rm2scb_export_fifo.analysis_export);
    mon2scb_export.connect(mon2scb_export_fifo.analysis_export);
  endfunction : connect_phase

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : run_phase
  ///////////////////////////////////////////////////////////////////////////////
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      mon2scb_export_fifo.get(act_trans);
      if (act_trans == null) $stop;
      act_trans_fifo.push_back(act_trans);

      rm2scb_export_fifo.get(exp_trans);
      if (exp_trans == null) $stop;
      exp_trans_fifo.push_back(exp_trans);

      compare_tnxs();
    end
  endtask

  task compare_tnxs();
    apb_dpmem_transaction exp_trans, act_trans;
    if (exp_trans_fifo.size != 0) begin
      exp_trans = exp_trans_fifo.pop_front();
      if (act_trans_fifo.size != 0) begin
        act_trans = act_trans_fifo.pop_front();

        `uvm_info(get_full_name(), $sformatf(
                  "expected PRDATA =%0h , actual PRDATA =%0h ", exp_trans.prdata, act_trans.prdata),
                  UVM_LOW);
        `uvm_info(get_full_name(), $sformatf(
                  "expected PREADY =%0h , actual PREADY =%0h ", exp_trans.pready, act_trans.pready),
                  UVM_LOW);
        `uvm_info(
            get_full_name(), $sformatf(
            "expected PSLVERR =%0h , actual PSLVERR =%0h ", exp_trans.pslverr, act_trans.pslverr),
            UVM_LOW);

        if (exp_trans.prdata == act_trans.prdata) begin
          `uvm_info(get_full_name(), $sformatf("PRDATA MATCHES"), UVM_LOW);
        end else begin
          `uvm_error(get_full_name(), $sformatf("PRDATA MIS-MATCHES"));
          error = 1;
        end

        if (exp_trans.pready == act_trans.pready) begin
          `uvm_info(get_full_name(), $sformatf("PREADY MATCHES"), UVM_LOW);
        end else begin
          `uvm_error(get_full_name(), $sformatf("PREADY MIS-MATCHES"));
          error = 1;
        end

        if (exp_trans.pslverr == act_trans.pslverr) begin
          `uvm_info(get_full_name(), $sformatf("PSLVERR MATCHES"), UVM_LOW);
        end else begin
          `uvm_error(get_full_name(), $sformatf("PSLVERR MIS-MATCHES"));
          error = 1;
        end

      end
    end
  endtask

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : report 
  // Description : Report the testcase status PASS/FAIL
  ///////////////////////////////////////////////////////////////////////////////
  function void report_phase(uvm_phase phase);
    if (error == 0) begin
      $display("+-------------------------+");
      $display("+ INFO : TEST CASE PASSED +");
      $display("+-------------------------+");
    end else begin
      $display("+-------------------------+");
      $display("+ ERROR : TEST CASE FAILED+");
      $display("+-------------------------+");
    end
  endfunction

endclass : apb_dpmem_scoreboard

`endif
