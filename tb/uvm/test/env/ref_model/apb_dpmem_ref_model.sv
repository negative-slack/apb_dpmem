`ifndef APB_DPMEM_REF_MODEL__SV
`define APB_DPMEM_REF_MODEL__SV 

// Because of this WARNING below I decalred the input outside the class ! 
// WARNING: [VRFC 10-9281] package import cannot be inside a class
import apb_dpmem_pkg::*;

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
  endfunction : new

  //////////////////////////////////////////////////////////////////////////////
  // Declaration of Local Signals 
  //////////////////////////////////////////////////////////////////////////////
  // Input from driver (transactions seen by the driver)
  // it will be connected together in the environment class ! 
  uvm_analysis_export #(apb_dpmem_transaction) rm_export;
  // Output to scoreboard (expected transactions after running the same tnxs seen by the driver into the ref model)
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

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : connect_phase 
  // Description : connect the ref model tnx (sent by the driver) to a the fifo
  ///////////////////////////////////////////////////////////////////////////////
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect rm_export to FIFO export 
    // and since the rm_export is connected to the dri2rm_port
    // so basically same tnxs ! 
    rm_export.connect(rm_fifo.analysis_export);
  endfunction

  ////////////////////////////////////////////////////////////////////////////
  // Method name : get_expected_transaction 
  // Description : Expected transaction 
  ////////////////////////////////////////////////////////////////////////////
  task get_expected_transaction(apb_dpmem_transaction rm_trans);
    exp_trans = rm_trans;  // equal the expected with the actual tnx
    if (exp_trans.presetn) begin
      if (exp_trans.pwrite) begin
        // TRYING TO WRITE TO A READ ONLY ADDRESS -> rasie the pslverr signal 
        if (exp_trans.paddr >= 10'h0 && exp_trans.paddr <= 10'hf) begin
          exp_trans.prdata  = '0;
          exp_trans.pready  = 1'b1;
          exp_trans.pslverr = 1'b1;
        end else begin
          // write to a write address range ! update the ref_mem
          for (int i = 0; i < `APB_STRB_WIDTH; i++) begin
            if (exp_trans.pstrb[i]) begin
              ref_mem[exp_trans.paddr][(i*8)+:8] = exp_trans.pwdata[(i*8)+:8];
            end
          end
          exp_trans.prdata  = '0;
          exp_trans.pready  = 1'b1;
          exp_trans.pslverr = 1'b0;
        end
      end else begin  // this is a read tnx below
        exp_trans.prdata  = ref_mem[exp_trans.paddr];
        exp_trans.pready  = 1'b1;
        exp_trans.pslverr = 1'b0;
      end
    end else begin  // if the preset is low
      exp_trans.prdata  = '0;
      exp_trans.pready  = 1'b0;
      exp_trans.pslverr = 1'b0;
    end

    // write the exp_trans to the port so it will be sent to the scb for a comparison with whatever we get from the monitor ! 
    rm2scb_port.write(exp_trans);

  endtask

  // i have to look more into uvm to see if there is a better way to randomzie the ref_mem & the DUT mem with the values instead of the seed !
  task initialize_ref_model_mem();
    automatic int seed = 123;
    for (int i = 0; i < `MEM_DEPTH; i++) begin
      automatic data_t random_val = $random(seed);
      ref_mem[i] = random_val;
    end
  endtask

  task run_phase(uvm_phase phase);
    initialize_ref_model_mem();
    forever begin
      rm_fifo.get(rm_trans);  // send the driver tnxs to the fifo
      get_expected_transaction(rm_trans);  // run the driver tnxs to the task
    end
  endtask

endclass : apb_dpmem_ref_model

`endif
