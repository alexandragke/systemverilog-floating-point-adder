module test_status_bits(
    input logic [7:0] status,
    input logic resetn
);

always_comb begin
    if(resetn) begin
        assert_zero_inf: assert (!(status[0] && status[1]))
            $display($stime,,,"\t\t %m PASS");
            else $error($stime,,,"\t\t %m FAIL");

        assert_zero_nan: assert (!(status[0] && status[2]))
            $display($stime,,,"\t\t %m PASS");
            else $error($stime,,,"\t\t %m FAIL");

        assert_inf_nan: assert (!(status[1] && status[2]))
            $display($stime,,,"\t\t %m PASS");
            else $error($stime,,,"\t\t %m FAIL");

        assert_tiny_huge: assert (!(status[3] && status[4]))
            $display($stime,,,"\t\t %m PASS");
            else $error($stime,,,"\t\t %m FAIL");

        assert_tiny_inf: assert (!(status[1] && status[3]))
            $display($stime,,,"\t\t %m PASS");
            else $error($stime,,,"\t\t %m FAIL");

        assert_tiny_nan: assert (!(status[2] && status[3]))
            $display($stime,,,"\t\t %m PASS");
            else $error($stime,,,"\t\t %m FAIL");

        assert_huge_zero: assert (!(status[0] && status[4]))
            $display($stime,,,"\t\t %m PASS");
            else $error($stime,,,"\t\t %m FAIL");

        assert_huge_nan: assert (!(status[2] && status[4]))
            $display($stime,,,"\t\t %m PASS");
            else $error($stime,,,"\t\t %m FAIL");

        assert_inexact_nan: assert (!(status[2] && status[5]))
            $display($stime,,,"\t\t %m PASS");
            else $error($stime,,,"\t\t %m FAIL");
    end
end
endmodule