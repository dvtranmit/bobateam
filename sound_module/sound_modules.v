`timescale 1ns / 1ps


//to get mole addresses and locations in a one mole diy mode
module mole_adressss_locations #(parameter MAX_ITEM = 4'd5, parameter INDEX_BITS = 4'd4) (
	input wire clock,
	input wire reset,
	input wire [7:0]switch,
	input wire upleft,
	input wire up,
	input wire upright,
	input wire left,
	input wire right,
	input wire downleft,
	input wire down,
	input wire downright,
	input wire enter,
	input wire diy_mode,
	input wire one_hz_enable,
//	input wire disp_data_in,			 // LED display signal
//   output wire disp_blank,           // LED display signal
//   output wire disp_clock,           // LED display signal
//   output wire disp_rs,              // LED display signal
//   output wire disp_ce_b,            // LED display signal
//   output wire disp_reset_b,         // LED display signal
//   output wire disp_data_out,        // LED display signal
	input wire [23:0] flash_address,
	input wire [INDEX_BITS-1:0] lookup_index, //default is [3:0] unless the parameter is changed
	output wire ready_to_use, //once bram full or reached end of music
	output wire [INDEX_BITS-1:0] items, 		//number of items (address + locations) stored in bram for dyi mode
	output wire [3:0]index_location,
	output wire [23:0] index_address,
	output wire [2:0]state); 			
	
	parameter MUSIC_END = 23'h6AC00;
	
	parameter INITIAL_STATE = 3'd0;
	parameter DIY_INITIAL = 3'd1;
	parameter DIY_START = 3'd2;
	parameter DIY_BUTTON_WAIT = 3'd3;
	parameter DIY_BUTTON_WAIT_DONE = 3'd4;
	parameter DIY_DONE = 3'd5;
	
	
	reg [23:0]address_memory[MAX_ITEM-1:0]; // MAX_ITEM number of 24-bit words
	reg [3:0] location_memory[MAX_ITEM-1:0];// MAX_ITEM number of  4-bit words
	reg [INDEX_BITS-1:0] counts;
	reg [3:0] location;
	assign index_location = location;
	reg [23:0] address;
	assign index_address = address;	
	reg [2:0] next_state;
	assign state = next_state;
	reg internal_ready;
	assign ready_to_use = internal_ready;
	reg [INDEX_BITS-1:0]internal_items;
	assign items = internal_items;
	wire [7:0] button_bits;
	assign button_bits = {upleft , up , upright , left , right , downleft , down , downright};
	reg [7:0] last_button_bits;
	
	
	//timer code
	reg [3:0] timer_value = 2;
	reg start_timer;
	wire timer_expired;
	wire [3:0] displayed_counter;
	
	timer diy_timer(.clk(clock),
						 .start_timer(start_timer),
						 .one_hz_enable(one_hz_enable),
						 .timer_value(timer_value),
						 .expired(timer_expired),
						 .displayed_counter(displayed_counter));
	
	//display code
/*	wire [63:0] display_data;
	assign display_data = {address,location,3'b0, internal_ready, internal_items, 1'b0, next_state, displayed_counter};
	display_16hex disp(.reset(switch[2]), .clock_27mhz(clock), .data_in(display_data), 
		                .disp_rs(disp_rs), .disp_ce_b(disp_ce_b), .disp_blank(disp_blank),
							 .disp_reset_b(disp_reset_b), .disp_data_out(disp_data_out), .disp_clock(disp_clock));
*/

	always @(posedge clock) begin
		//internal_state <= next_state;
		last_button_bits <= button_bits;
		case(next_state)
			INITIAL_STATE: begin 
									next_state <= (!diy_mode) ? INITIAL_STATE : DIY_INITIAL;
									internal_items <= 0;
									counts <= 0;
									internal_ready <= 0;
									start_timer <= 0;
								end
			DIY_INITIAL: begin
									next_state <= (!diy_mode) ? INITIAL_STATE : DIY_START;
									start_timer <= 0;
								end
			DIY_START: begin
								if(flash_address >= MUSIC_END) begin
									next_state <= DIY_DONE;
								end
								else begin
									case(button_bits)
										8'b10000000: begin
																address_memory[internal_items] <= flash_address;
																location_memory[internal_items]  <= 4'd0;
																if (!last_button_bits[7]) begin
																	start_timer <= 1;
																	internal_items <= internal_items + 1;
																	next_state <= (!diy_mode) ? INITIAL_STATE : DIY_BUTTON_WAIT;
																end

														 end
										8'b01000000: begin
																address_memory[internal_items] <= flash_address;
																location_memory[internal_items]  <= 4'd1;
																if (!last_button_bits[6]) begin
																	start_timer <= 1;
																	internal_items <= internal_items + 1;
																	next_state <= (!diy_mode) ? INITIAL_STATE : DIY_BUTTON_WAIT;
																end
														 end
										8'b00100000: begin
																address_memory[internal_items] <= flash_address;
																location_memory[internal_items]  <= 4'd2;
																if (!last_button_bits[5]) begin
																	start_timer <= 1;
																	internal_items <= internal_items + 1;
																	next_state <= (!diy_mode) ? INITIAL_STATE : DIY_BUTTON_WAIT;
																end
														 end
										8'b00010000: begin
																address_memory[internal_items] <= flash_address;
																location_memory[internal_items]  <= 4'd3;
																if (!last_button_bits[4]) begin
																	start_timer <= 1;
																	internal_items <= internal_items + 1;
																	next_state <= (!diy_mode) ? INITIAL_STATE : DIY_BUTTON_WAIT;
																end
														 end
										8'b00001000: begin
																address_memory[internal_items] <= flash_address;
																location_memory[internal_items]  <= 4'd4;
																if (!last_button_bits[3]) begin
																	start_timer <= 1;
																	internal_items <= internal_items + 1;
																	next_state <= (!diy_mode) ? INITIAL_STATE : DIY_BUTTON_WAIT;
																end
														 end
										8'b00000100: begin
																address_memory[internal_items] <= flash_address;
																location_memory[internal_items]  <= 4'd5;
																if (!last_button_bits[2]) begin
																	start_timer <= 1;
																	internal_items <= internal_items + 1;
																	next_state <= (!diy_mode) ? INITIAL_STATE : DIY_BUTTON_WAIT;
																end
														 end
										8'b00000010: begin
																address_memory[internal_items] <= flash_address;
																location_memory[internal_items]  <= 4'd6;
																if (!last_button_bits[1]) begin
																	start_timer <= 1;
																	internal_items <= internal_items + 1;
																	next_state <= (!diy_mode) ? INITIAL_STATE : DIY_BUTTON_WAIT;
																end
														 end
										8'b00000001: begin
																address_memory[internal_items] <= flash_address;
																location_memory[internal_items]  <= 4'd7;
																if (!last_button_bits[0]) begin
																	start_timer <= 1;
																	internal_items <= internal_items + 1;
																	next_state <= (!diy_mode) ? INITIAL_STATE : DIY_BUTTON_WAIT;
																end
														 end
										default: begin
														start_timer <= 0;
													end
									endcase
								end
							end
			DIY_BUTTON_WAIT:begin
										next_state <= (!diy_mode) ? INITIAL_STATE : (timer_expired) ? DIY_BUTTON_WAIT_DONE: DIY_BUTTON_WAIT;
										start_timer <= 0;
								  end
								  
			DIY_BUTTON_WAIT_DONE: begin
												next_state <= (!diy_mode) ? INITIAL_STATE : (internal_items >= MAX_ITEM) ? DIY_DONE : DIY_INITIAL; 
										  end
			DIY_DONE: begin
							internal_ready <= 1; //only get here once you reach the end ideally, because max items should be high enough never reached
							next_state <= (!diy_mode) ? INITIAL_STATE : DIY_DONE;
							address <= address_memory[lookup_index];
							location <= location_memory[lookup_index];

						 end
			default: begin
							next_state <= DIY_INITIAL;
						end
			
		endcase

	end

endmodule

///////////////////////////////////////////////////////////////////////////////
//
// Switch Debounce Module
//
///////////////////////////////////////////////////////////////////////////////

module debounce_ara (
  input wire reset, clock, noisy,
  output reg clean
);
  reg [18:0] count;
  reg new;

  always @(posedge clock)
    if (reset) begin
      count <= 0;
      new <= noisy;
      clean <= noisy;
    end
    else if (noisy != new) begin
      // noisy input changed, restart the .01 sec clock
      new <= noisy;
      count <= 0;
    end
    else if (count == 270000)
      // noisy input stable for .01 secs, pass it along!
      clean <= new;
    else
      // waiting for .01 sec to pass
      count <= count+1;

endmodule

//sound module for DDR whack-a-mole
module sound_module(
  input wire clock,	                // 27mhz system clock
  input wire reset,                 // 1 to reset to initial state
  input wire [7:0] switch,         // switches
  input wire ready,                 // 1 when AC97 data is available
  input wire [7:0] from_ac97_data, // 8-bit PCM data from mic
  input wire flash_sts,				 // flash signal
  output wire [15:0] flash_data,   // flash signals
  output wire [23:0] flash_address,// flash signals
  output wire flash_ce_b,           // flash signals
  output wire flash_oe_b,           // flash signals
  output wire flash_we_b,           // flash signals
  output wire flash_reset_b,        // flash signals
  output wire flash_byte_b,         // flash signals
  //input wire disp_data_in,			 // LED display signal
  //output wire disp_blank,           // LED display signal
  //output wire disp_clock,           // LED display signal
  //output wire disp_rs,              // LED display signal
  //output wire disp_ce_b,            // LED display signal
  //output wire disp_reset_b,         // LED display signal
  //output wire disp_data_out,        // LED display signal
  output wire [22:0] music_address, //output to davis
  input wire [3:0] game_state,     //input from davis
 // input wire [2:0] mole_loc,
  input wire diy_mode,
  output reg [7:0] to_ac97_data    // 8-bit PCM data to headphone
);

	//game states
	parameter IDLE = 4'd0;		// Check if user has pressed start
	parameter GAME_ONGOING	= 4'd2;		// Check lives & Address from Music
	parameter REQUEST_MOLE	= 4'd3;		// Request a mole to be displayed (pulse)
	parameter MOLE_MISSED	= 4'd5;		// Lives counter decremented (pulse)
	parameter MOLE_WHACKED	= 4'd6;		// Score counter incremented (pulse)
	parameter MOLE_COUNTDOWN = 4'd4;		// Mole displayed until stomped/expired
	parameter MOLE_MISSED_SOUND	= 4'd9;		// Extra time for sound
	parameter MOLE_WHACKED_SOUND	= 4'd10;		// Extra time for sound
	
	//sound module states
	parameter LOAD_POP_START = 3'd0;
	parameter LOADING_POP = 3'd1;
	parameter LOAD_MISSED_START = 3'd2;
	parameter LOADING_MISSED = 3'd3;
	parameter LOAD_WHACKED_START = 3'd4;
	parameter LOADING_WHACKED = 3'd5;
	parameter LOAD_DONE = 3'd6;
	parameter READY_TO_PLAY = 3'd7;
	// Placeholder variables for DIY mode
	parameter RECORD_DIY_BEGIN 	= 4'd11;		// Begin Recording Moles
	parameter RECORD_DIY_IN_PROGRESS = 4'd11;// Begin Recording Moles
	parameter RECORD_DIY_END		= 4'd13;		// Recording ended
	
	//address for background music and sound effects
	//make sure the order of things recorded is always background music, pop up sound, missed sound, and whacked sound b/c order
	//mattters whens loading sound effects from flash and putting them in bram in the beginning! Also make sure sound effects are not 
	//too long because bram might run out of memory!
	parameter MUSIC_START = 23'h3000;
	parameter MUSIC_END = 23'h6AC00;
	parameter POPUP_START = 23'h83000;
	parameter POPUP_END = 23'h83500;
	parameter MISSED_START = 23'h8C000;
	parameter MISSED_END = 23'h8CD00;
	parameter WHACKED_START = 23'h92A00;
	parameter WHACKED_END = 23'h93000;


	//state for sound loading to bram
	reg [3:0] sound_state;
	initial sound_state = 0; //start on loading pop start state

	//bram
	parameter LOGSIZE = 16;
	parameter WIDTH = 8;
	parameter BRAM_MAX_ADDRESS = (1 << LOGSIZE) -1 ;
	reg [LOGSIZE-1:0] bram_max_use;
	reg [LOGSIZE-1:0] bram_address;
	initial bram_address = 0;
	reg [WIDTH-1:0] bram_in;
	wire [WIDTH-1:0] bram_out;
	reg bram_we;
	initial bram_we = 0;
	//flash reader
	reg [22:0] flash_raddr;
	reg reading; //controls the doread signal to flash
	wire busy;
	mybram #(.LOGSIZE(LOGSIZE), .WIDTH(WIDTH)) soundeffect_memory(.addr(bram_address),.clk(clock),.we(bram_we),.din(bram_in),.dout(bram_out));

	flash_reader reader_bramdata(.clock(clock), .reset(reset),.read_address(flash_raddr), .reading(reading), .busy(busy),
								.flash_sts(flash_sts),
								.flash_data(flash_data),
								.flash_address(flash_address),
								.flash_ce_b(flash_ce_b),
								.flash_oe_b(flash_oe_b),
								.flash_we_b(flash_we_b),
								.flash_reset_b(flash_reset_b),
								.flash_byte_b(flash_byte_b));
								
	//low pass filter
	wire signed [17:0] filter_f_output; //filtered flash data
	reg [7:0] filter_f_input; //input to filter sound data coming from flash
	wire signed [17:0] filter_b_output; //filtered bram data
	reg [7:0] filter_b_input; //inpput to filter sound data coming from bram
								
	fir31 fir31_bram(.clock(clock), .reset(reset), .ready(ready), .x(filter_b_input), .y(filter_b_output));
	fir31 fir31_flash(.clock(clock), .reset(reset), .ready(ready), .x(filter_f_input), .y(filter_f_output));
	/*
	assign display_data = {mole_loc, game_state};
	
	
	display_16hex disp(.reset(switch[0]), .clock_27mhz(clock), .data_in(display_data), 
		                .disp_rs(disp_rs), .disp_ce_b(disp_ce_b), .disp_blank(disp_blank),
							 .disp_reset_b(disp_reset_b), .disp_data_out(disp_data_out), .disp_clock(disp_clock));
	*/
	
	reg [4:0] flash_read_count; ///wait 2^5 cycles between every read from memory for now when loading to bram
	reg [3:0] last_game_state;
	reg loaded_to_bram;
	initial loaded_to_bram = 0;
	reg pop_sound_done;
	reg missed_sound_done;
	reg whacked_sound_done;
	reg diy_mode_done;
	reg diy_playback;
	reg [LOGSIZE-1:0]bram_pop_start;
	reg [LOGSIZE-1:0]bram_pop_end;
	reg [LOGSIZE-1:0]bram_missed_start;
	reg [LOGSIZE-1:0]bram_missed_end;
	reg [LOGSIZE-1:0]bram_whacked_start;
	reg [LOGSIZE-1:0]bram_whacked_end;
	
	assign music_address = flash_raddr;
	
	always @ (posedge clock) begin
		if(!loaded_to_bram) begin
			case (sound_state)
				LOAD_POP_START: begin
										reading <= 1;
										flash_raddr <= POPUP_START;
										flash_read_count <= 0;
										sound_state <= LOADING_POP;
										bram_pop_start <= 0;
									 end
				LOADING_POP: begin
									flash_read_count <= flash_read_count + 1;
									if (flash_read_count == 0) begin
										bram_we <= 1;
										bram_address <= (bram_address < BRAM_MAX_ADDRESS) ? bram_address + 1 : bram_address;
										bram_pop_end <= bram_address;
										bram_in <= flash_data[7:0];
										if(flash_raddr < POPUP_END) begin
											flash_raddr <= flash_raddr + 1;
										end
										else begin
											sound_state <= LOAD_MISSED_START;
										end
									end								
								  end
				LOAD_MISSED_START: begin
											flash_raddr <= MISSED_START;
											sound_state <= LOADING_MISSED;
											bram_missed_start <= bram_address;
										  end
				LOADING_MISSED: 	begin
											flash_read_count <= flash_read_count + 1;
											if (flash_read_count == 0) begin
												bram_we <= 1;
												bram_address <= (bram_address < BRAM_MAX_ADDRESS) ? bram_address + 1 : bram_address;
												bram_missed_end <= bram_address;
												bram_in <= flash_data[7:0];
												if(flash_raddr < MISSED_END) begin
													flash_raddr <= flash_raddr + 1;
												end
												else begin
													sound_state <= LOAD_WHACKED_START;
												end
											end
										 end
				LOAD_WHACKED_START: begin
												flash_raddr <= WHACKED_START;
												sound_state <= LOADING_WHACKED;
												bram_whacked_start <= bram_address;
										  end
				LOADING_WHACKED: begin
											flash_read_count <= flash_read_count + 1;
											if (flash_read_count == 0) begin
												bram_we <= 1;
												bram_address <= (bram_address < BRAM_MAX_ADDRESS) ? bram_address + 1 : bram_address;
												bram_whacked_end <= bram_address;
												bram_in <= flash_data[7:0];
												if(flash_raddr < WHACKED_END) begin
													flash_raddr <= flash_raddr + 1;
												end
												else begin
													sound_state <= LOAD_DONE;
												end
											end
									  end
				LOAD_DONE: begin
									bram_we <= 0;
									flash_raddr <= MUSIC_START;
									sound_state <= READY_TO_PLAY;
									loaded_to_bram <= 1;
								end
				default: begin
								reading <= 0;
							 end
			endcase
		end else begin
			//if things have been loaded to bram
			if(game_state == IDLE) begin
				//before game starts
				to_ac97_data <= 0;
				flash_raddr <= MUSIC_START;
				reading <= 0;
			end
			else if (!busy) begin
				reading <= 1;
				last_game_state <= game_state;
				case(game_state)
					MOLE_COUNTDOWN: begin
												filter_f_input <= flash_data[7:0];

												if(last_game_state != game_state) begin
													bram_address <= bram_pop_start;
													pop_sound_done <= 0;
												end
												else begin
													if (ready) begin
														if (!pop_sound_done) begin //if pop sound not done
															if(bram_address >= bram_pop_end) begin
																pop_sound_done <= 1;
															end
															else begin 
																bram_address <= bram_address + 1;
																flash_raddr <= (flash_raddr >= MUSIC_END) ? MUSIC_START : flash_raddr + 1;
																to_ac97_data <= filter_f_output[17:10] + bram_out[7:0];
															end
														end
														else begin
															//done playing sound effect
															flash_raddr <= (flash_raddr >= MUSIC_END) ? MUSIC_START : flash_raddr + 1;
															to_ac97_data <= filter_f_output[17:10];
														end
													end
												end
										 end
					MOLE_MISSED_SOUND: begin
												filter_f_input <= flash_data[7:0];

												if(last_game_state != game_state) begin
													bram_address <= bram_missed_start;
													missed_sound_done <= 0;
												end
												else begin
													if (ready) begin
														if (!missed_sound_done) begin //if pop sound not done
															if(bram_address >= bram_missed_end) begin
																missed_sound_done <= 1;
															end
															else begin 
																bram_address <= bram_address + 1;
																flash_raddr <= (flash_raddr >= MUSIC_END) ? MUSIC_START : flash_raddr + 1;
																to_ac97_data <= filter_f_output[17:10] + bram_out[7:0];
															end
														end
														else begin
															//done playing sound effect
															flash_raddr <= (flash_raddr >= MUSIC_END) ? MUSIC_START : flash_raddr + 1;
															to_ac97_data <= filter_f_output[17:10];
														end
													end
												end
										 end
					MOLE_WHACKED_SOUND: begin
												filter_f_input <= flash_data[7:0];

												if(last_game_state != game_state) begin
													bram_address <= bram_whacked_start;
													whacked_sound_done <= 0;
												end
												else begin
													if (ready) begin
														if (!whacked_sound_done) begin //if pop sound not done
															if(bram_address >= bram_whacked_end) begin
																whacked_sound_done <= 1;
															end
															else begin 
																bram_address <= bram_address + 1;
																flash_raddr <= (flash_raddr >= MUSIC_END) ? MUSIC_START : flash_raddr + 1;
																to_ac97_data <= filter_f_output[17:10] + bram_out[7:0];
															end
														end
														else begin
															//done playing sound effect
															flash_raddr <= (flash_raddr >= MUSIC_END) ? MUSIC_START : flash_raddr + 1;
															to_ac97_data <= filter_f_output[17:10];
														end
													end
												end
										 end
					RECORD_DIY_IN_PROGRESS: begin
														if(last_game_state != game_state) begin
															flash_raddr <= MUSIC_START;
															diy_mode_done <= 0;
															diy_playback <= 0;
														end
														else begin
															if (!diy_mode_done) begin
																filter_f_input <= flash_data[7:0];
																if (ready) begin
																	to_ac97_data <= filter_f_output[17:0];
																	if(flash_raddr >= MUSIC_END) begin
																		diy_mode_done <= 1;
																	end
																	else begin
																		flash_raddr <= flash_raddr + 1; 
																	end
																end
															end
															else begin
																to_ac97_data <= 0;
															end
														end
													end
					default: begin
									//play background music
									filter_f_input <= flash_data[7:0];
									if(ready) begin
										to_ac97_data <= filter_f_output[17:10];
										flash_raddr <= (flash_raddr >= MUSIC_END) ? MUSIC_START : flash_raddr + 1;
									end
									
									
									/*
									//checked that all sounds correctly load to bram to the correct address, so thats not why
									//its not playing
									//comment out the code above and play this one instead to loop through whats in bram
									filter_b_input <= bram_out[7:0];
									if(ready) begin
										to_ac97_data <= bram_out[7:0];//filter_b_output[17:10];
										bram_address <= (bram_address < bram_whacked_end) ? bram_address + 1 : bram_whacked_start;
									end
									*/
								 end
				endcase
			end
		end
	end
endmodule


/////////////////////////////////////
//Flash reader module; takes in address and return value from flash for that address, slow reading each 32 clock cycle!
////////////////////////////////////
module flash_reader(
	input wire clock,	                // 27mhz system clock
  input wire reset,                 // 1 to reset to initial state
  input wire [22:0] read_address,		//address to read from
  input wire flash_sts,				 // flash signal
  output wire [15:0] flash_data,   // flash signals
  output wire [23:0] flash_address,// flash signals
  output wire flash_ce_b,           // flash signals
  output wire flash_oe_b,           // flash signals
  output wire flash_we_b,           // flash signals
  output wire flash_reset_b,        // flash signals
  output wire flash_byte_b,         // flash signals	
  input wire reading,						
  output wire busy 						//flash busy
);
	//flash hardcoded to readmode
	reg flash_reset = 0;
	reg writemode = 0;
	reg dowrite = 0;
	reg doread;
	//wire busy;
	reg [22:0]raddr; //address for reading from flash
	wire [15:0] frdata; //data from flash reading

	flash_manager flash_flash(.clock(clock), .reset(flash_reset), .writemode(writemode), .dowrite(dowrite),
										.doread(doread),  .busy(busy), .raddr(raddr), .frdata(frdata),
										.flash_data(flash_data), .flash_address(flash_address), .flash_ce_b(flash_ce_b), .flash_oe_b(flash_oe_b),
										.flash_we_b(flash_we_b), .flash_reset_b(flash_reset_b), .flash_sts(flash_sts), .flash_byte_b(flash_byte_b));
	always @ (posedge clock) begin
		if(!busy) begin
			raddr <= read_address;
			doread <= reading;
			writemode <= 0;
		end 
	end
endmodule

///////////////////////////////////////////////////////////////////////////////
//
// Record/playback
//
///////////////////////////////////////////////////////////////////////////////


//one that has sampling issues but works in terms of reading and writing to flash!	
module recorder(
  input wire clock,	                // 27mhz system clock
  input wire reset,                 // 1 to reset to initial state
  input wire playback,              // 1 for playback, 0 for record
  input wire ready,                 // 1 when AC97 data is available
  input wire [7:0] switch,         // switches
  input wire [7:0] from_ac97_data, // 8-bit PCM data from mic
  input wire disp_data_in,			 // LED display signal
  input wire flash_sts,				 // flash signal
  output wire [15:0] flash_data,   // flash signals
  output wire [23:0] flash_address,// flash signals
  output wire flash_ce_b,           // flash signals
  output wire flash_oe_b,           // flash signals
  output wire flash_we_b,           // flash signals
  output wire flash_reset_b,        // flash signals
  output wire flash_byte_b,         // flash signals
  output wire disp_blank,           // LED display signal
  output wire disp_clock,           // LED display signal
  output wire disp_rs,              // LED display signal
  output wire disp_ce_b,            // LED display signal
  output wire disp_reset_b,         // LED display signal
  output wire disp_data_out,        // LED display signal
  output wire [7:0] led,			    // leds
  output reg [7:0] to_ac97_data    // 8-bit PCM data to headphone
);  

	parameter MAX_READ_ADDRESS = 23'h0F0005; //23'h025; //max address you want to read
														//to set max write address, change parameter MAX_ADDRESS in test_fsm.v
														//should be same as in test_fsm, slighty higher right now for testing purposes
														
	wire busy; //output from flash that tells you if flash is busy doing something
	wire [11:0] fsmstate; //output from flash for debugging purposes
	wire [639:0] dots; //output from flash for debugging purposes (dots is used with the display.v module)
	reg writemode;
	reg dowrite;
	reg doread;
	reg [15:0] wdata = 16'h0; //data to be written to flash when flash is under write mode
	reg [22:0]raddr; //address for reading from flash
	wire [15:0] frdata; //data from flash reading
	
	reg [3:0] flash_write_counter; //waitsome clock cycles between each write to flash
	wire [63:0]display_data; //data for display_16hex.v module
	
	wire display_reset; //to reset display_16hex.v module; switch0
	wire flash_reset; //to put flash in erase mode; switch3
	wire writing; //to put flash in write mode; switch5
	wire reading; //to put flash in read mode; switch6
	wire read_incr; //to increment the read address (will be incrementing everytime this goes from 0 to 1); switch7
	reg last_read_incr; //to store last read_incr value
	wire clean_sw1; //debounced switch1
	wire clean_sw2; //debounced switch2	
	
	assign display_data = {flash_data, raddr[15:0], wdata};
	assign led[0] = ~flash_reset; //sw3
	assign led[1] = ~writemode; 
	assign led[2] = ~dowrite;
	assign led[3] = ~doread;
	assign led[4] = ~display_reset; //sw0
	assign led[5] = ~busy;
	assign led[6] = ~writing; //sw5
	assign led[7] = ~reading; //sw6, sw7 for incrementing read address
	

	reg [7:0] ready_count;
	
	wire signed [17:0] filter_output; //filtered
	reg [7:0] filter_input; //input to filter
	

   debounce sw0(.reset(reset),.clock(clock),.noisy(switch[0]),.clean(display_reset));
	debounce sw1(.reset(reset),.clock(clock),.noisy(switch[1]),.clean(clean_sw1));
	debounce sw2(.reset(reset),.clock(clock),.noisy(switch[2]),.clean(clean_sw2));
   debounce sw3(.reset(reset),.clock(clock),.noisy(switch[3]),.clean(flash_reset));
	debounce sw5(.reset(reset),.clock(clock),.noisy(switch[5]),.clean(writing));
	debounce sw6(.reset(reset),.clock(clock),.noisy(switch[6]),.clean(reading));
	debounce sw7(.reset(reset),.clock(clock),.noisy(switch[7]),.clean(read_incr));
	
	flash_manager flash_flash(.clock(clock), .reset(flash_reset), .dots(dots),
										.writemode(writemode), .wdata(wdata), .dowrite(dowrite),
										.raddr(raddr), .frdata(frdata), .doread(doread), .busy(busy), .fsmstate(fsmstate),
										.flash_data(flash_data), .flash_address(flash_address), .flash_ce_b(flash_ce_b), .flash_oe_b(flash_oe_b),
										.flash_we_b(flash_we_b), .flash_reset_b(flash_reset_b), .flash_sts(flash_sts), .flash_byte_b(flash_byte_b));
										
	display_16hex disp(.reset(display_reset), .clock_27mhz(clock), .data_in(display_data), 
		                .disp_rs(disp_rs), .disp_ce_b(disp_ce_b), .disp_blank(disp_blank),
							 .disp_reset_b(disp_reset_b), .disp_data_out(disp_data_out), .disp_clock(disp_clock));
	
	//low pass filter
	fir31 fir31(.clock(clock), .reset(reset), .ready(ready), .x(filter_input), .y(filter_output));
	
always @(posedge clock) begin
	if(clean_sw1 & clean_sw2) begin
		//reset signals
		writemode <= 1;
		dowrite <= 0;
		doread <= 0;
		raddr <= 0;
		ready_count <= 0;
	end
	else begin
		//if not resetting signals then do things based on if flash is busy or not
		if(!busy) begin
			//if flash is not busy
			if (writing) begin
				writemode <= 1;
				doread <= 0;
				
				filter_input <= from_ac97_data;

				if (ready) begin
					ready_count <= ready_count + 1;
					if (ready_count == 7) begin //i think 6 7 or 8 will work for this?
						ready_count <= 0;
						dowrite <=1;
						wdata <= filter_output[17:10]; //from_ac97_data;
					end
				end
			end
	
			if (reading) begin
				writemode <= 0;
				doread <= 1;
				filter_input <= frdata[7:0];
				if (ready) begin
					to_ac97_data <= filter_output[17:10]; //frdata[7:0];
					if (raddr >= MAX_READ_ADDRESS) begin
						raddr <= 0;
					end
					else raddr <= raddr + 1;
				end
			end
		end
		else begin
			//if flash is busy
			if (writing) begin
				dowrite <= 0;
			end
		end
	end
end //always block end
endmodule




///////////////////////////////////////////////////////////////////////////////
//
// Verilog equivalent to a BRAM, tools will infer the right thing!
// number of locations = 1<<LOGSIZE, width in bits = WIDTH.
// default is a 16K x 1 memory.
//
///////////////////////////////////////////////////////////////////////////////

module mybram #(parameter LOGSIZE=14, WIDTH=1)
              (input wire [LOGSIZE-1:0] addr,
               input wire clk,
               input wire [WIDTH-1:0] din,
               output reg [WIDTH-1:0] dout,
               input wire we);
   // let the tools infer the right number of BRAMs
   (* ram_style = "block" *)
   reg [WIDTH-1:0] mem[(1<<LOGSIZE)-1:0];
   always @(posedge clk) begin
     if (we) mem[addr] <= din;
     dout <= mem[addr];
   end
endmodule

///////////////////////////////////////////////////////////////////////////////
//
// 31-tap FIR filter, 8-bit signed data, 10-bit signed coefficients.
// ready is asserted whenever there is a new sample on the X input,
// the Y output should also be sampled at the same time.  Assumes at
// least 32 clocks between ready assertions.  Note that since the
// coefficients have been scaled by 2**10, so has the output (it's
// expanded from 8 bits to 18 bits).  To get an 8-bit result from the
// filter just divide by 2**10, ie, use Y[17:10].
//
///////////////////////////////////////////////////////////////////////////////

module fir31(
  input wire clock,reset,ready,
  input wire signed [7:0] x,
  output reg signed [17:0] y //accumulator
);
  reg signed [17:0] sum;
  reg [4:0] offset;
  reg [4:0] index_reg;
  wire [4:0] index;
  assign index = index_reg;
  reg signed [7:0] sample [31:0]; //32 element array each 8 bits wide
  initial begin
		sum = 0;
		offset = 0;
		index_reg =0;
  end
  
  wire signed [9:0] coeff;
  coeffs31 coeffs31(.index(index),.coeff(coeff));
  
  always @(posedge clock) begin
		if (ready) begin
			sum <= 0;
			index_reg <= 0;
			offset <= offset+1;
			sample[offset] <= x;
		end
		else if (index_reg<= 30) begin
			index_reg <= index_reg + 1;
			sum <= sum+ coeff*sample[offset-index];
			if(index_reg == 30)
				y <= sum + coeff*sample[offset-index];
		end
  end
  /*
  // for now just pass data through
  always @(posedge clock) begin
    if (ready) y <= {x,10'd0};
  end
  */
endmodule

///////////////////////////////////////////////////////////////////////////////
//
// Coefficients for a 31-tap low-pass FIR filter with Wn=.125 (eg, 3kHz for a
// 48kHz sample rate).  Since we're doing integer arithmetic, we've scaled
// the coefficients by 2**10
// Matlab command: round(fir1(30,.125)*1024)
//
///////////////////////////////////////////////////////////////////////////////

module coeffs31(
  input wire [4:0] index,
  output reg signed [9:0] coeff
);
  // tools will turn this into a 31x10 ROM
  always @(index)
    case (index)
      5'd0:  coeff = -10'sd1;
      5'd1:  coeff = -10'sd1;
      5'd2:  coeff = -10'sd3;
      5'd3:  coeff = -10'sd5;
      5'd4:  coeff = -10'sd6;
      5'd5:  coeff = -10'sd7;
      5'd6:  coeff = -10'sd5;
      5'd7:  coeff = 10'sd0;
      5'd8:  coeff = 10'sd10;
      5'd9:  coeff = 10'sd26;
      5'd10: coeff = 10'sd46;
      5'd11: coeff = 10'sd69;
      5'd12: coeff = 10'sd91;
      5'd13: coeff = 10'sd110;
      5'd14: coeff = 10'sd123;
      5'd15: coeff = 10'sd128;
      5'd16: coeff = 10'sd123;
      5'd17: coeff = 10'sd110;
      5'd18: coeff = 10'sd91;
      5'd19: coeff = 10'sd69;
      5'd20: coeff = 10'sd46;
      5'd21: coeff = 10'sd26;
      5'd22: coeff = 10'sd10;
      5'd23: coeff = 10'sd0;
      5'd24: coeff = -10'sd5;
      5'd25: coeff = -10'sd7;
      5'd26: coeff = -10'sd6;
      5'd27: coeff = -10'sd5;
      5'd28: coeff = -10'sd3;
      5'd29: coeff = -10'sd1;
      5'd30: coeff = -10'sd1;
      default: coeff = 10'hXXX;
    endcase
endmodule