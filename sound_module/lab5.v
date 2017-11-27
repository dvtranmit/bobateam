`default_nettype none

///////////////////////////////////////////////////////////////////////////////
//
// Switch Debounce Module
//
///////////////////////////////////////////////////////////////////////////////

module debounce (
  input wire reset, clock, noisy,
  output reg clean
);
  reg [18:0] count;
  reg new;

  always @(posedge clock)
    if (reset) begin
      count <= 0;
      new <= noisy;
      clean <= noisy;
    end
    else if (noisy != new) begin
      // noisy input changed, restart the .01 sec clock
      new <= noisy;
      count <= 0;
    end
    else if (count == 270000)
      // noisy input stable for .01 secs, pass it along!
      clean <= new;
    else
      // waiting for .01 sec to pass
      count <= count+1;

endmodule

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

   // VGA Output
   assign vga_out_red = 10'h0;
   assign vga_out_green = 10'h0;
   assign vga_out_blue = 10'h0;
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
			    
   wire [7:0] from_ac97_data, to_ac97_data;
   wire ready;

   // allow user to adjust volume
   wire vup,vdown;
   reg old_vup,old_vdown;
   debounce bup(.reset(reset),.clock(clock_27mhz),.noisy(~button_up),.clean(vup));
   debounce bdown(.reset(reset),.clock(clock_27mhz),.noisy(~button_down),.clean(vdown));
   reg [4:0] volume;
   always @ (posedge clock_27mhz) begin
     if (reset) volume <= 5'd8;
     else begin
	if (vup & ~old_vup & volume != 5'd31) volume <= volume+1;       
	if (vdown & ~old_vdown & volume != 5'd0) volume <= volume-1;       
     end
     old_vup <= vup;
     old_vdown <= vdown;
   end

   // AC97 driver
   lab5audio a(clock_27mhz, reset, volume, from_ac97_data, to_ac97_data, ready,
	       audio_reset_b, ac97_sdata_out, ac97_sdata_in,
	       ac97_synch, ac97_bit_clock);

   // record module
 /*  recorder r(.clock(clock_27mhz), .reset(reset), .ready(ready),
              .switch(switch), .led(led), 
              .from_ac97_data(from_ac97_data), .to_ac97_data(to_ac97_data),
				  .flash_data(flash_data),
				  .flash_address(flash_address),
				  .flash_ce_b(flash_ce_b),
				  .flash_oe_b(flash_oe_b),
				  .flash_we_b(flash_we_b),
				  .flash_reset_b(flash_reset_b),
				  .flash_byte_b(flash_byte_b),
				  .flash_sts(flash_sts),
				  .disp_blank(disp_blank),
				  .disp_clock(disp_clock),
				  .disp_rs(disp_rs),
				  .disp_ce_b(disp_ce_b),
				  .disp_reset_b(disp_reset_b),
				  .disp_data_out(disp_data_out),
				  .disp_data_in(disp_data_in));
*/

   // sound module
   sound_module s(.clock(clock_27mhz), .reset(reset), .ready(ready),
              .switch(switch), .led(led), 
              .from_ac97_data(from_ac97_data), .to_ac97_data(to_ac97_data),
				  .flash_data(flash_data),
				  .flash_address(flash_address),
				  .flash_ce_b(flash_ce_b),
				  .flash_oe_b(flash_oe_b),
				  .flash_we_b(flash_we_b),
				  .flash_reset_b(flash_reset_b),
				  .flash_byte_b(flash_byte_b),
				  .flash_sts(flash_sts),
				  .disp_blank(disp_blank),
				  .disp_clock(disp_clock),
				  .disp_rs(disp_rs),
				  .disp_ce_b(disp_ce_b),
				  .disp_reset_b(disp_reset_b),
				  .disp_data_out(disp_data_out),
				  .disp_data_in(disp_data_in));

   // output useful things to the logic analyzer connectors
   assign analyzer1_clock = ac97_bit_clock;
   assign analyzer1_data[0] = audio_reset_b;
   assign analyzer1_data[1] = ac97_sdata_out;
   assign analyzer1_data[2] = ac97_sdata_in;
   assign analyzer1_data[3] = ac97_synch;
   assign analyzer1_data[15:4] = 0;

   assign analyzer3_clock = ready;
   assign analyzer3_data = {from_ac97_data, to_ac97_data};
endmodule


//sound module for DDR whack-a-mole
module sound_module(
  input wire clock,	                // 27mhz system clock
  input wire reset,                 // 1 to reset to initial state
  input wire ready,                 // 1 when AC97 data is available
  input wire [7:0] switch,    //using switches inputs as game states for now
  input wire [7:0] from_ac97_data, // 8-bit PCM data from mic
  input wire disp_data_in,			 // LED display signal
  input wire flash_sts,				 // flash signal
  output wire [15:0] flash_data,   // flash signals
  output wire [23:0] flash_address,// flash signals
  output wire flash_ce_b,           // flash signals
  output wire flash_oe_b,           // flash signals
  output wire flash_we_b,           // flash signals
  output wire flash_reset_b,        // flash signals
  output wire flash_byte_b,         // flash signals
  output wire disp_blank,           // LED display signal
  output wire disp_clock,           // LED display signal
  output wire disp_rs,              // LED display signal
  output wire disp_ce_b,            // LED display signal
  output wire disp_reset_b,         // LED display signal
  output wire disp_data_out,        // LED display signal
  output wire [7:0] led,			    // leds
  output reg [7:0] to_ac97_data    // 8-bit PCM data to headphone
);

	wire signed [17:0] filter_output; //filtered
	reg [7:0] filter_input; //input to filter	
	
	//flash will be hardcoded to readmode
	reg flash_reset = 0;
	reg writemode = 0;
	reg dowrite = 0;
	reg doread;
	wire busy;
	reg [22:0]raddr; //address for reading from flash
	wire [15:0] frdata; //data from flash reading
	reg [22:0]last_music_addr; //used to go back to the original location of music when things change
	wire [63:0]display_data; //data for display_16hex.v module

	wire display_reset; //to reset display_16hex.v module; switch7
	wire clean_sw0;
	wire clean_sw1;
	wire clean_sw2;

	
	debounce sw7(.reset(reset),.clock(clock),.noisy(switch[7]),.clean(display_reset));
	debounce sw0(.reset(reset),.clock(clock),.noisy(switch[0]),.clean(clean_sw0)); //switch 0 for game started
	debounce sw1(.reset(reset),.clock(clock),.noisy(switch[1]),.clean(clean_sw1)); //switch1's pulse for mole popup
	debounce sw2(.reset(reset),.clock(clock),.noisy(switch[2]),.clean(clean_sw2));
	
	wire [2:0] current_state;
	assign current_state = {clean_sw2,clean_sw1,clean_sw0};
	reg [2:0] last_state;
	assign display_data = {last_music_addr, frdata[15:0], 8'b0 ,1'b0, last_state[2:0],1'b0,current_state[2:0]};
	assign led[0] = ~flash_reset;
	assign led[1] = ~writemode; 
	assign led[2] = ~dowrite;
	assign led[3] = ~doread;
	assign led[4] = ~display_reset; //sw7
	assign led[5] = ~busy;
	assign led[6] = 1;
	assign led[7] = 1; 

	flash_manager flash_flash(.clock(clock), .reset(flash_reset), .writemode(writemode), .dowrite(dowrite),
										.doread(doread),  .busy(busy), .raddr(raddr), .frdata(frdata),
										.flash_data(flash_data), .flash_address(flash_address), .flash_ce_b(flash_ce_b), .flash_oe_b(flash_oe_b),
										.flash_we_b(flash_we_b), .flash_reset_b(flash_reset_b), .flash_sts(flash_sts), .flash_byte_b(flash_byte_b));
										
	display_16hex disp(.reset(display_reset), .clock_27mhz(clock), .data_in(display_data), 
		                .disp_rs(disp_rs), .disp_ce_b(disp_ce_b), .disp_blank(disp_blank),
							 .disp_reset_b(disp_reset_b), .disp_data_out(disp_data_out), .disp_clock(disp_clock));
							 
	//low pass filter
	fir31 fir31(.clock(clock), .reset(reset), .ready(ready), .x(filter_input), .y(filter_output));


	//address for background music and sound effects
	parameter MUSIC_START = 23'h0;
	parameter MUSIC_END = 23'h282F4;
	parameter POPUP_START = 23'h29600; //23'h29300 gives about 1 second delay for sound effect; 23'h29600 is good for immediate sound effect
	parameter POPUP_END = 23'h29C00; //23'h29D00 was a decent ending marker for the sound
	
	//states
	parameter GAME_NOT_STARTED = 3'h0;
	parameter GAMEPLAY_START = 3'h1;
	parameter MOLE_POPUP = 3'h3;
	
	reg pop_sound_done;
	
	always @ (posedge clock) begin
		if ((current_state == GAME_NOT_STARTED)) begin
			//before game starts
			to_ac97_data <= 0;
			raddr <= MUSIC_START;
			last_music_addr <= MUSIC_START;
			doread <= 0;
		end
		else if (!busy )begin //if flash is not busy, and game has started
			writemode <= 0;
			doread <= 1;
			filter_input <= frdata[7:0];
			last_state <= current_state;
			case (current_state)
				GAMEPLAY_START: begin 	//play background music
											pop_sound_done <= 0;
											if (last_state != current_state) begin
												raddr <= last_music_addr;
												if (ready) begin
													to_ac97_data <= filter_output[17:10];
												end
											end
											else begin
												if (ready) begin
													to_ac97_data <= filter_output[17:10];
													raddr <= (raddr >= MUSIC_END) ? MUSIC_START : raddr + 1;
													last_music_addr <= raddr;
												end
											end
										end
										
				MOLE_POPUP: 		begin
											if(last_state != current_state) begin
												//state changed so popup sound should start from beginning
												raddr <= POPUP_START;
												pop_sound_done <= 0;
												if (ready) begin
													to_ac97_data <= filter_output[17:10];
												end
											end
											else begin 
												//if state has not changed
												if (ready) begin
													to_ac97_data <= filter_output[17:10];
													if (!pop_sound_done) begin //if pop up sound effect not finished playing
														if (raddr >= POPUP_END) begin //if reached last address of pop up sound effect
															pop_sound_done <= 1;
															raddr <= last_music_addr;
														end
														else raddr <= raddr + 1; //if still more of pop up sound effect left to play
													end
													else begin //if finished pop up sound
														last_music_addr <= raddr;
														raddr <= (raddr >= MUSIC_END) ? MUSIC_START : raddr + 1;
													end
												end
											end
										end
				default: writemode <= 0;//do nothing
			endcase							
		end
	end

endmodule

///////////////////////////////////////////////////////////////////////////////
//
// Record/playback
//
///////////////////////////////////////////////////////////////////////////////


//one that has sampling issues but works in terms of reading and writing to flash!	
module recorder(
  input wire clock,	                // 27mhz system clock
  input wire reset,                 // 1 to reset to initial state
  input wire playback,              // 1 for playback, 0 for record
  input wire ready,                 // 1 when AC97 data is available
  input wire [7:0] switch,         // switches
  input wire [7:0] from_ac97_data, // 8-bit PCM data from mic
  input wire disp_data_in,			 // LED display signal
  input wire flash_sts,				 // flash signal
  output wire [15:0] flash_data,   // flash signals
  output wire [23:0] flash_address,// flash signals
  output wire flash_ce_b,           // flash signals
  output wire flash_oe_b,           // flash signals
  output wire flash_we_b,           // flash signals
  output wire flash_reset_b,        // flash signals
  output wire flash_byte_b,         // flash signals
  output wire disp_blank,           // LED display signal
  output wire disp_clock,           // LED display signal
  output wire disp_rs,              // LED display signal
  output wire disp_ce_b,            // LED display signal
  output wire disp_reset_b,         // LED display signal
  output wire disp_data_out,        // LED display signal
  output wire [7:0] led,			    // leds
  output reg [7:0] to_ac97_data    // 8-bit PCM data to headphone
);  

	parameter MAX_READ_ADDRESS = 23'h0F0005; //23'h025; //max address you want to read
														//to set max write address, change parameter MAX_ADDRESS in test_fsm.v
														//should be same as in test_fsm, slighty higher right now for testing purposes
														
	wire busy; //output from flash that tells you if flash is busy doing something
	wire [11:0] fsmstate; //output from flash for debugging purposes
	wire [639:0] dots; //output from flash for debugging purposes (dots is used with the display.v module)
	reg writemode;
	reg dowrite;
	reg doread;
	reg [15:0] wdata = 16'h0; //data to be written to flash when flash is under write mode
	reg [22:0]raddr; //address for reading from flash
	wire [15:0] frdata; //data from flash reading
	
	reg [3:0] flash_write_counter; //waitsome clock cycles between each write to flash
	wire [63:0]display_data; //data for display_16hex.v module
	
	wire display_reset; //to reset display_16hex.v module; switch0
	wire flash_reset; //to put flash in erase mode; switch3
	wire writing; //to put flash in write mode; switch5
	wire reading; //to put flash in read mode; switch6
	wire read_incr; //to increment the read address (will be incrementing everytime this goes from 0 to 1); switch7
	reg last_read_incr; //to store last read_incr value
	wire clean_sw1; //debounced switch1
	wire clean_sw2; //debounced switch2	
	
	assign display_data = {flash_data, raddr[15:0], wdata};
	assign led[0] = ~flash_reset; //sw3
	assign led[1] = ~writemode; 
	assign led[2] = ~dowrite;
	assign led[3] = ~doread;
	assign led[4] = ~display_reset; //sw0
	assign led[5] = ~busy;
	assign led[6] = ~writing; //sw5
	assign led[7] = ~reading; //sw6, sw7 for incrementing read address
	

	reg [7:0] ready_count;
	
	wire signed [17:0] filter_output; //filtered
	reg [7:0] filter_input; //input to filter
	

   debounce sw0(.reset(reset),.clock(clock),.noisy(switch[0]),.clean(display_reset));
	debounce sw1(.reset(reset),.clock(clock),.noisy(switch[1]),.clean(clean_sw1));
	debounce sw2(.reset(reset),.clock(clock),.noisy(switch[2]),.clean(clean_sw2));
   debounce sw3(.reset(reset),.clock(clock),.noisy(switch[3]),.clean(flash_reset));
	debounce sw5(.reset(reset),.clock(clock),.noisy(switch[5]),.clean(writing));
	debounce sw6(.reset(reset),.clock(clock),.noisy(switch[6]),.clean(reading));
	debounce sw7(.reset(reset),.clock(clock),.noisy(switch[7]),.clean(read_incr));
	
	flash_manager flash_flash(.clock(clock), .reset(flash_reset), .dots(dots),
										.writemode(writemode), .wdata(wdata), .dowrite(dowrite),
										.raddr(raddr), .frdata(frdata), .doread(doread), .busy(busy), .fsmstate(fsmstate),
										.flash_data(flash_data), .flash_address(flash_address), .flash_ce_b(flash_ce_b), .flash_oe_b(flash_oe_b),
										.flash_we_b(flash_we_b), .flash_reset_b(flash_reset_b), .flash_sts(flash_sts), .flash_byte_b(flash_byte_b));
										
	display_16hex disp(.reset(display_reset), .clock_27mhz(clock), .data_in(display_data), 
		                .disp_rs(disp_rs), .disp_ce_b(disp_ce_b), .disp_blank(disp_blank),
							 .disp_reset_b(disp_reset_b), .disp_data_out(disp_data_out), .disp_clock(disp_clock));
	
	//low pass filter
	fir31 fir31(.clock(clock), .reset(reset), .ready(ready), .x(filter_input), .y(filter_output));
	
always @(posedge clock) begin
	if(clean_sw1 & clean_sw2) begin
		//reset signals
		writemode <= 1;
		dowrite <= 0;
		doread <= 0;
		raddr <= 0;
		ready_count <= 0;
	end
	else begin
		//if not resetting signals then do things based on if flash is busy or not
		if(!busy) begin
			//if flash is not busy
			if (writing) begin
				writemode <= 1;
				doread <= 0;
				
				filter_input <= from_ac97_data;

				if (ready) begin
					ready_count <= ready_count + 1;
					if (ready_count == 7) begin //i think 6 7 or 8 will work for this?
						ready_count <= 0;
						dowrite <=1;
						wdata <= filter_output[17:10]; //from_ac97_data;
					end
				end
			end
	
			if (reading) begin
				writemode <= 0;
				doread <= 1;
				filter_input <= frdata[7:0];
				if (ready) begin
					to_ac97_data <= filter_output[17:10]; //frdata[7:0];
					if (raddr >= MAX_READ_ADDRESS) begin
						raddr <= 0;
					end
					else raddr <= raddr + 1;
				end
			end
		end
		else begin
			//if flash is busy
			if (writing) begin
				dowrite <= 0;
			end
		end
	end
end //always block end
endmodule


///////////////////////////////////////////////////////////////////////////////
//
// Verilog equivalent to a BRAM, tools will infer the right thing!
// number of locations = 1<<LOGSIZE, width in bits = WIDTH.
// default is a 16K x 1 memory.
//
///////////////////////////////////////////////////////////////////////////////

module mybram #(parameter LOGSIZE=14, WIDTH=1)
              (input wire [LOGSIZE-1:0] addr,
               input wire clk,
               input wire [WIDTH-1:0] din,
               output reg [WIDTH-1:0] dout,
               input wire we);
   // let the tools infer the right number of BRAMs
   (* ram_style = "block" *)
   reg [WIDTH-1:0] mem[(1<<LOGSIZE)-1:0];
   always @(posedge clk) begin
     if (we) mem[addr] <= din;
     dout <= mem[addr];
   end
endmodule

///////////////////////////////////////////////////////////////////////////////
//
// 31-tap FIR filter, 8-bit signed data, 10-bit signed coefficients.
// ready is asserted whenever there is a new sample on the X input,
// the Y output should also be sampled at the same time.  Assumes at
// least 32 clocks between ready assertions.  Note that since the
// coefficients have been scaled by 2**10, so has the output (it's
// expanded from 8 bits to 18 bits).  To get an 8-bit result from the
// filter just divide by 2**10, ie, use Y[17:10].
//
///////////////////////////////////////////////////////////////////////////////

module fir31(
  input wire clock,reset,ready,
  input wire signed [7:0] x,
  output reg signed [17:0] y //accumulator
);
  reg signed [17:0] sum;
  reg [4:0] offset;
  reg [4:0] index_reg;
  wire [4:0] index;
  assign index = index_reg;
  reg signed [7:0] sample [31:0]; //32 element array each 8 bits wide
  initial begin
		sum = 0;
		offset = 0;
		index_reg =0;
  end
  
  wire signed [9:0] coeff;
  coeffs31 coeffs31(.index(index),.coeff(coeff));
  
  always @(posedge clock) begin
		if (ready) begin
			sum <= 0;
			index_reg <= 0;
			offset <= offset+1;
			sample[offset] <= x;
		end
		else if (index_reg<= 30) begin
			index_reg <= index_reg + 1;
			sum <= sum+ coeff*sample[offset-index];
			if(index_reg == 30)
				y <= sum + coeff*sample[offset-index];
		end
  end
  /*
  // for now just pass data through
  always @(posedge clock) begin
    if (ready) y <= {x,10'd0};
  end
  */
endmodule

///////////////////////////////////////////////////////////////////////////////
//
// Coefficients for a 31-tap low-pass FIR filter with Wn=.125 (eg, 3kHz for a
// 48kHz sample rate).  Since we're doing integer arithmetic, we've scaled
// the coefficients by 2**10
// Matlab command: round(fir1(30,.125)*1024)
//
///////////////////////////////////////////////////////////////////////////////

module coeffs31(
  input wire [4:0] index,
  output reg signed [9:0] coeff
);
  // tools will turn this into a 31x10 ROM
  always @(index)
    case (index)
      5'd0:  coeff = -10'sd1;
      5'd1:  coeff = -10'sd1;
      5'd2:  coeff = -10'sd3;
      5'd3:  coeff = -10'sd5;
      5'd4:  coeff = -10'sd6;
      5'd5:  coeff = -10'sd7;
      5'd6:  coeff = -10'sd5;
      5'd7:  coeff = 10'sd0;
      5'd8:  coeff = 10'sd10;
      5'd9:  coeff = 10'sd26;
      5'd10: coeff = 10'sd46;
      5'd11: coeff = 10'sd69;
      5'd12: coeff = 10'sd91;
      5'd13: coeff = 10'sd110;
      5'd14: coeff = 10'sd123;
      5'd15: coeff = 10'sd128;
      5'd16: coeff = 10'sd123;
      5'd17: coeff = 10'sd110;
      5'd18: coeff = 10'sd91;
      5'd19: coeff = 10'sd69;
      5'd20: coeff = 10'sd46;
      5'd21: coeff = 10'sd26;
      5'd22: coeff = 10'sd10;
      5'd23: coeff = 10'sd0;
      5'd24: coeff = -10'sd5;
      5'd25: coeff = -10'sd7;
      5'd26: coeff = -10'sd6;
      5'd27: coeff = -10'sd5;
      5'd28: coeff = -10'sd3;
      5'd29: coeff = -10'sd1;
      5'd30: coeff = -10'sd1;
      default: coeff = 10'hXXX;
    endcase
endmodule