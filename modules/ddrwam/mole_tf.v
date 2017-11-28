`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:34:30 11/28/2017
// Design Name:   mole
// Module Name:   /afs/athena.mit.edu/user/d/v/dvtran/Documents/6.111/finalproject/bobateam/modules/ddrwam/mole_tf.v
// Project Name:  ddrwam
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mole
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mole_tf;

	// Inputs
	reg clk;
	reg reset;
	reg one_hz_enable;
	reg [22:0] music_address;

	// Outputs
	wire request_mole;

	// Instantiate the Unit Under Test (UUT)
	mole uut (
		.clk(clk), 
		.reset(reset), 
		.one_hz_enable(one_hz_enable), 
		.music_address(music_address), 
		.request_mole(request_mole)
	);

	initial begin
		forever #5 clk = !clk;
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		one_hz_enable = 0;
		music_address = 0;

		// Wait 100 ns for global reset to finish
		#100;
      music_address = 23'h0000;
		#100;
		music_address = 23'h0001;
		#100;
		music_address = 23'h1000;
		#100;
		music_address = 23'h3000;
		#100;
		music_address = 23'h6000;
		#100;
		// Add stimulus here

	end
      
endmodule

