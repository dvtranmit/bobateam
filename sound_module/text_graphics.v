`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:11:06 12/09/2017 
// Design Name: 
// Module Name:    text_graphics 
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

/////////////////////////////////////////////////////////////////////////////////
//
// TEXT MODULES
//
/////////////////////////////////////////////////////////////////////////////////

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
