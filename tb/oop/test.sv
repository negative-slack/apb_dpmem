`ifndef TEST__SV
`define TEST__SV 

program test (
    apb_if intf
);

  environment env;

  initial begin
    env = new(intf);
    initialize_memories();
    env.main();
  end

  task initialize_memories();
    automatic int seed = 123;
    $display("Initializing DUT and Scoreboard memories...");

    for (int i = 0; i < dut.MEM.MEM_DEPTH; i++) begin
      automatic data_t random_val = $random(seed);
      dut.MEM.MEM[i]  = random_val;
      env.scb.scb_mem[i] = random_val;
      $display("i=%0d, DUT_MEM=%0h, SCB_MEM=%0h", i, dut.MEM.MEM[i], env.scb.scb_mem[i]);
      assert (dut.MEM.MEM[i] == env.scb.scb_mem[i]);
    end

    $display("SUCCESS: Both memories initialized with identical values");
  endtask

endprogram

`endif
