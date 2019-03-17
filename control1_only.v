module control1 (clk, rst_n, key_pressed, answer, wait_counter, prepare_judge, enable_counter, change_instruction, decrease_life);

	input clk;    // Clock
	input rst_n;  // Asynchronous reset active low
	input key_pressed; //User input new answer, 1 when key is pressed
	input answer; // Returned from judge, 1 when answer matchs the key
	input wait_counter; // Returned from counter, 1 if more than that counting time
	output reg prepare_judge; // Start to prepare judge unit, from Nothing to Judge
	output reg enable_counter; // Start to run transition counter
	output reg change_instruction;
	output reg decrease_life;
	reg [4:0] CURRENT_STATE, NEXT_STATE;


	localparam INSTRUCTION_STATE = 5'b00000,
			   INSTRUCTION_WAIT = 5'b00001,
			   ANSWER_STATE = 5'b00010,
			   WRONG_STATE = 5'b00011,
			   CORRECT_STATE = 5'b00100,
			   CORRECT_WAIT = 5'b00101,
			   WRONG_WAIT = 5'b00110,
			   START_STATE = 5'b00111,
			   START_WAIT = 5'b01000;

	always @(*) begin : FSM_TABLE
		case(CURRENT_STATE)
			INSTRUCTION_STATE: NEXT_STATE= key_pressed? INSTRUCTION_WAIT : INSTRUCTION_STATE;
			INSTRUCTION_WAIT: NEXT_STATE= key_pressed? INSTRUCTION_WAIT : ANSWER_STATE;
			ANSWER_STATE: NEXT_STATE= answer? CORRECT_STATE : WRONG_STATE;
			CORRECT_STATE: NEXT_STATE= wait_counter? CORRECT_STATE: CORRECT_WAIT;
			CORRECT_WAIT: NEXT_STATE= wait_counter? INSTRUCTION_STATE: CORRECT_WAIT;
			WRONG_STATE: NEXT_STATE= wait_counter? WRONG_STATE: WRONG_WAIT;
			WRONG_WAIT: NEXT_STATE= wait_counter? INSTRUCTION_STATE: WRONG_WAIT;
			START_STATE: NEXT_STATE = START_WAIT;
			START_WAIT: NEXT_STATE = INSTRUCTION_STATE;
			default: NEXT_STATE = INSTRUCTION_STATE;
		endcase
	end

	always @(*) begin : FSM_ASSIGNMENTS
		prepare_judge = 1'b0;
		enable_counter = 1'b0;
		change_instruction = 1'b0;
		decrease_life = 1'b0;
		case(CURRENT_STATE)
			INSTRUCTION_STATE: 
				begin
					prepare_judge = 1'b1;
				end
			CORRECT_STATE: // once enable counter, reset counter answer to 0, count to 0
				begin
					enable_counter = 1'b1;
					change_instruction = 1'b1;
				end

			WRONG_STATE: // once enable counter, reset counter answer to 0, count to 0
				begin
					enable_counter = 1'b1;
					change_instruction = 1'b1;
					decrease_life = 1'b1;
				end
			START_STATE:
				begin
					change_instruction = 1'b1;
				end
		endcase
	end

	always @(posedge clk) begin : FF_FSM
		if(~rst_n) 
			 CURRENT_STATE<= START_STATE;
		 else 
			 CURRENT_STATE<= NEXT_STATE;
	end


endmodule 