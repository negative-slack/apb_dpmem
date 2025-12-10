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

`ifndef GENERATOR__SV
`define GENERATOR__SV 

class Generator;

  Transaction trans;  // declare a handle
  mailbox gen2dri_mbx;
  event gen_ended;

  static int num_tnxs = 1000;

  function new(mailbox gen2dri_mbx, event gen_ended);
    this.gen2dri_mbx = gen2dri_mbx;
    this.gen_ended   = gen_ended;
  endfunction

  task run();
    for (int i = 0; i < num_tnxs; i++) begin
      trans = new();  // allocate a new Transaction on each iteration
      if (!trans.randomize()) begin
        $error("Transaction:%0d/%0d is not randomized", i + 1, num_tnxs);
      end else begin
        $display("");
        $display("The Generator has created the Transaction: (%0d) as below successfully:",  // 
                 i + 1);
        trans.display("Generator");
        gen2dri_mbx.put(trans);
      end
    end
    $display("");
    $display("/**********************************************************************/");
    $display("@ time = %0.3f, the Generator has finished the generation of %0d items", $time,
             num_tnxs);
    $display("/**********************************************************************/");
    $display("");
    ->gen_ended;
  endtask : run

endclass : Generator

`endif
