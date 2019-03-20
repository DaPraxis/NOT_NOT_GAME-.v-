module mux_ui (
	input change_instruction, 
	input reset_n,
	input clk,
	input clear_instruction,
	output VGA_CLK,   						//	VGA Clock
		output VGA_HS,							//	VGA H_SYNC
		output VGA_VS,							//	VGA V_SYNC
		output VGA_BLANK_N,						//	VGA BLANK
		output VGA_SYNC_N,						//	VGA SYNC
		output [9:0] VGA_R,   						//	VGA Red[9:0]
		output [9:0] VGA_G,	 						//	VGA Green[9:0]
		output [9:0] VGA_B,   						//	VGA Blue[9:0]
		output done
	);

	vga_adapter VGA(
			.resetn(reset_instructions),
			.clock(clk),
			.colour(color), 
			.x(x),
			.y(y),
			.plot(writeEn),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	wire [2:0] color; 
	wire [7:0] x;
	wire [6:0] y;
	wire [2:0] current_instruction; 
	wire [3:0] control_instructions;
	wire reset_instructions, done, writeEn;
	instruction_shift (change_instruction, reset_n, clk, current_instruction);
	mux_instructions(control_instructions, clk, reset_instructions, done, writeEn, x, y);
	mux_control(change_instruction, current_instruction, reset_n, done, clear_instruction,
		clk, reset_instructions, control_instructions, color);
	// clear_instruction paint the instruction back to black;
	// reset_instructions reset the instructions so that can be drawn

	// with a VGA adaptor

endmodule





module mux_instructions(
	input [3:0] instruction,  // input instruction with 4 bit, [3] clear when 1
	// [2:0] instruction 
	input clk, 
	input reset_n, 
	output done, 
	output reg writeEn, 
	output reg [2:0] color,
	output reg [7:0] x,
	output reg [6:0] y);
	reg en_u1, en_u1c, en_u2, en_u2c, en_u3, en_u3c, en_u4, en_u4c, en_u5, en_u5c, 
	en_u6, en_u6c;
	wire done1, done1c, done2, done2c, done3, done3c, done4, done4c, done5,
	done5c, done6, done6c;
	wire writeEn1, writeEn1c, writeEn2, writeEn2c, writeEn3, writeEn3c, writeEn4, 
	writeEn4c, writeEn5, writeEn5c, writeEn6, writeEn6c;
	

	localparam UP = 3'b000,
			   DOWN = 3'b001,
			   RIGHT = 3'b010, 
			   LEFT = 3'b011, 
			   R = 3'b100, 
			   L = 3'b101;

	wire [7:0] x1, x1c, x2, x2c, x3, x3c, x4, x4c, x5, x5c, x6, x6c;
	wire [6:0] y1, y1c, y2, y2c, y3, y3c, y4, y4c, y5, y5c, y6, y6c;

	always @(*) begin : proc_
		en_u1 = 0;
		en_u1c = 0;
		en_u2 = 0;
		en_u2c = 0 ;
		en_u3 = 0;
		en_u3c = 0;
		en_u4 = 0;
		en_u4c = 0;
		en_u5 = 0;
		en_u5c = 0;
		en_u6 = 0;
		en_u6c = 0;

		case (instruction[2:0])
			UP : if (instruction [3])
					en_u1c =1;
					x <= x1c;
					y <= y1c;
					done <= done1c;
					writeEn <= writeEn1c;
					color <= 3'b000;
				else 
					en_u1 = 1;
					x <= x1;
					y <= y1;
					done <= done1;
					writeEn <= writeEn1;
					color <= 3'b111;
			DOWN :  if (instruction [3])
						en_u2c =1;
						x <= x2c;
						y <= y2c;
						done <= done2c;
						writeEn <= writeEn2c;
						color <= 3'b000;
					else 
						en_u2 = 1;
						x <= x2;
						y <= y2;
						done <= done2;
						writeEn <= writeEn2;
						color <= 3'b001;
			RIGHT : if (instruction [3])
						en_u3c =1;
						x <= x3c;
						y <= y3c;
						done <= done3c;
						writeEn <= writeEn3c;
						color <= 3'b000;
					else 
						en_u3 = 1;
						x <= x3;
						y <= y3;
						done <= done3;
						writeEn <= writeEn3;
						color <= 3'b011;
			LEFT :  if (instruction [3])
						en_u4c =1;
						x <= x4c;
						y <= y4c;
						done <= done4c;
						writeEn <= writeEn4c;
						color <= 3'b000;
					else 
						en_u4 = 1;
						x <= x4;
						y <= y4;
						done <= done4;
						writeEn <= writeEn4;
						color <= 3'b010;
			R : if (instruction [3])
					en_u5c =1;
					x <= x5c;
					y <= y5c;
					done <= done5c;
					writeEn <= writeEn5c;
					color <= 3'b000;
				else 
					en_u5 = 1;
					x <= x5;
					y <= y5;
					done <= done5;
					writeEn <= writeEn5;
					color <= 3'b100;
			L : if (instruction [3])
					en_u6c =1;
					x <= x6c;
					y <= y6c;
					done <= done6c;
					writeEn <= writeEn6c;
					color <= 3'b000;
				else 
					en_u6 = 1;
					x <= x6;
					y <= y6;
					done <= done6;
					writeEn <= writeEn6;
					color <= 3'b101;
			
		endcase
	end
	
	ui_UP u1 (clk, reset_n, en_u1, x1, y1, done1, writeEn1);  
	// hard coding color for instructions and clear
	ui_UP u1c (clk, reset_n, en_u1c, x1c, y1c, done1c, writeEn1c);
	ui_DOWN u2 (clk, reset_n, en_u2, x2, y2, done2, writeEn2);
	ui_DOWN u2c (clk, reset_n, en_u2c, x2c, y2c, done2c, writeEn2c);
	ui_RIGHT u3 (clk, reset_n, en_u3, x3, y3, done3, writeEn3);
	ui_RIGHT u3c (clk, reset_n, en_u3c, x3c, y3c, done3c, writeEn3c);
	ui_LEFT u4 (clk, reset_n, en_u4, x4, y4, done4, writeEn4);
	ui_LEFT u4c (clk, reset_n, en_u4c, x4c, y4c, done4c, writeEn4c);
	ui_R u5 (clk, reset_n, en_u5, x5, y5, done5, writeEn5);
	ui_R u5c (clk, reset_n, en_u5c, x5c, y5c, done5c, writeEn5c);
	ui_L u6 (clk, reset_n, en_u6, x6, y6, done6, writeEn6);
	ui_L u6c (clk, reset_n, en_u6c, x6c, y6c, done6c, writeEn6c);
	

endmodule 

module mux_control(
		input enable,  // corresponding to change_instruction flag, flip
		input [2:0]instruction,
		input reset_n,
		input done, 
		input clear, // Clear the instruction, paint to black
		input clk,
		output reg reset_instructions, 
		output reg [3:0] control_instructions
		);

	localparam UP = 6'b000000, 
			   UP_WAIT = 6'b000001,
			   UP_CLEAR = 6'b000010,
			   UP_CLEAR_WAIT = 6'b000011, 
			   DOWN = 6'b000100, 
			   DOWN_WAIT = 6'b000101,
			   DOWN_CLEAR = 6'b000110,
			   DOWN_CLEAR_WAIT = 6'b000111,
			   LEFT = 6'b001000, 
			   LEFT_WAIT = 6'b001001,
			   LEFT_CLEAR = 6'b001010,
			   LEFT_CLEAR_WAIT = 6'b001011,
			   RIGHT = 6'b001100 , 
			   RIGHT_WAIT = 6'b001101,
			   RIGHT_CLEAR = 6'b001110,
			   RIGHT_CLEAR_WAIT = 6'b001111,
			   L = 6'b010000 , 
			   L_WAIT = 6'b010001,
			   L_CLEAR = 6'b010010,
			   L_CLEAR_WAIT = 6'b010011,
			   R = 6'b010100 , 
			   R_WAIT = 6'b010101,
			   R_CLEAR = 6'b010110,
			   R_CLEAR_WAIT = 6'b010111,
			   ON_HOLD = 6'b011000,
			   PREPARE_INSTRUCTION = 6'b011001;

	reg [5:0] CURRENT_STATE, NEXT_STATE;
	reg [5:0] clear_state; // register state to be cleared
	reg clear_ui;	   
	always @(*) begin : proc_
		case (CURRENT_STATE)
			ON_HOLD : NEXT_STATE =  enable ? PREPARE_INSTRUCTION: ON_HOLD;
			PREPARE_INSTRUCTION : 
				if ((!enable) & (!clear_ui))
				begin
					case (instruction)
						3'b000:  NEXT_STATE = UP;    // UP
						3'b001:  NEXT_STATE = DOWN;  // DOWN
					 	3'b010:  NEXT_STATE = LEFT;  // LEFT
						3'b011:  NEXT_STATE = RIGHT; // RIGHT
						3'b100:  NEXT_STATE = L;   	 // L
						3'b101:  NEXT_STATE = R;     // R
					endcase
				end
				else if ((!enable) & (clear_ui))
				begin
					case (instruction)
						3'b000:  NEXT_STATE = UP_CLEAR;    // UP
						3'b001:  NEXT_STATE = DOWN_CLEAR;  // DOWN
					 	3'b010:  NEXT_STATE = LEFT_CLEAR;  // LEFT
						3'b011:  NEXT_STATE = RIGHT_CLEAR; // RIGHT
						3'b100:  NEXT_STATE = L_CLEAR;     // L
						3'b101:  NEXT_STATE = R_CLEAR;     // R
					endcase
				end
				else 
					begin
					NEXT_STATE = PREPARE_INSTRUCTION;
					end
			UP: NEXT_STATE = done ? UP_WAIT : UP;
			UP_WAIT: NEXT_STATE = done ? UP_WAIT : ON_HOLD;
			DOWN: NEXT_STATE = done ? DOWN_WAIT : DOWN;
			DOWN_WAIT: NEXT_STATE = done ? DOWN_WAIT : ON_HOLD;
			RIGHT: NEXT_STATE = done ? RIGHT_WAIT : RIGHT;
			RIGHT_WAIT: NEXT_STATE = done ? RIGHT_WAIT : ON_HOLD;
			LEFT: NEXT_STATE = done ? LEFT_WAIT : LEFT;
			LEFT_WAIT: NEXT_STATE = done ? LEFT_WAIT : ON_HOLD;
			L: NEXT_STATE = done ? L_WAIT : L;
			L_WAIT: NEXT_STATE = done ? L_WAIT : ON_HOLD;
			R: NEXT_STATE = done ? R_WAIT : R;
			R_WAIT: NEXT_STATE = done ? R_WAIT : ON_HOLD;
			//
			UP_CLEAR: NEXT_STATE = done ? UP_CLEAR_WAIT : UP_CLEAR;
			UP_CLEAR_WAIT: NEXT_STATE = done ? UP_CLEAR_WAIT : ON_HOLD;
			DOWN_CLEAR: NEXT_STATE = done ? DOWN_CLEAR_WAIT : DOWN_CLEAR;
			DOWN_CLEAR_WAIT: NEXT_STATE = done ? DOWN_CLEAR_WAIT : ON_HOLD;
			RIGHT_CLEAR: NEXT_STATE = done ? RIGHT_CLEAR_WAIT : RIGHT_CLEAR;
			RIGHT_CLEAR_WAIT: NEXT_STATE = done ? RIGHT_CLEAR_WAIT : ON_HOLD;
			LEFT_CLEAR: NEXT_STATE = done ? LEFT_CLEAR_WAIT : LEFT_CLEAR;
			LEFT_CLEAR_WAIT: NEXT_STATE = done ? LEFT_CLEAR_WAIT : ON_HOLD;
			L_CLEAR: NEXT_STATE = done ? L_CLEAR_WAIT : L_CLEAR;
			L_CLEAR_WAIT: NEXT_STATE = done ? L_CLEAR_WAIT : ON_HOLD;
			R_CLEAR: NEXT_STATE = done ? R_CLEAR_WAIT : R;
			R_CLEAR_WAIT: NEXT_STATE = done ? R_CLEAR_WAIT : ON_HOLD;

			
			default : /* default */;
		endcase
	end

	always @(*) begin : FSM_ASS
		reset_instructions = 1'b1;
		case (CURRENT_STATE)
			PREPARE_INSTRUCTION: 
				clear ? clear_ui <= clear; // used for later
			ON_HOLD:
				clear_ui <= 0;
				reset_instructions = 0;
			UP: control_instructions <= 4'b0000;
			DOWN: control_instructions <= 4'b0001;
			RIGHT: control_instructions <= 4'b0010;
			LEFT: control_instructions <= 4'b0011;
			R: control_instructions <= 4'b0100;
			L: control_instructions <= 4'b0101;
			UP_CLEAR: control_instructions <= 4'b1000;
			DOWN_CLEAR: control_instructions <= 4'b1001;
			RIGHT_CLEAR: control_instructions <= 4'b1010;
			LEFT_CLEAR: control_instructions <= 4'b1011;
			R_CLEAR: control_instructions <= 4'b1100;
			L_CLEAR: control_instructions <= 4'b1101;


		endcase
	
	end

	always @(posedge clock) begin : proc_
		if(~reset_n) begin
			CURRENT_STATE <= ON_HOLD;
		end else begin
			CURRENT_STATE <= NEXT_STATE;
		end
	end


endmodule

// change instruction when change_instruction is high
module instruction_shift(
	input change_instruction, 
	input clk,
	input rst_n,
	output reg [2:0] instruction);
	wire [3:0]random;
	reg [3:0]ran;
	random r1 (clk, rst_n, random);
	always @(posedge change_instruction) begin : proc_
		ran <= random;
		if (ran < 4'b0011)
			instruction <= 3'b000; // UP
		else if (ran < 4'b0110)
			instruction <= 3'b001; // DOWN
		else if (ran < 4'b1001)
			instruction <= 3'b010; // LEFT
		else if (ran < 4'b1011)
			instruction <= 3'b011; // RIGHT
		else if (ran < 4'b1101)
			instruction <= 3'b100; // VOWEL
		else 
			instruction <= 3'b101; // DIGIT
	end
	

endmodule // module


module dff_0(clock,reset_n,data_in,q);
		input clock,reset_n,data_in;
		output reg q;
		always@(posedge clock)
		   begin
			if(reset_n == 0) 
				  q <= 1'b0; 
			else
				  q<= data_in;
			end
endmodule

module dff_1(clock,reset_n,data_in,q);
		input clock,reset_n,data_in;
		output reg q;
		always@(posedge clock)
		   begin
			if(reset_n == 0) 
				  q <= 1'b1; 
			else
				  q<= data_in;
			end
endmodule



module random(clock,reset_n,q);
		input clock,reset_n;
		output [3:0] q;
		
		dff_0 m1(clock,reset_n,q[2] ^ q[3],q[0]);
		dff_1 m2(clock,reset_n,q[0],q[1]);
		dff_1 m3(clock,reset_n,q[1],q[2]);
		dff_1 m4(clock,reset_n,q[2],q[3]);
endmodule