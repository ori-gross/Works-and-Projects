module Level_manager (
			input logic clk,
			input logic resetN,
			input logic levelUp, // pulse if lvl won and new stage started
			
			output logic increase // up to increase lvl graphic
);



always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			increase <= 1'b0;
	end
	
	else begin
		increase <= 1'b0;
		if (levelUp) 
			increase <= 1'b1;
	end
end

endmodule
