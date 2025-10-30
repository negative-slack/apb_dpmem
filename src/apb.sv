// module apb (
//     apb_if.slave apb_slave
// );
//   import apb_pkg::*;

//   apb_state_t apb_state;

//   parameter MEM_DEPTH = 1024;
//   data_t MEM[0:MEM_DEPTH-1];
//   logic [6:0] delay_cnt;

//   initial begin
//     foreach (MEM[i]) MEM[i] <= i;
//   end

//   always_ff @(posedge apb_slave.PCLK or negedge apb_slave.PRESETn) begin
//     if (!apb_slave.PRESETn) begin
//       apb_state <= IDLE;

//     end else begin
//       case (apb_state)

//         IDLE: begin
//           delay_cnt <= $urandom;
//           apb_slave.PSLVERR <= 0;
//           apb_slave.PREADY <= 0;
//           apb_slave.PRDATA <= '0;
//           if (apb_slave.PSEL && !apb_slave.PENABLE) begin
//             apb_state <= SETUP;
//           end else begin
//             apb_state <= IDLE;
//           end
//         end

//         SETUP: begin
//           apb_slave.PSLVERR <= 0;
//           apb_slave.PREADY  <= 0;

//           if (apb_slave.PSEL && apb_slave.PENABLE) begin
//             if (delay_cnt != 0) begin
//               delay_cnt <= delay_cnt - 1;
//             end else begin
//               apb_state <= ACCESS;
//               apb_slave.PREADY <= 1'b1;

//               if (apb_slave.PADDR >= 1024) begin
//                 apb_slave.PSLVERR <= 1;
//                 $error("Mem addr is above the limit");
//               end

//               else if (apb_slave.PWRITE && 
//               (apb_slave.PWDATA === 32'hx || 
//                apb_slave.PWDATA === 32'hz)) begin
//                 apb_slave.PSLVERR <= 1;
//                 $error("PWDATA is corrupted");
//               end else if (!apb_slave.PWRITE) begin
//                 apb_slave.PRDATA <= MEM[apb_slave.PADDR];  // READ
//               end

//             end
//           end else begin
//             apb_state <= SETUP;
//           end
//         end

//         ACCESS: begin
//           apb_slave.PREADY <= 1'b0;

//           if (apb_slave.PWRITE && !apb_slave.PSLVERR) begin
//             MEM[apb_slave.PADDR] <= apb_slave.PWDATA;  // WRITE
//           end

//           if (!apb_slave.PSEL) begin
//             apb_state <= IDLE;
//           end else begin
//             apb_state <= SETUP;
//           end
//         end

//         default: begin
//           apb_state <= IDLE;
//         end

//       endcase
//     end
//   end

// endmodule

module apb (
    apb_if.slave apb_slave
);
  import apb_pkg::*;

  apb_state_t apb_state;

  parameter MEM_DEPTH = 1024;
  data_t MEM[0:MEM_DEPTH-1];
  initial begin
    foreach (MEM[i]) MEM[i] <= i;
  end

  always_ff @(posedge apb_slave.PCLK or negedge apb_slave.PRESETn) begin
    if (!apb_slave.PRESETn) begin
      apb_state <= IDLE;
    end else begin
      case (apb_state)

        IDLE: begin
          apb_slave.PSLVERR <= 0;
          apb_slave.PREADY  <= 1'b0;
          apb_slave.PRDATA  <= 0;
          if (apb_slave.PSEL && !apb_slave.PENABLE) begin
            apb_state <= SETUP;
          end else begin
            apb_state <= IDLE;
          end
        end

        SETUP: begin
          apb_slave.PSLVERR <= 0;
          apb_slave.PREADY  <= 1'b0;
          apb_slave.PRDATA  <= 0;
          if (apb_slave.PSEL && apb_slave.PENABLE) begin
            apb_state <= ACCESS;
            apb_slave.PREADY <= 1'b1;

            if (apb_slave.PADDR >= MEM_DEPTH) begin
              apb_slave.PSLVERR <= 1;
              $error("Mem addr is above the limit");
            end
              else if (apb_slave.PWRITE && 
              (apb_slave.PWDATA === 32'hx || 
               apb_slave.PWDATA === 32'hz)) begin
              apb_slave.PSLVERR <= 1;
              $error("PWDATA is corrupted");
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
          apb_slave.PREADY <= 1'b0;
          apb_state <= IDLE;
        end

      endcase
    end
  end

endmodule
