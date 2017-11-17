`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:00:04 11/15/2017
// Design Name:   flash_manager
// Module Name:   /afs/athena.mit.edu/user/a/d/adhikara/Documents/6.111things/6.111 project/bobateam/flash_flash_flash/flashtesting.v
// Project Name:  flash_flash_flash
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: flash_manager
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module flashtesting;

	// Inputs
	reg clock;
	reg reset;
	reg writemode;
	reg [15:0] wdata;
	reg dowrite;
	reg [22:0] raddr;
	reg doread;
	reg flash_sts;

	// Outputs
	wire [639:0] dots;
	wire [15:0] frdata;
	wire busy;
	wire [23:0] flash_address;
	wire flash_ce_b;
	wire flash_oe_b;
	wire flash_we_b;
	wire flash_reset_b;
	wire flash_byte_b;
	wire [11:0] fsmstate;

	// Bidirs
	wire [15:0] flash_data;

	// Instantiate the Unit Under Test (UUT)
	flash_manager uut (
		.clock(clock), 
		.reset(reset), 
		.dots(dots), 
		.writemode(writemode), 
		.wdata(wdata), 
		.dowrite(dowrite), 
		.raddr(raddr), 
		.frdata(frdata), 
		.doread(doread), 
		.busy(busy), 
		.flash_data(flash_data), 
		.flash_address(flash_address), 
		.flash_ce_b(flash_ce_b), 
		.flash_oe_b(flash_oe_b), 
		.flash_we_b(flash_we_b), 
		.flash_reset_b(flash_reset_b), 
		.flash_sts(flash_sts), 
		.flash_byte_b(flash_byte_b), 
		.fsmstate(fsmstate)
	);

	initial begin   // system clock
      forever #5 clock = !clock;
      end

	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		writemode = 0;
		wdata = 0;
		dowrite = 0;
		raddr = 0;
		doread = 0;
		flash_sts = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		//erasing (seems to be working?)
		writemode = 1;
		#100;
		reset = 1;
		#50
		reset = 0;
		
		#100;
		
		//write
		//writemode = 1;
		//wdata = 16'h82;
		//dowrite = 1;
		
		//read
		//reset = 1;
		//#10;
		//reset = 0;
		//#20;
		//writemode = 0;
		//#20;
		//raddr = 24'h3;
		//#20;
		//doread = 1;
		//#1000;
		//doread = 0;

	end
      
endmodule

