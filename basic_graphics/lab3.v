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
	normalmole #(.WIDTH(212),.HEIGHT(256))
			mole8(.pixel_clk(clock_65mhz),.x(x8),.hcount(hcount8),.y(y8),.vcount(vcount8),.pixel(mole8_pixel));

   reg [23:0] rgb;
   wire border = (hcount1==0 | hcount1==1023 | vcount1==0 | vcount1==767);
   
	//assign pixel = mole1_pixel | mole2_pixel | mole3_pixel | mole4_pixel | mole5_pixel | mole6_pixel | mole7_pixel | mole8_pixel;
	//assign pixel = mole1_pixel;
   reg b,hs,vs;
	reg [9:0] height = 256;
	reg [9:0] y_change = 255;
	wire [10:0] x1 = 65;
	wire [9:0] y1 = 0;
	wire clock_10hz;
	happymole #(.WIDTH(207))
			mole1(.pixel_clk(clock_65mhz),.height(height),.x(x1),.hcount(hcount1),.y(y_change),.vcount(vcount1),.y_permanent(y1),.pixel(mole1_pixel));
	divider divider1(.clk(clock_27mhz),.ten_hz_enable(clock_10hz));
	reg led_status = 0;
	always @ (posedge clock_10hz) begin
		//if (height < 256)
		if (y_change < 256 && y_change > 0)
			//height <= height + 1;
			y_change <= y_change - 1;
		else if (y_change == 0)
			//height <= 1;
			y_change <= 255;
		led_status <= ~led_status;
	end
   always @(posedge clock_65mhz) begin
		hs <= hsync1;
		vs <= vsync1;
		b <= blank1;
		rgb <= mole1_pixel; 
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
   
   assign led = ~{2'b00,up,down,reset,switch[1:0],led_status};
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
	//#(parameter WIDTH = 207, HEIGHT = 256)
	#(parameter WIDTH = 207)
	(input pixel_clk,
    input [10:0] x, hcount,
    input [9:0] y, vcount, y_permanent,
	 input [9:0] height,
    output reg [23:0] pixel
    );
	wire [15:0] image_addr;
	wire [3:0] image_bits, red_mapped, green_mapped, blue_mapped;
	always @ (posedge pixel_clk) begin
		if ((hcount >= x && hcount < (x + WIDTH)) && (vcount >= y && vcount < 256))//(y + height)))
			pixel <= {red_mapped,4'b0, green_mapped,4'b0, blue_mapped,4'b0};
		else
			pixel <= 0;
	end
	assign image_addr = (hcount - x) + (vcount - 0) * WIDTH;
	happy_image_rom rom1_happy(.clka(pixel_clk),.addra(image_addr),.douta(image_bits));
	happy_red_rom rcm_happy (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
	happy_green_rom gcm_happy (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
	happy_blue_rom bcm_happy (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));	
endmodule

module divider(input clk, output reg ten_hz_enable);
	reg [26:0] count = 0;
	always @ (posedge clk) begin
		ten_hz_enable <= 0;
		count <= count + 1;
		if (count == 25'd135000) begin
			ten_hz_enable <= 1;
			count <= 0;
		end
	end
endmodule 