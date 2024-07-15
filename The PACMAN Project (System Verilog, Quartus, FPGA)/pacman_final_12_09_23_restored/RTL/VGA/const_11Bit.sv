// module to output a constant value


module const_11Bit (
	
	output logic [10:0] result
);

parameter logic [10:0] constant = 11'h001;

assign result = constant;

endmodule
