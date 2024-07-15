module	monster_HP_mux (	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
					
					input		logic	[4:0] addHPOne, // two set of inputs per unit
					input		logic	[4:0] removeHPOne, 
					
					input		logic	[4:0] addHPTwo,
					input		logic	[4:0] removeHPTwo, 
					
					input		logic	[4:0] addHPThree,
					input		logic	[4:0] removeHPThree, 
					
					input		logic	[4:0] addHPFour,
					input		logic	[4:0] removeHPFour, 
					
					output	logic [4:0] addHPmonsters,
				   output	logic	[4:0] removeHPmonsters,
					output	logic pacmanRespawn
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		addHPmonsters <= 5'h0;
		removeHPmonsters <= 5'h0;
		pacmanRespawn <= 1'b0;
	end
	
	else begin
		addHPmonsters <= 5'h0;
		removeHPmonsters <= 5'h0;
		pacmanRespawn <= 1'b0;
		// choose one HP addition
		if (addHPOne)   
			addHPmonsters <= addHPOne;
		else if (addHPTwo)
			addHPmonsters <= addHPTwo;
		else if (addHPThree)
			addHPmonsters <= addHPThree;
		else if (addHPFour)
			addHPmonsters <= addHPFour;
		
		// choose one HP removal
		if (removeHPOne) begin
			removeHPmonsters <= removeHPOne;
			pacmanRespawn <= 1'b1;
		end
		else if (removeHPTwo) begin
			removeHPmonsters <= removeHPTwo;
			pacmanRespawn <= 1'b1;
		end
		else if (removeHPThree) begin
			removeHPmonsters <= removeHPThree;
			pacmanRespawn <= 1'b1;
		end
		else if (removeHPFour) begin
			removeHPmonsters <= removeHPFour;
			pacmanRespawn <= 1'b1;
		end
	end
end

endmodule


