`default_nettype none

///////////////////////////////////////////////////////////////////////////////
//
// bi-directional monaural interface to AC97
//
///////////////////////////////////////////////////////////////////////////////

module lab5audio (
  input wire clock_27mhz,
  input wire reset,
  input wire [4:0] volume,
  output wire [7:0] audio_in_data,
  input wire [7:0] audio_out_data,
  output wire ready,
  output reg audio_reset_b,   // ac97 interface signals
  output wire ac97_sdata_out,
  input wire ac97_sdata_in,
  output wire ac97_synch,
  input wire ac97_bit_clock
);

  wire [7:0] command_address;
  wire [15:0] command_data;
  wire command_valid;
  wire [19:0] left_in_data, right_in_data;
  wire [19:0] left_out_data, right_out_data;

  // wait a little before enabling the AC97 codec
  reg [9:0] reset_count;
  always @(posedge clock_27mhz) begin
    if (reset) begin
      audio_reset_b = 1'b0;
      reset_count = 0;
    end else if (reset_count == 1023)
      audio_reset_b = 1'b1;
    else
      reset_count = reset_count+1;
  end

  wire ac97_ready;
  ac97 ac97(.ready(ac97_ready),
            .command_address(command_address),
            .command_data(command_data),
            .command_valid(command_valid),
            .left_data(left_out_data), .left_valid(1'b1),
            .right_data(right_out_data), .right_valid(1'b1),
            .left_in_data(left_in_data), .right_in_data(right_in_data),
            .ac97_sdata_out(ac97_sdata_out),
            .ac97_sdata_in(ac97_sdata_in),
            .ac97_synch(ac97_synch),
            .ac97_bit_clock(ac97_bit_clock));

  // ready: one cycle pulse synchronous with clock_27mhz
  reg [2:0] ready_sync;
  always @ (posedge clock_27mhz) ready_sync <= {ready_sync[1:0], ac97_ready};
  assign ready = ready_sync[1] & ~ready_sync[2];

  reg [7:0] out_data;
  always @ (posedge clock_27mhz)
    if (ready) out_data <= audio_out_data;
  assign audio_in_data = left_in_data[19:12];
  assign left_out_data = {out_data, 12'b000000000000};
  assign right_out_data = left_out_data;

  // generate repeating sequence of read/writes to AC97 registers
  ac97commands cmds(.clock(clock_27mhz), .ready(ready),
                    .command_address(command_address),
                    .command_data(command_data),
                    .command_valid(command_valid),
                    .volume(volume),
                    .source(3'b000));     // mic
endmodule

// assemble/disassemble AC97 serial frames
module ac97 (
  output reg ready,
  input wire [7:0] command_address,
  input wire [15:0] command_data,
  input wire command_valid,
  input wire [19:0] left_data,
  input wire left_valid,
  input wire [19:0] right_data,
  input wire right_valid,
  output reg [19:0] left_in_data, right_in_data,
  output reg ac97_sdata_out,
  input wire ac97_sdata_in,
  output reg ac97_synch,
  input wire ac97_bit_clock
);
  reg [7:0] bit_count;

  reg [19:0] l_cmd_addr;
  reg [19:0] l_cmd_data;
  reg [19:0] l_left_data, l_right_data;
  reg l_cmd_v, l_left_v, l_right_v;

  initial begin
    ready <= 1'b0;
    // synthesis attribute init of ready is "0";
    ac97_sdata_out <= 1'b0;
    // synthesis attribute init of ac97_sdata_out is "0";
    ac97_synch <= 1'b0;
    // synthesis attribute init of ac97_synch is "0";

    bit_count <= 8'h00;
    // synthesis attribute init of bit_count is "0000";
    l_cmd_v <= 1'b0;
    // synthesis attribute init of l_cmd_v is "0";
    l_left_v <= 1'b0;
    // synthesis attribute init of l_left_v is "0";
    l_right_v <= 1'b0;
    // synthesis attribute init of l_right_v is "0";

    left_in_data <= 20'h00000;
    // synthesis attribute init of left_in_data is "00000";
    right_in_data <= 20'h00000;
    // synthesis attribute init of right_in_data is "00000";
  end

  always @(posedge ac97_bit_clock) begin
    // Generate the sync signal
    if (bit_count == 255)
      ac97_synch <= 1'b1;
    if (bit_count == 15)
      ac97_synch <= 1'b0;

    // Generate the ready signal
    if (bit_count == 128)
      ready <= 1'b1;
    if (bit_count == 2)
      ready <= 1'b0;

    // Latch user data at the end of each frame. This ensures that the
    // first frame after reset will be empty.
    if (bit_count == 255) begin
      l_cmd_addr <= {command_address, 12'h000};
      l_cmd_data <= {command_data, 4'h0};
      l_cmd_v <= command_valid;
      l_left_data <= left_data;
      l_left_v <= left_valid;
      l_right_data <= right_data;
      l_right_v <= right_valid;
    end

    if ((bit_count >= 0) && (bit_count <= 15))
      // Slot 0: Tags
      case (bit_count[3:0])
        4'h0: ac97_sdata_out <= 1'b1;      // Frame valid
        4'h1: ac97_sdata_out <= l_cmd_v;   // Command address valid
        4'h2: ac97_sdata_out <= l_cmd_v;   // Command data valid
        4'h3: ac97_sdata_out <= l_left_v;  // Left data valid
        4'h4: ac97_sdata_out <= l_right_v; // Right data valid
        default: ac97_sdata_out <= 1'b0;
      endcase
    else if ((bit_count >= 16) && (bit_count <= 35))
      // Slot 1: Command address (8-bits, left justified)
      ac97_sdata_out <= l_cmd_v ? l_cmd_addr[35-bit_count] : 1'b0;
    else if ((bit_count >= 36) && (bit_count <= 55))
      // Slot 2: Command data (16-bits, left justified)
      ac97_sdata_out <= l_cmd_v ? l_cmd_data[55-bit_count] : 1'b0;
    else if ((bit_count >= 56) && (bit_count <= 75)) begin
      // Slot 3: Left channel
      ac97_sdata_out <= l_left_v ? l_left_data[19] : 1'b0;
      l_left_data <= { l_left_data[18:0], l_left_data[19] };
    end
    else if ((bit_count >= 76) && (bit_count <= 95))
      // Slot 4: Right channel
      ac97_sdata_out <= l_right_v ? l_right_data[95-bit_count] : 1'b0;
    else
      ac97_sdata_out <= 1'b0;

    bit_count <= bit_count+1;
  end // always @ (posedge ac97_bit_clock)

  always @(negedge ac97_bit_clock) begin
    if ((bit_count >= 57) && (bit_count <= 76))
      // Slot 3: Left channel
      left_in_data <= { left_in_data[18:0], ac97_sdata_in };
    else if ((bit_count >= 77) && (bit_count <= 96))
      // Slot 4: Right channel
      right_in_data <= { right_in_data[18:0], ac97_sdata_in };
  end
endmodule

// issue initialization commands to AC97
module ac97commands (
  input wire clock,
  input wire ready,
  output wire [7:0] command_address,
  output wire [15:0] command_data,
  output reg command_valid,
  input wire [4:0] volume,
  input wire [2:0] source
);
  reg [23:0] command;

  reg [3:0] state;
  initial begin
    command <= 4'h0;
    // synthesis attribute init of command is "0";
    command_valid <= 1'b0;
    // synthesis attribute init of command_valid is "0";
    state <= 16'h0000;
    // synthesis attribute init of state is "0000";
  end

  assign command_address = command[23:16];
  assign command_data = command[15:0];

  wire [4:0] vol;
  assign vol = 31-volume;  // convert to attenuation

  always @(posedge clock) begin
    if (ready) state <= state+1;

    case (state)
      4'h0: // Read ID
        begin
          command <= 24'h80_0000;
          command_valid <= 1'b1;
        end
      4'h1: // Read ID
        command <= 24'h80_0000;
      4'h3: // headphone volume
        command <= { 8'h04, 3'b000, vol, 3'b000, vol };
      4'h5: // PCM volume
        command <= 24'h18_0808;
      4'h6: // Record source select
        command <= { 8'h1A, 5'b00000, source, 5'b00000, source};
      4'h7: // Record gain = max
        command <= 24'h1C_0F0F;
      4'h9: // set +20db mic gain
        command <= 24'h0E_8048;
      4'hA: // Set beep volume
        command <= 24'h0A_0000;
      4'hB: // PCM out bypass mix1
        command <= 24'h20_8000;
      default:
        command <= 24'h80_0000;
    endcase // case(state)
  end // always @ (posedge clock)
endmodule // ac97commands

///////////////////////////////////////////////////////////////////////////////
//
// generate PCM data for 750hz sine wave (assuming f(ready) = 48khz)
//
///////////////////////////////////////////////////////////////////////////////

module tone750hz (
  input wire clock,
  input wire ready,
  output reg [19:0] pcm_data
);
   reg [8:0] index;

   initial begin
      index <= 8'h00;
      // synthesis attribute init of index is "00";
      pcm_data <= 20'h00000;
      // synthesis attribute init of pcm_data is "00000";
   end
   
   always @(posedge clock) begin
      if (ready) index <= index+1;
   end
   
   // one cycle of a sinewave in 64 20-bit samples
   always @(index) begin
      case (index[5:0])
        6'h00: pcm_data <= 20'h00000;
        6'h01: pcm_data <= 20'h0C8BD;
        6'h02: pcm_data <= 20'h18F8B;
        6'h03: pcm_data <= 20'h25280;
        6'h04: pcm_data <= 20'h30FBC;
        6'h05: pcm_data <= 20'h3C56B;
        6'h06: pcm_data <= 20'h471CE;
        6'h07: pcm_data <= 20'h5133C;
        6'h08: pcm_data <= 20'h5A827;
        6'h09: pcm_data <= 20'h62F20;
        6'h0A: pcm_data <= 20'h6A6D9;
        6'h0B: pcm_data <= 20'h70E2C;
        6'h0C: pcm_data <= 20'h7641A;
        6'h0D: pcm_data <= 20'h7A7D0;
        6'h0E: pcm_data <= 20'h7D8A5;
        6'h0F: pcm_data <= 20'h7F623;
        6'h10: pcm_data <= 20'h7FFFF;
        6'h11: pcm_data <= 20'h7F623;
        6'h12: pcm_data <= 20'h7D8A5;
        6'h13: pcm_data <= 20'h7A7D0;
        6'h14: pcm_data <= 20'h7641A;
        6'h15: pcm_data <= 20'h70E2C;
        6'h16: pcm_data <= 20'h6A6D9;
        6'h17: pcm_data <= 20'h62F20;
        6'h18: pcm_data <= 20'h5A827;
        6'h19: pcm_data <= 20'h5133C;
        6'h1A: pcm_data <= 20'h471CE;
        6'h1B: pcm_data <= 20'h3C56B;
        6'h1C: pcm_data <= 20'h30FBC;
        6'h1D: pcm_data <= 20'h25280;
        6'h1E: pcm_data <= 20'h18F8B;
        6'h1F: pcm_data <= 20'h0C8BD;
        6'h20: pcm_data <= 20'h00000;
        6'h21: pcm_data <= 20'hF3743;
        6'h22: pcm_data <= 20'hE7075;
        6'h23: pcm_data <= 20'hDAD80;
        6'h24: pcm_data <= 20'hCF044;
        6'h25: pcm_data <= 20'hC3A95;
        6'h26: pcm_data <= 20'hB8E32;
        6'h27: pcm_data <= 20'hAECC4;
        6'h28: pcm_data <= 20'hA57D9;
        6'h29: pcm_data <= 20'h9D0E0;
        6'h2A: pcm_data <= 20'h95927;
        6'h2B: pcm_data <= 20'h8F1D4;
        6'h2C: pcm_data <= 20'h89BE6;
        6'h2D: pcm_data <= 20'h85830;
        6'h2E: pcm_data <= 20'h8275B;
        6'h2F: pcm_data <= 20'h809DD;
        6'h30: pcm_data <= 20'h80000;
        6'h31: pcm_data <= 20'h809DD;
        6'h32: pcm_data <= 20'h8275B;
        6'h33: pcm_data <= 20'h85830;
        6'h34: pcm_data <= 20'h89BE6;
        6'h35: pcm_data <= 20'h8F1D4;
        6'h36: pcm_data <= 20'h95927;
        6'h37: pcm_data <= 20'h9D0E0;
        6'h38: pcm_data <= 20'hA57D9;
        6'h39: pcm_data <= 20'hAECC4;
        6'h3A: pcm_data <= 20'hB8E32;
        6'h3B: pcm_data <= 20'hC3A95;
        6'h3C: pcm_data <= 20'hCF044;
        6'h3D: pcm_data <= 20'hDAD80;
        6'h3E: pcm_data <= 20'hE7075;
        6'h3F: pcm_data <= 20'hF3743;
      endcase // case(index[5:0])
   end // always @ (index)
endmodule

/////////////////////////////////////////////////////////////////////////////////
////
//// 6.111 FPGA Labkit -- Template Toplevel Module
////
//// For Labkit Revision 004
//// Created: October 31, 2004, from revision 003 file
//// Author: Nathan Ickes, 6.111 staff
////
/////////////////////////////////////////////////////////////////////////////////

module lab5   (beep, audio_reset_b, ac97_sdata_out, ac97_sdata_in, ac97_synch,
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
   //lab5 assign audio_reset_b = 1'b0;
   //lab5 assign ac97_synch = 1'b0;
   //lab5 assign ac97_sdata_out = 1'b0;
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
   //assign flash_data = 16'hZ;
   //assign flash_address = 24'h0;
   //assign flash_ce_b = 1'b1;
   //assign flash_oe_b = 1'b1;
   //assign flash_we_b = 1'b1;
   //assign flash_reset_b = 1'b0;
   //assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs
   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

   // LED Displays
   //assign disp_blank = 1'b1;
   //assign disp_clock = 1'b0;
   //assign disp_rs = 1'b0;
   //assign disp_ce_b = 1'b1;
   //assign disp_reset_b = 1'b0;
   //assign disp_data_out = 1'b0;
   // disp_data_in is an input

   // Buttons, Switches, and Individual LEDs
   //lab5 assign led = 8'hFF;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
   //assign user1 = 32'hZ;
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
   //lab5 assign analyzer1_data = 16'h0;
   //lab5 assign analyzer1_clock = 1'b1;
   assign analyzer2_data = 16'h0;
   assign analyzer2_clock = 1'b1;
   //lab5 assign analyzer3_data = 16'h0;
   //lab5 assign analyzer3_clock = 1'b1;
   assign analyzer4_data = 16'h0;
   assign analyzer4_clock = 1'b1;
			    
//   wire [7:0] from_ac97_data, to_ac97_data;
//   wire ready;

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
   SRL16 #(.INIT(16'hFFFF)) reset_sr(.D(1'b0), .CLK(clock_27mhz), .Q(reset),
                                     .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
			
///////////////////////////////////////////
//			GENERATE 65MHz Clock				  //
///////////////////////////////////////////

   // use FPGA's digital clock manager to produce a
   // 65MHz clock (actually 64.8MHz)
   wire clock_65mhz_unbuf,clock_65mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_65mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 10
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 24
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_65mhz),.I(clock_65mhz_unbuf));

///////////////////////////////////////////
//				  DEBOUNCE INPUTS				  //
///////////////////////////////////////////

	wire upleft0, up0, upright0, left0, right0, downleft0, down0, downright0, enter;
	debounce db_ul(.clk(clock_27mhz), .reset(reset), .noisy(user1[31]), .clean(upleft0));
	debounce db_ur(.clk(clock_27mhz), .reset(reset), .noisy(user1[29]), .clean(upright0));
	debounce db_dl(.clk(clock_27mhz), .reset(reset), .noisy(user1[26]), .clean(downleft0));
	debounce db_dr(.clk(clock_27mhz), .reset(reset), .noisy(user1[24]), .clean(downright0));
	debounce db_u(.clk(clock_27mhz), .reset(reset), .noisy(user1[30]), .clean(up0));
	debounce db_d(.clk(clock_27mhz), .reset(reset), .noisy(user1[25]), .clean(down0));
	debounce db_l(.clk(clock_27mhz), .reset(reset), .noisy(user1[28]), .clean(left0));
	debounce db_r(.clk(clock_27mhz), .reset(reset), .noisy(user1[27]), .clean(right0));
	debounce db_e(.clk(clock_27mhz), .reset(reset), .noisy(button_enter), .clean(enter));
	
	wire diy_mode;
	debounce_ara db_diy(.clock(clock_27mhz), .reset(reset), .noisy(switch[7]), .clean(diy_mode));
	wire diy_playback;
	debounce_ara db_diypb(.clock(clock_27mhz), .reset(reset), .noisy(switch[6]), .clean(diy_playback));

///////////////////////////////////////////
//		CONVERT FLIP-FLOP BUTTON INPUTS	  //
///////////////////////////////////////////

	wire upleft, up, upright, left, right, downleft, down, downright;
	state_change_indicator sc_ul( 	.clk(clock_27mhz), .reset(reset),
														.changing_thing(upleft0), .state_change_pulse(upleft));
	state_change_indicator sc_ur( 	.clk(clock_27mhz), .reset(reset),
														.changing_thing(upright0), .state_change_pulse(upright));
	state_change_indicator sc_dl( 	.clk(clock_27mhz), .reset(reset),
														.changing_thing(downleft0), .state_change_pulse(downleft));
	state_change_indicator sc_dr( 	.clk(clock_27mhz), .reset(reset),
														.changing_thing(downright0), .state_change_pulse(downright));
	state_change_indicator sc_u( 	.clk(clock_27mhz), .reset(reset),
														.changing_thing(up0), .state_change_pulse(up));
	state_change_indicator sc_d( 	.clk(clock_27mhz), .reset(reset),
														.changing_thing(down0), .state_change_pulse(down));
	state_change_indicator sc_l( 	.clk(clock_27mhz), .reset(reset),
														.changing_thing(left0), .state_change_pulse(left));
	state_change_indicator sc_r( 	.clk(clock_27mhz), .reset(reset),
														.changing_thing(right0), .state_change_pulse(right));
	



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
	wire [3:0] display_state;
	wire request_mole;
	wire [22:0] music_address;
	parameter MAX_ITEM = 8'd128; 
	parameter INDEX_BITS = 8'd127; //depends on how many bits you might need to count up to max number of items 
	wire [MAX_ITEM-1:0] items; //this is a *count* of the number items stored in bram!!!!
	wire [MAX_ITEM-1:0] lookup_index;
	mole  #(.MAX_ITEM(MAX_ITEM)) 
			getmole (.clk(clock_27mhz), .reset(enter),
						.music_address(music_address),
						.game_state(display_state),
						.diy_playback(diy_playback),
						.total_moles(items),
						.one_hz_enable(one_hz_enable),
						.request_mole(request_mole));
						//.lookup_index(lookup_index));

	wire [1:0] lives;
	wire [7:0] score;
	wire ready_to_use;
	wire [23:0]index_address;
	wire [3:0]index_location;
	gameState game(.clk(clock_27mhz), .misstep(misstep),
						.whacked(whacked), .start(up),
						.reset(enter), .request_mole(request_mole),
						.expired(expired), .diy_mode(diy_mode),
						.ready_to_use(ready_to_use),
						.random_mole_location(random_mole_location),
						.start_timer(start_timer), .timer_value(timer_value),
						.display_state(display_state), .mole_location(mole_location), 
						.lives(lives), .score(score));
	
	/****Ara's code for sounds things here*/		
   wire [7:0] from_ac97_data, to_ac97_data;
   wire ready;

   // allow user to adjust volume
   reg [4:0] volume = 5'd8;
	
   // AC97 driver
   lab5audio a(clock_27mhz, reset, volume, from_ac97_data, to_ac97_data, ready,
	       audio_reset_b, ac97_sdata_out, ac97_sdata_in,
	       ac97_synch, ac97_bit_clock);

   // sound module
	
   sound_module s(.clock(clock_27mhz), .reset(reset), .ready(ready),
              .from_ac97_data(from_ac97_data), .to_ac97_data(to_ac97_data),
				  //.mole_loc(mole_location),
				  //.switch(switch),
				  //.disp_blank(disp_blank),
				  //.disp_clock(disp_clock),
				  //.disp_data_out(disp_data_out), 
				  //.disp_rs(disp_rs), 
				  //.disp_ce_b(disp_ce_b),
				  //.disp_reset_b(disp_reset_b),
				  .flash_data(flash_data),
				  .flash_address(flash_address),
				  .flash_ce_b(flash_ce_b),
				  .flash_oe_b(flash_oe_b),
				  .flash_we_b(flash_we_b),
				  .flash_reset_b(flash_reset_b),
				  .flash_byte_b(flash_byte_b),
				  .flash_sts(flash_sts),
				  .music_address(music_address),
				  .game_state(display_state),
				  .diy_mode(diy_mode));

   // output useful things to the logic analyzer connectors
   assign analyzer1_clock = ac97_bit_clock;
   assign analyzer1_data[0] = audio_reset_b;
   assign analyzer1_data[1] = ac97_sdata_out;
   assign analyzer1_data[2] = ac97_sdata_in;
   assign analyzer1_data[3] = ac97_synch;
   assign analyzer1_data[15:4] = 0;

   assign analyzer3_clock = ready;
   assign analyzer3_data = {from_ac97_data, to_ac97_data};

	//diy game module

	wire [2:0] state;
	assign lookup_index = (switch[6:3] <= items-1) ? switch[6:3] : 0 ; 	

 
	mole_adressss_locations #(.MAX_ITEM(MAX_ITEM), .INDEX_BITS(INDEX_BITS)) diy_addr_loc(.clock(clock_27mhz),
													//	.disp_blank(disp_blank),
													//	.disp_clock(disp_clock),
													//	.disp_data_out(disp_data_out), 
													//	.disp_rs(disp_rs), 
													//	.disp_ce_b(disp_ce_b),
													//	.disp_reset_b(disp_reset_b),
														.switch(switch),
													   .reset(reset),
														.upleft(upleft),
														.up(up),
														.upright(upright),
														.left(left),
														.right(right),
														.downleft(downleft),
														.down(down),
														.downright(downright),
														.enter(enter),
														.diy_mode(diy_mode),
														.one_hz_enable(one_hz_enable),
														.state(state),
														.lookup_index(lookup_index),
														.items(items),
														.flash_address(flash_address),
														.ready_to_use(ready_to_use),
														.index_address(index_address),
														.index_location(index_location));

	//VICTORIA'S CODE

   // feed XVGA signals
   wire [23:0] pixel;
   wire b,hs,vs;
	wire [10:0] hcount;
   wire [9:0] vcount;
   xvga xvga(.vclock(clock_65mhz),.hcount(hcount),.vcount(vcount),
              .hsync(hs),.vsync(vs),.blank(b));
		  
	displaymole displaymole1(.clk(clock_65mhz), .clk2(clock_27mhz), .reset(reset), .hcount(hcount), .vcount(vcount),
									.state(display_state), .mole_location(mole_location), .pixel(pixel));

   // VGA Output.  In order to meet the setup and hold times of the
   // AD7125, we send it ~clock_65mhz.disp_data_out
   assign vga_out_red = pixel[23:16];
   assign vga_out_green = pixel[15:8];
   assign vga_out_blue = pixel[7:0];
   assign vga_out_sync_b = 1'b1;    // not used
   assign vga_out_blank_b = ~b;
   assign vga_out_pixel_clock = ~clock_65mhz;
   assign vga_out_hsync = hs;
   assign vga_out_vsync = vs;	



/******************************************************************************/
//DAVIS CODE HERE

///////////////////////////////////////////
//						DEBUGGING		  			//
///////////////////////////////////////////



	// Blink w/ 2s period
	// Calculate displays
	reg toggler = 1'b1;
	reg [15:0] step_location;
	reg [7:0] feedback;
	reg [15:0] displayed_mole_location;
	reg [47:0] lives_display;
	always@(posedge clock_27mhz) begin
		toggler <= (down) ? ~toggler : toggler;
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
		case(mole_location)
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

	assign led = ~{upleft0, up0, upright0, left0, right0, downleft0, down0, downright0};

	// Display letter toggler value
	wire [127:0] string = {displayed_mole_location, 8'h30+display_state, "SCOR:", " ", 8'h30+score, lives_display};
	display_string debug_display(.reset(reset), .clock_27mhz(clock_27mhz),
											.string_data(string),
											.disp_blank(disp_blank),
											.disp_clock(disp_clock),
											.disp_data_out(disp_data_out), 
											.disp_rs(disp_rs), 
											.disp_ce_b(disp_ce_b),
											.disp_reset_b(disp_reset_b));
	
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
			else if (y_change == 256 + y_permanent)
				popup_done <= 1;
		end
	end
	

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
	assign pixel = (state == MOLE_ASCENDING || state == MOLE_COUNTDOWN) ? normal_pixel 
							: (state == MOLE_MISSED || state == MOLE_MISSED_SOUND || state == HAPPY_MOLE_DESCENDING) ? happy_pixel
							: (state == MOLE_WHACKED || state == MOLE_WHACKED_SOUND || state == DEAD_MOLE_DESCENDING) ? dead_pixel : 24'h0;
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