import round_pkg::*;

module fp_adder(
	input logic [31:0] a, b,
	input logic [2:0] round,
	output logic [31:0] z,
	output logic [7:0] status
);
	logic [8:0] final_exp;
	logic [24:0] final_mant;

	logic [7:0] exp_a, exp_b;
    logic [7:0] max_exp;
    logic [8:0] exp_diff;
    logic sign_exp_diff;

    logic [23:0] mant_a, mant_b;
    logic sa, sb;
    logic [27:0] result_mant;

    logic [8:0] norm_exp;
	logic [9:0] signed_norm_exp;
	logic signed [9:0] signed_final_exp;
    logic [26:0] norm_mant;

    logic z_sign;
    logic [24:0] round_mant;
    logic inexact_bit;

	logic [31:0] z_calc;
    logic overflow, underflow;
    logic zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f;

	assign sa = a[31];
	assign sb = b[31];

	assign exp_a = a[30:23];
	assign exp_b = b[30:23];

	assign mant_a = (exp_a == 8'b0) ? 24'b0 : {1'b1, a[22:0]};
	assign mant_b = (exp_b == 8'b0) ? 24'b0 : {1'b1, b[22:0]};

exponent_calc u_exp_calc(.*);

mant_calc u_mant_calc(.*);

norm_adder u_norm_adder(.*);

round_adder u_round_adder(.*);

exception_adder u_exception_adder(
	.result(z),
	.*
);

always_comb begin
	z_sign = 0;
	final_exp = 0;
	final_mant = 0;
	overflow = 0;
	underflow = 0;

	if(sa == sb) begin
		z_sign = sa;
	end
	else if(a[30:0] > b[30:0]) begin
		z_sign = sa;
	end
	else if(b[30:0] > a[30:0]) begin
		z_sign = sb;
	end
	else begin
		z_sign = 1'b0;
	end

	if(round_mant[24] == 1'b1) begin 
		final_mant = round_mant >> 1;
		final_exp = norm_exp + 1;
	end
	else begin
		final_mant = round_mant;
		final_exp = norm_exp;
	end

	if(final_exp >= 255)begin
		overflow = 1'b1;
	end
	else begin
		overflow = 1'b0;
	end

	if(final_exp <= 0)begin
		underflow = 1'b1;
	end
	else begin
		underflow = 1'b0;
	end

	z_calc = {z_sign, final_exp[7:0], final_mant[22:0]};

	status = {1'b0, 1'b0, inexact_f, huge_f, tiny_f, nan_f, inf_f, zero_f};
end
endmodule