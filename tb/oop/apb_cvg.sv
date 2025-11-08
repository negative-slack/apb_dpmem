class apb_coverage;
  virtual apb_if cov_intf;

  bit in_setup_state;
  int wait_counter;

  // Covergroups
  covergroup apb_cg @(posedge cov_intf.PCLK);

    // operation type coverage
    read_or_write_opn: coverpoint cov_intf.PWRITE {
      bins read = {0}; bins write = {1};
    }

    // Address range coverage
    addr_cp: coverpoint cov_intf.PADDR {
      bins low_addr = {[0 : 255]};
      bins mid_addr = {[256 : 767]};
      bins high_addr = {[768 : 1023]};
      bins out_of_range = {[1024 : $]};
    }

    // Wait states coverage - only sample when in SETUP phase
    wait_states_cp: coverpoint cov_intf.PREADY iff (in_setup_state) {
      bins no_wait = {1}; bins with_wait = {0};
    }

    wait_count_cp: coverpoint wait_counter iff (in_setup_state && !cov_intf.PREADY) {
      bins zero = {0};
      bins one = {1};
      bins two = {2};
      bins three = {3};
      bins four = {4};
      bins five = {5};
      bins six = {6};
      bins seven = {7};
    }

    // pslverr coverage
    error_cp: coverpoint cov_intf.PSLVERR {
      bins no_error = {0}; bins error = {1};
    }

  endgroup

  function new(virtual apb_if cov_intf);
    this.cov_intf = cov_intf;
    apb_cg = new();
  endfunction

  task run();
    forever begin
      @(posedge cov_intf.PCLK iff (cov_intf.PSEL && !cov_intf.PENABLE && !cov_intf.PREADY));

      in_setup_state = (cov_intf.PSEL && cov_intf.PENABLE);

      if (in_setup_state && !cov_intf.PREADY) begin
        wait_counter++;
      end else begin
        wait_counter = 0;
      end

      apb_cg.sample();
    end
  endtask

endclass
