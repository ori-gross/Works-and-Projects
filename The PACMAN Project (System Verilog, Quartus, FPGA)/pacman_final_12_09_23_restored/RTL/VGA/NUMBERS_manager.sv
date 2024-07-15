module NUMBERS_manager (
			input logic clk,
			input logic resetN,
			
			input logic decrease, // up if need to decrease output
			input logic increase, // up if need to increase outpu
			input logic zeroFlag, // if up and output is zero, dont act
			
			output logic zero, // up if output is zero
			output logic [3:0] outOnes,
			output logic [3:0] outTens,
			output logic [3:0] outHundreds
);

// starting parameters
parameter  logic [3:0] startOnes = 4'h0;
parameter  logic [3:0] startTens = 4'h0;
parameter  logic [3:0] startHundreds = 4'h1;


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			outOnes <= startOnes;
			outTens <= startTens;
			outHundreds <= startHundreds;
	end
	
	else begin
		if (!(zeroFlag && zero)) begin 
			if (increase ^ decrease) begin // enter only if one is up
				if (increase) begin // enter to increase output by one
					if (outOnes == 4'h9) begin
						if (outTens == 4'h9) begin
							if (outHundreds != 4'h9) begin
								outHundreds <= outHundreds + 4'h1;
								outTens <= 4'h0;
								outOnes <= 4'h0;
							end
						end
						else begin
							outTens <= outTens + 4'h1;
							outOnes <= 4'h0;
						end
					end
					else begin
						outOnes <= outOnes + 4'h1;
					end
				end
				if (decrease) begin // enter to decrease output by one
					if (outOnes == 4'h0) begin
						if (outTens == 4'h0) begin
							if (outHundreds != 4'h0) begin
								outHundreds <= outHundreds - 4'h1;
								outTens <= 4'h9;
								outOnes <= 4'h9;
							end
						end
						else begin
							outTens <= outTens - 4'h1;
							outOnes <= 4'h9;
						end
					end
					else begin
						outOnes <= outOnes - 4'h1;
					end
				end
			end
		end
	end
end

assign zero = ((outHundreds == 4'h0) && (outTens == 4'h0) && (outOnes == 4'h0)) ? 1'b1 : 1'b0;
endmodule
