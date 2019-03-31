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




