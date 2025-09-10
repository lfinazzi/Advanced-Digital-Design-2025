// Ejercicio 1 --------------------------------------------

module sum_gp1
(
    input wire  [2:0] i_data1,
    input wire  [2:0] i_data2,
    input wire  [1:0] i_sel,
    input wire        clk,
    input wire        i_rst_n,
    
    output wire [5:0] o_data
    output wire [5:0] o_overflow
);

    reg [3:0] r_ext_data1;
    reg [3:0] r_ext_data2;
    reg [3:0] r_input_sum;

    reg [3:0] r_mux_out;

    reg [5:0] r_register_summand;
    reg [6:0] r_sum_output;

    // combinatorial sum, MUX input
    always @(*) begin
        r_ext_data1 = {1'b0, i_data1};
        r_ext_data2 = {1'b0, i_data2};
        r_input_sum = i_data1 + i_data2;
    end

    // combinatorial, MUX selection
    always @(*) begin
        if (i_sel == 2'b0)
            r_mux_out = r_ext_data2;
        else if (i_sel == 2'b1)
            r_mux_out = r_input_sum;
        else if (i_sel == 2'b2)
            r_mux_out = r_ext_data1;
        else
            r_mux_out = 4'b0;
    end

    // sequential, iterative sum with asynchronous reset
    always @(posedge clk or negedge reset) begin
        if(!i_rst_n) begin   // active-low
            r_register_summand <= 0;
            r_sum_output <= 0;
        end
        else begin
            r_register_summand <= r_register_summand;
            r_sum_output <= r_sum_output;
        end

        r_register_summand <= r_sum_output[5:0];
        r_sum_output <= r_mux_out + r_register_summand;
    end

    assign o_overflow = r_sum_output[6];
    assign o_data = r_sum_output[5:0];

endmodule


// testbench pending


// Cuantos ciclos de reloj son necesarios para que el registro o_data produzca overlow cuando i_sel, i_data1 e i_data2 son iguales a 1?
// 64 ciclos de reloj, ya que en este caso el registro acumula la suma de a 2 y estamos queriendo ver cuanto tarda en llegar hasta
// 7b100_0000 contando de a 2.



// Ejercicio 2 --------------------------------------------

/*

               _______
i_dataA ------|       |        |\
              |   +   |--------| \
i_dataB ------|_______|        |  |  
               _______         |  |
i_dataA ------|       |        |  |  
              |   -   |--------|  |  
i_dataB ------|_______|        |  |  
               _______         |  |------- o_dataC
i_dataA ------|       |        |  |  
              |   &   |--------|  |  
i_dataB ------|_______|        |  |  
               _______         |  |
i_dataA ------|       |        |  |  
              |   |   |--------| /  
i_dataB ------|_______|         /|
                                 |
                                 |
                                i_sel

*/

module mux_sel
(
    input signed  [15:0]  i_dataA,
    input signed  [15:0]  i_dataB,
    input wire     [1:0]  i_sel,
    
    output signed [15:0]  o_dataC

);

    reg signed [15:0]  r_dataC;

    // combinatorial
    always @(*) begin
        if (i_sel == 2'b0)
            r_dataC = i_dataA + i_dataB;
        else if (i_sel == 2'b1)
            r_dataC = i_dataA - i_dataB;
        else if (i_sel == 2'b2)
            r_dataC = i_dataA & i_dataB;
        else
            r_dataC = i_dataA | i_dataB;
    end

    assign o_dataC = r_dataC;

endmodule

// testbench pending


// Ejercicio 4 --------------------------------------------

module filter
(
    input wire   [7:0] i_x,
    input wire         clk,
    input wire         i_rst,

    output wire [15:0] o_y
)

    reg  [7:0] r_x1;
    reg  [7:0] r_x2;
    reg  [7:0] r_x3;

    reg [15:0] r_y;
    reg [15:0] r_y1;
    reg [15:0] r_y2;

    always @(posedge clk or negedge i_rst) begin
        if(!i_rst) begin
            x1 <= 0
            x2 <= 0;
            x3 <= 0;

            r_y <= 0;
            r_y1 <= 0;
            r_y2 <= 0;
        end
        else begin
            x1 <= i_x;
            x2 <= x1;
            x3 <= x2;

            r_y <= i_x - x1 + x2 + x3 + (y_1 >>> 1) + (y2 >>> 2);
            r_y1 <= r_y;
            r_y2 <= r_y1;
        end
    end

    assign o_y = r_y;

endmodule
