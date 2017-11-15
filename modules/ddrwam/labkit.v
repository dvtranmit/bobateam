///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// CHANGES FOR BOARD REVISION 004
//
// 1) Added signals for logic analyzer pods 2-4.
// 2) Expanded "tv_in_ycrcb" to 20 bits.
// 3) Renamed "tv_out_data" to "tv_out_i2c_data" and "tv_out_sclk" to
//    "tv_out_i2c_clock".
// 4) Reversed disp_data_in and disp_data_out signals, so that "out" is an
//    output of the FPGA, and "in" is an input.
//
// CHANGES FOR BOARD REVISION 003
//
// 1) Combined flash chip enables into a single signal, flash_ce_b.
//
// CHANGES FOR BOARD REVISION 002
//
// 1) Added SRAM clock feedback path input and output
// 2) Renamed "mousedata" to "mouse_data"
// 3) Renamed some ZBT memory signals. Parity bits are now incorporated into 
//    the data bus, and the byte write enables have been combined into the
//    4-bit ram#_bwe_b bus.
// 4) Removed the "systemace_clock" net, since the SystemACE clock is now
//    hardwired on the PCB to the oscillator.
//
///////////////////////////////////////////////////////////////////////////////
//
// Complete change history (including bug fixes)
//
// 2006-Mar-08: Corrected default assignments to "vga_out_red", "vga_out_green"
//              and "vga_out_blue". (Was 10'h0, now 8'h0.)
//
// 2005-Sep-09: Added missing default assignments to "ac97_sdata_out",
//              "disp_data_out", "analyzer[2-3]_clock" and
//              "analyzer[2-3]_data".
//
// 2005-Jan-23: Reduced flash address bus to 24 bits, to match 128Mb devices
//              actually populated on the boards. (The boards support up to
//              256Mb devices, with 25 address lines.)
//
// 2004-Oct-31: Adapted to new revision 004 board.
//
// 2004-May-01: Changed "disp_data_in" to be an output, and gave it a default
//              value. (Previous versions of this file declared this port to
//              be an input.)
//
// 2004-Apr-29: Reduced SRAM address busses to 19 bits, to match 18Mb devices
//              actually populated on the boards. (The boards support up to
//              72Mb devices, with 21 address lines.)
//
// 2004-Apr-29: Change history started
//
///////////////////////////////////////////////////////////////////////////////

module labkit (beep, audio_reset_b, ac97_sdata_out, ac97_sdata_in, ac97_synch,
	       ac97_bit_clock,
	       
	       vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
	       vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
	       vga_out_vsync,

	       tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
	       tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
	       tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,

	       tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
	       tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
	       tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
	       tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,

	       ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
	       ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b, 

	       ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
	       ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,

	       clock_feedback_out, clock_feedback_in,

	       flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
	       flash_reset_b, flash_sts, flash_byte_b,

	       rs232_txd, rs232_rxd, rs232_rts, rs232_cts,

	       mouse_clock, mouse_data, keyboard_clock, keyboard_data,

	       clock_27mhz, clock1, clock2,

	       disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
	       disp_reset_b, disp_data_in,

	       button0, button1, button2, button3, button_enter, button_right,
	       button_left, button_down, button_up,

	       switch,

	       led,
	       
	       user1, user2, user3, user4,
	       
	       daughtercard,

	       systemace_data, systemace_address, systemace_ce_b,
	       systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,
	       
	       analyzer1_data, analyzer1_clock,
 	       analyzer2_data, analyzer2_clock,
 	       analyzer3_data, analyzer3_clock,
 	       analyzer4_data, analyzer4_clock);

   output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
   input  ac97_bit_clock, ac97_sdata_in;
   
   output [7:0] vga_out_red, vga_out_green, vga_out_blue;
   output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
	  vga_out_hsync, vga_out_vsync;

   output [9:0] tv_out_ycrcb;
   output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
	  tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
	  tv_out_subcar_reset;
   
   input  [19:0] tv_in_ycrcb;
   input  tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
	  tv_in_hff, tv_in_aff;
   output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
	  tv_in_reset_b, tv_in_clock;
   inout  tv_in_i2c_data;
        
   inout  [35:0] ram0_data;
   output [18:0] ram0_address;
   output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
   output [3:0] ram0_bwe_b;
   
   inout  [35:0] ram1_data;
   output [18:0] ram1_address;
   output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
   output [3:0] ram1_bwe_b;

   input  clock_feedback_in;
   output clock_feedback_out;
   
   inout  [15:0] flash_data;
   output [23:0] flash_address;
   output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
   input  flash_sts;
   
   output rs232_txd, rs232_rts;
   input  rs232_rxd, rs232_cts;

   input  mouse_clock, mouse_data, keyboard_clock, keyboard_data;

   input  clock_27mhz, clock1, clock2;

   output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;  
   input  disp_data_in;
   output  disp_data_out;
   
   input  button0, button1, button2, button3, button_enter, button_right,
	  button_left, button_down, button_up;
   input  [7:0] switch;
   output [7:0] led;

   inout [31:0] user1, user2, user3, user4;
   
   inout [43:0] daughtercard;

   inout  [15:0] systemace_data;
   output [6:0]  systemace_address;
   output systemace_ce_b, systemace_we_b, systemace_oe_b;
   input  systemace_irq, systemace_mpbrdy;

   output [15:0] analyzer1_data, analyzer2_data, analyzer3_data, 
		 analyzer4_data;
   output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // I/O Assignments
   //
   ////////////////////////////////////////////////////////////////////////////
   
   // Audio Input and Output
   assign beep= 1'b0;
   assign audio_reset_b = 1'b0;
   assign ac97_synch = 1'b0;
   assign ac97_sdata_out = 1'b0;
   // ac97_sdata_in is an input

   // VGA Output
   assign vga_out_red = 8'h0;
   assign vga_out_green = 8'h0;
   assign vga_out_blue = 8'h0;
   assign vga_out_sync_b = 1'b1;
   assign vga_out_blank_b = 1'b1;
   assign vga_out_pixel_clock = 1'b0;
   assign vga_out_hsync = 1'b0;
   assign vga_out_vsync = 1'b0;

   // Video Output
   assign tv_out_ycrcb = 10'h0;
   assign tv_out_reset_b = 1'b0;
   assign tv_out_clock = 1'b0;
   assign tv_out_i2c_clock = 1'b0;
   assign tv_out_i2c_data = 1'b0;
   assign tv_out_pal_ntsc = 1'b0;
   assign tv_out_hsync_b = 1'b1;
   assign tv_out_vsync_b = 1'b1;
   assign tv_out_blank_b = 1'b1;
   assign tv_out_subcar_reset = 1'b0;
   
   // Video Input
   assign tv_in_i2c_clock = 1'b0;
   assign tv_in_fifo_read = 1'b0;
   assign tv_in_fifo_clock = 1'b0;
   assign tv_in_iso = 1'b0;
   assign tv_in_reset_b = 1'b0;
   assign tv_in_clock = 1'b0;
   assign tv_in_i2c_data = 1'bZ;
   // tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, 
   // tv_in_aef, tv_in_hff, and tv_in_aff are inputs
   
   // SRAMs
   assign ram0_data = 36'hZ;
   assign ram0_address = 19'h0;
   assign ram0_adv_ld = 1'b0;
   assign ram0_clk = 1'b0;
   assign ram0_cen_b = 1'b1;
   assign ram0_ce_b = 1'b1;
   assign ram0_oe_b = 1'b1;
   assign ram0_we_b = 1'b1;
   assign ram0_bwe_b = 4'hF;
   assign ram1_data = 36'hZ; 
   assign ram1_address = 19'h0;
   assign ram1_adv_ld = 1'b0;
   assign ram1_clk = 1'b0;
   assign ram1_cen_b = 1'b1;
   assign ram1_ce_b = 1'b1;
   assign ram1_oe_b = 1'b1;
   assign ram1_we_b = 1'b1;
   assign ram1_bwe_b = 4'hF;
   assign clock_feedback_out = 1'b0;
   // clock_feedback_in is an input
   
   // Flash ROM
   assign flash_data = 16'hZ;
   assign flash_address = 24'h0;
   assign flash_ce_b = 1'b1;
   assign flash_oe_b = 1'b1;
   assign flash_we_b = 1'b1;
   assign flash_reset_b = 1'b0;
   assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs

   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

   // LED Displays
   assign disp_blank = 1'b1;
   assign disp_clock = 1'b0;
   assign disp_rs = 1'b0;
   assign disp_ce_b = 1'b1;
   assign disp_reset_b = 1'b0;
   assign disp_data_out = 1'b0;
   // disp_data_in is an input

   // Buttons, Switches, and Individual LEDs
//   assign led = 8'hFF;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
   assign user1 = 32'hZ;
   assign user2 = 32'hZ;
   assign user3 = 32'hZ;
   assign user4 = 32'hZ;

   // Daughtercard Connectors
   assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
   assign systemace_data = 16'hZ;
   assign systemace_address = 7'h0;
   assign systemace_ce_b = 1'b1;
   assign systemace_we_b = 1'b1;
   assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs

   // Logic Analyzer
   assign analyzer1_data = 16'h0;
   assign analyzer1_clock = 1'b1;
   assign analyzer2_data = 16'h0;
   assign analyzer2_clock = 1'b1;
   assign analyzer3_data = 16'h0;
   assign analyzer3_clock = 1'b1;
   assign analyzer4_data = 16'h0;
   assign analyzer4_clock = 1'b1;
			    
  ////////////////////////////////////////////////////////////////////////////
  //
  // Reset Generation
  //
  // A shift register primitive is used to generate an active-high reset
  // signal that remains high for 16 clock cycles after configuration finishes
  // and the FPGA's internal clocks begin toggling.
  //
  ////////////////////////////////////////////////////////////////////////////
  wire reset;
  SRL16 reset_sr(.D(1'b0), .CLK(clock_27mhz), .Q(reset),
	         .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
  defparam reset_sr.INIT = 16'hFFFF;

  ////////////////////////////////////////////////////////////////////////////
  // 
  // Control the leds with the switches
  // 
  assign led = ~switch;
  //
  ////////////////////////////////////////////////////////////////////////////

endmodule

//////////////////////////////////////////////////////////////////////////////
//																									 //
//										DIVIDER MODULE										 	 //
//																									 //
//////////////////////////////////////////////////////////////////////////////

module divider (	input clk,
						input start_timer,
						output one_hz_enable );

// Implemented similar to debounce
parameter DELAY = 32'd27000000;
   
reg [31:0] counter = 32'd0;
reg enable = 1'b0;

always @(posedge clk) begin
    if (start_timer) begin                  // divider reset
        counter <= 32'd0;
        enable <= 1'b0;
    end else if (enable) begin              // enable pulse off
        enable <= 1'b0;
        counter <= counter + 1;
    end else if (counter == DELAY) begin    // enable pulse on
        enable <= 1'b1;
        counter <= 32'd0;
    end else                                // increment counter
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
					output expired );

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
	        (input reset, clk, noisy,
	         output reg clean);

   reg [18:0] count;
   reg new;
   wire synced;
   synchronize sync1(.clk(clk), .in(noisy), .out(synced));

   always @(posedge clk) begin
		if (reset) begin
			count <= 0;
			new <= synced;
			clean <= synced;
		end else if (synced != new) begin
			new <= synced;
			count <= 0;
		end else if (count == DELAY)
			clean <= new;
		else
			count <= count+1;
	end
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
								input start,
								input reset,
								input mole_location,
								output misstep,
								output whacked);


reg [7:0] location = 8'b0;

// Temporary variables for output
reg temp_whacked = 1'b0;
reg temp_misstep = 1'b0;
 
always@(posedge clk) begin
	if ({upleft, up, upright, left, right, downleft, down, downright} == location)
		temp_whacked <= 1'b1;
	else if ({upleft, up, upright, left, right, downleft, down, downright} !== 8'b0)
		temp_misstep <= 1'b1;
	else begin
		temp_whacked <= 1'b0;
		temp_misstep <= 1'b0;
	end
end

// Convert location to one hot representation
always@(*) begin
	case(mole_location)
		3'd0: location = 8'b00000001;
		3'd1: location = 8'b00000010;
		3'd2: location = 8'b00000100;
		3'd3: location = 8'b00001000;
		3'd4: location = 8'b00010000;
		3'd5: location = 8'b00100000;
		3'd6: location = 8'b01000000;
		3'd7: location = 8'b10000000;
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

module mole(	input clk, reset,
					input one_hz_enable, // delete this when we can check address
					output request_mole );

// Current implementation is just a really long alternating signal
// Future implemention should either pop a mole up at specific memory addresses
// or at pre-programmed times

/* Memory address popup pseudocode
	
	initialize array of popup times
	initialize array index variable
	always @ posedge clk
		check time against current array value
			increment index if match
		increment time
*/
 
// States
parameter COUNTING 	= 1'b1;		// Countdown from timer_value (until expired)
parameter MOLE			= 1'b0;		// mole pulse lasts one clock cycle

// State machine variables
reg state = COUNTING;
reg [3:0] counter = 4'd5;

always @(posedge clk) begin
	if (reset) begin
		state <= COUNTING;
		counter <= 4'd5;
	end else if (state == COUNTING) begin
		state <= (counter == 0) ? MOLE : COUNTING;
		counter <= (one_hz_enable) ? counter - 1: counter;
	end else if (state == MOLE) begin
		state <= COUNTING;
		counter <= 4'd5;
	end
end

assign request_mole = (state == MOLE);
endmodule



//////////////////////////////////////////////////////////////////////////////
//																									 //
//							  RANDOM NUMBER GENERATOR MODULE								 //
//																									 //
//////////////////////////////////////////////////////////////////////////////
module rng(	input clk, reset,
				output [2:0] r );

reg [2:0] temp_r = 3'b001;

always @ (posedge clk) begin
	if (reset)
		temp_r <= 3'b001;
	else
		temp_r <= {temp_r[1:0], temp_r[2]^temp_r[0]};
end

assign r = temp_r;
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
						// Future input: record
						output start_timer,
						output [3:0] timer_value,
						output [3:0] display_state,
						output [2:0] mole_location,
						output [1:0] lives,
						output [7:0] score
						);
						
// States
reg [3:0] IDLE 					= 4'd0;		// Check if user has pressed start
reg [3:0] GAME_START_DELAY 	= 4'd1;		// Delay until user stands on center
reg [3:0] GAME_ONGOING			= 4'd2;		// Check lives & Address from Music
reg [3:0] REQUEST_MOLE			= 4'd3;		// Request a mole to be displayed (pulse)
reg [3:0] MOLE_COUNTDOWN		= 4'd4;		// Mole displayed until stomped/expired 
reg [3:0] MOLE_MISSED			= 4'd5;		// Lives counter decremented (pulse)
reg [3:0] MOLE_WHACKED			= 4'd6;		// Score counter incremented (pulse)
reg [3:0] SAFE_STEP_DELAY		= 4'd7;		// Prevent repeated lives decrement
reg [3:0] GAME_OVER				= 4'd8;		// Display Game Over Screen

// State machine variables
reg [3:0] state = 4'b0;
reg [3:0] next_state = 4'b0;

// Counters
reg [1:0] temp_lives = 2'd3;	// If zero --> Dead --> Game Over
reg [7:0] temp_score = 8'd0;

// Do a thing each relevant state
always @(posedge clk) begin
	if (reset)
		state <= 4'b0;
	state <= next_state;
end

// State machine
always @(*) begin
	case(state)
		IDLE : next_state = (start) ? GAME_START_DELAY : IDLE;
		GAME_START_DELAY: next_state = (expired) ? GAME_ONGOING : GAME_START_DELAY;
		GAME_ONGOING : next_state = (lives == 0) ? GAME_OVER : (request_mole) ? REQUEST_MOLE : GAME_ONGOING;
		REQUEST_MOLE : next_state = MOLE_COUNTDOWN;
		MOLE_COUNTDOWN : next_state = (expired || misstep) ? MOLE_MISSED : (whacked) ? MOLE_WHACKED : MOLE_COUNTDOWN;
		MOLE_MISSED : next_state = SAFE_STEP_DELAY;
		MOLE_WHACKED : next_state = SAFE_STEP_DELAY;
		SAFE_STEP_DELAY : next_state = (expired) ? GAME_ONGOING : SAFE_STEP_DELAY;
		GAME_OVER : next_state = (expired) ? IDLE : GAME_OVER;
		default : next_state = IDLE;
	endcase
end


wire [2:0] location;
rng loc(clk, reset, location);

assign start_timer = (state == IDLE && next_state == GAME_START_DELAY);
assign timer_value = 4'd2;
assign display_state = state;
assign mole_location = location;
assign lives = temp_lives;
assign score = temp_score;

endmodule