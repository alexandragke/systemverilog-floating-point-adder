import round_pkg::*;

module exception_adder(
    input logic [31:0] a, b, z_calc,
    input logic [2:0] round,
    input logic overflow, underflow, inexact_bit,
    output logic [31:0] result,
    output logic zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f
);

typedef enum logic [2:0] {
    ZERO,
    INF,
    NORM,
    MIN_NORM,
    MAX_NORM
} interp_t;

function interp_t num_interp(input logic [31:0] val);
    logic [7:0] exp;
    exp = val[30:23];

    if(exp == 8'b1111_1111) begin
        return INF;
    end
    else if(exp == 8'b0000_0000) begin
        return ZERO;
    end
    else if(exp == 8'b0000_0001 )begin
        return MIN_NORM;
    end
    else if(exp == 8'b1111_1110) begin
        return MAX_NORM;
    end
    else begin
        return NORM;
    end
endfunction: num_interp

function logic [30:0] z_num(input interp_t val);
    case(val)
        ZERO : return 31'h0000_0000;

        INF : return 31'h7F80_0000;

        MIN_NORM : return 31'h0080_0000;

        MAX_NORM : return 31'h7F7F_FFFF;

        default : return 31'h0000_0000;
    endcase
endfunction: z_num

interp_t interp_a, interp_b;
logic zero_sign;

always_comb begin
    result = 32'b0;
    zero_f = 1'b0;
    inf_f = 1'b0;
    nan_f = 1'b0;
    tiny_f = 1'b0;
    huge_f = 1'b0;
    inexact_f = 1'b0;

    interp_a = num_interp(a);
    interp_b = num_interp(b);

    if(round_t'(round) == IEEE_ninf) begin
        zero_sign = 1'b1;
    end
    else zero_sign = 1'b0;

    if(interp_a == ZERO && interp_b == ZERO) begin
        if(a[31] == b[31]) begin
            result = {a[31], z_num(ZERO)};
        end
        else begin
            result = {zero_sign, z_num(ZERO)};
        end
        zero_f = 1'b1;
    end
    else if(interp_a == INF || interp_b == INF) begin
        if(interp_a == INF && interp_b == INF && (a[31] != b[31])) begin
            result = 32'h7F80_0000;
            nan_f = 1'b1;
        end
        else begin
            result = {z_calc[31], z_num(INF)};
            inf_f = 1'b1;
        end
    end
    else begin
        if(overflow == 1'b1) begin
            huge_f = 1'b1;
            inexact_f =1'b1;

            case(round_t'(round))
                IEEE_near, near_maxMag : result = {z_calc[31], z_num(INF)};
                
                IEEE_zero : result = {z_calc[31], z_num(MAX_NORM)};

                IEEE_ninf : begin
                    if(z_calc[31] == 1'b1) begin
                        result = {1'b1, z_num(INF)};
                    end
                    else begin
                        result = {1'b0, z_num(MAX_NORM)};
                    end                   
                end

                IEEE_pinf : begin 
                    if(z_calc[31] == 1'b0) begin
                        result = {1'b0, z_num(INF)};
                    end
                    else begin
                        result = {1'b1, z_num(MAX_NORM)};
                    end
                end

                default : result = {z_calc[31], z_num(INF)};
            endcase
            if (result[30:23] == 8'hFF) inf_f = 1'b1;
        end
        else if(underflow == 1'b1) begin
            tiny_f = 1'b1;
            inexact_f =1'b1;

            case(round_t'(round))
                IEEE_near, near_maxMag : result = {1'b0, z_num(ZERO)};
                
                IEEE_zero : result = {1'b0, z_num(ZERO)};

                IEEE_ninf : begin
                    if(z_calc[31] == 1'b1) begin
                        result = {z_calc[31], z_num(MIN_NORM)};
                    end
                    else begin
                        result = {1'b1, z_num(ZERO)};
                    end
                end

                IEEE_pinf : begin 
                    if(z_calc[31] == 1'b0) begin
                        result = {1'b0, z_num(MIN_NORM)};
                    end
                    else begin
                        result = {1'b0, z_num(ZERO)};
                    end
                end

                default : result = {1'b0, z_num(ZERO)};
            endcase
            if (result[30:0] == 31'b0) zero_f = 1'b1;
        end

        else begin
            result = z_calc;
            inexact_f = inexact_bit;

            if (result[30:0] == 31'b0) zero_f = 1'b1;
        end
    end
end
endmodule