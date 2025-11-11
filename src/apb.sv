`ifndef APB__SV
`define APV__SV 

module apb
  import apb_pkg::*;
(
    apb_if.slave_mp apb_slave
);

  apb_state_t apb_state;

  dp_mem MEM (
      .clk(apb_slave.PCLK),
      .arstn(apb_slave.PRESETn),
      .write_en((apb_slave.PWRITE & (apb_state == ACCESS))),
      .addr(apb_slave.PADDR),
      .dat_in(apb_slave.PWDATA),
      .dat_out(apb_slave.PRDATA)
  );

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
            if (apb_slave.PADDR >= MEM.MEM_DEPTH) begin
              apb_slave.PSLVERR <= 1;
              $error("Mem ADDR over the MEM_DEPTH");
            end
            // else if (apb_slave.PWRITE) begin
            //   MEM[apb_slave.PADDR] <= apb_slave.PWDATA;  // WRITE
            // end else begin
            //   apb_slave.PRDATA <= MEM[apb_slave.PADDR];  // READ
            // end
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

`ifndef DP_MEM__SV
`define DP_MEM__SV 

module dp_mem
  import apb_pkg::*;
(
    input bit clk,
    input bit arstn,
    input logic write_en,
    input addr_t addr,
    input data_t dat_in,
    output data_t dat_out
);

  localparam MEM_DEPTH = 1024;
  data_t MEM[0:MEM_DEPTH-1];

  always_ff @(posedge clk or negedge arstn) begin
    if (!arstn) begin
      dat_out <= '0;
    end else begin
      if (write_en) begin
        MEM[addr] <= dat_in;
        dat_out   <= '0;
      end else begin
        dat_out <= MEM[addr];
      end
    end
  end

endmodule

`endif
