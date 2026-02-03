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

/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
 __    __                  __                                                      
|  \  |  \                |  \                                                     
| $$\ | $$  ______    ____| $$  ______    ______                                   
| $$$\| $$ |      \  /      $$ /      \  /      \                                  
| $$$$\ $$  \$$$$$$\|  $$$$$$$|  $$$$$$\|  $$$$$$\                                 
| $$\$$ $$ /      $$| $$  | $$| $$    $$| $$   \$$                                 
| $$ \$$$$|  $$$$$$$| $$__| $$| $$$$$$$$| $$                                       
| $$  \$$$ \$$    $$ \$$    $$ \$$     \| $$                                       
 \$$   \$$  \$$$$$$$  \$$$$$$$  \$$$$$$$ \$$                                       
                                                                                   
                                                                                   
                                                                                   
  ______   __                       __                __                  __       
 /      \ |  \                     |  \              |  \                |  \      
|  $$$$$$\| $$ _______    ______  _| $$_     _______ | $$____    ______  | $$____  
| $$__| $$| $$|       \  |      \|   $$ \   /       \| $$    \  /      \ | $$    \ 
| $$    $$| $$| $$$$$$$\  \$$$$$$\\$$$$$$  |  $$$$$$$| $$$$$$$\|  $$$$$$\| $$$$$$$\
| $$$$$$$$| $$| $$  | $$ /      $$ | $$ __  \$$    \ | $$  | $$| $$    $$| $$  | $$
| $$  | $$| $$| $$  | $$|  $$$$$$$ | $$|  \ _\$$$$$$\| $$  | $$| $$$$$$$$| $$  | $$
| $$  | $$| $$| $$  | $$ \$$    $$  \$$  $$|       $$| $$  | $$ \$$     \| $$  | $$
 \$$   \$$ \$$ \$$   \$$  \$$$$$$$   \$$$$  \$$$$$$$  \$$   \$$  \$$$$$$$ \$$   \$$
                                                                                   
                                                                                   
                                                                                   
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */

`include "../../../src/apb_dpmem.sv"
`include "../../../src/apb_if.sv"

module top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import apb_dpmem_pkg::*;
  import apb_dpmem_test_pkg::*;

  bit clk;
  bit resetn;
  localparam CLK_CYCLE = 10;

  // clk generation
  initial begin
    clk = 1;
    forever begin
      #(CLK_CYCLE / 2);
      clk = ~clk;
    end
  end

  apb_if top_intf (
      .PCLK(clk),
      .PRESETn(resetn)
  );

  apb_dpmem dut (.apb_slave(top_intf.slv_mp));

  //////////////////////////////////////////////////////////////////////////////
  /*********************starting the execution uvm phases**********************/
  //////////////////////////////////////////////////////////////////////////////
  initial begin
    run_test();
  end

  initial begin
    initialize_dut_mem();
    uvm_config_db#(virtual apb_if)::set(uvm_root::get(), "*", "vif", top_intf);
  end

  initial begin
    $dumpfile("apb_dpmem_uvm.vcd");
    $dumpvars(0, top);
  end

  task initialize_dut_mem();
    automatic int seed = 123;
    for (int i = 0; i < `MEM_DEPTH; i++) begin
      automatic data_t random_val = $random(seed);
      dut.MEM[i] = random_val;
    end
  endtask

endmodule : top
