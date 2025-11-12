/********************************************
 *  Copyright (c) 2025 
 *  Author: negative-slack (Nader Alnatsheh).
 *  All rights reserved.
 *******************************************/

`ifndef APB_DP_MEM__SV
`define APB_DP_MEM__SV 

module apb_dp_mem
  import apb_pkg::*;
(
    apb_if.slv_mp apb_slave
);

  apb_state_t apb_state, next_state;

  localparam MEM_DEPTH = 1024;
  data_t MEM[0:MEM_DEPTH-1];
  generate
    genvar idx;
    for (idx = 0; idx < MEM_DEPTH; idx = idx + 1) begin
      data_t tmp;
      assign tmp = MEM[idx];
    end
  endgenerate

  always_ff @(posedge apb_slave.PCLK or negedge apb_slave.PRESETn) begin
    if (!apb_slave.PRESETn) begin
      apb_state <= IDLE;
    end else begin
      apb_state <= next_state;
    end
  end

  always_comb begin
    case (apb_state)

      IDLE: begin
        if (apb_slave.PSEL && !apb_slave.PENABLE) begin
          next_state = SETUP;
        end else begin
          next_state = IDLE;
        end
      end

      SETUP: begin
        if (apb_slave.PSEL && apb_slave.PENABLE) begin
          next_state = ACCESS;
        end else begin
          next_state = SETUP;
        end
      end

      ACCESS: begin
        if (apb_slave.PSEL) begin
          next_state = SETUP;
        end else begin
          next_state = IDLE;
        end
      end

      default: begin
        next_state = IDLE;
      end

    endcase
  end

  always_comb begin

    case (next_state)

      IDLE: begin
        apb_slave.PREADY  = 0;
        apb_slave.PRDATA  = '0;
        apb_slave.PSLVERR = 0;
      end

      SETUP: begin
        apb_slave.PREADY  = 0;
        apb_slave.PRDATA  = '0;
        apb_slave.PSLVERR = 0;
      end

      ACCESS: begin
        apb_slave.PREADY = 1;
        if (apb_slave.PADDR >= MEM_DEPTH) begin
          apb_slave.PSLVERR <= 1;
          $error("Mem ADDR over the MEM_DEPTH");
        end else if (apb_slave.PWRITE) begin
          MEM[apb_slave.PADDR] <= apb_slave.PWDATA;
        end else begin
          apb_slave.PRDATA <= MEM[apb_slave.PADDR];
        end
      end

      default: begin
        apb_slave.PREADY  = 0;
        apb_slave.PRDATA  = '0;
        apb_slave.PSLVERR = 0;
      end

    endcase
  end

endmodule : apb_dp_mem

`endif
