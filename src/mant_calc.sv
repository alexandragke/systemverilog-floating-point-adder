module mant_calc(
    input logic [23:0] mant_a, mant_b,
    input logic [8:0] exp_diff,
    input logic sign_exp_diff,
    input logic sa, sb,
    output logic [27:0] result_mant
);

logic [23:0] large_mant, small_mant; // mantissa with the larger/smaller exponent
logic [27:0] final_large_mant, final_small_mant;
logic [48:0] aligned_small_mant;
logic guard, round, sticky;

always_comb begin: alignment
    // in case exp_a == exp_b we need to compare the mantissas too
    if(sign_exp_diff == 1'b1 || (exp_diff == 1'b0 && mant_a > mant_b)) begin 
        large_mant = mant_a;
        small_mant = mant_b;
    end
    else begin 
        large_mant = mant_b;
        small_mant = mant_a;
    end

    if(exp_diff > 48) begin
        if(small_mant != 24'b0) begin
            final_small_mant = 28'b1;
            sticky = 1'b1;
        end
        else begin
            final_small_mant = 28'b0;
            sticky = 1'b0;
        end
    end
    else begin
            aligned_small_mant = {small_mant, 25'b0} >> exp_diff; //LSR by exp_diff positions
            guard = aligned_small_mant[24];
            round = aligned_small_mant[23];
            sticky = |aligned_small_mant[22:0]; // OR all LSBs

            final_small_mant = {1'b0, aligned_small_mant[48:25], guard, round, sticky};
    end
    final_large_mant = {1'b0, large_mant, 3'b000};
end

always_comb begin: addition_subtraction
    if(sa == sb) begin
        result_mant = final_large_mant + final_small_mant;
    end
    else begin
        result_mant = final_large_mant - final_small_mant;
    end
end
endmodule