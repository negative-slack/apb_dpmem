class environment;

    generator  gen;
    driver     dri;
    monitor    mon;
    scoreboard scb;

    //declare 2 mailbox(from gen to dri and from mon to scb)
    mailbox m1;
    mailbox m2;

    virtual apb_if vif;

    function new(virtual apb_if vif);
        this.vif = vif;
        m1     = new();
        m2     = new();
        gen    = new(m1);
        dri   = new(vif, m1);
        mon    = new(vif, m2);
        scb    = new(m2);
    endfunction

    task test();
        fork
            gen.main();
            dri.main();
            mon.main();
            scb.main();
        join
        wait(gen.ended.triggered);
    endtask

    task run;
        test();
        $finish;
    endtask

endclass