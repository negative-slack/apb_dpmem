/********************************************
 *  Copyright (c) 2025 
 *  Author: negative-slack (Nader Alnatsheh).
 *  All rights reserved.
 *******************************************/

`ifndef SCOREBOARD__SV
`define SCOREBOARD__SV 

class Scoreboard;

  localparam MEM_DEPTH = 1 << ADDR_WIDTH;

  mailbox mon2scb_mbx;
  data_t scb_mem[0:MEM_DEPTH-1];
  int read_match_cnt;
  Transaction trans;

  function new(mailbox mon2scb_mbx);
    this.mon2scb_mbx = mon2scb_mbx;
  endfunction

  task run();
    forever begin
      mon2scb_mbx.get(trans);
      trans.display("Scoreboard");
      if (trans.req.pwrite) begin
        for (int i = 0; i < STRB_WIDTH; i++) begin
          if (trans.req.pstrb[i]) begin
            scb_mem[trans.req.paddr][(i*8)+:8] = trans.req.pwdata[(i*8)+:8];
          end
        end
      end else begin
        assert (trans.rsp.prdata == scb_mem[trans.req.paddr])
        else
          $error(
              "Scoreboard MISMATCH at addr %0h: expected %0h, got %0h",
              trans.req.paddr,
              scb_mem[trans.req.paddr],
              trans.rsp.prdata
          );
        if (trans.rsp.prdata == scb_mem[trans.req.paddr]) begin
          read_match_cnt++;
          $display("Scoreboard MATCH! Count = %0d", read_match_cnt);
        end
      end
    end
  endtask : run

endclass : Scoreboard

`endif
