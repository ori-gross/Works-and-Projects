// 32X32 Multiplier FSM
module mult32x32_fsm (
    input logic clk,              // Clock
    input logic reset,            // Reset
    input logic start,            // Start signal
    output logic busy,            // Multiplier busy indication
    output logic [1:0] a_sel,     // Select one byte from A
    output logic b_sel,           // Select one 2-byte word from B
    output logic [2:0] shift_sel, // Select output from shifters
    output logic upd_prod,        // Update the product register
    output logic clr_prod         // Clear the product register
);

// Put your code here
	
	// Declare states
	typedef enum {
		idle_st,
		a0_b0_st,
		a1_b0_st,
		a2_b0_st,
		a3_b0_st,
		a0_b1_st,
		a1_b1_st,
		a2_b1_st,
		a3_b1_st
	} sm_type;
	sm_type current_state;
	sm_type next_state;
	
	// Synchronous Logic
	always_ff @(posedge clk, posedge reset) begin
		if (reset == 1'b1) begin
			current_state <= idle_st;
		end
		else begin
			current_state <= next_state;
		end
	end
	
	// Asynchronous Logic
	always_comb begin
		next_state = current_state;
		busy = 1'b1;
		a_sel = 2'd0;
		b_sel = 1'd0;
		shift_sel = 3'd0;
		upd_prod = 1'b1;
		clr_prod = 1'b0;
		
		case (current_state)
			idle_st: begin
				busy = 1'b0;
				upd_prod = 1'b0;
				if (start == 1'b1) begin
					next_state = a0_b0_st;
					clr_prod = 1'b1;
				end
			end
			a0_b0_st: begin
				next_state = a1_b0_st;
				a_sel = 2'd0;
				b_sel = 1'd0;
				shift_sel = 3'd0;
			end
			a1_b0_st: begin
				next_state = a2_b0_st;
				a_sel = 2'd1;
				b_sel = 1'd0;
				shift_sel = 3'd1;
			end
			a2_b0_st: begin
				next_state = a3_b0_st;
				a_sel = 2'd2;
				b_sel = 1'd0;
				shift_sel = 3'd2;
			end
			a3_b0_st: begin
				next_state = a0_b1_st;
				a_sel = 2'd3;
				b_sel = 1'd0;
				shift_sel = 3'd3;
			end
			a0_b1_st: begin
				next_state = a1_b1_st;
				a_sel = 2'd0;
				b_sel = 1'd1;
				shift_sel = 3'd2;
			end
			a1_b1_st: begin
				next_state = a2_b1_st;
				a_sel = 2'd1;
				b_sel = 1'd1;
				shift_sel = 3'd3;
			end
			a2_b1_st: begin
				next_state = a3_b1_st;
				a_sel = 2'd2;
				b_sel = 1'd1;
				shift_sel = 3'd4;
			end
			a3_b1_st: begin
				next_state = idle_st;
				a_sel = 2'd3;
				b_sel = 1'd1;
				shift_sel = 3'd5;
			end
		endcase
	end
	
// End of your code

endmodule
