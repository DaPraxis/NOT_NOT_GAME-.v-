// clear probably don't work for clear done, need to test by hand
module top_game(
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
	output [9:0] VGA_B,  						//	VGA Blue[9:0]
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5
		);

	wire [7:0] x;
	wire [6:0] y;
	wire [2:0] color;
	wire writeEn;

	vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(color), 
			.x(x),
			.y(y),
			.plot(1'b1),
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


		game g1 (.clk(CLOCK_50),
				 .user_input(SW[5:0]),
				 .start(~KEY[1]),
				 .reset_n(KEY[0]),
				 .x(x),
				 .y(y),
				 .writeEn(writeEn),
				 .clear_done(~KEY[1]),
				 .done(LEDR[0]),
				 .current_state(LEDR[9:6]),
				 .time_counter_done(~KEY[1]),
				 .correct(LEDR[5]),
				 .wrong(LEDR[4]),
				 .color(color),
				 .CURRENT_INS(LEDR[3:1]),
				 .HEX0(HEX0),
				 .HEX1(HEX1),
				 .HEX2(HEX2),
				 .HEX3(HEX3),
				 .HEX4(HEX4),
				 .HEX5(HEX5)
				 );
endmodule


module game(  // unstrusted clear_done
		input clk, 
		input [5:0] user_input,
		input start,
		input reset_n,
		input clear_done,
		input time_counter_done,
		output [7:0]x,
		output [6:0]y,
		output writeEn, 
		output done,
		output [3:0]current_state,
		output correct,
		output wrong, 
		output [3:0] color,
		output [2:0] CURRENT_INS,
		output [6:0] HEX0,
		output [6:0] HEX1,
		output [6:0] HEX2,
		output [6:0] HEX3,
		output [6:0] HEX4,
		output [6:0] HEX5
		);
		wire instruction_ui_clear,reset_ui,enable_start,enable_instruction, enable_time_counter,
		 reset_time_counter, enable_feedback,feedback_ui_clear,start_ui_clear, reset_correct,
		 reset_wrong, STATE_start, STATE_ins,STATE_feed;
		 wire incr_point, decr_live;
		 wire [1:0] live;
		 wire [7:0] point;
		 wire dead, STATE_DEAD;

//		wire time_counter_done;  // done is not really used to indicate clear done
	
		game_control g1 (user_input, start, time_counter_done, clear_done, reset_n,clk,dead,
		 instruction_ui_clear,reset_ui,enable_start,enable_instruction, enable_time_counter,
		 reset_time_counter, enable_feedback,feedback_ui_clear,start_ui_clear, reset_correct,
		 reset_wrong, STATE_start, STATE_ins,STATE_feed, current_state, STATE_DEAD);

		game_datapath g2(instruction_ui_clear,reset_ui,enable_start,enable_instruction,
		 enable_feedback,feedback_ui_clear,start_ui_clear,clk, reset_correct,
		 reset_wrong, STATE_start, STATE_ins,STATE_feed,STATE_DEAD, user_input, x, y, color, done, writeEn, correct, wrong, CURRENT_INS,decr_live, incr_point );
		 
		 
//		time_counter t1(enable_time_counter, reset_time_counter, time_counter_done);
		user_lives c1(reset_n,decr_live,clk, live,dead);
		user_point c2(reset_n, incr_point, clk, point);
		hex_decoder h1(live,HEX0);
		hex_decoder h2(0,HEX1);
		hex_decoder h3(point[3:0],HEX2);
		hex_decoder h4(point[7:4],HEX3);

endmodule



module game_control(
		input[5:0] user_input,   // a bit wise user input with 0 1 2 3 4 5
										 //                            W A S D R L
		input start,             // pulse to start
		input time_counter_done,  // from TIME
		input clear_done,  // from DATAPATH
		input reset_n,
		input clk,
		input dead,
		output reg instruction_ui_clear,
		output reg reset_ui,
		output reg enable_start,
		output reg enable_instruction,
		output reg enable_time_counter,
		output reg reset_time_counter, 
		output reg enable_feedback,
		output reg feedback_ui_clear,
		output reg start_ui_clear, 
		output reg reset_correct,
		output reg reset_wrong, 
		output reg STATE_start, 
		output reg STATE_ins,
		output reg STATE_feed,
		output reg [3:0]  CURRENT_STATE,
		output reg STATE_DEAD
		
		
		
		);

	localparam 	ONHOLD = 4'b0000,
					RESET = 4'b0001,
					START = 4'b0010,
					INSTRUCTION = 4'b0011,
					INSTRUCTION_PREPARE = 4'b0100,
					JUDGE = 4'b0101,
					FEEDBACK = 4'b0110,   // see correct or not
					CLEAR_INSTRUCTION = 4'b0111,
					CLEAR_FEEDBACK = 4'b1000, 
					CLEAR_START = 4'b1001,
					FEEDBACK_WAIT = 4'b1010,
					PENDING = 4'b1011,
					DEAD = 4'b1100,
					CLEAR_START_WAIT = 4'b1101,
					FEEDBACK_STATE = 4'b1110;
					


	reg [3:0] NEXT_STATE;				
	always@(*)
		begin
		case (CURRENT_STATE)
		ONHOLD: NEXT_STATE = (start)? RESET : ONHOLD;
		RESET: NEXT_STATE = (start)? RESET: START;
		START: NEXT_STATE = (time_counter_done)? CLEAR_START: START;
		CLEAR_START: NEXT_STATE = (time_counter_done)? CLEAR_START: CLEAR_START_WAIT;
		CLEAR_START_WAIT: NEXT_STATE = (clear_done)? INSTRUCTION: CLEAR_START;
		INSTRUCTION: NEXT_STATE = INSTRUCTION_PREPARE;
		INSTRUCTION_PREPARE: NEXT_STATE = (| user_input)? JUDGE: INSTRUCTION_PREPARE;
		JUDGE: NEXT_STATE = (| user_input)? JUDGE: CLEAR_INSTRUCTION;
		CLEAR_INSTRUCTION: NEXT_STATE = (clear_done)? FEEDBACK_STATE: CLEAR_INSTRUCTION;
		FEEDBACK_STATE: NEXT_STATE = (clear_done)? FEEDBACK_STATE:FEEDBACK;
		FEEDBACK: NEXT_STATE = (time_counter_done)? FEEDBACK_WAIT: FEEDBACK;
		FEEDBACK_WAIT: NEXT_STATE = (time_counter_done)? FEEDBACK_WAIT: CLEAR_FEEDBACK;
		CLEAR_FEEDBACK: NEXT_STATE = (clear_done)? PENDING: CLEAR_FEEDBACK;
		PENDING: NEXT_STATE = (dead)? DEAD: INSTRUCTION;
		DEAD: NEXT_STATE = DEAD;
		endcase
		end
		
		
	always@(*)
		begin
		start_ui_clear <= 1;
		instruction_ui_clear <= 1;
		reset_ui <= 1;
		enable_start <=0;
		enable_instruction <=0;
		enable_time_counter <=0; 
		reset_time_counter <= 1;
		enable_feedback <= 0;
		feedback_ui_clear <= 1;
		reset_correct <=1;
		reset_wrong <=1;
		STATE_start <=0;
		STATE_ins <=0;
		STATE_feed <=0;
		STATE_DEAD <=0;
		case (CURRENT_STATE)
			RESET:
			begin	
				reset_ui <=0;
				reset_time_counter <= 0;
			end
			START: 
			begin
				enable_start <=1;
				STATE_start<=1;
				enable_time_counter <= 1;
				start_ui_clear <= 0;
			end
			CLEAR_START:
				STATE_start<=1;
			CLEAR_START_WAIT:
				STATE_start<=1;
			INSTRUCTION:
			begin
				enable_instruction <= 1;
				instruction_ui_clear <=0;
				reset_time_counter <= 0;
				reset_correct <=0;
				reset_wrong <=0;
				STATE_ins <=1;
			end
			INSTRUCTION_PREPARE:
			begin
				instruction_ui_clear <=0;
				reset_correct <=0;
				reset_wrong <=0;
				STATE_ins <=1;
			end
			JUDGE:
				STATE_ins <=1;
			CLEAR_INSTRUCTION:
				STATE_ins <=1;
			FEEDBACK_STATE:
				STATE_ins <=1;
			FEEDBACK:
			begin
				enable_feedback <=1;
				enable_time_counter <= 1;
				feedback_ui_clear <= 0;
				STATE_feed <=1;
			end
			FEEDBACK_WAIT:
			begin
				feedback_ui_clear <= 0;
				STATE_feed <=1;
			end
			CLEAR_FEEDBACK:
			begin
				STATE_feed <=1;
				enable_instruction <=1;
			end
//			PENDING:
//				STATE_feed <=1;
			DEAD: 
			begin
				STATE_DEAD <=1;
				instruction_ui_clear <=0;
			end
		endcase
		end
		
	always@(posedge clk)
		begin
			if (!reset_n)
				CURRENT_STATE <= ONHOLD;
			else 
				CURRENT_STATE <= NEXT_STATE;
		end

endmodule 




module time_counter(
		input enable, 
		input reset_n,
		input clk,
		output reg q);
		reg [34:0] count;
		always@(posedge clk)
		begin
			if (!reset_n)
			begin
				count <= 0;
				q <= 0;
			end 
			else 
				begin
				if (enable)
					count <= count +1;
				else if (count == 35'd150000000)
					q <= 1;
				end
			
		end
	

endmodule


module game_datapath(
		input instruction_ui_clear,
		input reset_ui, 
		input enable_start,         // CHECK
		input enable_instruction,   // CHECK
		input enable_feedback,		 // CHECK
		input feedback_ui_clear, 
		input start_ui_clear,
		input clk,
		input reset_correct,
		input reset_wrong,
		input STATE_start,
		input STATE_ins, 
		input STATE_feed,
		input STATE_DEAD,
		input [5:0] user_input,
		output reg [7:0] x,
		output reg [6:0]y, 
		output reg [2:0] color,
		output reg done, 
		output reg writeEn, 
		output reg correct,
		output reg wrong, 
		output [2:0] CURRENT_INS, 
		output reg decr_live,
		output reg incr_point);
		
		
		wire [2:0] ins_color, start_color, correct_color, wrong_color, dead_color;
		wire [7:0] ins_x, start_x, correct_x, wrong_x, dead_x;
		wire [6:0] ins_y, start_y, correct_y, wrong_y, dead_y;
		wire ins_done, start_done, correct_done, wrong_done, dead_done;
		wire ins_writeEn, start_writeEn, correct_writeEn, wrong_writeEn, dead_writeEn;
//		wire [2:0] CURRENT_INS;
		
		
		always@(*)
		begin
			writeEn <=0;
			done <=0;
			color<=3'b0000;
			decr_live <= 0;
			incr_point <=0;

// START			
			if (STATE_start)
				begin
				x <= start_x;
				y <= start_y;
				done <= start_done;
				writeEn <= 1;
				color <= start_color;
				end
				
				
				
// INSTRUCTION				
			else if (STATE_ins)
				begin
				x <= ins_x;
				y <= ins_y;
				done <= ins_done;
				writeEn <= 1;
				color<=ins_color;
					if (CURRENT_INS == 3'b000)      // UP
						begin
							if (|user_input)  //with S 
							begin
								if (user_input[2])
									begin
									correct<=1;
									wrong <=0;
									end
								else 
									begin
									correct<=0;
									wrong <=1;
									end
							end
						end
					
					else if (CURRENT_INS == 3'b001)      // DOWN
						begin
							if (|user_input)  //with W
							begin
								if (user_input[0])
									begin
									correct<=1;
									wrong <=0;
									end
								else 
									begin
									correct<=0;
									wrong <=1;
									end
							end
						end
						
					else if (CURRENT_INS == 3'b010)      // RIGHT
						begin
							if (|user_input)  //with A
							begin
								if (user_input[1])
									begin
									correct<=1;
									wrong <=0;
									end
								else 
									begin
									correct<=0;
									wrong <=1;
									end
							end
						end
						
					else if (CURRENT_INS == 3'b011)      // LEFT
						begin
							if (|user_input)  //with D
							begin
								if (user_input[3])
									begin
									correct<=1;
									wrong <=0;
									end
								else 
									begin
									correct<=0;
									wrong <=1;
									end
							end
						end
					
					else if (CURRENT_INS == 3'b101)      // L
						begin
							if (|user_input)  //with R
							begin
								if (user_input[4])
									begin
									correct<=1;
									wrong <=0;
									end
								else 
									begin
									correct<=0;
									wrong <=1;
									end
							end
						end
					
					else if (CURRENT_INS == 3'b100)      // R
						begin
							if (|user_input)  //with L
							begin
								if (user_input[5])
									begin
									correct<=1;
									wrong <=0;
									end
								else 
									begin
									correct<=0;
									wrong <=1;
									end
							end
						end
				end
			
// FEEDBACK			
			else if (STATE_feed)
				begin
				
					if (correct)
					begin
						incr_point <=1;
						x <= correct_x;
						y <= correct_y;
						done <= correct_done;
						writeEn <= 1;
						color<=correct_color;
					end
					else
					begin
						decr_live <=1;
						x <= wrong_x;
						y <= wrong_y;
						done <= wrong_done;
						writeEn <= 1;
						color<=wrong_color;
					end
				end
//				x <= wrong_x;
//				y <= wrong_y;
//				done <= wrong_done;
//				writeEn <= 1;
//				color<=wrong_color;
//				end
			else if (STATE_DEAD)
				begin
					x <= dead_x;
					y <= dead_y;
					color <= dead_color;
					done <= dead_done;
					writeEn <=1;
				end
					
		
		end
		
		
		mux_ui_ff m1(enable_instruction, reset_ui, clk, instruction_ui_clear, ins_color, ins_x, ins_y, ins_done, ins_writeEn, CURRENT_INS);
		ui_start m2(clk,reset_ui, enable_start, start_ui_clear, start_x, start_y, start_color, start_done, start_writeEn);
		ui_correct m3(clk, reset_correct, STATE_feed, feedback_ui_clear,correct_x,correct_y, correct_color, correct_done, correct_writeEn);
		ui_wrong m111(clk, reset_wrong, STATE_feed, feedback_ui_clear,wrong_x,wrong_y, wrong_color, wrong_done, wrong_writeEn);
		ui_dead m4(clk, reset_ui, STATE_DEAD, 0,dead_x,dead_y, dead_color, dead_done, dead_writeEn);
		

	

endmodule 
