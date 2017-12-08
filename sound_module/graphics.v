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
// Screens
//
////////////////////////////////////////////////////////////////////////////////

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

	wire [23:0] normal_pixel, dead_pixel, happy_pixel, whack_pixel, start_pixel;
	normalmole #(.WIDTH(212),.HEIGHT(256))
			normalmole1(.pixel_clk(clk),.x(x),.hcount(hcount),.y(y_change),
							.y_permanent(y_permanent), .vcount(vcount),.pixel(normal_pixel));
	deadmole #(.WIDTH(191),.HEIGHT(256))
			deadmole1(.pixel_clk(clk),.x(x),.hcount(hcount),.y(y_change),
							.y_permanent(y_permanent), .vcount(vcount),.pixel(dead_pixel));
	happymole #(.WIDTH(207),.HEIGHT(256))
			happymole1(.pixel_clk(clk),.x(x),.hcount(hcount),.y(y_change),
							.y_permanent(y_permanent), .vcount(vcount),.pixel(happy_pixel));
	assign pixel = (state == MOLE_ASCENDING || state == MOLE_COUNTDOWN) ? normal_pixel 
							: (state == MOLE_MISSED || state == MOLE_MISSED_SOUND || state == HAPPY_MOLE_DESCENDING) ? happy_pixel
							: (state == MOLE_WHACKED || state == MOLE_WHACKED_SOUND || state == DEAD_MOLE_DESCENDING) ? dead_pixel
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