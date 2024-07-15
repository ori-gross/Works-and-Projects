// 1-bit ALU template
module alu1bit (
    input logic a,           // Input bit a
    input logic b,           // Input bit b
    input logic cin,         // Carry in
    input logic [1:0] op,    // Operation
    output logic s,          // Output S
    output logic cout        // Carry out
);

// Put your code here
// ------------------
	logic w1;
	logic w2;
	logic w3;
	logic w4;
	logic w5;
	logic w6;

	OR2 # (.Tpdhl(8),.Tpdlh(8)) g1(.A(a),.B(b),.Z(w1));
	NAND2 # (.Tpdhl(8),.Tpdlh(8)) g2(.A(w1),.B(w1),.Z(w2));
	XNOR2 # (.Tpdhl(9),.Tpdlh(9)) g3(.A(a),.B(b),.Z(w3));
	NAND2 # (.Tpdhl(8),.Tpdlh(8)) g4(.A(w3),.B(w3),.Z(w4));
	NAND2 # (.Tpdhl(8),.Tpdlh(8)) g5(.A(op[0]),.B(op[1]),.Z(w5));
	fas fas0(.a(a),.b(b),.cin(cin),.a_ns(w5),.s(w6),.cout(cout));
	mux4 m4(.d0(w2),.d1(w4),.d2(w6),.d3(w6),.sel(op),.z(s));

// End of your code

endmodule
