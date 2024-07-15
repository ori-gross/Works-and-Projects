
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	Numbers_mux (	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
					
		   // ones 
					input		logic	onesDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] onesRGB, 
					
		   //	tens
					input		logic tensDrawingRequest,
					input		logic [7:0] tensRGB,
					
		   // hundreds
					input		logic hundredsDrawingRequest,
					input		logic [7:0] hundredsRGB,
					
		   //	text
					input		logic textDrawingRequest,
					input		logic [7:0] textRGB,
					
					output	logic NumbersDrawingRequest,
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut <= 8'b0;
	end
	
	else begin
		if (textDrawingRequest == 1'b1)   
			RGBOut <= textRGB;
		else if (hundredsDrawingRequest == 1'b1)
			RGBOut <= hundredsRGB;
		else if (tensDrawingRequest == 1'b1)
			RGBOut <= tensRGB;
		else if (onesDrawingRequest == 1'b1)
			RGBOut <= onesRGB;
		else
			RGBOut <= 8'b0;
	end
end

assign NumbersDrawingRequest = (RGBOut) ? 1'b1 : 1'b0;

endmodule


