module Score_manager (
			input logic clk,
			input logic resetN,
			input logic addScore, // pulse to add score after taking a coin
			
			output logic increase // increase score graphic
);



always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			increase <= 1'b0;
	end
	
	else begin
		increase <= 1'b0;
		if (addScore)
			increase <= 1'b1;
	end
end

endmodule
