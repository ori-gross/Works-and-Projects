// Full Adder/Subtractor template
module fas (
    input logic a,           // Input bit a
    input logic b,           // Input bit b
    input logic cin,         // Carry in
    input logic a_ns,        // A_nS (add/not subtract) control
    output logic s,          // Output S
    output logic cout        // Carry out
);

// Put your code here
// ------------------
	logic d;
	logic e;
	logic f;
	logic h;
	logic i;
	logic j;
	logic k;
	XNOR2 # (.Tpdhl(9),.Tpdlh(9))g2(.A(b),.B(cin),.Z(d));
	OR2 # (.Tpdhl(8),.Tpdlh(8)) g1(.A(a),.B(d),.Z(e));
	NAND2 # (.Tpdhl(8),.Tpdlh(8)) g4(.A(d),.B(a),.Z(f));
	NAND2 # (.Tpdhl(8),.Tpdlh(8)) g3(.A(e),.B(f),.Z(s));
	XNOR2 # (.Tpdhl(9),.Tpdlh(9)) g5(.A(a),.B(a_ns),.Z(h));
	OR2 # (.Tpdhl(8),.Tpdlh(8)) g7(.A(b),.B(cin),.Z(j));
	NAND2 # (.Tpdhl(8),.Tpdlh(8)) g6(.A(h),.B(j),.Z(i));
	NAND2 # (.Tpdhl(8),.Tpdlh(8)) g9(.A(b),.B(cin),.Z(k));
	NAND2 # (.Tpdhl(8),.Tpdlh(8)) g8(.A(i),.B(k),.Z(cout));

// End of your code

endmodule
