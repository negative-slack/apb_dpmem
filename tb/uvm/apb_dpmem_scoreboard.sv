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
  endfunction

  ////////////////////////////////////////////////////////////////////////////
  // PORTS to receive transactions
  ////////////////////////////////////////////////////////////////////////////
  uvm_analysis_export #(apb_dpmem_transaction)   mon_export;
  uvm_tlm_analysis_fifo #(apb_dpmem_transaction) mon_fifo;

  ////////////////////////////////////////////////////////////////////////////
  // Local memory
  ////////////////////////////////////////////////////////////////////////////
  localparam MEM_DEPTH = 1 << `APB_ADDR_WIDTH;
  data_t scb_mem[0:MEM_DEPTH-1];  // Assuming 32-bit data
  int total_transactions = 0;
  int write_count = 0;
  int read_count = 0;
  int read_matches = 0;
  int read_mismatches = 0;

  ///////////////////////////////////////////////////////////////////////////////
  // Build Phase
  ///////////////////////////////////////////////////////////////////////////////
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon_export = new("mon_export", this);
    mon_fifo   = new("mon_fifo", this);

    // Initialize memory to 0
    foreach (scb_mem[i]) scb_mem[i] = 32'h0;
  endfunction

  ///////////////////////////////////////////////////////////////////////////////
  // Connect Phase
  ///////////////////////////////////////////////////////////////////////////////
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mon_export.connect(mon_fifo.analysis_export);
  endfunction

  //////////////////////////////////////////////////////////////////////////////
  // Run Phase - FIXED!
  //////////////////////////////////////////////////////////////////////////////
  task run_phase(uvm_phase phase);
    apb_dpmem_transaction trans;  // Declare locally

    forever begin
      // Get transaction from monitor
      mon_fifo.get(trans);  // FIXED: was rm_trans which doesn't exist
      total_transactions++;

      // Process based on write/read
      if (trans.pwrite) begin
        process_write_transaction(trans);
      end else begin
        process_read_transaction(trans);
      end
    end
  endtask

  //////////////////////////////////////////////////////////////////////////////
  // Process Write Transaction
  //////////////////////////////////////////////////////////////////////////////
  virtual function void process_write_transaction(apb_dpmem_transaction trans);
    write_count++;

    // Check if address is in valid range
    if ((trans.paddr >= 10'h0 && trans.paddr <= 10'hf)) begin
      `uvm_warning("SCOREBOARD", $sformatf("Write to out-of-range address: 0x%h", trans.paddr))
      return;
    end

    // Update memory based on byte enables
    for (int i = 0; i < `APB_STRB_WIDTH; i++) begin
      if (trans.pstrb[i]) begin
        scb_mem[trans.paddr][(i*8)+:8] = trans.pwdata[(i*8)+:8];
      end
    end

    `uvm_info("SCOREBOARD", $sformatf(
              "WRITE #%0d: addr=0x%h, data=0x%h, strb=0x%h",
              write_count,
              trans.paddr,
              trans.pwdata,
              trans.pstrb
              ), UVM_MEDIUM)
  endfunction

  //////////////////////////////////////////////////////////////////////////////
  // Process Read Transaction
  //////////////////////////////////////////////////////////////////////////////
  virtual function void process_read_transaction(apb_dpmem_transaction trans);
    bit [31:0] expected_data;
    read_count++;

    // Check if address is in valid range
    if (!(trans.paddr >= 10'h0 && trans.paddr <= 10'hf)) begin
      `uvm_warning("SCOREBOARD", $sformatf("Read from out-of-range address: 0x%h", trans.paddr))
      return;
    end

    // Get expected data from memory
    expected_data = scb_mem[trans.paddr];

    // Compare with actual data
    if (trans.prdata === expected_data) begin
      read_matches++;
      `uvm_info("SCOREBOARD",
                $sformatf("✓ READ #%0d MATCH: addr=0x%h → Expected=0x%h, Got=0x%h", read_count,
                          trans.paddr, expected_data, trans.prdata), UVM_MEDIUM)

      // Nice display every few matches
      if (read_matches % 5 == 0) begin
        $display("\n");
        $display("+-----------------------------------+");
        $display("|  READ MATCH #%0d                 |", read_matches);
        $display("+-----------------------------------+");
        $display("\n");
      end
    end else begin
      read_mismatches++;
      `uvm_error("SCOREBOARD", $sformatf(
                 "READ #%0d MISMATCH at addr 0x%h!\n" + "  Expected: 0x%h\n" + "  Actual:   0x%h",
                 read_count,
                 trans.paddr,
                 expected_data,
                 trans.prdata
                 ))
    end
  endfunction

  //////////////////////////////////////////////////////////////////////////////
  // Report Phase - Show statistics
  //////////////////////////////////////////////////////////////////////////////
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    // Show non-zero memory contents
    `uvm_info("SCOREBOARD", "\n=== FINAL MEMORY STATE ===", UVM_LOW)
    for (int i = 0; i < MEM_DEPTH; i++) begin
      if (scb_mem[i] != 0) begin
        `uvm_info("SCOREBOARD", $sformatf("  Memory[0x%02h] = 0x%08h", i, scb_mem[i]), UVM_LOW)
      end
    end

    // Show statistics
    `uvm_info("SCOREBOARD", $sformatf(
              "\n" +
                 "==============================\n" +
                 "     SCOREBOARD RESULTS\n" +
                 "==============================\n" +
                 "Total Transactions: %0d\n" +
                 "  - Writes:         %0d\n" +
                 "  - Reads:          %0d\n" +
                 "Read Results:\n" +
                 "  - Matches:        %0d\n" +
                 "  - Mismatches:     %0d\n" +
                 "  - Success Rate:   %0.1f%%\n" +
                 "==============================",
              total_transactions,
              write_count,
              read_count,
              read_matches,
              read_mismatches,
              (read_count > 0) ? (read_matches * 100.0 / read_count) : 0.0
              ), UVM_LOW)

    // Final verdict
    if (read_mismatches > 0) begin
      `uvm_error("SCOREBOARD", "TEST FAILED - Read mismatches detected!")
    end else if (read_count > 0) begin
      `uvm_info("SCOREBOARD", "TEST PASSED - All reads matched!", UVM_LOW)
    end
  endfunction

endclass

`endif
