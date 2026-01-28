`ifndef APB_DPMEM_REF_MODEL__SV
`define APB_DPMEM_REF_MODEL__SV 

class apb_dpmem_ref_model extends uvm_component;

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of component utils to register with factory 
  //////////////////////////////////////////////////////////////////////////////
  `uvm_component_utils(apb_dpmem_ref_model);

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Local Signals 
  //////////////////////////////////////////////////////////////////////////////
  // Input from sequencer
  uvm_analysis_imp #(apb_dpmem_transaction, apb_dpmem_ref_model) seq2rm_imp;
  // Output to scoreboard
  uvm_analysis_port #(apb_dpmem_transaction) rm2scb_port;

  apb_dpmem_transaction trans;

  // Reference memory
  data_t ref_mem[0:`MEM_DEPTH-1];

  //////////////////////////////////////////////////////////////////////////////
  // Method name : new 
  // Description : constructor 
  //////////////////////////////////////////////////////////////////////////////
  function new(string name = "apb_dpmem_ref_model", uvm_component parent);
    super.new(name, parent);
  endfunction

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : build-phase 
  // Description : construct the components such as.. driver,monitor,sequencer..etc
  ///////////////////////////////////////////////////////////////////////////////
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq2rm_imp = new("seq2rm_imp", this);
    rm2scb_port = new("rm2scb_port", this);
  endfunction : build_phase

  //////////////////////////////////////////////////////////////////////////////
  // Method name : get_expected_transaction 
  // Description : Expected transaction 
  //////////////////////////////////////////////////////////////////////////////
  task get_expected_transaction(apb_dpmem_transaction trans);

    if (trans.pwrite) begin
      if (!(trans.paddr >= 10'h0 && trans.paddr <= 10'hf)) begin
        for (int i = 0; i < `APB_STRB_WIDTH; i++) begin
          if (trans.pstrb[i]) begin
            ref_mem[trans.paddr][(i*8)+:8] = trans.pwdata[(i*8)+:8];
          end
        end
      end
    end else begin
      trans.prdata = ref_mem[trans.paddr];
    end

    rm2scb_ap.write(trans);
  endtask

endclass : apb_dpmem_ref_model

`endif
