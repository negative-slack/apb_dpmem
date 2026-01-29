`ifndef APB_DPMEM_REF_MODEL__SV
`define APB_DPMEM_REF_MODEL__SV 

class apb_dpmem_ref_model extends uvm_component;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of component utils to register with factory 
  //////////////////////////////////////////////////////////////////////////////
  `uvm_component_utils(apb_dpmem_ref_model);

  //////////////////////////////////////////////////////////////////////////////
  // Method name : new 
  // Description : constructor 
  //////////////////////////////////////////////////////////////////////////////
  function new(string name = "apb_dpmem_ref_model", uvm_component parent);
    super.new(name, parent);
  endfunction

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Local Signals 
  //////////////////////////////////////////////////////////////////////////////
  // Input from driver (transactions seen by the driver)
  uvm_analysis_export #(apb_dpmem_transaction) rm_export;
  // Output to scoreboard (expected transactions after runnign the same tnxs seen bby the driver into the model)
  uvm_analysis_port #(apb_dpmem_transaction) rm2scb_port;
  // FIFO for transactions
  uvm_tlm_analysis_fifo #(apb_dpmem_transaction) rm_fifo;

  apb_dpmem_transaction rm_trans;  // transactions recieved from the driver
  apb_dpmem_transaction exp_trans;  // expected transactions ! 

  // Reference memory
  data_t ref_mem[0:`MEM_DEPTH-1];

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : build-phase 
  // Description : construct the components such as.. driver,monitor,sequencer..etc
  ///////////////////////////////////////////////////////////////////////////////
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rm_export = new("rm_export", this);
    rm2scb_port = new("rm2scb_port", this);
    rm_fifo = new("rm_fifo", this);
  endfunction : build_phase

  //////////////////////////////////////////////////////////////////////////////
  // Connect phase
  //////////////////////////////////////////////////////////////////////////////
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect export to FIFO
    rm_export.connect(rm_fifo.analysis_export);
  endfunction

  //////////////////////////////////////////////////////////////////////////////
  // Method name : get_expected_transaction 
  // Description : Expected transaction 
  //////////////////////////////////////////////////////////////////////////////
  task get_expected_transaction(apb_dpmem_transaction rm_trans);
    exp_trans = rm_trans;
    if (exp_trans.pwrite) begin
      if (!(exp_trans.paddr >= 10'h0 && exp_trans.paddr <= 10'hf)) begin
        for (int i = 0; i < `APB_STRB_WIDTH; i++) begin
          if (exp_trans.pstrb[i]) begin
            ref_mem[exp_trans.paddr][(i*8)+:8] = exp_trans.pwdata[(i*8)+:8];
          end
        end
      end
    end else begin
      exp_trans.prdata = ref_mem[exp_trans.paddr];
    end

    rm2scb_port.write(exp_trans);

  endtask

  task run_phase(uvm_phase phase);
    forever begin
      rm_fifo.get(rm_trans);
      get_expected_transaction(rm_trans);
    end
  endtask

endclass : apb_dpmem_ref_model

`endif
