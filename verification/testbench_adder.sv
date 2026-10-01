`timescale 1ns/1ps

import round_pkg::*;
import corner_pkg::*;

module testbench_adder ();
    logic [31:0] result;           // result = a + b
    logic [7:0] status;           // Status bits for the result
    logic [31:0] a, b;
    logic [2:0] round;          // Rounding mode
    bit clk, resetn;           // Clock and reset signals

    logic [32:0] a_big, b_big, result_big;
    logic [31:0] exp_r1, exp_r2;

    int random_error;
    int random_total;
    int corner_error;
    int corner_total;

	fp_adder_top dut_fp (.*);

// binding SVAs with wrapper module
    bind fp_adder_top test_status_bits sva_status_inst(.*);

    bind fp_adder_top test_status_z_combinations sva_z_inst(
        .z(result),
        .*
    );

	// Instantiate the hardfloat reference model 
	logic [31:0] results_hf;	// The results_hf 32-bit floatinf point number (after the recoding in Hardfloat), will be translated to the results_ref
	logic [31:0] results_ref;	// This is the golden reference value to be compared with the DUT result
	logic [2:0] rnd_hf;
	logic [31:0] a_hf, b_hf;	// These will be the floating point 32-bit inputs to the Hardfloat rec modules

    assign rnd_hf = round;

	// Update the reference model inputs
	always_comb begin
		// If a is NaN => Inf
		if(a[30:23] == '1) begin
			a_hf = {a[31], {8{1'b1}}, {23{1'b0}}};
		end
		// If a is denorm => Zero
		else if(a[30:23] == '0 ) begin
			a_hf = {a[31], {31{1'b0}}};
		end
		else begin
			a_hf = a;
		end

		// If b is NaN => Inf
		if(b[30:23] == '1) begin
			b_hf = {b[31], {8{1'b1}}, {23{1'b0}}};
		end
		// If b is denorm => Zero
		 else if(b[30:23] == '0 ) begin
			b_hf = {b[31], {31{1'b0}}};
		end
		else begin
			b_hf = b;
		end

		// If result is denorm => Zero or Min normal
		if(results_hf[30:23] == '0 && |results_hf[22:0]) begin
			if (round == 3'b001 || round == 3'b000 || (round == 3'b010 && !results_hf[31]) || (round == 3'b011 && results_hf[31]) || round == 3'b100)
				results_ref = {results_hf[31], {31{1'b0}}};
			else
				results_ref = {results_hf[31], {7{1'b0}}, 1'b1, {23{1'b0}}};
		end
		// If result is NaN => Inf
		else if(results_hf[30:23] == '1 && |results_hf[22:0]) begin
			results_ref = {results_hf[31], {8{1'b1}}, {23{1'b0}}};
		end
		else
			results_ref = results_hf;
	end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;  //toggle every 5ns -> period = 10ns
    end

    fNToRecFN #(8, 24) a_conv(  //convert 32-bit a to 33-bit a
        .in(a_hf),
        .out(a_big)
    );

    fNToRecFN #(8, 24) b_conv( //convert 32-bit b to 33-bit b
        .in(b_hf),
        .out(b_big)
    );

    addRecFN #(8, 24) ref_adder(
        .control(1'b0),
        .subOp(1'b0),
        .a(a_big),
        .b(b_big),
        .roundingMode(round),
        .out(result_big),
        .exceptionFlags()
    );

    recFNToFN #(8, 24) result_conv( //convert 33-bit result to 32-bit result
        .in(result_big),
        .out(results_hf)
    );

    task random; //check 10000 random tests for 5 rounding modes
        int i, j;

        random_error = 0;
        random_total = 0;

        resetn = 0;
        @(negedge clk);
        resetn = 1;

        for(i=1; i<=10000; i++) begin
            a = $urandom();
            b = $urandom();

            for(j = 0; j<=4; j++) begin
                @(negedge clk);
                round = j;
                random_total++;

                if(random_total > 2) begin
                    if(result !== exp_r2) begin
                        $display("Random Test Failed | a = %h, b = %h | Round = %h | Result = %h | Expected Result = %h", a, b, round, result, exp_r2);
                        
                        random_error++;
                    end
                end
            end
        end

// after the inputs stop repeat 2 times
        repeat(2) begin
            @(negedge clk);
            if(result !== exp_r2) begin
                $display("Random Test Failed | a = %h, b = %h | Round = %h | Result = %h | Expected Result = %h", a, b, round, result, exp_r2);
                random_error++;
            end
        end
    endtask: random

    task corner;  //check the 100 corner cases for 5 rounding modes
        int i, j, k;
        corner_t type_a, type_b;

        corner_error = 0;
        corner_total = 0;

        resetn = 0;
        @(negedge clk);
        resetn = 1;

        for(i=0; i<=9; i++) begin
            for(j=0; j<= 9; j++) begin
                type_a = corner_t'(i);
                type_b = corner_t'(j);

                a = corner_val(type_a);
                b = corner_val(type_b);

                for(k=0; k<=4; k++) begin
                    @(negedge clk);
                    round = k;
                    corner_total++;

                    if(corner_total > 2) begin
                        if(result !== exp_r2) begin
                            $display("Corner Test Failed | a = %h, b = %h | Round = %h | Result = %h | Expected Result = %h", a, b, round, result, exp_r2);

                            corner_error++;
                        end
                    end
                end
            end
        end

// after the inputs stop repeat 2 times
        repeat(2) begin
            @(negedge clk);
            if(result !== exp_r2) begin
                $display("Corner Test Failed | a = %h, b = %h | Round = %h | Result = %h | Expected Result = %h", a, b, round, result, exp_r2);
                
                corner_error++;
            end
        end
    endtask: corner

    initial begin
        a = 32'b0;
        b = 32'b0;
        round = 3'b0;

        random();
        corner();

        $display("Executed Tests %0d", random_total + corner_total);
        $display("Random Tests SUCCESS %0d / %0d", random_total - random_error, random_total);
        $display("Corner Tests SUCCESS %0d / %0d", corner_total - corner_error, corner_total);

        $finish;
    end

// 2-cycle delay to reference result
    always_ff @(posedge clk or negedge resetn) begin
        if(!resetn) begin
            exp_r1 <= 32'b0;
            exp_r2 <= 32'b0;
        end
        else begin
            exp_r1 <= results_ref;
            exp_r2 <= exp_r1;
        end
    end   
endmodule