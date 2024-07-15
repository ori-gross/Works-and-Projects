module	message_mux (	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
					
		   // start screen
					input		logic	StartDrawingRequest,
					input		logic	[7:0] StartRGB,
					input		logic pressToStart,
					
		   //	win screen
					input		logic WinDrawingRequest,
					input		logic [7:0] WinRGB,
					input		logic gameWon,
					
		   // lose screen
					input		logic LoseDrawingRequest,
					input		logic [7:0] LoseRGB,
					input		logic gameLost,
					
					output	logic DrawingRequest,
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut <= 8'h00;
	end
	
	else begin
		RGBOut <= 8'h00;
		if (pressToStart == 1'b1)  begin 
			if (StartDrawingRequest == 1'b1)
				RGBOut <= StartRGB;
		end
		else if (gameWon == 1'b1) begin
			if (WinDrawingRequest == 1'b1)
				RGBOut <= WinRGB;
		end
		else if (gameLost == 1'b1) begin
			if (LoseDrawingRequest == 1'b1)
				RGBOut <= LoseRGB;
		end
	end
end

assign DrawingRequest = (RGBOut) ? 1'b1 : 1'b0;

endmodule


