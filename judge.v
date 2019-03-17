module judge (
	input clk,    // Clock
	input prepare_judge, // Clock Enable
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
			NOTHING: NEXT_STATE = prepare_judge ? JUDGE_STATE : NOTHING;
			default: NEXT_STATE = NOTHING;
		endcase
	
	end

	always @(posedge clk) begin : FSM_ASSIGNMENTS
		case(CURRENT_STATE) // load IN JUDGE_WAIT and compare
			JUDGE_WAIT:  
			begin
				cur_input <= user_input;
				answer <= q;
			end
		endcase
	end
	
	always @(posedge clk) begin: FF_FSM
		CURRENT_STATE<= NEXT_STATE;
	end

	mux_compare m1(cur_input, q);

endmodule

module mux_compare(
	input [15:0] user_input,
	output reg q);
	
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

