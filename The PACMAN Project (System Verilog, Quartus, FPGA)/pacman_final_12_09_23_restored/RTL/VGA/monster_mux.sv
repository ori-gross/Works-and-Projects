module	monster_mux (	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
					
					input		logic	monsterOneDR, // two set of inputs per unit
					input		logic	[7:0] monsterOneRGB, 
					
					input		logic monsterTwoDR,
					input		logic [7:0] monsterTwoRGB,
					
					input		logic monsterThreeDR,
					input		logic [7:0] monsterThreeRGB,
					
					input		logic monsterFourDR,
					input		logic [7:0] monsterFourRGB,
					
					output	logic DrawingRequest,
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut <= 8'b0;
	end
	
	else begin
		if (monsterOneDR == 1'b1)   
			RGBOut <= monsterOneRGB;
		else if (monsterTwoDR == 1'b1)
			RGBOut <= monsterTwoRGB;
		else if (monsterThreeDR == 1'b1)
			RGBOut <= monsterThreeRGB;
		else if (monsterFourDR == 1'b1)
			RGBOut <= monsterFourRGB;
		else
			RGBOut <= 8'b0;
	end
end

assign DrawingRequest = (RGBOut) ? 1'b1 : 1'b0;

endmodule


