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
	output [9:0] VGA_B  						//	VGA Blue[9:0]
		);

	wire [7:0] x;
	wire [6:0] y;
	wire [2:0] color;
	wire writeEn;

	vga_adapter VGA(
			.resetn(reset_n),
			.clock(CLOCK_50),
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


		game g1 (.clk(CLOCK_50),
				 .user_input(SW[5:0]),
				 .start(~KEY[1]),
				 .reset_n(KEY[0]),
				 .x(x),
				 .y(y),
				 .writeEn(writeEn),
				 .clear_done(~KEY[2]),
				 .done(LEDR[0])
				 );
endmodule


module game(  // unstrusted clear_done
		input clk, 
		input [5:0] user_input,
		input start,
		input reset_n,
		input clear_done, 
		output [7:0]x,
		output [6:0]y,
		output writeEn, 
		output done
		);
		wire instruction_ui_clear,reset_ui,enable_start,enable_instruction, enable_time_counter,
		 reset_time_counter, enable_feedback,feedback_ui_clear,start_ui_clear, reset_correct,
		 reset_wrong, STATE_start, STATE_ins,STATE_feed;

		wire time_counter_done;  // done is not really used to indicate clear done
	
		game_control g1 (user_input, start, time_counter_done, clear_done, reset_n,clk,
		 instruction_ui_clear,reset_ui,enable_start,enable_instruction, enable_time_counter,
		 reset_time_counter, enable_feedback,feedback_ui_clear,start_ui_clear, reset_correct,
		 reset_wrong, STATE_start, STATE_ins,STATE_feed);



		game_datapath g2(clk, user_input, instruction_ui_clear,reset_ui,enable_start,enable_instruction,
		 enable_feedback,feedback_ui_clear,start_ui_clear, reset_correct,
		 reset_wrong, STATE_start, STATE_ins,STATE_feed, x, y, color, done, writeEn);
		 
		time_counter t1(enable_time_counter, reset_time_counter, time_counter_done);

endmodule



module game_control(
		input[5:0] user_input,   // a bit wise user input with 0 1 2 3 4 5
										 //                            W A S D R L
		input start,             // pulse to start
		input time_counter_done,  // from TIME
		input clear_done,  // from DATAPATH
		input reset_n,
		input clk,
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
		output reg STATE_feed
		
		
		
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
					FEEDBACK_WAIT = 4'b1010;


	reg [3:0] CURRENT_STATE, NEXT_STATE;				
	always@(*)
		begin
		case (CURRENT_STATE)
		ONHOLD: NEXT_STATE = (start)? RESET : ONHOLD;
		RESET: NEXT_STATE = START;
		START: NEXT_STATE = (time_counter_done)? CLEAR_START: START;
		CLEAR_START: NEXT_STATE = (clear_done)? INSTRUCTION: CLEAR_START;
		INSTRUCTION: NEXT_STATE = INSTRUCTION_PREPARE;
		INSTRUCTION_PREPARE: NEXT_STATE = (| user_input)? JUDGE: INSTRUCTION_PREPARE;
		JUDGE: NEXT_STATE = (| user_input)? JUDGE: CLEAR_INSTRUCTION;
		CLEAR_INSTRUCTION: NEXT_STATE = (clear_done)? FEEDBACK: CLEAR_INSTRUCTION;
		FEEDBACK: NEXT_STATE = (time_counter_done)? FEEDBACK_WAIT: FEEDBACK;
		FEEDBACK_WAIT: NEXT_STATE = CLEAR_FEEDBACK;
		CLEAR_FEEDBACK: NEXT_STATE = (clear_done)? INSTRUCTION: CLEAR_FEEDBACK;
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
				STATE_ins <=1;
			end
			JUDGE:
				STATE_ins <=1;
			CLEAR_INSTRUCTION:
				STATE_ins <=1;
			
			FEEDBACK:
			begin
				enable_feedback <=1;
				enable_time_counter <= 1;
				feedback_ui_clear <= 0;
				STATE_feed <=1;
			end
			CLEAR_FEEDBACK:
				STATE_ins <=1;
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
		input [5:0] user_input,
		output reg [7:0] x,
		output reg [6:0]y, 
		output reg [2:0] color,
		output reg done, 
		output reg writeEn, 
		output reg correct,
		output reg wrong);
		
		
		wire [2:0] ins_color, start_color, correct_color;
		wire [7:0] ins_x, start_x, correct_x;
		wire [6:0] ins_y, start_y, correct_y;
		wire ins_done, start_done, correct_done;
		wire ins_writeEn, start_writeEn, correct_writeEn;
		wire [2:0] CURRENT_INS;
		
		
		always@(*)
		begin
			writeEn <=0;
			done <=0;

// START			
			if (STATE_start)
				begin
				x <= start_x;
				y <= start_y;
				done <= start_done;
				writeEn <= start_writeEn;
				end
				
				
				
// INSTRUCTION				
			else if (STATE_ins)
				begin
				x <= ins_x;
				y <= ins_y;
				done <= ins_done;
				writeEn <= ins_writeEn;
					if (CURRENT_INS == 3'b000)      // UP
						begin
							if ((&user_input)&&(user_input[2]))  //with S 
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
					
					else if (CURRENT_INS == 3'b001)      // DOWN
						begin
							if ((&user_input)&&(user_input[0]))  //with W 
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
						
					else if (CURRENT_INS == 3'b010)      // LEFT
						begin
							if ((&user_input)&&(user_input[3]))  //with D 
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
						
					else if (CURRENT_INS == 3'b011)      // RIGHT
						begin
							if ((&user_input)&&(user_input[1]))  //with A
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
					
					else if (CURRENT_INS == 3'b101)      // R
						begin
							if ((&user_input)&&(user_input[5]))  //with L
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
					
					else if (CURRENT_INS == 3'b100)      // L
						begin
							if ((&user_input)&&(user_input[4]))  //with R
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
			
// FEEDBACK			
			else if (STATE_feed)
				begin
					if (right && !wrong)
					begin
						x <= correct_x;
						y <= correct_y;
						done <= correct_done;
						writeEn <= correct_writeEn;
					end
					else if (!right && wrong)
					begin
						x <= wrong_x;
						y <= wrong_y;
						done <= wrong_done;
						writeEn <= wrong_writeEn;
					end
				end
			
			
		
		
		
		
		
		end
		
		
		
		mux_ui_ff m1(enable_instruction, reset_ui, clk, instruction_ui_clear, ins_color, ins_x, ins_y, ins_done, ins_writeEn, CURRENT_INS);
		ui_start m2(clk,reset_ui, enable_start, start_ui_clear, start_x, start_y, start_color, start_done, start_writeEn);
		ui_correct m3(clk, reset_correct, enable_feedback && correct, feedback_ui_clear,correct_x,correct_y, 
		correct_color, correct_done, correct_writeEn);
		ui_wrong m4(clk, reset_correct, enable_feedback && wrong, feedback_ui_clear,wrong_x,wrong_y, 
		wrong_color, wrong_done, wrong_writeEn);
		
		


endmodule 