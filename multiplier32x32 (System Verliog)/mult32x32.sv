// 32X32 Iterative Multiplier template
module mult32x32 (
    input logic clk,            // Clock
    input logic reset,          // Reset
    input logic start,          // Start signal
    input logic [31:0] a,       // Input a
    input logic [31:0] b,       // Input b
    output logic busy,          // Multiplier busy indication
    output logic [63:0] product // Miltiplication product
);

// Put your code here
	
	// Logics
	logic [1:0] a_sel;     	// Select one byte from A
    logic b_sel;           	// Select one 2-byte word from B
    logic [2:0] shift_sel; 	// Select output from shifters
    logic upd_prod;        	// Update the product register
    logic clr_prod;     	// Clear the product register
	
	// FSM Unit
	mult32x32_fsm fsm_u(
		.clk(clk),
		.reset(reset),
		.start(start),
		.busy(busy),
		.a_sel(a_sel),
		.b_sel(b_sel),
		.shift_sel(shift_sel),
		.upd_prod(upd_prod),
		.clr_prod(clr_prod)
	);
	
	// Arithmetic Unit
	mult32x32_arith arith_u(
		.clk(clk),
		.reset(reset),
		.a(a),
		.b(b),
		.a_sel(a_sel),
		.b_sel(b_sel),
		.shift_sel(shift_sel),
		.upd_prod(upd_prod),
		.clr_prod(clr_prod),
		.product(product)
	);

// End of your code

endmodule
