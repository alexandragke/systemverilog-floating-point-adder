module exponent_calc(
    input logic [7:0] exp_a, exp_b,
    output logic [7:0] max_exp,
    output logic [8:0] exp_diff,
    output logic sign_exp_diff  
);

always_comb begin
    if(exp_a > exp_b) begin
        max_exp = exp_a;
        exp_diff = {1'b0, exp_a} - {1'b0, exp_b};   // to be 9-bit
        sign_exp_diff = 1'b1;   // 1 if exp_a > exp_b
    end
    else if(exp_b > exp_a) begin
        max_exp = exp_b;
        exp_diff = {1'b0, exp_b} - {1'b0, exp_a};
        sign_exp_diff = 1'b0;
    end
    else begin // if exponents are equal
        max_exp = exp_a;
        exp_diff = 9'b0;
        sign_exp_diff = 1'b0;
    end
end
endmodule