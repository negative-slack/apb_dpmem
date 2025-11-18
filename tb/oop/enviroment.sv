/********************************************
 *  Copyright (c) 2025 
 *  Author: negative-slack (Nader Alnatsheh).
 *  All rights reserved.
 *******************************************/

`ifndef ENVIROMENT__SV
`define ENVIROMENT__SV 

class environment;

  Generator      gen;
  Driver         dri;
  Monitor        mon;
  Scoreboard     scb;
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

  task run();
    fork
      gen.run();
      dri.run();
      mon.run();
      scb.run();
      cvg.run();
    join_none

    @(dri_ended);

    disable fork;
  endtask

  task main;
    run();
    $finish;
  endtask

endclass

`endif
