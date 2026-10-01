import round_pkg::*;

module round_adder(
    input logic [2:0] round,
    input logic [26:0] norm_mant,
    input logic z_sign,
    output logic [24:0] round_mant,
    output logic inexact_bit
);

logic G, R, S;

always_comb begin
    G = norm_mant[2];
    R = norm_mant[1];
    S = norm_mant[0];

    inexact_bit = G | R | S;  

    case(round_t'(round)) // cast round from logic to round_t
        IEEE_near : begin
            if(G == 1'b1 && (R == 1'b1 || S == 1'b1)) begin
                round_mant = {1'b0, norm_mant[26:3]} + 1'b1;
            end
            else if(G == 1'b1 && R == 1'b0 && S == 1'b0)begin
                round_mant = {1'b0, norm_mant[26:3]} + norm_mant[3];  // if norm_mant[3]=1 the number is odd
            end
            else begin
                round_mant = {1'b0, norm_mant[26:3]};
            end
        end

        IEEE_zero : begin
            round_mant = {1'b0, norm_mant[26:3]};
        end

        IEEE_ninf : begin
            if(z_sign == 1'b1 && inexact_bit == 1'b1) begin
                round_mant = {1'b0, norm_mant[26:3]} + 1'b1;
            end
            else begin
                round_mant = {1'b0, norm_mant[26:3]};
            end

        end

        IEEE_pinf : begin
            if(z_sign == 1'b0 && inexact_bit == 1'b1) begin
                round_mant = {1'b0, norm_mant[26:3]} + 1'b1;
            end
            else begin
                round_mant = {1'b0, norm_mant[26:3]};
            end
        end

        near_maxMag : begin
            if(G == 1'b1) begin
                round_mant = {1'b0, norm_mant[26:3]} + 1'b1;
            end
            else begin
                round_mant = {1'b0, norm_mant[26:3]};
            end
        end

        default : begin
            round_mant = {1'b0, norm_mant[26:3]};
        end
    endcase
end 
endmodule