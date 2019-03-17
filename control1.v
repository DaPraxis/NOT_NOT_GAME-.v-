module control1 (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input key_pressed, //User input new answer, 1 when key is pressed
	input answer, // Returned from judge, 1 when answer matchs the key
	input wait_counter, // Returned from counter, 1 if more than that counting time
	output reg prepare_judge, // Start to prepare judge unit, from Nothing to Judge
	output reg enable_counter, // Start to run transition counter
	output reg change_instruction,
	output reg decrese_life

	
);
	reg [1:0] CURRENT_STATE, NEXT_STATE;


	localparam INSTRUCTION_STATE = 5'b00000,
			   INSTRUCTION_WAIT = 5'b00001,
			   ANSWER_STATE = 5'b00010,
			   WRONG_STATE = 5'b00011,
			   CORRECT_STATE = 5'b00100,
			   CORRECT_WAIT = 5'b00101,
			   WRONG_WAIT = 5'b00110,
			   START_STATE = 5'b00111
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
		decrese_life = 1'b1;
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
					decrese_life = 1'b1;
				end
			START_STATE:
				begin
					change_instruction = 1'b1;
				end
		endcase
	end

	always @(posedge clk) begin : FF_FSM
		if(~rst_n) begin
			 CURRENT_STATE<= START_STATE;
		end else begin
			 CURRENT_STATE<= NEXT_STATE;
		end
	end


endmodule


module judge (
	input clk,    // Clock
	input prepare_judge, // Clock Enable
	input rst_n,  // Asynchronous reset active low
	input key_pressed,
	input [15:0] user_input,
	output reg answer
	
);
	reg [1:0] CURRENT_STATE, NEXT_STATE;
	reg [15:0] cur_input;
	wire q;

	localparam JUDGE_STATE = 2'b00,
			   JUDGE_WAIT = 2'b01,
			   NOTHING = 2'b10;

	always @(*) begin : FSM_JUDGE
		case(CURRENT_STATE)
			JUDGE_STATE: NEXT_STATE = key_pressed ? JUDGE_WAIT : JUDGE_STATE;
			JUDGE_WAIT: NEXT_STATE = key_pressed ? JUDGE_WAIT : NOTHING;
			NOTHING: NEXT_STATE = prepare_judge ? JUDGE_STATE : JUDGE_WAIT;
			default: NEXT_STATE = NOTHING;
		endcase
	
	end

	always @(*) begin : FSM_ASSIGNMENTS
		case(CURRENT_STATE) // load IN JUDGE_WAIT and compare
			JUDGE_WAIT:  
				cur_input <= user_input;
				answer <= q;
		endcase
	
	end

	mux_compare(cur_input, q)

endmodule

module mux_compare(
	input [15:0] user_input,
	output q);
	
	always @(*) begin : compare
		case(user_input)
			16'b0000000000: 
				begin
					q <= 1;
				end
			16'b0000000001:
				begin
					q <= 1;
				end
			default:
				q <= 0;
		endcase
	end

endmodule // module


module counter(
	input enable_counter,
	input clk,
	output reg count_q);

	reg [3:0]count;   // TODO change to ...s
	localparam LIMIT = 4'b111; 

	always @(posedge clk) begin : proc_
		if (enable_counter)
			begin
				count<=4'b0000;
				count_q<=1'b0;
			end
		else
			begin
				count<=count + 1;
				if (count >= LIMIT)
					begin
						count_q <= 1'b1;
					end
			end
	end


endmodule // module

module instruction_shift(
	input change_instruction, 
	input clk,
	output reg [2:0] instruction);
	wire [3:0]random;
	random r1 (clk, 1, random);
	always @(*) begin : proc_
		if (random < 4'd3)
			instruction = 3'b000; // UP
		else if (random < 4'd6)
			instruction = 3'b001; // DOWN
		else if (random < 4'd9)
			instruction = 3'b010; // LEFT
		else if (random < 4'd11)
			instruction = 3'b011; // RIGHT
		else if (random < 4'd13)
			instruction = 3'b100; // VOWEL
		else 
			instruction = 3'b101; // DIGIT
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

module test_control(
	input clk, 
	input key_pressed,
	input reset_control1, 
	input [15:0]user_input,
	output decrese_life,
	output [2:0]instruction
	);
	wire enable_counter, count_q, answer, prepare_judge, decrese_life, change_instruction;
	counter c1 (enable_counter,clk, count_q);
	control1 c0 (clk,reset_control1,key_pressed, answer, count_q,prepare_judge,enable_counter, change_instruction,decrese_life);
	judge j0 (clk, prepare_judge, rst_n, key_pressed, user_input, answer);
	instruction_shift i0(change_instruction, clk, instruction);




endmodule 