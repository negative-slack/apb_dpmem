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

`ifndef TEST__SV
`define TEST__SV 

program Test (
    apb_if test_intf
);

  Environment env;

  initial begin
    env = new(test_intf);
    initialize_memories();
    env.main();
  end

  task initialize_memories();
    automatic int seed = 123;
    $display("Initializing the apb_dpmem slave and Scoreboard memories");

    for (int i = 0; i < dut.MEM_DEPTH; i++) begin
      automatic data_t random_val = $random(seed);
      dut.MEM[i] = random_val;
      env.scb.scb_mem[i] = random_val;
      $display("i=%0d\t APB_DPMEM=0x%0h\t SCB_MEM=0x%0h", i, dut.MEM[i], env.scb.scb_mem[i]);
      assert (dut.MEM[i] == env.scb.scb_mem[i])
      else $error("ERROR : MISMATCH MEMORY INITALIZATION");
    end

    $display("SUCCESS: Both memories initialized with identical values");
  endtask

endprogram : Test

`endif
