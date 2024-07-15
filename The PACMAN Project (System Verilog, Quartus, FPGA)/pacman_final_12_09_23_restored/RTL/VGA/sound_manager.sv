module sound_manager (

			input 	logic clk,
			input 	logic resetN,
			input 	logic wallHit, // collision between pacman and wall
			input 	logic coinTaken, // collison between pacman and coin
			input		logic wallBroke, // up if wall was broken
			input		logic monsterHit, // collision between pacman and monster
			input		logic monsterType, // up if monster is red
			input		logic win, // game won
			input		logic lose, // game lost
			
			output 	logic EnableSound,
			output 	logic [3:0] frequency
);

logic [25:0] sound_time;
logic [2:0] sound_type;
logic monsterHit_D; // clk delay of monsterHit
logic win_D; // clk delay of win
logic lose_D; // clk delay of lose


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		EnableSound	<= 1'b0;
		frequency 	<= 4'd0;
		sound_time 	<= 26'd0;
		sound_type	<= 3'b000;
		monsterHit_D <= 1'b0;
		win_D <= 1'b0;
		lose_D <= 1'b0;
	end
	
	else begin
		EnableSound <= 1'b0;
		monsterHit_D <= monsterHit;
		
		if (sound_time > 0) begin // play sound
			EnableSound <= 1'b1;
			if (sound_type == 3'b001) // hit a wall
				frequency <= 4'd9;
			else if (sound_type == 3'b010) // take a coin
				frequency <= 4'd3;
			else if (sound_type == 3'b011) begin // break a wall
				if (sound_time > 26'd2500000) 
					frequency <= 4'd9;
				else 
					frequency <= 4'd5;
			end
			else if (sound_type == 3'b100) // hit a red monster
				frequency <= 4'd15;
			else if (sound_type == 3'b101) // hit a green monster
				frequency <= 4'd1;
			else if (sound_type == 3'b110) begin // win the game
				if (sound_time > 26'd40000000) 
					frequency <= 4'd3;
				else if (sound_time > 26'd30000000) 
					frequency <= 4'd2;
				else 
					frequency <= 4'd1;
			end
			else if (sound_type == 3'b111) begin // lose the game
				if (sound_time > 26'd40000000) 
					frequency <= 4'd7;
				else if (sound_time > 26'd30000000) 
					frequency <= 4'd8;
				else 
					frequency <= 4'd9;
			end
			sound_time <= sound_time - 26'd1;
		end
		
		if (wallHit) begin
			EnableSound <= 1'b1;
			sound_time <= 26'd5000000;
			sound_type	<= 3'b001; // hit a wall
		end
		
		if (coinTaken) begin
			EnableSound <= 1'b1;
			sound_time <= 26'd5000000;
			sound_type	<= 3'b010; // take a coin
		end
		
		if (wallBroke) begin
			EnableSound <= 1'b1;
			sound_time <= 26'd5000000;
			sound_type	<= 3'b011; // break a wall
		end
		
		if (monsterHit_D) begin
			EnableSound <= 1'b1;
			sound_time <= 26'd5000000;
			if (monsterType) sound_type <= 3'b100; // hit a red monster
			else sound_type <= 3'b101; // hit a green monster
		end
			
		win_D <= win;
		if (win && !win_D) begin
			EnableSound <= 1'b1;
			sound_time <= 26'd50000000;
			sound_type	<= 3'b110; // win the game
		end
		
		lose_D <= lose;
		if (lose && !lose_D) begin
			EnableSound <= 1'b1;
			sound_time <= 26'd50000000;
			sound_type <= 3'b111; // lose the game
		end
		
	end
end

endmodule
