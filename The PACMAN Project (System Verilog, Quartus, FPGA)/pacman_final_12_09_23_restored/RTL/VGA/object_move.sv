// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 


module	object_move(	 
					input		logic	clk,
					input		logic	resetN,
					input		logic	startOfFrame,  		// short pulse every start of frame 30Hz
					input		logic playGame,				// up if the game is playable
					input		logic	move_down,  			// move Y down
					input		logic	move_left,   			// move X left
					input		logic	move_right,   			// move X right
					input		logic	move_up,  				// move Y up
					input		logic objectAlive,			// the object is alive
					input 	logic collision,  			// collision if monster hits an object
					input 	logic object_respawn,		// up if the object needs to respawn
					input		logic wall_broke,				// wall was broken
					input		logic changeDirectionFlag, // if up, try to change direction on collision
					input		logic	[3:0] HitEdgeCode,	// one bit per edge 

					output	logic signed [10:0] topLeftX,		// output the top left corner 
					output	logic signed [10:0] topLeftY, 	// can be negative , if the object is partliy outside
					output	logic [3:0] curr_direction,		// one bit per current direction
					output	logic changeDirection				// change direction of object if up
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 384;
parameter int INITIAL_Y = 96;
parameter int SPEED = 40;
const int FIXED_POINT_MULTIPLIER	=	64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions


// movement limits 
const int   OBJECT_WIDTH_X = 32;
const int   OBJECT_HIGHT_Y = 32;
const int	SafetyMargin =	1;

const int	x_FRAME_LEFT	=	(SafetyMargin) * FIXED_POINT_MULTIPLIER / 2; 
const int	x_FRAME_RIGHT	=	(639 - SafetyMargin - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int	y_FRAME_TOP		=	(SafetyMargin) * FIXED_POINT_MULTIPLIER / 2;
const int	y_FRAME_BOTTOM	=	(481 -SafetyMargin - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER;

enum  logic [2:0] {IDLE_ST, // initial state
					MOVE_ST, // moving no colision 
					COLLISION_HANDLE_ST, // change speed done, handle collison until startOfFrame  
					POSITION_CHANGE_ST,// position interpolate 
					POSITION_LIMITS_ST //check if inside the frame  
					}  SM_PS, 
						SM_NS;

 int Xspeed_PS,  Xspeed_NS  ; // speed    
 int Yspeed_PS,  Yspeed_NS  ; 
 int Xposition_PS, Xposition_NS ; // position   
 int Yposition_PS, Yposition_NS ;  

 logic [3:0] wanted_direction; // nothing - 0000 , down - 0001 , right - 0010 , up - 0100 , left - 1000
 logic collision_D; // one clk delay of input collision

 //---------
 
 always_ff @(posedge clk or negedge resetN)
	begin : fsm_sync_proc
		if (resetN == 1'b0) begin 
			SM_PS <= IDLE_ST; 
			Xspeed_PS <= 0; 
			Yspeed_PS <= 0; 
			Xposition_PS <= 0; 
			Yposition_PS <= 0; 
			curr_direction <= 4'b0;
			wanted_direction <= 4'b0;
			changeDirection <= 1'b0;
			collision_D <= 1'b0;
		end 	
		else begin 
			// defaults
			SM_PS <= SM_NS;
			Xspeed_PS <= Xspeed_NS;
			Yspeed_PS <= Yspeed_NS;
			Xposition_PS <= Xposition_NS; 
			Yposition_PS <= Yposition_NS;
			changeDirection <= 1'b0;
			collision_D <= collision;
			if (object_respawn == 1'b1 || objectAlive == 1'b0 || playGame == 1'b0) begin // place object in initial state
				SM_PS <= IDLE_ST;
				curr_direction <= 4'b0;
			end
			else begin
				if (Yspeed_NS == 0 && Xspeed_NS == 0) 
					curr_direction <= 4'b0; // no movement
				else if (Yspeed_NS > 0) 
					curr_direction <= 4'b0001; // down
				else if (Yspeed_NS < 0) 
					curr_direction <= 4'b0100; // up
				else if (Xspeed_NS > 0) 
					curr_direction <= 4'b0010; // right
				else if (Xspeed_NS < 0) 
					curr_direction <= 4'b1000; // left
				
				if (move_down)
					wanted_direction <= 4'b0001;
				if (move_left)
					wanted_direction <= 4'b1000;
				if (move_right)
					wanted_direction <= 4'b0010;
				if (move_up)
					wanted_direction <= 4'b0100;
				
				if (((collision && !collision_D) || wall_broke || (curr_direction == 4'b0)) 
						&& !changeDirection) begin // work on wanted direction based on signals mentioned
					changeDirection <= 1'b1;
					if (changeDirectionFlag && startOfFrame) begin // monster - try to change direciton
						if (wanted_direction == 4'b1000)
							wanted_direction <= 4'b0001;
						else
							wanted_direction <= wanted_direction << 1;
					end
					else if (!changeDirectionFlag) // pacman - stop movement
						wanted_direction <= 4'b0;
				end
			end
		end 
	end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		SM_NS = SM_PS;
		Xspeed_NS = Xspeed_PS;
		Yspeed_NS = Yspeed_PS; 
		Xposition_NS = Xposition_PS;
		Yposition_NS = Yposition_PS;
	 	

	case(SM_PS)
//------------
		IDLE_ST: begin // initial state
//------------
		Xspeed_NS = 0; 
		Yspeed_NS = 0; 
		Xposition_NS = INITIAL_X * FIXED_POINT_MULTIPLIER;
		Yposition_NS = INITIAL_Y * FIXED_POINT_MULTIPLIER; 
		
		if (playGame && startOfFrame && objectAlive)
			SM_NS = MOVE_ST;
 	
	end
	
//------------
		MOVE_ST:  begin  // moving no colision 
//------------
			
			if (wanted_direction != curr_direction) begin // change movment only if wanted direction is different then current direction
				if (wanted_direction == 4'b0001 || wanted_direction == 4'b0100) begin // wanted change in Y axis
					if (topLeftX[4:0] == 5'b0) begin // placement in X axis is divisible by 32
						if (wanted_direction == 4'b0001) // change direction to down
							Yspeed_NS = SPEED;
						else // change direction to up
							Yspeed_NS = -SPEED;
						Xspeed_NS = 0;
					end
				end
				else if (wanted_direction == 4'b0010 || wanted_direction == 4'b1000) begin // wanted change in X axis
					if (topLeftY[4:0] <= 5'b0) begin // placement in Y axis is divisible by 32
						if (wanted_direction == 4'b0010) // change direction to right
							Xspeed_NS = SPEED;
						else // change direction to left
							Xspeed_NS = -SPEED;
						Yspeed_NS = 0;
					end
				end
			end
			
			SM_NS = COLLISION_HANDLE_ST;
			if (startOfFrame) 
						SM_NS = POSITION_CHANGE_ST ; 
		end 
	
//--------------------
		COLLISION_HANDLE_ST: begin  // change speed already done once, now handle collision
//--------------------
			if (collision || wall_broke) begin  // any colisin was detected
				// return to position divisable by 32
				if (topLeftX[4:0] >= 5'b11100) // X axis ceiling
					Xposition_NS = (Xposition_PS[31:11] + 1'b1) << 11;
				else if (topLeftX[4:0] <= 5'b00100) // X axis floor
					Xposition_NS = Xposition_PS[31:11] << 11;
				if (topLeftY[4:0] >= 5'b11100) // Y axis ceiling
					Yposition_NS = (Yposition_PS[31:11] + 1'b1) << 11;
				else if (topLeftY[4:0] <= 5'b00100) // Y axis floor
					Yposition_NS = Yposition_PS[31:11] << 11;
					
				if (HitEdgeCode [2] == 1)  // hit top border of wall  
					if (Yspeed_PS < 0)   // while moving up
						Yspeed_NS = 0;
					
				if (HitEdgeCode [0] == 1)	// hit bottom border of wall 
					if (Yspeed_PS > 0)	// while moving down
						Yspeed_NS = 0;
					
				if (HitEdgeCode [3] == 1)  // hit left border of wall 
					if (Xspeed_PS < 0)   // while moving left
						Xspeed_NS = 0;
					
				if (HitEdgeCode [1] == 1)  // hit right border of wall  
					if (Xspeed_PS > 0)   // while moving right
						Xspeed_NS = 0;  
					
				SM_NS = COLLISION_HANDLE_ST; // return to state until next frame
			end
			
			if (startOfFrame) 
				SM_NS = POSITION_CHANGE_ST; 
		end 

//------------------------
 		POSITION_CHANGE_ST : begin  // position interpolate 
//------------------------
	
			Xposition_NS = Xposition_PS + Xspeed_PS;
			Yposition_NS = Yposition_PS + Yspeed_PS;
			
			SM_NS = POSITION_LIMITS_ST ; 
		end
		
		
//------------------------
		POSITION_LIMITS_ST : begin  // check if still inside the frame 
//------------------------
		
		
				 if (Xposition_PS <= x_FRAME_LEFT ) 
						begin  
							Xposition_NS = x_FRAME_LEFT; 
							if (Xspeed_PS < 0 ) // moving to the left 
									Xspeed_NS = 0;
						end ; 
	
				 if (Xposition_PS >= x_FRAME_RIGHT) 
						begin  
							Xposition_NS = x_FRAME_RIGHT; 
							if (Xspeed_PS > 0 ) // moving to the right 
									Xspeed_NS = 0;
						end ; 
							
				if (Yposition_PS <= y_FRAME_TOP ) 
						begin  
							Yposition_NS = y_FRAME_TOP; 
							if (Yspeed_PS < 0 ) // moving to the top 
									Yspeed_NS = 0;
						end ; 
	
				 if (Yposition_PS >= y_FRAME_BOTTOM) 
						begin  
							Yposition_NS = y_FRAME_BOTTOM; 
							if (Yspeed_PS > 0 ) // moving to the bottom 
									Yspeed_NS = 0;
						end ;

			SM_NS = MOVE_ST;
			
		end
		
endcase  // case 
end		
//return from FIXED point  trunc back to prame size parameters

assign 	topLeftX = Xposition_PS / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = Yposition_PS / FIXED_POINT_MULTIPLIER ;     

	

endmodule	
//---------------
 
