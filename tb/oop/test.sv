/********************************************
 *  Copyright (c) 2025 
 *  Author: negative-slack (Nader Alnatsheh).
 *  All rights reserved.
 *******************************************/

`ifndef TEST__SV
`define TEST__SV 

program test (
    apb_if test_intf
);

  environment env;

  initial begin
    env = new(test_intf);
    initialize_memories();
    env.main();
  end

  task initialize_memories();
    int seed = 123;
    $display("Initializing the apb_slave and Scoreboard memories...");

    for (int i = 0; i < dut.MEM_DEPTH; i++) begin
      data_t random_val = $random(seed);
      dut.MEM[i] = random_val;
      env.scb.scb_mem[i] = random_val;
      $display("i=%0d\t APB_SLAVE_MEM=0x%0h\t SCB_MEM=0x%0h", i, dut.MEM[i], env.scb.scb_mem[i]);
      assert (dut.MEM[i] == env.scb.scb_mem[i]);
    end

    $display("SUCCESS: Both memories initialized with identical values");
  endtask

endprogram

`endif
