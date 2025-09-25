module apb (
        apb_if.slave apb_slave
    );
    import apb_pkg::*;

    apb_operation_states apb_state;

    parameter MEM_DEPTH = 1024;
    logic [ADDR_WIDTH-1:0] MEM [0:MEM_DEPTH-1];

    always_ff @(posedge apb_slave.PCLK or negedge apb_slave.PRESETn) begin
        if (!apb_slave.PRESETn) begin
            apb_state        <= IDLE;
            apb_slave.PRDATA <= '0;
            apb_slave.PREADY <= 1'b0;
        end else begin
            case (apb_state)
                IDLE: begin
                    if (apb_slave.PSEL) begin
                        apb_state <= SETUP;
                    end
                    else
                        apb_state <= IDLE;
                    apb_slave.PREADY <= 1'b0;
                end

                SETUP: begin
                    if (apb_slave.PENABLE) begin
                        apb_state <= ACCESS;
                    end
                    else
                        apb_state <= SETUP;
                    apb_slave.PREADY <= 1'b0;
                end

                ACCESS: begin
                    if (apb_slave.PSEL && apb_slave.PENABLE) begin
                        if(apb_slave.PWRITE) begin
                            MEM[apb_slave.PADDR] <= apb_slave.PWDATA;  // WRITE
                        end
                        else begin
                            apb_slave.PRDATA <= MEM[apb_slave.PADDR];  // READ
                        end
                        apb_slave.PREADY <= 1'b1;

                        if (apb_slave.PSEL) begin
                            apb_state <= SETUP;
                        end
                        else begin
                            apb_state <= IDLE;
                        end

                    end
                    else begin
                        apb_state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
