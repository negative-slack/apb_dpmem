class environment;

  generator      gen;
  driver         dri;
  monitor        mon;
  scoreboard     scb;

  mailbox        gen2dri_t;
  mailbox        mon2scb_t;

  virtual apb_if vif;

  function new(virtual apb_if vif);
    this.vif  = vif;
    gen2dri_t = new();
    mon2scb_t = new();
    gen       = new(gen2dri_t);
    dri       = new(vif, gen2dri_t);
    mon       = new(vif, mon2scb_t);
    scb       = new(mon2scb_t);
  endfunction

  task test();
    fork
      gen.main();
      dri.main();
      mon.main();
      scb.main();
    join
    wait (gen.ended.triggered);
  endtask

  task run;
    test();
    $finish;
  endtask

endclass
