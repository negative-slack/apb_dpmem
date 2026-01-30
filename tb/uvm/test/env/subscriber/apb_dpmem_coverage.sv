`ifndef APB_DPMEM_COVERAGE__SV
`define APB_DPMEM_COVERAGE__SV 

class apb_dpmem_coverage #(
    type T = apb_dpmem_transaction
) extends uvm_subscriber #(T);

  `uvm_component_utils(apb_dpmem_coverage);

  apb_dpmem_transaction cov_trans;

  covergroup apb_dpmem_cg;
    option.per_instance = 1;

    // presetn coverage
    presetn_cp: coverpoint cov_trans.presetn {
      bins presetn_0 = {0};  // how many times the value is 0
      bins presetn_1 = {1};  // how many times the value is 1
    }

    // address range coverage
    paddr_cp: coverpoint cov_trans.paddr {
      bins addr_1 = {1};
      bins addr_2 = {2};
      bins addr_4 = {4};
      bins addr_8 = {8};
      bins addr_16 = {16};
      bins addr_32 = {32};
      bins addr_64 = {64};
      bins addr_128 = {128};
      // confirm the number of the bin ver_low_addr by adding the 8 bins above!
      bins very_low_addr = {[0 : 255]};

      // the below bins must match numbers!
      bins addr_256 = {256};
      bins low_addr = {[256 : 511]};

      // the below bins must match numbers
      bins addr_512 = {512};
      bins high_addr = {[512 : 767]};

    // the below bin is commented out since I am constraint the paddr for the one_hot_index addresses ! 
    // bins very_high_addr = {[768 : 1023]};

    /* ALL THE ABOVE BINS MUST EQUAL TO THE MACRO `NUM_OF_TRANSACTIONS (WHICH IS 1000)*/
    }

    // operation type coverage
    pwrite_cp: coverpoint cov_trans.pwrite {
      // the 2 below bins MUST EQUAL TO THE MACRO `NUM_OF_TRANSACTIONS (WHICH IS 1000)
      bins read = {0};  // read only
      bins write = {1};  // write only

      bins two_reads = (0 => 0);  // read followed by a read tnxs
      bins two_writes = (1 => 1);  // write followed by a write tnxs

      // I added the 2 also just to confirm that two_reads/writes == multiple_reads/writes bin [0]
      bins multiple_reads[] = (0 [* 2: 5]);
      bins multiple_writes[] = (1 [* 2: 5]);

      bins read_write[] = (0 => 1);  // read followed by a write
      bins write_read[] = (1 => 0);  // write followed by a read
    }

    // pstrb coverage
    // confirm the bins zero with the bins read from the pwrite_cp (# of read operations) they must match since we constraint the pstrb to 0 when it is a read tnx   
    pstrb_cp: coverpoint $countones(
        cov_trans.pstrb
    ) {
      bins zero = {0}; bins one = {1}; bins two = {2}; bins three = {3}; bins four = {4};
    /* ALL THE ABOVE BINS MUST EQUAL TO THE MACRO `NUM_OF_TRANSACTIONS (WHICH IS 1000)*/
    }

    // pslverr coverage
    pslverr_cp: coverpoint cov_trans.pslverr {
      bins no_error = {0};  //
      bins error = {1};  // confirm the number of hits by adding the number of hits for all 4 bins of the paddr cross pwrite cp below (they must match!)
    /* ALL THE ABOVE BINS MUST EQUAL TO THE MACRO `NUM_OF_TRANSACTIONS (WHICH IS 1000)*/
    }

    // this below to count how many times we tried to write to a no write address, which kinda indiate the number of pslverr = 1 
    cross_paddr_pwrite: cross paddr_cp, pwrite_cp{
      bins addr1_write = binsof (paddr_cp.addr_1) && binsof (pwrite_cp.write); // when it is a write tnxs, and the address is 1
      bins addr2_write = binsof (paddr_cp.addr_2) && binsof (pwrite_cp.write);
      bins addr4_write = binsof (paddr_cp.addr_4) && binsof (pwrite_cp.write);
      bins addr8_write = binsof (paddr_cp.addr_8) && binsof (pwrite_cp.write);

      ignore_bins others = !( (binsof(paddr_cp.addr_1) || binsof(paddr_cp.addr_2) ||
                               binsof(paddr_cp.addr_4) || binsof(paddr_cp.addr_8))  &&                          
                               binsof(pwrite_cp.write) );
    }

    // the below cp was added to mainly confirm (track) the first bin = 0 which is that when it is a write tnx ->
    // the bin zero in the pstrb cp is 0 (this will miss up the coverage percentage! as this should never hit, hence the weight option is 0)
    cross_pwrite_pstrb_cp : cross pwrite_cp, pstrb_cp{
      bins pwrite_zero = binsof (pwrite_cp.write) && binsof (pstrb_cp.zero);
      // the below 4 bins hould equal the bins [1-4] from the pstrb cp numberss
      bins pwrite_one = binsof (pwrite_cp.write) && binsof (pstrb_cp.one);
      bins pwrite_two = binsof (pwrite_cp.write) && binsof (pstrb_cp.two);
      bins pwrite_three = binsof (pwrite_cp.write) && binsof (pstrb_cp.three);
      bins pwrite_four = binsof (pwrite_cp.write) && binsof (pstrb_cp.four);

      ignore_bins others = !binsof (pwrite_cp.write);

      option.weight = 0;
    }

  endgroup

  //////////////////////////////////////////////////////////////////////////////
  // Method name : new 
  // Description : constructor 
  //////////////////////////////////////////////////////////////////////////////
  function new(string name = "apb_dpmem_coverage", uvm_component parent);
    super.new(name, parent);
    apb_dpmem_cg = new();
  endfunction

  function void write(T t);
    cov_trans = t;
    apb_dpmem_cg.sample();
  endfunction

endclass : apb_dpmem_coverage

`endif
