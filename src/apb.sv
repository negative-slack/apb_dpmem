`ifndef APB__SV
`define APV__SV 

module apb (
    apb_if.slave apb_slave
);
  import apb_pkg::*;

  apb_state_t apb_state;

  parameter MEM_DEPTH = 1024;
  data_t MEM[0:MEM_DEPTH-1];
  initial begin
    foreach (MEM[i]) MEM[i] = i;
  end

  always_ff @(posedge apb_slave.PCLK or negedge apb_slave.PRESETn) begin
    if (!apb_slave.PRESETn) begin
      apb_state <= IDLE;
      apb_slave.PSLVERR <= 0;
      apb_slave.PREADY <= 0;
      apb_slave.PRDATA <= '0;
    end else begin
      case (apb_state)

        IDLE: begin
          if (apb_slave.PSEL && !apb_slave.PENABLE) begin
            apb_state <= SETUP;
            apb_slave.PSLVERR <= 0;
            apb_slave.PREADY <= 0;
            apb_slave.PRDATA <= '0;
          end else begin
            apb_state <= IDLE;
          end
        end

        SETUP: begin
          if (apb_slave.PSEL && apb_slave.PENABLE) begin
            apb_state <= ACCESS;
            apb_slave.PREADY <= 1;
            if (apb_slave.PADDR >= MEM_DEPTH) begin
              apb_slave.PSLVERR <= 1;
              apb_slave.PRDATA  <= '0;
              $error("Mem ADDR over the MEM_DEPTH");
            end else if (apb_slave.PWRITE) begin
              MEM[apb_slave.PADDR] <= apb_slave.PWDATA;  // WRITE
            end else begin
              apb_slave.PRDATA <= MEM[apb_slave.PADDR];  // READ
            end
          end else begin
            apb_state <= SETUP;
          end
        end

        ACCESS: begin
          apb_slave.PREADY <= 0;
          if (apb_slave.PSEL) begin
            apb_state <= SETUP;
          end else begin
            apb_state <= IDLE;
          end
        end

        default: begin
          apb_state <= IDLE;
        end

      endcase
    end
  end

endmodule : apb

`endif
