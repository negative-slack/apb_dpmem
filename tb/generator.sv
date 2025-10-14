class generator;

  transaction trans;
  mailbox gen2dri_mbx;
  event ended;
  int num_trans = 2000;

  function new(mailbox gen2dri_mbx);
    this.gen2dri_mbx = gen2dri_mbx;
  endfunction

  task main();
    for (int i = 0; i < num_trans; i++) begin
      trans = new();
      trans.randomize();
      $display("t=%0t [Generator] Loop:%0d/%0d create next transaction", $time, i + 1, num_trans);
      gen2dri_mbx.put(trans);
      trans.display("Generator");
    end
    $display("t = %0t [Generator] Done generation of %0d items", $time, num_trans);
    // trans.display("Generator");
    ->ended;
  endtask : main

endclass : generator


