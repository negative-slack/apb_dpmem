class scoreboard;

    mailbox mon2scb_mbx;

    logic [31:0] scb_mem [0:1023];

    int cnt;

    function new(mailbox mon2scb_mbx);
        this.mon2scb_mbx = mon2scb_mbx;
        foreach(scb_mem[i]) scb_mem[i] = 0;
    endfunction

    task main;

        transaction trans;
        forever begin
            mon2scb_mbx.get(trans);
            trans.display("Scoreboard");

            if (trans.PWRITE == 1)
                scb_mem[trans.PADDR] = trans.PWDATA;

            if (trans.PWRITE == 0) begin
                assert (trans.PRDATA == scb_mem[trans.PADDR]) begin
                    cnt++;
                    $display("MATCH!! cnt  = %0d", cnt);
                end else begin
                    $display("MISMATCH!!");
                    $fatal;
                end
            end
        end

    endtask

endclass