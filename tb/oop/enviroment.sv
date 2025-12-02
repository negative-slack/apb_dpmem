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

`ifndef ENVIRONMENT__SV
`define ENVIRONMENT__SV 

class Environment;

  Generator      gen;
  Driver         dri;
  Monitor        mon;
  Scoreboard     scb;
  apb_coverage   cvg;

  mailbox        gen2dri_t;
  mailbox        mon2scb_t;

  event          gen_ended;
  event          dri_ended;
  event          scb_ended;

  virtual apb_if vif;

  function new(virtual apb_if vif);
    this.vif  = vif;
    gen2dri_t = new();
    mon2scb_t = new();
    gen       = new(gen2dri_t, gen_ended);
    dri       = new(vif, gen2dri_t, dri_ended);
    mon       = new(vif, mon2scb_t);
    scb       = new(mon2scb_t, scb_ended);
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
  endtask : run

  task main;
    run();
    $finish;
  endtask : main

endclass : Environment

`endif
