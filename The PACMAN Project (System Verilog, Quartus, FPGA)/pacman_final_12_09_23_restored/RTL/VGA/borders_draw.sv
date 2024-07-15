//-- feb 2021 add all colors square 
// (c) Technion IIT, Department of Electrical Engineering 2021


module	borders_draw	(	

					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] pixelX,
					input logic	[10:0] pixelY,

					output logic [7:0]	BG_RGB,
					output logic bordersDrawReq 
);

const int xBracketStart = 513;
const int xBracketEnd	= 516;

logic [2:0] redBits;
logic [2:0] greenBits;
logic [1:0] blueBits;


localparam logic [2:0] DARK_COLOR = 3'b000 ;// bitmap of a dark color
localparam logic [2:0] LIGHT_COLOR = 3'b111 ;// bitmap of a light color
 
 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
				redBits <= DARK_COLOR;	
				greenBits <= DARK_COLOR;	
				blueBits <= DARK_COLOR[1:0];	 
	end 
	else begin

	// defaults 
		redBits <= DARK_COLOR;	
		greenBits <= DARK_COLOR;	
		blueBits <= DARK_COLOR[1:0];
		bordersDrawReq <= 1'b0;
		
		// draw the border
		if ((pixelX >= xBracketStart) && (pixelX <= xBracketEnd)) 
			begin 
					redBits <= LIGHT_COLOR;	
					greenBits <= LIGHT_COLOR;	
					blueBits <= LIGHT_COLOR[1:0];
					bordersDrawReq <= 1'b1;
			end

		BG_RGB =  {redBits , greenBits , blueBits} ; //collect color nibbles to an 8 bit word 
		
	end; 	
end 
endmodule

