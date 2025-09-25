class driver;

    virtual apb_if vif;
    transaction trans;
    mailbox gen2driv_mbx;

    function new(virtual apb_if vif, mailbox gen2driv_mbx);
        this.gen2driv_mbx = gen2driv_mbx;
        this.vif = vif;
    endfunction

    task main();
        forever begin
            gen2driv_mbx.get(trans);
            if(trans.PWRITE == 1) begin
                @(posedge vif.master.PCLK);
                apb_write(trans.PADDR,
                    trans.PWRITE,
                    trans.PWDATA);
            end
            else begin
                @(posedge vif.master.PCLK);
                apb_read(trans.PADDR);
            end
            trans.display("DRIVER");
        end

    endtask : main

    task apb_write(
            logic [31:0] paddr,
            bit pwrite,
            logic [31:0] pwdata
        );

        vif.master.PADDR <= paddr;
        vif.master.PWRITE <= 1;
        vif.master.PSEL <= 1;
        vif.master.PENABLE <= 0;
        vif.master.PWDATA <= pwdata;

        @(posedge vif.master.PCLK);
        vif.master.PADDR <= paddr;
        vif.master.PWRITE <= 1;
        vif.master.PSEL <= 1;
        vif.master.PENABLE <= 1; // HIGH NOW
        vif.master.PWDATA <= pwdata;

        wait(vif.master.PREADY == 1)
        vif.master.PSEL <= 0;
        vif.master.PENABLE <= 0;
    endtask

    task apb_read(
            logic [31:0] paddr
        );
        vif.master.PADDR <= paddr;
        vif.master.PWRITE <= 0;
        vif.master.PSEL <= 1;
        vif.master.PENABLE <= 0;

        @(posedge vif.master.PCLK);
        vif.master.PADDR <= paddr;
        vif.master.PWRITE <= 0;
        vif.master.PSEL <= 1;
        vif.master.PENABLE <= 1; // HIGH NOW

        wait(vif.master.PREADY == 1)
        vif.master.PSEL <= 0;
        vif.master.PENABLE <= 0;
    endtask


endclass : driver
