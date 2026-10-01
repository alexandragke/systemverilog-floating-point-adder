package corner_pkg;
    typedef enum int { 
        pos_nan,
        neg_nan,
        pos_inf,
        neg_inf,
        pos_norm,
        neg_norm,
        pos_denorm,
        neg_denorm,
        pos_zero,
        neg_zero
    } corner_t;

    function automatic logic [31:0] corner_val(corner_t c);
        case(c)
            pos_nan : return {1'b0, 8'hFF, 23'($urandom_range(1, 8388607))};
            neg_nan : return {1'b1, 8'hFF, 23'($urandom_range(1, 8388607))};
            pos_inf : return {1'b0, 8'hFF, 23'd0};
            neg_inf : return {1'b1, 8'hFF, 23'd0};
            pos_norm : return {1'b0, 8'($urandom_range(1, 254)), 23'($urandom())};
            neg_norm : return {1'b1, 8'($urandom_range(1, 254)), 23'($urandom())};
            pos_denorm : return {1'b0, 8'h00, 23'($urandom_range(1, 8388607))};
            neg_denorm : return {1'b1, 8'h00, 23'($urandom_range(1, 8388607))};
            pos_zero : return {1'b0, 8'h00, 23'd0};
            neg_zero : return {1'b1, 8'h00, 23'd0};
            default : return 32'b0;
        endcase
    endfunction
endpackage