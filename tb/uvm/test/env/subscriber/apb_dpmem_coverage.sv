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
      bins very_low_addr = {[0 : 255]};

      bins addr_256 = {256};
      bins low_addr = {[256 : 511]};

      bins addr_512 = {512};
      bins high_addr = {[512 : 767]};
    // bins very_high_addr = {[768 : 1023]};
    }

    // operation type coverage
    pwrite_cp: coverpoint cov_trans.pwrite {
      bins read = {0};  // read only
      bins write = {1};  // write only

      bins two_reads[] = (0 => 0);  // read followed by a read tnxs
      bins two_writes[] = (1 => 1);  // write followed by a write tnxs

      // I added the 2 also just to confirm that two_reads/writes == multiple_reads/writes bin [0]
      bins multiple_reads[] = (0 [* 2: 5]);
      bins multiple_writes[] = (1 [* 2: 5]);

      bins read_write[] = (0 => 1);  // read followed by a write
      bins write_read[] = (1 => 0);  // write followed by a read
    }

    // this below to count howmany times we tried to write to a no write address, which kinda indiate the number of pslverr = 1 
    cross_paddr_pwrite: cross paddr_cp, pwrite_cp{
      bins addr1_write = binsof (paddr_cp.addr_1) && binsof (pwrite_cp.write); // when it is a write tnxs, and the address is 1
      bins addr2_write = binsof (paddr_cp.addr_2) && binsof (pwrite_cp.write);
      bins addr4_write = binsof (paddr_cp.addr_4) && binsof (pwrite_cp.write);
      bins addr8_write = binsof (paddr_cp.addr_8) && binsof (pwrite_cp.write);

      ignore_bins others = !( (binsof(paddr_cp.addr_1) || binsof(paddr_cp.addr_2) ||
                               binsof(paddr_cp.addr_4) || binsof(paddr_cp.addr_8))  &&                          
                               binsof(pwrite_cp.write) );
    }

    // pstrb coverage
    // I used the $countones
    pstrb_cp: coverpoint $countones(
        cov_trans.pstrb
    ) {
      bins zero = {0}; bins one = {1}; bins two = {2}; bins three = {3}; bins four = {4};
    }

    // pslverr coverage
    error_cp: coverpoint cov_trans.pslverr {
      bins no_error = {0}; bins error = {1};
    }

    cross_pwrite_pstrb_cp : cross pwrite_cp, pstrb_cp{
      bins pwrite_zero = binsof (pwrite_cp.write) && binsof (pstrb_cp.zero);
      bins pwrite_one = binsof (pwrite_cp.write) && binsof (pstrb_cp.one);
      bins pwrite_two = binsof (pwrite_cp.write) && binsof (pstrb_cp.two);
      bins pwrite_three = binsof (pwrite_cp.write) && binsof (pstrb_cp.three);
      bins pwrite_four = binsof (pwrite_cp.write) && binsof (pstrb_cp.four);

      ignore_bins others = !binsof (pwrite_cp.write);
    }

  endgroup

  //////////////////////////////////////////////////////////////////////////////
  //constructor
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
