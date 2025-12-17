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
    display_dut_memory_after();
    $finish;
  end

  task initialize_memories();
    automatic int seed = 123;
    data_t initial_mem[0:dut.MEM_DEPTH-1];
    $display("Initializing the APB_DPMEM slave and Scoreboard memories");
    $display("   i\t APB_DPMEM\t SCB_MEM");
    $display("+-------------------------+");
    for (int i = 0; i < dut.MEM_DEPTH; i++) begin
      automatic data_t random_val = $random(seed);
      dut.MEM[i] = random_val;
      env.scb.scb_mem[i] = random_val;
      initial_mem[i] = random_val;
      $display("%4h\t 0x%8h\t 0x%8h", i, dut.MEM[i], env.scb.scb_mem[i]);
      assert (dut.MEM[i] == env.scb.scb_mem[i])
      else $error("INITIALIZATION ERROR");
    end

    $display("INITIALIZATION SUCCESS: Both memories initialized with identical values");
  endtask

  function void display_dut_memory_after();
    $display("");
    $display("   i\t Before\t After\t STATUS");
    $display("+--------------------------------------------------------------------------------+");
    for (int i = 0; i < dut.MEM_DEPTH; ++i) begin
      automatic string status = (initialize_memories.initial_mem[i] == dut.MEM[i]) ? "UNCHANGED" : "CHANGED";
      $display("%4h\t0x%8h\t 0x%8h\t %s", i, initialize_memories.initial_mem[i], dut.MEM[i], status);
    end
  endfunction

endprogram : Test

`endif
