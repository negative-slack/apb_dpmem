`ifndef GENERATOR__SV
`define GENERATOR__SV 

class generator;

  transaction trans;
  mailbox gen2dri_mbx;
  event gen_ended;
  const int num_trans = 1000;

  function new(mailbox gen2dri_mbx, event gen_ended);
    this.gen2dri_mbx = gen2dri_mbx;
    this.gen_ended   = gen_ended;
  endfunction

  task run();
    for (int i = 0; i < num_trans; i++) begin
      trans = new();
      assert (trans.randomize())
      else $error("Transaction:%0d/%0d is not randomized", i + 1, num_trans);
      trans.display("Generator");
      $display("The Generator created the Transaction:%0d/%0d as above",  // 
               i + 1, num_trans);
      gen2dri_mbx.put(trans);
    end
    $display("---------------------------------------------------------------------------");
    $display("t = %0t [Generator] Done generation of %0d items", $time, num_trans);
    $display("---------------------------------------------------------------------------");
    ->gen_ended;
  endtask : run

endclass : generator

`endif
