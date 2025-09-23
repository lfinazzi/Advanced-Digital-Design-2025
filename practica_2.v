// ejercicio 1

module multiply
(
    input  reg  [12:0] i_a,
    input  reg  [12:0] i_b,
    output wire [12:0] o_output
);

    reg [7:0]  r_mantissa_a;
    reg [7:0]  r_mantissa_b;
    reg [15:0] r_mantissa_out;

    reg [3:0]  r_exp_a;
    reg [3:0]  r_exp_b;
    reg [4:0]  r_exp_out;

    reg        r_sign_a;
    reg        r_sign_b;
    reg        r_sign_out;

    always @(*) begin
        r_mantissa_out = i_a[7:0]  * i_b[7:0];
        r_exp_out      = i_a[11:8] + i_b[11:8] - 7;
        r_sign_out     = i_a[12]   ^ i_b[12];   // XOR

    end

    assign o_output = {r_sign_out, r_exp_out, r_mantissa_out};


endmodule

// ejercicio 2
/*

A = 8'b1011_0011
B = 8'b1100_0101

a) A as integer is 179, B as integer is 197
    multiplication is 35263, which is 16'b1000_1001_1011_1111

                        1 0 1 1 0 0 1 1
                    *
                        1 1 0 0 0 1 0 1
                    ________________________________

                                    1 0 1 1 0 0 1 1
                                  0 0 0 0 0 0 0 0
                                1 0 1 1 0 0 1 1
                    +         0 0 0 0 0 0 0 0
                            0 0 0 0 0 0 0 0
                          0 0 0 0 0 0 0 0
                        1 0 1 1 0 0 1 1
                      1 0 1 1 0 0 1 1
                    ________________________________

                    1 0 0 0 1 0 0 1 1 0 1 1 1 1 1 1   --> 16'b1000_1001_1011_1111

b) A as S(8,7) is -0.3984375, B as S(8,7) is -0.5390625
    multiplication is 0.21478271484375

    A 2's complement is 8'b0100_1101
    B 2's complement is 8'b0011_1011

    result pending

*/

// Ejercicio 3

module unif_multiplication
(
    input reg   [15:0] i_a,
    input reg   [15:0] i_b,
    input reg          i_op1,
    input reg          i_op2,
    output wire [31:0] o_p
);

    wire [16:0]        w_mult_input_a;
    wire [16:0]        w_mult_input_b;

    reg signed [33:0]  r_mult_output;
    reg signed [31:0]  r_mult_output_trunc;
    reg                r_trunc_flag;

    wire signed [31:0] w_mult_filtered;
    wire               w_and_gate;    

    assign w_mult_input_a = (i_op1 == 1'b1) ? i_a : {0'b0, i_a[14:0]};
    assign w_mult_input_a = (i_op2 == 1'b1) ? i_b : {0'b0, i_b[14:0]};

    always @(*) begin
      r_mult_output = $signed(w_mult_input_a) * $signed(w_mult_input_b);
      r_mult_output_trunc = r_mult_output[31:0];  // this truncates, what about rounding before?
      r_trunc_flag = r_mult_output[33] | r_mult_output[32];
    end

    assign w_mult_filtered = (w_and_gate == 1'b0) ? r_mult_output : {r_mult_output[30:0], 1'b0};

    // TODO: fractional/integer flags?
    //       check corner case?
    //       mask at output

endmodule


// Ejercicio 4

module fir_filter
(
    input wire        i_clk,
    input wire        i_rst,
    input wire [15:0] i_x,
    output reg [17:0] i_y
);

    reg  [15:0]  r_x_vals 			[3:1];
    wire [31:0]  prods    			[3:0];
    wire [15:0]  prods_truncated    [3:0];
    reg  [17:0]  sums     			[1:0];

	// if coefficients were symmetrical, we would have three sums and two products (instead of three sums and four products)
	// Filter result would be h0*(x[i] + x[i-3]) + h1*(x[i-1] + x[i-2]) instead of
	// h0*x[i] + h1*x[i-1] + h2*x[i-2] + h3*x[i-3]
	parameter h0 = 16'b0100_0000_0000_0000; 	//  1/2
	parameter h1 = 16'b1010_0000_0000_0000;		// -1/4
	parameter h2 = 16'b0001_0000_0000_0000; 	//  1/8
	parameter h3 = 16'b1000_1000_0000_0000;		// -1/16

	// shift register
    always @(posedge clk) begin
      if(i_rst == 1'b1) begin
          r_x_vals[1] <= 16{1'b0};
          r_x_vals[2] <= 16{1'b0};
          r_x_vals[3] <= 16{1'b0};
      end
      else begin
        r_x_vals[1] <= i_x;
        r_x_vals[2] <= r_x_vals[1];
        r_x_vals[3] <= r_x_vals[2];
      end
    end

	// products with parameters
	assign prods[0] = $signed(h0) * $signed(i_x);	
	assign prods[1] = $signed(h1) * $signed(r_x_vals[1]);
	assign prods[2] = $signed(h2) * $signed(r_x_vals[2]);
	assign prods[3] = $signed(h3) * $signed(r_x_vals[3]);

	// truncation of products
	assign prods_truncated[0] = prods[0][15:0];
	assign prods_truncated[1] = prods[1][15:0];
	assign prods_truncated[2] = prods[2][15:0];
	assign prods_truncated[3] = prods[3][15:0];

	// 18 bit sums
	assign sum[0] = $signed(prod[0]) + $signed(prod[1]);
	assign sum[1] = $signed(prod[2]) + $signed(sum[0]);
	assign o_y 	  = $signed(prod[3]) + $signed(sum[1]);


endmodule