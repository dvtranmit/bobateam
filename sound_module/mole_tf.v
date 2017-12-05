`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:39:20 12/04/2017
// Design Name:   mole
// Module Name:   /afs/athena.mit.edu/user/a/d/adhikara/Documents/6.111things/6.111 project/bobateam/sound_module/mole_tf.v
// Project Name:  sound_module
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
	reg [22:0] music_address;
	reg using_diy;
	reg [119:0] diy_addresses;
	reg [19:0] diy_locations;

	// Outputs
	wire request_mole;

	// Instantiate the Unit Under Test (UUT)
	mole uut (
		.clk(clk), 
		.reset(reset), 
		.music_address(music_address), 
		.using_diy(using_diy), 
		.diy_addresses(diy_addresses), 
		.diy_locations(diy_locations), 
		.request_mole(request_mole)
	);

	initial begin
		forever #5 clk = !clk;
	end
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		music_address = 0;
		using_diy = 0;
		diy_addresses = 0;
		diy_locations = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		music_address = 24'b0;
		#10;
		music_address = 24'b6CDE;
		#10;
		music_address = 24'b6CDF;
		#10;
		music_address = 24'b8B00;
		#10;
		music_address = 24'b8B01;
		#10;
		
	end
      
endmodule

