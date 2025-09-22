`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////
module uart_rx   // works for 8N1 (8 databits, no parity, 1 stop bit)
(
    input wire        i_clk,
    input wire        i_rx,
    output wire [7:0] o_byte,
    output wire       o_data_valid
);

    // for 125 MHz CLK and 9600 baud rate
    localparam CLKS_PER_BIT = 14'd13020;
    localparam IDLE         = 2'b00;
    localparam RECEIVING    = 2'b01;
    localparam CLEANUP      = 2'b10;

    reg [7:0]  r_rx_buffer;

    reg [12:0] r_idle_counter;
    reg [13:0] r_div_counter;
    reg [13:0] r_cleanup_counter;
    reg [3:0]  r_bit_counter;

    reg [1:0]  r_state;
    reg        r_data_valid;

    always @(posedge i_clk) begin

        case (r_state)
            IDLE : begin
                if(i_rx == 1'b0) begin
                    if(r_idle_counter > CLKS_PER_BIT/2) begin
                        r_state <= RECEIVING;
                        r_idle_counter <= 13'd0;
                        r_data_valid <= 1'b0;
                    end
                    else begin
                        r_state <= r_state;
                        r_idle_counter <= r_idle_counter + 13'd1;
                        r_data_valid <= 1'b0;
                    end
                end
            end

            RECEIVING : begin
                if(r_div_counter > CLKS_PER_BIT) begin
                    if (r_bit_counter < 4'b1000) begin
                        r_rx_buffer[r_bit_counter] <= i_rx;         // samples bit and saves to buffer
                        r_bit_counter <= r_bit_counter + 4'd1;
                        r_div_counter <= 14'd0;
                        r_state <= r_state;
                        r_data_valid <= 1'b0;
                    end
                    else begin
                        r_bit_counter <= 4'd0;
                        r_div_counter <= 14'd0;
                        r_state <= CLEANUP;
                        r_data_valid <= 1'b1;
                    end
                end
                else begin
                    r_bit_counter <= r_bit_counter;
                    r_div_counter = r_div_counter + 14'd1;
                    r_state <= r_state;
                    r_data_valid <= 1'b0;
                end
            end

            CLEANUP : begin
                if(r_cleanup_counter > CLKS_PER_BIT) begin
                    if(i_rx == 1'b1) begin
                        r_state <= IDLE;        // end of transmission
                        r_data_valid <= 1'b0;
                    end
                    else begin
                        r_state <= RECEIVING;   // get ready for next frame
                        r_data_valid <= 1'b0;
                    end
                end
                else begin
                    r_cleanup_counter <= r_cleanup_counter + 14'd1;
                    r_state <= r_state;
                    r_data_valid <= 1'b0;
                end
            end

            default : begin
                r_idle_counter <= 13'd0;
                r_div_counter <= 14'd0;
                r_cleanup_counter <= 14'd0;
                r_bit_counter <= 4'd0;
                r_data_valid <= 1'b0;
                r_state <= IDLE;
            end

        endcase

    end
    
    assign o_byte       = r_rx_buffer;
    assign o_data_valid = r_data_valid;

endmodule
