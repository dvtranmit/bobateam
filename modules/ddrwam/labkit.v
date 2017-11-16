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
	//   assign disp_blank = 1'b1;
	//   assign disp_clock = 1'b0;
	//   assign disp_rs = 1'b0;
	//   assign disp_ce_b = 1'b1;
	//   assign disp_reset_b = 1'b0;
	//   assign disp_data_out = 1'b0;
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


///////////////////////////////////////////
//				  DEBOUNCE INPUTS				  //
///////////////////////////////////////////

	wire upleft, up, upright, left, right, downleft, down, downright, enter;
	debounce db_ul(.clk(clock_27mhz), .reset(reset), .noisy(button3), .clean(upleft));
	debounce db_ur(.clk(clock_27mhz), .reset(reset), .noisy(button2), .clean(upright));
	debounce db_dl(.clk(clock_27mhz), .reset(reset), .noisy(button1), .clean(downleft));
	debounce db_dr(.clk(clock_27mhz), .reset(reset), .noisy(button0), .clean(downright));
	debounce db_u(.clk(clock_27mhz), .reset(reset), .noisy(button_up), .clean(up));
	debounce db_d(.clk(clock_27mhz), .reset(reset), .noisy(button_down), .clean(down));
	debounce db_l(.clk(clock_27mhz), .reset(reset), .noisy(button_left), .clean(left));
	debounce db_r(.clk(clock_27mhz), .reset(reset), .noisy(button_right), .clean(right));
	debounce db_e(.clk(clock_27mhz), .reset(reset), .noisy(button_enter), .clean(enter));
	
	wire start;
	debounce db_st(.clk(clock_27mhz), .reset(reset), .noisy(switch[7]), .clean(start));

///////////////////////////////////////////
//			INITIALIZE & CONNECT GAME		  //
///////////////////////////////////////////

	/* Available Modules
		gameState
		interpretInput
		mole
		debounce
		divider
		display_string
		rng
		interpret_input
	*/
	
	// Pulse every hz for human time domain timing
	wire one_hz_enable;
	divider one_hz_div(.clk(clock_27mhz), .reset(enter), .one_hz_enable(one_hz_enable));

	// timer for delays
	wire expired;
	wire [3:0] displayed_counter;
	wire start_timer;
	wire [3:0] timer_value;
	timer game_start_delay(.clk(clock_27mhz), .start_timer(start_timer), .one_hz_enable(one_hz_enable),
									.timer_value(timer_value), .expired(expired),
									.displayed_counter(displayed_counter));
	
	// Generate random locations (a number 0-7)
	wire [2:0] random_mole_location;
	random moleloc(.clk(one_hz_enable), .reset(enter), .r(random_mole_location));

	// Send misstep and whacked signals for game logic
	wire misstep;
	wire whacked;
	wire [2:0] mole_location;
	interpret_input step_signals( .clk(clock_27mhz), .upleft(upleft),
												.up(up), .upright(upright),
												.left(left), .right(right),
												.downleft(downleft), .down(down),
												.downright(downright), .reset(enter),
												.mole_location(mole_location),
												.misstep(misstep), .whacked(whacked));

	wire request_mole;
	mole getmole(.clk(clock_27mhz), .reset(enter),
						.one_hz_enable(one_hz_enable),
						.request_mole(request_mole));

	wire [3:0] display_state;
	wire [1:0] lives;
	wire [7:0] score;
	gameState game(.clk(clock_27mhz), .misstep(misstep),
						.whacked(whacked), .start(start),
						.reset(enter), .request_mole(request_mole),
						.expired(expired), .random_mole_location(random_mole_location),
						.start_timer(start_timer), .timer_value(timer_value),
						.display_state(display_state), .mole_location(mole_location), 
						.lives(lives), .score(score));

///////////////////////////////////////////
//						DEBUGGING		  			//
///////////////////////////////////////////

	// Blink w/ 2s period
	// Calculate displays
	reg toggler = 1'b1;
	reg [15:0] step_location;
	reg [7:0] feedback;
	reg [2:0] current_mole_location = 3'd0;
	reg [15:0] displayed_mole_location;
	reg [47:0] lives_display;
	always@(posedge clock_27mhz) begin
		toggler <= (request_mole) ? ~toggler : toggler;
		current_mole_location <= (request_mole) ? mole_location : current_mole_location;
		case({upleft, up, upright, left, right, downleft, down, downright})
			8'b10000000: step_location <= "UL";
			8'b01000000: step_location <= "U ";
			8'b00100000: step_location <= "UR";
			8'b00010000: step_location <= "L ";
			8'b00001000: step_location <= "R ";
			8'b00000100: step_location <= "DL";
			8'b00000010: step_location <= "D ";
			8'b00000001: step_location <= "DR";
			default: step_location <= "??";
		endcase
		case(current_mole_location)
			3'd0: displayed_mole_location <= "UL";
			3'd1: displayed_mole_location <= "U ";
			3'd2: displayed_mole_location <= "UR";
			3'd3: displayed_mole_location <= "L ";
			3'd4: displayed_mole_location <= "R ";
			3'd5: displayed_mole_location <= "DL";
			3'd6: displayed_mole_location <= "D ";
			3'd7: displayed_mole_location <= "DR";
			default: displayed_mole_location <= "??";
		endcase
		case({whacked, misstep})
			2'b01: feedback <= "X";
			2'b10: feedback <= "$";
			default: feedback <= "?";
		endcase
		if (lives > 0)
			lives_display <= {"LIVE:", 8'h30 + lives};
		else if (lives == 0)
			lives_display <= "URDEAD";
		else
			lives_display <= "??????";
	end	
	
	// Display letter toggler value
	wire [127:0] string = {displayed_mole_location, "SCORE:", 8'h30+score, " ", lives_display};
	display_string debug_display(.reset(reset), .clock_27mhz(clock_27mhz),
											.string_data(string),
											.disp_blank(disp_blank),
											.disp_clock(disp_clock),
											.disp_data_out(disp_data_out), 
											.disp_rs(disp_rs), 
											.disp_ce_b(disp_ce_b),
											.disp_reset_b(disp_reset_b));

	assign led = {toggler, button_up, button2, button_left, button_right, button1, button_down, button0};
endmodule

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
//									GAME STATE FSM MODULE									 //
//																									 //
//////////////////////////////////////////////////////////////////////////////

module gameState(input clk,
						input misstep, whacked,
						input start,
						input reset,
						input request_mole,
						input expired,
						input [2:0] random_mole_location,
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
	if (reset) begin
		state <= 4'b0;
		temp_lives <= 2'd3;
		temp_score <= 8'd0;
	end else if (state == MOLE_MISSED)
		temp_lives <= temp_lives - 1;
	else if (state == MOLE_WHACKED)
		temp_score <= temp_score + 1;
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

assign start_timer = (state !== next_state);
assign timer_value = 4'd3;
assign display_state = state;
assign mole_location = random_mole_location;
assign lives = temp_lives;
assign score = temp_score;

endmodule

///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- 16 characer ASCII string display 
//
//
// File:   display_string.v
// Date:   24-Sep-05
// Author: I. Chuang <ichuang@mit.edu>
//
// Based on Nathan Ickes' hex display code
//
// 28-Nov-2006 CJT: fixed race condition between CE and RS
//
// This module drives the labkit hex displays and shows the value of 
// 8 ascii bytes as characters on the displays.
//
// Uses the Jae's ascii2dots module
//
// Inputs:
//
//   reset       - active high
//   clock_27mhz - the synchronous clock
//   string_data - 128 bits; each 8 bits gives an ASCII coded character
//   
// Outputs:
//
//    disp_*     - display lines used in the 6.111 labkit (rev 003 & 004)
//
///////////////////////////////////////////////////////////////////////////////

module display_string (
   input reset, clock_27mhz,    	// clock and reset (active high reset)
   input [16*8-1:0] string_data,	// 8 ascii bytes to display
   output disp_blank, disp_clock,   
   output reg disp_data_out, disp_rs, disp_ce_b, disp_reset_b
	);
   
   ////////////////////////////////////////////////////////////////////////////
   //
   // Display Clock
   //
   // Generate a 500kHz clock for driving the displays.
   //
   ////////////////////////////////////////////////////////////////////////////
   
   reg [4:0] count;
   reg [7:0] reset_count;
   reg clock;
   wire dreset;

   always @(posedge clock_27mhz)
     begin
	if (reset)
	  begin
	     count = 0;
	     clock = 0;
	  end
	else if (count == 26)
	  begin
	     clock = ~clock;
	     count = 5'h00;
	  end
	else
	  count = count+1;
     end
   
   always @(posedge clock_27mhz)
     if (reset)
       reset_count <= 100;
     else
       reset_count <= (reset_count==0) ? 0 : reset_count-1;

   assign dreset = (reset_count != 0);

   assign disp_clock = ~clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // Display State Machine
   //
   ////////////////////////////////////////////////////////////////////////////
      
   reg [7:0] state;		// FSM state
   reg [9:0] dot_index;		// index to current dot being clocked out
   reg [31:0] control;		// control register
   reg [3:0] char_index;	// index of current character
   wire [39:0] dots;		// dots for a single digit 
   reg [39:0] rdots;		// pipelined dots
   reg [7:0] ascii;		// ascii value of current character
   
   assign disp_blank = 1'b0; // low <= not blanked
   
   always @(posedge clock)
     if (dreset)
       begin
	  state <= 0;
	  dot_index <= 0;
	  control <= 32'h7F7F7F7F;
       end
     else
       casex (state)
	 8'h00:
	   begin
	      // Reset displays
	      disp_data_out <= 1'b0; 
	      disp_rs <= 1'b0; // dot register
	      disp_ce_b <= 1'b1;
	      disp_reset_b <= 1'b0;	     
	      dot_index <= 0;
	      state <= state+1;
	   end
	 
	 8'h01:
	   begin
	      // End reset
	      disp_reset_b <= 1'b1;
	      state <= state+1;
	   end
	 
	 8'h02:
	   begin
	      // Initialize dot register (set all dots to zero)
	      disp_ce_b <= 1'b0;
	      disp_data_out <= 1'b0; // dot_index[0];
	      if (dot_index == 639)
		state <= state+1;
	      else
		dot_index <= dot_index+1;
	   end
	 
	 8'h03:
	   begin
	      // Latch dot data
	      disp_ce_b <= 1'b1;
	      dot_index <= 31;		// re-purpose to init ctrl reg
	      state <= state+1;
	      disp_rs <= 1'b1; // Select the control register
	   end
	 
	 8'h04:
	   begin
	      // Setup the control register
	      disp_ce_b <= 1'b0;
	      disp_data_out <= control[31];
	      control <= {control[30:0], 1'b0};	// shift left
	      if (dot_index == 0)
		state <= state+1;
	      else
		dot_index <= dot_index-1;
	      char_index <= 15;		// set this up early for pipeline
	   end
	  
	 8'h05:
	   begin
	      // Latch the control register data / dot data
	      disp_ce_b <= 1'b1;
	      dot_index <= 39;		// init for single char
	      rdots <= dots;		// store dots of char 15
	      char_index <= 14;		// ready for next char
	      state <= state+1;
	      disp_rs <= 1'b0;	 		// Select the dot register
	   end
	 
	 8'h06:
	   begin
	      // Load the user's dot data into the dot reg, char by char
	      disp_ce_b <= 1'b0;
	      disp_data_out <= rdots[dot_index]; // dot data from msb
	      if (dot_index == 0)
	        if (char_index == 15)
	          state <= 5;			// all done, latch data
		else
		begin
		  char_index <= char_index - 1;	// goto next char
		  dot_index <= 39;
		  rdots <= dots;		// latch in next char dots
		end
	      else
		dot_index <= dot_index-1;	// else loop thru all dots 
	   end

       endcase

   // combinatorial logic to generate dots for current character
   // this mux, and the ascii table lookup, are slow, so note that
   // this is pipelined by one display clock stage in the always
   // loop above.

   always @(string_data or char_index)
     case (char_index)
       4'h0: ascii = string_data[7:0];
       4'h1: ascii = string_data[7+1*8:1*8];
       4'h2: ascii = string_data[7+2*8:2*8];
       4'h3: ascii = string_data[7+3*8:3*8];
       4'h4: ascii = string_data[7+4*8:4*8];
       4'h5: ascii = string_data[7+5*8:5*8];
       4'h6: ascii = string_data[7+6*8:6*8];
       4'h7: ascii = string_data[7+7*8:7*8];
       4'h8: ascii = string_data[7+8*8:8*8];
       4'h9: ascii = string_data[7+9*8:9*8];
       4'hA: ascii = string_data[7+10*8:10*8];
       4'hB: ascii = string_data[7+11*8:11*8];
       4'hC: ascii = string_data[7+12*8:12*8];
       4'hD: ascii = string_data[7+13*8:13*8];
       4'hE: ascii = string_data[7+14*8:14*8];
       4'hF: ascii = string_data[7+15*8:15*8];
     endcase

   ascii2dots a2d(ascii,dots);

endmodule

/////////////////////////////////////////////////////////////////////////////
// Display font dots generation from ASCII code

module ascii2dots(ascii_in,char_dots);

input [7:0] ascii_in;
output [39:0] char_dots;

  //////////////////////////////////////////////////////////////////////////
  // ROM: ASCII-->DOTS conversion
  //////////////////////////////////////////////////////////////////////////
	reg [39:0] char_dots;
	
	always @(ascii_in)
	 case(ascii_in)
		8'h20:	char_dots = 40'b00000000_00000000_00000000_00000000_00000000; //  32	' '
		8'h21:	char_dots = 40'b00000000_00000000_00101111_00000000_00000000; //  33	 !
		8'h22:	char_dots = 40'b00000000_00000111_00000000_00000111_00000000; //  34	"
		8'h23:	char_dots = 40'b00010100_00111110_00010100_00111110_00010100; //  35	 #
		8'h24:	char_dots = 40'b00000100_00101010_00111110_00101010_00010000; //  36	 $
		8'h25:	char_dots = 40'b00010011_00001000_00000100_00110010_00000000; //  37	 %
		8'h26:	char_dots = 40'b00010100_00101010_00010100_00100000_00000000; //  38	 &
		8'h27:	char_dots = 40'b00000000_00000000_00000111_00000000_00000000; //  39	'
		8'h28:	char_dots = 40'b00000000_00011110_00100001_00000000_00000000;//  40	 (
		8'h29:	char_dots = 40'b00000000_00100001_00011110_00000000_00000000; //  41	 )
		8'h2A:	char_dots = 40'b00000000_00101010_00011100_00101010_00000000; //  42	 *
		8'h2B:	char_dots = 40'b00001000_00001000_00111110_00001000_00001000; //  43	  +
		8'h2C:	char_dots = 40'b00000000_01000000_00110000_00010000_00000000; //  44	,
		8'h2D:	char_dots = 40'b00001000_00001000_00001000_00001000_00000000; //  45	 -
		8'h2E:	char_dots = 40'b00000000_00110000_00110000_00000000_00000000; //  46	 .
		8'h2F:	char_dots = 40'b00010000_00001000_00000100_00000010_00000000; //  47	 /
		8'h30:	char_dots = 40'b00000000_00011110_00100001_00011110_00000000; //  48	 0		--> 17
		8'h31:	char_dots = 40'b00000000_00100010_00111111_00100000_00000000; //  49	 1
		8'h32:	char_dots = 40'b00100010_00110001_00101001_00100110_00000000; //  50	 2
		8'h33:	char_dots = 40'b00010001_00100101_00100101_00011011_00000000; //  51	 3
		8'h34:	char_dots = 40'b00001100_00001010_00111111_00001000_00000000; //  52	 4
		8'h35:	char_dots = 40'b00010111_00100101_00100101_00011001_00000000; //  53	 5
		8'h36:	char_dots = 40'b00011110_00100101_00100101_00011000_00000000; //  54	 6
		8'h37:	char_dots = 40'b00000001_00110001_00001101_00000011_00000000; //  55	 7
		8'h38:	char_dots = 40'b00011010_00100101_00100101_00011010_00000000; //  56	 8
		8'h39:	char_dots = 40'b00000110_00101001_00101001_00011110_00000000; //  57	 9
		8'h3A:	char_dots = 40'b00000000_00110110_00110110_00000000_00000000; //  58	 :		--> 27
		8'h3B:	char_dots = 40'b01000000_00110110_00010110_00000000_00000000; //  59	 ;
		8'h3C:	char_dots = 40'b00000000_00001000_00010100_00100010_00000000; //  60	 <
		8'h3D:	char_dots = 40'b00010100_00010100_00010100_00010100_00000000; //  61	 =
		8'h3E:	char_dots = 40'b00000000_00100010_00010100_00001000_00000000; //  62	 >
		8'h3F:	char_dots = 40'b00000000_00000010_00101001_00000110_00000000; //  63	 ?
		8'h40:	char_dots = 40'b00011110_00100001_00101101_00001110_00000000; //  64	 @
		8'h41:	char_dots = 40'b00111110_00001001_00001001_00111110_00000000; //  65	 A		--> 34
		8'h42:	char_dots = 40'b00111111_00100101_00100101_00011010_00000000; //  66	 B
		8'h43:	char_dots = 40'b00011110_00100001_00100001_00010010_00000000; //  67	 C
		8'h44:	char_dots = 40'b00111111_00100001_00100001_00011110_00000000; //  68	 D
		8'h45:	char_dots = 40'b00111111_00100101_00100101_00100001_00000000; //  69	 E
		8'h46:	char_dots = 40'b00111111_00000101_00000101_00000001_00000000; //  70	 F
		8'h47:	char_dots = 40'b00011110_00100001_00101001_00111010_00000000; //  71	 G
		8'h48:	char_dots = 40'b00111111_00000100_00000100_00111111_00000000; //  72	 H
		8'h49:	char_dots = 40'b00000000_00100001_00111111_00100001_00000000; //  73	 I
		8'h4A:	char_dots = 40'b00010000_00100000_00100000_00011111_00000000; //  74	 J
		8'h4B:	char_dots = 40'b00111111_00001100_00010010_00100001_00000000; //  75	 K
		8'h4C:	char_dots = 40'b00111111_00100000_00100000_00100000_00000000; //  76	 L
		8'h4D:	char_dots = 40'b00111111_00000110_00000110_00111111_00000000; //  77	 M
		8'h4E:	char_dots = 40'b00111111_00000110_00011000_00111111_00000000; //  78	 N
		8'h4F:	char_dots = 40'b00011110_00100001_00100001_00011110_00000000; //  79	 O
		8'h50:	char_dots = 40'b00111111_00001001_00001001_00000110_00000000; //  80	 P
		8'h51:	char_dots = 40'b00011110_00110001_00100001_01011110_00000000; //  81	 Q
		8'h52:	char_dots = 40'b00111111_00001001_00011001_00100110_00000000; //  82	 R
		8'h53:	char_dots = 40'b00010010_00100101_00101001_00010010_00000000; //  83	 S
		8'h54:	char_dots = 40'b00000000_00000001_00111111_00000001_00000000; //  84	 T
		8'h55:	char_dots = 40'b00011111_00100000_00100000_00011111_00000000; //  85	 U
		8'h56:	char_dots = 40'b00001111_00110000_00110000_00001111_00000000; //  86	 V
		8'h57:	char_dots = 40'b00111111_00011000_00011000_00111111_00000000; //  87	 W
		8'h58:	char_dots = 40'b00110011_00001100_00001100_00110011_00000000; //  88	 X
		8'h59:	char_dots = 40'b00000000_00000111_00111000_00000111_00000000; //  89	 Y
		8'h5A:	char_dots = 40'b00110001_00101001_00100101_00100011_00000000; //  90	 Z		--> 59
		8'h5B:	char_dots = 40'b00000000_00111111_00100001_00100001_00000000; //  91	 [
		8'h5C:	char_dots = 40'b00000010_00000100_00001000_00010000_00000000; //  92	 \
		8'h5D:	char_dots = 40'b00000000_00100001_00100001_00111111_00000000; //  93	 ]
		8'h5E:	char_dots = 40'b00000000_00000010_00000001_00000010_00000000; //  94	 ^
		8'h5F:	char_dots = 40'b00100000_00100000_00100000_00100000_00000000; //  95	 _
		8'h60:	char_dots = 40'b00000000_00000001_00000010_00000000_00000000; //  96	 '
		8'h61:	char_dots = 40'b00011000_00100100_00010100_00111100_00000000; //  97	 a		--> 66
		8'h62:	char_dots = 40'b00111111_00100100_00100100_00011000_00000000; //  98	 b
		8'h63:	char_dots = 40'b00011000_00100100_00100100_00000000_00000000; //  99	 c
		8'h64:	char_dots = 40'b00011000_00100100_00100100_00111111_00000000; // 100	 d
		8'h65:	char_dots = 40'b00011000_00110100_00101100_00001000_00000000; // 101	 e
		8'h66:	char_dots = 40'b00001000_00111110_00001001_00000010_00000000; // 102	 f
		8'h67:	char_dots = 40'b00101000_01010100_01010100_01001100_00000000; // 103	 g
		8'h68:	char_dots = 40'b00111111_00000100_00000100_00111000_00000000; // 104	 h
		8'h69:	char_dots = 40'b00000000_00100100_00111101_00100000_00000000; // 105	 i
		8'h6A:	char_dots = 40'b00000000_00100000_01000000_00111101_00000000; // 106	 j
		8'h6B:	char_dots = 40'b00111111_00001000_00010100_00100000_00000000; // 107	 k
		8'h6C:	char_dots = 40'b00000000_00100001_00111111_00100000_00000000; // 108	 l
		8'h6D:	char_dots = 40'b00111100_00001000_00001100_00111000_00000000; // 109	 m
		8'h6E:	char_dots = 40'b00111100_00000100_00000100_00111000_00000000; // 110	 n
		8'h6F:	char_dots = 40'b00011000_00100100_00100100_00011000_00000000; // 111	 o
		8'h70:	char_dots = 40'b01111100_00100100_00100100_00011000_00000000; // 112	 p
		8'h71:	char_dots = 40'b00011000_00100100_00100100_01111100_00000000; // 113	 q
		8'h72:	char_dots = 40'b00111100_00000100_00000100_00001000_00000000; // 114	 r
		8'h73:	char_dots = 40'b00101000_00101100_00110100_00010100_00000000; // 115	 s
		8'h74:	char_dots = 40'b00000100_00011111_00100100_00100000_00000000; // 116	 t
		8'h75:	char_dots = 40'b00011100_00100000_00100000_00111100_00000000; // 117	 u
		8'h76:	char_dots = 40'b00000000_00011100_00100000_00011100_00000000; // 118	 v
		8'h77:	char_dots = 40'b00111100_00110000_00110000_00111100_00000000; // 119	 w
		8'h78:	char_dots = 40'b00100100_00011000_00011000_00100100_00000000; // 120	 x
		8'h79:	char_dots = 40'b00001100_01010000_00100000_00011100_00000000; // 121	 y
		8'h7A:	char_dots = 40'b00100100_00110100_00101100_00100100_00000000; // 122	 z		--> 91
		8'h7B:	char_dots = 40'b00000000_00000100_00011110_00100001_00000000; // 123	 {
		8'h7C:	char_dots = 40'b00000000_00000000_00111111_00000000_00000000; // 124	 |
		8'h7D:	char_dots = 40'b00000000_00100001_00011110_00000100_00000000; // 125	 }
		8'h7E:	char_dots = 40'b00000010_00000001_00000010_00000001_00000000; // 126	 ~		--> 95
		default:	char_dots = 40'b01000001_01000001_01000001_01000001_01000001;
    endcase

endmodule
