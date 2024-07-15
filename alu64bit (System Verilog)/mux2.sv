// 2->1 multiplexer template
module mux2 (
    input logic d0,          // Data input 0
    input logic d1,          // Data input 1
    input logic sel,         // Select input
    output logic z           // Output
);

// Put your code here
// ------------------
	logic w1;
	logic w2;
	logic w3;

	NAND2 #(
		.Tpdhl(8),
		.Tpdlh(8)
	) g1(
		.A(sel),
		.B(sel),
		.Z(w1)
	);
	
	NAND2 #(
		.Tpdhl(8),
		.Tpdlh(8)
	) g2(
		.A(d0),
		.B(w1),
		.Z(w2)
	);
	
	NAND2 #(
		.Tpdhl(8),
		.Tpdlh(8)
	) g3(
		.A(d1),
		.B(sel),
		.Z(w3)
	);
	
	NAND2 #(
		.Tpdhl(8),
		.Tpdlh(8)
	) g4(
		.A(w2),
		.B(w3),
		.Z(z)
	);

// End of your code

endmodule
