// MIT License

// Copyright (c) 2025 negative-slack (Nader Alnatsheh)

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

`ifndef APV_COVERAGE__SV
`define APV_COVERAGE__SV 

class apb_coverage;

  virtual apb_if cov_intf;

  covergroup apb_cg;

    // presetn coverage
    presetn_cp: coverpoint cov_intf.PRESETn {
      bins presetn_0 = {0}; bins presetn_1 = {1};
    }

    // address range coverage
    paddr_cp: coverpoint cov_intf.PADDR {
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
    pwrite_cp: coverpoint cov_intf.PWRITE {
      bins read = {0};  // read only
      bins write = {1};  // write only

      bins two_reads[] = (0 => 0);
      bins two_writes[] = (1 => 1);

      // I added the 2 also just to confirm that two_reads/writes == multiple_reads/writes bin [0]
      bins multiple_reads[] = (0 [* 2: 5]);
      bins multiple_writes[] = (1 [* 2: 5]);

      bins read_write[] = (0 => 1);
      bins write_read[] = (1 => 0);
    }

    cross_paddr_pwrite: cross paddr_cp, pwrite_cp{
      bins addr1_write = binsof (paddr_cp.addr_1) && binsof (pwrite_cp.write);
      bins addr2_write = binsof (paddr_cp.addr_2) && binsof (pwrite_cp.write);
      bins addr4_write = binsof (paddr_cp.addr_4) && binsof (pwrite_cp.write);
      bins addr8_write = binsof (paddr_cp.addr_8) && binsof (pwrite_cp.write);

      ignore_bins others = !( (binsof(paddr_cp.addr_1) || binsof(paddr_cp.addr_2) ||
                               binsof(paddr_cp.addr_4) || binsof(paddr_cp.addr_8))  &&                          
                               binsof(pwrite_cp.write) );
    }

    // pstrb coverage
    pstrb_cp: coverpoint $countones(
        cov_intf.PSTRB
    ) {
      bins zero = {0}; bins one = {1}; bins two = {2}; bins three = {3}; bins four = {4};
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
      @(posedge cov_intf.PCLK iff ((cov_intf.PSEL && cov_intf.PENABLE && cov_intf.PREADY) || !cov_intf.PRESETn ));
      apb_cg.sample();
    end
  endtask

endclass

`endif
