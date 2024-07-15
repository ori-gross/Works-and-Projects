
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux_pacman	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
					input		logic playGame, // signal indicating that the game is playable
					
					input		logic signed [10:0] pixelX,
			
			// monster
					input		logic monsterDrawingRequest,
					input		logic [7:0] monsterRGB,
					
		   // pacman 
					input		logic	pacmanDrawingRequest,
					input		logic	[7:0] pacmanRGB,
					
		   //	coin
					input		logic coinDrawingRequest,
					input		logic [7:0] coinRGB,
		   // info
					input		logic infoDrawingRequest,
					input		logic [7:0] infoRGB,
					
		   //	tiles
					input		logic tileDrawingRequest,
					input		logic [7:0] tileRGB,
					
		   // background    
					input		logic	BGDrawingRequest,
					input		logic	[7:0] backGroundRGB,
					
		   // message
					input		logic	messageDrawingRequest,
					input		logic	[7:0] messageRGB,
					
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		RGBOut <= 8'h00; // default value (transperant)
		if (playGame) begin
			if (pixelX <= 11'b1) // fix trailing pixels
				RGBOut <= 8'b0;
			
			// draw the pixel according to following hierarchy
			else if (monsterDrawingRequest == 1'b1) 
				RGBOut <= monsterRGB;
			
			else if (pacmanDrawingRequest == 1'b1) 
				RGBOut <= pacmanRGB;
			
			else if (coinDrawingRequest == 1'b1)
				RGBOut <= coinRGB;
			
			else if (tileDrawingRequest == 1'b1)
				RGBOut <= tileRGB;
		end
		else begin
			if (messageDrawingRequest == 1'b1)
				RGBOut <= messageRGB;
		end
		if (infoDrawingRequest == 1'b1)
			RGBOut <= infoRGB;
			
		else if (BGDrawingRequest == 1'b1)
			RGBOut <= backGroundRGB;
	end
end

endmodule


