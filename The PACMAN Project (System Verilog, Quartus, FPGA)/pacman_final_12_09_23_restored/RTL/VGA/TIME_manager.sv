module TIME_manager (
			input logic clk,
			input logic resetN,
			input logic startOfFrame,
			input logic playGame, // up if game is playable

			output logic decrease // up to decrease time graphic
);

int counter = 0;


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			counter <= 0;
			decrease <= 1'b0;
	end
	
	else begin
		decrease <= 1'b0;
		if (playGame)
			counter <= counter + 1;
		if (counter == 31500000) begin // count 1 second
			decrease <= 1'b1; // pulse to decrease time
			counter <= 0;
		end
	end
end

endmodule
