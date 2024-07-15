module	info_mux (	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,					
		   // HP 
					input		logic	HPDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] HPRGB, 					
		   //	Time
					input		logic TimeDrawingRequest,
					input		logic [7:0] TIMERGB,
		   // Score
					input		logic ScoreDrawingRequest,
					input		logic [7:0] SCORERGB,
			// Level
					input		logic LevelDrawingRequest,
					input		logic [7:0] LEVELRGB,
					
					output	logic DrawingRequest,
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut <= 8'b0;
	end
	
	else begin
		if (HPDrawingRequest == 1'b1)   
			RGBOut <= HPRGB;
		else if (TimeDrawingRequest == 1'b1)
			RGBOut <= TIMERGB;
		else if (ScoreDrawingRequest == 1'b1)
			RGBOut <= SCORERGB;
		else if (LevelDrawingRequest == 1'b1)
			RGBOut <= LEVELRGB;
		else
			RGBOut <= 8'b0;
	end
end

assign DrawingRequest = (RGBOut) ? 1'b1 : 1'b0;

endmodule


