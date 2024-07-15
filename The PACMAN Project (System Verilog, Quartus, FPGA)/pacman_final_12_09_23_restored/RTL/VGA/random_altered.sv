// (c) Technion IIT, Department of Electrical Engineering 2021 
module random_altered	
 ( 
	input	logic  clk,
	input	logic  resetN, 
	input	logic	 rise, // signal to output new dout
	input logic  [3:0] keyPad, // number of key pressed
	input logic startOfFrame,
	output logic unsigned [3:0] dout	
  ) ;

// Generating a random number by latching a fast counter with the rising edge of an input ( e.g. key pressed )
  

logic [1:0] MIN_VAL = 0;  //set the min and max values 
logic [1:0] MAX_VAL = 3;

logic unsigned  [1:0] counter;
logic rise_d; // clk delay of rise
logic [3:0] keyPadMem; // last key pressed
logic [3:0] frameCounter;
	
	
always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			dout <= 4'h0;
			counter <= MIN_VAL;
			rise_d <= 1'b0;
			frameCounter <= 4'h0;
		end
		
		else begin
			counter <= counter + 1'b1;
			keyPadMem <= keyPad;
			if (startOfFrame)
				frameCounter <= frameCounter + 1'b1;
			if (keyPadMem != keyPad) // enter only if there was a new key pressed
				counter <= counter ^ keyPad[2:1];
			if ( counter >= MAX_VAL ) // the +1 is done on the next clock 
				counter <=  MIN_VAL ; // return to min value
			rise_d <= rise;
			if (rise && !rise_d) begin // rising edge 
				if (counter == 2'b00) // down
					dout <= 4'b0001;
				if (counter == 2'b01) // left
					dout <= 4'b1000;
				if (counter == 2'b10) // right
					dout <= 4'b0010;
				if (counter == 2'b11) // up
					dout <= 4'b0100;
			end
			if (frameCounter == 4'hf) begin // zero the output every 15 frames
				frameCounter <= 4'h0;
				dout <= 4'b0000;
			end
		end
	end
 
endmodule

