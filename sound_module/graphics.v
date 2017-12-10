`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:01:03 12/08/2017 
// Design Name: 
// Module Name:    graphics 
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

/******************************************************************************/
//VICTORIA CODE HERE

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
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
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

////////////////////////////////////////////////////////////////////////////////
//
// MOLE MODULES
//
////////////////////////////////////////////////////////////////////////////////

module normalmole
	#(parameter WIDTH = 212, HEIGHT = 256)
	(input pixel_clk,
    input [10:0] x, hcount,
    input [9:0] y, y_permanent, vcount, 
    output reg [23:0] pixel
    );
	wire [15:0] image_addr;
	wire [3:0] image_bits, red_mapped, green_mapped, blue_mapped;
	always @ (posedge pixel_clk) begin
		if ((hcount >= x && hcount < (x + WIDTH)) && (vcount >= y && vcount < (y_permanent + HEIGHT)))
			pixel <= {red_mapped,4'b0, green_mapped,4'b0, blue_mapped,4'b0};
		else
			pixel <= 0;
	end
	assign image_addr = (hcount - x) + (vcount - y) * WIDTH;
	normalmole_image_rom rom1(.clka(pixel_clk),.addra(image_addr),.douta(image_bits));
	normalmole_red_rom rcm (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
	normalmole_green_rom gcm (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
	normalmole_blue_rom bcm (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));	
endmodule

module deadmole
	#(parameter WIDTH = 191, HEIGHT = 256)
	(input pixel_clk,
    input [10:0] x, hcount,
    input [9:0] y, y_permanent,vcount,
    output reg [23:0] pixel
    );
	wire [15:0] image_addr;
	wire [3:0] image_bits, red_mapped, green_mapped, blue_mapped;
	always @ (posedge pixel_clk) begin
		if ((hcount >= x && hcount < (x + WIDTH)) && (vcount >= y && vcount < (y_permanent + HEIGHT)))
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
    input [9:0] y, y_permanent, vcount,
	 input [9:0] height,
    output reg [23:0] pixel
    );
	wire [15:0] image_addr;
	wire [3:0] image_bits, red_mapped, green_mapped, blue_mapped;
	always @ (posedge pixel_clk) begin
		if ((hcount >= x && hcount < (x + WIDTH)) && (vcount >= y && vcount < (y_permanent + HEIGHT)))
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


////////////////////////////////////////////////////////////////////////////////
//
// MOLE MUX
//
////////////////////////////////////////////////////////////////////////////////
module displaymole(	input clk, clk2, reset,
							input [3:0] state,
							input [2:0] mole_location,
							input [10:0] hcount,
							input [9:0]  vcount,
							input [1:0] lives,
							input [7:0] score,
							output [23:0] pixel,
							output reg popup_done = 0);

	// States
	reg [3:0] IDLE 					= 4'd0;		// Check if user has pressed start
	reg [3:0] GAME_START_DELAY 	= 4'd1;		// Delay until user stands on center
	reg [3:0] GAME_ONGOING			= 4'd2;		// Check lives & Address from Music
	reg [3:0] REQUEST_MOLE			= 4'd3;		// Request a mole to be displayed (pulse)
	reg [3:0] MOLE_COUNTDOWN		= 4'd4;		// Mole displayed until stomped/expired 
	reg [3:0] MOLE_MISSED			= 4'd5;		// Lives counter decremented (pulse)
	reg [3:0] MOLE_WHACKED			= 4'd6;		// Score counter incremented (pulse)
	reg [3:0] GAME_OVER				= 4'd8;		// Display Game Over Screen
	reg [3:0] MOLE_MISSED_SOUND	= 4'd9;		// Extra time for sound
	reg [3:0] MOLE_WHACKED_SOUND	= 4'd10;		// Extra time for sound
	// Placeholder variables for DIY mode
	parameter [3:0] RECORD_DIY_BEGIN 	= 4'd11;		// Begin Recording Moles
	parameter [3:0] RECORD_DIY_IN_PROGRESS = 4'd12;// Begin Recording Moles

	// New Fancy Mole Display States
	parameter [3:0] MOLE_ASCENDING				= 4'd13;
	parameter [3:0] HAPPY_MOLE_DESCENDING		= 4'd14;
	parameter [3:0] DEAD_MOLE_DESCENDING		= 4'd15;

   // TOP LEFT MOLE CORNERS
	parameter [10:0] x1 = 65;
	parameter [9:0] y1p = 0;		// The "p" stands for permanent (the non-moving border of a picture)
	parameter [10:0] x2 = 406;	// It also happens to stand for parameter because these don't change (:
	parameter [9:0] y2p = 0;
	parameter [10:0] x3 = 747;
	parameter [9:0] y3p = 0;
	parameter [10:0] x4 = 65;
	parameter [9:0] y4p = 256;
	parameter [10:0] x5 = 747;
	parameter [9:0] y5p = 256;
	parameter [10:0] x6 = 65;
	parameter [9:0] y6p = 512;
	parameter [10:0] x7 = 406;
	parameter [9:0] y7p = 512;
	parameter [10:0] x8 = 747;
	parameter [9:0] y8p = 512;

	wire mole_pulse;
	mole_divider mole_divider1(.clk(clk2), .mole_popup_clock(mole_pulse));

	// Assign x y location based on input from game state
	// y_permanent assigns the bottom border and selects from parameters above
	reg [10:0] x;
	reg [9:0] y_permanent;
	reg [9:0] y_change;
	always@(posedge clk2) begin
		if (reset) begin
			x <= x1;
			y_permanent <= y1p;
		end else if (state == REQUEST_MOLE) begin
			case(mole_location)
				3'd0: begin x <= x1; y_permanent <= y1p; y_change <= 255 + y1p; end
				3'd1: begin x <= x2; y_permanent <= y2p; y_change <= 255 + y2p; end
				3'd2: begin x <= x3; y_permanent <= y3p; y_change <= 255 + y3p; end
				3'd3: begin x <= x4; y_permanent <= y4p; y_change <= 255 + y4p; end
				3'd4: begin x <= x5; y_permanent <= y5p; y_change <= 255 + y5p; end
				3'd5: begin x <= x6; y_permanent <= y6p; y_change <= 255 + y6p; end
				3'd6: begin x <= x7; y_permanent <= y7p; y_change <= 255 + y7p; end
				3'd7: begin x <= x8; y_permanent <= y8p; y_change <= 255 + y8p; end
			endcase
			popup_done <= 0;
		end else if (state == MOLE_ASCENDING) begin
			if (popup_done == 0) begin
				if (y_change <= 256 + y_permanent && y_change > y_permanent)
					y_change <= (mole_pulse) ? y_change - 1 : y_change;
				else if (y_change == y_permanent)
					popup_done <= 1;
			end
		end else if (state == HAPPY_MOLE_DESCENDING) begin
			if (y_change < 256 + y_permanent && y_change >= y_permanent)
				y_change <= (mole_pulse) ? y_change + 1 : y_change;
			else if (y_change == 256 + y_permanent)
				popup_done <= 1;
		end else if (state == DEAD_MOLE_DESCENDING) begin
			if (y_change < 256 + y_permanent && y_change >= y_permanent)
				y_change <= (mole_pulse) ? y_change + 1 : y_change;
			else
				popup_done <= 1;
		end else if (state == MOLE_WHACKED_SOUND || state == MOLE_MISSED_SOUND) begin
			y_change <= y_permanent;
		end else
			popup_done <= 0;
	end

	wire [23:0] startscreen_pixel, gameoverscreen_pixel, lives_ongoing_pixel, score_ongoing_pixel;
	wire [23:0] whacktext, amoletext, pressup, gameovertext, livestext, scoretext;
	wire [23:0] lives0, lives1, lives2, lives3;
	wire [23:0] d0,d1,d2,d3,d4,d5,d6,d7,d8,d9;
	wire [23:0] d00,d01,d02,d03,d04,d05,d06,d07,d08,d09;
	// generate text
	whack_text_display whack1(.x(60),.hcount(hcount),.y(100),.vcount(vcount),.p_out(whacktext));
	amole_text_display amole1(.x(476),.hcount(hcount),.y(100),.vcount(vcount),.p_out(amoletext));
	pressuptostart_text_display pressup1(.x(200),.hcount(hcount),.y(500),.vcount(vcount),.p_out(pressup));
	gameover_text_display gameover1(.x(150),.hcount(hcount),.y(200),.vcount(vcount),.p_out(gameovertext));
	lives_text_display lives1(.x(300),.hcount(hcount),.y(300),.vcount(vcount),.p_out(livestext));
	score_text_display score1(.x(300),.hcount(hcount),.y(400),.vcount(vcount),.p_out(scoretext));
	
	assign startscreen_pixel = whacktext | amoletext| pressup;
	// generate digits for lives
	digit0 live0(.x(500),.hcount(hcount),.y(300),.vcount(vcount),.p_out(lives0));
	digit1 live1(.x(500),.hcount(hcount),.y(300),.vcount(vcount),.p_out(lives1));
	digit2 live2(.x(500),.hcount(hcount),.y(300),.vcount(vcount),.p_out(lives2));
	digit3 live3(.x(500),.hcount(hcount),.y(300),.vcount(vcount),.p_out(lives3));
	// generate 1st digits for score
	digit0 n0(.x(520),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d0));
	digit1 n1(.x(520),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d1));
	digit2 n2(.x(520),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d2));
	digit3 n3(.x(520),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d3));
	digit4 n4(.x(520),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d4));
	digit5 n5(.x(520),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d5));
	digit6 n6(.x(520),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d6));
	digit7 n7(.x(520),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d7));
	digit8 n8(.x(520),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d8));
	digit9 n9(.x(520),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d9));
	// generate 2nd digits for score
	digit0 n0(.x(560),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d00));
	digit1 n1(.x(560),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d01));
	digit2 n2(.x(560),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d02));
	digit3 n3(.x(560),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d03));
	digit4 n4(.x(560),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d04));
	digit5 n5(.x(560),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d05));
	digit6 n6(.x(560),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d06));
	digit7 n7(.x(560),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d07));
	digit8 n8(.x(560),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d08));
	digit9 n9(.x(560),.hcount(hcount),.y(400),.vcount(vcount),.p_out(d09));
	
	case(lives)
		2'd0: lives_ongoing_pixel = livestext | lives0;
		2'd1: lives_ongoing_pixel = livestext | lives1;
		2'd2: lives_ongoing_pixel = livestext | lives2;
		2'd3: lives_ongoing_pixel = livestext | lives3;
	endcase
	
	case(score)
		8'd0: score_ongoing_pixel = scoretext | d0;
		8'd1: score_ongoing_pixel = scoretext | d1;
		8'd2: score_ongoing_pixel = scoretext | d2;
		8'd3: score_ongoing_pixel = scoretext | d3;
		8'd4: score_ongoing_pixel = scoretext | d4;
		8'd5: score_ongoing_pixel = scoretext | d5;
		8'd6: score_ongoing_pixel = scoretext | d6;
		8'd7: score_ongoing_pixel = scoretext | d7;
		8'd8: score_ongoing_pixel = scoretext | d8;
		8'd9: score_ongoing_pixel = scoretext | d9;
		8'd10: score_ongoing_pixel = scoretext | d1 | d00;
		8'd11: score_ongoing_pixel = scoretext | d1 | d01;
		8'd12: score_ongoing_pixel = scoretext | d1 | d02;
		8'd13: score_ongoing_pixel = scoretext | d1 | d03;
		8'd14: score_ongoing_pixel = scoretext | d1 | d04;
		8'd15: score_ongoing_pixel = scoretext | d1 | d05;
		8'd16: score_ongoing_pixel = scoretext | d1 | d06;
		8'd17: score_ongoing_pixel = scoretext | d1 | d07;
		8'd18: score_ongoing_pixel = scoretext | d1 | d08;
		8'd19: score_ongoing_pixel = scoretext | d1 | d09;
		8'd20: score_ongoing_pixel = scoretext | d2 | d00;
		8'd21: score_ongoing_pixel = scoretext | d2 | d01;
		8'd22: score_ongoing_pixel = scoretext | d2 | d02;
		8'd23: score_ongoing_pixel = scoretext | d2 | d03;
		8'd24: score_ongoing_pixel = scoretext | d2 | d04;
		8'd25: score_ongoing_pixel = scoretext | d2 | d05;
		8'd26: score_ongoing_pixel = scoretext | d2 | d06;
		8'd27: score_ongoing_pixel = scoretext | d2 | d07;
		8'd28: score_ongoing_pixel = scoretext | d2 | d08;
		8'd29: score_ongoing_pixel = scoretext | d2 | d09;
		8'd30: score_ongoing_pixel = scoretext | d3 | d00;
		8'd31: score_ongoing_pixel = scoretext | d3 | d01;
		8'd32: score_ongoing_pixel = scoretext | d3 | d02;
		8'd33: score_ongoing_pixel = scoretext | d3 | d03;
		8'd34: score_ongoing_pixel = scoretext | d3 | d04;
		8'd35: score_ongoing_pixel = scoretext | d3 | d05;
		8'd36: score_ongoing_pixel = scoretext | d3 | d06;
		8'd37: score_ongoing_pixel = scoretext | d3 | d07;
		8'd38: score_ongoing_pixel = scoretext | d3 | d08;
		8'd39: score_ongoing_pixel = scoretext | d3 | d09;
		8'd40: score_ongoing_pixel = scoretext | d4 | d00;
		8'd41: score_ongoing_pixel = scoretext | d4 | d01;
		8'd42: score_ongoing_pixel = scoretext | d4 | d02;
		8'd43: score_ongoing_pixel = scoretext | d4 | d03;
		8'd44: score_ongoing_pixel = scoretext | d4 | d04;
		8'd45: score_ongoing_pixel = scoretext | d4 | d05;
		8'd46: score_ongoing_pixel = scoretext | d4 | d06;
		8'd47: score_ongoing_pixel = scoretext | d4 | d07;
		8'd48: score_ongoing_pixel = scoretext | d4 | d08;
		8'd49: score_ongoing_pixel = scoretext | d4 | d09;
		8'd50: score_ongoing_pixel = scoretext | d5 | d00;
		8'd51: score_ongoing_pixel = scoretext | d5 | d01;
		8'd52: score_ongoing_pixel = scoretext | d5 | d02;
		8'd53: score_ongoing_pixel = scoretext | d5 | d03;
		8'd54: score_ongoing_pixel = scoretext | d5 | d04;
		8'd55: score_ongoing_pixel = scoretext | d5 | d05;
		8'd56: score_ongoing_pixel = scoretext | d5 | d06;
		8'd57: score_ongoing_pixel = scoretext | d5 | d07;
		8'd58: score_ongoing_pixel = scoretext | d5 | d08;
		8'd59: score_ongoing_pixel = scoretext | d5 | d09;
		8'd60: score_ongoing_pixel = scoretext | d6 | d00;
		8'd61: score_ongoing_pixel = scoretext | d6 | d01;
		8'd62: score_ongoing_pixel = scoretext | d6 | d02;
		8'd63: score_ongoing_pixel = scoretext | d6 | d03;
		8'd64: score_ongoing_pixel = scoretext | d6 | d04;
		8'd65: score_ongoing_pixel = scoretext | d6 | d05;
		8'd66: score_ongoing_pixel = scoretext | d6 | d06;
		8'd67: score_ongoing_pixel = scoretext | d6 | d07;
		8'd68: score_ongoing_pixel = scoretext | d6 | d08;
		8'd69: score_ongoing_pixel = scoretext | d6 | d09;
		8'd70: score_ongoing_pixel = scoretext | d7 | d00;
		8'd71: score_ongoing_pixel = scoretext | d7 | d01;
		8'd72: score_ongoing_pixel = scoretext | d7 | d02;
		8'd73: score_ongoing_pixel = scoretext | d7 | d03;
		8'd74: score_ongoing_pixel = scoretext | d7 | d04;
		8'd75: score_ongoing_pixel = scoretext | d7 | d05;
		8'd76: score_ongoing_pixel = scoretext | d7 | d06;
		8'd77: score_ongoing_pixel = scoretext | d7 | d07;
		8'd78: score_ongoing_pixel = scoretext | d7 | d08;
		8'd79: score_ongoing_pixel = scoretext | d7 | d09;
		8'd80: score_ongoing_pixel = scoretext | d8 | d00;
		8'd81: score_ongoing_pixel = scoretext | d8 | d01;
		8'd82: score_ongoing_pixel = scoretext | d8 | d02;
		8'd83: score_ongoing_pixel = scoretext | d8 | d03;
		8'd84: score_ongoing_pixel = scoretext | d8 | d04;
		8'd85: score_ongoing_pixel = scoretext | d8 | d05;
		8'd86: score_ongoing_pixel = scoretext | d8 | d06;
		8'd87: score_ongoing_pixel = scoretext | d8 | d07;
		8'd88: score_ongoing_pixel = scoretext | d8 | d08;
		8'd89: score_ongoing_pixel = scoretext | d8 | d09;
		8'd90: score_ongoing_pixel = scoretext | d9 | d00;
		8'd91: score_ongoing_pixel = scoretext | d9 | d01;
		8'd92: score_ongoing_pixel = scoretext | d9 | d02;
		8'd93: score_ongoing_pixel = scoretext | d9 | d03;
		8'd94: score_ongoing_pixel = scoretext | d9 | d04;
		8'd95: score_ongoing_pixel = scoretext | d9 | d05;
		8'd96: score_ongoing_pixel = scoretext | d9 | d06;
		8'd97: score_ongoing_pixel = scoretext | d9 | d07;
		8'd98: score_ongoing_pixel = scoretext | d9 | d08;
		8'd99: score_ongoing_pixel = scoretext | d9 | d09;
	endcase
	
	assign gameoverscreen_pixel = gameovertext | score_ongoing_pixel;
	wire [23:0] normal_pixel, dead_pixel, happy_pixel;
	normalmole #(.WIDTH(212),.HEIGHT(256))
			normalmole1(.pixel_clk(clk),.x(x),.hcount(hcount),.y(y_change),
							.y_permanent(y_permanent), .vcount(vcount),.pixel(normal_pixel));
	deadmole #(.WIDTH(191),.HEIGHT(256))
			deadmole1(.pixel_clk(clk),.x(x),.hcount(hcount),.y(y_change),
							.y_permanent(y_permanent), .vcount(vcount),.pixel(dead_pixel));
	happymole #(.WIDTH(207),.HEIGHT(256))
			happymole1(.pixel_clk(clk),.x(x),.hcount(hcount),.y(y_change),
							.y_permanent(y_permanent), .vcount(vcount),.pixel(happy_pixel));
	assign pixel = state == IDLE ? startscreen_pixel	
							: (state == MOLE_ASCENDING || state == MOLE_COUNTDOWN) ? normal_pixel | lives_ongoing_pixel | score_ongoing_pixel
							: (state == MOLE_MISSED || state == MOLE_MISSED_SOUND || state == HAPPY_MOLE_DESCENDING) ? happy_pixel | lives_ongoing_pixel | score_ongoing_pixel
							: (state == MOLE_WHACKED || state == MOLE_WHACKED_SOUND || state == DEAD_MOLE_DESCENDING) ? dead_pixel | lives_ongoing_pixel | score_ongoing_pixel
							: (state == GAME_OVER) ? gameoverscreen_pixel | score_ongoing_pixel
							: 24'h0;
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// MOLE DIVIDER
//
////////////////////////////////////////////////////////////////////////////////

module mole_divider(input clk, output reg mole_popup_clock);
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

