module mux_ui ( // testing
	input change_instruction, 
	input reset_n,
	input clk,
	input clear_instruction,
	output [7:0] x,
	output [6:0] y,
	output [2:0] color,
	output writeEn
	);

	wire [3:0] control_instructions;
	wire reset_instructions, done;
	wire [2:0] current_instruction;
	instruction_shift i1(change_instruction, clk, current_instruction);
	mux_instructions i2(change_instruction, control_instructions, clk, reset_instructions, done, writeEn, color, x, y);
	mux_control i3(change_instruction, current_instruction, reset_n, done, clear_instruction,
		clk, reset_instructions, control_instructions);

	// after recieve done, 0-1-0, we have clear set to high for one pulse
	
endmodule 


module mux_instructions(
	input enable,
	input [3:0] instruction,  // input instruction with 4 bit, [3] clear when 1
	// [2:0] instruction 
	input clk, 
	input reset_n, 
	output reg done, 
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
	reg [3:0] CURRRENT_INSTRUCTION;
	
	always @(*)
	begin
			CURRRENT_INSTRUCTION<=	instruction; // update instruction if enabled
			
	end
	

	localparam UP = 3'b000,
			   DOWN = 3'b001,
			   RIGHT = 3'b010, 
			   LEFT = 3'b011, 
			   R = 3'b100, 
			   L = 3'b101;

	wire [7:0] x1, x1c, x2, x2c, x3, x3c, x4, x4c, x5, x5c, x6, x6c;
	wire [6:0] y1, y1c, y2, y2c, y3, y3c, y4, y4c, y5, y5c, y6, y6c;

	always @(*) begin : FFFF
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

		case (CURRRENT_INSTRUCTION[2:0])
			UP : 
				begin 
				if (CURRRENT_INSTRUCTION[3])
					begin
					en_u1c =1;
					x = x1c;
					y = y1c;
					done = done1c;
					writeEn = writeEn1c;
					color = 3'b000;
					end
				else 
					begin
					en_u1 = 1;
					x = x1;
					y = y1;
					done = done1;
					writeEn = writeEn1;
					color = 3'b111;
					end
				end
			DOWN :  
				begin
				if (CURRRENT_INSTRUCTION[3])
						begin
						en_u2c =1;
						x = x2c;
						y = y2c;
						done = done2c;
						writeEn = writeEn2c;
						color = 3'b000;
						end
					else 
					begin
						en_u2 = 1;
						x = x2;
						y = y2;
						done = done2;
						writeEn = writeEn2;
						color = 3'b001;
						end
					end
			RIGHT : 
				begin
				if (CURRRENT_INSTRUCTION [3])
					begin
						en_u3c =1;
						x = x3c;
						y = y3c;
						done = done3c;
						writeEn = writeEn3c;
						color = 3'b000;
						end
					else 
					begin
						en_u3 = 1;
						x = x3;
						y = y3;
						done = done3;
						writeEn = writeEn3;
						color = 3'b011;
						end
					end
			LEFT :  
				begin
				if (CURRRENT_INSTRUCTION [3])
					begin
						en_u4c =1;
						x = x4c;
						y = y4c;
						done = done4c;
						writeEn = writeEn4c;
						color = 3'b000;
						end
					else 
					begin
						en_u4 = 1;
						x = x4;
						y = y4;
						done = done4;
						writeEn = writeEn4;
						color = 3'b010;
						end
					end
			R : 
				begin
				if (CURRRENT_INSTRUCTION [3])
					begin
					en_u5c =1;
					x = x5c;
					y = y5c;
					done = done5c;
					writeEn = writeEn5c;
					color = 3'b000;
					end
				else 
					begin
					en_u5 = 1;
					x = x5;
					y = y5;
					done = done5;
					writeEn = writeEn5;
					color = 3'b100;
					end
				end
			L : 
				begin
				if (CURRRENT_INSTRUCTION [3])
					begin
					en_u6c =1;
					x = x6c;
					y = y6c;
					done = done6c;
					writeEn = writeEn6c;
					color = 3'b000;
					end
				else 
					begin
					en_u6 = 1;
					x = x6;
					y = y6;
					done = done6;
					writeEn = writeEn6;
					color = 3'b101;
					end
				end
			
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
	reg clear_ui;	   
	always @(*) begin : proc_
		case (CURRENT_STATE)
			ON_HOLD : NEXT_STATE =  (enable) ? PREPARE_INSTRUCTION: ON_HOLD;
			PREPARE_INSTRUCTION : 
			begin
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
			end
			UP: NEXT_STATE = done ? UP_WAIT : UP;
			UP_WAIT: NEXT_STATE = done ? UP_WAIT : PREPARE_INSTRUCTION;
			DOWN: NEXT_STATE = done ? DOWN_WAIT : DOWN;
			DOWN_WAIT: NEXT_STATE = done ? DOWN_WAIT : PREPARE_INSTRUCTION;
			RIGHT: NEXT_STATE = done ? RIGHT_WAIT : RIGHT;
			RIGHT_WAIT: NEXT_STATE = done ? RIGHT_WAIT : PREPARE_INSTRUCTION;
			LEFT: NEXT_STATE = done ? LEFT_WAIT : LEFT;
			LEFT_WAIT: NEXT_STATE = done ? LEFT_WAIT : PREPARE_INSTRUCTION;
			L: NEXT_STATE = done ? L_WAIT : L;
			L_WAIT: NEXT_STATE = done ? L_WAIT : PREPARE_INSTRUCTION;
			R: NEXT_STATE = done ? R_WAIT : R;
			R_WAIT: NEXT_STATE = done ? R_WAIT : PREPARE_INSTRUCTION;
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
		reset_instructions <= 1'b1;
		case (CURRENT_STATE)
			PREPARE_INSTRUCTION: 
				if (clear)
					begin 
					clear_ui <= clear; // used for later
					end
			ON_HOLD:
				begin
				clear_ui <= 0;
				reset_instructions <= 0;
				end
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

	always @(posedge clk) begin : FF
		if(!reset_n) begin
			CURRENT_STATE <= ON_HOLD;
		end else begin
			CURRENT_STATE <= NEXT_STATE;
		end
	end


endmodule



module instruction_shift_control (
	input enable,
	input clk,
	output reg reset_random);
// random need to be initialized with reset, but only once, we need control
reg [1:0] CURRENT_STATE, NEXT_STATE;

localparam START = 2'b01, 
		   RESET = 2'b10,
		   DONE = 2'b11;

always @(*)
	begin
		if (enable) begin
			CURRENT_STATE <= START;
		end
	end


always @(*)
	begin
		case (CURRENT_STATE)
			START: NEXT_STATE = RESET;
			RESET: NEXT_STATE = DONE;
			DONE: NEXT_STATE = DONE;
			default: NEXT_STATE = START;
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
		CURRENT_STATE <= NEXT_STATE;		
	end

endmodule



// change instruction when change_instruction is high, no need for reseting instruction_shift
module instruction_shift(
	input change_instruction, 
	input clk,
	output reg [2:0] instruction);
	wire [3:0]random;
	wire rst_n;
	reg [3:0] ran;
	wire enable_control;
	// reset this machine automatically in first 2 clk
	assign enable_control = 1'b1;
	
	instruction_shift_control c0 (enable_control, clk, rst_n);
	
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



// enable unit set start the unit, change with a palse of 1 : 0000100000
// enable unit set start the unit, change with a palse of 1 : 0000100000
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
		else if (frame_enable & !enable2)
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
	// assign enable1 = (frame_out == 4'd0) ? 1 : 0;
	

	counter_8 c1(clk, frame_enable, reset_n, increment1);
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b111) ? 1 : 0;
	
	counter_4 c2(clk, enable2 & frame_enable, reset_n, increment2);

	assign enable3 = (increment2 == 3'b011) ? 1 : 0;

	counter_4 c3(clk, enable3 & frame_enable, reset_n, increment3);
	
	assign done = (frame_out == 5'd17) ? 1 : 0;
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
		else if (frame_enable & !enable2)
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
	// assign enable1 = (frame_out == 4'd0) ? 1 : 0;
	

	counter_8 c1(clk, frame_enable, reset_n, increment1);
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b111) ? 1 : 0;
	
	counter_4 c2(clk, enable2 & frame_enable, reset_n, increment2);

	assign enable3 = (increment2 == 3'b011) ? 1 : 0;

	counter_4 c3(clk, enable3 & frame_enable, reset_n, increment3);
	
	assign done = (frame_out == 5'd17) ? 1 : 0;
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
		else if (frame_enable & !enable2)
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
	// assign enable1 = (frame_out == 4'd0) ? 1 : 0;
	

	counter_8 c1(clk, frame_enable, reset_n, increment1);
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b111) ? 1 : 0;
	
	counter_4 c2(clk, enable2 & frame_enable, reset_n, increment2);

	assign enable3 = (increment2 == 3'b011) ? 1 : 0;

	counter_4 c3(clk, enable3 & frame_enable, reset_n, increment3);
	
	assign done = (frame_out == 5'd17) ? 1 : 0;
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
		else if (frame_enable & !enable2)
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
	// assign enable1 = (frame_out == 4'd0) ? 1 : 0;
	

	counter_8 c1(clk, frame_enable, reset_n, increment1);
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b111) ? 1 : 0;
	
	counter_4 c2(clk, enable2 & frame_enable, reset_n, increment2);

	assign enable3 = (increment2 == 3'b011) ? 1 : 0;

	counter_4 c3(clk, enable3 & frame_enable, reset_n, increment3);
	
	assign done = (frame_out == 5'd17) ? 1 : 0;
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
		else if (frame_enable & !enable2)
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
	// assign enable1 = (frame_out == 4'd0) ? 1 : 0;
	

	counter_8 c1(clk, frame_enable, reset_n, increment1);
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b111) ? 1 : 0;
	
	counter_4 c2(clk, enable2 & frame_enable, reset_n, increment2);

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
		else if (frame_enable & !enable2)
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
	// assign enable1 = (frame_out == 4'd0) ? 1 : 0;
	

	counter_4 c1(clk, frame_enable, reset_n, increment1); // --
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b011) ? 1 : 0;
	
	counter_3 c2(clk, enable2 & frame_enable, reset_n, increment2);

	assign enable3 = (increment2 == 3'b010) ? 1 : 0;

	counter_4 c3(clk, enable3 & frame_enable, reset_n, increment3);

	assign enable4 = (increment3 == 3'b011) ? 1 : 0;

	counter_3 c4(clk, enable4 & frame_enable, reset_n, increment4);

	assign enable5 = (increment4 == 3'b010) ? 1 : 0;

	counter_4 c5(clk, enable5 & frame_enable, reset_n, increment5);

	assign enable6 = (increment5 == 3'b011) ? 1 : 0;

	counter_5 c6(clk, enable6 & frame_enable, reset_n, increment6);

	assign enable7 = (increment6 == 3'b100) ? 1 : 0;

	counter_5 c7(clk, enable7 & frame_enable, reset_n, increment7);

	assign enable8 = (increment7 == 3'b100) ? 1 : 0;

	counter_5 c8(clk, enable8 & frame_enable, reset_n, increment8);

	
	assign done = (frame_out == 5'd22) ? 1 : 0;
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
				increment <= 3'b010;
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
				increment <= 3'b100;
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
				increment <= 3'b011;
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
				increment <= 3'b111;
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
			out <= 4'b0;
			end
		else if (enable) begin
			if (out == 5'd18)
				out <= 4'b0;
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
