class monitor;

  virtual apb_if vif;

  mailbox mon2scb_mbx;

  function new(virtual apb_if vif, mailbox mon2scb_mbx);
    this.vif = vif;
    this.mon2scb_mbx = mon2scb_mbx;
  endfunction

  task main();

    bit [31:0] addr_temp;
    bit [31:0] wdata_temp;

    transaction trans;
    trans = new();

    forever begin

      @(posedge vif.slave.PCLK);
      while (vif.slave.PSEL == 0) begin
        @(posedge vif.slave.PCLK);

        if (vif.slave.PWRITE) begin
          addr_temp  = vif.slave.PADDR;
          wdata_temp = vif.slave.PWDATA;
          @(posedge vif.slave.PCLK);
          assert (vif.slave.PENABLE == 1);

          while (vif.slave.PREADY == 0) begin
            assert (vif.slave.PENABLE == 1);
            assert (vif.slave.PWRITE == 1);
            assert (addr_temp == vif.slave.PADDR);
            assert (wdata_temp == vif.slave.PWDATA);
          end

          trans.PSEL   = 1;
          trans.PADDR  = vif.slave.PADDR;
          trans.PWDATA = vif.slave.PWDATA;
        end 
        
        else begin
          addr_temp = vif.slave.PADDR;
          @(posedge vif.slave.PCLK);
          assert (vif.slave.PENABLE == 1);

          while (vif.slave.PREADY == 0) begin
            assert (vif.slave.PENABLE == 1);
            assert (vif.slave.PWRITE == 0);
            assert (addr_temp == vif.slave.PADDR);
            @(posedge vif.slave.PCLK);
          end

          trans.PSEL   = 0;
          trans.PADDR  = vif.slave.PADDR;
          trans.PWDATA = vif.slave.PWDATA;
        end

      end

      mon2scb_mbx.put(trans);
      trans.display("Monitor");
    end

  endtask
endclass : monitor
