module uart_fixed   // works for 8N1 (8 databits, no parity, 1 stop bit)
(
    input clk,
    input i_rx
);

    // for 96 MHz CLK and 9600 baud rate
    localparam CLKS_PER_BIT = 14'd10000;
    localparam IDLE         = 2'b00;
    localparam RECEIVING    = 2'b01;
    localparam CLEANUP      = 2'b10;

    reg [7:0]  r_rx_buffer;

    reg [12:0] r_idle_counter;
    reg [13:0] r_div_counter;
    reg [13:0] r_cleanup_counter;
    reg [2:0]  r_bit_counter;

    reg [1:0]  r_state;

    always @(posedge clk) begin

        case (state)
            case IDLE : begin
                if(i_rx == 1'b0) begin
                    if(r_idle_counter > CLKS_PER_BIT/2) begin
                        r_state <= RECEIVING;
                        r_idle_counter <= 13'd0;
                    end
                    else begin
                        r_state <= r_state;
                        r_idle_counter <= r_idle_counter + 13'd1;
                    end
                end
            end

            case (RECEIVING) : begin
                if(r_div_counter > CLKS_PER_BIT) begin
                    if (r_bit_counter < 3'b111) begin
                        r_rx_buffer[r_bit_counter] <= i_rx;         // samples bit and saves to buffer
                        r_bit_counter <= r_bit_counter += 3'd1;
                        r_div_counter <= 14'd0;
                        r_state <= r_state;
                    end
                    else begin
                        r_bit_counter <= 3'd0;
                        r_div_counter <= 14'd0;
                        r_state <= CLEANUP;
                    end
                end
                else begin
                    r_bit_counter <= r_bit_counter;
                    r_div_counter = r_div_counter + 14'd1;
                    r_state <= r_state;
                end
            end

            case (CLEANUP) : begin
                if(r_cleanup_counter > CLKS_PER_BIT) begin
                    if(i_rx == 1'b1) begin
                        r_state <= IDLE;        // end of transmission
                    end
                    else begin
                        r_state <= RECEIVING;   // get ready for next frame
                    end
                    r_cleanup_counter <= 0;
                end
                else begin
                    r_cleanup_counter <= r_cleanup_counter + 14'd1;
                    r_state <= r_state;
                end
            end

            default : begin
                r_idle_counter <= 13'd0;
                r_div_counter <= 14'd0;
                r_cleanup_counter <= 14'd0;
                r_bit_counter <= 3'd0;
                r_state <= IDLE;
            end

        endcase

    end

endmodule