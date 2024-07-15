module	TilesManager	(
					input	logic	clk,
					input	logic	resetN,
					input logic gameInit, // up if game needs to initialize
					input logic collision_pacman_tile, // collision between pacman and tile
					input logic break_mode, // up if pacman in break mode
					input logic [1:0] random_map, // map choice
					
					input logic	[10:0] pixelX,
					input logic	[10:0] pixelY,
					input logic InsideRectangle,
					
					output logic finishedRand, // up after finishing to setup the map
					output logic [1:0] wallSelect, // current wall to draw
					output logic [4:0] removeHP, // HP removed on hit with wall with break_mode on
					output logic [7:0] BG_RGB,
					output logic tilesDrawReq,
					output logic wall_broke // pulse if a wall was broken
);  	

// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 16*16 and use only the top left 16*15 squares 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the  understanding

localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel 


logic [3:0] row = 4'h0;
logic [3:0] column = 4'h0;

logic collision_pacman_tile_D; // collision with one delay clk

logic [0:3] [0:15] [0:15] [1:0] MazeBitMapMask = {

{{2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h3, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h1, 2'h3, 2'h0, 2'h1, 2'h2, 2'h1, 2'h0, 2'h2, 2'h0, 2'h3, 2'h2, 2'h1, 2'h0, 2'h2, 2'h0},
 {2'h0, 2'h2, 2'h1, 2'h0, 2'h2, 2'h3, 2'h1, 2'h0, 2'h1, 2'h0, 2'h1, 2'h2, 2'h2, 2'h0, 2'h1, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h2, 2'h3, 2'h0, 2'h1, 2'h0, 2'h2, 2'h1, 2'h2, 2'h2, 2'h3, 2'h0, 2'h1, 2'h0, 2'h2, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0},
 {2'h1, 2'h1, 2'h2, 2'h0, 2'h3, 2'h2, 2'h1, 2'h0, 2'h1, 2'h0, 2'h1, 2'h2, 2'h3, 2'h1, 2'h0, 2'h2},
 {2'h2, 2'h2, 2'h3, 2'h0, 2'h3, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h0, 2'h2},
 {2'h3, 2'h3, 2'h1, 2'h0, 2'h2, 2'h0, 2'h2, 2'h1, 2'h0, 2'h2, 2'h2, 2'h0, 2'h1, 2'h0, 2'h1, 2'h3},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h1, 2'h0, 2'h0, 2'h1, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h3, 2'h3, 2'h1, 2'h0, 2'h3, 2'h2, 2'h2, 2'h0, 2'h1, 2'h3, 2'h0, 2'h1, 2'h0, 2'h3, 2'h2, 2'h2},
 {2'h2, 2'h2, 2'h3, 2'h0, 2'h2, 2'h1, 2'h3, 2'h0, 2'h0, 2'h2, 2'h2, 2'h3, 2'h0, 2'h2, 2'h1, 2'h3},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h3, 2'h0, 2'h3, 2'h2, 2'h0, 2'h1, 2'h1, 2'h2, 2'h0, 2'h3, 2'h0, 2'h3},
 {2'h0, 2'h2, 2'h1, 2'h0, 2'h1, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h1, 2'h1, 2'h0, 2'h1, 2'h0, 2'h0, 2'h0, 2'h1, 2'h0, 2'h2, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0}},
 
{{2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h1, 2'h3, 2'h0, 2'h3, 2'h2, 2'h2, 2'h0, 2'h2, 2'h2, 2'h3, 2'h2, 2'h1, 2'h0, 2'h2, 2'h0},
 {2'h0, 2'h2, 2'h1, 2'h0, 2'h2, 2'h3, 2'h3, 2'h0, 2'h2, 2'h3, 2'h1, 2'h2, 2'h2, 2'h0, 2'h1, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h2, 2'h3, 2'h0, 2'h1, 2'h0, 2'h2, 2'h0, 2'h2, 2'h2, 2'h3, 2'h0, 2'h1, 2'h0, 2'h2, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h1, 2'h0},
 {2'h1, 2'h1, 2'h2, 2'h0, 2'h3, 2'h2, 2'h1, 2'h0, 2'h1, 2'h0, 2'h1, 2'h2, 2'h3, 2'h0, 2'h2, 2'h0},
 {2'h2, 2'h2, 2'h3, 2'h0, 2'h3, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h1, 2'h0},
 {2'h3, 2'h3, 2'h1, 2'h0, 2'h2, 2'h0, 2'h2, 2'h0, 2'h1, 2'h2, 2'h2, 2'h0, 2'h1, 2'h0, 2'h1, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h1, 2'h0, 2'h3, 2'h1, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h3, 2'h3, 2'h1, 2'h0, 2'h3, 2'h2, 2'h2, 2'h0, 2'h1, 2'h3, 2'h0, 2'h1, 2'h0, 2'h3, 2'h1, 2'h0},
 {2'h2, 2'h2, 2'h3, 2'h0, 2'h2, 2'h1, 2'h3, 2'h0, 2'h2, 2'h2, 2'h2, 2'h3, 2'h0, 2'h2, 2'h1, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h2, 2'h1, 2'h0, 2'h3, 2'h2, 2'h1, 2'h0, 2'h2, 2'h3, 2'h1, 2'h2, 2'h0, 2'h3, 2'h1, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0}},
 
{{2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h1, 2'h1, 2'h1, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h3, 2'h2, 2'h0, 2'h1, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h2, 2'h3, 2'h0},
 {2'h0, 2'h2, 2'h3, 2'h0, 2'h3, 2'h2, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1, 2'h2, 2'h0, 2'h3, 2'h2, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h2, 2'h2, 2'h3, 2'h0, 2'h1, 2'h1, 2'h2, 2'h1, 2'h0, 2'h2, 2'h3, 2'h0, 2'h1, 2'h0, 2'h2, 2'h3},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h2, 2'h1, 2'h3, 2'h0, 2'h3, 2'h2, 2'h1, 2'h1, 2'h0, 2'h1, 2'h0, 2'h1, 2'h3, 2'h1, 2'h0, 2'h2},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h2, 2'h2, 2'h0, 2'h0},
 {2'h2, 2'h3, 2'h1, 2'h0, 2'h2, 2'h0, 2'h2, 2'h1, 2'h0, 2'h1, 2'h0, 2'h1, 2'h3, 2'h1, 2'h0, 2'h2},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h1, 2'h0, 2'h1, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h3, 2'h1, 2'h2, 2'h0, 2'h3, 2'h2, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0, 2'h1, 2'h0, 2'h3, 2'h2, 2'h2},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h1, 2'h3, 2'h1, 2'h0, 2'h1, 2'h2, 2'h3, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h2, 2'h3, 2'h0, 2'h0, 2'h0, 2'h3, 2'h1, 2'h0, 2'h1, 2'h1, 2'h2, 2'h0, 2'h3, 2'h2, 2'h0},
 {2'h0, 2'h3, 2'h2, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h3, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h0, 2'h3, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0}},
 
{{2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h2, 2'h1, 2'h3, 2'h0, 2'h1, 2'h2, 2'h1, 2'h0, 2'h2, 2'h0, 2'h2, 2'h2, 2'h2, 2'h0, 2'h2, 2'h0},
 {2'h2, 2'h0, 2'h1, 2'h0, 2'h2, 2'h3, 2'h1, 2'h0, 2'h2, 2'h0, 2'h2, 2'h2, 2'h2, 2'h0, 2'h1, 2'h0},
 {2'h0, 2'h0, 2'h1, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h2, 2'h3, 2'h0, 2'h1, 2'h0, 2'h2, 2'h1, 2'h0, 2'h2, 2'h3, 2'h0, 2'h1, 2'h0, 2'h2, 2'h1},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0},
 {2'h1, 2'h1, 2'h2, 2'h0, 2'h3, 2'h2, 2'h1, 2'h1, 2'h3, 2'h1, 2'h1, 2'h3, 2'h1, 2'h1, 2'h2, 2'h0},
 {2'h1, 2'h1, 2'h2, 2'h0, 2'h3, 2'h0, 2'h0, 2'h3, 2'h0, 2'h3, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h1, 2'h1, 2'h2, 2'h0, 2'h2, 2'h0, 2'h2, 2'h1, 2'h3, 2'h1, 2'h1, 2'h3, 2'h1, 2'h1, 2'h2, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h1, 2'h2, 2'h0, 2'h1, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h3, 2'h1, 2'h0, 2'h3, 2'h2, 2'h2, 2'h0, 2'h0, 2'h3, 2'h0, 2'h1, 2'h0, 2'h1, 2'h1, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h2, 2'h1, 2'h3, 2'h2, 2'h0, 2'h2, 2'h0, 2'h3, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h3, 2'h2, 2'h0, 2'h3, 2'h0, 2'h0, 2'h0, 2'h0, 2'h1, 2'h0, 2'h2, 2'h0, 2'h1, 2'h3, 2'h2},
 {2'h0, 2'h2, 2'h3, 2'h0, 2'h3, 2'h2, 2'h1, 2'h1, 2'h0, 2'h1, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h3, 2'h3, 2'h0, 2'h2, 2'h0, 2'h0, 2'h0, 2'h2, 2'h1, 2'h0},
 {2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0}}
 
};
 
logic [0:15] [0:15] [1:0]  MazeBitMapMaskClone; // holds the playable map


logic [0:2] [0:31] [0:31] [7:0]  object_colors  = {
{	// brick wall
	{8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h60,8'hac,8'hac,8'hac,8'hac,8'hac,8'hac,8'h60,8'hac,8'hac,8'hd1,8'h60,8'hac,8'hac,8'hac,8'hac,8'hac,8'h84,8'h80,8'h60,8'h84,8'hac,8'hac,8'hac,8'hac},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h20,8'h80,8'ha4,8'ha4,8'ha4,8'ha4,8'hcc,8'h60,8'h80,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h20,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'h80,8'h80,8'h80,8'h60,8'h80,8'h60,8'h80,8'h60,8'h80,8'ha4,8'ha4,8'h80,8'h80,8'ha4,8'h60,8'ha4,8'h80,8'h60,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'h60,8'ha4,8'hac,8'ha4,8'h60},
	{8'ha4,8'ha4,8'ha4,8'h84,8'h60,8'ha4,8'h60,8'ha4,8'h84,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'h84,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h84},
	{8'ha4,8'ha4,8'ha4,8'hcc,8'hac,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'hcc,8'ha4,8'ha4,8'hcc,8'ha4,8'h60,8'hac,8'ha4,8'hcc,8'ha4,8'ha4,8'ha4,8'h20,8'ha4},
	{8'ha4,8'ha4,8'ha4,8'h80,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h20,8'ha4},
	{8'ha4,8'ha4,8'ha4,8'h60,8'h84,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h80,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h80,8'ha4,8'ha4,8'ha4,8'h60,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h20,8'ha4},
	{8'h84,8'h84,8'h80,8'h60,8'h60,8'h84,8'h84,8'h60,8'h84,8'h84,8'h20,8'h60,8'h60,8'h60,8'h84,8'h84,8'h84,8'h80,8'h84,8'h60,8'h80,8'ha4,8'h84,8'h60,8'h60,8'h84,8'h84,8'h80,8'h84,8'h60,8'h60,8'h84},
	{8'hcc,8'hac,8'hcc,8'hac,8'hcc,8'hd0,8'h84,8'hcc,8'ha4,8'ha4,8'hcc,8'ha4,8'hcc,8'hcc,8'hcc,8'h60,8'h80,8'hcc,8'hcc,8'hcc,8'hcc,8'hac,8'hac,8'hcc,8'hcc,8'ha4,8'h60,8'ha4,8'hcc,8'hcc,8'hcc,8'hcc},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hd1,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hd1,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h84,8'hd1,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'h84,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h84,8'ha4,8'h60,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h80,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h80,8'ha4,8'h84,8'h60,8'h60,8'h80,8'ha4,8'h80,8'h84,8'h80,8'ha4,8'hcc,8'h60,8'h84,8'h84,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h20,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h60,8'h20,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h60,8'h84,8'h60},
	{8'ha4,8'hcc,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'hac,8'hcc,8'hac,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'ha4},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'h60,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'ha4},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h80,8'h80,8'h60,8'ha4,8'h84,8'h80,8'ha4,8'ha4,8'ha4,8'ha4,8'h84,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'had,8'had,8'had,8'had,8'had,8'had,8'had,8'h84,8'h60,8'h60,8'h60,8'h60,8'h80,8'had,8'had,8'h84,8'h80,8'h60,8'had,8'had,8'had,8'had,8'had,8'had,8'h60,8'had,8'had,8'had,8'h80,8'h60,8'h60,8'had},
	{8'hcc,8'hcc,8'h60,8'hcc,8'ha4,8'h20,8'hac,8'hcc,8'hcc,8'hcc,8'hcc,8'h80,8'h20,8'hac,8'hac,8'hac,8'hac,8'hcc,8'h20,8'h20,8'hcc,8'hac,8'ha4,8'ha4,8'hac,8'hcc,8'h20,8'h60,8'hcc,8'hac,8'hac,8'hcc},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hcc,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'ha4,8'h60,8'ha4,8'ha4,8'ha4,8'ha4,8'h80,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h20,8'h60,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h84,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'had,8'had,8'had,8'had,8'h84,8'h60,8'had,8'had,8'hd0,8'h60,8'had,8'h84,8'h60,8'h20,8'h80,8'had,8'ha4,8'h60,8'h20,8'h60,8'ha4,8'had,8'had,8'had,8'h84,8'h20,8'h60,8'h60,8'h84,8'had,8'h80,8'ha4},
	{8'hcc,8'hcd,8'h60,8'h00,8'hd0,8'hcc,8'h20,8'h00,8'hcc,8'hcc,8'hcc,8'hac,8'hcc,8'hcc,8'h20,8'h84,8'hcc,8'hac,8'hcc,8'h80,8'h60,8'h60,8'h20,8'h60,8'h60,8'h60,8'h60,8'hcc,8'hcc,8'hcc,8'hcc,8'h60},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'h20,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h20,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hcc,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h20,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h20,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hcc,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60},
	{8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'h60,8'h84,8'ha4,8'ha4,8'ha4,8'ha4,8'h84,8'ha4,8'h20,8'hcc,8'ha4,8'ha4,8'ha4,8'ha4,8'h80,8'h60,8'hcc,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60},
	{8'h00,8'h20,8'h60,8'h00,8'h00,8'h00,8'h00,8'h20,8'h20,8'h20,8'h20,8'h60,8'h60,8'h20,8'h20,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h60,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'ha4,8'ha4,8'hd0,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h20,8'h20,8'hcc,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'ha4,8'ha4,8'hd0,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h20,8'ha4,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'ha4,8'hcd,8'hd0,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h84,8'ha4,8'ha4,8'h84,8'h60,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h60,8'hac,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'h80,8'h60,8'h60,8'hcc,8'h80,8'hcc,8'hcc,8'hcc,8'h60,8'h20,8'h80,8'h60,8'h60,8'hcc,8'ha4,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'h80,8'h60,8'h60,8'h60,8'h84,8'h80,8'h80,8'h60,8'hcc,8'hcc,8'hcc,8'h80}
},
{	// glass wall
	{8'hbf,8'hbf,8'hdf,8'hdf,8'hbf,8'hbf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hbf,8'hbf},
	{8'hbf,8'hbf,8'hdf,8'hdf,8'hbf,8'hbf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hbf,8'hbf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hbf,8'hbf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hbf,8'hbf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hbf,8'hbf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hbf,8'hbf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdf,8'hdf,8'h00,8'h00,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf},
	{8'hbf,8'hbf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hbf,8'hbf,8'hdf,8'hdf,8'hdf,8'hdf,8'hbf,8'hbf},
	{8'hbf,8'hbf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hdf,8'hbf,8'hbf,8'hdf,8'hdf,8'hdf,8'hdf,8'hbf,8'hbf}
},
{	// wood wall
	{8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h84},
	{8'hf4,8'hf0,8'hf0,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h84},
	{8'hf4,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hcc,8'hcc,8'hec,8'hec,8'hf0,8'hf0,8'h8c,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h84},
	{8'hf4,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hec,8'hf0,8'hf0,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h84},
	{8'hf4,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'h84},
	{8'hf4,8'hcc,8'hcc,8'hec,8'hec,8'hcc,8'hec,8'hec,8'hcc,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hf0,8'hf0,8'hec,8'hec,8'h84},
	{8'hf4,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hcc,8'hcc,8'hec,8'hcc,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h84},
	{8'hf4,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hf0,8'hf0,8'hf0,8'hf0,8'h84},
	{8'hf4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'h8c,8'hf0,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'h84},
	{8'hf4,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hd0,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'h84},
	{8'hf4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h84},
	{8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h84},
	{8'hf4,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h8c,8'hf0,8'hf0,8'h84},
	{8'hf4,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hec,8'h84},
	{8'hf4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hf0,8'hf0,8'hf0,8'hf0,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'h84},
	{8'hf4,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hf0,8'hf0,8'hf0,8'hec,8'hec,8'hcc,8'h84},
	{8'hf4,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hf0,8'hf0,8'hf0,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'h84},
	{8'hf4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hcc,8'hcc,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'h84},
	{8'hf4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'h84},
	{8'hf4,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'h8c,8'hf0,8'hcc,8'h84},
	{8'hf4,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hd0,8'hcc,8'hcc,8'h84},
	{8'hf4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h84},
	{8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'hf4,8'h84},
	{8'hf4,8'hf0,8'hf0,8'h8c,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h84},
	{8'hf4,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'hec,8'hec,8'hec,8'hec,8'hf0,8'hf0,8'hf0,8'hf0,8'hf0,8'h84},
	{8'hf4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'h84},
	{8'hf4,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'h84},
	{8'hf4,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hf0,8'hf0,8'hf0,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hcc,8'hcc,8'hcc,8'hec,8'hcc,8'hcc,8'h84},
	{8'hf4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hcc,8'hec,8'hec,8'h84},
	{8'hf4,8'hcc,8'hcc,8'h8c,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hec,8'hec,8'hec,8'h84},
	{8'hf4,8'hcc,8'hcc,8'hd0,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'hcc,8'h84},
	{8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84}
}};



// randomizer portion
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin // enters also if gameFinished is up
		row <= 4'h0;
		column <= 4'h0;
		finishedRand <= 1'b0;
		MazeBitMapMaskClone <= 512'b0;
		collision_pacman_tile_D <= 1'b0;
		BG_RGB <= TRANSPARENT_ENCODING;
		removeHP <= 5'd0;
		wall_broke <= 1'b0;

	end
	else begin
		removeHP <= 5'd0;
		wall_broke <= 1'b0;
		BG_RGB <= TRANSPARENT_ENCODING ; // default
		
		if (gameInit && !finishedRand) begin // initialize map
			MazeBitMapMaskClone[row][column] <= MazeBitMapMask[random_map][row][column];
			
			if (column == 4'hF) begin // go to next row
				row <= row + 1'b1;
				column <= 4'h0;
			end
			else
				column <= column + 1'b1; // go to next column
			if	(row == 4'hF) // finished randomizing all tiles
				finishedRand <= 1'b1;
		end
		
		collision_pacman_tile_D <= collision_pacman_tile;
		if (collision_pacman_tile && !collision_pacman_tile_D && break_mode && 
			 MazeBitMapMaskClone[pixelY[8:5]][(pixelX[8:0] - 2'h2) >> 5]) begin // enter if needed to break a wall
			
			// break right wall in steps
			if (MazeBitMapMaskClone[pixelY[8:5]][(pixelX[8:0] - 2'h2) >> 5] == 2'h1)
				MazeBitMapMaskClone[pixelY[8:5]][(pixelX[8:0] - 2'h2) >> 5] <= 2'h3;
			else if (MazeBitMapMaskClone[pixelY[8:5]][(pixelX[8:0] - 2'h2) >> 5] == 2'h3)
				MazeBitMapMaskClone[pixelY[8:5]][(pixelX[8:0] - 2'h2) >> 5] <= 2'h2;
			else if (MazeBitMapMaskClone[pixelY[8:5]][(pixelX[8:0] - 2'h2) >> 5] == 2'h2) begin
				MazeBitMapMaskClone[pixelY[8:5]][(pixelX[8:0] - 2'h2) >> 5] <= 2'h0;
			end
			wall_broke <= 1'b1;
			removeHP <= 5'd5;
		end
		if (InsideRectangle && finishedRand && wallSelect)
			BG_RGB <= object_colors[wallSelect- 1][pixelY[4:0]][pixelX[4:0]];
	end	
end

assign wallSelect = (finishedRand) ? MazeBitMapMaskClone[pixelY[8:5]][pixelX[8:5]] : 2'h0;
assign tilesDrawReq = (BG_RGB != TRANSPARENT_ENCODING) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap

endmodule 