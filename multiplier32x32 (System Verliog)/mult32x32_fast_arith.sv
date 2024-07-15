// 32X32 Multiplier arithmetic unit template
module mult32x32_fast_arith (
    input logic clk,             // Clock
    input logic reset,           // Reset
    input logic [31:0] a,        // Input a
    input logic [31:0] b,        // Input b
    input logic [1:0] a_sel,     // Select one byte from A
    input logic b_sel,           // Select one 2-byte word from B
    input logic [2:0] shift_sel, // Select output from shifters
    input logic upd_prod,        // Update the product register
    input logic clr_prod,        // Clear the product register
    output logic a_msb_is_0,     // Indicates MSB of operand A is 0
    output logic b_msw_is_0,     // Indicates MSW of operand B is 0
    output logic [63:0] product  // Miltiplication product
);

// Put your code here
// ------------------
	
	// logics
	logic [7:0] a_out;
	logic [15:0] b_out;
	logic [23:0] multiplier_out;
	logic [63:0] shift_out;
	
	// A mux
	always_comb begin
		case (a_sel)
			2'd0: a_out = {a[7:0]};
			2'd1: a_out = {a[15:8]};
			2'd2: a_out = {a[23:16]};
			2'd3: a_out = {a[31:24]};
			default: a_out = {32{1'b0}};
		endcase
	end
	
	// B mux
	always_comb begin
		case (b_sel)
			1'd0: b_out = {b[15:0]};
			1'd1: b_out = {b[31:16]};
			default: b_out = {32{1'b0}};
		endcase
	end
	
	// 16X8 multiplier
	always_comb begin
		multiplier_out = a_out * b_out;
	end	
	
	// Shift mux
	always_comb begin
		case (shift_sel)
			3'd0: shift_out = {{40{1'b0}},{multiplier_out[23:0]}};
			3'd1: shift_out = {{40{1'b0}},{multiplier_out[23:0]}} << 8;
			3'd2: shift_out = {{40{1'b0}},{multiplier_out[23:0]}} << 16;
			3'd3: shift_out = {{40{1'b0}},{multiplier_out[23:0]}} << 24;
			3'd4: shift_out = {{40{1'b0}},{multiplier_out[23:0]}} << 32;
			3'd5: shift_out = {{40{1'b0}},{multiplier_out[23:0]}} << 40;
			3'd6: shift_out = {64{1'b0}};
			3'd7: shift_out = {64{1'b0}};
			default: shift_out = {64{1'b0}};
		endcase
	end
	
	// Product register
	always_ff @(posedge clk, posedge reset) begin
		if (reset == 1'b1) begin
			product <= {64{1'b0}};
		end
		else begin
			if (clr_prod == 1'b1) begin
				product <= {64{1'b0}};
				if(a[31:24]== 1'b0) begin
				a_msb_is_0 <= 1'b1;
				end
				else begin
				a_msb_is_0 <= 1'b0;
				end
				if(b[31:16]== 1'b0) begin
					b_msw_is_0 <= 1'b1;
				end
				else begin
				b_msw_is_0 <= 1'b0;
				end	
			end
			else if (upd_prod == 1'b1) begin
				product <= product + shift_out;
			end
		end
	end


// End of your code

endmodule
