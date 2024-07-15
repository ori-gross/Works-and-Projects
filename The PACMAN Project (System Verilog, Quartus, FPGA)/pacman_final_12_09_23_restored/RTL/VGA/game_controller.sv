module	game_controller(	 
					input		logic	clk,
					input		logic	resetN,
					input		logic startInit, // signal to start initializing the game
					input		logic initFinished, // signal that initialization is finished
					input		logic win, // game won
					input		logic lose, // game lost
					
					output	logic pressToStart, // signal inidicating we wait to start the game
					output	logic initGame, // up during the initialization of the game
					output	logic playGame, // up during the game is playable 
					output	logic gameWon, // up during win state
					output	logic gameLost, // up during lose state
					output	logic resetInfo, // reset info in case the game lost
					output	logic nextLevel // update info in case the game won
);


enum  logic [2:0] {IDLE_ST, // wait for signal to start state
						INITIALIZATION_ST, // initialize the game board 
						PLAY_ST, // player plays the game 
						LOSE_ST, // player loses
						RESET_INFO_ST, // reset HP and score
						WIN_ST,   // player wins
						NEXT_LEVEL_ST // update info after win
					}  GAME_PS, GAME_NS ;




 //---------
 
 always_ff @(posedge clk or negedge resetN)
	begin : fsm_sync_proc
		if (resetN == 1'b0) begin 
			GAME_PS <= IDLE_ST;
			pressToStart <= 1'b0;
			initGame <= 1'b0;
			playGame <= 1'b0;
			gameLost <= 1'b0;
			gameWon <= 1'b0;
			resetInfo <= 1'b0;
			nextLevel <= 1'b0;
		end 	
		else begin 
			GAME_PS <= GAME_NS;
			pressToStart <= 1'b0;
			initGame <= 1'b0;
			playGame <= 1'b0;
			gameLost <= 1'b0;
			gameWon <= 1'b0;
			resetInfo <= 1'b0;
			nextLevel <= 1'b0;
			// update outputs according to states
			if (GAME_PS == IDLE_ST)
				pressToStart <= 1'b1;
			else if (GAME_PS == INITIALIZATION_ST)
				initGame <= 1'b1;
			else if (GAME_PS == PLAY_ST)
				playGame <= 1'b1;
			else if (GAME_PS == LOSE_ST)
				gameLost <= 1'b1;
			else if (GAME_PS == RESET_INFO_ST) begin
				gameLost <= 1'b1;
				resetInfo <= 1'b1;
			end
			else if (GAME_PS == WIN_ST)
				gameWon <= 1'b1;
			else if (GAME_PS == NEXT_LEVEL_ST) begin
				gameWon <= 1'b1;
				nextLevel <= 1'b1;
			end
		end 
	end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		 GAME_NS = GAME_PS;

	case(GAME_PS)
//------------
		IDLE_ST: begin // wait for player to start the game
//------------

			if (startInit)
				GAME_NS = INITIALIZATION_ST;
		end
	
//------------
		INITIALIZATION_ST:  begin // initialize the game board
//------------

			if (initFinished)
				GAME_NS = PLAY_ST;
		end 
	
//--------------------
		PLAY_ST: begin  // allow the player to play
//--------------------

			if (win)
				GAME_NS = WIN_ST;
			else if (lose)
				GAME_NS = LOSE_ST;
		end 

//------------------------
 		LOSE_ST : begin  // game lost
//------------------------
	
			if (startInit)
				GAME_NS = RESET_INFO_ST;
		end

//------------------------
 		RESET_INFO_ST : begin  // reset info in preparation for next game after losing
//------------------------
	
			GAME_NS = INITIALIZATION_ST;
		end

//------------------------
		WIN_ST : begin  // game won
//------------------------

			if (startInit)
				GAME_NS = NEXT_LEVEL_ST;
		end
		
//------------------------
		NEXT_LEVEL_ST : begin  // update info in preparation for next game after winning
//------------------------

			GAME_NS = INITIALIZATION_ST;
		end
		
	endcase  // case 
end
	

endmodule 