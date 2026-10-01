module test_status_z_combinations(
    input logic clk,
    input logic [31:0] a, b, z,
    input logic [7:0] status
);

    property p_zero;
        @(posedge clk) status[0] |-> (z[30:23] == 8'b0);
    endproperty

    assert_zero: assert property(p_zero)
        $display($stime,,,"\t\t %m PASS");
        else $error($stime,,,"\t\t %m FAIL");

    property p_inf;
        @(posedge clk) status[1] |-> (z[30:23] == 8'b1111_1111);
    endproperty

    assert_inf: assert property(p_inf)
        $display($stime,,,"\t\t %m PASS");
        else $error($stime,,,"\t\t %m FAIL");

    property p_nan;
        @(posedge clk) status[2] |->
            ($past(a[30:23], 2) == 8'b1111_1111) &&
            ($past(b[30:23], 2) == 8'b1111_1111) &&
            ($past(a[31], 2) != $past(b[31], 2));
    endproperty

    assert_nan: assert property(p_nan)
        $display($stime,,,"\t\t %m PASS");
        else $error($stime,,,"\t\t %m FAIL");

    property p_huge;
        @(posedge clk) status[4] |-> 
            (z[30:23] == 8'b1111_1111) ||
            ((z[30:23] == 8'b1111_1110) && (z[22:0] == 23'h7F_FFFF));
    endproperty

    assert_huge: assert property(p_huge)
        $display($stime,,,"\t\t %m PASS");
        else $error($stime,,,"\t\t %m FAIL");

endmodule