
class environment;

  generator      gen;
  driver         dri;
  monitor        mon;
  scoreboard     scb;
  apb_coverage   cvg;

  mailbox        gen2dri_t;
  mailbox        mon2scb_t;

  event          gen_ended;
  event          dri_ended;

  virtual apb_if vif;

  function new(virtual apb_if vif);
    this.vif  = vif;
    gen2dri_t = new();
    mon2scb_t = new();
    gen       = new(gen2dri_t, gen_ended);
    dri       = new(vif, gen2dri_t, dri_ended);
    mon       = new(vif, mon2scb_t);
    scb       = new(mon2scb_t);
    cvg       = new(vif);
  endfunction

  task test();
    fork
      gen.main();
      dri.main();
      mon.main();
      scb.main();
      cvg.main();
    join
    wait (gen.gen_ended.triggered);
  endtask

  task run;
    test();
    $stop;
  endtask

endclass
