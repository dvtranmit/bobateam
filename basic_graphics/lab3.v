///////////////////////////////////////////////////////////////////////////////
//
// Pushbutton Debounce Module (video version - 24 bits)  
//
///////////////////////////////////////////////////////////////////////////////

module debounce (input reset, clock, noisy,
                 output reg clean);

   reg [19:0] count;
   reg new;

   always @(posedge clock)
     if (reset) begin new <= noisy; clean <= noisy; count <= 0; end
     else if (noisy != new) begin new <= noisy; count <= 0; end
     else if (count == 650000) clean <= new;
     else count <= count+1;

endmodule

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
// 2012-Sep-15: Converted to 24bit RGB
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

module lab3   (beep, audio_reset_b, ac97_sdata_out, ac97_sdata_in, ac97_synch,
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
   //lab3 assign led = 8'hFF;
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
   // lab3 : a simple pong game
   //
   ////////////////////////////////////////////////////////////////////////////

   // use FPGA's digital clock manager to produce a
   // 65MHz clock (actually 64.8MHz)
   wire clock_65mhz_unbuf,clock_65mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_65mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 10
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 24
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_65mhz),.I(clock_65mhz_unbuf));

   // power-on reset generation
   wire power_on_reset;    // remain high for first 16 clocks
   SRL16 reset_sr (.D(1'b0), .CLK(clock_65mhz), .Q(power_on_reset),
		   .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
   defparam reset_sr.INIT = 16'hFFFF;

   // ENTER button is user reset
   wire reset,user_reset;
   debounce db1(.reset(power_on_reset),.clock(clock_65mhz),.noisy(~button_enter),.clean(user_reset));
   assign reset = user_reset | power_on_reset;
   
   // UP and DOWN buttons for pong paddle
   wire up,down, right, left;
   debounce db2(.reset(reset),.clock(clock_65mhz),.noisy(~button_up),.clean(up));
   debounce db3(.reset(reset),.clock(clock_65mhz),.noisy(~button_down),.clean(down));
	debounce db4(.reset(reset),.clock(clock_65mhz),.noisy(~button_right),.clean(right));
   debounce db5(.reset(reset),.clock(clock_65mhz),.noisy(~button_left),.clean(left));

   // generate basic XVGA video signals
   wire [10:0] hcount1;
   wire [9:0]  vcount1;
	wire [10:0] hcount2;
	wire [9:0] vcount2;
	wire [10:0] hcount3;
   wire [9:0]  vcount3;
	wire [10:0] hcount4;
	wire [9:0] vcount4;
	wire [10:0] hcount5;
   wire [9:0]  vcount5;
	wire [10:0] hcount6;
	wire [9:0] vcount6;
	wire [10:0] hcount7;
   wire [9:0]  vcount7;
	wire [10:0] hcount8;
	wire [9:0] vcount8;
	wire hsync1,vsync1,blank1;
	wire hsync2,vsync2,blank2;
	wire hsync3,vsync3,blank3;
	wire hsync4,vsync4,blank4;
	wire hsync5,vsync5,blank5;
	wire hsync6,vsync6,blank6;
	wire hsync7,vsync7,blank7;
	wire hsync8,vsync8,blank8;
	
   xvga xvga1(.vclock(clock_65mhz),.hcount(hcount1),.vcount(vcount1),
              .hsync(hsync1),.vsync(vsync1),.blank(blank1));
	xvga xvga2(.vclock(clock_65mhz),.hcount(hcount2),.vcount(vcount2),
              .hsync(hsync2),.vsync(vsync2),.blank(blank2));
	xvga xvga3(.vclock(clock_65mhz),.hcount(hcount3),.vcount(vcount3),
              .hsync(hsync3),.vsync(vsync3),.blank(blank3));
	xvga xvga4(.vclock(clock_65mhz),.hcount(hcount4),.vcount(vcount4),
              .hsync(hsync4),.vsync(vsync4),.blank(blank4));
	xvga xvga5(.vclock(clock_65mhz),.hcount(hcount5),.vcount(vcount5),
              .hsync(hsync5),.vsync(vsync5),.blank(blank5));
	xvga xvga6(.vclock(clock_65mhz),.hcount(hcount6),.vcount(vcount6),
              .hsync(hsync6),.vsync(vsync6),.blank(blank6));
	xvga xvga7(.vclock(clock_65mhz),.hcount(hcount7),.vcount(vcount7),
              .hsync(hsync7),.vsync(vsync7),.blank(blank7));
	xvga xvga8(.vclock(clock_65mhz),.hcount(hcount8),.vcount(vcount8),
              .hsync(hsync8),.vsync(vsync8),.blank(blank8));

   // feed XVGA signals
   wire [23:0] pixel;
	wire [23:0] mole1_pixel;
	wire [23:0] mole2_pixel;
	wire [23:0] mole3_pixel;
	wire [23:0] mole4_pixel;
	wire [23:0] mole5_pixel;
	wire [23:0] mole6_pixel;
	wire [23:0] mole7_pixel;
	wire [23:0] mole8_pixel;
	
   wire phsync,pvsync,pblank;

	//wire [10:0] x1 = 65;
	//wire [9:0] y1 = 0;
	wire [10:0] x2 = 406;
	wire [9:0] y2 = 0;
	wire [10:0] x3 = 747;
	wire [9:0] y3 = 0;
	wire [10:0] x4 = 65;
	wire [9:0] y4 = 256;
	wire [10:0] x5 = 747;
	wire [9:0] y5 = 256;
	wire [10:0] x6 = 65;
	wire [9:0] y6 = 512;
	wire [10:0] x7 = 406;
	wire [9:0] y7 = 512;
	wire [10:0] x8 = 747;
	wire [9:0] y8 = 512;

	//happymole #(.WIDTH(207),.HEIGHT(128))
			//mole1(.pixel_clk(clock_65mhz),.x(x1),.hcount(hcount1),.y(y1),.vcount(vcount1),.pixel(mole1_pixel));
	normalmole #(.WIDTH(212),.HEIGHT(256))
			mole2(.pixel_clk(clock_65mhz),.x(x2),.hcount(hcount2),.y(y2),.vcount(vcount2),.pixel(mole2_pixel));
	deadmole #(.WIDTH(191),.HEIGHT(256))
			mole3(.pixel_clk(clock_65mhz),.x(x3),.hcount(hcount3),.y(y3),.vcount(vcount3),.pixel(mole3_pixel));
	deadmole #(.WIDTH(191),.HEIGHT(256))
			mole4(.pixel_clk(clock_65mhz),.x(x4),.hcount(hcount4),.y(y4),.vcount(vcount4),.pixel(mole4_pixel));
	normalmole #(.WIDTH(212),.HEIGHT(256))
			mole5(.pixel_clk(clock_65mhz),.x(x5),.hcount(hcount5),.y(y5),.vcount(vcount5),.pixel(mole5_pixel));
	normalmole #(.WIDTH(212),.HEIGHT(256))
			mole6(.pixel_clk(clock_65mhz),.x(x6),.hcount(hcount6),.y(y6),.vcount(vcount6),.pixel(mole6_pixel));
	//happymole #(.WIDTH(207),.HEIGHT(128))
			//mole7(.pixel_clk(clock_65mhz),.x(x7),.hcount(hcount7),.y(y7),.vcount(vcount7),.pixel(mole7_pixel));
	//normalmole #(.WIDTH(212),.HEIGHT(256))
			//mole8(.pixel_clk(clock_65mhz),.x(x8),.hcount(hcount8),.y(y8),.vcount(vcount8),.pixel(mole8_pixel));

   reg [23:0] rgb;
   wire border = (hcount1==0 | hcount1==1023 | vcount1==0 | vcount1==767);
   wire [23:0] whack_pixel;
	wire [23:0] start_pixel;
	wire [23:0] gameover_pixel;
	wire [10:0] x_whack = 1;
	wire [9:0] y_whack = 156;
	wire [10:0] x_start = 1;
	wire [9:0] y_start = 600;
	//assign pixel = mole1_pixel | mole2_pixel | mole3_pixel | mole4_pixel | mole5_pixel | mole6_pixel | mole7_pixel | mole8_pixel;
	//assign pixel = mole1_pixel;
	//whackamole #(.WIDTH(1024),.HEIGHT(119))
			//whack1(.pixel_clk(clock_65mhz),.x(x_whack),.hcount(hcount8),.y(y_whack),.vcount(vcount8),.pixel(whack_pixel));
	//startscreen #(.WIDTH(1024),.HEIGHT(119))
			//start1(.pixel_clk(clock_65mhz),.x(x_start),.hcount(hcount7),.y(y_start),.vcount(vcount7),.pixel(start_pixel));
	//gameover #(.WIDTH(1024),.HEIGHT(144))
			//end1(.pixel_clk(clock_65mhz),.x(5),.hcount(hcount1),.y(400),.vcount(vcount1),.pixel(gameover_pixel));
	//assign pixel = whack_pixel | start_pixel | gameover_pixel;
   reg b,hs,vs;
	reg [9:0] height = 256;
	reg [9:0] y_change = 255;
	wire [10:0] x1 = 65;
	reg [9:0] y1 = 255;
	wire mole_clock;
	reg shrink = 0;
	happymole #(.WIDTH(207),.HEIGHT(256))
			mole1(.pixel_clk(clock_65mhz),.height(height),.x(x1),.hcount(hcount1),.y(y_change),.vcount(vcount1),.pixel(mole1_pixel));
	divider divider1(.clk(clock_27mhz),.mole_popup_clock(mole_clock));
	always @ (posedge mole_clock) begin
		if (shrink == 0) begin
			if (y_change < 256 && y_change > 0) begin
				y_change <= y_change - 1;
			end

			else if (y_change == 0) begin
				y_change <= y_change + 1;
				shrink <= 1;
			end
		end
		else if (shrink == 1) begin
			if (y_change < 256 && y_change > 0) begin
				y_change <= y_change + 1;
			end
			else if (y_change == 256) begin
				y_change <= y_change - 1;
				shrink <= 0;
			end
		end
	end
	
	wire [23:0] text_pixel;
	wire [23:0] whacktext;
	wire [23:0] amoletext;
	wire [23:0] pressup;
	wire [23:0] gameovertext, livestext, scoretext;
	wire [23:0] d0,d1,d2,d3,d4,d5,d6,d7,d8,d9;
	whack_text_display whack1(.x(60),.hcount(hcount1),.y(100),.vcount(vcount1),.p_out(whacktext));
	amole_text_display amole1(.x(476),.hcount(hcount1),.y(100),.vcount(vcount1),.p_out(amoletext));
	pressuptostart_text_display pressup1(.x(200),.hcount(hcount1),.y(500),.vcount(vcount1),.p_out(pressup));
	gameover_text_display gameover1(.x(100),.hcount(hcount1),.y(300),.vcount(vcount1),.p_out(gameovertext));
	lives_text_display lives1(.x(100),.hcount(hcount1),.y(200),.vcount(vcount1),.p_out(livestext));
	score_text_display score1(.x(700),.hcount(hcount1),.y(200),.vcount(vcount1),.p_out(scoretext));
	
	digit0 n0(.x(0),.hcount(hcount1),.y(400),.vcount(vcount1),.p_out(d0));
	digit1 n1(.x(100),.hcount(hcount1),.y(400),.vcount(vcount1),.p_out(d1));
	digit2 n2(.x(200),.hcount(hcount1),.y(400),.vcount(vcount1),.p_out(d2));
	digit3 n3(.x(300),.hcount(hcount1),.y(400),.vcount(vcount1),.p_out(d3));
	digit4 n4(.x(400),.hcount(hcount1),.y(400),.vcount(vcount1),.p_out(d4));
	digit5 n5(.x(500),.hcount(hcount1),.y(400),.vcount(vcount1),.p_out(d5));
	digit6 n6(.x(600),.hcount(hcount1),.y(400),.vcount(vcount1),.p_out(d6));
	digit7 n7(.x(700),.hcount(hcount1),.y(400),.vcount(vcount1),.p_out(d7));
	digit8 n8(.x(800),.hcount(hcount1),.y(400),.vcount(vcount1),.p_out(d8));
	digit9 n9(.x(900),.hcount(hcount1),.y(400),.vcount(vcount1),.p_out(d9));
	
	assign text_pixel = whacktext | amoletext | pressup | d0|d1|d2|d3|d4|d5|d6|d7|d8|d9 | gameovertext |livestext|scoretext;
   always @(posedge clock_65mhz) begin
		hs <= hsync1;
		vs <= vsync1;
		b <= blank1;
		rgb <= text_pixel; 
   end

   // VGA Output.  In order to meet the setup and hold times of the
   // AD7125, we send it ~clock_65mhz.
   assign vga_out_red = rgb[23:16];
   assign vga_out_green = rgb[15:8];
   assign vga_out_blue = rgb[7:0];
   assign vga_out_sync_b = 1'b1;    // not used
   assign vga_out_blank_b = ~b;
   assign vga_out_pixel_clock = ~clock_65mhz;
   assign vga_out_hsync = hs;
   assign vga_out_vsync = vs;
   
   assign led = ~{3'b000,up,down,reset,switch[1:0]};
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// xvga: Generate XVGA display signals (1024 x 768 @ 60Hz)
//
////////////////////////////////////////////////////////////////////////////////

module xvga(input vclock,
            output reg [10:0] hcount,    // pixel number on current line
            output reg [9:0] vcount,	 // line number
            output reg vsync,hsync,blank);

   // horizontal: 1344 pixels total
   // display 1024 pixels per line
   reg hblank,vblank;
   wire hsyncon,hsyncoff,hreset,hblankon;
   assign hblankon = (hcount == 1023);    
   assign hsyncon = (hcount == 1047);
   assign hsyncoff = (hcount == 1183);
   assign hreset = (hcount == 1343);

   // vertical: 806 lines total
   // display 768 lines
   wire vsyncon,vsyncoff,vreset,vblankon;
   assign vblankon = hreset & (vcount == 767);    
   assign vsyncon = hreset & (vcount == 776);
   assign vsyncoff = hreset & (vcount == 782);
   assign vreset = hreset & (vcount == 805);

   // sync and blanking
   wire next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;/////	
   always @(posedge vclock) begin
      hcount <= hreset ? 0 : hcount + 1;
      hblank <= next_hblank;
      hsync <= hsyncon ? 0 : hsyncoff ? 1 : hsync;  // active low

      vcount <= hreset ? (vreset ? 0 : vcount + 1) : vcount;
      vblank <= next_vblank;
      vsync <= vsyncon ? 0 : vsyncoff ? 1 : vsync;  // active low

      blank <= next_vblank | (next_hblank & ~hreset);
   end
endmodule

///////////////////////////////////////////////////////////
///// MOLE MODULES 																
///////////////////////////////////////////////////////////
module normalmole
	#(parameter WIDTH = 212, HEIGHT = 256)
	(input pixel_clk,
    input [10:0] x, hcount,
    input [9:0] y, vcount,
    output reg [23:0] pixel
    );
	wire [15:0] image_addr;
	wire [3:0] image_bits, red_mapped, green_mapped, blue_mapped;
	always @ (posedge pixel_clk) begin
		if ((hcount >= x && hcount < (x + WIDTH)) && (vcount >= y && vcount < (y + HEIGHT)))
			pixel <= {red_mapped,4'b0, green_mapped,4'b0, blue_mapped,4'b0};
		else
			pixel <= 0;
	end
	assign image_addr = (hcount - x) + (vcount - y) * WIDTH;
	tiger_image_rom rom1(.clka(pixel_clk),.addra(image_addr),.douta(image_bits));
	tiger_red_rom rcm (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
	tiger_green_rom gcm (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
	tiger_blue_rom bcm (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));	
endmodule

module deadmole
	#(parameter WIDTH = 191, HEIGHT = 256)
	(input pixel_clk,
    input [10:0] x, hcount,
    input [9:0] y, vcount,
    output reg [23:0] pixel
    );
	wire [15:0] image_addr;
	wire [3:0] image_bits, red_mapped, green_mapped, blue_mapped;
	always @ (posedge pixel_clk) begin
		if ((hcount >= x && hcount < (x + WIDTH)) && (vcount >= y && vcount < (y + HEIGHT)))
			pixel <= {red_mapped,4'b0, green_mapped,4'b0, blue_mapped,4'b0};
		else
			pixel <= 0;
	end
	assign image_addr = (hcount - x) + (vcount - y) * WIDTH;
	dead_image_rom rom1_dead(.clka(pixel_clk),.addra(image_addr),.douta(image_bits));
	dead_red_rom rcm_dead (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
	dead_green_rom gcm_dead (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
	dead_blue_rom bcm_dead (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));	
endmodule

module happymole
	#(parameter WIDTH = 207, HEIGHT = 256)
	(input pixel_clk,
    input [10:0] x, hcount,
    input [9:0] y, vcount,
	 input [9:0] height,
    output reg [23:0] pixel
    );
	wire [15:0] image_addr;
	wire [3:0] image_bits, red_mapped, green_mapped, blue_mapped;
	always @ (posedge pixel_clk) begin
		if ((hcount >= x && hcount < (x + WIDTH)) && (vcount >= y && vcount < HEIGHT))
			pixel <= {red_mapped,4'b0, green_mapped,4'b0, blue_mapped,4'b0};
		else
			pixel <= 0;
	end
	assign image_addr = (hcount - x) + (vcount - y) * WIDTH;
	happy_image_rom rom1_happy(.clka(pixel_clk),.addra(image_addr),.douta(image_bits));
	happy_red_rom rcm_happy (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
	happy_green_rom gcm_happy (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
	happy_blue_rom bcm_happy (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));	
endmodule

module whackamole
	#(parameter WIDTH = 1020, HEIGHT = 119)
	(input pixel_clk,
    input [10:0] x, hcount,
    input [9:0] y, vcount,
    output reg [23:0] pixel
    );
	wire [16:0] image_addr;
	wire [3:0] image_bits, red_mapped, green_mapped, blue_mapped;
	always @ (posedge pixel_clk) begin
		if ((hcount >= x && hcount < (x + WIDTH)) && (vcount >= y && vcount < (y + HEIGHT)))
			pixel <= {red_mapped,4'b0, green_mapped,4'b0, blue_mapped,4'b0};
		else
			pixel <= 0;
	end
	assign image_addr = (hcount - x) + (vcount - y) * WIDTH;
	whackrom rom1_whack(.clka(pixel_clk),.addra(image_addr),.douta(image_bits));
	whack_red_rom rcm_whack (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
	whack_green_rom gcm_whack (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
	whack_blue_rom bcm_whack (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));	
endmodule

module startscreen
	#(parameter WIDTH = 1020, HEIGHT = 119)
	(input pixel_clk,
    input [10:0] x, hcount,
    input [9:0] y, vcount,
    output reg [23:0] pixel
    );
	wire [16:0] image_addr;
	wire [3:0] image_bits, red_mapped, green_mapped, blue_mapped;
	always @ (posedge pixel_clk) begin
		if ((hcount >= x && hcount < (x + WIDTH)) && (vcount >= y && vcount < (y + HEIGHT)))
			pixel <= {red_mapped,4'b0, green_mapped,4'b0, blue_mapped,4'b0};
		else
			pixel <= 0;
	end
	assign image_addr = (hcount - x) + (vcount - y) * WIDTH;
	startrom rom1_start(.clka(pixel_clk),.addra(image_addr),.douta(image_bits));
	start_red_rom rcm_start (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
	start_green_rom gcm_start (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
	start_blue_rom bcm_start (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));	
endmodule

module gameover
	#(parameter WIDTH = 1020, HEIGHT = 144)
	(input pixel_clk,
    input [10:0] x, hcount,
    input [9:0] y, vcount,
    output reg [23:0] pixel
    );
	wire [16:0] image_addr;
	wire [3:0] image_bits, red_mapped, green_mapped, blue_mapped;
	always @ (posedge pixel_clk) begin
		if ((hcount >= x && hcount < (x + WIDTH)) && (vcount >= y && vcount < (y + HEIGHT)))
			pixel <= {red_mapped,4'b0, green_mapped,4'b0, blue_mapped,4'b0};
		else
			pixel <= 0;
	end
	assign image_addr = (hcount - x) + (vcount - y) * WIDTH;
	gameoverrom rom1_end(.clka(pixel_clk),.addra(image_addr),.douta(image_bits));
	gameover_red_rom rcm_end (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
	gameover_green_rom gcm_end (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
	gameover_blue_rom bcm_end (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));	
endmodule

module divider(input clk, output reg mole_popup_clock);
	reg [26:0] count = 0;
	always @ (posedge clk) begin
		mole_popup_clock <= 0;
		count <= count + 1;
		if (count == 25'd33750) begin
			mole_popup_clock <= 1;
			count <= 0;
		end
	end
endmodule 


module whack_text_display(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 4; //power of two scaling factor 
	parameter HEIGHT = 4;
	parameter WIDTH = 26;
	

	reg [23:0] pixel;
	reg [7:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = CLEAR; // SPACE
			1: pixel = WHITE;
			2: pixel = CLEAR;
			3: pixel = CLEAR;
			4: pixel = CLEAR;
			5: pixel = WHITE; // W
			6: pixel = CLEAR; // SPACE
			7: pixel = WHITE; 
			8: pixel = CLEAR;
			9: pixel = CLEAR;
			10: pixel = WHITE; // H
			11: pixel = CLEAR; // SPACE
			12: pixel = CLEAR;
			13: pixel = WHITE;
			14: pixel = WHITE;
			15: pixel = CLEAR; // A
			16: pixel = CLEAR; // SPACE
			17: pixel = CLEAR;
			18: pixel = WHITE; 
			19: pixel = WHITE;
			20: pixel = WHITE; // C
			21: pixel = CLEAR; // SPACE
			22: pixel = WHITE;
			23: pixel = CLEAR;
			24: pixel = WHITE;
			25: pixel = WHITE; // K
			 
			26: pixel = CLEAR; // SPACE
			27: pixel = WHITE; 
			28: pixel = CLEAR;
			29: pixel = CLEAR;
			30: pixel = CLEAR;
			31: pixel = WHITE; // W 
			32: pixel = CLEAR; // SPACE
			33: pixel = WHITE;
			34: pixel = WHITE;
			35: pixel = WHITE;
			36: pixel = WHITE; // H
			37: pixel = CLEAR; // SPACE
			38: pixel = WHITE;
			39: pixel = CLEAR;
			40: pixel = CLEAR;
			41: pixel = WHITE; // A
			42: pixel = CLEAR; // SPACE
			43: pixel = WHITE;
			44: pixel = CLEAR;
			45: pixel = CLEAR;
			46: pixel = CLEAR; // C
			47: pixel = CLEAR; // SPACE
			48: pixel = WHITE;
			49: pixel = WHITE;
			50: pixel = CLEAR;
			51: pixel = CLEAR; // K
			
			52: pixel = CLEAR; // SPACE
			53: pixel = WHITE;
			54: pixel = CLEAR;
			55: pixel = WHITE;
			56: pixel = CLEAR;
			57: pixel = WHITE; // W
			58: pixel = CLEAR; // SPACE
			59: pixel = WHITE;
			60: pixel = CLEAR;
			61: pixel = CLEAR; 
			62: pixel = WHITE; // H
			63: pixel = CLEAR; // SPACE
			64: pixel = WHITE;
			65: pixel = WHITE;
			66: pixel = WHITE;
			67: pixel = WHITE; // A
			68: pixel = CLEAR; // SPACE
			69: pixel = WHITE;
			70: pixel = CLEAR;
			71: pixel = CLEAR;
			72: pixel = CLEAR; // C
			73: pixel = CLEAR; // SPACE
			74: pixel = WHITE;
			75: pixel = WHITE;
			76: pixel = CLEAR;
			77: pixel = CLEAR; // K

			78: pixel = CLEAR; // SPACE
			79: pixel = CLEAR;
			80: pixel = WHITE;
			81: pixel = CLEAR; 
			82: pixel = WHITE;
			83: pixel = CLEAR; // W
			84: pixel = CLEAR; // SPACE
			85: pixel = WHITE;
			86: pixel = CLEAR;
			87: pixel = CLEAR;
			88: pixel = WHITE; // H
			89: pixel = CLEAR; // SPACE
			90: pixel = WHITE;
			91: pixel = CLEAR;
			92: pixel = CLEAR;
			93: pixel = WHITE; // A
			94: pixel = CLEAR; // SPACE
			95: pixel = CLEAR;
			96: pixel = WHITE;
			97: pixel = WHITE;
			98: pixel = WHITE; // C
			99: pixel = CLEAR; // SPACE
			100: pixel = WHITE;
			101: pixel = CLEAR;
			102: pixel = WHITE;
			103: pixel = WHITE; // K
			
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module amole_text_display(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 4; //power of two scaling factor 
	parameter HEIGHT = 4;
	parameter WIDTH = 28;
	

	reg [23:0] pixel;
	reg [7:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = CLEAR; 
			1: pixel = CLEAR; // SPACE
			2: pixel = CLEAR;
			3: pixel = WHITE;
			4: pixel = WHITE;
			5: pixel = CLEAR; // A
			6: pixel = CLEAR; 
			7: pixel = CLEAR; // SPACE
			8: pixel = WHITE;
			9: pixel = CLEAR;
			10: pixel = CLEAR; 
			11: pixel = CLEAR; 
			12: pixel = WHITE; // M
			13: pixel = CLEAR; // SPACE
			14: pixel = CLEAR;
			15: pixel = WHITE; 
			16: pixel = WHITE; 
			17: pixel = CLEAR; // O
			18: pixel = CLEAR; // SPACE 
			19: pixel = WHITE; 
			20: pixel = CLEAR; 
			21: pixel = CLEAR; 
			22: pixel = CLEAR; // L
			23: pixel = CLEAR; // SPACE
			24: pixel = WHITE;
			25: pixel = WHITE;  
			26: pixel = WHITE; 
			27: pixel = WHITE; // E
			
			28: pixel = CLEAR;
			29: pixel = CLEAR; // SPACE
			30: pixel = WHITE; 
			31: pixel = CLEAR;  
			32: pixel = CLEAR; 
			33: pixel = WHITE; // A
			34: pixel = CLEAR;
			35: pixel = CLEAR; // SPACE
			36: pixel = WHITE; 
			37: pixel = WHITE; 
			38: pixel = CLEAR;
			39: pixel = WHITE;
			40: pixel = WHITE; // M
			41: pixel = CLEAR; // SPACE
			42: pixel = WHITE; 
			43: pixel = CLEAR;
			44: pixel = CLEAR;
			45: pixel = WHITE; // O
			46: pixel = CLEAR; // SPACE
			47: pixel = WHITE; 
			48: pixel = CLEAR;
			49: pixel = CLEAR;
			50: pixel = CLEAR; // L
			51: pixel = CLEAR; // SPACE
			52: pixel = WHITE; 
			53: pixel = WHITE;
			54: pixel = WHITE;
			55: pixel = CLEAR; // E
			
			56: pixel = CLEAR;
			57: pixel = CLEAR; // SPACE
			58: pixel = WHITE; 
			59: pixel = WHITE;
			60: pixel = WHITE;
			61: pixel = WHITE; // A 
			62: pixel = CLEAR; 
			63: pixel = CLEAR; // SPACE
			64: pixel = WHITE;
			65: pixel = CLEAR;
			66: pixel = WHITE;
			67: pixel = CLEAR; 
			68: pixel = WHITE; // M
			69: pixel = CLEAR; // SPACE
			70: pixel = WHITE;
			71: pixel = CLEAR;
			72: pixel = CLEAR; 
			73: pixel = WHITE; // O
			74: pixel = CLEAR; // SPACE
			75: pixel = WHITE; 
			76: pixel = CLEAR;
			77: pixel = CLEAR; 
			78: pixel = CLEAR; // L
			79: pixel = CLEAR; // SPACE
			80: pixel = WHITE; 
			81: pixel = CLEAR; 
			82: pixel = CLEAR;
			83: pixel = CLEAR; // E
			
			84: pixel = CLEAR; 
			85: pixel = CLEAR; // SPACE
			86: pixel = WHITE;
			87: pixel = CLEAR;
			88: pixel = CLEAR; 
			89: pixel = WHITE; // A
			90: pixel = CLEAR;
			91: pixel = CLEAR; // SPACE
			92: pixel = WHITE;
			93: pixel = CLEAR; 
			94: pixel = CLEAR; 
			95: pixel = CLEAR;
			96: pixel = WHITE; // M
			97: pixel = CLEAR; // SPACE
			98: pixel = CLEAR; 
			99: pixel = WHITE; 
			100: pixel = WHITE;
			101: pixel = CLEAR; // O
			102: pixel = CLEAR; // SPACE
			103: pixel = WHITE; 
			104: pixel = WHITE;
			105: pixel = WHITE; 
			106: pixel = WHITE; // L
			107: pixel = CLEAR; // SPACE
			108: pixel = WHITE;
			109: pixel = WHITE; 
			110: pixel = WHITE;
			111: pixel = WHITE; // E
			
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module pressuptostart_text_display(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 76;
	

	reg [23:0] pixel;
	reg [8:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = WHITE; 
			1: pixel = WHITE; 
			2: pixel = WHITE;
			3: pixel = CLEAR; // P
			4: pixel = CLEAR; // SPACE
			5: pixel = WHITE; 
			6: pixel = WHITE; 
			7: pixel = WHITE; 
			8: pixel = CLEAR; // R
			9: pixel = CLEAR; // SPACE
			10: pixel = WHITE; 
			11: pixel = WHITE; 
			12: pixel = WHITE; 
			13: pixel = WHITE; // E
			14: pixel = CLEAR; // SPACE
			15: pixel = CLEAR; 
			16: pixel = WHITE; 
			17: pixel = WHITE; 
			18: pixel = WHITE; // S 
			19: pixel = CLEAR; // SPACE 
			20: pixel = CLEAR; 
			21: pixel = WHITE; 
			22: pixel = WHITE; 
			23: pixel = WHITE; // S
			24: pixel = CLEAR; // SPACE
			25: pixel = CLEAR;  
			26: pixel = CLEAR; 
			27: pixel = CLEAR; 
			28: pixel = CLEAR; // SPACE
			29: pixel = WHITE; 
			30: pixel = CLEAR; 
			31: pixel = CLEAR;  
			32: pixel = WHITE; // U 
			33: pixel = CLEAR; // SPACE
			34: pixel = WHITE;
			35: pixel = WHITE; 
			36: pixel = WHITE; 
			37: pixel = CLEAR; // P 
			38: pixel = CLEAR;
			39: pixel = CLEAR;
			40: pixel = CLEAR; 
			41: pixel = CLEAR; // SPACE
			42: pixel = WHITE; 
			43: pixel = WHITE;
			44: pixel = WHITE; // T
			45: pixel = CLEAR; // SPACE 
			46: pixel = CLEAR; 
			47: pixel = WHITE; 
			48: pixel = WHITE;
			49: pixel = CLEAR; // O
			50: pixel = CLEAR; 
			51: pixel = CLEAR; 
			52: pixel = CLEAR; 
			53: pixel = CLEAR; // SPACE
			54: pixel = CLEAR;
			55: pixel = WHITE; 
			56: pixel = WHITE;
			57: pixel = WHITE; // S
			58: pixel = CLEAR; // SPACE 
			59: pixel = WHITE;
			60: pixel = WHITE;
			61: pixel = WHITE; // T 
			62: pixel = CLEAR; // SPACE
			63: pixel = CLEAR; 
			64: pixel = WHITE;
			65: pixel = WHITE;
			66: pixel = CLEAR; // A
			67: pixel = CLEAR; // SPACE
			68: pixel = WHITE; 
			69: pixel = WHITE; 
			70: pixel = WHITE; 
			71: pixel = CLEAR; // R
			72: pixel = CLEAR; // SPACE
			73: pixel = WHITE; 
			74: pixel = WHITE; 
			75: pixel = WHITE; // T
			
			76: pixel = WHITE; 
			77: pixel = CLEAR; 
			78: pixel = CLEAR;
			79: pixel = WHITE; // P
			80: pixel = CLEAR; // SPACE
			81: pixel = WHITE; 
			82: pixel = CLEAR; 
			83: pixel = CLEAR; 
			84: pixel = WHITE; // R
			85: pixel = CLEAR; // SPACE
			86: pixel = WHITE; 
			87: pixel = CLEAR; 
			88: pixel = CLEAR; 
			89: pixel = CLEAR; // E
			90: pixel = CLEAR; // SPACE
			91: pixel = WHITE; 
			92: pixel = CLEAR; 
			93: pixel = CLEAR; 
			94: pixel = CLEAR; // S 
			95: pixel = CLEAR; // SPACE 
			96: pixel = WHITE; 
			97: pixel = CLEAR; 
			98: pixel = CLEAR; 
			99: pixel = CLEAR; // S
			100: pixel = CLEAR; // SPACE
			101: pixel = CLEAR;  
			102: pixel = CLEAR; 
			103: pixel = CLEAR; 
			104: pixel = CLEAR; // SPACE
			105: pixel = WHITE; 
			106: pixel = CLEAR; 
			107: pixel = CLEAR;  
			108: pixel = WHITE; // U 
			109: pixel = CLEAR; // SPACE
			110: pixel = WHITE;
			111: pixel = CLEAR; 
			112: pixel = CLEAR; 
			113: pixel = WHITE; // P 
			114: pixel = CLEAR;
			115: pixel = CLEAR;
			116: pixel = CLEAR; 
			117: pixel = CLEAR; // SPACE
			118: pixel = CLEAR; 
			119: pixel = WHITE;
			120: pixel = CLEAR; // T
			121: pixel = CLEAR; // SPACE 
			122: pixel = WHITE; 
			123: pixel = CLEAR; 
			124: pixel = CLEAR;
			125: pixel = WHITE; // O
			126: pixel = CLEAR; 
			127: pixel = CLEAR; 
			128: pixel = CLEAR; 
			129: pixel = CLEAR; // SPACE
			130: pixel = WHITE;
			131: pixel = CLEAR; 
			132: pixel = CLEAR;
			133: pixel = CLEAR; // S
			134: pixel = CLEAR; // SPACE 
			135: pixel = CLEAR;
			136: pixel = WHITE;
			137: pixel = CLEAR; // T 
			138: pixel = CLEAR; // SPACE
			139: pixel = WHITE; 
			140: pixel = CLEAR;
			141: pixel = CLEAR;
			142: pixel = WHITE; // A
			143: pixel = CLEAR; // SPACE
			144: pixel = WHITE; 
			145: pixel = CLEAR; 
			146: pixel = CLEAR; 
			147: pixel = WHITE; // R
			148: pixel = CLEAR; // SPACE
			149: pixel = CLEAR; 
			150: pixel = WHITE; 
			151: pixel = CLEAR; // T
			
			152: pixel = WHITE; 
			153: pixel = WHITE; 
			154: pixel = WHITE;
			155: pixel = CLEAR; // P
			156: pixel = CLEAR; // SPACE
			157: pixel = WHITE; 
			158: pixel = WHITE; 
			159: pixel = WHITE; 
			160: pixel = CLEAR; // R
			161: pixel = CLEAR; // SPACE
			162: pixel = WHITE; 
			163: pixel = WHITE; 
			164: pixel = WHITE; 
			165: pixel = CLEAR; // E
			166: pixel = CLEAR; // SPACE
			167: pixel = CLEAR; 
			168: pixel = WHITE; 
			169: pixel = WHITE; 
			170: pixel = CLEAR; // S 
			171: pixel = CLEAR; // SPACE 
			172: pixel = CLEAR; 
			173: pixel = WHITE; 
			174: pixel = WHITE; 
			175: pixel = CLEAR; // S
			176: pixel = CLEAR; // SPACE
			177: pixel = CLEAR;  
			178: pixel = CLEAR; 
			179: pixel = CLEAR; 
			180: pixel = CLEAR; // SPACE
			181: pixel = WHITE; 
			182: pixel = CLEAR; 
			183: pixel = CLEAR;  
			184: pixel = WHITE; // U 
			185: pixel = CLEAR; // SPACE
			186: pixel = WHITE;
			187: pixel = WHITE; 
			188: pixel = WHITE; 
			189: pixel = CLEAR; // P 
			190: pixel = CLEAR;
			191: pixel = CLEAR;
			192: pixel = CLEAR; 
			193: pixel = CLEAR; // SPACE
			194: pixel = CLEAR; 
			195: pixel = WHITE;
			196: pixel = CLEAR; // T
			197: pixel = CLEAR; // SPACE 
			198: pixel = WHITE; 
			199: pixel = CLEAR; 
			200: pixel = CLEAR;
			201: pixel = WHITE; // O
			202: pixel = CLEAR; 
			203: pixel = CLEAR; 
			204: pixel = CLEAR; 
			205: pixel = CLEAR; // SPACE
			206: pixel = CLEAR;
			207: pixel = WHITE; 
			208: pixel = WHITE;
			209: pixel = CLEAR; // S
			210: pixel = CLEAR; // SPACE 
			211: pixel = CLEAR;
			212: pixel = WHITE;
			213: pixel = CLEAR; // T 
			214: pixel = CLEAR; // SPACE
			215: pixel = WHITE; 
			216: pixel = WHITE;
			217: pixel = WHITE;
			218: pixel = WHITE; // A
			219: pixel = CLEAR; // SPACE
			220: pixel = WHITE; 
			221: pixel = WHITE; 
			222: pixel = WHITE; 
			223: pixel = CLEAR; // R
			224: pixel = CLEAR; // SPACE
			225: pixel = CLEAR; 
			226: pixel = WHITE; 
			227: pixel = CLEAR; // T
			
			228: pixel = WHITE; 
			229: pixel = CLEAR; 
			230: pixel = CLEAR;
			231: pixel = CLEAR; // P
			232: pixel = CLEAR; // SPACE
			233: pixel = WHITE; 
			234: pixel = CLEAR; 
			235: pixel = CLEAR; 
			236: pixel = WHITE; // R
			237: pixel = CLEAR; // SPACE
			238: pixel = WHITE; 
			239: pixel = CLEAR; 
			240: pixel = CLEAR; 
			241: pixel = CLEAR; // E
			242: pixel = CLEAR; // SPACE
			243: pixel = CLEAR; 
			244: pixel = CLEAR; 
			245: pixel = CLEAR; 
			246: pixel = WHITE; // S 
			247: pixel = CLEAR; // SPACE 
			248: pixel = CLEAR; 
			249: pixel = CLEAR; 
			250: pixel = CLEAR; 
			251: pixel = WHITE; // S
			252: pixel = CLEAR; // SPACE
			253: pixel = CLEAR;  
			254: pixel = CLEAR; 
			255: pixel = CLEAR; 
			256: pixel = CLEAR; // SPACE
			257: pixel = WHITE; 
			258: pixel = CLEAR; 
			259: pixel = CLEAR;  
			260: pixel = WHITE; // U 
			261: pixel = CLEAR; // SPACE
			262: pixel = WHITE;
			263: pixel = CLEAR; 
			264: pixel = CLEAR; 
			265: pixel = CLEAR; // P 
			266: pixel = CLEAR;
			267: pixel = CLEAR;
			268: pixel = CLEAR; 
			269: pixel = CLEAR; // SPACE
			270: pixel = CLEAR; 
			271: pixel = WHITE;
			272: pixel = CLEAR; // T
			273: pixel = CLEAR; // SPACE 
			274: pixel = WHITE; 
			275: pixel = CLEAR; 
			276: pixel = CLEAR;
			277: pixel = WHITE; // O
			278: pixel = CLEAR; 
			279: pixel = CLEAR; 
			280: pixel = CLEAR; 
			281: pixel = CLEAR; // SPACE
			282: pixel = CLEAR;
			283: pixel = CLEAR; 
			284: pixel = CLEAR;
			285: pixel = WHITE; // S
			286: pixel = CLEAR; // SPACE 
			287: pixel = CLEAR;
			288: pixel = WHITE;
			289: pixel = CLEAR; // T 
			290: pixel = CLEAR; // SPACE
			291: pixel = WHITE; 
			292: pixel = CLEAR;
			293: pixel = CLEAR;
			294: pixel = WHITE; // A
			295: pixel = CLEAR; // SPACE
			296: pixel = WHITE; 
			297: pixel = CLEAR; 
			298: pixel = CLEAR; 
			299: pixel = WHITE; // R
			300: pixel = CLEAR; // SPACE
			301: pixel = CLEAR; 
			302: pixel = WHITE; 
			303: pixel = CLEAR; // T
			
			304: pixel = WHITE; 
			305: pixel = CLEAR; 
			306: pixel = CLEAR;
			307: pixel = CLEAR; // P
			308: pixel = CLEAR; // SPACE
			309: pixel = WHITE; 
			310: pixel = CLEAR; 
			311: pixel = CLEAR; 
			312: pixel = WHITE; // R
			313: pixel = CLEAR; // SPACE
			314: pixel = WHITE; 
			315: pixel = WHITE; 
			316: pixel = WHITE; 
			317: pixel = WHITE; // E
			318: pixel = CLEAR; // SPACE
			319: pixel = WHITE; 
			320: pixel = WHITE; 
			321: pixel = WHITE; 
			322: pixel = CLEAR; // S 
			323: pixel = CLEAR; // SPACE 
			324: pixel = WHITE; 
			325: pixel = WHITE; 
			326: pixel = WHITE; 
			327: pixel = CLEAR; // S
			328: pixel = CLEAR; // SPACE
			329: pixel = CLEAR;  
			330: pixel = CLEAR; 
			331: pixel = CLEAR; 
			332: pixel = CLEAR; // SPACE
			333: pixel = CLEAR; 
			334: pixel = WHITE; 
			335: pixel = WHITE;  
			336: pixel = CLEAR; // U 
			337: pixel = CLEAR; // SPACE
			338: pixel = WHITE;
			339: pixel = CLEAR; 
			340: pixel = CLEAR; 
			341: pixel = CLEAR; // P 
			342: pixel = CLEAR;
			343: pixel = CLEAR;
			344: pixel = CLEAR; 
			345: pixel = CLEAR; // SPACE
			346: pixel = CLEAR; 
			347: pixel = WHITE;
			348: pixel = CLEAR; // T
			349: pixel = CLEAR; // SPACE 
			350: pixel = CLEAR; 
			351: pixel = WHITE; 
			352: pixel = WHITE;
			353: pixel = CLEAR; // O
			354: pixel = CLEAR; 
			355: pixel = CLEAR; 
			356: pixel = CLEAR; 
			357: pixel = CLEAR; // SPACE
			358: pixel = WHITE;
			359: pixel = WHITE; 
			360: pixel = WHITE;
			361: pixel = CLEAR; // S
			362: pixel = CLEAR; // SPACE 
			363: pixel = CLEAR;
			364: pixel = WHITE;
			365: pixel = CLEAR; // T 
			366: pixel = CLEAR; // SPACE
			367: pixel = WHITE; 
			368: pixel = CLEAR;
			369: pixel = CLEAR;
			370: pixel = WHITE; // A
			371: pixel = CLEAR; // SPACE
			372: pixel = WHITE; 
			373: pixel = CLEAR; 
			374: pixel = CLEAR; 
			375: pixel = WHITE; // R
			376: pixel = CLEAR; // SPACE
			377: pixel = CLEAR; 
			378: pixel = WHITE; 
			379: pixel = CLEAR; // T
			
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module digit1(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 4;
	

	reg [23:0] pixel;
	reg [4:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			2: pixel = WHITE;
			6: pixel = WHITE;
			10: pixel = WHITE;
			14: pixel = WHITE;
			18: pixel = WHITE;
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module digit2(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 4;
	

	reg [23:0] pixel;
	reg [4:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = WHITE; 
			1: pixel = WHITE; 
			2: pixel = WHITE;
			3: pixel = WHITE;
			
			4: pixel = CLEAR; 
			5: pixel = CLEAR; 
			6: pixel = CLEAR;
			7: pixel = WHITE;
			
			8: pixel = WHITE; 
			9: pixel = WHITE; 
			10: pixel = WHITE;
			11: pixel = WHITE;
			
			12: pixel = WHITE; 
			13: pixel = CLEAR; 
			14: pixel = CLEAR;
			15: pixel = CLEAR;
			
			16: pixel = WHITE; 
			17: pixel = WHITE; 
			18: pixel = WHITE;
			19: pixel = WHITE;
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module digit3(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 4;
	

	reg [23:0] pixel;
	reg [4:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = WHITE; 
			1: pixel = WHITE; 
			2: pixel = WHITE;
			3: pixel = WHITE;
			
			4: pixel = CLEAR; 
			5: pixel = CLEAR; 
			6: pixel = CLEAR;
			7: pixel = WHITE;
			
			8: pixel = WHITE; 
			9: pixel = WHITE; 
			10: pixel = WHITE;
			11: pixel = WHITE;
			
			12: pixel = CLEAR; 
			13: pixel = CLEAR; 
			14: pixel = CLEAR;
			15: pixel = WHITE;
			
			16: pixel = WHITE; 
			17: pixel = WHITE; 
			18: pixel = WHITE;
			19: pixel = WHITE;
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module digit4(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 4;
	

	reg [23:0] pixel;
	reg [4:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = WHITE; 
			1: pixel = CLEAR; 
			2: pixel = CLEAR;
			3: pixel = WHITE;
			
			4: pixel = WHITE; 
			5: pixel = CLEAR; 
			6: pixel = CLEAR;
			7: pixel = WHITE;
			
			8: pixel = WHITE; 
			9: pixel = WHITE; 
			10: pixel = WHITE;
			11: pixel = WHITE;
			
			12: pixel = CLEAR; 
			13: pixel = CLEAR; 
			14: pixel = CLEAR;
			15: pixel = WHITE;
			
			16: pixel = CLEAR; 
			17: pixel = CLEAR; 
			18: pixel = CLEAR;
			19: pixel = WHITE;
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module digit5(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 4;
	

	reg [23:0] pixel;
	reg [4:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = WHITE; 
			1: pixel = WHITE; 
			2: pixel = WHITE;
			3: pixel = WHITE;
			
			4: pixel = WHITE; 
			5: pixel = CLEAR; 
			6: pixel = CLEAR;
			7: pixel = CLEAR;
			
			8: pixel = WHITE; 
			9: pixel = WHITE; 
			10: pixel = WHITE;
			11: pixel = WHITE;
			
			12: pixel = CLEAR; 
			13: pixel = CLEAR; 
			14: pixel = CLEAR;
			15: pixel = WHITE;
			
			16: pixel = WHITE; 
			17: pixel = WHITE; 
			18: pixel = WHITE;
			19: pixel = WHITE;
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module digit6(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 4;
	

	reg [23:0] pixel;
	reg [4:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = WHITE; 
			1: pixel = WHITE; 
			2: pixel = WHITE;
			3: pixel = WHITE;
			
			4: pixel = WHITE; 
			5: pixel = CLEAR; 
			6: pixel = CLEAR;
			7: pixel = CLEAR;
			
			8: pixel = WHITE; 
			9: pixel = WHITE; 
			10: pixel = WHITE;
			11: pixel = WHITE;
			
			12: pixel = WHITE; 
			13: pixel = CLEAR; 
			14: pixel = CLEAR;
			15: pixel = WHITE;
			
			16: pixel = WHITE; 
			17: pixel = WHITE; 
			18: pixel = WHITE;
			19: pixel = WHITE;
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module digit7(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 4;
	

	reg [23:0] pixel;
	reg [4:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = WHITE; 
			1: pixel = WHITE; 
			2: pixel = WHITE;
			3: pixel = WHITE;
			
			4: pixel = CLEAR; 
			5: pixel = CLEAR; 
			6: pixel = CLEAR;
			7: pixel = WHITE;
			
			8: pixel = CLEAR; 
			9: pixel = CLEAR; 
			10: pixel = CLEAR;
			11: pixel = WHITE;
			
			12: pixel = CLEAR; 
			13: pixel = CLEAR; 
			14: pixel = CLEAR;
			15: pixel = WHITE;
			
			16: pixel = CLEAR; 
			17: pixel = CLEAR; 
			18: pixel = CLEAR;
			19: pixel = WHITE;
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module digit8(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 4;
	

	reg [23:0] pixel;
	reg [4:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = WHITE; 
			1: pixel = WHITE; 
			2: pixel = WHITE;
			3: pixel = WHITE;
			
			4: pixel = WHITE; 
			5: pixel = CLEAR; 
			6: pixel = CLEAR;
			7: pixel = WHITE;
			
			8: pixel = WHITE; 
			9: pixel = WHITE; 
			10: pixel = WHITE;
			11: pixel = WHITE;
			
			12: pixel = WHITE; 
			13: pixel = CLEAR; 
			14: pixel = CLEAR;
			15: pixel = WHITE;
			
			16: pixel = WHITE; 
			17: pixel = WHITE; 
			18: pixel = WHITE;
			19: pixel = WHITE;
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module digit9(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 4;
	

	reg [23:0] pixel;
	reg [4:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = WHITE; 
			1: pixel = WHITE; 
			2: pixel = WHITE;
			3: pixel = WHITE;
			
			4: pixel = WHITE; 
			5: pixel = CLEAR; 
			6: pixel = CLEAR;
			7: pixel = WHITE;
			
			8: pixel = WHITE; 
			9: pixel = WHITE; 
			10: pixel = WHITE;
			11: pixel = WHITE;
			
			12: pixel = CLEAR; 
			13: pixel = CLEAR; 
			14: pixel = CLEAR;
			15: pixel = WHITE;
			
			16: pixel = CLEAR; 
			17: pixel = CLEAR; 
			18: pixel = CLEAR;
			19: pixel = WHITE;
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module digit0(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 4;
	

	reg [23:0] pixel;
	reg [4:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = WHITE; 
			1: pixel = WHITE; 
			2: pixel = WHITE;
			3: pixel = WHITE;
			
			4: pixel = WHITE; 
			5: pixel = CLEAR; 
			6: pixel = CLEAR;
			7: pixel = WHITE;
			
			8: pixel = WHITE; 
			9: pixel = CLEAR; 
			10: pixel = CLEAR;
			11: pixel = WHITE;
			
			12: pixel = WHITE; 
			13: pixel = CLEAR; 
			14: pixel = CLEAR;
			15: pixel = WHITE;
			
			16: pixel = WHITE; 
			17: pixel = WHITE; 
			18: pixel = WHITE;
			19: pixel = WHITE;
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module gameover_text_display(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 4; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 45;
	

	reg [23:0] pixel;
	reg [8:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = CLEAR; 
			1: pixel = WHITE; 
			2: pixel = WHITE;
			3: pixel = WHITE; // G
			4: pixel = CLEAR; // SPACE
			5: pixel = CLEAR; 
			6: pixel = WHITE; 
			7: pixel = WHITE; 
			8: pixel = CLEAR; // A
			9: pixel = CLEAR; // SPACE
			10: pixel = WHITE; 
			11: pixel = CLEAR; 
			12: pixel = CLEAR; 
			13: pixel = CLEAR; 
			14: pixel = WHITE; // M
			15: pixel = CLEAR; // SPACE
			16: pixel = WHITE; 
			17: pixel = WHITE; 
			18: pixel = WHITE;  
			19: pixel = WHITE; // E 
			20: pixel = CLEAR; // SPACE
			21: pixel = CLEAR; 
			22: pixel = CLEAR; 
			23: pixel = CLEAR; 
			24: pixel = CLEAR; // SPACE
			25: pixel = CLEAR;  
			26: pixel = WHITE; 
			27: pixel = WHITE; 
			28: pixel = CLEAR; // O
			29: pixel = CLEAR; // SPACE
			30: pixel = WHITE; 
			31: pixel = CLEAR; 
			32: pixel = CLEAR;  
			33: pixel = CLEAR;  
			34: pixel = WHITE; // V
			35: pixel = CLEAR; // SPACE
			36: pixel = WHITE; 
			37: pixel = WHITE; 
			38: pixel = WHITE;  
			39: pixel = WHITE; // E
			40: pixel = CLEAR; // SPACE
			41: pixel = WHITE; 
			42: pixel = WHITE; 
			43: pixel = WHITE; 
			44: pixel = CLEAR; // R
			
			45: pixel = WHITE; 
			46: pixel = CLEAR; 
			47: pixel = CLEAR;
			48: pixel = CLEAR; // G
			49: pixel = CLEAR; // SPACE
			50: pixel = WHITE; 
			51: pixel = CLEAR; 
			52: pixel = CLEAR; 
			53: pixel = WHITE; // A
			54: pixel = CLEAR; // SPACE
			55: pixel = WHITE; 
			56: pixel = WHITE; 
			57: pixel = CLEAR; 
			58: pixel = WHITE; 
			59: pixel = WHITE; // M
			60: pixel = CLEAR; // SPACE
			61: pixel = WHITE; 
			62: pixel = CLEAR; 
			63: pixel = CLEAR;  
			64: pixel = CLEAR; // E 
			65: pixel = CLEAR; // SPACE
			66: pixel = CLEAR; 
			67: pixel = CLEAR; 
			68: pixel = CLEAR; 
			69: pixel = CLEAR; // SPACE
			70: pixel = WHITE;  
			71: pixel = CLEAR; 
			72: pixel = CLEAR; 
			73: pixel = WHITE; // O
			74: pixel = CLEAR; // SPACE 
			75: pixel = WHITE;
			76: pixel = CLEAR; 
			77: pixel = CLEAR;  
			78: pixel = CLEAR;  
			79: pixel = WHITE; // V
			80: pixel = CLEAR; // SPACE
			81: pixel = WHITE; 
			82: pixel = CLEAR; 
			83: pixel = CLEAR;  
			84: pixel = CLEAR; // E
			85: pixel = CLEAR; // SPACE
			86: pixel = WHITE; 
			87: pixel = CLEAR; 
			88: pixel = CLEAR; 
			89: pixel = WHITE; // R
			
			90: pixel = WHITE; 
			91: pixel = CLEAR; 
			92: pixel = WHITE;
			93: pixel = WHITE; // G
			94: pixel = CLEAR; // SPACE
			95: pixel = WHITE; 
			96: pixel = WHITE; 
			97: pixel = WHITE; 
			98: pixel = WHITE; // A
			99: pixel = CLEAR; // SPACE
			100: pixel = WHITE; 
			101: pixel = CLEAR; 
			102: pixel = WHITE; 
			103: pixel = CLEAR; 
			104: pixel = WHITE; // M
			105: pixel = CLEAR; // SPACE
			106: pixel = WHITE; 
			107: pixel = WHITE; 
			108: pixel = WHITE;  
			109: pixel = CLEAR; // E 
			110: pixel = CLEAR; // SPACE
			111: pixel = CLEAR; 
			112: pixel = CLEAR; 
			113: pixel = CLEAR; 
			114: pixel = CLEAR; // SPACE
			115: pixel = WHITE;  
			116: pixel = CLEAR; 
			117: pixel = CLEAR; 
			118: pixel = WHITE; // O
			119: pixel = CLEAR; // SPACE
			120: pixel = WHITE; 
			121: pixel = CLEAR; 
			122: pixel = CLEAR;  
			123: pixel = CLEAR;  
			124: pixel = WHITE; // V
			125: pixel = CLEAR; // SPACE
			126: pixel = WHITE; 
			127: pixel = WHITE; 
			128: pixel = WHITE;  
			129: pixel = CLEAR; // E
			130: pixel = CLEAR; // SPACE
			131: pixel = WHITE; 
			132: pixel = WHITE; 
			133: pixel = WHITE; 
			134: pixel = CLEAR; // R
			
			135: pixel = WHITE; 
			136: pixel = CLEAR; 
			137: pixel = CLEAR;
			138: pixel = WHITE; // G
			139: pixel = CLEAR; // SPACE
			140: pixel = WHITE; 
			141: pixel = CLEAR; 
			142: pixel = CLEAR; 
			143: pixel = WHITE; // A
			144: pixel = CLEAR; // SPACE
			145: pixel = WHITE; 
			146: pixel = CLEAR; 
			147: pixel = CLEAR; 
			148: pixel = CLEAR; 
			149: pixel = WHITE; // M
			150: pixel = CLEAR; // SPACE
			151: pixel = WHITE; 
			152: pixel = CLEAR; 
			153: pixel = CLEAR;  
			154: pixel = CLEAR; // E 
			155: pixel = CLEAR; // SPACE
			156: pixel = CLEAR; 
			157: pixel = CLEAR; 
			158: pixel = CLEAR; 
			159: pixel = CLEAR; // SPACE
			160: pixel = WHITE;  
			161: pixel = CLEAR; 
			162: pixel = CLEAR; 
			163: pixel = WHITE; // O
			164: pixel = CLEAR; // SPACE
			165: pixel = CLEAR; 
			166: pixel = WHITE; 
			167: pixel = CLEAR;  
			168: pixel = WHITE;  
			169: pixel = CLEAR; // V
			170: pixel = CLEAR; // SPACE
			171: pixel = WHITE; 
			172: pixel = CLEAR; 
			173: pixel = CLEAR;  
			174: pixel = CLEAR; // E
			175: pixel = CLEAR; // SPACE
			176: pixel = WHITE; 
			177: pixel = CLEAR; 
			178: pixel = CLEAR; 
			179: pixel = WHITE; // R
			
			180: pixel = CLEAR; 
			181: pixel = WHITE; 
			182: pixel = WHITE;
			183: pixel = WHITE; // G
			184: pixel = CLEAR; // SPACE
			185: pixel = WHITE; 
			186: pixel = CLEAR; 
			187: pixel = CLEAR; 
			188: pixel = WHITE; // A
			189: pixel = CLEAR; // SPACE
			190: pixel = WHITE; 
			191: pixel = CLEAR; 
			192: pixel = CLEAR; 
			193: pixel = CLEAR; 
			194: pixel = WHITE; // M
			195: pixel = CLEAR; // SPACE
			196: pixel = WHITE; 
			197: pixel = WHITE; 
			198: pixel = WHITE;  
			199: pixel = WHITE; // E 
			200: pixel = CLEAR; // SPACE
			201: pixel = CLEAR; 
			202: pixel = CLEAR; 
			203: pixel = CLEAR; 
			204: pixel = CLEAR; // SPACE
			205: pixel = CLEAR;  
			206: pixel = WHITE; 
			207: pixel = WHITE; 
			208: pixel = CLEAR; // O
			209: pixel = CLEAR; // SPACE
			210: pixel = CLEAR; 
			211: pixel = CLEAR; 
			212: pixel = WHITE;  
			213: pixel = CLEAR;  
			214: pixel = CLEAR; // V
			215: pixel = CLEAR; // SPACE
			216: pixel = WHITE; 
			217: pixel = WHITE; 
			218: pixel = WHITE;  
			219: pixel = WHITE; // E
			220: pixel = CLEAR; // SPACE
			221: pixel = WHITE; 
			222: pixel = CLEAR; 
			223: pixel = CLEAR; 
			224: pixel = WHITE; // R
			
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module lives_text_display(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 22;
	

	reg [23:0] pixel;
	reg [8:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = WHITE; 
			1: pixel = CLEAR; 
			2: pixel = CLEAR;
			3: pixel = CLEAR; // L
			4: pixel = CLEAR; // SPACE
			5: pixel = WHITE; // I
			6: pixel = CLEAR; // SPACE
			7: pixel = WHITE; 
			8: pixel = CLEAR; 
			9: pixel = CLEAR; 
			10: pixel = CLEAR; 
			11: pixel = WHITE; // V 
			12: pixel = CLEAR; // SPACE
			13: pixel = WHITE; 
			14: pixel = WHITE; 
			15: pixel = WHITE; 
			16: pixel = WHITE; // E
			17: pixel = CLEAR; // SPACE 
			18: pixel = CLEAR;  
			19: pixel = WHITE;  
			20: pixel = WHITE; 
			21: pixel = WHITE; // S
			
			22: pixel = WHITE; 
			23: pixel = CLEAR; 
			24: pixel = CLEAR;
			25: pixel = CLEAR; // L
			26: pixel = CLEAR; // SPACE
			27: pixel = WHITE; // I
			28: pixel = CLEAR; // SPACE
			29: pixel = WHITE; 
			30: pixel = CLEAR; 
			31: pixel = CLEAR; 
			32: pixel = CLEAR; 
			33: pixel = WHITE; // V 
			34: pixel = CLEAR; // SPACE
			35: pixel = WHITE; 
			36: pixel = CLEAR; 
			37: pixel = CLEAR; 
			38: pixel = CLEAR; // E
			39: pixel = CLEAR; // SPACE 
			40: pixel = WHITE;  
			41: pixel = CLEAR;  
			42: pixel = CLEAR; 
			43: pixel = CLEAR; // S
			
			44: pixel = WHITE; 
			45: pixel = CLEAR; 
			46: pixel = CLEAR;
			47: pixel = CLEAR; // L
			48: pixel = CLEAR; // SPACE
			49: pixel = WHITE; // I
			50: pixel = CLEAR; // SPACE
			51: pixel = WHITE; 
			52: pixel = CLEAR; 
			53: pixel = CLEAR; 
			54: pixel = CLEAR; 
			55: pixel = WHITE; // V 
			56: pixel = CLEAR; // SPACE
			57: pixel = WHITE; 
			58: pixel = WHITE; 
			59: pixel = WHITE; 
			60: pixel = CLEAR; // E
			61: pixel = CLEAR; // SPACE 
			62: pixel = CLEAR;  
			63: pixel = WHITE;  
			64: pixel = WHITE; 
			65: pixel = CLEAR; // S
			
			66: pixel = WHITE; 
			67: pixel = CLEAR; 
			68: pixel = CLEAR;
			69: pixel = CLEAR; // L
			70: pixel = CLEAR; // SPACE
			71: pixel = WHITE; // I
			72: pixel = CLEAR; // SPACE
			73: pixel = CLEAR; 
			74: pixel = WHITE; 
			75: pixel = CLEAR; 
			76: pixel = WHITE; 
			77: pixel = CLEAR; // V 
			78: pixel = CLEAR; // SPACE
			79: pixel = WHITE; 
			80: pixel = CLEAR; 
			81: pixel = CLEAR; 
			82: pixel = CLEAR; // E
			83: pixel = CLEAR; // SPACE 
			84: pixel = CLEAR;  
			85: pixel = CLEAR;  
			86: pixel = CLEAR; 
			87: pixel = WHITE; // S
		
			88: pixel = WHITE; 
			89: pixel = WHITE; 
			90: pixel = WHITE;
			91: pixel = WHITE; // L
			92: pixel = CLEAR; // SPACE
			93: pixel = WHITE; // I
			94: pixel = CLEAR; // SPACE
			95: pixel = CLEAR; 
			96: pixel = CLEAR; 
			97: pixel = WHITE; 
			98: pixel = CLEAR; 
			99: pixel = CLEAR; // V 
			100: pixel = CLEAR; // SPACE
			101: pixel = WHITE; 
			102: pixel = WHITE; 
			103: pixel = WHITE; 
			104: pixel = WHITE; // E
			105: pixel = CLEAR; // SPACE 
			106: pixel = WHITE;  
			107: pixel = WHITE;  
			108: pixel = WHITE; 
			109: pixel = CLEAR; // S
			
			default: pixel = CLEAR; 
		endcase
	end
endmodule

module score_text_display(
	input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] p_out
    );


	parameter WHITE = 24'hff_ff_ff;
	parameter CLEAR = 24'h00_00_00;
	parameter SCALE = 3; //power of two scaling factor 
	parameter HEIGHT = 5;
	parameter WIDTH = 24;
	

	reg [23:0] pixel;
	reg [8:0] location;


	always@(*) begin 
	//decode 
		if ((hcount >= x && hcount < (x+(WIDTH<<SCALE))) && (vcount >= y && vcount < (y+(HEIGHT<<SCALE)))) 
			p_out = pixel;
		else p_out = CLEAR;
		location = ((hcount-x)>>SCALE) + (((vcount - y))>>SCALE)*WIDTH;
		case(location)
			0: pixel = CLEAR; 
			1: pixel = WHITE; 
			2: pixel = WHITE;
			3: pixel = WHITE; // S
			4: pixel = CLEAR; // SPACE
			5: pixel = CLEAR; 
			6: pixel = WHITE; 
			7: pixel = WHITE; 
			8: pixel = CLEAR; // C
			9: pixel = CLEAR; // SPACE
			10: pixel = CLEAR; 
			11: pixel = WHITE;  
			12: pixel = WHITE; 
			13: pixel = CLEAR; // O 
			14: pixel = CLEAR; // SPACE
			15: pixel = WHITE; 
			16: pixel = WHITE; 
			17: pixel = WHITE;  
			18: pixel = CLEAR; // R  
			19: pixel = CLEAR; // SPACE 
			20: pixel = WHITE; 
			21: pixel = WHITE; 
			22: pixel = WHITE; 
			23: pixel = WHITE; // E
			
			24: pixel = WHITE; 
			25: pixel = CLEAR; 
			26: pixel = CLEAR;
			27: pixel = CLEAR; // S
			28: pixel = CLEAR; // SPACE
			29: pixel = WHITE; 
			30: pixel = CLEAR; 
			31: pixel = CLEAR; 
			32: pixel = WHITE; // C
			33: pixel = CLEAR; // SPACE
			34: pixel = WHITE; 
			35: pixel = CLEAR;  
			36: pixel = CLEAR; 
			37: pixel = WHITE; // O 
			38: pixel = CLEAR; // SPACE
			39: pixel = WHITE; 
			40: pixel = CLEAR; 
			41: pixel = CLEAR;  
			42: pixel = WHITE; // R  
			43: pixel = CLEAR; // SPACE 
			44: pixel = WHITE; 
			45: pixel = CLEAR; 
			46: pixel = CLEAR; 
			47: pixel = CLEAR; // E
		
			48: pixel = CLEAR; 
			49: pixel = WHITE; 
			50: pixel = WHITE;
			51: pixel = CLEAR; // S
			52: pixel = CLEAR; // SPACE
			53: pixel = WHITE; 
			54: pixel = CLEAR; 
			55: pixel = CLEAR; 
			56: pixel = CLEAR; // C
			57: pixel = CLEAR; // SPACE
			58: pixel = WHITE; 
			59: pixel = CLEAR;  
			60: pixel = CLEAR; 
			61: pixel = WHITE; // O 
			62: pixel = CLEAR; // SPACE
			63: pixel = WHITE; 
			64: pixel = WHITE; 
			65: pixel = WHITE;  
			66: pixel = CLEAR; // R  
			67: pixel = CLEAR; // SPACE 
			68: pixel = WHITE; 
			69: pixel = WHITE; 
			70: pixel = WHITE; 
			71: pixel = CLEAR; // E
			
			72: pixel = CLEAR; 
			73: pixel = CLEAR; 
			74: pixel = CLEAR;
			75: pixel = WHITE; // S
			76: pixel = CLEAR; // SPACE
			77: pixel = WHITE; 
			78: pixel = CLEAR; 
			79: pixel = CLEAR; 
			80: pixel = WHITE; // C
			81: pixel = CLEAR; // SPACE
			82: pixel = WHITE; 
			83: pixel = CLEAR;  
			84: pixel = CLEAR; 
			85: pixel = WHITE; // O 
			86: pixel = CLEAR; // SPACE
			87: pixel = WHITE; 
			88: pixel = CLEAR; 
			89: pixel = CLEAR;  
			90: pixel = WHITE; // R  
			91: pixel = CLEAR; // SPACE 
			92: pixel = WHITE; 
			93: pixel = CLEAR; 
			94: pixel = CLEAR; 
			95: pixel = CLEAR; // E
			
			96: pixel = WHITE; 
			97: pixel = WHITE; 
			98: pixel = WHITE;
			99: pixel = CLEAR; // S
			100: pixel = CLEAR; // SPACE
			101: pixel = CLEAR; 
			102: pixel = WHITE; 
			103: pixel = WHITE; 
			104: pixel = CLEAR; // C
			105: pixel = CLEAR; // SPACE
			106: pixel = CLEAR; 
			107: pixel = WHITE;  
			108: pixel = WHITE; 
			109: pixel = CLEAR; // O 
			110: pixel = CLEAR; // SPACE
			111: pixel = WHITE; 
			112: pixel = CLEAR; 
			113: pixel = CLEAR;  
			114: pixel = WHITE; // R  
			115: pixel = CLEAR; // SPACE 
			116: pixel = WHITE; 
			117: pixel = WHITE; 
			118: pixel = WHITE; 
			119: pixel = WHITE; // E
			
			default: pixel = CLEAR; 
		endcase
	end
endmodule
