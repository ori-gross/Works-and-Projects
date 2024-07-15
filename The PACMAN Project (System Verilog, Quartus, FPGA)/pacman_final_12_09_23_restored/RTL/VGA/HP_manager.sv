module HP_manager (
			input logic clk,
			input logic resetN,
			
			input logic [4:0] removeHP, // amount of HP to remove
			input logic [4:0] addHP, // amount of HP to add
			
			output logic decrease, // decrease HP graphic
			output logic increase // increase HP graphic
);

logic [4:0] addCounter = 5'h0;
logic [4:0] removeCounter = 5'h0;


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			removeCounter <= 5'h0;
			addCounter <= 5'h0;
			decrease <= 1'b0;
			increase <= 1'b0;
	end
	
	else begin
		decrease <= 1'b0;
		increase <= 1'b0;
		if (removeHP > 5'b0)
			removeCounter <= removeCounter + removeHP;
		if (addHP > 5'b0)
			addCounter <= addCounter + addHP;
		if (!removeHP && !addHP) begin // enter if both inputs are zero
			if (addCounter > 0 && removeCounter > 0) begin // if both counters arent zero no need to update HP
				addCounter <= addCounter - 5'h1;
				removeCounter <= removeCounter - 5'h1;
			end
			else begin
				if (removeCounter > 0) begin // remove HP removeCounter times
					decrease <= 1'b1;
					removeCounter <= removeCounter - 5'h1;
				end
				if (addCounter > 0) begin // add HP addCounter times
					increase <= 1'b1;
					addCounter <= addCounter - 5'h1;
				end
			end
		end
	end
end

endmodule
