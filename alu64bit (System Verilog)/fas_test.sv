// Full Adder/Subtractor test bench template
module fas_test;

// Put your code here
// ------------------
	logic s;
    logic cout;
	
	logic a;
    logic b;
	logic a_ns;
    logic cin;

	fas uut(.a(a),.b(b),.cin(cin),.a_ns(a_ns),.s(s),.cout(cout));
	
	initial begin
		a=0;
		b=0;
		a_ns=0;
		cin=0;
		
		#100;
		a=0;
		b=1;
		a_ns=0;
		cin=0;
		
		#100;
		a=0;
		b=0;
		a_ns=0;
		cin=0;
		
		#100;
	end

// End of your code

endmodule
