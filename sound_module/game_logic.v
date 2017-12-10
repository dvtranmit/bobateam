`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:00:40 12/04/2017 
// Design Name: 
// Module Name:    game_logic 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//																									 //
//										DIVIDER MODULE										 	 //
//																									 //
//////////////////////////////////////////////////////////////////////////////

module divider (	input clk, reset,
						output one_hz_enable );

// Implemented similarly to debounce
parameter DELAY = 32'd27000000;
   
reg [31:0] counter = 32'd0;
reg enable = 1'b0;

always @(posedge clk) begin
    if (reset) begin                  		 // divider reset
        counter <= 32'd0;
        enable <= 1'b0;
    end else if (enable) begin              // enable pulse off
        counter <= counter + 1;
        enable <= 1'b0;
    end else if (counter == DELAY) begin    // enable pulse on
        counter <= 32'd0;
        enable <= 1'b1;
    end else                                 // increment counter
        counter <= counter + 1;
end

assign one_hz_enable = enable;
endmodule

//////////////////////////////////////////////////////////////////////////////
//																									 //
//										TIMER MODULE											 //
//																									 //
//////////////////////////////////////////////////////////////////////////////

module timer( 	input clk, start_timer, one_hz_enable,
					input [3:0] timer_value,
					output expired,
					output [3:0] displayed_counter );

// States
parameter [1:0] IDLE 		= 2'd0;		// Await start_timer
parameter [1:0] COUNTING 	= 2'd1;		// Countdown from timer_value (until expired)
parameter [1:0] EXPIRED 	= 2'd2;		// Expired pulse lasts one clock cycle

// State machine variables
reg [3:0] state = IDLE;
reg [3:0] counter = 4'b0;

always @(posedge clk) begin
    if (state == IDLE) begin                                     
        state <= (start_timer) ? COUNTING : IDLE;
        counter <= (start_timer) ? timer_value : 4'b0;
    end else if (state == COUNTING) begin
        state <= (counter == 0) ? EXPIRED : COUNTING;
        counter <= (one_hz_enable) ? counter - 1: 
							(start_timer) ? timer_value : counter;
    end else if (state == EXPIRED) begin
        state <= IDLE;
        counter <= 4'b0;
    end
end

assign expired = (state == EXPIRED);
assign displayed_counter = counter;
endmodule

//////////////////////////////////////////////////////////////////////////////
//																									 //
//									  SYNCHRONIZE MODULE										 //
//																									 //
//////////////////////////////////////////////////////////////////////////////

module synchronize #(parameter NSYNC = 2)  // number of sync flops.  must be >= 2
                   (input clk,in,
                    output reg out);

  reg [NSYNC-2:0] sync;

  always @ (posedge clk)
  begin
    {out,sync} <= {sync[NSYNC-2:0],in};
  end
endmodule

//////////////////////////////////////////////////////////////////////////////
//																									 //
//										DEBOUNCE MODULE										 //
//																									 //
//////////////////////////////////////////////////////////////////////////////

module debounce #(parameter DELAY=270000)   // .01 sec with a 27Mhz clock
	        (input clk, reset, noisy,
	         output clean);

   reg [19:0] count;
   reg new;
   wire synced;
   synchronize sync1(.clk(clk), .in(noisy), .out(synced));

	reg temp_clean = 1'b0;
   always @(posedge clk) begin
		if (reset) begin
			count <= 0;
			new <= synced;
			temp_clean <= synced;
		end else if (synced != new) begin
			new <= synced;
			count <= 0;
		end else if (count == DELAY)
			temp_clean <= new;
		else
			count <= count+1;
	end
	
	assign clean = ~temp_clean;
endmodule

//////////////////////////////////////////////////////////////////////////////
//																									 //
//									STATE CHANGE PULSE MODULE								 //
//																									 //
//////////////////////////////////////////////////////////////////////////////
module state_change_indicator(	input clk, reset, changing_thing,
											output reg state_change_pulse);

parameter [19:0] DELAY = 2700000; // 0.1 seconds for 27MHz clock.

reg current_state = 1'b0;
reg [19:0] counter;
always @(posedge clk) begin
	if (reset) begin
		counter <= 0;
	end else if (state_change_pulse) begin
		state_change_pulse <= 1'b0;
	end else if (changing_thing == current_state) begin
		counter <= 0;
	end else begin
		if (counter == DELAY) begin
			state_change_pulse <= 1'b1;
			current_state <= changing_thing;
			counter <= 0;
		end else
			counter <= counter + 1;
	end
end
		
endmodule

//////////////////////////////////////////////////////////////////////////////
//																									 //
//							  RANDOM NUMBER GENERATOR MODULE								 //
//																									 //
//////////////////////////////////////////////////////////////////////////////
module random(	input clk, reset,
				output [2:0] r );

reg [3:0] temp_r = 4'b0001;

always @ (posedge clk) begin
	if (reset)
		temp_r <= 4'b0001;
	else
		temp_r <= {temp_r[2:0], temp_r[3]^temp_r[2]};
end

assign r = temp_r[2:0];
endmodule

//////////////////////////////////////////////////////////////////////////////
//																									 //
//								  INTERPRET INPUT MODULE									 //
//																									 //
//////////////////////////////////////////////////////////////////////////////

module interpret_input(	input clk,
								input upleft, up, upright, 
								input left, right, 
								input downleft, down, downright,
								input reset,
								input [2:0] mole_location,
								output misstep,
								output whacked);


reg [7:0] location = 8'b0;

// Temporary variables for output
reg temp_whacked = 1'b0;
reg temp_misstep = 1'b0;
 
always@(posedge clk) begin
	if ({upleft, up, upright, left, right, downleft, down, downright} == location)
		temp_whacked <= 1'b1;
	else if ({upleft, up, upright, left, right, downleft, down, downright} !== 8'd0)
		temp_misstep <= 1'b1;
	else begin
		temp_whacked <= 1'b0;
		temp_misstep <= 1'b0;
	end
end

// Convert location to one hot representation
always@(*) begin
	case(mole_location)
		3'd0: location = 8'b10000000;
		3'd1: location = 8'b01000000;
		3'd2: location = 8'b00100000;
		3'd3: location = 8'b00010000;
		3'd4: location = 8'b00001000;
		3'd5: location = 8'b00000100;
		3'd6: location = 8'b00000010;
		3'd7: location = 8'b00000001;
		default: location = 8'b0;
	endcase
end

assign misstep = temp_misstep;
assign whacked = temp_whacked;
endmodule

//////////////////////////////////////////////////////////////////////////////
//																									 //
//								    MOLE TIMING MODULE									 	 //
//																									 //
//////////////////////////////////////////////////////////////////////////////

module mole #(parameter MAX_ITEM = 8'd127, parameter INDEX_BITS = 8) 
				(	input clk, reset,
					input [22:0] music_address,
					input [3:0] game_state,
					input diy_playback_mode,
					input [INDEX_BITS-1:0] total_moles,
					input one_hz_enable,
					input [22:0] index_address,
					output request_mole,
					output reg [INDEX_BITS-1:0] lookup_index = 0);

/* Memory address popup pseudocode
	
	initialize array of popup times
	initialize array index variable
	always @ posedge clk
		check time against current array value
			increment index if match
		increment time
*/

//Modified States
parameter IDLE = 3'd0;
parameter CHECKING = 3'd1;
parameter MOLE = 3'd2;
parameter DIY_IDLE = 3'd3;
parameter DIY_CHECKING = 3'd4;
parameter DIY_WAIT_ADDRESS = 3'd5;
parameter DIY_LOAD_ADDRESS = 3'd6;

// State machine variables
reg [2:0] state = IDLE;
reg [2:0] next_state;

// Music tracker
reg [367:0] addresses = {23'h6CDE, 23'h8B00, 23'hE900, 23'h14900,
										 23'h17B00, 23'h1B100, 23'h21F00, 23'h28000,
										 23'h2E500, 23'h31A00, 23'h35900, 23'h39500,
										 23'h3DA00, 23'h41800, 23'h47800, 23'h4FD00};
reg [22:0] current_address;

always @(posedge clk) begin
	if (state == IDLE) begin
		if(diy_playback_mode)
			current_address <= index_address;
		else current_address <= 23'h6CDE;
		
		addresses[367:0] <= {23'h6CDE, 23'h8B00, 23'hE900, 23'h14900,
										 23'h17B00, 23'h1B100, 23'h21F00, 23'h28000,
										 23'h2E500, 23'h31A00, 23'h35900, 23'h39500,
										 23'h3DA00, 23'h41800, 23'h47800, 23'h4FD00};
	end else if (state == CHECKING) begin
		addresses <= (current_address == music_address) ? {addresses[344:0], addresses[367:345]} : addresses; 
		current_address <= (current_address == music_address) ? addresses[344:322] : current_address;
	end else if (state == DIY_IDLE) begin
		lookup_index <= 0;
	end else if (state == DIY_LOAD_ADDRESS) begin
		current_address <= index_address;
	end else if (state == DIY_CHECKING) begin
		lookup_index <= (current_address == music_address && lookup_index == total_moles-1) ? 4'd0:
								(current_address == music_address) ? lookup_index+1: lookup_index;
	end
	state <= next_state;
end

always @(*) begin
	if(reset || game_state == 4'd0 || game_state == 4'd11)
		next_state = (diy_playback_mode) ? DIY_IDLE : IDLE;
	else begin
		case(state)
			IDLE: next_state = CHECKING;
			CHECKING: next_state = (current_address == music_address) ? MOLE : CHECKING;
			MOLE: next_state = (diy_playback_mode) ? DIY_WAIT_ADDRESS : CHECKING;
			DIY_IDLE: next_state = DIY_WAIT_ADDRESS;
			DIY_WAIT_ADDRESS: next_state = DIY_LOAD_ADDRESS;
			DIY_LOAD_ADDRESS: next_state = DIY_CHECKING;
			DIY_CHECKING: next_state = (current_address == music_address) ? MOLE : DIY_CHECKING;
			default: next_state = IDLE;
		endcase
	end
end

assign request_mole = (state == MOLE);
endmodule


//////////////////////////////////////////////////////////////////////////////
//																									 //
//									GAME STATE FSM MODULE									 //
//																									 //
//////////////////////////////////////////////////////////////////////////////

module gameState(input clk,
						input misstep, whacked,
						input start,
						input reset,
						input request_mole,
						input expired,
						input diy_mode,
						input diy_playback_mode,
						input ready_to_use,
						input popup_done,
						input [2:0] random_mole_location,
						input [2:0] saved_mole_location,
						// Future input: record
						output start_timer,
						output [3:0] timer_value,
						output [3:0] display_state,
						output [2:0] mole_location,
						output [1:0] lives,
						output [7:0] score
						);
						
// States
parameter [3:0] IDLE 					= 4'd0;		// Check if user has pressed start
parameter [3:0] GAME_START_DELAY 	= 4'd1;		// Delay until user stands on center
parameter [3:0] GAME_ONGOING			= 4'd2;		// Check lives & Address from Music
parameter [3:0] REQUEST_MOLE			= 4'd3;		// Request a mole to be displayed (pulse)
parameter [3:0] MOLE_COUNTDOWN		= 4'd4;		// Mole displayed until stomped/expired 
parameter [3:0] MOLE_MISSED			= 4'd5;		// Lives counter decremented (pulse)
parameter [3:0] MOLE_WHACKED			= 4'd6;		// Score counter incremented (pulse)
// Deleted Safe Step Delay in favor of Mole Missed_Sound and Mole_Whacked Sound
parameter [3:0] GAME_OVER				= 4'd8;		// Display Game Over Screen
parameter [3:0] MOLE_MISSED_SOUND	= 4'd9;		// Extra time for sound
parameter [3:0] MOLE_WHACKED_SOUND	= 4'd10;		// Extra time for sound
// For DIY mode
parameter [3:0] DIY_DONE_RECORD		= 4'd11;    //Done recording and ready for use, but still in diy mode
parameter [3:0] RECORD_DIY_IN_PROGRESS = 4'd12;// Begin Recording Moles for DIY

// New Fancy Mole Display States
parameter [3:0] MOLE_ASCENDING				= 4'd13;
parameter [3:0] HAPPY_MOLE_DESCENDING		= 4'd14;
parameter [3:0] DEAD_MOLE_DESCENDING		= 4'd15;

// State machine variables
reg [3:0] state = 4'b0;
reg [3:0] next_state = 4'b0;

// Counters
reg [1:0] temp_lives = 2'd3;	// If zero --> Dead --> Game Over
reg [7:0] temp_score = 8'd0;

// Mole location
reg [2:0] current_mole_location;
reg [2:0] next_mole_location;
// Do a thing each relevant state
always @(posedge clk) begin
	if (state == IDLE) begin
		temp_lives <= 2'd3;
		temp_score <= 8'd0;
	end else if (state == MOLE_MISSED)
		temp_lives <= temp_lives - 1;
	else if (state == MOLE_WHACKED)
		temp_score <= temp_score + 1;
	current_mole_location <= next_mole_location;
	state <= next_state;
end

// State machine
always @(*) begin
	if (reset) begin
		next_state = IDLE;
	end else begin
		next_mole_location = (request_mole & diy_playback_mode) ? saved_mole_location :
									(request_mole) ? random_mole_location : next_mole_location;
		case(state)
			IDLE : next_state = (diy_mode) ? RECORD_DIY_IN_PROGRESS  : (start) ? GAME_START_DELAY : IDLE;
			GAME_START_DELAY: next_state = (expired) ? GAME_ONGOING : GAME_START_DELAY;
			GAME_ONGOING : next_state = (lives == 0) ? GAME_OVER : (request_mole) ? REQUEST_MOLE : GAME_ONGOING;
			REQUEST_MOLE : next_state = MOLE_ASCENDING;
			MOLE_COUNTDOWN : next_state = (expired || misstep) ? MOLE_MISSED : (whacked) ? MOLE_WHACKED : MOLE_COUNTDOWN;
			MOLE_MISSED : next_state = MOLE_MISSED_SOUND;
			MOLE_WHACKED : next_state = MOLE_WHACKED_SOUND;
			MOLE_MISSED_SOUND : next_state = (expired) ? HAPPY_MOLE_DESCENDING : MOLE_MISSED_SOUND;
			MOLE_WHACKED_SOUND : next_state = (expired) ? DEAD_MOLE_DESCENDING: MOLE_WHACKED_SOUND;
			GAME_OVER : next_state = (start) ? IDLE : GAME_OVER;//(expired) ? IDLE : GAME_OVER;
			RECORD_DIY_IN_PROGRESS: next_state = (!diy_mode) ? IDLE : (ready_to_use) ? DIY_DONE_RECORD : RECORD_DIY_IN_PROGRESS; 
			DIY_DONE_RECORD: next_state = (!diy_mode) ? IDLE : (diy_playback_mode & start) ? GAME_ONGOING : DIY_DONE_RECORD;
			MOLE_ASCENDING : next_state = (misstep) ? MOLE_MISSED : (whacked) ? MOLE_WHACKED : (popup_done) ? MOLE_COUNTDOWN : MOLE_ASCENDING;
			HAPPY_MOLE_DESCENDING : next_state = (popup_done) ? GAME_ONGOING : HAPPY_MOLE_DESCENDING;
			DEAD_MOLE_DESCENDING : next_state = (popup_done) ? GAME_ONGOING : DEAD_MOLE_DESCENDING;
			default : next_state = IDLE;
		endcase
	end
end

assign start_timer = (state !== next_state);
assign timer_value = 4'd2; 	// Must be less than mole pop up rate
assign display_state = state;
assign mole_location = current_mole_location;
assign lives = temp_lives;
assign score = temp_score;

endmodule