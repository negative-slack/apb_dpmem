class monitor;

    virtual apb_if vif;

    mailbox mon2scb_mbx;

    function new(virtual apb_if vif, mailbox mon2scb_mbx);
        this.mon2scb_mbx = mon2scb_mbx;
        this.vif = vif;
    endfunction

    bit [31:0] addr_temp;
    bit [31:0] wdata_temp;

    task main();
        transaction trans;
        trans = new();

        @(posedge vif.slave.PCLK);
        while (vif.slave.PSEL == 0) begin
            @(posedge vif.slave.PCLK);

            if (vif.slave.PWRITE) begin
                addr_temp  = vif.slave.PADDR;
                wdata_temp = vif.slave.PWDATA;
                @(posedge vif.slave.PCLK);
                assert (vif.slave.PENABLE == 1);
            end
        end

    endtask
endclass : monitor