module norm_adder(
    input logic [7:0] max_exp,
    input logic [27:0] result_mant,
    output logic [8:0] norm_exp,
    output logic [26:0] norm_mant
);

logic [4:0] leading_zeroes;

//counts the number of '0' before the first '1' on the left
lzc u_lzc(
    .result_mant(result_mant),
    .leading_zeroes(leading_zeroes)
);

always_comb begin
    if(result_mant[27] == 1'b1) begin  // if result_mant >= 2
        norm_mant = {result_mant[27:2], (result_mant[1] | result_mant[0])};
        norm_exp = {1'b0, max_exp} + 1;
    end
    else if(result_mant[26] == 1'b1) begin
            norm_mant = result_mant[26:0]; // discard the MSB
            norm_exp = {1'b0, max_exp};
    end
    else if(result_mant == 28'b0) begin
        norm_mant = 27'b0; // if mant = 0
        norm_exp = 9'b0;   // exponent set to 0 too
    end
    else begin
        // ex: if there is only 2 leading zeroes the mantissa must LSL by 1
        norm_mant = result_mant[26:0] << (leading_zeroes - 1); // LSL by leading_zeroes
        if({1'b0, max_exp} < (leading_zeroes - 1)) begin
            norm_exp = 9'b0;
        end
        else begin
            norm_exp = {1'b0, max_exp} - (leading_zeroes - 1);
        end
    end
end
endmodule