// MIT License

// Copyright (c) 2025 negative-slack (Nader Alnatsheh)

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

`ifndef APB_DPMEM__SV
`define APB_DPMEM__SV 

module apb_dpmem
  import apb_dpmem_pkg::*;
(
    apb_if.slv_mp apb_slave
);

  typedef enum bit [1:0] {
    IDLE,
    SETUP,
    ACCESS
  } apb_fsm_enum;

  apb_fsm_enum present_state, next_state;

  data_t MEM[0:`MEM_DEPTH-1];  // 1024
  localparam READ_LATENCY = 2'b01;  // 2 clock cycles delay for a read
  localparam WRITE_LATENCY = 2'b11;  // 4 clock cycles delay for a write
  localparam int unsigned NO_WRITE_LOW_ADDRESS = 0;
  localparam int unsigned NO_WRITE_HIGH_ADDRESS = 15;
  logic [1:0] read_cnt;
  logic [1:0] write_cnt;
  // this generate blk only needed to dump sampled MEM as tmp regs to view them in the surfur/gtkwave waveforms 
  generate
    genvar idx;
    for (idx = 0; idx < `MEM_DEPTH; idx = idx + 1) begin
      data_t tmp;
      assign tmp = MEM[idx];
    end
  endgenerate

  // present_state
  always_ff @(posedge apb_slave.PCLK or negedge apb_slave.PRESETn) begin
    if (!apb_slave.PRESETn) begin
      present_state <= IDLE;
    end else begin
      present_state <= next_state;
    end
  end

  // next_state
  always_comb begin
    case (present_state)

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
          // from code coverage this statement/branch never executes! 
          if (apb_slave.PSEL && !apb_slave.PENABLE) begin  // is this a b2b_tnxs?
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

  always_comb begin
    case (present_state)

      ACCESS: begin
        // write to a READ ONLY ADDRESS
        if (apb_slave.PRESETn)
          if ((apb_slave.PADDR >= NO_WRITE_LOW_ADDRESS &&
        apb_slave.PADDR <= NO_WRITE_HIGH_ADDRESS) &&
        apb_slave.PWRITE) begin
            $display("");
            $error(
                "DUT ERROR: YOU ARE TRYING TO WRITE TO THE ADDRESS=0x%0h. \nADDRESSES FROM 0x0 till 0xf are READ ONLY",
                apb_slave.PADDR);
            apb_slave.PREADY  = 1;
            apb_slave.PSLVERR = 1;
          end else if (apb_slave.PWRITE) begin  // a valid write tnx
            if (write_cnt == 0) begin
              apb_slave.PREADY = 1;
            end
          end else begin  // a read tnx
            if (read_cnt == 0) begin
              apb_slave.PREADY = 1;
              apb_slave.PRDATA = MEM[apb_slave.PADDR];  // read now (0 delay when PREADY is high!)
            end
          end
      end

      default: begin
        apb_slave.PREADY  = 0;
        apb_slave.PRDATA  = '0;
        apb_slave.PSLVERR = 0;
      end

    endcase
  end

  always_ff @(posedge apb_slave.PCLK or negedge apb_slave.PRESETn) begin
    if (!apb_slave.PRESETn) begin
      write_cnt <= WRITE_LATENCY;
      read_cnt  <= READ_LATENCY;
    end else begin

      case (present_state)

        IDLE, SETUP: begin
          write_cnt <= WRITE_LATENCY;
          read_cnt  <= READ_LATENCY;
        end

        ACCESS: begin
          if (apb_slave.PWRITE) begin
            if (write_cnt != 0) begin
              write_cnt <= write_cnt - 1;
            end else begin
              for (int i = 0; i < `APB_STRB_WIDTH; i++) begin
                if (apb_slave.PSTRB[i]) begin
                  MEM[apb_slave.PADDR][(i*8)+:8] <= apb_slave.PWDATA[(i*8)+:8];  // start at (i*8) and go up 8 bits
                end
              end
            end
          end else begin
            if (read_cnt != 0) begin
              read_cnt <= read_cnt - 1;
            end
          end
        end

        default: begin
          write_cnt <= WRITE_LATENCY;
          read_cnt  <= READ_LATENCY;
        end

      endcase
    end
  end

  bind apb_dpmem apb_assertions apb_asserts_dut (.assert_intf(apb_if.sva_mp));

endmodule : apb_dpmem

`endif
