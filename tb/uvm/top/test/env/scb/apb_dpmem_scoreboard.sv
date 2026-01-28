// `ifndef APB_DPMEM_SCOREBOARD__SV
// `define APB_DPMEM_SCOREBOARD__SV 

// class apb_dpmem_scoreboard extends uvm_component;

//   //////////////////////////////////////////////////////////////////////////////
//   // Declaration of component utils to register with factory 
//   //////////////////////////////////////////////////////////////////////////////
//   `uvm_component_utils(apb_dpmem_scoreboard)

//   ///////////////////////////////////////////////////////////////////////////////
//   // Method name : new 
//   // Description : constructor
//   ///////////////////////////////////////////////////////////////////////////////
//   function new(string name = "apb_dpmem_scoreboard", uvm_component parent);
//     super.new(name, parent);
//   endfunction : new

//   ////////////////////////////////////////////////////////////////////////////
//   // PORTS to receive transactions
//   ////////////////////////////////////////////////////////////////////////////
//   uvm_analysis_export #(apb_dpmem_transaction) mon_export;
//   uvm_tlm_analysis_fifo #(apb_dpmem_transaction) mon_fifo;

//   //////////////////////////////////////////////////////////////////////////////
//   // Declaration of Transaction item 
//   //////////////////////////////////////////////////////////////////////////////
//   apb_dpmem_transaction trans;

//   ////////////////////////////////////////////////////////////////////////////
//   // Local memory (THIS IS YOUR REFERENCE MODEL!)
//   ////////////////////////////////////////////////////////////////////////////
//   localparam MEM_DEPTH = 1 << `APB_ADDR_WIDTH;
//   data_t scb_mem[0:MEM_DEPTH-1];
//   int total_transactions = 0;
//   int write_count = 0;
//   int read_count = 0;
//   int read_matches = 0;
//   int read_mismatches = 0;

//   ///////////////////////////////////////////////////////////////////////////////
//   // Method name : build-phase 
//   // Description : construct the components such as.. driver,monitor,sequencer..etc
//   ///////////////////////////////////////////////////////////////////////////////
//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);

//     mon_export = new("mon_export", this);
//     mon_fifo   = new("mon_fifo", this);
//   endfunction : build_phase

//   ///////////////////////////////////////////////////////////////////////////////
//   // Method name : connect_phase 
//   // Description : connect tlm ports ande exports (ex: analysis port/exports) 
//   ///////////////////////////////////////////////////////////////////////////////
//   function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//     mon_export.connect(mon_fifo.analysis_export);
//   endfunction : connect_phase

//   //////////////////////////////////////////////////////////////////////////////
//   // Method name : run 
//   // Description : Driving the dut inputs
//   //////////////////////////////////////////////////////////////////////////////
//   task run_phase(uvm_phase phase);
//     forever begin
//       mon_fifo.get(rm_trans);
//       get_expected_transaction(trans);
//     end
//   endtask

//   task compare_tnxs(apb_dpmem_transaction rm_trans);
//     forever begin

//       if (trans.pwrite) begin
//         if (!(trans.paddr >= 10'h0 && trans.paddr <= 10'hf)) begin
//           for (int i = 0; i < `APB_STRB_WIDTH; i++) begin
//             if (trans.pstrb[i]) begin
//               scb_mem[trans.paddr][(i*8)+:8] = trans.pwdata[(i*8)+:8];
//             end
//           end
//         end
//       end else begin
//         assert (trans.prdata == scb_mem[trans.paddr])
//         else
//           $error(
//               "Scoreboard ERROR; THERE IS A MISMATCH at addr %0h: expected %0h, got %0h",
//               trans.paddr,
//               scb_mem[trans.paddr],
//               trans.prdata
//           );
//         if (trans.prdata == scb_mem[trans.paddr]) begin
//           scb_read_match_cnt++;
//           read_display("SCOREBOARD");
//           $display("Scoreboard MATCH! \nThe READ Counter = %0d", scb_read_match_cnt);
//           $display("+-------------------------+");
//         end
//       end
//     end
//   endtask

// endclass

// `endif

`ifndef APB_SCOREBOARD__SV
`define APB_SCOREBOARD__SV

class apb_scoreboard extends uvm_component;

  `uvm_component_utils(apb_scoreboard)

  // Expected from reference model
  uvm_analysis_imp #(Transaction, apb_scoreboard) exp_ap;

  int read_match_cnt;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    exp_ap = new("exp_ap", this);
  endfunction

  function void write(Transaction exp);
    if (!exp.req.pwrite) begin
      if (exp.rsp.prdata !== exp.req.prdata) begin
        `uvm_error("SCB",
          $sformatf("READ MISMATCH @ %0h exp=%0h got=%0h",
            exp.req.paddr,
            exp.rsp.prdata,
            exp.req.prdata))
      end
      else begin
        read_match_cnt++;
        `uvm_info("SCB",
          $sformatf("READ MATCH @ %0h data=%0h (count=%0d)",
            exp.req.paddr,
            exp.rsp.prdata,
            read_match_cnt),
          UVM_LOW)
      end
    end
  endfunction

endclass

`endif

