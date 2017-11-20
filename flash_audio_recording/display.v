///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Alphanumeric Display Interface
//
//
// Created: November 5, 2003
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// Change history
//
// 2005-05-09: Made <dots> input registered, and converted the 640-input MUX
//             to a 640-bit shift register.
//
///////////////////////////////////////////////////////////////////////////////

module display (reset, clock_27mhz,
		disp_blank, disp_clock, disp_rs, disp_ce_b,
		disp_reset_b, disp_data_out, dots);

   input  reset, clock_27mhz;
   output disp_blank, disp_clock, disp_data_out, disp_rs, disp_ce_b, 
	  disp_reset_b;
   input [639:0] dots;
   
   reg disp_data_out, disp_rs, disp_ce_b, disp_reset_b;

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
   
   reg [7:0] state;
   reg [9:0] dot_index;
   reg [31:0] control;
   reg [639:0] ldots;
   
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
	      // Initialize dot register
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
	      dot_index <= 31;
	      state <= state+1;
	   end
	 
	 8'h04:
	   begin
	      // Setup the control register
	      disp_rs <= 1'b1; // Select the control register
	      disp_ce_b <= 1'b0;
	      disp_data_out <= control[31];
	      control <= {control[30:0], 1'b0};
	      if (dot_index == 0)
		state <= state+1;
	      else
		dot_index <= dot_index-1;
	   end
	  
	 8'h05:
	   begin
	      // Latch the control register data
	      disp_ce_b <= 1'b1;
	      dot_index <= 639;
	      ldots <= dots;
	      state <= state+1;
	   end
	 
	 8'h06:
	   begin
	      // Load the user's dot data into the dot register
	      disp_rs <= 1'b0; // Select the dot register
	      disp_ce_b <= 1'b0;
	      disp_data_out <= ldots[639];
	      ldots <= ldots<<1;
	      if (dot_index == 0)
		state <= 5;
	      else
		dot_index <= dot_index-1;
	   end
       endcase
   
endmodule
