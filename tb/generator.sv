class generator;

  transaction trans;
  mailbox gen2dri_mbx;
  event ended;
  int num_trans = 10;

  function new(mailbox gen2dri_mbx);
    this.gen2dri_mbx = gen2dri_mbx;
  endfunction

  task main();
    for (int i = 0; i < num_trans; i++) begin
      trans = new();
      trans.randomize();
      trans.display("Generator");
      $display("t=%0t [Generator] created loop:%0d/%0d as above", $time, i + 1, num_trans);
      gen2dri_mbx.put(trans);
    end
    $display("---------------------------------------------------------------------------");
    $display("t = %0t [Generator] Done generation of %0d items", $time, num_trans);
    $display("---------------------------------------------------------------------------");
    ->ended;
  endtask : main

endclass : generator


