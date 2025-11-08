class scoreboard;

  mailbox mon2scb_mbx;
  data_t scb_mem[0:1023];
  int read_match_cnt;
  transaction trans;

  function new(mailbox mon2scb_mbx);
    this.mon2scb_mbx = mon2scb_mbx;
    foreach (scb_mem[i]) scb_mem[i] = i;
  endfunction

  task run;
    forever begin
      mon2scb_mbx.get(trans);
      trans.display("Scoreboard");
      if (trans.req.pwrite) begin
        scb_mem[trans.req.paddr] = trans.req.pwdata;
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

endclass
