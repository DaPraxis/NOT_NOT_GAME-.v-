
// module mux_ui ( // testing
// 	input change_instruction, 
// 	input reset_n,
// 	input clk,
// 	input clear_instruction,
// 	output [7:0] x,
// 	output [6:0] y,
// 	output [2:0] color,
// 	output writeEn
// 	);

// 	wire [3:0] control_instructions;
// 	wire reset_instructions, done;
// 	wire [2:0] current_instruction;
// 	instruction_shift i1(change_instruction, clk, current_instruction);
// 	mux_instructions i2(change_instruction, control_instructions, clk, reset_instructions, done, writeEn, color, x, y);
// 	mux_control i3(change_instruction, current_instruction, reset_n, done, clear_instruction,
// 		clk, reset_instructions, control_instructions);

// 	// after recieve done, 0-1-0, we have clear set to high for one pulse
	

// endmodule 

module mux_ui_test_inlab(
	input [9:0] SW,
	input CLOCK_50,
	input [3:0] KEY,
	output [9:0] LEDR,
	output VGA_CLK,   						//	VGA Clock
		output VGA_HS,							//	VGA H_SYNC
		output VGA_VS,							//	VGA V_SYNC
		output VGA_BLANK_N,						//	VGA BLANK
		output VGA_SYNC_N,						//	VGA SYNC
		output [9:0] VGA_R,   						//	VGA Red[9:0]
		output [9:0] VGA_G,	 						//	VGA Green[9:0]
		output [9:0] VGA_B  						//	VGA Blue[9:0]
		);

	mux_ui_ff c1(SW[0],KEY[0], CLOCK_50, SW[1], VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N,	VGA_R,
			VGA_G, VGA_B, LEDR[0] , LEDR[9:4]);


endmodule

module mux_ui_ff ( // clear_instruction need to be set with high change_instruction; 
	// reset to change instruction, no reset for clear
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
		output [9:0] VGA_B,  						//	VGA Blue[9:0]
		output done_signal,
		output [5:0] CURRENT_STATE
	);

	vga_adapter VGA(
			.resetn(reset_n),
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
	wire [3:0] control_instructions;
	wire reset_instructions, done, writeEn;
	wire [2:0] current_instruction;
	assign done_signal = done;
	instruction_shift i1(change_instruction, clk, reset_n, current_instruction);
	mux_instructions i2(change_instruction, control_instructions, clk, reset_instructions, done, writeEn, x, y);
	mux_control i3(clear_instruction, change_instruction, current_instruction, reset_n, done,
		clk, reset_instructions, control_instructions, CURRENT_STATE, color);
	//always (posedge clk)
	//begin
	//	if (clear_instruction | !reset_n)
	//	begin
	//		vga_color <= 3'b000;
	//	end
	//	else // if (change_instruction)
	//	begin
	//		vga_color <= color;
	//	end
	//end
//	// clear_instruction paint the instruction back to black;
//	// reset_instructions reset the instructions so that can be drawn
//
//	// with a VGA adaptor
//
endmodule





module mux_instructions(
	input enable,
	input [3:0] instruction,  // input instruction with 4 bit, [3] clear when 1
	// [2:0] instruction 
	input clk, 
	input reset_n, 
	output reg done, 
	output reg writeEn, 
	output reg [7:0] x,
	output reg [6:0] y);
	reg en_u1,  en_u2,  en_u3,  en_u4,  en_u5,  en_u6;
	reg reset_1, reset_2, reset_3, reset_4, reset_5, reset_6;
	wire done1, done2, done3, done4, done5, done6;
	wire writeEn1, writeEn2, writeEn3, writeEn4, writeEn5, writeEn6;
	reg [3:0] CURRRENT_INSTRUCTION;
	
	
	

	localparam UP = 3'b000,
			   DOWN = 3'b001,
			   RIGHT = 3'b010, 
			   LEFT = 3'b011, 
			   R = 3'b100, 
			   L = 3'b101,
				NULL = 3'b110;

	wire [7:0] x1, x2, x3, x4, x5, x6;
	wire [6:0] y1, y2, y3, y4, y5, y6;

	always @(*) begin : FFFF
		en_u1 = 0;
		reset_1 = 0;
		en_u2 = 0;
		reset_2 = 0 ;
		en_u3 = 0;
		reset_3 = 0;
		en_u4 = 0;
		reset_4 = 0;
		en_u5 = 0;
		reset_5 = 0;
		en_u6 = 0;
		reset_6 = 0;

		case (CURRRENT_INSTRUCTION[2:0])
			UP : 
				begin
				en_u1 = 1;
				x = x1;
				y = y1;
				done = done1;
				writeEn = writeEn1;
				reset_1 = 1;
				end
			DOWN :  
				begin
				en_u2 = 1;
				x = x2;
				y = y2;
				done = done2;
				writeEn = writeEn2;
				reset_2 = 1;
				end
			RIGHT : 
				begin
				en_u3 = 1;
				x = x3;
				y = y3;
				done = done3;
				writeEn = writeEn3;
				reset_3 = 1;
				end
			LEFT :  
				begin
				en_u4 = 1;
				x = x4;
				y = y4;
				done = done4;
				writeEn = writeEn4;
				reset_4 = 1;
				end
			R : 
				begin
				en_u5 = 1;
				x = x5;
				y = y5;
				done = done5;
				writeEn = writeEn5;
				reset_5 = 1;
				end
			L : 
				begin
				en_u6 = 1;
				x = x6;
				y = y6;
				done = done6;
				writeEn = writeEn6;
				reset_6 = 1;
				end
			
		endcase
	end
	
	ui_UP u1 (clk, reset_1, en_u1, x1, y1, done1, writeEn1);  
	ui_DOWN u2 (clk, reset_2, en_u2, x2, y2, done2, writeEn2);
	ui_RIGHT u3 (clk, reset_3, en_u3, x3, y3, done3, writeEn3);
	ui_LEFT u4 (clk, reset_4, en_u4, x4, y4, done4, writeEn4);
	ui_R u5 (clk, reset_5, en_u5, x5, y5, done5, writeEn5);
	ui_L u6 (clk, reset_6, en_u6, x6, y6, done6, writeEn6);
	
	always@(posedge clk)
	begin
	if (!reset_n)
		begin
			CURRRENT_INSTRUCTION [2:0] <= NULL; 
		end
	else if (enable)
	begin
			CURRRENT_INSTRUCTION <=instruction; // update instruction if enabled
			
	end
	end
	

endmodule 

module mux_control(
		input clear,
		input enable,  // corresponding to change_instruction flag, flip
		input [2:0]instruction,
		input reset_n,
		input done, 
		input clk,
		output reg reset_instructions, 
		output reg [3:0] control_instructions,
		output reg [5:0] CURRENT_STATE,
		output reg [2:0] color
		);


	localparam UP = 6'b000000, 
			   UP_WAIT = 6'b000001,
	
			   DOWN = 6'b000100, 
			   DOWN_WAIT = 6'b000101,
			   
			   LEFT = 6'b001000, 
			   LEFT_WAIT = 6'b001001,
			   
			   RIGHT = 6'b001100 , 
			   RIGHT_WAIT = 6'b001101,
			   
			   L = 6'b010000 , 
			   L_WAIT = 6'b010001,
			   
			   R = 6'b010100 , 
			   R_WAIT = 6'b010101,
			   
			   ON_HOLD = 6'b011000,
			   PREPARE_INSTRUCTION = 6'b011001,
			   
			   ON_HOLD_WAIT = 6'b011101;

	reg [5:0]  NEXT_STATE;	   
	always @(*) begin : proc_
		case (CURRENT_STATE)
			ON_HOLD : NEXT_STATE = ON_HOLD_WAIT;
			ON_HOLD_WAIT : NEXT_STATE =  (enable) ? PREPARE_INSTRUCTION: ON_HOLD_WAIT;
			PREPARE_INSTRUCTION : 
				if (!enable)
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
			UP: NEXT_STATE = done ? UP_WAIT : UP;
			UP_WAIT: NEXT_STATE = done ? UP_WAIT : ON_HOLD_WAIT;
			DOWN: NEXT_STATE = done ? DOWN_WAIT : DOWN;
			DOWN_WAIT: NEXT_STATE = done ? DOWN_WAIT : ON_HOLD_WAIT;
			RIGHT: NEXT_STATE = done ? RIGHT_WAIT : RIGHT;
			RIGHT_WAIT: NEXT_STATE = done ? RIGHT_WAIT : ON_HOLD_WAIT;
			LEFT: NEXT_STATE = done ? LEFT_WAIT : LEFT;
			LEFT_WAIT: NEXT_STATE = done ? LEFT_WAIT : ON_HOLD_WAIT;
			L: NEXT_STATE = done ? L_WAIT : L;
			L_WAIT: NEXT_STATE = done ? L_WAIT : ON_HOLD_WAIT;
			R: NEXT_STATE = done ? R_WAIT : R;
			R_WAIT: NEXT_STATE = done ? R_WAIT : ON_HOLD_WAIT;
			
			
			default : /* default */;
		endcase
	end

	always @(*) begin : FSM_ASS
		reset_instructions <= 1'b1;
		case (CURRENT_STATE)
			ON_HOLD:
				begin
				reset_instructions <= 0;
				color <= 3'b000;
				end
			UP: 
			begin
			control_instructions <= 4'b0000;
			color <= (clear)? 3'b000:3'b001;
			end
			DOWN: 
			begin
			control_instructions <= 4'b0001;
			color <= (clear)? 3'b000:3'b010;
			end
			RIGHT: 
			begin
			control_instructions <= 4'b0010;
			color <= (clear)? 3'b000:3'b011;
			end
			LEFT: 
			begin
			control_instructions <= 4'b0011;
			color <= (clear)? 3'b000:3'b100;
			end
			R: 
			begin
			control_instructions <= 4'b0100;
			color <= (clear)? 3'b000:3'b101;
			end
			L: 
			begin
			control_instructions <= 4'b0101;
			color <= (clear)? 3'b000:3'b110;
			end
		endcase
	
	end
	

	always @(posedge clk) begin : FF
		if(!reset_n) begin
			CURRENT_STATE <= ON_HOLD;
		end 
		else
		begin
			CURRENT_STATE <= NEXT_STATE;
		end
	end


endmodule



module instruction_shift_control (
	input clk,
	input reset_n,
	output reg reset_random);
// random need to be initialized with reset, but only once, we need control
reg [1:0] CURRENT_STATE, NEXT_STATE;



localparam START = 2'b01, 
		   RESET = 2'b10,
		   DONE = 2'b11;



always @(*)
	begin
		case (CURRENT_STATE)
			START: NEXT_STATE = (reset_n)? RESET : START;
			RESET: NEXT_STATE = DONE;
			DONE: NEXT_STATE = DONE;
		endcase
	end

always @(*)
	begin
	reset_random = 1;
		case (CURRENT_STATE)
			RESET: reset_random = 0;
		endcase
	end

always @(posedge clk)
	begin
		if (!reset_n)
		begin
		CURRENT_STATE <= START;
		end
		
		else 
		begin
		CURRENT_STATE <= NEXT_STATE;	
		end
	end

endmodule



// change instruction when change_instruction is high, no need for reseting instruction_shift
module instruction_shift(
	input change_instruction, 
	input clk,
	input reset_n,  // reset only the control, only once by FSM
	output reg [2:0] instruction);
	wire [3:0]random;
	wire rst_n;
	reg [3:0] ran;
	wire enable_control;
	// reset this machine automatically in first 2 clk
	
	instruction_shift_control c0 (clk, reset_n ,rst_n);
	
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
			instruction <= 3'b100; // L
		else 
			instruction <= 3'b101; // R
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




// for all the instruction UIs
// this is the ui component we use to connect with mux_ui
module ui_UP
	(
		input clk,						
        input reset_vga, // reset controller
        input enable_control, // enable the control
		output [7:0] x,
		output [6:0] y, 
		output done,
		output writeEn);
	wire enable, reset_datapath;
	control_UI c0(clk, reset_vga, enable_control, enable, writeEn, reset_datapath);
	datapath_up d0(clk, reset_datapath, enable, x, y, done);

endmodule



// no limit for enable
module control_UI(input clk, 
			   input reset_n,
			   input enable_unit,
			   output reg enable, 
			   output reg writeEn,
			   output reg reset_datapath);

	localparam 	ENABLE_STATE = 4'b0000, 
				ENABLE_WAIT = 4'b0001, 
				DRAW = 4'b0010,
				DISABLE = 4'b0011;
	reg [1:0] current_state, next_state;

	always @(*) begin
		case (current_state)
			DISABLE : next_state = (enable_unit) ? DRAW : DISABLE;
			// ENABLE_STATE : next_state = (enable_unit) ? ENABLE_STATE : ENABLE_WAIT;
			// ENABLE_WAIT : next_state = DRAW;
			DRAW : next_state = (reset_n) ? DRAW : DISABLE;
		endcase
	end

	always @(*) begin
		enable = 1'b0;
		writeEn = 1'b0;
		reset_datapath = 1'b0;
		case (current_state)
			DRAW: begin
				enable = 1'b1;
				writeEn = 1'b1;
				reset_datapath = 1'b1;
			end
		endcase
	end

	always @(posedge clk) begin
		if (!reset_n) begin
			current_state <= DISABLE;
		end
		else begin
			current_state <= next_state;
		end
	end
endmodule


module datapath_up (input clk, 
				input reset_n, 
				input enable, 
				output reg [7:0] x,
				output reg [6:0] y,
				output done // signal for all ui drawing is done
				);

	// could vary according to shape
	wire [2:0] increment1;
	wire [2:0] increment2;
	wire [2:0] increment3;
	// when rate division done, frame enabled
	wire [24:0] rate_out;
	wire frame_enable;
	// when frame division done, x enabled 
	wire [4:0] frame_out;
	wire enable1, enable2, enable3;

	
	always @(posedge clk) begin : proc_
		if (!reset_n)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end
		else if (done)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end	
		else if (enable3)
		begin
			x <= 8'd79 - increment3;
			y <= 7'd63 + increment3;

		end
		else if (enable2)
		begin
			x <= 8'd79 + increment2;
			y <= 7'd63 + increment2;
		end
		else if (enable1)
		begin
			x <= 8'd79;
			y <= 7'd63 + increment1;
		end
	
	end
	// rate divider
	rate_divider rate(clk, reset_n, enable, rate_out); 
	assign frame_enable = (rate_out == 25'd0) ? 1 : 0;
	
	// frame counter
	frame_counter frame(clk, frame_enable, reset_n, frame_out);
	 assign enable1 = (frame_out == 4'd4) ? 1 : 0;  // DRAW IN 4 FRAME
	

	counter_8 c1(clk, enable1, reset_n, increment1);
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b111) ? 1 : 0;
	
	counter_4 c2(clk, enable2 & frame_enable, reset_n, increment2);

	assign enable3 = (increment2 == 3'b011) ? 1 : 0;

	counter_4 c3(clk, enable3 & frame_enable, reset_n, increment3);
	
	assign done = (frame_out == 5'd15) ? 1 : 0;
	// start done in 17 frame
	
	
	
endmodule


module test_rate_divider(
		input clk,
		input reset_n,
		input enable,
		output [3:0] frame_out);

		wire [24:0] rate_out;

	rate_divider rate(clk, reset_n, enable, rate_out); 
	assign frame_enable = (rate_out == 25'd0) ? 1 : 0;
	frame_counter frame(clk, frame_enable, reset_n, frame_out);


endmodule



module ui_DOWN
	(
		input clk,						
        input reset_vga, // reset controller
        input enable_control, // enable the control
		output [7:0] x,
		output [6:0] y, 
		output done,
		output writeEn);
		wire enable, reset_datapath;
	control_UI c0(clk, reset_vga, enable_control, enable, writeEn, reset_datapath);
	datapath_down d0(clk, reset_datapath, enable, x, y, done);


endmodule


module datapath_down (input clk, 
				input reset_n, 
				input enable, 
				output reg [7:0] x,
				output reg [6:0] y,
				output done // signal for all ui drawing is done
				);

	// could vary according to shape
	wire [2:0] increment1;
	wire [2:0] increment2;
	wire [2:0] increment3;
	// when rate division done, frame enabled
	wire [24:0] rate_out;
	wire frame_enable;
	// when frame division done, x enabled 
	wire [4:0] frame_out;
	wire enable1, enable2, enable3;

	
	always @(posedge clk) begin : proc_
		if (!reset_n)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end
		else if (done)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end	
		else if (enable3)
		begin
			x <= 8'd79 - increment3;
			y <= 7'd63 + increment3;

		end
		else if (enable2)
		begin
			x <= 8'd79 + increment2;
			y <= 7'd63 + increment2;
		end
		else if (enable1)
		begin
			x <= 8'd79;
			y <= 7'd63 + increment1;
		end
	
	end
	// rate divider
	rate_divider rate(clk, reset_n, enable, rate_out); 
	assign frame_enable = (rate_out == 25'd0) ? 1 : 0;
	
	// frame counter
	frame_counter frame(clk, frame_enable, reset_n, frame_out);
	 assign enable1 = (frame_out == 4'd5) ? 1 : 0;  // DRAW IN 5 FRAME
	

	counter_8 c1(clk, enable1, reset_n, increment1);
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b111) ? 1 : 0;
	
	counter_4 c2(clk, enable2, reset_n, increment2);

	assign enable3 = (increment2 == 3'b011) ? 1 : 0;

	counter_4 c3(clk, enable3, reset_n, increment3);
	
	assign done = (frame_out == 5'd15) ? 1 : 0;
	// start done in 17 frame
	
	
	
endmodule

module ui_RIGHT
	(
		input clk,						
        input reset_vga, // reset controller
        input enable_control, // enable the control
		output [7:0] x,
		output [6:0] y, 
		output done,
		output writeEn);
	wire enable, reset_datapath;
	control_UI c0(clk, reset_vga, enable_control, enable, writeEn, reset_datapath);
	datapath_right d0(clk, reset_datapath, enable, x, y, done);



endmodule

module datapath_right (input clk, 
				input reset_n, 
				input enable, 
				output reg [7:0] x,
				output reg [6:0] y,
				output done // signal for all ui drawing is done
				);

	// could vary according to shape
	wire [2:0] increment1;
	wire [2:0] increment2;
	wire [2:0] increment3;
	// when rate division done, frame enabled
	wire [24:0] rate_out;
	wire frame_enable;
	// when frame division done, x enabled 
	wire [4:0] frame_out;
	wire enable1, enable2, enable3;

	
	always @(posedge clk) begin : proc_
		if (!reset_n)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end
		else if (done)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end	
		else if (enable3)
		begin
			x <= 8'd79 - increment3;
			y <= 7'd63 + increment3;

		end
		else if (enable2)
		begin
			x <= 8'd79 - increment2;
			y <= 7'd63 - increment2;
		end
		else if (enable1)
		begin
			x <= 8'd79 - increment1;
			y <= 7'd63; 
		end
	
	end

	// rate divider
	rate_divider rate(clk, reset_n, enable, rate_out); 
	assign frame_enable = (rate_out == 25'd0) ? 1 : 0;
	
	// frame counter
	frame_counter frame(clk, frame_enable, reset_n, frame_out);
	assign enable1 = (frame_out == 4'd6) ? 1 : 0;  // DRAW IN 6 FRAME
	

	counter_8 c1(clk, enable1, reset_n, increment1);
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b111) ? 1 : 0;
	
	counter_4 c2(clk, enable2, reset_n, increment2);

	assign enable3 = (increment2 == 3'b011) ? 1 : 0;

	counter_4 c3(clk, enable3, reset_n, increment3);
	
	assign done = (frame_out == 5'd15) ? 1 : 0;
	// start done in 17 frame

endmodule

module ui_LEFT
	(
		input clk,						
        input reset_vga, // reset controller
        input enable_control, // enable the control
		output [7:0] x,
		output [6:0] y, 
		output done,
		output writeEn);
	wire enable, reset_datapath;
	control_UI c0(clk, reset_vga, enable_control, enable, writeEn, reset_datapath);
	datapath_left d0(clk, reset_datapath, enable, x, y, done);


endmodule

module datapath_left (input clk, 
				input reset_n, 
				input enable, 
				output reg [7:0] x,
				output reg [6:0] y,
				output done // signal for all ui drawing is done
				);

	// could vary according to shape
	wire [2:0] increment1;
	wire [2:0] increment2;
	wire [2:0] increment3;
	// when rate division done, frame enabled
	wire [24:0] rate_out;
	wire frame_enable;
	// when frame division done, x enabled 
	wire [4:0] frame_out;
	wire enable1, enable2, enable3;

	
	always @(posedge clk) begin : proc_
		if (!reset_n)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end
		else if (done)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end	
		else if (enable3)
		begin
			x <= 8'd79 + increment3;
			y <= 7'd63 + increment3;

		end
		else if (enable2)
		begin
			x <= 8'd79 + increment2;
			y <= 7'd63 - increment2;
		end
		else if (enable1)
		begin
			x <= 8'd79 + increment1; 
			y <= 7'd63; 
		end
	
	end


	// rate divider
	rate_divider rate(clk, reset_n, enable, rate_out); 
	assign frame_enable = (rate_out == 25'd0) ? 1 : 0;
	
	// frame counter
	frame_counter frame(clk, frame_enable, reset_n, frame_out);
	assign enable1 = (frame_out == 4'd7) ? 1 : 0;  // DRAW IN 7 FRAME
	

	counter_8 c1(clk, enable1, reset_n, increment1);
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b111) ? 1 : 0;
	
	counter_4 c2(clk, enable2, reset_n, increment2);

	assign enable3 = (increment2 == 3'b011) ? 1 : 0;

	counter_4 c3(clk, enable3, reset_n, increment3);
	
	assign done = (frame_out == 5'd15) ? 1 : 0;
	// start done in 17 frame

endmodule




module ui_L
	(
		input clk,						
        input reset_vga, // reset controller
        input enable_control, // enable the control
		output [7:0] x,
		output [6:0] y, 
		output done,
		output writeEn);
	wire enable, reset_datapath;
	control_UI c0(clk, reset_vga, enable_control, enable, writeEn, reset_datapath);
	datapath_L d0(clk, reset_datapath, enable, x, y, done);


endmodule

module datapath_L (input clk, 
				input reset_n, 
				input enable, 
				output reg [7:0] x,
				output reg [6:0] y,
				output done // signal for all ui drawing is done
				);

	// could vary according to shape
	wire [2:0] increment1;
	wire [2:0] increment2;
	wire [2:0] increment3;
	// when rate division done, frame enabled
	wire [24:0] rate_out;
	wire frame_enable;
	// when frame division done, x enabled 
	wire [4:0] frame_out;
	wire enable1, enable2, enable3;

	
	always @(posedge clk) begin : proc_
		if (!reset_n)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end
		else if (done)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end	
		// else if (enable3)
		// begin
		// 	x <= 8'd79 - increment3;
		// 	y <= 7'd63 + increment3;

		// end
		else if (enable2)
		begin
			x <= 8'd79 + increment2;
			y <= 7'd63;
		end
		else if (enable1)
		begin
			x <= 8'd79; 
			y <= 7'd63 - increment1; 
		end
	
	end


	// rate divider
	rate_divider rate(clk, reset_n, enable, rate_out); 
	assign frame_enable = (rate_out == 25'd0) ? 1 : 0;
	
	// frame counter
	frame_counter frame(clk, frame_enable, reset_n, frame_out);
	assign enable1 = (frame_out == 4'd8) ? 1 : 0;  // DRAW IN 8 FRAME
	

	counter_8 c1(clk, enable1, reset_n, increment1);
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b111) ? 1 : 0;
	
	counter_4 c2(clk, enable2, reset_n, increment2);

	// assign enable3 = (increment2 == 3'b011) ? 1 : 0;

	// counter_4 c3(clk, enable3 & frame_enable, reset_n, increment3);
	
	assign done = (frame_out == 5'd17) ? 1 : 0;
	// start done in 17 frame

endmodule



module ui_R
	(
		input clk,						
        input reset_vga, // reset controller
        input enable_control, // enable the control
		output [7:0] x,
		output [6:0] y, 
		output done,
		output writeEn);
	wire enable, reset_datapath;
	control_UI c0(clk, reset_vga, enable_control, enable, writeEn, reset_datapath);
	datapath_R d0(clk, reset_datapath, enable, x, y, done);


endmodule


module datapath_R (input clk, 
				input reset_n, 
				input enable, 
				output reg [7:0] x,
				output reg [6:0] y,
				output done // signal for all ui drawing is done
				);

	// could vary according to shape
	wire [2:0] increment1;
	wire [2:0] increment2;
	wire [2:0] increment3, increment4, increment5, increment6, increment7, increment8;
	// when rate division done, frame enabled
	wire [24:0] rate_out;
	wire frame_enable;
	// when frame division done, x enabled 
	wire [4:0] frame_out;
	wire enable1, enable2, enable3, enable4, enable5, enable6, enable7, enable8;

	
	always @(posedge clk) begin : proc_
		if (!reset_n)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end
		else if (done)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end	
		else if (enable8)
		begin
			x <= 8'd79 + increment8;
			y <= 7'd67 + increment8;

		end
		else if (enable7)
		begin
			x <= 8'd79;
			y <= 7'd67 + increment7;

		end
		else if (enable6)
		begin
			x <= 8'd79;
			y <= 7'd63 + increment6;

		end
		else if (enable5)
		begin
			x <= 8'd81 - increment5;
			y <= 7'd67;

		end
		else if (enable4)
		begin
			x <= 8'd82 - increment4;
			y <= 7'd66 + increment4;

		end
		else if (enable3)
		begin
			x <= 8'd82;
			y <= 7'd64 + increment3;

		end
		else if (enable2)
		begin
			x <= 8'd81 + increment2;
			y <= 7'd63 + increment2;
		end
		else if (enable1)
		begin
			x <= 8'd79 + increment1; 
			y <= 7'd63; 
		end
	
	end


	// rate divider
	rate_divider rate(clk, reset_n, enable, rate_out); 
	assign frame_enable = (rate_out == 25'd0) ? 1 : 0;
	
	// frame counter
	frame_counter frame(clk, frame_enable, reset_n, frame_out);
	assign enable1 = (frame_out == 4'd9) ? 1 : 0;  // DRAW IN 9 FRAME
	

	counter_4 c1(clk, enable1, reset_n, increment1); // --
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b011) ? 1 : 0;
	
	counter_3 c2(clk, enable2, reset_n, increment2);

	assign enable3 = (increment2 == 3'b010) ? 1 : 0;

	counter_4 c3(clk, enable3, reset_n, increment3);

	assign enable4 = (increment3 == 3'b011) ? 1 : 0;

	counter_3 c4(clk, enable4, reset_n, increment4);

	assign enable5 = (increment4 == 3'b010) ? 1 : 0;

	counter_4 c5(clk, enable5, reset_n, increment5);

	assign enable6 = (increment5 == 3'b011) ? 1 : 0;

	counter_5 c6(clk, enable6, reset_n, increment6);

	assign enable7 = (increment6 == 3'b100) ? 1 : 0;

	counter_5 c7(clk, enable7, reset_n, increment7);

	assign enable8 = (increment7 == 3'b100) ? 1 : 0;

	counter_5 c8(clk, enable8, reset_n, increment8);

	
	assign done = (frame_out == 5'd15) ? 1 : 0;
	// start done in 17 frame

endmodule

module counter_3 (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [2:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			begin
			increment <= 3'b0;
			end
		else if (enable) begin
			if (increment == 3'b010)
				increment <= 3'b000;
			else 
				increment <= increment + 1'b1;
		end
	end
endmodule 

module counter_5 (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [2:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			begin
			increment <= 3'b0;
			end
		else if (enable) begin
			if (increment == 3'b100)
				increment <= 3'b000;
			else 
				increment <= increment + 1'b1;
		end
	end
endmodule 


module counter_4 (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [2:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			begin
			increment <= 3'b0;
			end
		else if (enable) begin
			if (increment == 3'b011)
				increment <= 3'b000;
			else 
				increment <= increment + 1'b1;
		end
	end
endmodule 

module counter_8 (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [2:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			begin
			increment <= 3'b0;
			end
		else if (enable) begin
			if (increment == 3'b111)
				increment <= 3'b000;
			else
				increment <= increment + 1'b1;
		end
	end
endmodule


// frame counter, count to 17 for every move so that the frame could refresh
module frame_counter(clk, enable, reset_n, out);
	input clk, enable, reset_n;
	output reg [4:0] out;
	
	always @(posedge clk) begin
		if (!reset_n) begin
			out <= 5'b0;
			end
		else if (enable) begin
			if (out == 5'd15)
				out <= 5'b0;
			else
				out <= out + 1'b1;
		end
	end
endmodule


// rate divider that divides the clk
module rate_divider(clk, reset_n, enable, out);
		input clk;
		input reset_n;
		input enable;
		output reg [24:0] out;
		
		always @(posedge clk)
		begin
			if (!reset_n) begin
				out <= 25'd0;
				end
			else if (enable) begin
			   	if (out == 25'd3125000)
					begin
					out <= 25'd0;
					end
				else
					begin
					out <= out + 1'b1;
					end
			end
		end
endmodule

