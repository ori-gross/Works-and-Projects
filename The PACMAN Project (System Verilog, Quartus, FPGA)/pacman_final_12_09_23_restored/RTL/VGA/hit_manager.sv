
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	hit_manager	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_pacman,
			input	logic	drawing_request_tiles,
			input	logic	drawing_request_coins,
			input	logic	drawing_request_bracket,
			input logic drawing_request_monster_one,
			input logic drawing_request_monster_two,
			input logic drawing_request_monster_three,
			input logic drawing_request_monster_four,

			
			output logic collision_pacman, // active in case of collision between two objects
			output logic wallHit,
			output logic coinTaken,
			output logic monsterHit,
			output logic collision_monster_tile_one,
			output logic collision_monster_tile_two,
			output logic collision_monster_tile_three,
			output logic collision_monster_tile_four,
			output logic collision_monster_pacman_one,
			output logic collision_monster_pacman_two,
			output logic collision_monster_pacman_three,
			output logic collision_monster_pacman_four
);


logic collision_pacman_coin;
logic collision_pacman_tile;
logic collision_pacman_monster;

assign collision_pacman = ( drawing_request_pacman &&  ( drawing_request_tiles || drawing_request_bracket));// BG - pacman collision 
assign collision_monster_tile_one = ( drawing_request_monster_one &&  ( drawing_request_tiles || drawing_request_bracket));// BG - monster collision 
assign collision_monster_tile_two = ( drawing_request_monster_two &&  ( drawing_request_tiles || drawing_request_bracket));// BG - monster collision 
assign collision_monster_tile_three = ( drawing_request_monster_three &&  ( drawing_request_tiles || drawing_request_bracket));// BG - monster collision 
assign collision_monster_tile_four = ( drawing_request_monster_four &&  ( drawing_request_tiles || drawing_request_bracket));// BG - monster collision 

assign collision_monster_pacman_one = ( drawing_request_monster_one &&  drawing_request_pacman);// monster-pacman collision 
assign collision_monster_pacman_two = ( drawing_request_monster_two &&  drawing_request_pacman);// monster-pacman collision  
assign collision_monster_pacman_three = ( drawing_request_monster_three &&  drawing_request_pacman);// monster-pacman collision 
assign collision_monster_pacman_four = ( drawing_request_monster_four &&  drawing_request_pacman);// monster-pacman collision 

assign collision_pacman_tile = (drawing_request_pacman && drawing_request_tiles); // pacman-tile collision
assign collision_pacman_coin = (drawing_request_pacman && drawing_request_coins); // pacman-coin collision 
assign collision_pacman_monster = (drawing_request_pacman && (drawing_request_monster_one ||
																				  drawing_request_monster_two ||
																				  drawing_request_monster_three ||
																				  drawing_request_monster_four)); // pacman-monster collision 

// flags to rise according outputs at max once per frame
logic flag_tile;
logic flag_coin; 
logic flag_monster;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag_tile <= 1'b0;
		wallHit <= 1'b0;
		flag_coin <= 1'b0;
		coinTaken <= 1'b0;
		flag_monster <= 1'b0;
		monsterHit <= 1'b0;
	end 
	else begin
		wallHit <= 1'b0;
		coinTaken <= 1'b0;
		monsterHit <= 1'b0;
		if(startOfFrame) begin // reset for next frame 
			flag_tile <= 1'b0;
			flag_coin <= 1'b0; 
			flag_monster <= 1'b0;
		end
		
		if (collision_pacman_tile  && (flag_tile == 1'b0)) begin 
			flag_tile <= 1'b1; // to enter only once
			wallHit <= 1'b1;
		end
		
		if (collision_pacman_coin  && (flag_coin == 1'b0)) begin 
			flag_coin <= 1'b1; // to enter only once
			coinTaken <= 1'b1;
		end
		
		if (collision_pacman_monster  && (flag_monster == 1'b0)) begin 
			flag_monster <= 1'b1; // to enter only once
			monsterHit <= 1'b1;
		end
	end 
end

endmodule
