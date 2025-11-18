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

  localparam READ_WAIT = 1'b1;  // 2 clock cycles delay
  localparam WRITE_WAIT = 2'b11;  // 4 clock cycles delay
  logic read_cnt;
  logic [1:0] write_cnt;

  localparam MEM_DEPTH = 1 << ADDR_WIDTH;
  data_t MEM[0:MEM_DEPTH-1];
  // this generate blk only needed to dump sampled MEM as tmp regs to view them in the waveforms  
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
        if (apb_slave.PREADY) begin
          if (apb_slave.PSEL) begin
            next_state = SETUP;
          end else begin
            next_state = IDLE;
          end
        end else begin
          next_state = ACCESS;
        end
      end

      default: begin
        next_state = IDLE;
      end

    endcase
  end

  always_ff @(posedge apb_slave.PCLK or negedge apb_slave.PRESETn) begin
    if (!apb_slave.PRESETn) begin
      write_cnt <= WRITE_WAIT;
      read_cnt <= READ_WAIT;
      apb_slave.PREADY <= 0;
      apb_slave.PRDATA <= '0;
      apb_slave.PSLVERR <= 0;
    end else begin
      case (apb_state)

        IDLE: begin
          write_cnt <= WRITE_WAIT;
          read_cnt <= READ_WAIT;
          apb_slave.PREADY <= 0;
          apb_slave.PRDATA <= '0;
          apb_slave.PSLVERR <= 0;
        end

        SETUP: begin
          write_cnt <= WRITE_WAIT;
          read_cnt <= READ_WAIT;
          apb_slave.PREADY <= 0;
          apb_slave.PRDATA <= '0;
          apb_slave.PSLVERR <= 0;
        end

        ACCESS: begin
          apb_slave.PREADY <= 0;

          if (apb_slave.PWRITE) begin
            if (write_cnt != 0) begin
              write_cnt <= write_cnt - 1;
            end else begin
              apb_slave.PREADY <= 1;
              for (int i = 0; i < STRB_WIDTH; i++) begin
                if (apb_slave.PSTRB[i]) begin
                  MEM[apb_slave.PADDR][(i*8)+:8] <= apb_slave.PWDATA[(i*8)+:8];
                end
              end
              write_cnt <= WRITE_WAIT;
            end
          end else begin
            if (read_cnt != 0) begin
              read_cnt <= read_cnt - 1;
            end else begin
              apb_slave.PREADY <= 1;
              apb_slave.PRDATA <= MEM[apb_slave.PADDR];
              read_cnt <= READ_WAIT;
            end
          end
        end

        default: begin
          write_cnt <= WRITE_WAIT;
          read_cnt <= READ_WAIT;
          apb_slave.PREADY <= 0;
          apb_slave.PRDATA <= '0;
          apb_slave.PSLVERR <= 0;
        end

      endcase
    end
  end


endmodule : apb_dp_mem

`endif
