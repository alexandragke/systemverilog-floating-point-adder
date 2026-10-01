module lzc(
    input logic [27:0] result_mant,
    output logic [4:0] leading_zeroes
);
always_comb begin
    leading_zeroes = 5'd28;  // in case all bits are zero

    for(int i=0; i<=27; i++) begin
        if(result_mant[27-i] == 1'b1) begin
            leading_zeroes = 5'(i);
            break;
        end
    end
end
endmodule